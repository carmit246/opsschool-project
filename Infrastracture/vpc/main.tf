provider "aws" {
  region     = "${var.aws_region}"
}

#Crate VPC
resource "aws_vpc" "project-vpc" {
  cidr_block       = "${var.vpc_config.cidr_block}"
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
resource "aws_instance" "project-nat" {
    count = "${var.num_public_subnets}"
    ami = "ami-024582e76075564db"
    instance_type = "t2.micro"
    key_name = "test1"
    vpc_security_group_ids = ["${aws_security_group.project-sg.id}"]
    subnet_id = "${aws_subnet.project-pub[count.index].id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "project-nat${count.index}"
    }
}

resource "aws_eip" "project-nat" {
  count = "${var.num_public_subnets}"
  instance = "${aws_instance.project-nat[count.index].id}"
  vpc      = true
  tags = {
        Name = "project-nat${count.index}"
    }
}

#Create route table for internal subnet
resource "aws_route_table" "project-rtint" {
    count = "${var.num_private_subnets}"
    vpc_id = "${aws_vpc.project-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.project-nat[count.index].id}"
    }
    tags = {
        Name = "project-rtint${count.index}"
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
        Name = "project-ssh-allowed"
    }
}


#associate route table for external subnet
resource "aws_route_table_association" "project-pub" {
    count = "${length(aws_subnet.project-pub.*.id)}"
    subnet_id = "${element(aws_subnet.project-pub.*.id, count.index)}"
    route_table_id = "${aws_route_table.project-rtpub.id}"
}
