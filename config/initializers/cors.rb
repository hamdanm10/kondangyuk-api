Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Array(Rails.application.credentials.dig(:cors, :allowed_origins)))

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 600
  end
end
