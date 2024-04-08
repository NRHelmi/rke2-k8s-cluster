#! /bin/bash

common_tools() {
    apt update
    apt install -y tmux net-tools
}

install_rke2() {
    curl -sfL https://get.rke2.io | sh -
}

rke2_server_config() {
    mkdir -p /etc/rancher/rke2/

    NODE_IP="$(hostname -I | awk '{print $2}')"

    if [ $NODE_IP = "192.168.56.11" ]; then
        cat > /etc/rancher/rke2/config.yaml << EOF
write-kubeconfig-mode: "0644"
tls-san:
  - 192.168.56.2
  - 192.168.56.11
  - 192.168.56.12
  - 192.168.56.13
# node-taint:
#   - "CriticalAddonsOnly=true:NoExecute"
etcd-expose-metrics: true
cni:
  - canal
#node-ip: $NODE_IP
node-external-ip: $NODE_IP
bind-address: $NODE_IP
advertise-address: 192.168.56.2
EOF
    else
        cat > /etc/rancher/rke2/config.yaml << EOF
write-kubeconfig-mode: "0644"
server: https://192.168.56.2:9345
token:
tls-san:
  - 192.168.56.2
  - 192.168.56.11
  - 192.168.56.12
  - 192.168.56.13

#node-ip: $NODE_IP
node-external-ip: $NODE_IP
bind-address: $NODE_IP
advertise-address: 192.168.56.2
EOF
    fi

    # systemctl enable rke2-server
    # systemctl start rke2-server
}

systemctl stop ufw
systemctl disable ufw

systemctl stop apparomor
systemctl disable apparmor

setup_kubectl_config() {
    mkdir -p /home/vagrant/.kube
    cp /etc/rancher/rke2/rke2.yaml /home/vagrant/.kube/config
    chown vagrant:vagrant /home/vagrant/.kube/config

    echo PATH=\$PATH:/var/lib/rancher/rke2/bin/ >> /home/vagrant/.bashrc
}

if !(command -v ifconfig); then
    common_tools
fi

if !(command -v rke2 --version); then
    install_rke2
fi

rke2_server_config

# if !(command -v kubectl --version); then
#     setup_kubectl_config
# fi
