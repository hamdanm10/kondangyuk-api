namespace :api do
  namespace :v1 do
    namespace :super_admin do
      resources :users,  only: [ :index, :create ]
      resources :themes, only: [ :index, :show, :create, :update, :destroy ]
      resources :tiers,  only: [ :index, :show, :create, :update, :destroy ]

      resources :templates, only: [ :index, :show, :create, :update, :destroy ] do
        resource :document, only: [ :show, :update, :destroy ], controller: "template_documents" do
          resources :media, only: [ :index, :create, :destroy ], controller: "template_document_media"
        end
        resource :thumbnail, only: [ :show, :update, :destroy ], controller: "template_thumbnails"
      end
    end
  end
end
