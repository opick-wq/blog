pipeline {
    agent any

    environment {
        // ID credentials untuk Docker Hub
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub') 
        // ID credentials untuk file kubeconfig Anda
        KUBECONFIG_CREDENTIALS = credentials('kubeconfig-dev') // Ganti ID jika perlu
        // Nama image Docker Anda
        DOCKER_IMAGE = "sultan877/blog-statis" 
    }

    stages {
        // Stage 'Checkout' tidak diperlukan di sini, 
        // karena Jenkins sudah otomatis melakukan checkout kode dari SCM
        // yang dikonfigurasi di pengaturan Pipeline job.

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
                    // Login, Push, dan Tag image
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
                // Gunakan wrapper withKubeconfig untuk memuat credentials K8s secara aman
                withKubeConfig(credentialsId: 'kubeconfig-dev') {
                    // Semua perintah 'kubectl' di dalam blok ini akan menggunakan kubeconfig yang disediakan
                    script {
                        echo "Updating Kubernetes deployment with image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                        // Ganti tag image di file deployment.yaml secara dinamis
                        sh "sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' kubernetes/deployment.yaml"
                        
                        echo "Applying deployment to Kubernetes cluster..."
                        sh "kubectl apply -f kubernetes/deployment.yaml"

                        echo "Applying service to Kubernetes cluster..."
                        sh "kubectl apply -f kubernetes/service.yaml"

                        echo "Verifying deployment rollout status..."
                        // Perintah ini akan menunggu sampai deployment selesai dan berhasil
                        sh "kubectl rollout status deployment/blog-statis-deployment --timeout=2m"
                    }
                }
            }
        }
    }
    post {
        always {
            // Selalu logout dari Docker Hub dan hapus image lokal untuk kebersihan
            echo "Logging out from Docker Hub..."
            sh "docker logout"
            // Menggunakan -f (force) untuk menghindari error jika build gagal dan image tidak ada
            echo "Cleaning up local Docker image..."
            sh "docker rmi -f ${DOCKER_IMAGE}:${BUILD_NUMBER}"
        }
    }
}