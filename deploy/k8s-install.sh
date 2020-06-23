#!/bin/bash
swapoff -a
cp /etc/fstab /etc/fstab.bak && cat /etc/fstab.bak | grep -v swap > /etc/fstab

cat >> /etc/hosts <<EOF
192.168.2.100 k8s-master
192.168.2.101 k8s-node1
192.168.2.102 k8s-node2
192.168.2.30 registry.cnegroup.com
EOF

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

yum install vim net-tools gcc -y

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

yum install -y --nogpgcheck kubelet kubeadm kubectl

systemctl enable kubelet && systemctl start kubelet