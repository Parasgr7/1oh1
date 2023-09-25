Sidekiq.configure_server do |config|
  if Rails.env.development?
    uri = "redis://localhost:6379/0"
  else
    uri = ENV["REDISTOGO_URL"]
  end
  config.redis = { url: uri }
end

Sidekiq.configure_client do |config|
  if Rails.env.development?
    uri = "redis://localhost:6379/0"
  else
    uri = ENV["REDISTOGO_URL"]
  end
  config.redis = { url: uri }
end
