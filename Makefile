# Makefile for automating project tasks
.PHONY: help install test lint build run clean deploy destroy

# Default target: display help
help:
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make test       - Run tests"
	@echo "  make lint       - Run linter"
	@echo "  make build      - Build Docker image"
	@echo "  make run        - Run application locally"
	@echo "  make clean      - Clean up resources"
	@echo "  make deploy     - Deploy infrastructure"
	@echo "  make destroy    - Destroy infrastructure"

# Install project dependencies from package-lock.json
install:
	npm ci

# Run unit tests with coverage
test:
	npm test

# Run code linter
lint:
	npm run lint

# Build the application Docker image
build:
	docker build -t cicd-node-app:latest .

# Run the application locally
run:
	npm start

# Clean up local environment and Docker resources
clean:
	rm -rf node_modules coverage
	docker system prune -af

# Initialize and apply Terraform infrastructure
deploy:
	cd terraform && terraform init && terraform apply

# Destroy Terraform managed infrastructure
destroy:
	cd terraform && terraform destroy

# Set default goal to 'help'
.DEFAULT_GOAL := help
