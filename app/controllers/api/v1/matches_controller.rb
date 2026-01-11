module Api
  module V1
    class MatchesController < BaseController
      before_action :set_match, only: [ :show, :update, :destroy, :upload_video, :videos ]
      before_action :authorize_match_participant, only: [ :update, :destroy, :upload_video ]

      def index
        @matches = Match.includes(:court, :players, :reviews).all
        render json: @matches.as_json(
          include: {
            court: { include: :club },
            players: { only: [ :id, :email, :first_name, :last_name ] },
            reviews: { only: [ :id, :status, :decision, :confidence ] }
          }
        ), status: :ok
      end

      def show
        match_data = @match.as_json(
          include: {
            court: { include: :club },
            players: { only: [ :id, :email, :first_name, :last_name ] },
            reviews: { only: [ :id, :status, :decision, :confidence, :video_url ] }
          }
        )

        # Add video information
        match_data["videos"] = @match.videos.map { |video| video_json(video) }
        match_data["video_count"] = @match.videos.count

        render json: match_data, status: :ok
      end

      def create
        @match = Match.new(match_params)

        if @match.save
          add_players if params[:player_ids].present?
          render json: @match, status: :created
        else
          render json: { errors: @match.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @match.update(match_params)
          render json: @match, status: :ok
        else
          render json: { errors: @match.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @match.destroy
        head :no_content
      end

      # Upload video to match
      def upload_video
        if params[:video].present?
          # Attach video
          @match.videos.attach(params[:video])

          # Save match to persist the attachment (skip validations to avoid player count issues)
          @match.save(validate: false)
          @match.reload

          # Get the attached video with URL
          latest_video = @match.videos.last

          if latest_video
            video_data = video_json(latest_video)
          else
            video_data = { message: "Video attachment failed" }
          end

          render json: {
            message: "Video uploaded successfully",
            video_count: @match.videos.count,
            latest_video: video_data
          }, status: :created
        else
          render json: { error: "No video file provided" }, status: :unprocessable_entity
        end
      end

      # List all videos for a match
      def videos
        videos_data = @match.videos.map { |video| video_json(video) }
        render json: {
          match_id: @match.id,
          video_count: @match.videos.count,
          videos: videos_data
        }, status: :ok
      end

      private

      def video_json(video)
        {
          id: video.id,
          filename: video.filename.to_s,
          content_type: video.content_type,
          byte_size: video.byte_size,
          url: video.url,  # Direct S3 URL
          created_at: video.created_at
        }
      end

      def set_match
        @match = Match.find(params[:id])
      end

      def match_params
        params.require(:match).permit(:court_id, :match_type, :status, :scheduled_at, :team1_score, :team2_score)
      end

      def add_players
        player_ids = params[:player_ids]
        team_assignments = params[:team_assignments] || {}

        player_ids.each_with_index do |player_id, index|
          team_number = team_assignments[player_id.to_s] || (index < (@match.singles? ? 1 : 2) ? 1 : 2)
          @match.match_players.create(user_id: player_id, team_number: team_number)
        end
      end

      def authorize_match_participant
        unless @match.players.include?(current_user) || current_user_admin?
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      end
    end
  end
end
