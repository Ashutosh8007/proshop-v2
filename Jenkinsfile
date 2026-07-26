pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        SONAR_TOKEN = credentials('sonarcloud-token')
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Install Backend Dependencies') {
            steps {
                sh 'npm install --omit=dev'
            }
        }

        stage('Install Frontend Dependencies') {
            steps {
                dir('frontend') {
                    sh 'npm install'
                }
            }
        }

        stage('SonarCloud Analysis') {
            steps {
                withSonarQubeEnv('SonarCloud') {
                    sh '''
                        npx sonar-scanner \
                        -Dsonar.organization=ashutosh8007 \
                        -Dsonar.projectKey=Ashutosh8007_devsecops-proshop-pipeline \
                        -Dsonar.sources=. \
                        -Dsonar.host.url=https://sonarcloud.io \
                        -Dsonar.token=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                sh 'docker build -t $DOCKERHUB_CREDENTIALS_USR/proshop-backend:$IMAGE_TAG .'
            }
        }

        stage('Build Frontend Image') {
            steps {
                dir('frontend') {
                    sh 'docker build -t $DOCKERHUB_CREDENTIALS_USR/proshop-frontend:$IMAGE_TAG .'
                }
            }
        }

    }

    stage('Trivy Scan - Backend') {
            steps {
                sh '''
                    trivy image --severity CRITICAL --exit-code 1 --format table $DOCKERHUB_CREDENTIALS_USR/proshop-backend:$IMAGE_TAG || true
                    trivy image --format table $DOCKERHUB_CREDENTIALS_USR/proshop-backend:$IMAGE_TAG > trivy-backend-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-backend-report.txt', allowEmptyArchive: true
            }
        }

        stage('Trivy Scan - Frontend') {
            steps {
                sh '''
                    trivy image --severity CRITICAL --exit-code 1 --format table $DOCKERHUB_CREDENTIALS_USR/proshop-frontend:$IMAGE_TAG || true
                    trivy image --format table $DOCKERHUB_CREDENTIALS_USR/proshop-frontend:$IMAGE_TAG > trivy-frontend-report.txt
                '''
                archiveArtifacts artifacts: 'trivy-frontend-report.txt', allowEmptyArchive: true
            }
        }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Build succeeded!'
        }
        failure {
            echo 'Build failed — check logs above.'
        }
    }
}