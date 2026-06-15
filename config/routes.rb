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
      resources :orders, only: [ :index, :show, :create, :update, :destroy ]

      resources :templates, only: [ :index, :show, :create, :update, :destroy ] do
        resource :document, only: [ :show, :update, :destroy ], controller: "template_documents" do
          resources :media, only: [ :index, :create, :destroy ], controller: "template_document_media"
        end
        resource :thumbnail, only: [ :show, :update, :destroy ], controller: "template_thumbnails"
      end

      resources :invitations, only: [ :index, :show, :create, :update, :destroy ] do
        resource :document, only: [ :show, :update, :destroy ], controller: "invitation_documents" do
          resources :media, only: [ :index, :create, :destroy ], controller: "invitation_document_media"
        end
        resource :thumbnail, only: [ :show, :update, :destroy ], controller: "invitation_thumbnails"
      end

      namespace :public do
        resources :invitations, only: [ :show ], param: :slug
      end
    end
  end
end
