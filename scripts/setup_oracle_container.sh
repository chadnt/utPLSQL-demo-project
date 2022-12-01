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