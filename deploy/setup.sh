#!/usr/bin/env bash

set -e

PROJECT_GIT_URL='https://github.com/Jiahao76/profiles-rest-api.git'
PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "Installing dependencies..."
apt-get update
apt-get install -y \
    python3-dev \
    python3.12-venv \
    python3-pip \
    sqlite3 \
    supervisor \
    nginx \
    git \
    build-essential \
    libpcre3 \
    libpcre3-dev \
    libssl-dev

echo "Cloning project..."
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH

echo "Creating virtual environment..."
python3 -m venv $PROJECT_BASE_PATH/env

echo "Installing Python packages..."
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt
$PROJECT_BASE_PATH/env/bin/pip install gunicorn

echo "Running Django setup tasks..."
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

echo "Configuring Supervisor..."
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

echo "Configuring Nginx..."
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
