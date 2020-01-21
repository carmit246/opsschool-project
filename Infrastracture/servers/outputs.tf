#output "bastion-ip" {
 # value = ["${aws_instance.project-k8s-nodes.*.pubic_ip}"]
#}

output "k8s-master-ip" {
  value = "${aws_instance.project-k8s-master.public_ip}"
}

output "k8s-worker-ip" {
  value = ["${aws_instance.project-k8s-nodes.*.public_ip}"]
}