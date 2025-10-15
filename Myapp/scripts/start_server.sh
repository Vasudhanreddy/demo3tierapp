#!/bin/bash
# -----------------------------------------------------------------------------
# start_server.sh - FINAL ROBUST VERSION
# Assumes runas: ec2-user in appspec.yml to resolve binary paths.
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/myapp"

# 1. Change to the application directory
cd $APP_DIR

# 2. Get DB credentials from AWS Parameter Store.
# Reliance on 'runas: ec2-user' in appspec.yml for AWS CLI to be found.
echo "Fetching DB Credentials from SSM..."
export DB_HOST=$(aws ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text)
export DB_USER=$(aws ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text)
export DB_PASSWORD=$(aws ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text)

# 3. Install dependencies (npm should be in PATH for ec2-user)
echo "Installing application dependencies..."
npm install

# 4. Install PM2 globally (guarantees pm2 is available for the next command)
echo "Installing PM2 globally..."
npm install -g pm2

# 5. Start the application with PM2
echo "Starting application with PM2..."
# PM2 is now in the PATH, and app.js is fixed not to exit on DB failure.
pm2 start app.js --name "MyWebApp" --update-env
pm2 save

echo "Application startup script finished successfully."
