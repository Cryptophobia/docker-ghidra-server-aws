#!/usr/bin/env bash
set -euo pipefail

apt-get update -y
apt-get upgrade -y

apt-get install -y docker.io
systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu
sg docker -c "bash"

mkdir -p /home/ubuntu/repos

docker build . -t cs6747/ghidra-server:10.1.2
