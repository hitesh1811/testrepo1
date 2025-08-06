pipeline {
    agent any

    environment {
        SONARQUBE_ENV = 'MySonarQube'      // Must match Jenkins SonarQube Server name
        EC2_HOST = 'ubuntu@52.66.147.75' // Include SSH username
        EC2_KEY = 'ec2-ssh-creds'          // Jenkins credentials ID for EC2 SSH key
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
                script {
                    withSonarQubeEnv("${SONARQUBE_ENV}") {
                        def scannerHome = tool 'SonarQubeScanner'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
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
                            # Install Node.js and npm if not installed
                            if ! command -v node >/dev/null 2>&1; then
                                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                                sudo yum install -y nodejs || sudo apt install -y nodejs
                            fi

                            # Install PM2 if not installed
                            if ! command -v pm2 >/dev/null 2>&1; then
                                sudo npm install -g pm2
                            fi

                            # Create app directory if not exists
                            if [ ! -d /var/www/nodeapp ]; then
                                mkdir -p /var/www/nodeapp
                                git clone git@github.com:hitesh1811/testrepo1.git /var/www/nodeapp
                            else
                                cd /var/www/nodeapp && git pull origin master
                            fi

                            cd /var/www/nodeapp
                            npm install

                            # Start or restart app using PM2
                            pm2 restart app || pm2 start app.js --name app

                            # Save PM2 process for startup
                            pm2 save
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
