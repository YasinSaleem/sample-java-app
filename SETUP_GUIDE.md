# 🚀 Post-Infrastructure Setup Guide

## Infrastructure Status
✅ **VPC, Subnets, NAT Gateways** - Completed  
✅ **Application Load Balancer** - Completed  
✅ **ECR Repository** - Completed  
✅ **EKS Cluster** - Completed (8m6s)  
🔄 **EKS Node Group** - In Progress (20+ minutes)  
🔄 **Jenkins EC2** - In Progress  

## Once Terraform Completes

### 1. Get Infrastructure Details
```bash
# Get all outputs from Terraform
terraform output

# Expected outputs:
# - jenkins_public_ip = "xxx.xxx.xxx.xxx"
# - jenkins_url = "http://xxx.xxx.xxx.xxx:8080"  
# - eks_cluster_endpoint = "https://..."
# - ecr_repository_url = "043031296302.dkr.ecr.us-west-2.amazonaws.com/sample-java-app-repo"
```

### 2. Configure EKS Access
```bash
# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region us-west-2 --name sample-java-app-cluster

# Verify cluster access
kubectl get nodes
kubectl get namespaces
```

### 3. Access Jenkins Server
```bash
# SSH to Jenkins server (after getting IP from terraform output)
ssh -i ~/.ssh/id_rsa ec2-user@<jenkins-ip>

# Get Jenkins initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Access Jenkins web interface
# http://<jenkins-ip>:8080
```

### 4. Configure Jenkins
1. **Initial Setup**:
   - Go to Jenkins URL
   - Enter initial admin password
   - Install suggested plugins + additional plugins:
     - Docker Pipeline
     - Kubernetes CLI
     - Amazon ECR
     - GitHub Integration

2. **Create Credentials**:
   - AWS credentials for ECR access
   - GitHub personal access token
   - SSH key for repository access

3. **Configure Tools**:
   - Maven installation (should be auto-detected)
   - Docker (should be available)
   - kubectl (installed via user-data script)

### 5. Build and Push Docker Image Manually (First Time)
```bash
# Build the application
mvn clean package

# Login to ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 043031296302.dkr.ecr.us-west-2.amazonaws.com

# Build and push Docker image
docker build -t 043031296302.dkr.ecr.us-west-2.amazonaws.com/sample-java-app-repo:latest .
docker push 043031296302.dkr.ecr.us-west-2.amazonaws.com/sample-java-app-repo:latest
```

### 6. Deploy Application to EKS
```bash
# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# Check application logs
kubectl logs -l app=sample-java-app

# Get service endpoint
kubectl get service sample-java-app-nodeport -o wide
```

### 7. Set Up Jenkins Pipeline
1. **Create New Pipeline Job**:
   - New Item → Pipeline
   - Name: "sample-java-app-cicd"
   - Pipeline script from SCM

2. **Configure Repository**:
   - Repository URL: https://github.com/YasinSaleem/sample-java-app
   - Branch: main
   - Script Path: Jenkinsfile

3. **Configure Webhooks** (Optional):
   - GitHub repository settings
   - Add webhook: http://<jenkins-ip>:8080/github-webhook/

### 8. Test CI/CD Pipeline
```bash
# Make a change to the application
# For example, modify HelloController.java:

# Push changes to trigger pipeline
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# Monitor pipeline execution in Jenkins
# Check deployment in Kubernetes
kubectl get pods -w
```

### 9. Configure Ansible (Optional Enhancement)
```bash
# Update inventory file with actual Jenkins IP
cd ansible
sed -i 's/JENKINS_IP_HERE/<actual-jenkins-ip>/g' inventory

# Run Ansible playbook for additional Jenkins configuration
ansible-playbook -i inventory install-jenkins.yml
```

### 10. Access Your Application
Once everything is deployed:
- **Via ALB**: http://sample-java-app-alb-1187300512.us-west-2.elb.amazonaws.com
- **Via NodePort**: http://<node-ip>:30080
- **Health Check**: /actuator/health (if Spring Boot Actuator is enabled)

## 🔍 Troubleshooting Commands

### EKS Issues
```bash
# Check cluster status
aws eks describe-cluster --name sample-java-app-cluster --region us-west-2

# Check node group status  
aws eks describe-nodegroup --cluster-name sample-java-app-cluster --nodegroup-name sample-java-app-node-group --region us-west-2

# Check pod issues
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Jenkins Issues
```bash
# Check Jenkins service status
sudo systemctl status jenkins

# Check Jenkins logs
sudo journalctl -u jenkins -f

# Restart Jenkins if needed
sudo systemctl restart jenkins
```

### Docker/ECR Issues
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 043031296302.dkr.ecr.us-west-2.amazonaws.com

# List images in ECR
aws ecr list-images --repository-name sample-java-app-repo --region us-west-2
```

## ✅ Success Criteria
- [ ] Jenkins accessible at http://<jenkins-ip>:8080
- [ ] EKS cluster has 3 running nodes
- [ ] Application pods are running in Kubernetes
- [ ] Application accessible via Load Balancer
- [ ] CI/CD pipeline builds and deploys successfully
- [ ] ECR contains Docker images
- [ ] All infrastructure costs monitored

## 📊 Monitoring
- **AWS CloudWatch**: EKS, ALB, EC2 metrics
- **Jenkins**: Build history and logs
- **Kubernetes**: kubectl get events, pod logs
- **Application**: Spring Boot Actuator endpoints

---
*This guide will be updated as infrastructure deployment completes*