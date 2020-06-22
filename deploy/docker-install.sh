#!/bin/bash
yum -y install net-tools wget gcc yum-utils device-mapper-persistent-data lvm2 vim

yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-ce-cli containerd.io

systemctl enable docker

mkdir -p /etc/docker

cat > /etc/docker/daemon.json << EOF
{
        "registry-mirrors": [
            "http://registry.cnegroup.com",
            "https://ddxgxqwx.mirror.aliyuncs.com"
        ],
        "insecure-registries": [
            "registry.cnegroup.com"
        ],
        "exec-opts": [
            "native.cgroupdriver=systemd"
        ],
        "log-driver": "json-file",
        "log-opts": {
            "max-size": "100m"
        },
        "storage-driver": "overlay2"
}
EOF

sed -i 's/-H fd:\/\//-H fd:\/\/ -H tcp:\/\/0.0.0.0:2375/g' /usr/lib/systemd/system/docker.service

curl -L https://get.daocloud.io/docker/compose/releases/download/1.26.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

systemctl daemon-reload
systemctl start docker

systemctl disable firewalld && systemctl stop firewalld