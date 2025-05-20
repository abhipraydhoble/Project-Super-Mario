terraform {
  backend "s3" {
    bucket = "super-mario-tf-kubernetes-project" # Replace with your actual S3 bucket name
    key    = "EKS/terraform.tfstate"
    region = "ap-southeast-1"
    profile = "eks"
  }
}
