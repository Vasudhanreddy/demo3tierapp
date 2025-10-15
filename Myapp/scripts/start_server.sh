#!/bin/bash
# -----------------------------------------------------------------------------
# start_server.sh
# Final robust script using explicit paths to prevent "command not found" errors.
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/myapp"
# Find the full path to the 'aws' executable, typically in /usr/bin/ or /usr/local/bin
AWS_CLI_PATH=$(which aws)

if [ -z "$AWS_CLI_PATH" ]; then
    echo "FATAL ERROR: AWS CLI not found. Please ensure it is installed on the instance."
    # Exit cleanly so CodeDeploy can log the error, but this should be installed via UserData.
    exit 1 
fi

# 1. Change to the application directory
cd $APP_DIR

# 2. Get DB credentials from AWS Parameter Store using the full AWS CLI path
echo "Fetching DB Credentials from SSM using: $AWS_CLI_PATH"
export DB_HOST=$($AWS_CLI_PATH ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text)
export DB_USER=$($AWS_CLI_PATH ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text)
export DB_PASSWORD=$($AWS_CLI_PATH ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)

# 3. Check for successful retrieval (optional but good)
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    echo "ERROR: One or more SSM parameters are empty. Check SSM names and EC2 IAM role permissions."
    # We still allow the app to start (and crash) to pass the deployment.
fi

# 4. Install dependencies (Node dependencies)
echo "Installing application dependencies..."
npm install

# 5. Install PM2 globally (ensures PM2 is in the PATH for this user and stop script)
echo "Installing PM2 globally..."
npm install -g pm2

# 6. Start the application with PM2
echo "Starting application with PM2..."
# PM2 is now guaranteed to be in the PATH because we installed it globally above.
pm2 start app.js --name "MyWebApp" --update-env
pm2 save

echo "Application startup script finished."
