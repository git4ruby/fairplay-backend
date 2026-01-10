module Api
  module V1
    class CourtsController < BaseController
      before_action :set_club
      before_action :set_court, only: [:show, :update, :destroy]
      before_action :authorize_club_owner, only: [:create, :update, :destroy]

      def index
        @courts = @club.courts
        render json: @courts, status: :ok
      end

      def show
        render json: @court, status: :ok
      end

      def create
        @court = @club.courts.build(court_params)

        if @court.save
          render json: @court, status: :created
        else
          render json: { errors: @court.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @court.update(court_params)
          render json: @court, status: :ok
        else
          render json: { errors: @court.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @court.destroy
        head :no_content
      end

      private

      def set_club
        @club = Club.find(params[:club_id])
      end

      def set_court
        @court = @club.courts.find(params[:id])
      end

      def court_params
        params.require(:court).permit(:name, :surface_type, :description)
      end

      def authorize_club_owner
        unless @club.owners.include?(current_user) || current_user_admin?
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end
