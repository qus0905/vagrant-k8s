#!/usr/bin/env bash

# switch user
sudo su -

# setting passwd 
echo "root:oscadmin" | sudo chpasswd

# swapoff -a to disable swapping
swapoff -a
# sed to comment the swap partition in /etc/fstab
sed -i.bak -r 's/(.+ swap .+)/#\1/' /etc/fstab

# config hosts
echo "192.168.1.10 control-k8s" >> /etc/hosts
for (( i=1; i<=$1; i++  )); do echo "192.168.1.10$i worker$i-k8s" >> /etc/hosts; done

# config DNS  
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# sshd config setting 
sed -i -e '15s:^#::' /etc/ssh/sshd_config
sed -i -e '39s:^#::' /etc/ssh/sshd_config
systemctl start sshd.service