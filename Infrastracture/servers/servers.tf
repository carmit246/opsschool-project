data "terraform_remote_state" "project-vpc" {
  backend = "s3"

  config = {
    bucket = "project-terraform-remote-state-storage-s3"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

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

  
#Create EC2 Web Instances
resource "aws_instance" "project-bastion" {
    count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0]}")
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0],count.index)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    #iam_instance_profile = "${aws_iam_instance_profile.lesson3hw_profile.name}"
    tags = {
        Name = "project-bastion${count.index}"
    }
}



resource "aws_security_group" "k8s-master" {
  name   = "k8s-master-security-group"
  vpc_id = "${data.terraform_remote_state.project-vpc.outputs.vpc-id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "project-k8s-master" {
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0], 1)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    #iam_instance_profile = "${aws_iam_instance_profile.lesson3hw_profile.name}"
    user_data = "${file("scripts/k8s.sh")}"
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
    count = length("${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0]}")
    ami = "ami-04b9e92b5572fa0d1"
    instance_type = "t2.micro"
    subnet_id = "${element(data.terraform_remote_state.project-vpc.outputs.subnet-pub-id[0],count.index)}"
    vpc_security_group_ids = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
    key_name = "ansible_key"
    user_data = "${file("scripts/k8s_node.sh")}"
    #iam_instance_profile = "${aws_iam_instance_profile.lesson3hw_profile.name}"
    tags = {
        Name = "project-k8s-node${count.index}"
    }
}

  /* provisioner "remote-exec" {       
	
	inline = [
  "sudo mkdir /home/ubuntu/.aws",
	"sudo apt -y update",
	"sudo apt install -y nginx",
	"sudo echo lesson2hw-web0 | sudo tee /var/www/html/index.nginx-debian.html",
	"sudo service nginx start",
  "sudo apt -y update",
  "sudo apt install -y awscli",
  "sudo apt install -y python3-pip",
  "pip3 install --upgrade --user awscli",
  "echo aws s3 cp /var/log/nginx/access.log s3://lesson3hw-nginx-logs-s3-web0/ > /home/ubuntu/accesslogs3.sh",
  "sudo chmod +x /home/ubuntu/accesslogs3.sh",
  "sudo touch /var/spool/cron/ubuntu",
  "sudo /usr/bin/crontab /var/spool/cron/ubuntu",
  "echo '0 * * * * /home/ubuntu/accesslogs3.sh'  | sudo tee -a /var/spool/cron/ubuntu"
	]	
         } */

  #provisioner "file" {
   # source      = "C:\Users\Carmit\.aws\credentials"
    #destination = "/home/ubuntu/.aws/credentials"
  #}

  #provisioner "file" {
   # source      = "C:\Users\Carmit\.aws\config"
    #destination = "/home/ubuntu/.aws/config"
  #}
#}


/* 

resource "aws_instance" "lesson2hw-web1" {
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-pub2-id}"
    vpc_security_group_ids = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.security-group-pub}"]
    key_name = "terraform"
    iam_instance_profile = "${aws_iam_instance_profile.lesson3hw_profile.name}"
    tags = {
        Name = "lesson2hw-web1"
    }

    
    connection {
    	type = "ssh"
    	host = self.public_ip
	user = "ubuntu"
	private_key = "${file("D:\\opschool\\terraform.pem")}"
  }
  
  provisioner "remote-exec" {       
	
	inline = [
  "sudo mkdir /home/ubuntu/.aws",
	"sudo apt -y update",
	"sudo apt install -y nginx",
	"sudo echo lesson2hw-web1 | sudo tee /var/www/html/index.nginx-debian.html",
  "echo 'set_real_ip_from 0.0.0.0/0; real_ip_header X-Forwarded-For;' | sudo tee /etc/nginx/conf.d/custom.conf",
	"sudo service nginx start",
  "sudo apt -y update",
  "sudo apt install -y awscli",
  "sudo apt install -y python3-pip",
  "pip3 install --upgrade --user awscli",
  "echo aws s3 cp /var/log/nginx/access.log s3://lesson3hw-nginx-logs-s3-web1/ > /home/ubuntu/accesslogs3.sh",
  "sudo chmod +x /home/ubuntu/accesslogs3.sh",
  "sudo touch /var/spool/cron/ubuntu",
  "sudo /usr/bin/crontab /var/spool/cron/ubuntu",
  "echo '0 * * * * /home/ubuntu/accesslogs3.sh'  | sudo tee -a /var/spool/cron/ubuntu"
	]	
         }

  #provisioner "file" {
    #source      = "C:\\Users\\Carmit\\.aws\\credentials"
    #destination = "/home/ubuntu/.aws/credentials"
  #}

  #provisioner "file" {
    #source      = "C:\\Users\\Carmit\\.aws\\config"
    #destination = "/home/ubuntu/.aws/config"
  #}
}


#Create EC2 DB Instances
resource "aws_instance" "lesson2hw-db1" {
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-int1-id}"
    vpc_security_group_ids = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.security-group-pub}"]
    key_name = "terraform"
     tags = {
        Name = "lesson2hw-db1"
    }
}
resource "aws_instance" "lesson2hw-db2" {
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    subnet_id = "${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-int2-id}"
    vpc_security_group_ids = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.security-group-pub}"]
    key_name = "terraform"
     tags = {
        Name = "lesson2hw-db2"
    }
}

resource "aws_s3_bucket_object" "dist" {
  for_each = fileset("/home/pawan/Documents/Projects/", "*")

  bucket = "lesson3hw-terraform-remote-state-storage-s3"
  key    = each.value
  source = "/home/pawan/Documents/Projects/${each.value}"
  # etag makes the file update when it changes; see https://stackoverflow.com/questions/56107258/terraform-upload-file-to-s3-on-every-apply
  etag   = filemd5("/home/pawan/Documents/Projects/${each.value}")
} */ 