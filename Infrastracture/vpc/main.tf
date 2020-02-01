provider "aws" {
  region     = "${var.aws_region}"
}

#Crate VPC
resource "aws_vpc" "project-vpc" {
  cidr_block       = "${var.vpc_config.cidr_block}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_config.name}"
  }
}
#Create public subnets
resource "aws_subnet" "project-pub" {  
  count = "${var.num_public_subnets}"
  vpc_id = "${aws_vpc.project-vpc.id}"
  cidr_block              = "${var.public_subnets_cidrs[count.index]}"
  availability_zone       = "${var.project_zones[count.index]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "project-pub${count.index}"
    "kubernetes.io/cluster/kubernetes" = "kubernetes"
  }
}

#Create internal subnets
resource "aws_subnet" "project-int" {
  count = "${var.num_private_subnets}"
  vpc_id     = "${aws_vpc.project-vpc.id}"
  cidr_block = "${var.private_subnets_cidrs[count.index]}"
  availability_zone = "${var.project_zones[count.index]}"
  tags = {
    Name = "project-int${count.index}"
  }
}

#Create internet GW
resource "aws_internet_gateway" "project-igw" {
    vpc_id = "${aws_vpc.project-vpc.id}"
    
    tags = {
        Name = "project-igw"
        "kubernetes.io/cluster/kubernetes" = "kubernetes"
    }
}

#Create route table for external subnet
resource "aws_route_table" "project-rtpub" {
    vpc_id = "${aws_vpc.project-vpc.id}"
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = "${aws_internet_gateway.project-igw.id}" 
    }
    
    tags = {
        Name = "project-rtpub"
    }
}

#Create NAT
resource "aws_eip" "project-nat" {
  count = "${var.num_public_subnets}"
  #instance = "${aws_instance.project-nat[count.index].id}"
  vpc      = true
  tags = {
        Name = "project-nat${count.index}"
    }
}

resource "aws_nat_gateway" "project-nat" {
  count         = "${var.num_public_subnets}"
  subnet_id     = "${element(aws_subnet.project-pub.*.id, count.index)}"
  allocation_id = "${element(aws_eip.project-nat.*.id, count.index)}"
  tags = {
    Name = "project-nat${count.index}"
    "kubernetes.io/cluster/kubernetes" = "kubernetes"
  }
}

/* resource "aws_instance" "project-nat" {
    count = "${var.num_public_subnets}"
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    key_name = "ansible_key"
    vpc_security_group_ids = ["${aws_security_group.project-sg.id}"]
    subnet_id = "${aws_subnet.project-pub[count.index].id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "project-nat${count.index}"
    }
}
 */

#Create route table for internal subnet
resource "aws_route_table" "project-rtint" {
    count = "${var.num_private_subnets}"
    vpc_id = "${aws_vpc.project-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${element(aws_nat_gateway.project-nat.*.id,count.index)}"
        #instance_id = "${aws_instance.project-nat[count.index].id}"
    }
    tags = {
        Name = "project-rtint${count.index}"
        "kubernetes.io/cluster/kubernetes" = "kubernetes"
    }
}

#associate route table for internal subnet
resource "aws_route_table_association" "project-int" {
    count = "${length(aws_subnet.project-int.*.id)}"
    subnet_id = "${element(aws_subnet.project-int.*.id, count.index)}"
    route_table_id = "${aws_route_table.project-rtint[count.index].id}"
}

#Create security group
resource "aws_security_group" "project-sg" {
    vpc_id = "${aws_vpc.project-vpc.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 6443
        to_port = 6443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8
        to_port = 0
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "project-sg"
    }
}

resource "aws_security_group" "k8s-master" {
  name   = "k8s-master-security-group"
  vpc_id = "${aws_vpc.project-vpc.id}"

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
  tags = {
        Name = "project-k8s-master"
    }
}

resource "aws_security_group" "k8s-node" {
  name   = "k8s-node-security-group"
  vpc_id = "${aws_vpc.project-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 30036
    to_port     = 30036
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
        Name = "project-k8s-nodes"
    }
}

resource "aws_security_group" "consul" {
  name   = "consul-security-group"
  vpc_id = "${aws_vpc.project-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8500
    to_port     = 8500
    cidr_blocks = ["0.0.0.0/0"]
  }
    
  ingress {
    protocol    = "tcp"
    from_port   = 8300
    to_port     = 8300
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8301
    to_port     = 8301
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
        Name = "project-consul"
    }
}


resource "aws_security_group" "jenkins-master" {
  name   = "jenkins-master-security-group"
  vpc_id = "${aws_vpc.project-vpc.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8300
    to_port     = 8300
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8301
    to_port     = 8301
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
        Name = "project-jenkins"
    }
}

#associate route table for external subnet
resource "aws_route_table_association" "project-pub" {
    count = "${length(aws_subnet.project-pub.*.id)}"
    subnet_id = "${element(aws_subnet.project-pub.*.id, count.index)}"
    route_table_id = "${aws_route_table.project-rtpub.id}"
}
