pipeline {
    agent any

    environment {
        SONAR_SCANNER = tool 'SonarQubeScanner'
    }

    stages {
        stage('Clone') {
            steps {
                git credentialsId: 'github-creds', url: 'git@github.com:hitesh1811/testrepo1.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Code Quality Check') {
            steps {
                withSonarQubeEnv('MySonarQubeServer') {
                    sh "${SONAR_SCANNER}/bin/sonar-scanner"
                }
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'npm test || true'
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(['ec2-ssh-creds']) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@52.66.147.75'
                        cd testrepo1 || git clone git@github.com:hitesh1811/testrepo1.git &&
                        cd testrepo1 &&
                        git pull origin main &&
                        npm install &&
                        pm2 restart testrepo || pm2 start index.js --name testrepo
                    '
                    """
                }
            }
        }
    }

    post {
        always {
            echo '✅ Deployment Finished'
        }
    }
}
