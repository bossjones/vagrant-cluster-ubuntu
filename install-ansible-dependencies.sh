#!/usr/bin/env bash

set -x

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_USER=vagrant
_NON_ROOT_USER_UID_OLD=1000
_NON_ROOT_USER_GID_OLD=1000
_NON_ROOT_USER_UID=1100
_NON_ROOT_USER_GID=1100
_PYENV_PYTHON_VERSION=3.6.2

DOCKER_COMPOSE_VERSION=v17.09.1
DOCKER_VERSION=17.09.0~ce-0~ubuntu
DOCKER_PACKAGE_NAME=docker-engine
DEBIAN_FRONTEND=noninteractive

# sudo apt-get install -y git
# sudo apt-get install -y make
# sudo apt-get install -y libbz2-dev
# sudo apt-get install -y libsqlite3-dev

# if [ ! -f /var/log/pythonsetup ];
# then
#     git clone git://github.com/yyuu/pyenv.git /home/${_USER}/.pyenv
#     chown ${_USER}:${_USER} .pyenv
#     echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> /home/${_USER}/.bashrc
#     echo 'eval "$(pyenv init -)"' >> /home/${_USER}/.bashrc

#     # Can't source /home/${_USER}/.bashrc for some reason so repeat commands below
#     export PATH="$HOME/.pyenv/bin:$PATH"
#     eval "$(pyenv init -)"

#     pyenv install ${_PYENV_PYTHON_VERSION}
#     pyenv rehash

#     touch /var/log/pythonsetup
# fi


apt-get update -yqq && \
sudo apt-get install -yqq \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual && \
apt-get install -yqq software-properties-common \
                   python-software-properties && \
apt-get install -yqq git && \
apt-get install -yqq build-essential \
                   libssl-dev \
                   libreadline-dev \
                   wget curl \
                   openssh-server && \
apt-get install -yqq gcc make \
                   linux-headers-$(uname -r) && \
apt-get install -yqq ca-certificates bash && \
apt-get install -yqq python-setuptools \
                   perl pkg-config \
                   python python-pip \
                   python-dev && \

sudo easy_install --upgrade pip && \
sudo easy_install --upgrade setuptools; \
sudo pip install setuptools --upgrade && \

add-apt-repository -y ppa:git-core/ppa && \
add-apt-repository -y ppa:ansible/ansible && \

apt-get update -yqq && \
apt-get install -yqq git lsof strace && \
apt-get upgrade -yqq && \
apt-get install -yqq ansible;

apt-get install -y openssh-server \
                   cryptsetup \
                   build-essential \
                   libssl-dev \
                   libreadline-dev \
                   zlib1g-dev \
                   linux-source \
                   dkms \
                   nfs-common \
                   zip unzip \
                   tree screen \
                   vim ntp \
                   vim-nox;

echo "CHANGE PASSWORD NOW FRIEND"

echo ${_USER}:${_USER} | chpasswd
# groupmod -A ${_USER} wheel
usermod -a -G wheel ${_USER}

# Install the ${_USER} insecure public SSH key.
mkdir -p /home/${_USER}/.ssh
curl -LsSo /home/${_USER}/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R ${_USER}:${_USER} /home/${_USER}/.ssh
chmod -R go-rwx /home/${_USER}/.ssh

# Give the ${_USER} user sudo privileges.
cat > /etc/sudoers.d/${_USER} <<-EOF
	${_USER} ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/${_USER}

#fix stuff
sed -i '/UsePAM/aUseDNS no' /etc/ssh/sshd_config
sed -i '/env_reset/aDefaults        env_keep += "SSH_AUTH_SOCK"' /etc/sudoers;
# # source: https://github.com/geekduck/packer-templates/blob/76fb94e4161cd21a30047205c77cefeb4b881f8d/Ubuntu16.04/scripts/base.sh
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo ALL=(ALL:ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
adduser vagrant adm

date > /etc/vagrant_box_build_time

# cleanup
# source: https://github.com/geekduck/packer-templates/blob/76fb94e4161cd21a30047205c77cefeb4b881f8d/Ubuntu16.04/scripts/cleanup.sh
apt-get -yqq autoremove
apt-get -yqq clean

# Install docker now
# prereqs
apt-get update -qq
apt-get install -yqq --no-install-recommends \
    apt-transport-https \
    curl \
    software-properties-common

# aufs support
apt-get install -y --no-install-recommends \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual

# Download and import Docker’s public key for CS packages:
curl -fsSL 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add -

add-apt-repository -y \
   "deb https://packages.docker.com/1.12/apt/repo/ \
   ubuntu-$(lsb_release -cs) \
   main"

# source: https://www.ubuntuupdates.org/ppa/docker_new?dist=ubuntu-trusty ( so we can get 1.12.5 )
apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo sh -c "echo deb https://apt.dockerproject.org/repo ubuntu-trusty main \
> /etc/apt/sources.list.d/docker.list"
sudo apt-get update -qq
sudo apt-get install -y ${DOCKER_PACKAGE_NAME}

apt-get update -qq

apt-cache search ${DOCKER_PACKAGE_NAME}
apt-cache madison ${DOCKER_PACKAGE_NAME}
apt-get -y -o Dpkg::Options::="--force-confnew" install ${DOCKER_PACKAGE_NAME}=$DOCKER_VERSION

rm -f /usr/local/bin/docker-compose
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
mv docker-compose /usr/local/bin
docker-compose --version

usermod -a -G docker ${_USER}

# Finally, and optionally, let’s configure Docker to start when the server boots:
update-rc.d docker defaults

# ctop
sudo wget https://github.com/bcicen/ctop/releases/download/v0.6.0/ctop-0.6.0-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# other deps
sudo apt-get update -qq
sudo apt-get install -y git-core \
                     htop \
                     curl zlib1g-dev \
                     build-essential \
                     libssl-dev libreadline-dev \
                     libyaml-dev libsqlite3-dev \
                     sqlite3 libxml2-dev libxslt1-dev \
                     libcurl4-openssl-dev \
                     python-software-properties \
                     libffi-dev nodejs

sudo apt-get install -yqq libgdbm-dev \
                        libncurses5-dev \
                        automake libtool \
                        bison libffi-dev

# https://askubuntu.com/questions/21547/what-are-the-packages-libraries-i-should-install-before-compiling-python-from-so
sudo apt-get install -yqq build-essential \
                        libncursesw5-dev \
                        libssl-dev \
                        libgdbm-dev \
                        libc6-dev \
                        libsqlite3-dev tk-dev \
                        libbz2-dev

sudo apt-get build-dep -yqq python3.4

exit 0
