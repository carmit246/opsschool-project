#!/bin/bash

cd /home/carmit/Git-Repositories/Project/Infrastracture/initState
terraform apply -auto-approve
cd /home/carmit/Git-Repositories/Project/Infrastracture/vpc
terraform apply -auto-approve
cd /home/carmit/Git-Repositories/Project/Infrastracture/servers
terraform apply -auto-approve