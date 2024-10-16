#!/usr/bin/env bash

# install util packages 
apt update
apt install -y sshpass
apt install -y git python3-venv python3-pip

# ssh key create 
ssh-keygen -N "" -f /root/.ssh/id_rsa

# ssh key copy 
sshpass -p oscadmin ssh-copy-id -f -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no control-k8s
sshpass -p oscadmin ssh-copy-id -f -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no worker1-k8s
sshpass -p oscadmin ssh-copy-id -f -i /root/.ssh/id_rsa.pub -o StrictHostKeyChecking=no worker2-k8s

# git clone
mkdir -p /opt/kubespray-2.22-git
cd /opt/kubespray-2.22-git/
git clone https://github.com/kubernetes-sigs/kubespray.git -b release-2.22

# make python3 venv
python3 -m venv /opt/kubespray-2.22-venv

# activate venv
source /opt/kubespray-2.22-venv/bin/activate

# install pip & requirements
cd /opt/kubespray-2.22-git/kubespray/
pip3 install -U pip
pip3 install -r requirements.txt

# copy inventory 
mkdir /opt/kubespray-2.22-git/kubespray/inventory/hansem
cp -r /opt/kubespray-2.22-git/kubespray/inventory/sample/* /opt/kubespray-2.22-git/kubespray/inventory/hansem/

# write inventory.ini
cat > /opt/kubespray-2.22-git/kubespray/inventory/hansem/inventory.ini << EOF
[all]
control-k8s ip=192.168.1.10 ansible_host=control-k8s

worker1-k8s ip=192.168.1.101 ansible_host=worker1-k8s
worker2-k8s ip=192.168.1.102 ansible_host=worker2-k8s

[kube_control_plane]
control-k8s

[etcd]
control-k8s

[kube_node]
worker1-k8s
worker2-k8s

[calico_rr]

[k8s_cluster:children]
kube_control_plane
kube_node
calico_rr


[all:vars]
ansible_user=root
ansible_ssh_private_key_file='/root/.ssh/id_rsa'
ansible_become=True
ansible_become_user=root
ansible_become_pass=oscadmin
ansible_connection=ssh
ansible_port=22
EOF

# kubernetes version 
sed -i 's/^kube_version: v1.26.11/kube_version: v1.26.5/g' /opt/kubespray-2.22-git/kubespray/inventory/hansem/group_vars/k8s_cluster/k8s-cluster.yml

# config addons 
sed -i 's/^metrics_server_enabled: false/metrics_server_enabled: true/g' /opt/kubespray-2.22-git/kubespray/inventory/hansem/group_vars/k8s_cluster/addons.yml
sed -i 's/^ingress_nginx_enabled: false/ingress_nginx_enabled: true/g' /opt/kubespray-2.22-git/kubespray/inventory/hansem/group_vars/k8s_cluster/addons.yml
sed -i 's/^enable_nodelocaldns: true/enable_nodelocaldns: false/g' /opt/kubespray-2.22-git/kubespray/inventory/hansem/group_vars/k8s_cluster/k8s-cluster.yml

# ping test
ansible -m ping -i /opt/kubespray-2.22-git/kubespray/inventory/hansem/inventory.ini all -f 1

# create cluster
ansible-playbook -i /opt/kubespray-2.22-git/kubespray/inventory/hansem/inventory.ini cluster.yml

# install bash-completion for kubectl 
apt install -y bash-completion 

# kubectl completion on bash-completion dir
kubectl completion bash >/etc/bash_completion.d/kubectl
