#!/bin/bash

set -x

# For Node
curl -sL https://rpm.nodesource.com/setup_10.x | sudo -E bash -

# For xmlstarlet
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo yum update -y

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.16.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator

chmod +x ./aws-iam-authenticator

mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH

echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

sleep 10

# Setting up Docker
sudo yum install -y docker
sudo usermod -a -G docker ec2-user

# Just to be safe removing previously available java if present
sudo yum remove -y java

sudo yum install -y python2-pip jq unzip vim tree biosdevname nc mariadb bind-utils at screen tmux xmlstarlet git java-1.8.0-openjdk-devel nc gcc-c++ make nodejs

sudo -H pip install awscli bcrypt
sudo -H pip install --upgrade awscli --user
sudo -H pip install --upgrade aws-ec2-assign-elastic-ip

sudo aws --version
sudo aws configure set aws_access_key_id aws_access_key_id
sudo aws configure set aws_secret_access_key aws_access_key_id
sudo aws configure set default.region us-east-1

sudo npm install -g @angular/cli
# ZABBIX agent
sudo rpm -ivh http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
sudo yum install zabbix-agent
sudo systemctl start zabbix-agent
sudo zabbix_agentd -V

# ELK Filebeat  agent
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.0-x86_64.rpm
sudo rpm -vi filebeat-7.5.0-x86_64.rpm

#DATADOG AGENT
DD_API_KEY=f11339098d300e24ab22df26bc5e2698 bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"

#PAGERDUTY AGENT

sudo sh -c 'cat >/etc/yum.repos.d/pdagent.repo <<EOF
[pdagent]
name=PDAgent
baseurl=https://packages.pagerduty.com/pdagent/rpm
enabled=1
gpgcheck=1
gpgkey=https://packages.pagerduty.com/GPG-KEY-RPM-pagerduty
EOF'

sudo yum install pdagent pdagent-integrations -y
sudo yum update pdagent pdagent-integrations


sudo systemctl enable docker
sudo systemctl enable atd

sudo yum clean all
sudo rm -rf /var/cache/yum/
exit 0