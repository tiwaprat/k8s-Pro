#!/bin/bash

# Check if $1 (hostname) is provided, if not, prompt the user
if [ -z "$1" ]; then
  read -p "Enter the hostname: " hostname
else
  hostname=$1
fi

# Set the hostname
sudo hostnamectl hostname "$hostname"
echo "----------------------package update on $1-------------------" 
sudo apt update 
echo "----------------------configuring network --------------------"
sudo modprobe br_netfilter
sudo ls /proc/sys/net/bridge
sudo tee /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
EOF

sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
echo "----------------------package update on $1-------------------"
sudo apt update
echo "----------------------Installing containerd-------------------"
sudo apt install -y containerd
sudo mkdir -p /etc/containerd

containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
cat /etc/containerd/config.toml |grep -i SystemdCgroup -B 20
sudo systemctl restart containerd.service
sudo systemctl status  containerd.service
sudo systemctl enable   containerd.service
echo "----------------------package update on $1-------------------"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet
