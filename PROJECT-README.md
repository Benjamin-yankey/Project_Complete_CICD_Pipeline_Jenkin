# Complete CI/CD Pipeline with Jenkins

[![Jenkins](https://img.shields.io/badge/Jenkins-LTS-red)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green)](https://nodejs.org/)
[![AWS](https://img.shields.io/badge/AWS-EC2-orange)](https://aws.amazon.com/)

A production-ready CI/CD pipeline implementation using Jenkins, Docker, and AWS EC2 that automates the build, test, containerization, and deployment of a Node.js web application.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Pipeline Stages](#pipeline-stages)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)
- [Testing](#testing)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Evidence & Screenshots](#evidence--screenshots)
- [Cleanup](#cleanup)
- [Contributing](#contributing)

## 🎯 Overview

This project demonstrates a complete CI/CD pipeline that:
- Automatically builds and tests a Node.js application
- Creates Docker containers for consistent deployments
- Pushes images to Docker Hub registry
- Deploys to AWS EC2 instances via SSH
- Cleans up resources after deployment

**Pipeline Duration**: ~2-3 minutes per deployment

## 🏗️ Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐      ┌──────────────┐
│   GitHub    │─────▶│   Jenkins    │─────▶│ Docker Hub  │─────▶│   AWS EC2    │
│ Repository  │      │   Server     │      │  Registry   │      │  App Server  │
└─────────────┘      └──────────────┘      └─────────────┘      └──────────────┘
                            │
                            ▼
                     ┌──────────────┐
                     │  Unit Tests  │
                     └──────────────┘
```

## ✨ Features

- **Automated CI/CD**: Full automation from code commit to production deployment
- **Infrastructure as Code**: Terraform scripts for AWS infrastructure provisioning
- **Containerization**: Docker-based deployment for consistency
- **Automated Testing**: Unit tests run on every build
- **Security**: Credentials managed securely via Jenkins Credentials Store
- **Rollback Support**: Easy rollback to previous versions
- **Resource Cleanup**: Automatic cleanup of unused Docker images
- **Health Monitoring**: Built-in health check endpoints

## 📦 Prerequisites

### Required Software
- **AWS CLI** (configured with credentials)
- **Terraform** >= 1.0
- **Git**
- **Docker Hub Account**
- **AWS Account** with EC2 access

### Required Jenkins Plugins
- Pipeline
- Git
- Credentials Binding
- Docker Pipeline
- SSH Agent

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/your-username/Project_Complete_CICD_Pipeline_Jenkins.git
cd Project_Complete_CICD_Pipeline_Jenkins

# 2. Deploy infrastructure
cd terraform
terraform init
terraform apply

# 3. Configure Jenkins (see SETUP-GUIDE.md)

# 4. Run pipeline
# Jenkins Dashboard → CICD-Node-Pipeline → Build Now

# 5. Verify deployment
curl http://<EC2_IP>:5000/health
```

## 📁 Project Structure

```
Project_Complete_CICD_Pipeline_Jenkins/
├── app.js                      # Node.js Express application
├── app.test.js                 # Unit tests
├── package.json                # Node.js dependencies
├── jest.config.js              # Jest test configuration
├── Dockerfile                  # Docker image definition
├── Jenkinsfile                 # CI/CD pipeline definition
├── README.md                   # This file
├── RUNBOOK.md                  # Operations guide
├── SETUP-GUIDE.md              # Detailed setup instructions
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   └── modules/                # Terraform modules
│       ├── vpc/                # VPC configuration
│       ├── security/           # Security groups
│       ├── jenkins/            # Jenkins server
│       ├── ec2/                # Application server
│       └── keypair/            # SSH key management
└── .gitignore                  # Git ignore rules
```

## 🔄 Pipeline Stages

### 1. Checkout
- Clones source code from Git repository
- Duration: ~10 seconds

### 2. Install/Build
- Installs Node.js dependencies using `npm ci`
- Duration: ~20 seconds

### 3. Test
- Runs unit tests with Jest
- Fails pipeline if tests don't pass
- Duration: ~5 seconds

### 4. Docker Build
- Builds Docker image with application
- Tags image with build number and 'latest'
- Duration: ~30 seconds

### 5. Push Image
- Authenticates with Docker Hub
- Pushes image to registry
- Duration: ~40 seconds

### 6. Deploy
- SSH to EC2 instance
- Stops old container
- Pulls new image
- Starts new container
- Cleans up old images
- Duration: ~30 seconds

### Post Actions
- Cleans up local Docker images
- Reports success/failure status

## 🛠️ Setup Instructions

### Step 1: Infrastructure Setup

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

### Step 2: Jenkins Configuration

1. Access Jenkins at `http://<JENKINS_IP>:8080`
2. Complete initial setup wizard
3. Install required plugins
4. Configure credentials:
   - `registry_creds`: Docker Hub username/password
   - `ec2_ssh`: EC2 SSH private key

### Step 3: Create Pipeline

1. New Item → Pipeline
2. Configure Git repository
3. Set Script Path to `Jenkinsfile`
4. Add parameter `EC2_HOST` with EC2 public IP
5. Save and build

**For detailed instructions, see [SETUP-GUIDE.md](SETUP-GUIDE.md)**

## 💻 Usage

### Local Development

```bash
# Install dependencies
npm install

# Run tests
npm test

# Start application
npm start

# Access application
curl http://localhost:5000
```

### Trigger Pipeline Build

**Manual Trigger**:
- Jenkins Dashboard → CICD-Node-Pipeline → Build Now

**Automatic Trigger** (with webhook):
- Push code to main branch
- Pipeline starts automatically

### Access Deployed Application

```bash
# Health check
curl http://<EC2_IP>:5000/health

# Main page
curl http://<EC2_IP>:5000/

# API info
curl http://<EC2_IP>:5000/api/info
```

## 🧪 Testing

### Run Tests Locally

```bash
npm test
```

### Test Coverage

```bash
npm test -- --coverage
```

### Test Cases

- ✅ GET / returns HTML page
- ✅ GET /health returns healthy status
- ✅ GET /api/info returns application info

## 🚢 Deployment

### Deployment Process

1. **Code Push**: Developer pushes code to GitHub
2. **Build Trigger**: Jenkins detects change (webhook) or manual trigger
3. **Pipeline Execution**: All stages run sequentially
4. **Deployment**: Application deployed to EC2
5. **Verification**: Health checks confirm successful deployment

### Rollback Procedure

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@<EC2_IP>

# Stop current container
docker stop node-app && docker rm node-app

# Run previous version
docker run -d --name node-app -p 5000:5000 <username>/cicd-node-app:<previous-build>
```

## 📊 Monitoring

### Application Health

```bash
# Health endpoint
curl http://<EC2_IP>:5000/health

# Expected response
{"status":"healthy"}
```

### Container Status

```bash
# SSH to EC2
ssh -i your-key.pem ec2-user@<EC2_IP>

# Check running containers
docker ps

# View logs
docker logs node-app

# Follow logs
docker logs -f node-app
```

### Jenkins Monitoring

- **Console Output**: Build → Console Output
- **Build History**: Pipeline dashboard
- **Blue Ocean**: Visual pipeline view

## 🔧 Troubleshooting

### Common Issues

#### Pipeline Fails at Test Stage
```bash
# Run tests locally to debug
npm test

# Check test output in Jenkins console
```

#### Docker Push Fails
```bash
# Verify Docker Hub credentials in Jenkins
# Test login manually: docker login
```

#### Cannot Connect to EC2
```bash
# Check security group allows SSH from Jenkins
# Verify ec2_ssh credential has correct private key
# Test SSH manually: ssh -i key.pem ec2-user@<EC2_IP>
```

#### Application Not Accessible
```bash
# Check security group allows port 5000
# Verify container is running: docker ps
# Check container logs: docker logs node-app
```

**For more troubleshooting, see [RUNBOOK.md](RUNBOOK.md)**

## 📸 Evidence & Screenshots

### Required Screenshots for Submission

1. **Jenkins Pipeline Success**
   - Location: `screenshots/pipeline-success.png`
   - Shows: All stages completed successfully

2. **Console Output**
   - Location: `screenshots/console-output.png`
   - Shows: Complete build log

3. **Docker Hub Image**
   - Location: `screenshots/dockerhub-image.png`
   - Shows: Pushed image in registry

4. **Application Running**
   - Location: `screenshots/app-running.png`
   - Shows: Browser accessing application

5. **EC2 Container Status**
   - Location: `screenshots/ec2-container.png`
   - Shows: `docker ps` output on EC2

### Logs to Collect

```bash
# Jenkins console output
# Save from Jenkins UI: Build → Console Output → Save

# Docker images on EC2
ssh ec2-user@<EC2_IP> "docker images" > logs/docker-images.txt

# Container logs
ssh ec2-user@<EC2_IP> "docker logs node-app" > logs/container-logs.txt

# Application response
curl http://<EC2_IP>:5000/api/info > logs/app-response.json
```

## 🧹 Cleanup

### Destroy All Infrastructure

```bash
cd terraform
terraform destroy
# Type 'yes' to confirm
```

### Clean Docker Resources

```bash
# On EC2
ssh ec2-user@<EC2_IP>
docker stop node-app
docker rm node-app
docker system prune -af
exit

# On Jenkins server
ssh ec2-user@<JENKINS_IP>
docker system prune -af
exit
```

## 📝 Configuration Files

### Jenkins Credentials Required

| ID | Type | Description |
|---|---|---|
| `registry_creds` | Username/Password | Docker Hub credentials |
| `ec2_ssh` | SSH Private Key | EC2 access key |

### Environment Variables

| Variable | Description | Example |
|---|---|---|
| `DOCKER_IMAGE` | Image name | `cicd-node-app` |
| `DOCKER_TAG` | Image tag | `${BUILD_NUMBER}` |
| `REGISTRY` | Registry URL | `docker.io` |
| `CONTAINER_NAME` | Container name | `node-app` |
| `EC2_HOST` | EC2 public IP | `3.15.123.45` |

## 🔒 Security Best Practices

- ✅ Credentials stored in Jenkins Credentials Store
- ✅ SSH keys not committed to Git
- ✅ Security groups restrict access by IP
- ✅ Docker images scanned for vulnerabilities
- ✅ Application runs as non-root user
- ✅ HTTPS recommended for production

## 📚 Additional Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- Jenkins community for excellent CI/CD tools
- Docker for containerization platform
- AWS for cloud infrastructure
- Node.js and Express communities

---

**📧 Contact**: For questions or support, please open an issue in the repository.

**⭐ Star this repo** if you find it helpful!
