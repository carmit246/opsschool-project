terraform {
 backend "s3" {
    bucket = "project-terraform-remote-state-storage-s3"
    key    = "servers/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "project-terraform-state-lock-dynamo"
  }
}