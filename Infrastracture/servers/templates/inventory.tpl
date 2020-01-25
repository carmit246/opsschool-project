[k8s-master]
master ansible_host=${k8s-master-ip}

[k8s-workers]
${k8s-worker-ip}

[k8s:children]
k8s-master
k8s-workers

[jenkins-slaves]
${jenkins-slave-ip}

[k8s:vars]
#ansible_ssh_common_args='ssh -o ProxyCommand="ssh -W %h:%p -q ubuntu@

[all:vars]
ansible_ssh_private_key_file=/home/carmit/Downloads/ansible.pem 
ansible_python_interpreter=/usr/bin/python3
ansible_user=ubuntu
