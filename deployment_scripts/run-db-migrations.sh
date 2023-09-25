#!/bin/bash

# Load environment variables
source /etc/profile

# Go to the deployment directory
cd /home/deploy/mvp-1oh1

# Run migrations in production
# RAILS_ENV=production bundle exec rake db:migrate
~/.rvm/bin/rvm ruby-2.3.3 do bundle exec rake db:migrate
