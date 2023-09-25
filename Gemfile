source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3', '~> 1.3', '< 1.4'
gem 'pg'

gem 'rails_12factor'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'
# gem 'jquery-easing-rails'
gem 'friendly_id', '~> 5.2'
gem 'material_icons'
gem 'psych', '< 4'
gem 'bootstrap'


gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'

gem 'city-state'
gem 'language_list', '~> 1.1'
gem 'countries', :require => 'countries/global'

gem 'timezone' #backend
gem 'local_time' #frontend

gem 'sidekiq'
gem 'chartjs-ror'

gem 'filterrific'
gem 'will_paginate'
gem 'kaminari'
gem 'ransack' #gem for advanced search

gem 'rest-client'

gem 'ahoy_matey' #track metrics

gem 'simple_form'
gem 'faker'
# Authentication gem
gem 'devise'
# Authorisation gem
gem 'cancancan'
gem 'rolify'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

gem 'stripe'
gem 'ice_cube'
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 3.0"
# gem 'redis-namespace'
# gem 'redis-rails'
# gem 'redis-rack-cache'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'figaro'
gem 'ed25519', '>= 1.2', '< 2.0'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'

# gem 'bullet', group: 'development'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano'
  gem 'capistrano3-puma'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-postgresql', '~> 6.2'
  gem 'capistrano-rvm'
  gem 'capistrano-sidekiq'
  gem 'rails-erd'
end

# group :production do
#   gem 'bundler', '~> 2.1.2'
# end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
