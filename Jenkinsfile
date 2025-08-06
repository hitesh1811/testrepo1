pipeline {
    agent any

    tools {
        SonarQubeScanner 'SonarQubeScanner' // Must match Jenkins Tools configuration
    }

    environment {
        SONARQUBE_ENV = 'SonarQubeServer'   // Must match Jenkins SonarQube Server name
        EC2_HOST = '52.66.147.75'   // Your EC2 instance user and IP
        EC2_KEY = 'ec2-ssh-creds'             // Jenkins credentials ID for EC2 SSH key
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

        stage('Code Quality Check') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'sonar-scanner'
                }
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
                            cd /var/www/nodeapp || mkdir -p /var/www/nodeapp &&
                            git pull origin master || git clone git@github.com:hitesh1811/testrepo1.git /var/www/nodeapp &&
                            cd /var/www/nodeapp &&
                            npm install &&
                            pm2 restart app || pm2 start app.js --name app
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
