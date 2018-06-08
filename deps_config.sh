#!/bin/sh
set -e

# Install Golang
wget -q https://dl.google.com/go/go1.10.2.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.10.2.linux-armv6l.tar.gz
rm go1.10.2.linux-armv6l.tar.gz
echo "export PATH=\$PATH:/usr/local/go/bin" >> .profile

# Install Docker
sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
echo "deb [arch=armhf] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
     $(lsb_release -cs) stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update; sudo apt-get install -y docker-ce=18.04.0~ce~3-0~raspbian
sudo systemctl start docker
sudo usermod pi -aG docker

# Disable Swap
sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall && \
  sudo update-rc.d dphys-swapfile remove

# Modify cmdline.txt
echo Adding " cgroup_enable=cpuset cgroup_enable=memory" to /boot/cmdline.txt
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt

# Add repo list and install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubelet=1.10.2-00 kubectl=1.10.2-00 kubeadm=1.10.2-00
