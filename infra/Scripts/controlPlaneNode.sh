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

# Commands only to be run on control-plane node
echo "---------------------- Initializing cluster -------------------"
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "---------------------- Installing CNI plugin -------------------"
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "----------------Setting up kubectl alias and commandline auto complition---------" 

sudo apt update
sudo apt install bash-completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc
source ~/.bashrc

echo "================= Kubernetes Setup Completed ================="
date
