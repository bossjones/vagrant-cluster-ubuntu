# -*- mode: ruby -*-
# # vi: set ft=ruby :
# https://github.com/hashicorp/vagrant/issues/8058

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# Defaults for config options defined in CONFIG
$num_instances = 3
$instance_name_prefix = "ubuntu"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 2048
$vm_cpus = 2
$forwarded_ports = {}

# SOURCE: https://github.com/bossjones/docker-swarm-vbox-lab/blob/master/Vagrantfile
$docker_script = <<SHELL
if [ -f /vagrant_bootstrap ]; then
   echo "vagrant_bootstrap EXISTS ALREADY"
   exit 0
fi

export DEBIAN_FRONTEND=noninteractive
sudo apt-get autoremove -y && \
sudo apt-get update -yqq && \
sudo apt-get install -yqq software-properties-common \
                   python-software-properties && \
sudo apt-get install -yqq build-essential \
                   libssl-dev \
                   libreadline-dev \
                   wget curl \
                   openssh-server && \
sudo apt-get install -yqq python-setuptools \
                   perl pkg-config \
                   python python-pip \
                   python-dev && \
sudo easy_install --upgrade pip && \
sudo easy_install --upgrade setuptools; \
sudo pip install setuptools --upgrade && \
sudo add-apt-repository -y ppa:git-core/ppa && \
sudo add-apt-repository -y ppa:ansible/ansible && \
sudo apt-get update -yqq && \
sudo apt-get install -yqq git lsof strace ansible && \
sudo mkdir -p /home/vagrant/ansible/{roles,group_vars,inventory}
sudo chown -R vagrant:vagrant /home/vagrant/
cat << EOF > /home/vagrant/ansible/ansible.cfg
[defaults]
# Modern servers come and go too often for host key checking to be useful
roles_path = ./roles
system_errors = False
host_key_checking = False
ask_sudo_pass = False
retry_files_enabled = False
gathering = smart
force_handlers = True
[privilege_escalation]
# Nearly everything requires sudo, so default on
become = True
[ssh_connection]
# Speeds things up, but requires disabling requiretty in /etc/sudoers
pipelining = True
EOF
cat << EOF > /home/vagrant/ansible/playbook.yml
---
- hosts: all
  become: yes
  become_method: sudo
  vars:
    ulimit_config:
      - domain: '*'
        type: soft
        item: nofile
        value: 64000
      - domain: '*'
        type: hard
        item: nofile
        value: 64000
  roles:
    - role: ulimit
    - role: sysctl-performance
EOF
cat << EOF > /home/vagrant/ansible/hosts
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python2
EOF
cat << EOF > /home/vagrant/ansible/galaxy.txt
debops.ansible_plugins
debops.apache
debops.apt
debops.apt_cacher_ng
debops.apt_install
debops.apt_listchanges
debops.apt_preferences
debops.apt_proxy
debops.atd
debops.auth
debops.authorized_keys
debops.avahi
debops.backporter
debops.bootstrap
debops.boxbackup
debops.console
debops.core
debops.cron
debops.cryptsetup
debops.debops
debops.debops_api
debops.debops_fact
debops.dhcpd
debops.dhparam
debops.dnsmasq
debops.docker
debops.docker_gen
debops.dokuwiki
debops.dovecot
debops.elastic_co
debops.elasticsearch
debops.environment
debops.etc_aliases
debops.etc_services
debops.etherpad
debops.fail2ban
debops.fcgiwrap
debops.ferm
debops.gitlab
debops.gitlab_ci
debops.gitlab_ci_runner
debops.gitlab_runner
debops.gitusers
debops.golang
debops.grub
debops.gunicorn
debops.hashicorp
debops.hwraid
debops.ifupdown
debops.ipxe
debops.iscsi
debops.java
debops.kibana
debops.kvm
debops.librenms
debops.libvirt
debops.libvirtd
debops.libvirtd_qemu
debops.logrotate
debops.lvm
debops.lxc
debops.mailman
debops.mariadb
debops.mariadb_server
debops.memcached
debops.monit
debops.monkeysphere
debops.mosquitto
debops.mysql
debops.netbox
debops.nfs
debops.nfs_server
debops.nginx
debops.nodejs
debops.nsswitch
debops.ntp
debops.nullmailer
debops.opendkim
debops.openvz
debops.owncloud
debops.persistent_paths
debops.php
debops.php5
debops.phpipam
debops.phpmyadmin
debops.pki
debops.postconf
debops.postfix
debops.postgresql
debops.postgresql_server
debops.postscreen
debops.postwhite
debops.preseed
debops.rabbitmq_management
debops.rabbitmq_server
debops.radvd
debops.rails_deploy
debops.redis
debops.reprepro
debops.resources
debops.root_account
debops.rsnapshot
debops.rstudio_server
debops.rsyslog
debops.ruby
debops.salt
debops.samba
debops.saslauthd
debops.secret
debops.sftpusers
debops.sks
debops.slapd
debops.smstools
debops.snmpd
debops.sshd
debops.stunnel
debops.swapfile
debops.sysctl
debops.tcpwrappers
debops.tftpd
debops.tgt
debops.tinc
debops.unattended_upgrades
debops.unbound
debops.users
EOF
cd /home/vagrant/ansible/roles && \
git clone https://github.com/KAMI911/ansible-role-sysctl-performance sysctl-performance && \
git clone https://github.com/picotrading/ansible-ulimit ulimit && \
git clone https://github.com/dev-sec/ansible-os-hardening.git ansible-os-hardening && \
cd /home/vagrant/ansible && \
ansible-playbook -i hosts playbook.yml && \
cd /home/vagrant && \
sudo chown -R vagrant:vagrant /home/vagrant/ && \
sudo touch /vagrant_bootstrap && \
sudo chown vagrant:vagrant /vagrant_bootstrap
SHELL

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  config.vm.box = "ubuntu/trusty64"

  # enable hostmanager
  config.hostmanager.enabled = true

  # configure the host's /etc/hosts
  config.hostmanager.manage_host = true

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          # NOTE: uart1: serial port
          # INFO: http://wiki.openpicus.com/index.php/UART_serial_port
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          # INFO: --uartmode<1-N> <arg>: This setting controls how VirtualBox connects a given virtual serial port (previously configured with the --uartX setting, see above) to the host on which the virtual machine is running. As described in detail in Section 3.10, “Serial ports”, for each such port, you can specify <arg> as one of the following options:
          # SOURCE: https://www.virtualbox.org/manual/ch08.html
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
          vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          vb.customize ["modifyvm", :id, "--ioapic", "on"]
          # vb.customize ["modifyvm", :id, "--cpuexecutioncap", "75"]
          vb.customize ["modifyvm", :id, "--chipset", "ich9"]
        end
      end

      # -----------------------------------------------------------------
      # source: https://github.com/bossjones/oh-my-fedora24/blob/9c16caf1451ae26c5b2d7ad4eb631d9ddc80df2e/Vagrantfile
      # FIXME: We need these guys
      # config.ssh.insert_key = false

      # config.vm.provider :virtualbox do |v|
      #   v.memory = 1024
      #   v.cpus = 2
      #   v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      #   v.customize ["modifyvm", :id, "--ioapic", "on"]
      # end

      # set auto_update to false, if you do NOT want to check the correct
      # # additions version when booting this machine
      # config.vbguest.auto_update = true

      # # do NOT download the iso file from a webserver
      # config.vbguest.no_remote = false

      # *****************************************************************
      # config.vm.hostname = 'hyena.org'
      # config.vm.boot_timeout = 400

      # # network
      # config.vm.network "public_network", :bridge => 'en0: Wi-Fi (AirPort)'
      # config.vm.network "forwarded_port", guest: 19360, host: 1936
      # config.vm.network "forwarded_port", guest: 139, host: 1139
      # config.vm.network "forwarded_port", guest: 8081, host: 8881
      # config.vm.network "forwarded_port", guest: 2376, host: 2376
      # config.vm.network "forwarded_port", guest: 1999, host: 19999

      # # ssh
      # config.ssh.username = "vagrant"
      # config.ssh.host = "127.0.0.1"
      # config.ssh.guest_port = "2222"
      # config.ssh.private_key_path = ENV['HOME'] + '/dev/bossjones/oh-my-fedora24/keys/vagrant_id_rsa'
      # config.ssh.forward_agent = true
      # config.ssh.forward_x11 = true
      # config.ssh.insert_key = false
      # config.ssh.keep_alive  = 5
      # *****************************************************************

      # NOTE: Borrowed from scarlett-ansible
      # config.vm.network "forwarded_port", guest: 2376, host: 2376, host_ip: "127.0.0.1"
      # # config.vm.network :forwarded_port,
      # #   guest: 22,
      # #   host: 2222,
      # #   host_ip: "127.0.0.1",
      # #   id: "ssh",
      # #   auto_correct: true
      # config.ssh.username = 'vagrant'
      # config.ssh.host = '127.0.0.1'
      # config.ssh.guest_port = '2222'
      # config.ssh.private_key_path = './keys/vagrant_id_rsa'
      # config.ssh.forward_agent = true
      # config.ssh.forward_x11 = true
      # config.ssh.insert_key = false
      # -----------------------------------------------------------------

      $forwarded_ports.each do |guest, host|
        config.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
      end

      ip = "172.17.10.#{i+100}"
      config.vm.network :private_network, ip: ip

      # config.vm.network "private_network", ip: box_ip

      # # set auto_update to false, if you do NOT want to check the correct
      # # additions version when booting this machine
      # config.vbguest.auto_update = true

      # # do NOT download the iso file from a webserver
      # config.vbguest.no_remote = false

      # FIXME: Set this to a real path
      public_key = ENV['HOME'] + '/dev/vagrant-box/fedora/keys/vagrant.pub'

      config.vm.provision :shell, inline: $docker_script

      # Only execute once the Ansible provisioner,
      # when all the machines are up and ready.
      current_i = "#{i}"

      if current_i == "#{$num_instances}"

        # Run Ansible from the Vagrant Host

        config.vm.provision "ansible" do |ansible|
          ansible.playbook = "playbook.yml"
          ansible.verbose = "-v"
          ansible.sudo = true
          ansible.host_key_checking = false
          ansible.limit = 'all'
          # ansible.inventory_path = "provisioning/inventory"
          ansible.inventory_path = "ubuntu-inventory"
          # ansible.sudo = true
          # ansible.extra_vars = {
          #   public_key: public_key
          # }
        end
      end  # if i == num_instances
    end
  end
end
