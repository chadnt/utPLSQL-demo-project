#! /bin/sh

# Download and extract
mkdir demo-agent && cd demo-agent 
curl https://vstsagentpackage.azureedge.net/agent/2.213.2/vsts-agent-linux-x64-2.213.2.tar.gz |
    tar zxv

# Configure
./config.sh

# Install service
sudo ./svc.sh install
sudo ./svc.sh start
