pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'hitesh1811/testrepo1'
        EC2_HOST = 'ubuntu@3.110.32.201'
        EC2_CRED = 'docker-hub-credentials'   // Jenkins credentials ID for EC2 SSH key
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_HUB_REPO}:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([ credentialsId: 'docker-hub-creds', url: '' ]) {
                    sh "docker push ${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [env.EC2_CRED]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} << 'EOF'

                        # Stop and remove old container if exists
                        docker stop testrepo1 || true
                        docker rm testrepo1 || true

                        # Pull latest image
                        docker pull ${DOCKER_HUB_REPO}:latest

                        # Function to check if port is free
                        is_port_free() {
                            ! sudo lsof -i :$1 >/dev/null 2>&1
                        }

                        # Default port
                        PORT=3000

                        # Try alternative ports if 3000 is busy
                        if ! is_port_free 3000; then
                            echo "Port 3000 busy, trying 8080..."
                            if is_port_free 8080; then
                                PORT=8080
                            else
                                echo "Port 8080 busy, falling back to 5000..."
                                PORT=5000
                            fi
                        fi

                        echo "Running container on port $PORT"
                        docker run -d --name testrepo1 -p $PORT:3000 ${DOCKER_HUB_REPO}:latest

                        EOF
                    '''
                }
            }
        }
    }
}
