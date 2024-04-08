# -*- mode: ruby -*-
# vi: set ft=ruby :

SERVER_NODE_COUNT = 2
AGENT_NODE_COUNT  = 2

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  config.vm.define "nginx-lb" do |lb|
    lb.vm.hostname = "lb"
    lb.vm.network "private_network", ip: "192.168.56.2"
    lb.vm.provision :shell, path: "scripts/lb.sh"
    lb.vm.provider "virtualbox" do |v|
      v.name = "lb"
      v.memory = 2048
      v.cpus = 4
    end
  end

  (1..SERVER_NODE_COUNT).each() do |i|
    config.vm.define "server-#{i}" do |server|
      server.vm.hostname = "server-#{i}"
      server.vm.network "private_network", ip: "192.168.56.1#{i}"
      server.vm.provision :shell, path: "scripts/server.sh"
      server.vm.provider "virtualbox" do |v|
        v.name = "server-#{i}"
        v.memory = 4096
        v.cpus = 4
      end
    end
  end

  (1..AGENT_NODE_COUNT).each() do |i|
    config.vm.define "agent-#{i}" do |agent|
      agent.vm.hostname = "agent-#{i}"
      agent.vm.network "private_network", ip: "192.168.56.2#{i}"
      agent.vm.provision :shell, path: "scripts/agent.sh"
      agent.vm.provider "virtualbox" do |v|
        v.name = "agent-#{i}"
        v.memory = 4096
        v.cpus = 4
      end
    end
  end
end
