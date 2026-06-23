namespace :api do
  namespace :v1 do
    namespace :super_admin do
      resource  :profile, only: [ :show ]
      resources :users,  only: [ :index, :create ]
      resources :themes, only: [ :index, :show, :create, :update, :destroy ]
      resources :tiers,  only: [ :index, :show, :create, :update, :destroy ]
      resources :orders, only: [ :index, :show, :create, :update, :destroy ]

      namespace :autocomplete do
        resources :themes, only: [ :index ]
        resources :tiers,  only: [ :index ]
      end

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
    end
  end
end
