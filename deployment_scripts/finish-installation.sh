#!/bin/bash

# Load environment variables
source /etc/profile

# Print deployment info
DEPLOYMENT_TIME=$( date -u "+%Y/%m/%d %H:%M:%S" )
echo "Deployment finished at: "$DEPLOYMENT_TIME" UTC" > /home/deploy/mvp-1oh1/public/deployment_time.txt

# Arrange folder permissions
chown -R deploy:deploy /home/deploy/mvp-1oh1
chmod -R 775 /home/deploy/mvp-1oh1

service nginx restart
