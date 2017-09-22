#!/bin/bash
sudo yum -y install epel-release
# Deshabilitar temporalmente update debido al tiempo que necesita
# sudo yum -y update
sudo yum -y install ansible pyOpenSSL wget git net-tools bind-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
