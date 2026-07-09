namespace :api do
  namespace :v1 do
    namespace :designer do
      resource :profile, only: [ :show, :update ]
    end
  end
end
