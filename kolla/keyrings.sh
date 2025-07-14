#!/bin/bash

# Créer les répertoires locaux si nécessaires
mkdir -p /etc/kolla/config/nova
mkdir -p /etc/kolla/config/glance
mkdir -p /etc/kolla/config/cinder/cinder-volume
mkdir -p /etc/kolla/config/cinder/cinder-backup

# Copier les fichiers Ceph au bon emplacement pour Kolla
cp /etc/ceph/ceph.conf /etc/kolla/config/nova/
cp /etc/ceph/ceph.conf /etc/kolla/config/glance/
cp /etc/ceph/ceph.conf /etc/kolla/config/cinder/

cp /etc/ceph/ceph.client.glance.keyring /etc/kolla/config/glance/
cp /etc/ceph/ceph.client.nova.keyring /etc/kolla/config/nova/
cp /etc/ceph/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-volume/
cp /etc/ceph/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-backup/
cp /etc/ceph/ceph.client.cinder-backup.keyring /etc/kolla/config/cinder/cinder-backup/

# Copier les fichiers vers les autres nœuds
for node in controller compute1 compute2; do
  echo "Copying Ceph keyrings and conf to $node..."
  ssh-keygen -f "/root/.ssh/known_hosts" -R "$node" 2>/dev/null
  ssh -o StrictHostKeyChecking=no root@$node "mkdir -p /etc/kolla/config/nova /etc/kolla/config/glance /etc/kolla/config/cinder/cinder-volume /etc/kolla/config/cinder/cinder-backup"
  scp -o StrictHostKeyChecking=no \
    /etc/ceph/ceph.conf \
    /etc/ceph/ceph.client.nova.keyring \
    /etc/ceph/ceph.client.glance.keyring \
    /etc/ceph/ceph.client.cinder.keyring \
    /etc/ceph/ceph.client.cinder-backup.keyring \
    root@$node:/tmp/

  # Déplacer ensuite au bon emplacement sur la machine distante
  ssh -o StrictHostKeyChecking=no root@$node <<'EOF'
    mv /tmp/ceph.conf /etc/kolla/config/nova/
    cp /etc/kolla/config/nova/ceph.conf /etc/kolla/config/glance/
    cp /etc/kolla/config/nova/ceph.conf /etc/kolla/config/cinder/
    mv /tmp/ceph.client.nova.keyring /etc/kolla/config/nova/
    mv /tmp/ceph.client.glance.keyring /etc/kolla/config/glance/
    mv /tmp/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-volume/
    cp /etc/kolla/config/cinder/cinder-volume/ceph.client.cinder.keyring /etc/kolla/config/cinder/cinder-backup/
    mv /tmp/ceph.client.cinder-backup.keyring /etc/kolla/config/cinder/cinder-backup/
EOF
done

