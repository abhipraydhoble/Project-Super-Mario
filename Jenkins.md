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
                git branch: 'main', url: 'https://github.com/abhipraydhoble/Project-Super-Mario.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir('EKS-TF') {
                    sh 'terraform init'
                }
                  }
               
            }
        }

        stage('Terraform Validate') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
               dir('EKS-TF') {
                    sh 'terraform validate'
                  }
               }
                
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('EKS-TF') {
                    sh 'terraform plan -out=tfplan'
                  }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                /* input message: "Approve Terraform Apply?" */
                dir('EKS-TF') {
                    sh 'terraform apply -auto-approve tfplan'
                  }
                }
            }
        }

        stage('Update kubeconfig') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                sh '''
                aws eks --region $AWS_DEFAULT_REGION \
                update-kubeconfig --name $CLUSTER_NAME 
                '''
                }
            }
        }

        stage('Verify Cluster') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                sh 'kubectl get nodes'
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                 withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                sh '''
                kubectl apply -f deployment.yaml
                kubectl apply -f service.yaml
                '''
                 }
            }
        }
         stage('Terraform destroy') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-cred', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
      
                dir('EKS-TF') {
                    sh 'terraform destroy -auto-approve'
                  }
                }
            }
        }

        
    }
}
````
