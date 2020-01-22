[k8s-master]
master ansible_host=${k8s-master-ip}

[k8s-workers]
${k8s-worker-ip}

[all:vars]
ansible_ssh_private_key_file=/home/carmit/Downloads/ansible.pem 
ansible_python_interpreter=/usr/bin/python3
ansible_user=ubuntu