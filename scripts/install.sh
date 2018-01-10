#!/bin/bash
set -e

NODE_COUNT=$1
ADMIN_USER=$2
MASTER_DOMAIN=$3

if [ ! -d "terraform-azure-openshift" ]; then
    echo "Cloning terraform-azure-openshift Github repo..."
    git clone https://github.com/alejandronb/terraform-azure-openshift.git
fi

cd terraform-azure-openshift
git pull

chmod 600 certs/*
cp -f certs/openshift.key ansible/openshift.key
cp -f templates/host-preparation-inventory ansible/inventory/hosts
# This line is testing
cp -f templates/azure_rm.* ansible/inventory/

NODE_MAX_INDEX=$((NODE_COUNT-1))
sed -i "s/###NODE_COUNT###/$NODE_MAX_INDEX/g" ansible/inventory/hosts
sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" ansible/inventory/hosts

cd ansible
# This is working
ansible-playbook -i inventory/hosts host-preparation.yml
# Testing dynamic inventory
#ansible-playbook -i inventory/ host-preparation.yml

cd ../..

if [ ! -d "openshift-ansible" ]; then
    echo "Cloning openshift-ansible Github repo..."
    git clone https://github.com/openshift/openshift-ansible.git
fi

cd openshift-ansible
git pull
git checkout release-3.7
cp -f ../terraform-azure-openshift/certs/openshift.key openshift.key
#mkdir -p inventory/dinventory
# This line is working
#cp -f ../terraform-azure-openshift/templates/openshift-inventory inventory/openshift-inventory
#This line is testing
cp -f ../openshift-inventory inventory/openshift-inventory

# This line is testing
#cp -f ../terraform-azure-openshift/templates/openshift-inventory inventory/dinventory/openshift-inventory

# This line is testing
#cp -f ../terraform-azure-openshift/templates/azure_rm.* inventory/dinventory/

#INDEX=0
#while [ $INDEX -lt $NODE_COUNT ]; do
#  printf "node$INDEX openshift_hostname=node$INDEX openshift_node_labels=\"{'role':'app','zone':'default','logging':'true'}\"\n" >> inventory/dinventory/openshift-inventory
#  let INDEX=INDEX+1
#done

sed -i "s/###ADMIN_USER###/$ADMIN_USER/g" inventory/openshift-inventory
sed -i "s/###MASTER_DOMAIN###/$MASTER_DOMAIN/g" inventory/openshift-inventory
# This line works
ansible-playbook --private-key=openshift.key -i inventory/openshift-inventory playbooks/byo/config.yml
# This is testing
#ansible-playbook --private-key=openshift.key -i inventory/dinventory/ playbooks/byo/config.yml

cd ..

rm install.sh
