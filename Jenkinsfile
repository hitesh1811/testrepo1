pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'hitesh1811/testrepo1'
        EC2_HOST = 'ubuntu@3.110.32.201'
        EC2_CRED = 'ec2-ssh-creds'
    }

    triggers {
        githubPush()   // Auto trigger on GitHub push
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_HUB_REPO}:latest ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withDockerRegistry([ credentialsId: 'docker-hub-credentials', url: '' ]) {
                    sh "docker push ${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [env.EC2_CRED]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} << 'EOF'

                        docker stop testrepo1 || true
                        docker rm testrepo1 || true
                        docker pull ${DOCKER_HUB_REPO}:latest

                        PORT=3000
                        if sudo lsof -i :3000; then
                            echo "Port 3000 busy, switching to 4000..."
                            PORT=4000
                        fi

                        echo "Running container on port $PORT"
                        docker run -d --name testrepo1 -p $PORT:4000 ${DOCKER_HUB_REPO}:latest

                        echo "Deployed at: http://$(curl -s ifconfig.me):$PORT"

                        EOF
                    '''
                }
            }
        }
    }
}
