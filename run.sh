#!/bin/bash

cd /home/carmit/Git-Repositories/Project/Infrastracture/initState
terraform apply -auto-approve
cd /home/carmit/Git-Repositories/Project/Infrastracture/vpc
terraform apply -auto-approve
cd /home/carmit/Git-Repositories/Project/Infrastracture/servers
terraform apply -auto-approve
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i hosts /home/carmit/Git-Repositories/Project/Config/k8s-install.yml