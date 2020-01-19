variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_config" {
  description = "AWS VPC configuration"
  default     = {
      name = "lesson3hw-vpc"
      cidr_block = "10.0.0.0/16"
  }
}
