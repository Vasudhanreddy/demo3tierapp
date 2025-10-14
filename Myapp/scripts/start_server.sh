#!/bin/bash
# start_server.sh
# CodeDeploy ApplicationStart Hook Script (Run as ec2-user)
#
# This script fetches database credentials from AWS SSM, sets them as
# environment variables, and starts the Node.js application using PM2.
#
# Note: npm install should typically run during the CodeBuild stage,
# but it is kept here for deployment simplicity if dependencies change.

APP_DIR="/home/ec2-user/myapp"
# Ensure common path is available for tools like 'aws'
export PATH=$PATH:/usr/bin:/usr/local/bin

echo "--- Starting Application (PID: $$) ---"
cd $APP_DIR

# 1. Fetch DB Credentials from AWS Parameter Store (Requires IAM permissions)
echo "Fetching DB Credentials from SSM..."
# Use correct region if environment variable is available
AWS_REGION=${AWS_REGION:-us-east-1}

# Fetch secrets using AWS CLI
DB_HOST=$(aws ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text --region $AWS_REGION)
DB_USER=$(aws ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text --region $AWS_REGION)
DB_PASSWORD=$(aws ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)

# Basic error checking for secrets retrieval
if [ -z "$DB_HOST" ]; then
    echo "ERROR: DB_HOST (SSM) retrieval failed or returned empty value. Exiting."
    exit 1
fi

echo "DB Host retrieved successfully."

# 2. Set Environment Variables
export DB_HOST=$DB_HOST
export DB_USER=$DB_USER
export DB_PASSWORD=$DB_PASSWORD
export PORT=3000 # Example port, adjust as needed

# 3. Optional: Install Dependencies (Only if not done in CodeBuild)
# If you are still having issues with missing node_modules, uncomment this line:
# echo "Running npm install..."
# npm install

# 4. Start the application using PM2
echo "Stopping any previous PM2 instance of MyWebApp..."
# Use /usr/bin/env to ensure PM2 is found in the shell's PATH
/usr/bin/env pm2 stop MyWebApp || true

echo "Starting app.js with PM2..."
/usr/bin/env pm2 start app.js --name "MyWebApp" --update-env

# Save the process list for persistence across reboots
/usr/bin/env pm2 save

echo "--- Application Start Complete ---"
