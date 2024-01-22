#!/bin/bash

set -e

# Prompt user to set hostname within 10 seconds
read -t 10 -p "Set hostname if not canceled in 10 seconds. Press Enter to continue or Ctrl+C to cancel..." || exit 1

# Update the package manager
sudo yum update -y

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules for containerd
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay br_netfilter

# Configure sysctl settings for Kubernetes
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Install required packages
sudo yum install -y curl gnupg2 yum-utils device-mapper-persistent-data lvm2

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/centos/gpg | sudo gpg --dearmour -o /etc/pki/rpm-gpg/docker.gpg
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure containerd
sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

# Start and enable containerd
sudo systemctl start containerd
sudo systemctl enable containerd

# Set SELinux in permissive mode
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Add Kubernetes GPG key and repository
sudo rpm --import https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
sudo rpm --import https://packages.cloud.google.com/yum/doc/yum-key.gpg

sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.27/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.27/rpm/repodata/repomd.xml.key
EOF

# Install Kubernetes components

# Install CNI Plugins
CNI_PLUGINS_VERSION="v1.3.0"
ARCH="amd64"
DEST="/opt/cni/bin"
sudo mkdir -p "$DEST"
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C "$DEST" -xz

# Install crictl
CRICTL_VERSION="v1.27.0"
DOWNLOAD_DIR="/usr/local/bin"
sudo mkdir -p "$DOWNLOAD_DIR"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz

# Install kubectl
RELEASE="v1.27.0"
cd $DOWNLOAD_DIR
sudo rm -rf kubeadm kubelet
sudo curl -L --remote-name-all https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/{kubeadm,kubelet}
sudo chmod +x {kubeadm,kubelet}

# Configure kubelet service
RELEASE_VERSION="v0.15.1"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubelet/lib/systemd/system/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/kubepkg/templates/latest/deb/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Install kubectl separately
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl

echo $PWD
# Add the script directory to PATH in ~/.bashrc
touch /tmp/kube.sh
sudo grep -qxF "export PATH=\$PATH:$(pwd)" /tmp/kube.sh || sudo echo "export PATH=\$PATH:$(pwd)" >> /tmp/kube.sh
sudo cp -pr /tmp/kube.sh /etc/profile.d/kube.sh
sudo rm /tmp/kube.sh
#sudo cat >> /etc/profile.d/kube.sh <<EOF
#  PATH=$PATH:$DOWNLOAD_DIR
#EOF

# Start and enable kubelet
sudo systemctl enable --now kubelet

# Prevent automatic updates of Kubernetes components
#sudo yum install -y yum-plugin-versionlock
#sudo yum versionlock add kubelet kubeadm kubectl kubernetes-cni
