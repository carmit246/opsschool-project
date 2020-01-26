data "template_file" "inventory" {
    template = "${file("./templates/inventory.tpl")}"
    vars = {
      k8s-master-ip = "${aws_instance.project-k8s-master.private_ip}"
      k8s-worker-ip = "${join("\n", aws_instance.project-k8s-nodes.*.private_ip)}"
      jenkins-master-ip =  "${aws_instance.project-jenkins.public_ip}" #"${join("\n", aws_instance.project-slave.*.public_ip)}"
      jenkins-slave-ip =  "${aws_instance.project-slave.public_ip}" #"${join("\n", aws_instance.project-slave.*.public_ip)}"
      bastion-ip = "${aws_instance.project-bastion.public_ip}"
    }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "./hosts"
}