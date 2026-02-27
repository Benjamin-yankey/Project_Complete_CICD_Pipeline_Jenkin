#!/bin/bash
# Troubleshooting script to check EC2 instance connectivity and service status

# Target EC2 public IP
EC2_IP="52.212.99.167"
# SSH key file path (passed as first argument)
KEY_FILE="$1"

echo "Troubleshooting EC2 Connection to $EC2_IP"
echo "================================================"

# 1. Test basic network reachability using ping
echo -e "\n1. Testing EC2 reachability..."
if ping -c 3 $EC2_IP > /dev/null 2>&1; then
    echo "[OK] EC2 instance is reachable"
else
    echo "[FAIL] EC2 instance is NOT reachable (Check Security Groups and Internet Gateway)"
fi

# 2. Test if SSH port 22 is open and accepting connections
echo -e "\n2. Testing SSH port (22)..."
if nc -zv -w 5 $EC2_IP 22 2>&1 | grep -q succeeded; then
    echo "[OK] SSH port is open"
else
    echo "[FAIL] SSH port is closed or filtered (Check Security Group inbound rules)"
fi

# 3. Test if the application port 5000 is open
echo -e "\n3. Testing application port (5000)..."
if nc -zv -w 5 $EC2_IP 5000 2>&1 | grep -q succeeded; then
    echo "[OK] Port 5000 is open"
else
    echo "[FAIL] Port 5000 is closed or filtered (Check if container is running and SG allows port 5000)"
fi

# 4. If SSH key is provided, log into the instance to check internal state
if [ -n "$KEY_FILE" ] && [ -f "$KEY_FILE" ]; then
    echo -e "\n4. Checking Docker container status via SSH..."
    ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=10 ec2-user@$EC2_IP << 'EOF'
        # Display installed Docker version
        echo "Docker version:"
        docker --version
        
        # List all running and stopped containers
        echo -e "\nDocker containers:"
        docker ps -a
        
        # Check if any process is listening on port 5000
        echo -e "\nChecking if port 5000 is listening:"
        sudo netstat -tlnp | grep 5000 || echo "Port 5000 not listening"
        
        # Fetch associated security groups via EC2 instance metadata service
        echo -e "\nChecking security group (from instance metadata):"
        curl -s http://169.254.169.254/latest/meta-data/security-groups
EOF
else
    echo -e "\n4. [SKIP] Skipping Docker check (no SSH key provided)"
    echo "   Usage: $0 /path/to/key.pem"
fi

echo -e "\n================================================"
echo "Troubleshooting complete!"