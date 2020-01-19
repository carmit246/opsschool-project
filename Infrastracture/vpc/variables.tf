variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_config" {
  description = "AWS VPC configuration"
  default     = {
      name = "project-vpc"
      cidr_block = "10.0.0.0/16"
  }
}

variable "num_public_subnets"{
  default = 2
}

variable "project_zones" {
  type = "list"
  default = ["us-east-1a","us-east-1b"]
}

variable "public_subnets" {
  type = "list"
  default = ["project-pub-1a","project-pub-1b"]
}

variable "public_subnets_cidrs" {
  type = "list"
  default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "num_private_subnets" {
  default = 2
}

variable "private_subnets" {
  type = "list"
  default = ["project-private-1a","project-private-1b"]
}
variable "private_subnets_cidrs" {
  type = "list"
  default = ["10.0.3.0/24","10.0.4.0/24"]
}