#!/bin/bash
# Jenkins Installation Script for Amazon Linux 2

# Update system
yum update -y

# Install Java 11
yum install -y java-11-amazon-corretto

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker jenkins
usermod -aG docker ec2-user

# Install kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.27.1/2023-04-19/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin
ln -s /usr/local/bin/kubectl /usr/bin/kubectl

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install -y unzip
unzip awscliv2.zip
./aws/install

# Install Maven
cd /opt
wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
tar xzf apache-maven-3.8.6-bin.tar.gz
ln -s apache-maven-3.8.6 maven
echo 'export PATH=/opt/maven/bin:$PATH' >> /etc/profile
echo 'export MAVEN_HOME=/opt/maven' >> /etc/profile

# Configure Jenkins
systemctl start jenkins
systemctl enable jenkins

# Configure Docker registry login for ECR
mkdir -p /var/lib/jenkins/.docker
chown jenkins:jenkins /var/lib/jenkins/.docker

# Install git
yum install -y git

# Create initial admin password display script
cat > /home/ec2-user/get-jenkins-password.sh << 'EOF'
#!/bin/bash
echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
EOF

chmod +x /home/ec2-user/get-jenkins-password.sh

# Wait for Jenkins to start and then display password
(sleep 60 && /home/ec2-user/get-jenkins-password.sh) &