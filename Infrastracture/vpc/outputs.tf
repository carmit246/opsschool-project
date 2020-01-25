output "vpc-id" {
  value = "${aws_vpc.project-vpc.id}"
}

output "subnet-pub-id" {
  value = ["${aws_subnet.project-pub.*.id}"]
}

output "subnet-int-id" {
  value = ["${aws_subnet.project-int.*.id}"]
}

output "security-group-pub" {
  value = "${aws_security_group.project-sg.id}"
}

output "security-group-consul" {
  value = "${aws_security_group.consul.id}"
}

output "security-group-k8s-master" {
  value = "${aws_security_group.k8s-master.id}"
}

output "security-group-k8s-node" {
  value = "${aws_security_group.k8s-node.id}"
}