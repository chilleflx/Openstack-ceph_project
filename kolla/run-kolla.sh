#! /bin/sh
sudo apt install -y python3-pip
sudo pip install 'ansible-core>=2.16,<2.17.99'
sudo pip install git+https://opendev.org/openstack/kolla-ansible@master

sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

sudo cp /vagrant/kolla/multinode .
sudo cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
sudo cp /vagrant/kolla/globals.yml /etc/kolla

kolla-ansible install-deps
kolla-genpwd
kolla-ansible bootstrap-servers -i ./multinode
kolla-ansible prechecks -i ./multinode
kolla-ansible deploy -i ./multinode
echo "Horizon available at 192.168.56.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
