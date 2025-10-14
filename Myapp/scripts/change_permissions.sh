#!/bin/bash
# -----------------------------------------------------------------------------
# change_permissions.sh (CRITICAL FIX)
# This script ensures the target directory is clean and properly owned,
# fixing the "Not a directory" error caused by stale files.
# -----------------------------------------------------------------------------

APP_DIR="/home/ec2-user/myapp"
APP_USER="ec2-user"

echo "CRITICAL: Cleaning up any stale file/directory at ${APP_DIR}."

# 1. CRITICAL STEP: Remove any existing file or directory at the target path.
# This fixes the "Not a directory" error if a file named 'myapp' exists.
if [ -e "$APP_DIR" ]; then
    echo "Stale entry found at ${APP_DIR}. Deleting it now."
    rm -rf "$APP_DIR"
fi

# 2. Create the application directory
echo "Creating clean application directory: ${APP_DIR}"
mkdir -p "$APP_DIR"

# 3. Set ownership recursively to ec2-user
echo "Setting ownership of ${APP_DIR} to ${APP_USER}:${APP_USER}"
chown -R "$APP_USER":"$APP_USER" "$APP_DIR"

# 4. Set read/write/execute permissions for the owner
echo "Setting directory permissions."
chmod -R 755 "$APP_DIR"

echo "Permissions setup complete."
