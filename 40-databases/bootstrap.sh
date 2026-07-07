#!/bin/bash

component=$1 #mongodb
environment=$2 #dev
dnf install ansible -y
mkdir -p /var/log/roboshop/                                  #creating log directory 
chown -R ec2-user:ec2-user /var/log/roboshop
chmod -R 755 /var/log/roboshop
touch /var/log/roboshop/ansible.log

cd /home/ec2-user
git clone https://github.com/venkey27/roboshop-ansible-v3.git
cd roboshop-ansible-v3
git pull                                                                 # sometimes we update scripts so writing git pull is better 
ansible-playbook -e component=$component -e env=$environment roboshop.yaml # the variable component and environment comes from main.tf line 41
                                                                       # - sudo sh /tmp/bootstrap.sh mongodb ${var.environment}