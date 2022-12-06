#! /bin/sh

# Make sure apt is up to date
apt update

# Add docker gpg key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index
apt update

# Install Docker Engine, containerd, and Docker Compose
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# WARNING break this script up. Need to mount data drive and configure docker to use it.

# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal
# Identify disk to mount
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

sudo parted /dev/sda --script mklabel gpt mkpart xfspart xfs 0% 100%
sudo mkfs.xfs /dev/sda1
sudo partprobe /dev/sda1

sudo mkdir /mnt/data

sudo mount /dev/sda1 /mnt/data

sudo blkid
# /dev/sda1: UUID="dd67b885-cc2a-4c72-b965-45ecff2547f2" TYPE="xfs" PARTLABEL="xfspart" PARTUUID="2d502536-0e5b-49f7-9c2c-aaaa7d13e033"

sudo nano /etc/fstab

# UUID=dd67b885-cc2a-4c72-b965-45ecff2547f2   /mnt/data   xfs   defaults,nofail   1   2

lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -i "sd"

# Configure docker to use data drive
mkdir /mnt/data/docker
nano /etc/docker/daemon.json

# edit daemon.json
{
  "data-root": "/mnt/data/docker"
}

# restart docker
sudo systemctl restart docker

# Login to container registry
docker login acrnbtmestest.azurecr.io

# Pull the oracle image
docker pull acrnbtmestest.azurecr.io/oracle-xe:21.0

# Start the container
docker run -d --name oracle-xe -p 1521:1521 acrnbtmestest.azurecr.io/oracle-xe:21.0

# Wait until database is up
docker logs -f oracle-xe | grep -m 1 "DATABASE IS READY TO USE!" --line-buffered

# Set the sys password
docker exec oracle-xe ./setPassword.sh nucor

# Do it for a container named PSI
docker run -d --name psi -p 11521:1521 acrnbtmestest.azurecr.io/oracle-xe:21.0
docker exec psi ./setPassword.sh nucor