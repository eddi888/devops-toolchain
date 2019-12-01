#!/usr/bin/env bash
set -xe

if [ -z "$1" ];
  then
    echo "Error: 1. parameter is missing"
    exit 1;
  else
    DOMAIN=$1;
  fi

if [ -z "$2" ];
  then
    echo "Error: 2. parameter is missing"
    exit 1;
  else
    EMAIL=$2;
  fi

echo "DOMAIN=$DOMAIN"
echo "EMAIL=$EMAIL"

# INSTALL APACHE2 AND REQUIRED MODS
apt-get update
apt-get upgrade -y
apt-get install apache2 -y
a2enmod proxy
a2enmod proxy_http
a2enmod rewrite 
a2enmod ssl
a2enmod headers

# REVERSE PROXY CONFIGURATION
cp index.html /var/www/html/index.html
mkdir -p /var/www/html/error
cp custom_503.html /var/www/html/error/custom_503.html
if [ ! -d /etc/letsencrypt ]; 
  then
    mkdir -p /etc/letsencrypt/
  fi
cp options-ssl-apache.conf /etc/letsencrypt/options-ssl-apache.conf
sed -i s/"___DOMAIN___"/"$DOMAIN"/g 020-nexus.conf
cp 020-nexus.conf /etc/apache2/sites-enabled/020-nexus.conf
sed -i s/"___DOMAIN___"/"$DOMAIN"/g 030-jenkins.conf
cp 030-jenkins.conf /etc/apache2/sites-enabled/030-jenkins.conf

# STOP APACHE2 - certbot is running on port 80 temporarily for validate domain
service apache2 stop
echo "Wait for apache2 stop"
while : ; do
  printf "."
  sleep 1
  [[ $(ps aux | grep [a]pache2 | wc -l) -le 1 ]] && break
done
echo "stopped"

# CERTBOT SSL
add-apt-repository ppa:certbot/certbot -y
apt install python-certbot-apache -y
if [ -d /etc/letsencrypt/live/nexus.$DOMAIN ]; 
  then
    echo "ssl for nexus.$DOMAIN already configured"
  else
    certbot certonly --standalone -n --email $EMAIL --agree-tos --preferred-challenges http -d nexus.$DOMAIN
  fi

if [ -d /etc/letsencrypt/live/nexus.$DOMAIN ]; 
  then
    echo "ssl for jenkins.$DOMAIN already configured"
  else
    certbot certonly --standalone -n --email $EMAIL --agree-tos --preferred-challenges http -d jenkins.$DOMAIN  
  fi

# RENEW CRONJOB SCRIPT
crontab cron

# Start APACHE2
service apache2 start
