# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( '.ttf','.woff' )
Rails.application.config.assets.precompile += %w( filterrific/filterrific-spinner.gif )

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( calendars.css sessions.css calendars.js chests.js chests.css profile_builder.js sessions.js signaling-server.js headscript.js messages.js messages.css home.js home.css reservation.js)
