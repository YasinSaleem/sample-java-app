# 🔧 **Jenkins Configuration Details - Step by Step**

## **STEP 1: Initial Jenkins Setup**

### **Access Jenkins:**
- URL: `http://35.91.0.7:8080`
- Initial Admin Password: `1e88ac6d9a8d4865893813ea5767f3ac`

### **Plugin Installation:**
When prompted for plugins, select **"Install suggested plugins"** PLUS these additional ones:
- `Docker Pipeline`
- `Kubernetes CLI`
- `AWS Steps`
- `Amazon ECR`
- `GitHub`
- `Maven Integration`

### **Create Admin User:**
- Username: `admin` (or your preferred username)
- Password: `your-secure-password`
- Full Name: `Your Name`
- Email: `your-email@example.com`

---

## **STEP 2: Configure Global Tools**

### **Go to:** Manage Jenkins → Global Tool Configuration

#### **Maven Configuration:**
- Name: `Maven-3.8.6`
- Install automatically: ✅ **Checked**
- Version: `3.8.6`

#### **JDK Configuration:**
- Name: `JDK-17`
- Install automatically: ✅ **Checked**
- Version: `OpenJDK 17`

#### **Docker Configuration:**
- Name: `Docker`
- Install automatically: ✅ **Checked**

---

## **STEP 3: Add Credentials**

### **Go to:** Manage Jenkins → Manage Credentials → System → Global credentials

#### **1. GitHub Credentials (Optional - for private repos):**
- Kind: `Secret text`
- Secret: `your-github-personal-access-token`
- ID: `github-token`
- Description: `GitHub Personal Access Token`

#### **2. AWS Credentials:**
- Kind: `AWS Credentials`
- Access Key ID: `your-aws-access-key-id`
- Secret Access Key: `your-aws-secret-access-key`
- ID: `aws-credentials`
- Description: `AWS ECR Access`

**Note:** You can get AWS credentials by running:
```bash
aws configure list
```

---

## **STEP 4: Create Pipeline Job**

### **Go to:** Jenkins Dashboard → New Item

#### **Job Configuration:**
- **Item Name:** `sample-java-app-pipeline`
- **Type:** Select **"Pipeline"**
- Click **"OK"**

#### **Pipeline Configuration Settings:**

**General Tab:**
- Description: `CI/CD Pipeline for Sample Java App`
- ✅ **GitHub project**
- Project URL: `https://github.com/YasinSaleem/sample-java-app`

**Build Triggers:**
- ✅ **GitHub hook trigger for GITScm polling**
- ✅ **Poll SCM** (optional backup)
- Schedule: `H/5 * * * *` (every 5 minutes)

**Pipeline Tab:**
- **Definition:** `Pipeline script from SCM`
- **SCM:** `Git`
- **Repository URL:** `https://github.com/YasinSaleem/sample-java-app`
- **Credentials:** Leave as `- none -` (for public repo)
- **Branch Specifier:** `*/main`
- **Script Path:** `Jenkinsfile`

**Advanced Settings:**
- Repository Browser: `(Auto)`
- Additional Behaviours: Leave empty

---

## **STEP 5: Environment Variables (if needed)**

### **In Pipeline Job → Configure → Pipeline:**

Add these environment variables in your Jenkinsfile (already configured):
```groovy
environment {
    AWS_REGION = 'us-west-2'
    ECR_REGISTRY = '043031296302.dkr.ecr.us-west-2.amazonaws.com'
    ECR_REPOSITORY = 'sample-java-app-repo'
    IMAGE_TAG = "${BUILD_NUMBER}"
    EKS_CLUSTER = 'sample-java-app-cluster'
}
```

---

## **STEP 6: Configure System Settings**

### **Go to:** Manage Jenkins → Configure System

#### **Jenkins Location:**
- Jenkins URL: `http://35.91.0.7:8080/`
- System Admin e-mail address: `your-email@example.com`

#### **GitHub:**
- GitHub Server: `GitHub` (default)
- API URL: `https://api.github.com`
- Credentials: Select your GitHub token (if added)

---

## **STEP 7: Test Pipeline**

### **Manual Test:**
1. Go to your pipeline job: `sample-java-app-pipeline`
2. Click **"Build Now"**
3. Monitor the build in **"Console Output"**

### **Expected Pipeline Stages:**
1. ✅ Checkout Code
2. ✅ Build with Maven
3. ✅ Docker Build
4. ✅ ECR Login & Push
5. ✅ Update Kubernetes Manifest
6. ✅ Deploy to EKS
7. ✅ Health Check

---

## **🔍 TROUBLESHOOTING REFERENCE**

### **Common Issues & Solutions:**

#### **Issue 1: AWS CLI not found**
**Solution:** Add to Jenkinsfile:
```groovy
sh 'which aws || (curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install)'
```

#### **Issue 2: Docker permission denied**
**Solution:** Ensure Jenkins user is in docker group (already done on your server)

#### **Issue 3: kubectl not found**
**Solution:** Add to Jenkinsfile:
```groovy
sh 'which kubectl || (curl -LO "https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl" && chmod +x kubectl && sudo mv kubectl /usr/local/bin/)'
```

#### **Issue 4: Maven not found**
**Solution:** Verify Maven tool configuration in Global Tool Configuration

---

## **🚀 READY TO GO!**

After completing these configurations:

1. **Save** your pipeline configuration
2. **Build Now** to test the pipeline
3. Check the **Console Output** for any errors
4. Verify application deployment: `http://sample-java-app-alb-1187300512.us-west-2.elb.amazonaws.com/`

**Your CI/CD pipeline will automatically:**
- ✅ Pull code from GitHub
- ✅ Build with Maven
- ✅ Create Docker image (AMD64 architecture)
- ✅ Push to ECR
- ✅ Deploy to EKS
- ✅ Verify application health

🎉 **That's it! Your complete CI/CD pipeline is ready!**