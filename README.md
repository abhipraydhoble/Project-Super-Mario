
## Project Workflow
Step 1 → Login and basics setup

Step 2 → Setup Docker ,Terraform ,aws cli , and Kubectl

Step 3 → IAM Role for EC2

Step 4 →Attach IAM role with your EC2

Step 5 → Building Infrastructure Using terraform

Step 6 → Creation of deployment and service for EKS

Step 7 → Destroy all the Insrastructure

### Step 1 → Login and basics setup:
1. Click on launch Instance
   ![instance](https://github.com/abhipraydhoble/Project-Super-Mario/assets/122669982/5fe51373-eaac-4f7c-9669-34c578277051)
2. Connect to EC2-Instance
   ![connect-ec2](https://github.com/abhipraydhoble/Project-Super-Mario/assets/122669982/9d518e77-6f65-4153-acfc-790a6eaf669a)

### Step 2 → Setup Docker ,Terraform ,aws cli , and Kubectl

````
sudo apt update -y
````
Setup Docker:
````
sudo apt install docker.io
sudo usermod -aG docker $USER
newgrp docker
docker --version
````
Setup Terraform:
````
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform
terraform --version

````
Setup AWS cli:
````
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip 
unzip awscliv2.zip
sudo ./aws/install
aws --version

````
Setup Kubectl:
````
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
kubectl version --client
````
