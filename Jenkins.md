````
pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "ap-southeast-1"
        CLUSTER_NAME = "EKS_CLOUD"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git 'https://github.com/abhipraydhoble/Project-Super-Mario.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('EKS-TF') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('EKS-TF') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('EKS-TF') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: "Approve Terraform Apply?"
                dir('EKS-TF') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Update kubeconfig') {
            steps {
                sh '''
                aws eks --region $AWS_DEFAULT_REGION \
                update-kubeconfig --name $CLUSTER_NAME
                '''
            }
        }

        stage('Verify Cluster') {
            steps {
                sh 'kubectl get nodes'
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
            }
        }

        stage('Check Service') {
            steps {
                sh 'kubectl get svc mario-service'
            }
        }
    }
}
````
