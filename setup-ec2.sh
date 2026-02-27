#!/bin/bash
# Script to install Docker on an Amazon Linux 2 EC2 instance
# This should be run on the application server

# Update system packages
sudo yum update -y

# Install Docker engine
sudo yum install -y docker

# Start Docker service and enable it to start on boot
sudo systemctl start docker
sudo systemctl enable docker

# Add the default ec2-user to the docker group to run docker without sudo
sudo usermod -a -G docker ec2-user

echo "Docker installed! Please logout and login again for group changes to take effect."