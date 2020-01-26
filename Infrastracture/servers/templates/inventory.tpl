[k8s-master]
master ansible_host=${k8s-master-ip}

[k8s-workers]
${k8s-worker-ip}

[k8s:children]
k8s-master
k8s-workers

[bastion]
${bastion-ip}

[jenkins-master]
${jenkins-master-ip}

[jenkins-slaves]
${jenkins-slave-ip}

[k8s:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -i /home/carmit/Downloads/ansible.pem ubuntu@${bastion-ip}"'

[jenkins-slaves:vars]
jenkins_master_ip=${jenkins-master-ip}

[all:vars]
ansible_ssh_private_key_file=/home/carmit/Downloads/ansible.pem 
ansible_python_interpreter=/usr/bin/python3
ansible_user=ubuntu
