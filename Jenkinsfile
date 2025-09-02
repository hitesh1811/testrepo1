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
                sh 'docker build -t hitesh1811/testrepo1:latest .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push hitesh1811/testrepo1:latest
                    '''
                }
            }
        }

        stage('Deploy on EC2 with Docker') {
            steps {
                sshagent([env.EC2_KEY]) {
                    sh '''
                      ssh -o StrictHostKeyChecking=no $EC2_HOST "
                        docker pull hitesh1811/testrepo1:latest &&
                        docker stop testrepo1 || true &&
                        docker rm testrepo1 || true &&
                        docker run -d --name testrepo1 -p 3000:3000 hitesh1811/testrepo1:latest
                      "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
