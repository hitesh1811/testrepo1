pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@3.110.32.201'     // EC2 instance user and IP
        EC2_KEY  = 'ec2-ssh-creds'            // Jenkins credentials ID for EC2 SSH key
        DOCKER_IMAGE = 'hitesh1811/testrepo1:latest'
    }

    triggers {
        githubPush()   // Auto-trigger on GitHub push (requires webhook)
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push $DOCKER_IMAGE
                    '''
                }
            }
        }

        stage('Deploy on EC2 with Docker') {
            steps {
                sshagent([env.EC2_KEY]) {
                    sh '''
                      ssh -o StrictHostKeyChecking=no $EC2_HOST << 'EOF'
                      set -e
                      
                      echo "🔄 Pulling latest image..."
                      docker pull $DOCKER_IMAGE
                      
                      echo "🛑 Stopping old container..."
                      docker stop testrepo1 || true
                      docker rm testrepo1 || true
                      
                      echo "🧹 Cleaning unused images/containers..."
                      docker system prune -f || true
                      
                      echo "🚀 Starting new container..."
                      docker run -d --name testrepo1 -p 4000:3000 $DOCKER_IMAGE
                      EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline executed successfully! App deployed on EC2 at port 3000"
        }
        failure {
            echo "❌ Pipeline failed. Check Jenkins logs for details."
        }
    }
}
