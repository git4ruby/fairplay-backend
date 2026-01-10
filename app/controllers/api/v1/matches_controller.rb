module Api
  module V1
    class MatchesController < BaseController
      before_action :set_match, only: [:show, :update, :destroy]
      before_action :authorize_match_participant, only: [:update, :destroy]

      def index
        @matches = Match.includes(:court, :players, :reviews).all
        render json: @matches.as_json(
          include: {
            court: { include: :club },
            players: { only: [:id, :email, :first_name, :last_name] },
            reviews: { only: [:id, :status, :decision, :confidence] }
          }
        ), status: :ok
      end

      def show
        render json: @match.as_json(
          include: {
            court: { include: :club },
            players: { only: [:id, :email, :first_name, :last_name] },
            reviews: { only: [:id, :status, :decision, :confidence, :video_url] }
          }
        ), status: :ok
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

      private

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
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end
