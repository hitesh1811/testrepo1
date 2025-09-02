pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker-hub-credentials') // Jenkins credentials ID
        EC2_HOST = 'ubuntu@3.110.32.201'                       // EC2 user@IP
        EC2_KEY = 'ec2-ssh-creds'                              // Jenkins SSH private key ID
        IMAGE_NAME = 'hitesh1811/testrepo1'
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
                    sh """
                        echo "${DOCKERHUB_CREDENTIALS_PSW}" | docker login -u "${DOCKERHUB_CREDENTIALS_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:latest .
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [EC2_KEY]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} '
                            # Kill any process using port 3000 (Node.js or Docker leftovers)
                            sudo fuser -k 3000/tcp || true

                            # Pull latest image
                            docker pull ${IMAGE_NAME}:latest &&

                            # Stop and remove old container if exists
                            docker stop testrepo1 || true &&
                            docker rm testrepo1 || true &&

                            # Run new container on port 3000
                            docker run -d --name testrepo1 -p 3000:3000 ${IMAGE_NAME}:latest
                        '
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
