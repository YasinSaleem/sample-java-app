# CI/CD Pipeline for Java Application on AWS EKS

## 🎯 Project Overview
This project implements a complete CI/CD pipeline to deploy a Dockerized Java web application to a Kubernetes cluster on AWS using Jenkins, GitHub, Maven, Terraform, and Ansible.

## 🏗️ Architecture Components

### Infrastructure (Terraform)
- **VPC** with public and private subnets across 3 AZs
- **EKS Cluster** with Kubernetes 1.28
- **Jenkins EC2 Instance** (t3.medium) with auto-configuration
- **ECR Repository** for Docker images
- **Application Load Balancer** for external access
- **NAT Gateways** for private subnet internet access

### CI/CD Pipeline (Jenkins)
- **Source Control**: GitHub integration
- **Build Tool**: Maven 3.8.6
- **Container**: Docker with ECR registry
- **Orchestration**: Kubernetes on EKS
- **Configuration**: Ansible playbooks

## 📁 Project Structure
```
sample-java-app/
├── src/main/java/com/example/demo/
│   ├── DemoApplication.java      # Main Spring Boot app
│   └── HelloController.java      # REST controller
├── k8s/
│   ├── deployment.yaml           # K8s deployment manifest
│   └── service.yaml              # K8s service manifest  
├── terraform/
│   ├── main.tf                   # Infrastructure definitions
│   ├── variables.tf              # Terraform variables
│   ├── outputs.tf                # Infrastructure outputs
│   └── jenkins-userdata.sh       # Jenkins auto-install script
├── ansible/
│   ├── install-jenkins.yml       # Jenkins configuration playbook
│   └── inventory                 # Ansible inventory template
├── Dockerfile                    # Container definition
├── Jenkinsfile                   # CI/CD pipeline definition  
├── pom.xml                       # Maven build configuration
└── README.md                     # This documentation
```

## 🚀 Deployment Steps

### Phase 1: Infrastructure Provisioning
```bash
# 1. Initialize Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Expected Output:
# - Jenkins Public IP
# - EKS Cluster endpoint
# - ECR Repository URL
# - Load Balancer DNS name
```

### Phase 2: Jenkins Configuration
```bash
# 2. Update Ansible inventory with Jenkins IP
cd ../ansible
# Edit inventory file with actual Jenkins IP from Terraform output

# 3. Configure Jenkins using Ansible
ansible-playbook -i inventory install-jenkins.yml

# 4. Access Jenkins
# URL: http://<jenkins-ip>:8080
# Get password: ssh ec2-user@<jenkins-ip> sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Phase 3: EKS Configuration
```bash
# 5. Configure kubectl for EKS
aws eks update-kubeconfig --region us-west-2 --name sample-java-app-cluster

# 6. Verify cluster access
kubectl get nodes
kubectl get namespaces
```

### Phase 4: CI/CD Pipeline Setup
```bash
# 7. Create Jenkins Pipeline Job
# - New Item -> Pipeline
# - Configure GitHub repository
# - Select "Pipeline script from SCM"
# - Set repository URL and Jenkinsfile path

# 8. Configure Jenkins Credentials
# - AWS credentials for ECR access
# - GitHub credentials for repository access
# - Kubeconfig for EKS deployment
```

## 🔄 CI/CD Pipeline Workflow

### Stage 1: Checkout Code
- Jenkins pulls code from GitHub repository
- Triggers on push to main branch or PR

### Stage 2: Maven Build
- Compiles Java source code
- Runs unit tests  
- Packages application as JAR
- Archives build artifacts

### Stage 3: Docker Build
- Creates Docker image from Dockerfile
- Tags image with build number
- Optimized for Spring Boot applications

### Stage 4: ECR Push
- Authenticates with AWS ECR
- Pushes Docker image to repository
- Tags both with build number and 'latest'

### Stage 5: Kubernetes Deploy
- Updates deployment manifest with new image
- Applies manifests to EKS cluster
- Waits for rollout completion
- Performs health checks

### Stage 6: Verification
- Checks pod status and logs
- Verifies service endpoints
- Reports deployment status

## 🛠️ Technologies Used

| Component | Technology | Version |
|-----------|------------|---------|
| **Language** | Java | 17 |
| **Framework** | Spring Boot | 3.1.4 |
| **Build Tool** | Maven | 3.8.6 |
| **Container** | Docker | Latest |
| **Orchestration** | Kubernetes | 1.28 |
| **Cloud Platform** | AWS EKS | Latest |
| **CI/CD** | Jenkins | Latest |
| **Infrastructure** | Terraform | >= 1.0 |
| **Configuration** | Ansible | Latest |
| **Registry** | AWS ECR | Latest |

## 🌐 Access Points

### Application URLs
- **Load Balancer**: `http://<alb-dns-name>`
- **NodePort**: `http://<node-ip>:30080`
- **Health Check**: `/actuator/health` (if enabled)

### Management Interfaces  
- **Jenkins**: `http://<jenkins-ip>:8080`
- **Kubernetes Dashboard**: (if deployed)
- **AWS Console**: EKS, ECR, EC2 services

## 📊 Monitoring & Logging

### Application Monitoring
- Spring Boot Actuator endpoints
- Kubernetes liveness/readiness probes
- Container resource monitoring

### Pipeline Monitoring
- Jenkins build history and logs
- Email notifications on build status
- Slack integration (configurable)

### Infrastructure Monitoring
- CloudWatch for AWS resources
- EKS cluster metrics
- Application Load Balancer metrics

## 🔒 Security Considerations

### Network Security
- Private subnets for EKS nodes
- Security groups with minimal required ports
- VPC isolation and NAT gateways

### Access Control
- IAM roles for EKS and Jenkins
- ECR repository policies
- SSH key-based EC2 access

### Secrets Management
- Jenkins credentials store
- AWS IAM roles (no hardcoded keys)
- Kubernetes secrets for sensitive data

## 🧪 Testing Strategy

### Unit Testing
- Maven Surefire plugin
- JUnit test execution
- Test coverage reporting

### Integration Testing
- Health check endpoints
- Service connectivity tests
- Database integration (when applicable)

### Deployment Testing
- Rolling deployment verification
- Zero-downtime deployment
- Rollback capabilities

## 📈 Scaling & Performance

### Horizontal Pod Autoscaling
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: sample-java-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sample-java-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### EKS Node Group Scaling
- Min: 1 node
- Desired: 3 nodes  
- Max: 10 nodes
- Instance type: t3.medium

## 🚨 Troubleshooting

### Common Issues

#### Jenkins Build Failures
```bash
# Check Jenkins logs
sudo journalctl -u jenkins -f

# Verify Docker permissions
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### EKS Deployment Issues
```bash
# Check pod status
kubectl get pods -o wide
kubectl describe pod <pod-name>

# Check node status
kubectl get nodes
kubectl describe node <node-name>
```

#### ECR Push Failures
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-url>

# Check IAM permissions
aws sts get-caller-identity
```

## 🔄 Maintenance

### Regular Tasks
- Update Jenkins plugins monthly
- Rotate SSH keys quarterly
- Review and update IAM policies
- Monitor resource usage and costs

### Backup Strategy
- Jenkins configuration backup
- Database backups (if applicable)
- Infrastructure state backup (Terraform)

## 💰 Cost Optimization

### AWS Resources Cost (Monthly Estimate)
- EKS Cluster: ~$73
- EC2 Instances (3x t3.medium): ~$100
- NAT Gateways (3x): ~$135
- Application Load Balancer: ~$23
- **Total**: ~$331/month

### Cost Reduction Tips
- Use Spot instances for development
- Schedule EKS nodes during business hours
- Implement resource quotas
- Monitor usage with AWS Cost Explorer

## 📚 Additional Resources

### Documentation Links
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)

### Learning Resources
- [AWS EKS Workshop](https://www.eksworkshop.com/)
- [Jenkins Pipeline Tutorial](https://www.jenkins.io/doc/tutorials/)
- [Kubernetes Learning Path](https://kubernetes.io/docs/tutorials/)

---

## ✅ Project Completion Checklist

- [x] ✅ **Java Application** (Spring Boot with REST endpoints)
- [x] ✅ **Dockerfile** (Multi-stage build for optimization)
- [x] ✅ **Kubernetes Manifests** (Deployment and Service)
- [x] ✅ **Terraform Infrastructure** (VPC, EKS, Jenkins, ECR)
- [x] ✅ **Jenkins Pipeline** (Complete CI/CD workflow)
- [x] ✅ **Ansible Playbook** (Jenkins configuration automation)
- [x] ✅ **Documentation** (Comprehensive setup guide)

**Status**: 🚀 **READY FOR DEPLOYMENT**

This project demonstrates a production-ready CI/CD pipeline following DevOps best practices with full automation from code commit to production deployment.