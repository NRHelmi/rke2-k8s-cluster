# !/bin/bash

common_tools() {
    apt update
    apt install -y tmux net-tools
}

install_rke2() {
    curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -
}

rke2_agent_config() {
    NODE_IP=$(hostname -I | awk '{print $2}')
    mkdir -p /etc/rancher/rke2/

    cat > /etc/rancher/rke2/config.yaml << EOF
server: https://192.168.56.2:9345
token:
#node-ip: $NODE_IP
node-external-ip: $NODE_IP
EOF

    # systemctl enable rke2-agent &
    # systemctl start rke2-agent &

    echo PATH=\$PATH:/var/lib/rancher/rke2/bin/ >> /home/vagrant/.bashrc
}

systemctl stop ufw
systemctl disable ufw

systemctl stop apparomor
systemctl disable apparmor

if !(command -v ifconfig); then
    common_tools
fi

if !(command -v rke2 --version); then
    install_rke2
fi

rke2_agent_config