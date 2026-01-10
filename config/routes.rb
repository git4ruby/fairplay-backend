require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq Web UI (protect this in production)
  mount Sidekiq::Web => '/sidekiq'

  # Devise routes for authentication
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # API routes
  namespace :api do
    namespace :v1 do
      # Clubs with nested courts
      resources :clubs do
        resources :courts
      end

      # Matches with nested reviews
      resources :matches do
        resources :reviews, only: [:index, :create]
      end

      # Reviews (disputes)
      resources :reviews, only: [:show, :update]
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
