#!/bin/bash

cd /home/carmit/Git-Repositories/Project/Infrastracture/servers
terraform destroy -auto-approve

cd /home/carmit/Git-Repositories/Project/Infrastracture/vpc
terraform destroy -auto-approve

cd /home/carmit/Git-Repositories/Project/Infrastracture/initState
terraform destroy -auto-approve