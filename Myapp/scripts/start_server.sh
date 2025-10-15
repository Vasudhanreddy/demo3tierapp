#!/bin/bash
# -----------------------------------------------------------------------------
# start_server.sh - ULTIMATE PATH FIX
# This version ensures PM2 is installed locally and executed via its absolute 
# path within node_modules to bypass all PATH environment issues.
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/Myapp"

# 1. Change to the application directory
cd $APP_DIR

# 2. Get DB credentials from AWS Parameter Store.
# Relying on 'aws' being in the PATH (must be available in the EC2 user profile).
echo "Fetching DB Credentials from SSM..."
export DB_HOST=$(aws ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text)
export DB_USER=$(aws ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text)
export DB_PASSWORD=$(aws ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)

# 3. Install dependencies and PM2 locally
echo "Installing application dependencies and PM2 locally..."
# npm install runs first to get express and mysql
npm install
# Install PM2 locally so we can run it from the local binary path
npm install pm2 --silent

# Define the local binary path
PM2_LOCAL_BIN="./node_modules/.bin/pm2"

# 4. Start the application using the LOCAL PM2 path
echo "Starting application with PM2 using local binary path: ${PM2_LOCAL_BIN}"
# Use the guaranteed local path to execute PM2
$PM2_LOCAL_BIN start app.js --name "MyWebApp" --update-env
$PM2_LOCAL_BIN save

echo "Application startup script finished successfully."
