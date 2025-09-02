pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@3.110.32.201'   // Your EC2 instance
        EC2_KEY  = 'ec2-ssh-creds'         // Jenkins SSH key credential ID
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t hitesh1811/testrepo1:latest .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-creds', url: '']) {
                    sh 'docker push hitesh1811/testrepo1:latest'
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent([env.EC2_KEY]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no $EC2_HOST '
                            # Kill Node.js process if running
                            pkill -f "node" || true

                            # Free port 3000 if in use
                            sudo fuser -k 3000/tcp || true

                            # Pull latest image
                            docker pull hitesh1811/testrepo1:latest

                            # Stop and remove old container
                            docker stop testrepo1 || true
                            docker rm testrepo1 || true

                            # Run new container
                            docker run -d --name testrepo1 -p 3000:3000 hitesh1811/testrepo1:latest
                        '
                    """
                }
            }
        }
    }
}
