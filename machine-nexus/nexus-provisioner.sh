#!/usr/bin/env bash
set -e

apt-get update
apt-get upgrade -y
apt-get install -y nvme-cli
apt-get install -y openjdk-8-jdk-headless
sh ./prepare-volume.sh $1 $2 $3

wget https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.19.1-01-unix.tar.gz

echo "CHECK: NEXUS-SERVER UNPACKED ON STORAGE?"
if [ -d /storage/nexus ]; 
  then
    echo "OK: NEXUS-SERVER UNPACKED ALREADY"
  else
    echo "NO: PACKING NEXUS TO STORAGE..."
	tar xfz nexus-3.19.1-01-unix.tar.gz -C /storage
	ln -s /storage/nexus-3.19.1-01 /storage/nexus
  fi

echo "CHECK: Check Service existing?"
if [ -f /etc/init.d/nexus ]; 
  then
    echo "OK: INIT AND START-SCRIPT FOR NEXUS EXIST ALREADY"
  else
    echo "NO: CREATE INIT AND START-SCRIPT FOR NEXUS..."
	ln -s /storage/nexus/bin/nexus /etc/init.d/nexus
	sudo useradd nexus --uid=2000 --home=/storage
	echo "run_as_user=\"nexus\"" | tee /storage/nexus/bin/nexus.rc
    chown nexus:nexus /storage/nexus -R
	chown nexus:nexus /storage/sonatype-work -R
	chown nexus:nexus /storage/nexus-3.19.1-01 -R
	chown nexus:nexus /etc/init.d/nexus
	cd /etc/init.d && update-rc.d nexus defaults
	cp /home/ubuntu/nexus.service /etc/systemd/system/nexus.service
	systemctl daemon-reload
	systemctl enable nexus.service
	systemctl start nexus.service
  fi

