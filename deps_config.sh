#!/bin/sh
set -e

# Define the type of node being set (the selection could use regexp)
read -r -p "Is this a Master or Slave node? (s) " node_choice
case "$node_choice" in
  m|M ) node_type=master;;
  s|S ) node_type=slave;;
  * ) node_type=slave;;
esac

# Install Golang
# wget https://dl.google.com/go/go1.10.2.linux-armv6l.tar.gz
# sudo tar -C /usr/local -xzf go1.10.2.linux-armv6l.tar.gz
# rm go1.10.2.linux-armv6l.tar.gz
# echo "export PATH=\$PATH:/usr/local/go/bin" >> .profile

# Add user to Docker group
if [[ "$node_type" == "m" ]]; then
  sudo usermod pirate -aG docker
else
  echo "Docker should be installed"
  exit 1
fi

# Backup cmdline.txt and add cgroups
sudo cp /boot/cmdline.txt /boot/cmdline_backup.txt
orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo $orig | sudo tee /boot/cmdline.txt

# Install Kubernetes 1.10.2-00
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubeadm=1.10.2-00 kubectl=1.10.2-00 kubelet=1.10.2-00

if [[ "$node_type" == "m" ]]; then
  sudo sed -i '/KUBELET_NETWORK_ARGS=/d' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
fi
