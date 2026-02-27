#!/bin/bash
# Script to start the CI/CD application on the EC2 server
# This script should be run on the app server (63.35.216.161)

set -e

echo "=== Starting CI/CD Pipeline Application ==="

# Navigate to application directory
cd /opt/app

# Check if application files exist
if [ ! -f "app.js" ] || [ ! -f "Dockerfile" ] || [ ! -f "docker-compose.yml" ]; then
    echo "Application files not found. Cloning from repository..."
    
    # Clone the application repository (update this URL)
    # You'll need to provide your repository URL
    REPO_URL="${REPO_URL:-https://github.com/your-repo/cicd-pipeline.git}"
    REPO_BRANCH="${REPO_BRANCH:-main}"
    
    git clone -b "$REPO_BRANCH" "$REPO_URL" /opt/app || {
        echo "Failed to clone repository. Please manually copy files to /opt/app"
        exit 1
    }
fi

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    echo "Starting Docker service..."
    systemctl start docker
    systemctl enable docker
fi

# Stop any existing container
echo "Stopping any existing containers..."
docker-compose down 2>/dev/null || true

# Build and start the application
echo "Building and starting the application..."
docker-compose up -d --build

# Verify the container is running
echo "Checking container status..."
docker-compose ps

# Check if application is responding
echo "Checking application health..."
sleep 5

# Test the application endpoint
if curl -s http://localhost:5000/health > /dev/null; then
    echo "✅ Application is running successfully on port 5000!"
    echo "Access the application at: http://63.35.216.161:5000"
else
    echo "⚠️ Application may not be fully started yet. Checking logs..."
    docker-compose logs
fi

echo "=== Setup Complete ==="
