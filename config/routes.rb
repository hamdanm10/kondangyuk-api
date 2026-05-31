Rails.application.routes.draw do
  if Rails.env.development? || Rails.env.test?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resource  :session, only: [ :create, :destroy ]
      resource  :profile, only: [ :show ]
      resources :users,   only: [ :index, :create ]
      resources :themes,  only: [ :index, :show, :create, :update, :destroy ]
      resources :tiers,   only: [ :index, :show, :create, :update, :destroy ]
    end
  end
end
