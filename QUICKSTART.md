# Quick Start Guide - 15 Minutes to Running Pipeline

This guide gets you from zero to a running CI/CD pipeline in 15 minutes.

## ⚡ Prerequisites (5 minutes)

```bash
# 1. Verify AWS CLI
aws --version
aws sts get-caller-identity

# 2. Verify Terraform
terraform --version

# 3. Get your public IP
curl ifconfig.me

# 4. Have ready:
# - Docker Hub username and password
# - AWS EC2 key pair name
```

## 🚀 Step 1: Deploy Infrastructure (5 minutes)

```bash
# Clone and navigate
git clone <your-repo-url>
cd Project_Complete_CICD_Pipeline_Jenkins/terraform

# Create configuration
cat > terraform.tfvars << EOF
aws_region = "us-east-1"
project_name = "cicd-demo"
environment = "dev"
key_name = "your-existing-key-name"
jenkins_admin_password = "Admin123!"
allowed_ips = ["$(curl -s ifconfig.me)/32"]
jenkins_instance_type = "t3.medium"
app_instance_type = "t3.small"
EOF

# Deploy (takes ~3-4 minutes)
terraform init
terraform apply -auto-approve

# Save outputs
terraform output > ../infrastructure.txt
cat ../infrastructure.txt
```

**Expected Output:**
```
jenkins_url = "http://3.15.123.45:8080"
app_url = "http://3.15.123.67:5000"
```

## 🔧 Step 2: Configure Jenkins (5 minutes)

### 2.1 Access Jenkins (1 minute)
```bash
# Get Jenkins URL
cd ..
JENKINS_URL=$(grep jenkins_url infrastructure.txt | cut -d'"' -f2)
echo "Open: $JENKINS_URL"

# Get initial password
JENKINS_IP=$(grep jenkins_public_ip infrastructure.txt | cut -d'"' -f2)
ssh -i ~/.ssh/your-key.pem ec2-user@$JENKINS_IP \
  "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

### 2.2 Setup Jenkins (2 minutes)
1. Open Jenkins URL in browser
2. Paste initial password
3. Click "Install suggested plugins" (wait ~2 minutes)
4. Create admin user (use password from terraform.tfvars)
5. Keep default URL → Start using Jenkins

### 2.3 Add Credentials (2 minutes)

**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**

**Credential 1: Docker Hub**
- Kind: `Username with password`
- Username: `your-dockerhub-username`
- Password: `your-dockerhub-password`
- ID: `registry_creds`
- Click "Create"

**Credential 2: EC2 SSH**
- Kind: `SSH Username with private key`
- ID: `ec2_ssh`
- Username: `ec2-user`
- Private Key: Enter directly → Paste your .pem file content
- Click "Create"

## 📦 Step 3: Create Pipeline (3 minutes)

### 3.1 Create Job (1 minute)
1. Dashboard → New Item
2. Name: `CICD-Node-Pipeline`
3. Type: Pipeline → OK

### 3.2 Configure Pipeline (2 minutes)

**Pipeline Section:**
- Definition: `Pipeline script from SCM`
- SCM: `Git`
- Repository URL: `https://github.com/your-username/your-repo.git`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

**This project is parameterized:**
- Add String Parameter
- Name: `EC2_HOST`
- Default Value: (paste app server IP from infrastructure.txt)

Click "Save"

## 🎯 Step 4: Run Pipeline (2 minutes)

```bash
# Update Jenkinsfile with EC2 IP
APP_IP=$(grep app_server_public_ip infrastructure.txt | cut -d'"' -f2)
echo "App Server IP: $APP_IP"

# If you need to update Jenkinsfile, do it now
# Then commit and push
```

**In Jenkins:**
1. Click "Build Now"
2. Watch the pipeline execute
3. Wait for SUCCESS (~2-3 minutes)

## ✅ Step 5: Verify (1 minute)

```bash
# Get app URL
APP_IP=$(grep app_server_public_ip infrastructure.txt | cut -d'"' -f2)

# Test endpoints
curl http://$APP_IP:5000/health
curl http://$APP_IP:5000/api/info

# Open in browser
echo "Open: http://$APP_IP:5000"
```

**Expected:**
- Health: `{"status":"healthy"}`
- Browser: Shows "CI/CD Pipeline App" with version info

## 🎉 Success!

You now have a fully functional CI/CD pipeline!

## 📸 Collect Evidence

```bash
# Run automated collection
./collect-evidence.sh

# Then manually capture:
# 1. Jenkins pipeline success screenshot
# 2. Application in browser screenshot
# 3. Docker Hub image screenshot
```

## 🧹 Cleanup When Done

```bash
cd terraform
terraform destroy -auto-approve
```

## 🚨 Troubleshooting

### Jenkins not accessible
```bash
# Wait 2-3 minutes after terraform apply
# Check security group allows your IP
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=*jenkins*"
```

### Pipeline fails at Deploy stage
```bash
# Verify ec2_ssh credential has correct key
# Test SSH manually
ssh -i ~/.ssh/your-key.pem ec2-user@$APP_IP
```

### Application not accessible
```bash
# Check security group allows port 5000
# Verify container is running
ssh -i ~/.ssh/your-key.pem ec2-user@$APP_IP "docker ps"
```

## 📚 Next Steps

- Review [SETUP-GUIDE.md](SETUP-GUIDE.md) for detailed explanations
- Check [RUNBOOK.md](RUNBOOK.md) for operations guide
- See [EVIDENCE-GUIDE.md](EVIDENCE-GUIDE.md) for submission requirements

---

**Total Time: ~15 minutes** ⏱️

**Questions?** Check the documentation or open an issue!
