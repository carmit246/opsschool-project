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
 


resource "aws_instance" "project-jenkins" {
    #count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0]}")
    #ami = "ami-024582e76075564db"
    ami = "ami-062b01a91f75b7ddd"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0],1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-jenkins-master}"]
    key_name = "ansible_key"
    iam_instance_profile = "${aws_iam_instance_profile.project-consul.name}"
    tags = {
        Name = "project-jenkins-master"
        consul_server = "true"
    }
}


resource "aws_instance" "project-slave" {
    #count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0]}")
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0],1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    tags = {
        Name = "project-jenkins-slave"
    }
}


resource "aws_instance" "project-k8s-master" {
    ami = "ami-04b9e92b5572fa0d1"
    #ami = "ami-069fa5f549baee43b"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0], 1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-k8s-master}"]
    key_name = "ansible_key"
    iam_instance_profile = "${aws_iam_instance_profile.project-k8s.name}"
    root_block_device {
      volume_size = 20
    }
    #user_data = "${file("scripts/k8s.sh")}"
    tags = {
        Name = "project-k8s-master"
        "kubernetes.io/cluster/kubernetes" = "kubernetes"
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
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0],count.index)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-k8s-node}"]
    key_name = "ansible_key"
    #user_data = "${file("scripts/k8s_node.sh")}"
    iam_instance_profile = "${aws_iam_instance_profile.project-k8s.name}"
    tags = {
        Name = "project-k8s-node${count.index}"
        "kubernetes.io/cluster/kubernetes" = "kubernetes"
    }
}

resource "aws_instance" "project-consul" {
    count = 3
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0], count.index)}"
    #subnet_id = "${lookup(data.terraform_remote_state.project-vpc.outputs.subnet-int-id-str, count.index % length(data.terraform_remote_state.project-vpc.outputs.subnet-int-id[0]))}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-consul}"]
    key_name = "ansible_key"
    iam_instance_profile = "${aws_iam_instance_profile.project-consul.name}"
    tags = {
        Name = "project-consul${count.index}"
        consul_server = "true"
    }
}