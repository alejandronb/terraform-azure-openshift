# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
nodes
masters

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=###ADMIN_USER###

# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true

openshift_deployment_type=origin
openshift_disable_check=disk_availability,memory_availability
#openshift_master_default_subdomain=###MASTER_DOMAIN###
openshift_use_dnsmasq=true
openshift_override_hostname_check=true


# uncomment the following to enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
#openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]


# host group for masters
[masters]
${master_hosts} openshift_public_hostname=###MASTER_DOMAIN###

# host group for etcd
[etcd]
${master_hosts}

[app]
${app_hosts} openshift_hostname=${app_hosts}

[infra]
${infra_hosts} openshift_hostname=${infra_hosts}

# host group for nodes, includes region info
[nodes:children]
app
infra
masters

[app:vars]
openshift_node_labels="{'region': 'primary', 'zone': 'default'}"

[infra:vars]
openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
