#!/bin/bash

# Go to the deployment directory
cd /home/deploy/mvp-1oh1

# Load environment variables
source /etc/profile

# Run asset precompilation
# - No need to run assets:clobber because this is a new folder. There should be none. We compile assets from the beginning in all deployments.
# RAILS_ENV=production bundle exec rake assets:precompile
~/.rvm/bin/rvm ruby-2.3.3 do bundle exec rake assets:precompile
