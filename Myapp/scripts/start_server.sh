#!/bin/bash
cd /home/ec2-user/myapp

# Get DB credentials from AWS Parameter Store
export DB_HOST=$(aws ssm get-parameter --name "/MyApp/DB_HOST" --query "Parameter.Value" --output text --region us-east-1)
export DB_USER=$(aws ssm get-parameter --name "/MyApp/DB_USER" --query "Parameter.Value" --output text --region us-east-1)
export DB_PASSWORD=$(aws ssm get-parameter --name "/MyApp/DB_PASSWORD" --with-decryption --query "Parameter.Value" --output text --region us-east-1)

# Install app dependencies and start the app with PM2
npm install
pm2 start app.js --name "MyWebApp" --update-env
pm2 save
