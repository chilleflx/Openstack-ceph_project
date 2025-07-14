#!/bin/bash
cp /vagrant/.vagrant/machines/compute1/virtualbox/private_key .ssh/compute1.pem
cp /vagrant/.vagrant/machines/compute2/virtualbox/private_key .ssh/compute2.pem
cp /vagrant/.vagrant/machines/ceph1/virtualbox/private_key .ssh/ceph1.pem

chmod 600 .ssh/compute1.pem
chmod 600 .ssh/compute2.pem
chmod 600 .ssh/ceph1.pem

ssh -i .ssh/compute1.pem vagrant@compute1 echo "OK"
ssh -i .ssh/compute2.pem vagrant@compute2 echo "OK"
ssh -i .ssh/ceph1.pem vagrant@ceph1 echo "OK"


for node in compute{1..2} ceph1
do
  echo "=== Adding SSH key to $node (root user) ==="

  # Define the private key for each node
  if [[ $node == compute2 ]]; then
    key="/home/vagrant/.ssh/compute2.pem"
  elif [[ $node == compute1 ]]; then
    key="/home/vagrant/.ssh/compute1.pem"
  elif [[ $node == ceph1 ]]; then
    key="/home/vagrant/.ssh/ceph1.pem"
  fi

  ssh -i $key vagrant@$node "sudo mkdir -p /root/.ssh && sudo echo '$(sudo cat /root/.ssh/id_rsa.pub)' | sudo tee -a /root/.ssh/authorized_keys && sudo chmod 600 /root/.ssh/authorized_keys"
  echo ""
  sleep 2
done

