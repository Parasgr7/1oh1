#!/bin/bash

# Go to the deployment directory
cd /home/deploy/mvp-1oh1

# Get temporaray credentials for AWS CodeCommit
# - Remember that the instance must have access rights to the CodeCommit repositories in Gemfile.
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

# Install gems using bundler
# - Bundle location: /var/www/pisirpaylas/shared/bundle
# - Binary location: /var/www/pisirpaylas/shared/bin
# - Without development and test gems
# - Using gemfile in current directory
# - Also quietly. No need to generate all logs.
# RAILS_ENV=production bundle install --binstubs /home/deploy/mvp-1oh1/shared/bin --gemfile ./Gemfile --path /home/deploy/mvp-1oh1/shared/bundle --without development test --deployment --quiet
~/.rvm/bin/rvm ruby-2.3.3 do bundle install --path /home/deploy/mvp-1oh1/shared/bundle --jobs 4 --without development test --deployment --quiet
