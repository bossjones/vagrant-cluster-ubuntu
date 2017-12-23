# -*- mode: ruby -*-
# # vi: set ft=ruby :
# https://github.com/hashicorp/vagrant/issues/8058

# role = File.basename(File.expand_path(File.dirname(__FILE__)))

# require 'yaml'
# settings = YAML.load_file 'vagrant.yml'

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

###############################################################
# FIXME: We can use this to make a dynamic inventory 12/22/2017
# SOURCE: https://github.com/tdi/vagrant-docker-swarm/blob/master/Vagrantfile
###############################################################
# auto = ENV['AUTO_START_SWARM'] || false
# # Increase numworkers if you want more than 3 nodes
# numworkers = 2

# # VirtualBox settings
# # Increase vmmemory if you want more than 512mb memory in the vm's
# vmmemory = 512
# # Increase numcpu if you want more cpu's per vm
# numcpu = 1

# instances = []

# (1..numworkers).each do |n|
#   instances.push({:name => "worker#{n}", :ip => "192.168.10.#{n+2}"})
# end

# manager_ip = "192.168.10.2"

# File.open("./hosts", 'w') { |file|
#   instances.each do |i|
#     file.write("#{i[:ip]} #{i[:name]} #{i[:name]}\n")
#   end
# }
###############################################################


# FIX: "InsecurePlatformWarning: A true SSLContext object is not available. This prevents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. For more information, see urllib3.readthedocs.org/en/latest/security.html#insecureplatformwarning. InsecurePlatformWarning"
# SOURCE: https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04

$fix_perm = <<SHELL
sudo chmod 600 /home/vagrant/.ssh/id_rsa
SHELL

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
sudo add-apt-repository -y ppa:git-core/ppa && \
sudo add-apt-repository -y ppa:ansible/ansible && \
sudo add-apt-repository ppa:chris-lea/python-urllib3 && \
sudo apt-get update -yqq && \
sudo apt-get install -yqq python-urllib3 && \
sudo apt-get install -yqq git ansible && \
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

  # config.vm.post_up_message = "Now you can get an access to https://localhost:8085 \n See login and password in secret/credentials/owncloud.local/owncloud/admin/"
  # config.vm.define "owncloud.local"

  # # This ensures that the locale is correctly set for Postgres
  # config.vm.provision "shell", inline: 'update-locale LC_ALL="en_US.utf8"'

  # enable hostmanager
  config.hostmanager.enabled = true

  # configure the host's /etc/hosts
  config.hostmanager.manage_host = true

  # FIXME: ENABLE ME
  # SOURCE: https://github.com/tIsGoud/Docker-Swarm-deployed-with-Ansible
  # config.vbguest.auto_update = true
  # config.vbguest.no_remote = true

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

      # FIXME: Needed for docker-swarm??????? 12/22/2017
      # SOURCE: https://github.com/ball6847/ansible-gitlab-ci/blob/9c90c8c7e5852b4a9982bb8f7dcfc45951ea6802/Vagrantfile
      # config.vm.network "public_network", bridge: "en0: Wi-Fi (AirPort)"

      # config.vm.network "private_network", ip: box_ip

      # # set auto_update to false, if you do NOT want to check the correct
      # # additions version when booting this machine
      # config.vbguest.auto_update = true

      # # do NOT download the iso file from a webserver
      # config.vbguest.no_remote = false

      # FIXME: Set this to a real path
      public_key = ENV['HOME'] + '/dev/vagrant-box/fedora/keys/vagrant.pub'

      config.vm.provision :shell, inline: $docker_script

      # copy private key so hosts can ssh using key authentication (the script below sets permissions to 600)
      config.vm.provision :file do |file|
        file.source      = './keys/vagrant_id_rsa'
        file.destination = '/home/vagrant/.ssh/id_rsa'
      end

      # fix permissions on private key file
      config.vm.provision :shell, inline: $fix_perm

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
          # Prevent intermittent connection timeout on ssh when provisioning.
          # ansible.raw_ssh_args = ['-o ConnectTimeout=120']
          # gist: https://gist.github.com/phantomwhale/9657134
          # ansible.raw_arguments = Shellwords.shellsplit(ENV['ANSIBLE_ARGS']) if ENV['ANSIBLE_ARGS']
          # CLI command.
          # ANSIBLE_ARGS='--extra-vars "some_var=value"' vagrant up
          # ansible.tags="dotfiles"
        end  # config.vm.provision "ansible" do |ansible|
      end  # if i == num_instances

      ansible_inventory_dir = "ansible/hosts"

      # source: https://www.simonholywell.com/post/2016/02/intelligent-vagrant-and-ansible-files/
      # setup the ansible inventory file
      # Dir.mkdir(ansible_inventory_dir) unless Dir.exist?(ansible_inventory_dir)
      # File.open("#{ansible_inventory_dir}/vagrant-dynamic" ,'w') do |f|
      #   f.write "[#{settings['vm_name']}]\n"
      #   f.write "#{settings['ip_address']}\n"
      # end

    end
  end
end
