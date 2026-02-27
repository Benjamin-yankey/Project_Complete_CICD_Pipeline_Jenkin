#!/bin/bash
# Secure Deployment Script
# Automates the entire process of deploying security-hardened infrastructure

# Exit immediately if a command fails
set -e

echo "🚀 Secure CI/CD Infrastructure Deployment"
echo "=========================================="
echo ""

# Ensure the script is executed within the terraform directory
if [ ! -f "main.tf" ]; then
    echo "❌ Error: Please run this script from the terraform directory"
    exit 1
fi

# Step 1: Execute the security validator script to check for vulnerabilities
echo "Step 1: Validating security configuration..."
./validate-security.sh
if [ $? -ne 0 ]; then
    echo ""
    echo "Please fix security issues before proceeding."
    exit 1
fi
echo ""

# Step 2: Initialize Terraform (download providers and modules)
echo "Step 2: Initializing Terraform..."
terraform init
echo ""

# Step 3: Validate the Terraform HCL syntax and configuration
echo "Step 3: Validating Terraform configuration..."
terraform validate
echo ""

# Step 4: Create an execution plan and save it to 'tfplan'
echo "Step 4: Planning deployment..."
terraform plan -out=tfplan
echo ""

# Step 5: Require manual user confirmation before applying changes to AWS
echo "Step 5: Ready to deploy"
read -p "Do you want to proceed with deployment? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Deployment cancelled."
    # Cleanup plan file if cancelled
    rm -f tfplan
    exit 0
fi
echo ""

# Step 6: Apply the saved plan to provision the infrastructure
echo "Step 6: Deploying infrastructure..."
terraform apply tfplan
# Cleanup plan file after successful apply
rm -f tfplan
echo ""

# Step 7: Display the final outputs for user reference
echo "✅ Deployment completed successfully!"
echo ""
echo "📋 Access Information:"
terraform output
echo ""

# Security best practice reminders
echo "🔐 Security Reminders:"
echo "  - Jenkins password is stored in AWS Secrets Manager"
echo "  - SSH access is restricted to allowed_ips"
echo "  - Private key saved locally: $(terraform output -raw ssh_jenkins | awk '{print $3}')"
echo ""

# Post-deployment guidance
echo "📖 Next Steps:"
echo "  1. Access Jenkins: terraform output jenkins_url"
echo "  2. Configure Jenkins credentials (registry_creds, ec2_ssh)"
echo "  3. Create pipeline job"
echo "  4. See QUICKSTART.md for detailed instructions"
