#!/bin/bash

sudo apt install -y cephadm

sudo cephadm bootstrap --mon-ip=192.168.56.12 \
  --cluster-network 192.168.56.0/24 \
  --initial-dashboard-password=admin \
  --dashboard-password-noupdate

sudo cephadm add-repo --release squid

sudo apt-get install -y ceph-common

for node in ceph{2..3}
do
  echo "=== Copying ceph.pub to $node ==="
  sudo ssh-copy-id -f -i /etc/ceph/ceph.pub root@$node
  echo ""
  sleep 2
done

for node in ceph{1..3}
do
  sudo ceph orch host add $node
done

sudo ceph orch apply osd --all-available-devices --method raw

for node in ceph{1..3}
do
  sudo ceph orch host label add $node mon
  sudo ceph orch host label add $node osd
done

for pool_name in volumes images backups vms
do
  sudo ceph osd pool create $pool_name
  sudo rbd pool init $pool_name
done

sudo ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images' -o /etc/ceph/ceph.client.glance.keyring
sudo ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=images' -o /etc/ceph/ceph.client.cinder.keyring
sudo ceph auth get-or-create client.nova mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=vms, allow rx pool=images' -o /etc/ceph/ceph.client.nova.keyring
sudo ceph auth get-or-create client.cinder-backup mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=backups' -o /etc/ceph/ceph.client.cinder-backup.keyring

for node in controller compute{1..2}
do
  sudo ssh root@$node sudo tee /etc/ceph/ceph.conf </etc/ceph/ceph.conf
done
