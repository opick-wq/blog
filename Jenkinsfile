pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub') // ID credentials di Jenkins
        DOCKER_IMAGE = "sultan877/blog-statis" // Ganti dengan nama user Anda
    }

    stages {
        stage('Checkout') {
            steps {
                // Ambil kode dari Git
                git branch: 'main', url: 'https://github.com/opick-wq/blog.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build image Docker dengan tag unik (nomor build Jenkins)
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Login ke Docker Hub menggunakan credentials
                    sh "echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_USR --password-stdin"
                    // Push image ke Docker Hub
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    // Push juga tag 'latest'
                    sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Ganti tag image di file deployment.yaml secara dinamis
                    sh "sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' kubernetes/deployment.yaml"
                    // Apply konfigurasi ke Kubernetes
                    // Pastikan Jenkins memiliki akses ke K8s (kubeconfig)
                    sh "kubectl apply -f kubernetes/deployment.yaml"
                    sh "kubectl apply -f kubernetes/service.yaml"
                }
            }
        }
    }
    post {
        always {
            // Selalu logout dari Docker Hub dan hapus image lokal untuk kebersihan
            sh "docker logout"
            sh "docker rmi ${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
    }
}