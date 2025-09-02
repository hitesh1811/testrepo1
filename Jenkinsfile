pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@3.110.32.201'     // EC2 user@ip
        EC2_KEY = 'ec2-ssh-creds'            // Jenkins credentials ID for EC2 SSH key
        DOCKER_IMAGE = 'hitesh1811/testrepo1' // DockerHub repo name
        DOCKER_TAG = 'latest'
        DOCKER_CREDS = 'dockerhub-creds'      // Jenkins credentials ID for DockerHub
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                """
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Deploy on EC2 with Docker') {
            steps {
                sshagent (credentials: ["${EC2_KEY}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} "
                            docker pull ${DOCKER_IMAGE}:${DOCKER_TAG} &&
                            docker stop testrepo1 || true &&
                            docker rm testrepo1 || true &&
                            docker run -d --name testrepo1 -p 3000:3000 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully with Docker!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
