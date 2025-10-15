#!/bin/bash
# -----------------------------------------------------------------------------
# start_server.sh - ULTIMATE PATH FIX
# This version explicitly finds and uses the absolute path for NPM and PM2.
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/myapp"

# 1. Find the absolute path for critical binaries
# NOTE: This runs 'which' in the simple shell environment.
NPM_PATH=$(which npm)
AWS_CLI_PATH=$(which aws)

if [ -z "$NPM_PATH" ]; then
    echo "FATAL ERROR: NPM not found in the PATH. Check Node/NPM installation."
    # We must exit, as we can't install dependencies or PM2.
    exit 1
fi
if [ -z "$AWS_CLI_PATH" ]; then
    echo "WARNING: AWS CLI not found. SSM credential fetch will likely fail."
fi

# 2. Change to the application directory
cd $APP_DIR

# 3. Get DB credentials from AWS Parameter Store.
# Use the found path if available, otherwise rely on the default PATH (may fail).
echo "Fetching DB Credentials from SSM..."
if [ -n "$AWS_CLI_PATH" ]; then
    export DB_HOST=$($AWS_CLI_PATH ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text)
    export DB_USER=$($AWS_CLI_PATH ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text)
    export DB_PASSWORD=$($AWS_CLI_PATH ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)
else
    echo "Fallback: Attempting credential fetch using simple 'aws' call (HIGH FAILURE RISK)."
    export DB_HOST=$(aws ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text)
    export DB_USER=$(aws ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text)
    export DB_PASSWORD=$(aws ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)
fi


# 4. Install dependencies using the absolute NPM path
echo "Installing application dependencies..."
$NPM_PATH install

# 5. Install PM2 globally using the absolute NPM path
echo "Installing PM2 globally..."
$NPM_PATH install -g pm2

# 6. Start the application with PM2
echo "Starting application with PM2..."
# PM2 is installed globally, so it should now be in the shell's PATH for the ec2-user.
pm2 start app.js --name "MyWebApp" --update-env
pm2 save

echo "Application startup script finished successfully."
