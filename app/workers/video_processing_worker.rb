class VideoProcessingWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform(review_id)
    review = Review.find(review_id)

    begin
      review.update!(status: :processing)

      Rails.logger.info "Processing video for review #{review_id}: #{review.video_url}"

      # Get court type from match
      court_type = review.match.match_type # "singles" or "doubles"

      # Call Python CV microservice
      cv_service_url = ENV.fetch("CV_SERVICE_URL", "http://localhost:8000")
      response = call_cv_service(review.video_url, court_type, cv_service_url)

      # Update review with results from CV service
      review.update!(
        decision: response["decision"].downcase.to_sym,
        confidence: (response["confidence"] * 100).round,
        landing_x: response["landing_x"],
        landing_y: response["landing_y"],
        landing_frame_url: response["landing_frame_url"],
        status: :processed
      )

      Rails.logger.info "Completed processing review #{review_id}: #{response["decision"]} (confidence: #{response["confidence"]})"
    rescue StandardError => e
      Rails.logger.error "Failed to process review #{review_id}: #{e.message}"
      review.update!(status: :failed)
      raise e
    end
  end

  private

  def call_cv_service(video_url, court_type, cv_service_url)
    require "net/http"
    require "json"
    require "uri"

    uri = URI.parse("#{cv_service_url}/analyze")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 60 # 60 second timeout

    request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
    request.body = {
      video_url: video_url,
      court_type: court_type
    }.to_json

    Rails.logger.info "Calling CV service: #{uri}"

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "CV service error: #{response.code} - #{response.body}"
    end

    JSON.parse(response.body)
  end
end
