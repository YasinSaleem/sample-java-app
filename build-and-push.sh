#!/bin/bash

# Build and Push Script for ARM64 Mac to AMD64 EKS
# This script ensures Docker images are built for the correct architecture

set -e

# Configuration
AWS_REGION="us-west-2"
ECR_REGISTRY="043031296302.dkr.ecr.us-west-2.amazonaws.com"
ECR_REPOSITORY="sample-java-app-repo"
IMAGE_TAG="${1:-latest}"

echo "🔨 Building Java application with Maven..."
mvn clean package -DskipTests

echo "🐳 Building Docker image for AMD64 architecture..."
# Build for AMD64 (x86_64) to run on EKS nodes
docker buildx build --platform linux/amd64 -t ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .

echo "🔐 Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

echo "📤 Pushing image to ECR..."
docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}

# Also tag and push as latest
if [ "$IMAGE_TAG" != "latest" ]; then
    docker tag ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
    docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:latest
fi

echo "✅ Image built and pushed successfully!"
echo "📍 Image: ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"