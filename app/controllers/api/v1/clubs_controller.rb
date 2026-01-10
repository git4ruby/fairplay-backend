module Api
  module V1
    class ClubsController < BaseController
      before_action :set_club, only: [:show, :update, :destroy]
      before_action :authorize_club_owner, only: [:update, :destroy]

      def index
        @clubs = Club.includes(:owners, :courts).all
        render json: @clubs.as_json(include: { owners: { only: [:id, :email, :first_name, :last_name] }, courts: { only: [:id, :name, :surface_type] } }), status: :ok
      end

      def show
        render json: @club.as_json(include: { owners: { only: [:id, :email, :first_name, :last_name] }, courts: { only: [:id, :name, :surface_type] } }), status: :ok
      end

      def create
        @club = Club.new(club_params)

        if @club.save
          @club.owners << current_user
          render json: @club, status: :created
        else
          render json: { errors: @club.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @club.update(club_params)
          render json: @club, status: :ok
        else
          render json: { errors: @club.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @club.destroy
        head :no_content
      end

      private

      def set_club
        @club = Club.find(params[:id])
      end

      def club_params
        params.require(:club).permit(:name, :address, :latitude, :longitude, :no_of_courts, :email, :phone_number)
      end

      def authorize_club_owner
        unless @club.owners.include?(current_user) || current_user_admin?
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end
