#!/bin/bash
# -----------------------------------------------------------------------------
# start_server.sh
# CodeDeploy ApplicationStart Hook Script
# Deletes old process, fetches environment variables from SSM, and starts
# the Node.js application using PM2 (for robust process management).
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/myapp"

# 1. Change to the application directory
cd $APP_DIR

# 2. Define SSM Parameter Store names (These must exist in your AWS Parameter Store)
# NOTE: The EC2 Instance Profile MUST have 'ssm:GetParameter' permission.
DB_HOST_PARAM="/MyApp/DB_HOST"
DB_USER_PARAM="/MyApp/DB_USER"
DB_PASS_PARAM="/MyApp/DB_PASSWORD"

# 3. Fetch environment variables from SSM
# Use 'sudo su - ec2-user' to ensure PM2 is found and run as the correct user if the script fails to run as 'ec2-user' from appspec
# However, since appspec.yml has runas: ec2-user, we run directly.
echo "Fetching DB Credentials from SSM..."
export DB_HOST=$(aws ssm get-parameter --name "$DB_HOST_PARAM" --query "Parameter.Value" --output text)
export DB_USER=$(aws ssm get-parameter --name "$DB_USER_PARAM" --query "Parameter.Value" --output text)
# Note: Use --with-decryption for SecureString passwords
export DB_PASSWORD=$(aws ssm get-parameter --name "$DB_PASS_PARAM" --with-decryption --query "Parameter.Value" --output text)

# Check for successful retrieval
if [ -z "$DB_HOST" ]; then
    echo "ERROR: DB_HOST environment variable is empty. Failed to retrieve SSM parameters."
    exit 1
fi

# 4. Install dependencies (Crucial for the first run if node_modules wasn't deployed)
echo "Installing application dependencies..."
npm install

# 5. Start the application with PM2, passing environment variables
echo "Starting application with PM2..."

# PM2 START Command
# --name: Process name
# --update-env: Updates environment variables on restart
# -- start app.js: The actual command to run, separated by --
pm2 start app.js --name "MyWebApp" --update-env --
pm2 save

echo "Application startup script finished."
