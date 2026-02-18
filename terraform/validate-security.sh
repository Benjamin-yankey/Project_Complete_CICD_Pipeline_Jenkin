#!/bin/bash
# Security Configuration Validator
# Run this before terraform apply to validate security settings

set -e

echo "🔒 Security Configuration Validator"
echo "===================================="
echo ""

ERRORS=0
WARNINGS=0

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "❌ ERROR: terraform.tfvars not found"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ terraform.tfvars found"
    
    # Check allowed_ips configuration
    if grep -q 'allowed_ips.*=.*\["0.0.0.0/0"\]' terraform.tfvars; then
        echo "⚠️  WARNING: allowed_ips is set to 0.0.0.0/0 (open to internet)"
        echo "   Recommendation: Set to your IP address (e.g., [\"$(curl -s ifconfig.me)/32\"])"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✅ allowed_ips is restricted"
    fi
    
    # Check if jenkins_admin_password is set
    if ! grep -q 'jenkins_admin_password' terraform.tfvars; then
        echo "❌ ERROR: jenkins_admin_password not set in terraform.tfvars"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ jenkins_admin_password is configured"
    fi
fi

echo ""
echo "Security Checks Summary:"
echo "------------------------"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ Security validation FAILED. Please fix errors before deploying."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  Security validation passed with warnings."
    echo "   Consider addressing warnings for production deployments."
    exit 0
else
    echo "✅ Security validation PASSED. Safe to deploy."
    exit 0
fi
