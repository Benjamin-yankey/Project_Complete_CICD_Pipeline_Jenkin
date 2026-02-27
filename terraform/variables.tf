# AWS region where infrastructure will be deployed
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

# Project name used for naming and tagging resources
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cicd-pipeline"
}

# Deployment environment (e.g., dev, staging, prod)
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# CIDR block for the Virtual Private Cloud (VPC)
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# List of CIDR blocks for public subnets
variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# List of CIDR blocks for private subnets
variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# Restricted IP ranges for administrative access (SSH and Jenkins UI)
variable "allowed_ips" {
  description = "List of allowed IP addresses for SSH and Jenkins access. MUST be set to specific IPs (e.g., YOUR_IP/32)"
  type        = list(string)

  # Security validation: Prevent open access (0.0.0.0/0)
  validation {
    condition     = length(var.allowed_ips) > 0 && !contains(var.allowed_ips, "0.0.0.0/0")
    error_message = "allowed_ips cannot be 0.0.0.0/0. Specify your IP address (e.g., YOUR_IP/32) for security."
  }
}

# Restricted IP ranges for accessing the web application on port 5000
variable "app_allowed_ips" {
  description = "List of allowed IP addresses for application port 5000. Use specific IPs or load balancer security group"
  type        = list(string)

  # Security validation: Prevent open access (0.0.0.0/0)
  validation {
    condition     = length(var.app_allowed_ips) > 0 && !contains(var.app_allowed_ips, "0.0.0.0/0")
    error_message = "app_allowed_ips cannot be 0.0.0.0/0. Specify trusted IPs or use a load balancer."
  }
}

# Root EBS volume size for the Jenkins EC2 instance
variable "jenkins_volume_size" {
  description = "Root volume size for Jenkins instance in GB"
  type        = number
  default     = 20
}

# Root EBS volume size for the application EC2 instance
variable "app_volume_size" {
  description = "Root volume size for application instance in GB"
  type        = number
  default     = 20
}

# AWS instance type for the Jenkins server
variable "jenkins_instance_type" {
  description = "Instance type for Jenkins server"
  type        = string
  default     = "t3.micro"
}

# AWS instance type for the application server
variable "app_instance_type" {
  description = "Instance type for application server"
  type        = string
  default     = "t3.micro"
}

# Sensitive variable for the Jenkins initial admin password
variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

# Name of the existing AWS EC2 key pair for SSH access
variable "key_name" {
  description = "Name of existing EC2 key pair in AWS. Do not generate keys via Terraform."
  type        = string

  validation {
    condition     = length(var.key_name) > 0
    error_message = "key_name must be set to an existing EC2 key pair name in your AWS account."
  }
}