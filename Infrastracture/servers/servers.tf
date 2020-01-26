data "terraform_remote_state" "project-vpc" {
  backend = "s3"

  config = {
    bucket = "project-terraform-remote-state-storage-s3"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region     = "${var.aws_region}"
}
/* 
resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "${data.terraform_remote_state.project-vpc.outputs.vpc-id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 */

resource "aws_instance" "project-bastion" {
    #count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0]}")
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0],0)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    tags = {
        Name = "project-bastion"
    }
}
 

resource "aws_instance" "project-slave" {
    #count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0]}")
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0],1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    tags = {
        Name = "project-slave"
    }
}


resource "aws_instance" "project-k8s-master" {
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0], 1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    #iam_instance_profile = "${aws_iam_instance_profile.lesson3hw_profile.name}"
    #user_data = "${file("scripts/k8s.sh")}"
    tags = {
        Name = "project-k8s-master"
    }

  #   connection {
  #   	type = "ssh"
  #   	host = self.public_ip
	# user = "ubuntu"
	# private_key = "${file("/home/carmit/Downloads/ansible.pem")}"
  }


  resource "aws_instance" "project-k8s-nodes" {
    count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0]}")
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0],count.index)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-k8s-node}"]
    key_name = "ansible_key"
    #user_data = "${file("scripts/k8s_node.sh")}"
    #iam_instance_profile = "${aws_iam_instance_profile.lesson3hw_profile.name}"
    tags = {
        Name = "project-k8s-node${count.index}"
    }
}

resource "aws_instance" "project-consul" {
    count = 3
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0], 1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-consul}"]
    key_name = "ansible_key"
    tags = {
        Name = "project-consul${count.index}"
    }
}
