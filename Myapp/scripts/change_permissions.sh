#!/bin/bash
# -----------------------------------------------------------------------------
# change_permissions.sh
# CodeDeploy BeforeInstall Hook Script
#
# This script ensures the target application directory exists and sets the
# correct ownership (ec2-user) and permissions before the new files are
# copied by the CodeDeploy agent.
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/myapp"
APP_USER="ec2-user"

echo "Checking and setting up application directory: ${APP_DIR}"

# 1. Create the application directory if it does not exist
if [ ! -d "$APP_DIR" ]; then
    echo "Directory ${APP_DIR} does not exist. Creating it now."
    mkdir -p "$APP_DIR"
fi

# 2. Set ownership recursively to ec2-user
# This is crucial for subsequent scripts (ApplicationStart) run as 'ec2-user'
echo "Setting ownership of ${APP_DIR} to ${APP_USER}:${APP_USER}"
chown -R "$APP_USER":"$APP_USER" "$APP_DIR"

# 3. Set read/write/execute permissions for the owner, and read/execute for others
echo "Setting directory permissions."
chmod -R 755 "$APP_DIR"

echo "Permissions setup complete."
