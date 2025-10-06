pipeline {
    agent any
    
    tools {
        maven 'Maven-3.8.6'
    }
    
    environment {
        AWS_REGION = 'us-west-2'
        ECR_REGISTRY = '043031296302.dkr.ecr.us-west-2.amazonaws.com'
        ECR_REPOSITORY = 'sample-java-app-repo'
        IMAGE_TAG = "${BUILD_NUMBER}"
        EKS_CLUSTER = 'sample-java-app-cluster'
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Code checked out successfully'
            }
        }
        
        stage('Build with Maven') {
            steps {
                sh 'mvn clean compile test package'
                echo 'Maven build completed'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    archiveArtifacts 'target/*.jar'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
                script {
                    def dockerImage = docker.build("${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}")
                    echo "Docker image built: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('ECR Login & Push') {
            steps {
                script {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                        docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
                    """
                    echo "Image pushed to ECR: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Update Kubernetes Manifest') {
            steps {
                script {
                    // Update the deployment YAML with new image
                    sh """
                        sed -i 's|image: .*|image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}|g' k8s/deployment.yaml
                        cat k8s/deployment.yaml
                    """
                    echo "Kubernetes manifest updated with new image tag"
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    sh """
                        # Configure kubectl for EKS
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                        
                        # Apply Kubernetes manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        
                        # Wait for deployment to complete
                        kubectl rollout status deployment/sample-java-app --timeout=300s
                        
                        # Get deployment status
                        kubectl get deployments
                        kubectl get pods
                        kubectl get services
                    """
                    echo "Application deployed to EKS cluster"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    sh """
                        # Get the LoadBalancer URL
                        LOAD_BALANCER=\$(kubectl get service sample-java-app-nodeport -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                        if [ ! -z "\$LOAD_BALANCER" ]; then
                            echo "Application is accessible at: http://\$LOAD_BALANCER:30080"
                        else
                            echo "Service is running as NodePort. Check your EKS cluster nodes."
                        fi
                        
                        # Show pod status
                        kubectl describe pods -l app=sample-java-app
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
            emailext(
                subject: "✅ Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "The build was successful. Application deployed to EKS cluster.",
                to: "developer@company.com"
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext(
                subject: "❌ Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: "The build failed. Please check the logs.",
                to: "developer@company.com"
            )
        }
    }
}