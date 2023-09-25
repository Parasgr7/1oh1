#!/bin/bash

# Remove if previous deployment folder exists
rm -rf /home/deploy/mvp-1oh1/pre-current

# Backup current deployment
mv /home/deploy/mvp-1oh1/current /home/deploy/mvp-1oh1/pre-current

# Create new deployment folder and make deploy owner
mkdir /home/deploy/mvp-1oh1/current

chown deploy:deploy /home/deploy/mvp-1oh1/current
