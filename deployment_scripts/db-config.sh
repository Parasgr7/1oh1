#!/bin/bash

# Go to the deployment directory
cd /home/deploy/mvp-1oh1

# Remove if there is an existing database configuration
rm -f config/database.yml

# Link the database configuration to shared db config file
ln -s /home/deploy/mvp-1oh1/shared/config/database.yml config/database.yml
