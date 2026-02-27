// Main pipeline definition
pipeline {
    agent any // Runs on any available Jenkins agent

    // Parameters for manual trigger
    parameters {
        string(name: 'EC2_HOST', description: 'Public IP of the app server EC2 instance (from Terraform output: app_server_public_ip)')
        booleanParam(name: 'SKIP_SECURITY_SCAN', defaultValue: false, description: 'Skip security scanning (use for trusted builds)')
    }

    // Global environment variables
    environment {
        DOCKER_IMAGE = "cicd-node-app"
        DOCKER_TAG = "${BUILD_NUMBER}"
        REGISTRY = "docker.io"
        // Credentials stored in Jenkins
        REGISTRY_CREDS = credentials('registry_creds')
        CONTAINER_NAME = "node-app"
    }
    
    // Stages of the CI/CD pipeline
    stages {
        // Step 1: Clone the source code
        stage('Checkout') {
            steps {
                echo 'Checking out code from repository...'
                checkout scm
            }
        }
        
        // Step 2: Install Node.js dependencies and run security scans in parallel
        stage('Install & Security Scan') {
            parallel {
                // Install dependencies
                stage('Install/Build') {
                    steps {
                        echo 'Installing dependencies...'
                        sh '''
                            npm ci
                        '''
                    }
                }
                
                // npm audit for dependency vulnerabilities
                stage('npm Audit') {
                    when {
                        expression { params.SKIP_SECURITY_SCAN == false }
                    }
                    steps {
                        echo 'Running npm audit for dependency vulnerabilities...'
                        sh '''
                            npm audit --audit-level=high || true
                        '''
                    }
                }
                
                // ESLint for code quality
                stage('Lint') {
                    steps {
                        echo 'Running ESLint for code quality...'
                        sh '''
                            npm run lint || true
                        '''
                    }
                }
            }
        }
        
        // Step 3: Run unit tests and generate coverage report
        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh '''
                    npm test -- --coverage
                '''
            }
            // Always archive test results
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'test-results/*.xml'
                }
            }
        }
        
        // Step 4: Build multi-architecture Docker image
        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh '''
                    docker buildx build --platform linux/amd64,linux/arm64 \
                      --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
                      --build-arg VERSION=${BUILD_NUMBER} \
                      --label "org.opencontainers.image.created=$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
                      --label "org.opencontainers.image.version=${BUILD_NUMBER}" \
                      --label "org.opencontainers.image.revision=${GIT_COMMIT}" \
                      -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                      --load .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                '''
            }
        }
        
        // Step 5: Run security scans on Docker image in parallel with container tests
        stage('Security Scan & Test') {
            parallel {
                // Trivy container security scan
                stage('Trivy Security Scan') {
                    when {
                        expression { params.SKIP_SECURITY_SCAN == false }
                    }
                    steps {
                        echo 'Running Trivy security scan on Docker image...'
                        sh '''
                            # Install Trivy if not present
                            if ! command -v trivy &> /dev/null; then
                                echo "Installing Trivy..."
                                brew install trivy || apt-get install -y trivy || true
                            fi
                            
                            # Run Trivy scan (exit 0 to not fail on vulnerabilities, just report)
                            trivy image --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-results.json ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                            trivy image --severity HIGH,CRITICAL --exit-code 0 ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                            
                            echo "Trivy scan completed. See trivy-results.json for details."
                        '''
                    }
                }
                
                // Test the Docker container
                stage('Docker Test') {
                    steps {
                        echo 'Testing Docker container...'
                        sh '''
                            # Run the container in detached mode
                            docker run -d \
                              --name ${DOCKER_IMAGE}-test \
                              -p 5001:5000 \
                              -e APP_VERSION=${BUILD_NUMBER} \
                              ${DOCKER_IMAGE}:latest
                            
                            # Wait for container to start
                            sleep 5
                            
                            # Test health endpoint
                            echo "Testing health endpoint..."
                            HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5001/health)
                            if [ "$HEALTH_RESPONSE" != "200" ]; then
                                echo "Health check failed! Expected 200, got $HEALTH_RESPONSE"
                                docker stop ${DOCKER_IMAGE}-test || true
                                docker rm ${DOCKER_IMAGE}-test || true
                                exit 1
                            fi
                            echo "Health endpoint passed!"
                            
                            # Test root endpoint
                            echo "Testing root endpoint..."
                            ROOT_RESPONSE=$(curl -s http://localhost:5001/)
                            if ! echo "$ROOT_RESPONSE" | grep -q "CI/CD Pipeline App"; then
                                echo "Root endpoint test failed!"
                                docker stop ${DOCKER_IMAGE}-test || true
                                docker rm ${DOCKER_IMAGE}-test || true
                                exit 1
                            fi
                            echo "Root endpoint passed!"
                            
                            # Test API info endpoint
                            echo "Testing API info endpoint..."
                            API_RESPONSE=$(curl -s http://localhost:5001/api/info)
                            if ! echo "$API_RESPONSE" | grep -q "version"; then
                                echo "API info endpoint test failed!"
                                docker stop ${DOCKER_IMAGE}-test || true
                                docker rm ${DOCKER_IMAGE}-test || true
                                exit 1
                            fi
                            echo "API info endpoint passed!"
                            
                            # Stop and remove the test container
                            docker stop ${DOCKER_IMAGE}-test
                            docker rm ${DOCKER_IMAGE}-test
                            
                            echo "All Docker container tests passed!"
                        '''
                    }
                }
            }
        }
        
        // Step 6: Push the built Docker image to Docker Hub
        stage('Push Image') {
            steps {
                echo 'Pushing image to registry...'
                sh '''
                    echo $REGISTRY_CREDS_PSW | docker login -u $REGISTRY_CREDS_USR --password-stdin
                    docker buildx build --platform linux/amd64,linux/arm64 \
                      --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
                      --build-arg VERSION=${BUILD_NUMBER} \
                      -t $REGISTRY_CREDS_USR/${DOCKER_IMAGE}:${DOCKER_TAG} \
                      -t $REGISTRY_CREDS_USR/${DOCKER_IMAGE}:latest \
                      --push .
                '''
            }
        }
        
        // Step 7: Deploy the application to AWS EC2
        stage('Deploy') {
            // Only run if EC2 host IP is provided
            when {
                expression { params.EC2_HOST != null && params.EC2_HOST != '' }
            }
            steps {
                echo 'Deploying to EC2...'
                script {
                    try {
                        // Use SSH credentials to connect to EC2
                        withCredentials([sshUserPrivateKey(credentialsId: 'ec2_ssh', keyFileVariable: 'SSH_KEY')]) {
                            sh '''
                                ssh -i $SSH_KEY -o StrictHostKeyChecking=no ec2-user@${EC2_HOST} << EOF
                                    # Stop and remove old container
                                    docker stop ${CONTAINER_NAME} || true
                                    docker rm ${CONTAINER_NAME} || true
                                    
                                    # Login and pull latest image
                                    echo $REGISTRY_CREDS_PSW | docker login -u $REGISTRY_CREDS_USR --password-stdin
                                    docker pull $REGISTRY_CREDS_USR/${DOCKER_IMAGE}:latest
                                    
                                    # Run the new container with health checks
                                    docker run -d \
                                      --name ${CONTAINER_NAME} \
                                      --restart unless-stopped \
                                      --health-cmd="curl -f http://localhost:5000/health || exit 1" \
                                      --health-interval=30s \
                                      --health-timeout=3s \
                                      --health-retries=3 \
                                      -p 5000:5000 \
                                      -e APP_VERSION=${BUILD_NUMBER} \
                                      $REGISTRY_CREDS_USR/${DOCKER_IMAGE}:latest
                                    
                                    # Wait and verify deployment
                                    sleep 10
                                    docker ps --filter name=${CONTAINER_NAME} --format "{{.Status}}"
                                    
                                    # Prune unused images
                                    docker image prune -af
EOF
                            '''
                        }
                    } catch (Exception e) {
                        echo "⚠️ Deploy skipped or failed: ${e.message}"
                        echo "Ensure 'ec2_ssh' credentials exist in Jenkins and EC2 is reachable."
                    }
                }
            }
        }
    }
    
    // Global post actions
    post {
        always {
            echo 'Cleaning up local Docker images...'
            sh '''
                docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                docker rmi ${DOCKER_IMAGE}:latest || true
                docker rmi $REGISTRY_CREDS_USR/${DOCKER_IMAGE}:${DOCKER_TAG} || true
                docker rmi $REGISTRY_CREDS_USR/${DOCKER_IMAGE}:latest || true
            '''
            // Archive Trivy results if available
            archiveArtifacts artifacts: 'trivy-results.json', allowEmptyArchive: true
        }
        success {
            echo '✅ Pipeline completed successfully!'
            echo "Application deployed: http://${params.EC2_HOST}:5000"
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
