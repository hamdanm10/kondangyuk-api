Rails.application.routes.draw do
  if Rails.env.development? || Rails.env.test?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end
  get "up" => "rails/health#show", as: :rails_health_check

  # Routes are split per role under config/routes/<role>.rb
  draw(:guest)
  draw(:admin)
  draw(:super_admin)
  draw(:designer)
end
