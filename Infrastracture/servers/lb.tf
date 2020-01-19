/* 
#Create ELB
resource "aws_elb" "lesson2hw-elb" {  
  name            = "lesson2hw-elb"  
  subnets         = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-pub1-id}", "${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-pub2-id}"]
  security_groups = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.security-group-pub}"]
    listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 15
  }

  instances                   = ["${aws_instance.lesson2hw-web0.id}", "${aws_instance.lesson2hw-web1.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {    
    Name    = "lesson2hw-elb"    
  }   
}

resource "aws_lb_cookie_stickiness_policy" "lesson2hw-elb-stickiness" {
  name                     = "lesson2hw-elb-stickiness"
  load_balancer            = "${aws_elb.lesson2hw-elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 60
}


resource "aws_elb" "lesson2hw-elbint" {  
  name            = "lesson2hw-elbint"  
  subnets         = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-int1-id}", "${data.terraform_remote_state.lesson3hw-vpc.outputs.subnet-int2-id}"]
  internal        = true
  security_groups = ["${data.terraform_remote_state.lesson3hw-vpc.outputs.security-group-pub}"]
    listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:22"
    interval            = 15
  }

  instances                   = ["${aws_instance.lesson2hw-db1.id}", "${aws_instance.lesson2hw-db2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {    
    Name    = "lesson2hw-elbint"    
  }   
} */