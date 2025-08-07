pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@43.205.206.6'     // Your EC2 instance user and IP
        EC2_KEY = 'ec2-ssh-creds'            // Jenkins credentials ID for EC2 SSH key
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: ["${EC2_KEY}"]) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ${EC2_HOST} "
                            if [ ! -d /home/ubuntu/testrepo1 ]; then
                                mkdir -p /home/ubuntu/testrepo1p && cd /home/ubuntu/testrepo1
                                git clone git@github.com:hitesh1811/testrepo1.git
                            else
                                cd /home/ubuntu/testrepo1 && git pull origin main
                            fi
                            cd /home/ubuntu/testrepo1 &&
                            npm install &&
                            pm2 restart testrepo1 || pm2 start app.js --name testrepo1
                        "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
