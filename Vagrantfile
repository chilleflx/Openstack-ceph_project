# -*- mode: ruby -*-
# vi: set ft=ruby :

servers = [
  {
    :hostname => "controller",
    :ip => "192.168.56.10",
    :box => "ubuntu/jammy64",
    :ram => 6144,
    :cpu => 2,
    :disk => "20GB",
    :script => "sh /vagrant/setups/deployment_setup.sh"
  },
  {
    :hostname => "compute1",
    :ip => "192.168.56.11",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/compute1.sh"
  },
  {
    :hostname => "compute2",
    :ip => "192.168.56.13",
    :box => "ubuntu/jammy64",
    :ram => 1024,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/compute2.sh"
  },
  {
    :hostname => "ceph1",
    :ip => "192.168.56.12",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 2,
    :disk => "20GB",
    :script => "sh /vagrant/setups/ceph_setup.sh"
  },
  {
    :hostname => "ceph2",
    :ip => "192.168.56.14",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/ceph2_setup.sh"
  },
  {
    :hostname => "ceph3",
    :ip => "192.168.56.15",
    :box => "ubuntu/jammy64",
    :ram => 2048,
    :cpu => 1,
    :disk => "20GB",
    :script => "sh /vagrant/setups/ceph3_setup.sh"
  }
]

Vagrant.configure(2) do |config|
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = machine[:box]
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]  # Host-only network for access from host
      
      # ONLY ADDITION: Configure enp0s9 for OpenStack nodes (controller/computes)
      if ["controller", "compute1", "compute2"].include?(machine[:hostname])
        node.vm.network "private_network",
          ip: "192.168.57.#{machine[:ip].split('.').last}", # Auto IP (192.168.57.10/11/13)
          virtualbox__intnet: "provider_network",
          auto_config: true
      end
      
      node.disksize.size = machine[:disk]

      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram], "--cpus", machine[:cpu]]
        
        # NIC2 = host-only (enp0s8)
        vb.customize ["modifyvm", :id, "--nic2", "hostonly", "--hostonlyadapter2", "VirtualBox Host-Only Ethernet Adapter"]

        # NIC3 = NAT network (enp0s9)
        vb.customize ["modifyvm", :id, "--nic3", "natnetwork", "--nat-network3", "ProviderNetwork1", "--nicpromisc3", "allow-all"]

        # Add disk to controller (unchanged)
        if machine[:hostname] == "controller"
          file_to_disk = File.realpath(".") + "/block1cinder.vdi"
          unless File.exist?(file_to_disk)
            vb.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', "20480"]
          end
          vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
        end

        # Add disk to Ceph nodes (unchanged)
        if machine[:hostname].start_with?("ceph")
          disk_file = File.realpath(".") + "/block1#{machine[:hostname]}.vdi"
          unless File.exist?(disk_file)
            vb.customize ['createhd', '--filename', disk_file, '--format', 'VDI', '--size', "40480"]
          end
          vb.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', disk_file]
        end
      end

      node.vm.provision "shell", inline: machine[:script], privileged: true, run: "once"
    end
  end
end