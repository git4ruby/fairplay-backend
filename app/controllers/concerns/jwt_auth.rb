module JwtAuth
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    attr_reader :current_user
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    return render_unauthorized('Missing Authorization header') unless header.present?

    # Extract token from "Bearer TOKEN" format
    token = header.to_s.split(' ').last
    Rails.logger.debug "Auth header: #{header.inspect}, Token: #{token[0..20]}..."

    begin
      decoded = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256' })
      @current_user = User.find(decoded[0]['sub'])
      Rails.logger.debug "Successfully authenticated user: #{@current_user.email}"
    rescue StandardError => e
      Rails.logger.error "JWT Auth Error: #{e.class} - #{e.message}"
      render_unauthorized("Invalid token: #{e.message}")
    end
  end

  def render_unauthorized(message = 'Unauthorized')
    render json: { error: message }, status: :unauthorized
  end
end
