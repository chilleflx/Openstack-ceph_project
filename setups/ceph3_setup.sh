#! /bin/sh

sudo cp /vagrant/network_config/90-custom.yaml /etc/netplan/60-custom.yaml
sudo chmod 600 /etc/netplan/60-custom.yaml
sudo cp /vagrant/network_config/99-disable-network-config.cfg /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo netplan generate
sudo netplan apply
sudo cp /vagrant/network_config/hosts /etc/hosts
sudo cp /vagrant/network_config/grub /etc/default/grub

sudo update-grub
sudo timedatectl set-timezone Africa/Casablanca

sudo apt update -y
sudo apt upgrade -y

sudo apt-get install -y ca-certificates curl

# Create the directory for Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package list again to include the Docker repository
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl restart docker
sudo systemctl enable docker

reboot