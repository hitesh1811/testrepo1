pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@3.110.32.201'     // Your EC2 instance user and IP
        EC2_KEY  = 'ec2-ssh-creds'           // Jenkins credentials ID for EC2 SSH key
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
                    dockerImage = docker.build("hitesh1811/testrepo1:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-credentials') {
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [env.EC2_KEY]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no $EC2_HOST '
                            # Kill any running Node.js process (non-Docker)
                            pkill -f "node" || true

                            # Pull latest image
                            docker pull hitesh1811/testrepo1:latest &&

                            # Stop and remove old container if exists
                            docker stop testrepo1 || true &&
                            docker rm testrepo1 || true &&

                            # Run new container on port 3000
                            docker run -d --name testrepo1 -p 3000:3000 hitesh1811/testrepo1:latest
                        '
                    '''
                }
            }
        }
    }
}
