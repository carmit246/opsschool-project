#!/bin/bash

cd /home/carmit/Git-Repositories/Project/Infrastracture/initState
terraform apply -auto-approve
cd /home/carmit/Git-Repositories/Project/Infrastracture/vpc
terraform apply -auto-approve
cd /home/carmit/Git-Repositories/Project/Infrastracture/servers
terraform apply -auto-approve
ansible-playbook -i hosts /home/carmit/Git-Repositories/Project/Config/k8s-install.yml
ansible-playbook -i hosts /home/carmit/Git-Repositories/Project/Config/Jenkins-Slave-Install.yml
ansible-playbook -i hosts /home/carmit/Git-Repositories/Project/Config/consul/Consul-install-server.yml
ansible-playbook -i hosts /home/carmit/Git-Repositories/Project/Config/consul/Consul-install-agent.yml