Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :game, only: [:index]
      resources :time, only: [:index]
    end
  end
  mount ActionCable.server => '/cable'
end
