#!/usr/bin/env bash
set -e

apt-get update
apt-get install -y nvme-cli
sh ./prepare-volume.sh $1 $2 $3

wget https://pkg.jenkins.io/debian-stable/jenkins.io.key -O jenkins.io.key
apt-key add jenkins.io.key
echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y openjdk-8-jdk-headless
apt-get install -y jenkins
