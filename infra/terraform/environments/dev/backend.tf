# Following Permissions are required for the user to access the S3 bucket:
# * s3:ListBucket
# * s3:GetObject
# * s3:PutObject
# ref: https://developer.hashicorp.com/terraform/language/backend/s3#s3-bucket-permissions

terraform {
  backend "s3" {
    bucket = "pf-tfstate-2025-02-22"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
