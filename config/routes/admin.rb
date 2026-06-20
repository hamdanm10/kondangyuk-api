namespace :api do
  namespace :v1 do
    namespace :admin do
      resource  :profile, only: [ :show ]
      resources :orders,  only: [ :index, :show, :create, :update, :destroy ]

      resources :invitations, only: [ :index, :show, :create, :update, :destroy ] do
        resource :document, only: [ :show, :update, :destroy ], controller: "invitation_documents" do
          resources :media, only: [ :index, :create, :destroy ], controller: "invitation_document_media"
        end
        resource :thumbnail, only: [ :show, :update, :destroy ], controller: "invitation_thumbnails"
      end
    end
  end
end
