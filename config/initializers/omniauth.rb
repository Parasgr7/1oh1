Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, Rails.application.secrets.google_client_id, Rails.application.secrets.google_client_secret, skip_jwt: true
  provider :facebook, Rails.application.secrets.facebook_client_id, Rails.application.secrets.facebook_client_secret, skip_jwt: true
  OmniAuth.config.full_host = Rails.env.production? ? 'https://www.1oh1.org' : 'http://localhost:3000'
end
