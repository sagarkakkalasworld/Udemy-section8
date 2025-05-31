# GitLab CI/CD: Using a Self-Hosted Runner on AWS

## 👤 Step 0: Create GitLab Account

Start by creating a GitLab account using your existing email ID. You can then either:

- Import your project from GitHub to GitLab
- Or create a new repository directly in your GitLab account

## 🔐 GitLab Token for Git Push

Generate a **GitLab Personal Access Token** and use it for pushing code using the following format:

```bash
git push https://<username>:<token>@gitlab.com/sagarkakkala-group
````

---

## 🖥️ Step 1: Create AWS Instance and Setup SSH

1. Launch an AWS EC2 Instance to act as the self-hosted runner.
2. Establish an SSH connection between the self-hosted server and the Demo Server.

## 🔑 Step 2: Generate SSH Key Pair

```bash
ssh-keygen
```

This generates a key pair at:

* `/home/ubuntu/.ssh/id_rsa` (private key)
* `/home/ubuntu/.ssh/id_rsa.pub` (public key)

Copy the public key content and paste it into the `authorized_keys` file on the Demo Server.

## 🔁 Step 3: Test SSH Connection

```bash
ssh ubuntu@{DemoServer_Private_IP}
exit
```

---

## 💾 Step 4: Store Private Key as GitLab Variable

Go to:

`Settings → CI/CD → Variables`

Paste the contents of your private key into a variable named:

```text
UBUNTU_SERVER_SSH
```

---

## ⚙️ Step 5: Set Up GitLab Runner

Navigate to:

`Settings → CI/CD → Runners`

Follow the instructions provided and assign appropriate tags. Make sure the runner and the demo server can communicate via SSH.

### 🧰 Install GitLab Runner

```bash
# Download the binary
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Make it executable
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a user for GitLab Runner
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and start as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```

### 📝 Register the Runner

```bash
gitlab-runner register \
  --url https://gitlab.com \
  --token <your-registration-token>
```

Replace `<your-registration-token>` with your actual GitLab runner token.

---

## 📄 Step 6: Create `.gitlab-ci.yml`

```yaml
stages:
  - pre_requisites
  - build
  - deploy

variables:
  DEMO_SERVER: "172.31.30.63"  # Change to your private IP

before_script:
  - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
  - eval $(ssh-agent -s)
  - echo "$UDEMY_SERVER_SSH_KEY" | tr -d '\r' | ssh-add -
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh
  - ssh-keyscan -H $AWS_PRIVATE_IP >> ~/.ssh/known_hosts

pre_requisites:
  stage: pre_requisites
  tags:
    - agent
    - cicd
  script:
    - |
      ssh ubuntu@$AWS_PRIVATE_IP << 'EOF'
        rm -rf /home/ubuntu/udemy-section7
        git clone https://gitlab.com/sagarkakkala-group/Udemy-section6.git
        cd udemy-section7
        chmod 744 build.sh
        chmod 744 deploy.sh
      EOF

build:
  stage: build
  tags:
    - agent
    - cicd
  needs: ["pre_requisites"]
  script:
    - ssh ubuntu@$AWS_PRIVATE_IP "bash /home/ubuntu/Udemy-section6/build.sh"

deploy:
  stage: deploy
  tags:
    - agent
    - cicd
  needs: ["build"]
  script:
    - ssh ubuntu@$AWS_PRIVATE_IP "bash /home/ubuntu/Udemy-section6/deploy.sh"
```

### This pipeline performs three main stages:

* **pre\_requisites**: Clones the repo and sets file permissions
* **build**: Executes the `build.sh` script
* **deploy**: Executes the `deploy.sh` script

---

## 🔗 Connect with Me

I post content related to contrafactums, fun vlogs, travel stories, DevOps and more. Use the link below for all access:

[🌐 Sagar Kakkala One Stop](https://linktr.ee/sagar_kakkalas_world)

🖊 Feedback, queries, and suggestions are welcome in the comments.

