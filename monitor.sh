#!/bin/bash

# Monitor Infrastructure Status Script
echo "🔍 Infrastructure Status Monitor"
echo "================================"
echo "Date: $(date)"
echo ""

# Function to check EKS node group status
check_eks_nodes() {
    echo "📊 EKS Node Group Status:"
    echo "------------------------"
    
    status=$(aws eks describe-nodegroup \
      --cluster-name sample-java-app-cluster \
      --nodegroup-name sample-java-app-node-group \
      --region us-west-2 \
      --query 'nodegroup.status' \
      --output text 2>/dev/null)
    
    if [ "$status" = "ACTIVE" ]; then
        echo "✅ Node Group: ACTIVE"
        
        # Check actual nodes
        kubectl get nodes 2>/dev/null && echo "✅ Nodes are ready" || echo "⚠️  Nodes not yet available in kubectl"
        
        # Get instance details
        aws eks describe-nodegroup \
          --cluster-name sample-java-app-cluster \
          --nodegroup-name sample-java-app-node-group \
          --region us-west-2 \
          --query 'nodegroup.{Status:status,InstanceTypes:instanceTypes,ScalingConfig:scalingConfig,Health:health}' \
          --output table
          
    elif [ "$status" = "CREATING" ]; then
        echo "🔄 Node Group: CREATING (still in progress)"
    elif [ "$status" = "CREATE_FAILED" ]; then
        echo "❌ Node Group: CREATE_FAILED"
        echo "Error details:"
        aws eks describe-nodegroup \
          --cluster-name sample-java-app-cluster \
          --nodegroup-name sample-java-app-node-group \
          --region us-west-2 \
          --query 'nodegroup.health.issues' \
          --output table
    else
        echo "❓ Node Group Status: $status"
    fi
    echo ""
}

# Function to check Jenkins status
check_jenkins() {
    echo "🔧 Jenkins Server Status:"
    echo "-------------------------"
    
    jenkins_ip="35.91.0.7"
    jenkins_url="http://${jenkins_ip}:8080"
    
    # Check if Jenkins is responding
    if curl -s -I "$jenkins_url" >/dev/null 2>&1; then
        echo "✅ Jenkins is accessible at: $jenkins_url"
        
        # Check if setup wizard is ready
        if curl -s "$jenkins_url" | grep -q "Getting Started"; then
            echo "🎯 Jenkins setup wizard is ready"
            echo "📝 To get initial admin password:"
            echo "   ssh -i ~/.ssh/id_rsa ec2-user@$jenkins_ip"
            echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
        fi
    else
        echo "🔄 Jenkins is starting up... (may take 3-5 minutes)"
        echo "📍 Jenkins URL: $jenkins_url"
        
        # Check EC2 instance status
        instance_state=$(aws ec2 describe-instances \
          --filters "Name=tag:Name,Values=sample-java-app-jenkins" \
          --query 'Reservations[0].Instances[0].State.Name' \
          --output text 2>/dev/null)
        echo "🖥️  EC2 Instance State: $instance_state"
    fi
    echo ""
}

# Function to check application deployment readiness
check_app_readiness() {
    echo "🚀 Application Deployment Readiness:"
    echo "-----------------------------------"
    
    # Check ECR repository
    echo "📦 ECR Repository:"
    aws ecr describe-repositories \
      --repository-names sample-java-app-repo \
      --region us-west-2 \
      --query 'repositories[0].{Name:repositoryName,URI:repositoryUri,CreatedAt:createdAt}' \
      --output table 2>/dev/null || echo "❌ ECR repository not found"
    
    # Check ALB
    echo "🌐 Application Load Balancer:"
    alb_state=$(aws elbv2 describe-load-balancers \
      --names sample-java-app-alb \
      --query 'LoadBalancers[0].State.Code' \
      --output text 2>/dev/null)
    
    if [ "$alb_state" = "active" ]; then
        echo "✅ ALB is active: http://sample-java-app-alb-1187300512.us-west-2.elb.amazonaws.com"
    else
        echo "🔄 ALB State: $alb_state"
    fi
    echo ""
}

# Function to show next steps
show_next_steps() {
    echo "🎯 Next Steps:"
    echo "-------------"
    
    node_status=$(aws eks describe-nodegroup \
      --cluster-name sample-java-app-cluster \
      --nodegroup-name sample-java-app-node-group \
      --region us-west-2 \
      --query 'nodegroup.status' \
      --output text 2>/dev/null)
    
    jenkins_ready=$(curl -s -I "http://35.91.0.7:8080" >/dev/null 2>&1 && echo "true" || echo "false")
    
    if [ "$node_status" = "ACTIVE" ] && [ "$jenkins_ready" = "true" ]; then
        echo "✅ Infrastructure is ready! You can now:"
        echo "1. Access Jenkins: http://35.91.0.7:8080"
        echo "2. Build and deploy the application"
        echo "3. Set up CI/CD pipeline"
    elif [ "$node_status" = "ACTIVE" ]; then
        echo "🔄 EKS is ready, waiting for Jenkins..."
        echo "1. Monitor Jenkins startup: curl -I http://35.91.0.7:8080"
    elif [ "$jenkins_ready" = "true" ]; then
        echo "🔄 Jenkins is ready, waiting for EKS nodes..."
        echo "1. Monitor node group: kubectl get nodes"
    else
        echo "🔄 Waiting for both EKS nodes and Jenkins to be ready..."
        echo "1. This script will update every 30 seconds"
    fi
    echo ""
}

# Main execution
while true; do
    clear
    echo "🔍 Infrastructure Status Monitor"
    echo "================================"
    echo "Date: $(date)"
    echo ""
    
    check_eks_nodes
    check_jenkins
    check_app_readiness
    show_next_steps
    
    echo "⏱️  Auto-refreshing in 30 seconds... (Press Ctrl+C to stop)"
    sleep 30
done