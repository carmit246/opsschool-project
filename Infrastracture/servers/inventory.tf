data "template_file" "inventory" {
    template = "${file("./templates/inventory.tpl")}"
    vars = {
      k8s-master-ip = "${aws_instance.project-k8s-master.public_ip}"
      k8s-worker-ip = "${join("\n", aws_instance.project-k8s-nodes.*.public_ip)}"
    }
}

resource "local_file" "save_inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "./hosts"
}