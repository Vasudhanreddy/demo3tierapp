#!/bin/bash
# -----------------------------------------------------------------------------
# start_server.sh (Updated & Recommended Version)
# Combines robust error checking with correct user permissions and region settings.
# -----------------------------------------------------------------------------

# --- CONFIGURATION ---
APP_DIR="/home/ec2-user/myapp"
# !! IMPORTANT: Set this to your AWS region, e.g., "us-east-1", "eu-west-2", etc. !!
AWS_REGION="us-east-1"

# --- SCRIPT START ---
echo "Running ApplicationStart hook script..."
cd $APP_DIR || { echo "ERROR: Failed to change to directory $APP_DIR"; exit 1; }

# 1. Fetch environment variables from SSM Parameter Store
echo "Fetching DB Credentials from SSM in region $AWS_REGION..."
export DB_HOST=$(aws ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text --region $AWS_REGION)
export DB_USER=$(aws ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text --region $AWS_REGION)
export DB_PASSWORD=$(aws ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text --region $AWS_REGION)

# 2. Check for successful parameter retrieval
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "ERROR: One or more SSM parameters could not be retrieved. Deployment failed."
    # A non-zero exit code tells CodeDeploy the script failed.
    exit 1
fi
echo "Successfully fetched DB credentials."

# 3. Install/update application dependencies
echo "Installing application dependencies with npm..."
npm install

# 4. Start the application as the 'ec2-user' to avoid running as root
echo "Starting application with PM2 as ec2-user..."
# Using 'sudo -u ec2-user' is the best practice to run the app as a non-privileged user
sudo -u ec2-user pm2 start app.js --name "MyWebApp" --update-env
sudo -u ec2-user pm2 save

echo "Application startup script finished successfully."
# Exit with 0 to signal success to CodeDeploy
exit 0

