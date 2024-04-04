#!/bin/bash
# Script to setup K3s on Ubuntu

# Disable ubuntu firewall
sudo ufw disable

# Install k3s for the master
curl -sfL https://get.k3s.io | sh -

# Download the binary for kubectl for linux on x86 architecture
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Make kubectl understand that it has to listen to the k3s config file
echo "sudo chmod 604 /etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc

# Reload the bashrc to apply the changes immediately
source ~/.bashrc

# Capture the value of the command into a variable
node_token=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Print instructions for joining nodes to the cluster
echo "BE CAREFUL ABOUT THE IP ADDRESS USED. YOU HAVE TO USE THE IP ADDRESS OF THE MASTER NODE"
echo "curl -sfL https://get.k3s.io | K3S_URL=https://<MASTER_IP>:6443 K3S_TOKEN=$node_token sh"
