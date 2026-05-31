Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource  :session, only: [ :create, :destroy ]
      resource  :profile, only: [ :show ]
      resources :users,   only: [ :index ]
    end
  end
end
