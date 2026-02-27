#!/bin/bash
# Script to install Jenkins on Amazon Linux 2 EC2 instance
# Assumes Docker is already installed for building container images

# Install Java 11 OpenJDK (required by Jenkins)
sudo yum install -y java-11-openjdk

# Download and add the Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# Import the Jenkins repository GPG key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins

# Start Jenkins service and enable it to start on boot
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Add the 'jenkins' user to the 'docker' group to allow Jenkins to run Docker commands
sudo usermod -a -G docker jenkins
# Restart Jenkins to apply group membership changes
sudo systemctl restart jenkins

echo "Jenkins installed! Access it at http://YOUR_EC2_IP:8080"
echo "Initial admin password below is required for first-time setup:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword