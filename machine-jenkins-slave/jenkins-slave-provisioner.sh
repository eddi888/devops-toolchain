#!/usr/bin/env bash
set -e

# Docker
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
apt-get -y install docker.io
systemctl start docker
systemctl enable docker
docker --version

# Java
apt-get install -y openjdk-8-jdk-headless

# Maven
apt-get install -y maven

# Stop the Template after 15min
shutdown -h 15
