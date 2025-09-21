pipeline {
    agent any

    options{
        // Max number of build logs to keep and days to keep
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        // Enable timestamp at each job in the pipeline
        timestamps()
    }

    environment{
        registry = 'quangtp/house-price-prediction-api'
        registryCredential = 'dockerhub'      
    }

    stages {
        stage('Test') {
            agent {
                docker {
                    image 'python:3.8-slim' 
                    args '-u root:root' //run image with root
                }
            }
            steps {
                echo 'Testing model correctness..'
                sh 'pip install -r requirements.txt && pytest'
            }
        }
        stage('Build') {
            steps {
                script {
                    echo 'Building image for deployment..'
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                    echo 'Pushing image to dockerhub..'
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                kubernetes {
                    containerTemplate {
                        name 'helm' // Name of the container to be used for helm upgrade
                        image 'quangtp/custom-jenkins:latest' // The image containing helm
                        alwaysPullImage false // Only pull custom jenkins image if not present
                    }
                }
            }
            steps {
                script {
                    container('helm') {
                        sh("helm upgrade --install hpp ./helm-charts/hpp --namespace model-serving")
                    }
                }
            }
        }

        stage('Clean up'){
            steps {
                script {
                    echo 'Delete local image hehe'
                    sh 'docker rmi ${registry}:${BUILD_NUMBER} ${registry}:latest || true'
                }
            }
        }
    }
}