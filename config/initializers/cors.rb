Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Array(Rails.application.credentials.cors_origins).compact)

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end