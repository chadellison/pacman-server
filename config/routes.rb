Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: :json do
      resources :players, only: [:index]
    end
  end
  mount ActionCable.server => '/cable'
end
