module Api
  module V1
    class ReviewsController < BaseController
      before_action :set_match, only: [:index, :create]
      before_action :set_review, only: [:show, :update]
      before_action :authorize_match_participant, only: [:create]
      before_action :authorize_review_owner, only: [:update]

      def index
        @reviews = @match.reviews.includes(:user)
        render json: @reviews.as_json(include: { user: { only: [:id, :email, :first_name, :last_name] } }), status: :ok
      end

      def show
        render json: @review.as_json(include: { user: { only: [:id, :email, :first_name, :last_name] }, match: { include: :court } }), status: :ok
      end

      def create
        @review = @match.reviews.build(review_params)
        @review.user = current_user

        if @review.save
          VideoProcessingWorker.perform_async(@review.id)
          render json: @review, status: :created
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @review.update(review_params)
          render json: @review, status: :ok
        else
          render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_match
        @match = Match.find(params[:match_id])
      end

      def set_review
        @review = Review.find(params[:id])
      end

      def review_params
        params.require(:review).permit(:video_url, :video, :decision, :confidence, :status)
      end

      def authorize_match_participant
        unless @match.players.include?(current_user) || current_user_admin?
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def authorize_review_owner
        unless @review.user == current_user || current_user_admin?
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end
