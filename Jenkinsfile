pipeline {
    agent {
        docker {
            image 'quangtp/custom-jenkins:latest'  // Image chứa kubectl + helm
            reuseNode true       // Giữ workspace giữa các stage
            alwaysPull false     // Có thể bật true nếu muốn luôn pull image mới
        }
    }

    options{
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        timestamps()
    }

    environment{
        registry = 'quangtp/house-price-prediction-api'
        registryCredential = 'dockerhub'
        nameSpace = 'model-serving'
        helmChartPath = './helm-charts/hpp'   
        pullPolicy = 'Always'
        context = 'inner-replica-469607-h9-new-gke'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build docker image') {
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

        stage('Deploy to K8s') {
            steps {
                withCredentials([file(credentialsId: 'k8s-config', variable: 'KUBECONFIG')]) {
                    script {
                        sh """
                            helm upgrade --install hpp ${helmChartPath} \
                                --namespace ${nameSpace} \
                                --kube-context=${context} \
                                --set image.repository=${registry} \
                                --set image.tag=${BUILD_NUMBER} \
                                --set image.pullPolicy=${pullPolicy}
                        """
                        sh "kubectl --context=${context} rollout restart deployment hpp -n ${nameSpace}"
                    }
                }
            }
        }

        stage('Clean up'){
            steps {
                script {
                    echo 'Delete local image'
                    sh "docker rmi ${registry}:${BUILD_NUMBER} ${registry}:latest || true"
                }
            }
        }
    }
}