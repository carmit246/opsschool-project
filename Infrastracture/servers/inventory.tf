data "template_file" "inventory" {
    template = "${file("./templates/inventory.tpl")}"
    vars = {
      k8s-master-ip = "${aws_instance.project-k8s-master.private_ip}"
      k8s-master-dns = "${aws_instance.project-k8s-master.private_dns}"
      #ttt = concat(["${aws_instance.project-k8s-nodes.*.private_dns}"][" workerip="]["${aws_instance.project-k8s-nodes.*.private_ip}"])
      #k8s-worker-ip = "${join("\n", aws_instance.project-k8s-nodes.*.private_ip)}"
      k8s-worker-dns1 = "${join("", ["${aws_instance.project-k8s-nodes.0.private_dns}", " workerip=", "${aws_instance.project-k8s-nodes.0.private_ip}"])}"
      k8s-worker-dns2 = "${join("", ["${aws_instance.project-k8s-nodes.1.private_dns}", " workerip=", "${aws_instance.project-k8s-nodes.1.private_ip}"])}"
      #k8s-worker-dns = "${join("\n", aws_instance.project-k8s-nodes.*.private_dns)}"
      jenkins-master-ip =  "${aws_instance.project-jenkins.public_ip}" #"${join("\n", aws_instance.project-slave.*.public_ip)}"
      jenkins-slave-ip =  "${aws_instance.project-slave.private_ip}" #"${join("\n", aws_instance.project-slave.*.public_ip)}"
      bastion-ip = "${aws_instance.project-bastion.public_ip}"
      consul-ip = "${join("\n", aws_instance.project-consul.*.private_ip)}"
    }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "./hosts"
}