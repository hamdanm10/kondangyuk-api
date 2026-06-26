namespace :api do
  namespace :v1 do
    namespace :super_admin do
      resource  :profile, only: [ :show, :update ]
      resources :users,  only: [ :index, :create ] do
        resource :activation, only: [ :create, :destroy ], controller: "user_activations"
      end
      resources :themes,       only: [ :index, :show, :create, :update, :destroy ]
      resources :tiers,        only: [ :index, :show, :create, :update, :destroy ]
      resources :marketplaces, only: [ :index, :show, :create, :update, :destroy ]
      resources :orders,       only: [ :index, :show, :create, :update, :destroy ]

      namespace :autocomplete do
        resources :themes,       only: [ :index ]
        resources :tiers,        only: [ :index ]
        resources :marketplaces, only: [ :index ]
        resources :templates,    only: [ :index ]
      end

      resources :templates, only: [ :index, :show, :create, :update, :destroy ] do
        resource :document, only: [ :show, :update, :destroy ], controller: "template_documents" do
          resources :media, only: [ :index, :create, :destroy ], controller: "template_document_media"
        end
        resource :thumbnail, only: [ :show, :update, :destroy ], controller: "template_thumbnails"
      end

      # Invitations are created/updated/deleted through their order (Order has_one Invitation).
      # Only the read-only detail and the content sub-resources are addressed directly here, via
      # the invitation id from the order.
      resources :invitations, only: [ :show ] do
        resource :document, only: [ :show, :update, :destroy ], controller: "invitation_documents" do
          resources :media, only: [ :index, :create, :destroy ], controller: "invitation_document_media"
        end
        resource :thumbnail, only: [ :show, :update, :destroy ], controller: "invitation_thumbnails"
      end
    end
  end
end
