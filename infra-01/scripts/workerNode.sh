#!/bin/bash

LOGFILE="install.log"

# Check if $1 (Version) is provided, if not, prompt the user
if [ -z "$1" ]; then
  read -p "Enter the version like v1.31 : " version
else
  version=$1
fi

# Redirect all output (stdout + stderr) to logfile + console
exec > >(tee -a "$LOGFILE") 2>&1

echo "================= Kubernetes Setup Started ================="
date

# Set the hostname (optional, uncomment if needed)
# sudo hostnamectl hostname "$hostname"

echo "---------------------- Package update -------------------" 
sudo apt update 

echo "---------------------- Configuring network --------------------"
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

echo "---------------------- updating package -------------------"
sudo apt update

echo "---------------------- Installing containerd runtime-------------------"
sudo apt install -y containerd
sudo mkdir -p /etc/containerd

containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
cat /etc/containerd/config.toml | grep -i SystemdCgroup -B 20
sudo systemctl restart containerd.service
sudo systemctl status containerd.service
sudo systemctl enable containerd.service

echo "---------------------- Setting up Kubernetes repository -------------------"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/$version/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$version/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet


