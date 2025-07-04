pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub')
        KUBECONFIG_CREDENTIALS = credentials('kubeconfig-dev')
        DOCKER_IMAGE = "sultan877/blog-statis"
    }

    stages {
        stage('Checkout with Submodules') {
            steps {
                echo "Checking out repository and all submodules..."
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/opick-wq/blog.git']],
                    extensions: [[$class: 'SubmoduleOption', recursive: true]]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Logging in to Docker Hub..."
                    sh "echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin"

                    echo "Pushing image ${DOCKER_IMAGE}:${BUILD_NUMBER} to Docker Hub..."
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"

                    echo "Tagging and pushing 'latest'..."
                    sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(credentialsId: 'kubeconfig-dev') {
                    script {
                        echo "Updating Kubernetes deployment with image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                        sh "sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' kubernetes/deployment.yaml"

                        echo "Applying deployment to Kubernetes cluster..."
                        sh "kubectl apply -f kubernetes/deployment.yaml"

                        echo "Applying service to Kubernetes cluster..."
                        sh "kubectl apply -f kubernetes/service.yaml"

                        echo "Verifying deployment rollout status..."
                        sh "kubectl rollout status deployment/blog-statis-deployment --timeout=2m"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Logging out from Docker Hub...'
            sh 'docker logout'

            echo 'Cleaning up local Docker image...'
            sh "docker rmi -f ${DOCKER_IMAGE}:${BUILD_NUMBER} || true"
        }
    }
}
