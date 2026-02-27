#!/bin/bash
# Security Configuration Validator
# This script inspects terraform.tfvars to ensure no critical security misconfigurations exist.

# Exit immediately if a command fails
set -e

echo "Security Configuration Validator"
echo "===================================="
echo ""

# Initialize counters for issues found
ERRORS=0
WARNINGS=0

# Check if the variables file exists
if [ ! -f "terraform.tfvars" ]; then
    echo "[ERROR] terraform.tfvars not found"
    ERRORS=$((ERRORS + 1))
else
    echo "[OK] terraform.tfvars found"
    
    # Check 1: Ensure administrative access (allowed_ips) is not open to the world
    if grep -q 'allowed_ips.*=.*\["0.0.0.0/0"\]' terraform.tfvars; then
        echo "[ERROR] allowed_ips is set to 0.0.0.0/0 (CRITICAL SECURITY RISK)"
        echo "   Fix: Set to your IP address (e.g., [\"$(curl -s ifconfig.me)/32\"])"
        ERRORS=$((ERRORS + 1))
    else
        echo "[OK] allowed_ips is restricted"
    fi
    
    # Check 2: Ensure application access (app_allowed_ips) is not open to the world
    if grep -q 'app_allowed_ips.*=.*\["0.0.0.0/0"\]' terraform.tfvars; then
        echo "[ERROR] app_allowed_ips is set to 0.0.0.0/0 (CRITICAL SECURITY RISK)"
        echo "   Fix: Set to your IP address or load balancer"
        ERRORS=$((ERRORS + 1))
    elif ! grep -q 'app_allowed_ips' terraform.tfvars; then
        echo "[ERROR] app_allowed_ips not set in terraform.tfvars"
        ERRORS=$((ERRORS + 1))
    else
        echo "[OK] app_allowed_ips is configured"
    fi
    
    # Check 3: Ensure a Jenkins admin password has been defined
    if ! grep -q 'jenkins_admin_password' terraform.tfvars; then
        echo "[ERROR] jenkins_admin_password not set"
        ERRORS=$((ERRORS + 1))
    else
        echo "[OK] jenkins_admin_password is configured"
    fi
fi

# Print summary of findings
echo ""
echo "Security Checks Summary:"
echo "------------------------"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

# Determine exit code based on error count
if [ $ERRORS -gt 0 ]; then
    echo "[FAIL] Security validation FAILED. Fix errors before deploying."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "[WARN] Security validation passed with warnings."
    exit 0
else
    echo "[PASS] Security validation PASSED. Safe to deploy."
    exit 0
fi
