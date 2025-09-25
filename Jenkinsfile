pipeline {
    agent {
        docker {
            image 'quangtp/custom-jenkins:latest'  // Image chứa kubectl + helm
            reuseNode true       // Giữ workspace giữa các stage
            alwaysPull false
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        timestamps()
    }

    environment {
        registry = 'quangtp/house-price-prediction-api'
        registryCredential = 'dockerhub'
        nameSpace = 'model-serving'
        helmChartPath = './helm-charts/hpp'   
        pullPolicy = 'Always'
        context = 'inner-replica-469607-h9-new-gke'
        gitRepo = 'https://github.com/quangtranphu/jenkins-tutorial.git'
        gitBranch = 'main'
    }

    stages {
        stage('Checkout') {
            steps {
                dir("${env.WORKSPACE}") {
                    // Xóa folder .git cũ nếu có, rồi clone trực tiếp trong container
                    sh """
                        rm -rf .git || true
                        git clone ${gitRepo} .
                        git checkout ${gitBranch}
                    """
                    sh 'ls -la' // Kiểm tra repo
                }
            }
        }

        stage('Build docker image') {
            steps {
                script {
                    echo 'Building image for deployment...'
                    dockerImage = docker.build("${registry}:${BUILD_NUMBER}")
                    echo 'Pushing image to Docker Hub...'
                    docker.withRegistry('', registryCredential) {
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
                        echo "Deploying to cluster: ${context}"
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

        stage('Clean up local Docker images') {
            agent { label 'docker-host' } // chạy trên node có Docker daemon
            steps {
                script {
                    echo 'Deleting local Docker images...'
                    sh "docker rmi ${registry}:${BUILD_NUMBER} ${registry}:latest || true"
                }
            }
        }
    }
}
