/*
#Create ELB
resource "aws_elb" "opsschool-project-elb" {  
  name            = "opsschool-project-elb"  
  subnets         = ["${data.terraform_remote_state.project-vpc.outputs.subnet-pub-id}"]
  security_groups = ["${data.terraform_remote_state.project-vpc.outputs.security-group-pub}"]
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
    target              = "TCP:30036"
    interval            = 15
  }

  instances                   = ["${aws_instance.project-k8s-nodes.*.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {    
    Name    = "opsschool-project-elb"    
  }   
}

resource "aws_lb_cookie_stickiness_policy" "opsschool-project-elb-stickiness" {
  name                     = "opsschool-project-elb-stickiness"
  load_balancer            = "${aws_elb.opsschool-project-elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 60
}
 */