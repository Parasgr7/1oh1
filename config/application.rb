require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mvp1oh1
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    # config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
    #for development comment it
    config.autoload_paths += %W(#{config.root}/lib)
    config.active_job.queue_adapter = :sidekiq
    config.exceptions_app = self.routes
  end
end
