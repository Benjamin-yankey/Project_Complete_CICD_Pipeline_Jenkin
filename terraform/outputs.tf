# The unique identifier of the created VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

# The public IP address of the Jenkins automation server
output "jenkins_public_ip" {
  description = "Public IP address of Jenkins server"
  value       = module.jenkins.public_ip
}

# The URL used to access the Jenkins web interface
output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${module.jenkins.public_ip}:8080"
}

# The public IP address of the application server
output "app_server_public_ip" {
  description = "Public IP address of application server"
  value       = module.app_server.public_ip
}

# The URL used to access the deployed web application
output "app_url" {
  description = "Application URL"
  value       = "http://${module.app_server.public_ip}:5000"
}

# Example SSH command to connect to the Jenkins server
output "ssh_jenkins" {
  description = "SSH command for Jenkins server"
  value       = "ssh -i /path/to/${var.key_name}.pem ec2-user@${module.jenkins.public_ip}"
}

# Example SSH command to connect to the application server
output "ssh_app_server" {
  description = "SSH command for application server"
  value       = "ssh -i /path/to/${var.key_name}.pem ec2-user@${module.app_server.public_ip}"
}

# The name of the secret in AWS Secrets Manager containing the Jenkins admin password
output "jenkins_password_secret_name" {
  description = "AWS Secrets Manager secret name for Jenkins admin password"
  value       = module.secrets.secret_name
}

# The ARN of the secret in AWS Secrets Manager containing the Jenkins admin password
output "jenkins_password_secret_arn" {
  description = "AWS Secrets Manager secret ARN for Jenkins admin password"
  value       = module.secrets.secret_arn
  sensitive   = true
}