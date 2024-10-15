# -*- mode: ruby -*-
# vi: set ft=ruby :

## configuration variables ##
# max number of worker nodes
N = 2 
# each of components to install 
k8s_V = '1.26.5'           # Kubernetes 
ctrd_V = '1.7.13'   # Containerd 
## /configuration variables ##

Vagrant.configure("2") do |config|

  #==============#
  # Worker Nodes #
  #==============#

  (1..N).each do |i|
    config.vm.define "worker#{i}-k8s-#{k8s_V[0..5]}" do |cfg|
      cfg.vm.box = "sysnet4admin/Ubuntu-k8s"
      cfg.vm.provider "virtualbox" do |vb|
        vb.name = "worker#{i}-k8s-#{k8s_V[0..5]}"
        vb.cpus = 2
        vb.memory = 2048
        vb.customize ["modifyvm", :id, "--groups", "/k8s-C#{k8s_V[0..5]}"]
      end
      cfg.vm.host_name = "worker#{i}-k8s"
      cfg.vm.network "private_network", ip: "192.168.1.10#{i}"
      cfg.vm.network "forwarded_port", guest: 22, host: "6010#{i}", auto_correct: true, id: "ssh"
      cfg.vm.synced_folder "../data", "/vagrant", disabled: true
      cfg.vm.provision "shell", path: "k8s_env_build.sh", args: N
    end
  end

  #=============#
  # Master Node #
  #=============#

    config.vm.define "control-k8s-#{k8s_V[0..5]}" do |cfg|
      cfg.vm.box = "sysnet4admin/Ubuntu-k8s"
      cfg.vm.provider "virtualbox" do |vb|
        vb.name = "control-k8s-#{k8s_V[0..5]}"
        vb.cpus = 4
        vb.memory = 4096
        vb.customize ["modifyvm", :id, "--groups", "/k8s-C#{k8s_V[0..5]}"]
      end
      cfg.vm.host_name = "control-k8s"
      cfg.vm.network "private_network", ip: "192.168.1.10"
      cfg.vm.network "forwarded_port", guest: 22, host: 60010, auto_correct: true, id: "ssh"
  cfg.vm.synced_folder "../data", "/vagrant", disabled: true
#      cfg.vm.synced_folder "../", "/vagrant"
      cfg.vm.provision "shell", path: "k8s_env_build.sh", args: N
      cfg.vm.provision "shell", path: "k8s_pkg_cfg.sh", args: [ k8s_V, ctrd_V ]
    end

end
