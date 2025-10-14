<img width="1022" height="1051" alt="image" src="https://github.com/user-attachments/assets/86d1079a-c3ea-43a0-97c0-e7edf66b2904" />

# 🏗️ Demo: 3-Tier Application on AWS

This project demonstrates how to **deploy a 3-tier Node.js web application** using **AWS CodePipeline, CodeDeploy, and CloudFormation**.

---

## 📁 Project Structure

Your GitHub repository should follow this structure:

```
/
|-- app.js
|-- package.json
|-- appspec.yml
|-- scripts/
|   |-- start_server.sh
|   |-- stop_server.sh
```

### 🔍 File Breakdown

| File                | Description                                                                              |
| ------------------- | ---------------------------------------------------------------------------------------- |
| **app.js**          | Main file for your Node.js application. Contains the web server logic.                   |
| **package.json**    | Defines project metadata and dependencies (e.g., `express`, `mysql`).                    |
| **appspec.yml**     | AWS CodeDeploy specification file. Defines where to copy files and which scripts to run. |
| **scripts/**        | Directory containing deployment scripts.                                                 |
| **start_server.sh** | Installs dependencies, fetches DB credentials, and starts the app.                       |
| **stop_server.sh**  | Safely stops the running app before deploying a new version.                             |

When pushed to GitHub, **AWS CodePipeline** will automatically build and deploy your application using these files.

---

## 🧩 Application Files

### **File 1: app.js**

Simple Node.js web app that connects to a database and displays connection status.

### **File 2: package.json**

Lists the app dependencies (`express`, `mysql`) required to run the server.

### **File 3: appspec.yml**

Defines deployment instructions for **AWS CodeDeploy** on EC2 instances.

### **Files 4 & 5: Deployment Scripts**

Add these inside the `scripts` folder:

```
scripts/start_server.sh   # Starts the server
scripts/stop_server.sh    # Stops the server
```

---

## ☁️ Step 2: Deploy Infrastructure with One File

We’ll use a **single CloudFormation template** to deploy the entire AWS environment — VPC, subnets, security groups, RDS database, Load Balancer, and EC2 Auto Scaling group.

**Filename:** `all-in-one-stack.yml`

### 🛠️ Deployment Steps

1. Go to **AWS CloudFormation Console** → Click **Create Stack**
2. Upload `all-in-one-stack.yml`
3. Name your stack (e.g., `MyWebApp-Stack`)
4. Provide parameters:

   * **KeyName** → Your EC2 key pair
   * **DBPassword** → A secure DB password
5. Acknowledge IAM resource creation
6. Click **Create stack** and wait 15–20 minutes

---

## 🔄 Step 3: Set Up the CI/CD Pipeline

Once the stack is deployed, set up your CI/CD pipeline:

### 1️⃣ Store DB Credentials in Parameter Store

Go to **Systems Manager → Parameter Store** and create:

| Name                 | Type         | Value                                             |
| -------------------- | ------------ | ------------------------------------------------- |
| `/MyApp/DB_HOST`     | String       | *(Copy from CloudFormation Outputs → DBEndpoint)* |
| `/MyApp/DB_USER`     | String       | `masteruser`                                      |
| `/MyApp/DB_PASSWORD` | SecureString | *(Your DB password)*                              |

---

### 2️⃣ Create CodeDeploy Application

1. Go to **AWS CodeDeploy → Applications → Create Application**

   * Name: `MyWebApp`
   * Platform: `EC2/On-premises`
2. Inside the app, create a **Deployment Group**:

   * Name: `MyWebApp-DG`
   * Service Role: *Let AWS create one*
   * Environment: Select the EC2 Auto Scaling group from your stack
   * Disable load balancing
   * Click **Create Deployment Group**

---

### 3️⃣ Create CodePipeline

1. Go to **AWS CodePipeline → Create Pipeline**
2. **Name:** `MyWebApp-Pipeline`
3. **Source:** Connect to your GitHub repo
4. **Build:** Use **AWS CodeBuild**

   * Let it detect `buildspec.yml` automatically
   * Grant IAM permission to read SSM parameters
5. **Deploy:** Choose **AWS CodeDeploy**

   * Application: `MyWebApp`
   * Deployment Group: `MyWebApp-DG`
6. Click **Create Pipeline**

---

## ✅ Step 4: Test Your Deployment

Once the pipeline completes successfully:

* Go to your CloudFormation stack’s **Outputs** tab
* Copy the **LoadBalancerDNS** value
* Paste it in your browser → You should see a “**Hello World**” message and database connection status 🎉

---

## ⚙️ Important Regional Configuration Notes

Depending on your AWS region, you may need to update some values in `all-in-one-stack.yml`.

### 1️⃣ Required Parameters (No File Changes)

| Parameter      | Description                |
| -------------- | -------------------------- |
| **KeyName**    | Your EC2 SSH key pair name |
| **DBPassword** | Secure password for RDS    |

---

### 2️⃣ Must Change if **NOT** in `us-east-1` (N. Virginia)

#### 🔸 A. Amazon Machine Image (AMI) ID

**Line 126:**

```yaml
ImageId: 'ami-0c55b159cbfafe1f0'
```

This AMI ID is region-specific.

✅ **To fix:**

1. Go to EC2 Console → Launch Instance
2. Search for “Amazon Linux 2”
3. Copy its AMI ID (e.g., `ami-xxxxxxxxxxxxxxxxx`)
4. Replace it in your YAML file

---

#### 🔸 B. CodeDeploy Agent URL

**Line 139:**

```bash
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
```

Change this URL to match your region:

| Region                    | Example URL                                                                    |
| ------------------------- | ------------------------------------------------------------------------------ |
| **Europe (London)**       | `https://aws-codedeploy-eu-west-2.s3.eu-west-2.amazonaws.com/latest/install`   |
| **Asia Pacific (Mumbai)** | `https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install` |

---

## 🧾 Summary

* ✅ **us-east-1** users: No edits needed.
* 🌍 Other regions: Update `ImageId` and `wget` URL.
* 💡 Provide `KeyName` and `DBPassword` during stack launch.
* 🚀 Once deployed, the AWS CodePipeline automates the full build → test → deploy workflow.

---

### 🧠 Tip

 **training sessions, workshops, or quick POCs** demonstrating CI/CD pipelines and AWS infrastructure automation with a working full-stack Node.js application.




## 🚀 How Others Can Use This Project

This repository is designed so **anyone can clone it**, customize their code, and deploy their own 3-tier application using **AWS CodePipeline + CloudFormation**.

---

### 🧩 Step 1: Fork or Clone This Repository

#### Option 1: Fork

1. Click **“Fork”** on the top right of this repository.
2. This creates a personal copy under your GitHub account.
3. Clone your forked version:

   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
   ```

#### Option 2: Clone Directly (if you just want to test)

```bash
git clone https://github.com/<original-owner>/<repo-name>.git
cd <repo-name>
```

---

### 🧰 Step 2: Customize Your Application

You can now:

* Modify `app.js` to include your own routes or logic.
* Add dependencies in `package.json` if needed.
* Update `appspec.yml` or deployment scripts (`scripts/start_server.sh`, `stop_server.sh`) as per your app requirements.

> 💡 *Make sure the start script in `start_server.sh` matches your main app entry point.*

---

### ☁️ Step 3: Deploy Your Own AWS Infrastructure

Use the included **CloudFormation template** (`all-in-one-stack.yml`) to spin up your own 3-tier AWS environment.

1. Go to **AWS CloudFormation Console → Create Stack**
2. Upload `all-in-one-stack.yml`
3. Provide the following parameters:

   * **KeyName** → your EC2 key pair name
   * **DBPassword** → a secure password for the RDS database
4. Wait for the stack to finish (about 15–20 minutes).

---

### 🔐 Step 4: Add Your Database Credentials in Parameter Store

In **AWS Systems Manager → Parameter Store**, add:

| Parameter            | Type         | Example Value                                 |
| -------------------- | ------------ | --------------------------------------------- |
| `/MyApp/DB_HOST`     | String       | Copy from CloudFormation Outputs → DBEndpoint |
| `/MyApp/DB_USER`     | String       | masteruser                                    |
| `/MyApp/DB_PASSWORD` | SecureString | your password                                 |

---

### 🔄 Step 5: Set Up Your Own CI/CD Pipeline

1. Go to **AWS CodePipeline → Create Pipeline**
2. Connect to your **forked GitHub repo**
3. Add **AWS CodeBuild** for the build stage (it will auto-detect your `buildspec.yml` if you add one)
4. Add **AWS CodeDeploy** for the deploy stage
5. Select the **Application Name** and **Deployment Group** created from your stack

That’s it — your AWS pipeline will automatically deploy your version of the app whenever you push new commits to GitHub 🎉

---

### 🧾 Optional: Rename and Brand It

If you’re reusing this template for your own project:

* Change the project name in **README.md**
* Update AWS stack name (e.g., `MyCoolApp-Stack`)
* Replace any old branding references

---

### 🧠 Bonus Tip — Automate Personalization

If you want others to onboard quickly, you can include a **“Setup Script”** in your repo:

```bash
#!/bin/bash
echo "Cloning repo and configuring AWS pipeline..."
# Example: ask user for app name, AWS region, and DB password
# Automatically substitute values in all-in-one-stack.yml before deployment
```

This makes your repo **template-ready** for others.

---

### ✅ Summary

| Step                  | Description                                 |
| --------------------- | ------------------------------------------- |
| **1. Fork / Clone**   | Copy the repository                         |
| **2. Customize Code** | Modify app.js, scripts, etc.                |
| **3. Deploy Infra**   | Run CloudFormation template                 |
| **4. Store Secrets**  | Add credentials in Parameter Store          |
| **5. Setup Pipeline** | Create your own CI/CD flow                  |
| **6. Push & Deploy**  | Your code auto-deploys via AWS CodePipeline |

