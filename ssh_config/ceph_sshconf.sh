#!/bin/bash
cp /vagrant/.vagrant/machines/controller/virtualbox/private_key .ssh/controller.pem
cp /vagrant/.vagrant/machines/compute1/virtualbox/private_key .ssh/compute1.pem
cp /vagrant/.vagrant/machines/compute2/virtualbox/private_key .ssh/compute2.pem
cp /vagrant/.vagrant/machines/ceph2/virtualbox/private_key .ssh/ceph2.pem
cp /vagrant/.vagrant/machines/ceph3/virtualbox/private_key .ssh/ceph3.pem
chmod 600 .ssh/controller.pem
chmod 600 .ssh/compute1.pem
chmod 600 .ssh/compute2.pem
chmod 600 .ssh/ceph2.pem
chmod 600 .ssh/ceph3.pem

ssh -i .ssh/controller.pem vagrant@controller echo "OK"
ssh -i .ssh/compute1.pem vagrant@compute1 echo "OK"
ssh -i .ssh/compute2.pem vagrant@compute2 echo "OK"
ssh -i .ssh/ceph2.pem vagrant@ceph2 echo "OK"
ssh -i .ssh/ceph3.pem vagrant@ceph3 echo "OK"


for node in controller compute{1..2} ceph{2..3}
do
  echo "=== Adding SSH key to $node (root user) ==="

  # Define the private key for each node
  if [[ $node == compute2 ]]; then
    key="/home/vagrant/.ssh/compute2.pem"
  elif [[ $node == compute1 ]]; then
    key="/home/vagrant/.ssh/compute1.pem"
  elif [[ $node == controller ]]; then
    key="/home/vagrant/.ssh/controller.pem"
  elif [[ $node == ceph2 ]]; then
    key="/home/vagrant/.ssh/ceph2.pem"
  elif [[ $node == ceph3 ]]; then
    key="/home/vagrant/.ssh/ceph3.pem"
  fi

  ssh -i $key vagrant@$node "sudo mkdir -p /root/.ssh && sudo echo '$(sudo cat /root/.ssh/id_rsa.pub)' | sudo tee -a /root/.ssh/authorized_keys && sudo chmod 600 /root/.ssh/authorized_keys"
  echo ""
  sleep 2
done

