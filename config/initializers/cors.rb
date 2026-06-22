Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    configured_origins = Array(Rails.application.credentials.dig(:cors, :allowed_origins))
    development_origins = [ "http://localhost:5173", "http://127.0.0.1:5173" ]
    allowed_origins = configured_origins.presence || (Rails.env.local? ? development_origins : [])

    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 600
  end
end
