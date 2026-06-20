namespace :api do
  namespace :v1 do
    namespace :guest do
      resource  :session, only: [ :create, :destroy ]
      resources :invitations, only: [ :show ], param: :slug
      resources :templates,   only: [ :index, :show ], param: :slug
    end
  end
end
