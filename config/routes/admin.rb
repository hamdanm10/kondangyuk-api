namespace :api do
  namespace :v1 do
    namespace :admin do
      resource :profile, only: [ :show, :update ]
    end
  end
end
