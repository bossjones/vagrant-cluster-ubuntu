# HACKING

# Researching this

https://samiux.blogspot.com/2015/09/howto-hardening-and-tuning-ubuntu-1404.html

## Sysctl.conf setting ( Look at each kernel value and see if its bullshit or not )

```
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.
#

#kernel.domainname = example.com

# Uncomment the following to stop low-level messages on console
#kernel.printk = 3 4 1 3

##############################################################3
# Functions previously found in netbase
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
#net.ipv4.conf.default.rp_filter=1
#net.ipv4.conf.all.rp_filter=1

# Uncomment the next line to enable TCP/IP SYN cookies
# See http://lwn.net/Articles/277146/
# Note: This may impact IPv6 TCP sessions too
#net.ipv4.tcp_syncookies=1

# Uncomment the next line to enable packet forwarding for IPv4
#net.ipv4.ip_forward=1

# Uncomment the next line to enable packet forwarding for IPv6
#  Enabling this option disables Stateless Address Autoconfiguration
#  based on Router Advertisements for this host
#net.ipv6.conf.all.forwarding=1


###################################################################
# Additional settings - these settings can improve the network
# security of the host and prevent against some network attacks
# including spoofing attacks and man in the middle attacks through
# redirection. Some network environments, however, require that these
# settings are disabled so review and enable them as needed.
#
# Do not accept ICMP redirects (prevent MITM attacks)
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv6.conf.all.accept_redirects = 0
# _or_
# Accept ICMP redirects only for gateways listed in our default
# gateway list (enabled by default)
# net.ipv4.conf.all.secure_redirects = 1
#
# Do not send ICMP redirects (we are not a router)
#net.ipv4.conf.all.send_redirects = 0
#
# Do not accept IP source route packets (we are not a router)
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv6.conf.all.accept_source_route = 0
#
# Log Martian Packets
#net.ipv4.conf.all.log_martians = 1
#

## added by samiux for performance and security

# performance tuning
kernel.sem = 250 32000 100 128
kernel.shmall = 2097152
kernel.shmmax = 2147483648
kernel.shmmni = 4096
# If you have more than 512MB RAM, use this setting unless comment it out
fs.file-max = 262140
# If you have 512MB RAM or less, uncomment this setting; otherwise, comment it out
#fs.file-max = 65535
vm.swappiness = 1
vm.vfs_cache_pressure = 50
vm.min_free_kbytes = 65536

net.core.rmem_default = 33554432
net.core.rmem_max = 33554432
net.core.wmem_default = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_rmem = 10240 87380 33554432
net.ipv4.tcp_wmem = 10240 87380 33554432
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_tw_buckets = 360000

net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_mem = 94500000 915000000 927000000

# security setting

## protect against tcp time-wait assassination hazards
## drop RST packets for sockets in the time-wait state
## (not widely supported outside of linux, but conforms to RFC)
net.ipv4.tcp_rfc1337 = 1

## tcp timestamps
## + protect against wrapping sequence numbers (at gigabit speeds)
## + round trip time calculation implemented in TCP
## - causes extra overhead and allows uptime detection by scanners like nmap
## enable @ gigabit speeds
net.ipv4.tcp_timestamps = 0

net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_orphan_retries = 2
net.ipv4.conf.all.accept_redirects = 0

## send redirects (not a router, disable it)
net.ipv4.conf.all.send_redirects = 0

## ICMP routing redirects (only secure)
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.secure_redirects = 0
net.ipv6.conf.default.secure_redirects = 0

## log martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

## sets the kernels reverse path filtering mechanism to value 1(on)
## will do source validation of the packet's recieved from all the interfaces on the machine
## protects from attackers that are using ip spoofing methods to do harm
net.ipv4.conf.all.rp_filter = 1
net.ipv6.conf.all.rp_filter = 1

net.ipv4.conf.default.rp_filter = 1

## TCP SYN cookie protection (default)
## helps protect against SYN flood attacks
## only kicks in when net.ipv4.tcp_max_syn_backlog is reached
net.ipv4.tcp_syncookies = 1

## ignore echo broadcast requests to prevent being part of smurf attacks (default)
net.ipv4.icmp_echo_ignore_broadcasts = 1

## ignore bogus icmp errors (default)
net.ipv4.icmp_ignore_bogus_error_responses = 1

# network traffic congestion control
net.ipv4.tcp_congestion_control=htcp

# I/O tuning
#vm.dirty_background_ratio = 0
vm.dirty_background_ratio = 2
vm.dirty_background_bytes = 209715200
vm.dirty_ratio = 40
vm.dirty_bytes = 209715200
vm.dirty_writeback_centisecs = 100
vm.dirty_expire_centisecs = 200

# Buffer Overflow Protection in Ubuntu only
# Enable "No Execute (NX)" or "Execute Disable (XD)" in BIOS/UEFI
# Then run : sudo dmesg | grep --color '[NX|XD]*protection'
# If you see "NX (Execute Disable) protection: active" or similar, your
# kernel is protected from Buffer Overflow.

# Buffer Overflow Protection in RedHat/CentOS/Fedora only
#kernel.exec-shield = 1

# Enable ASLR
# 0 - Do not randomize stack and vdso page.
# 1 - Turn on protection and randomize stack, vdso page and mmap.
# 2 - Turn on protection and randomize stack, vdso page and mmap +
#     randomize brk base address.
kernel.randomize_va_space = 2
```

## How to Performance Tune Ubuntu 14.04 LTS Trusty in AWS EC2

**source: http://www.philchen.com/2015/10/28/how-to-performance-tune-ubuntu-14-04-lts-trusty-in-aws-ec2**

This article will explain how to performance tune Ubuntu 14.04 LTS Trusty in Amazon Web Services EC2. Building a good base AWS AMI is important and if your using Ubuntu 14.04 this will hopefully be of some help.

Step 0
Time Matters! Make sure you have NTP installed otherwise do the following:

```
sudo apt-get update

sudo ntpdate pool.ntp.org

sudo apt-get install ntp
```

Step 1
Increase the default file descriptor limit of 1024. TCP/IP sockets are considered open files so increasing this will help you handle more connections.

Append the below to your limits.conf file

`sudo vim /etc/security/limits.conf`

```
root		soft	nofile		65535
root		hard	nofile		65535
*		soft	nofile		65535
*		hard	nofile		65535
```

Append the below to your sshd_config file *Note this might already exist

`sudo vim /etc/ssh/sshd_config`

`UsePAM yes`
Append the below to your PAM sshd file *Note this might already exist

sudo vim /etc/pam.d/sshd
session required pam_limits.so
Append the below to your PAM common-session file

sudo vim /etc/pam.d/common-session
session required pam_limits.so
Append the below to your sysctl.conf file

sudo vim /etc/sysctl.conf
fs.file-max = 762427
Run

sudo sysctl -p
Step 2
Save your SSD drives and leverage RAM by avoiding the use of swap. With this setting the kernel will swap only to avoid an out of memory condition.

Append the below to your sysctl.conf file

sudo vim /etc/sysctl.conf
vm.swappiness = 0
Run

sudo sysctl -p
Step 3
Configure Kernel Network Performance Settings

Append the below to your sysctl.conf file

sudo vim /etc/sysctl.conf
# Increase the number of connections
net.core.somaxconn = 1000

# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 5000

# Maximum Socket Receive Buffer
net.core.rmem_max = 16777216

# Default Socket Send Buffer
net.core.wmem_max = 16777216

# Increase the maximum total buffer-space allocatable
net.ipv4.tcp_wmem = 4096 12582912 16777216
net.ipv4.tcp_rmem = 4096 12582912 16777216

# Increase the number of outstanding syn requests allowed
net.ipv4.tcp_max_syn_backlog = 8096

# For persistent HTTP connections
net.ipv4.tcp_slow_start_after_idle = 0

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_tw_reuse = 1

# Allowed local port range
net.ipv4.ip_local_port_range = 10240 65535
Run

sudo sysctl -p
Step 4
Disable file access time logging. Setting the noatime effects removing a write for every read. Typically when a file is read the system updates the inode for the file with an access time so that the last access time is recorded, which basically entails a write to the file system. Unless you are running some sort of mirror you probably do not need the access time written.

Add the noatime attribute to your mount in fstab

sudo vim /etc/fstab
LABEL=cloudimg-rootfs	/	 ext4	defaults,noatime,discard	0 0
Step 5
Increase history and make your command prompt more informative, nothing more sad then typing history and not seeing some old commands you forgot to take not of. Also these changes will help you know where your at from a path standpoint.

Append the below to your profile file

sudo vim /etc/profile
# HISTORY SETTINGS
export HISTTIMEFORMAT='%F %R '
export HISTSIZE=2000
export HISTFILESIZE=2000
export HISTCONTROL=ignoredups

# Command Prompt Settings

export PS1='\[\033[1;34m\][\u@\h:\w]\$\[\033[0m\]'
*You will have to log out and back in for these changes to take effect.

After your done make a new AMI image and you should have a decently strong foundation for your application specific AMI’s. If your not making an image you may want to reboot the instance to ensure your changes took, specifically in the case of the fstab noatime.


# Add to Makefile

**source: https://github.com/voytek-solutions/aws-build/blob/7a867d0bfcf73cebb341d6b92d53d6b8f303e21b/Makefile**

```
## Lint Ansible roles
lint:
	find ansible/roles ansible/playbooks -name "*.yml" -print0 | xargs -n1 -0 -I{} \
		ansible-lint \
			-v \
			--exclude=ansible/vendor \
			{}

## Builds and `ssh` to given machine.
# Startup and (re)provision local VM and then `ssh` to it for given ROLE.
# Example: make vagrant ROLE=example
#          make vagrant ROLE=example MODE=configure
vagrant: vagrant_build
	vagrant ssh

## Builds VM
vagrant_build:
	vagrant up --no-provision
	MODE="$(MODE)" vagrant provision

## Watch changes and rebuild local VM
# Example: make watch ROLE=example
vagrant_watch:
	while sleep 1; do \
		find ansible/ \
			vagrant/ \
			Vagrantfile \
		| entr -d $(MAKE) lint vagrant_build ROLE=$(ROLE); \
	done

## Runs simple command on a given local VM.
# Example: make vagrant_ssh ROLE=example
#          make vagrant_status ROLE=example
#          make vagrant_halt ROLE=example
#          make vagrant_destroy ROLE=example
vagrant_%:
	MODE=$(MODE) vagrant $(subst vagrant_,,$@)

## Clean up
clean:
	rm -rf ansible/vendor
	rm -rf .venv

# creates empty `.make` if it does not exist
.make:
	echo "" > .make
```


# More

http://software.danielwatrous.com/using-vagrant-to-explore-ansible/


# https://github.com/debops/examples/blob/master/vagrant-multi-machine/Vagrantfile

```

# -*- mode: ruby -*-
# vim: ft=ruby


# ---- Configuration variables ----

GUI               = false # Enable/Disable GUI
RAM               = 128   # Default memory size in MB

# Network configuration
DOMAIN            = ".nat.example.com"
NETWORK           = "192.168.50."
NETMASK           = "255.255.255.0"

# Default Virtualbox .box
# See: https://wiki.debian.org/Teams/Cloud/VagrantBaseBoxes
BOX               = 'debian/jessie64'


HOSTS = {
   "web" => [NETWORK+"10", RAM, GUI, BOX],
   "db" => [NETWORK+"11", RAM, GUI, BOX],
}

ANSIBLE_INVENTORY_DIR = 'ansible/inventory'

# ---- Vagrant configuration ----

Vagrant.configure(2) do |config|
  HOSTS.each do | (name, cfg) |
    ipaddr, ram, gui, box = cfg

    config.vm.define name do |machine|
      machine.vm.box   = box
      machine.vm.guest = :debian

      machine.vm.provider "virtualbox" do |vbox|
        vbox.gui    = gui
        vbox.memory = ram
        vbox.name = name
      end

      machine.vm.hostname = name + DOMAIN
      machine.vm.network 'private_network', ip: ipaddr, netmask: NETMASK
    end
  end # HOSTS-each

  config.vm.provision "vai" do |ansible|
    ansible.inventory_dir=ANSIBLE_INVENTORY_DIR
    # optional: add a group listing all vagrant machines
    ansible.groups = {
      'secondGroup' => [ "db" ],
    #  '_provided_by_vagrant_'=> HOSTS.keys,
    }
  end

end

```

# Research

- http://www.rsyslog.com/modern-syslogd/
- https://www.rfaircloth.com/2017/02/10/building-perfect-syslog-collection-infrastructure/
- https://rsyslog.readthedocs.io/en/latest/whitepapers/index.html
- https://rsyslog.readthedocs.io/en/latest/whitepapers/syslog_protocol.html
- https://rsyslog.readthedocs.io/en/latest/whitepapers/syslog_parsing.html
- https://rsyslog.readthedocs.io/en/latest/whitepapers/queues_analogy.html
- https://github.com/guilhemmarchand/nmon-logger/tree/master/vagrant-ansible-demo-rsyslog
- https://www.corestack.io/blog/governing-log-ops-hybrid-cloud/
- https://www.loggly.com/docs/troubleshooting-rsyslog/
- http://www.rsyslog.com/doc/v8-stable/
- https://www.loggly.com/docs/configure-syslog-script/
- https://github.com/loggly/install-script/blob/master/Linux%20Script/configure-linux.sh


# https://github.com/petro-rudenko/bigdata-toolbox/blob/master/Vagrantfile


# Custom Facts in ansible

- https://medium.com/@jezhalford/ansible-custom-facts-1e1d1bf65db8
- http://serverascode.com/2015/01/27/ansible-custom-facts.html
- https://docs.ansible.com/ansible/latest/setup_module.html
-


# To deug tomorrow

```
WARNING: No memory limit support
WARNING: No swap limit support
WARNING: No kernel memory limit support
WARNING: No oom kill disable support
WARNING: No cpu cfs quota support
WARNING: No cpu cfs period support
WARNING: No cpu shares support
WARNING: No cpuset support
```

# DNS ( PowerDNS )
- https://github.com/PowerDNS/pdns-ansible/tree/master/molecule/common


```
become: pi
become_user: pi
```
