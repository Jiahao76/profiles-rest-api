#!/usr/bin/env bash

set -e  # Exit on any error

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

# Ensure distutils is installed (optional if already done in setup)
apt-get install -y python3.12-venv

# Navigate to project directory
cd $PROJECT_BASE_PATH

# Pull latest changes
git pull

# Use virtual environment explicitly to run Django commands
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

# Restart app via supervisor
supervisorctl restart profiles_api

echo "DONE! :)"
