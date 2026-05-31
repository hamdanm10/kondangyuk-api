Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource  :session, only: [ :create, :destroy ]
      resource  :profile, only: [ :show ]
      resources :users,   only: [ :index, :create ]
      resources :themes,  only: [ :index ]
    end
  end
end
