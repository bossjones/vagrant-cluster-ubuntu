# include .mk

SHELL=/bin/bash
ELASTIC_REGISTRY ?= docker.elastic.co

# source: https://github.com/ansible-city/aws_foundation/blob/cb7352ab84a0e437f1be8cebfab541af8df09c29/Makefile
# ROLE_NAME ?= $(shell basename $$(pwd))
# VENV ?= .venv

# PATH := $(VENV)/bin:$(shell printenv PATH)
# SHELL := env PATH=$(PATH) /bin/bash

export PATH := ./bin:./venv/bin:$(PATH)

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))


.PHONY: list help
# .PHONY: all dockerfile docker-compose test test-build lint clean pristine run run-single run-cluster build release-manager release-manager-snapshot push

help:
	@echo "Convenience Make commands for provisioning a scarlett node"

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

create-gitignore:
	@bash ./bin/clean_install_roles

vagrant-provision:
	vagrant provision

vagrant-up:
	vagrant up

vagrant-ssh:
	vagrant ssh

vagrant-destroy:
	vagrant destroy

vagrant-halt:
	vagrant halt

vagrant-config:
	vagrant ssh-config

serverspec-diff:
	cat serverspec_things_to_check_for.txt

serverspec:
	bundle exec rake

serverspec-install:
	bundle install --path .vendor

download-roles:
	ansible-galaxy install -r install_roles.txt --roles-path roles/ -vvv

install-cidr-brew:
	pip install cidr-brewer

install-test-deps:
	pip install ansible==2.2.3.0
	pip install docker-py
	pip install molecule --pre

bootstrap-molecule:
	molecule init scenario --role-name $(current_dir) --scenario-name default

ci:
	molecule test

bootstrap: venv

# enter virtualenv so we can use Ansible
activate:
	. venv/bin/activate

# The tests are written in Python. Make a virtualenv to handle the dependencies.
venv: requirements.txt
	@if [ -z $$PYTHON2 ]; then\
	    PY2_MINOR_VER=`python2 --version 2>&1 | cut -d " " -f 2 | cut -d "." -f 2`;\
	    if (( $$PY2_MINOR_VER < 7 )); then\
		echo "Couldn't find python2 in \$PATH that is >=3.5";\
		echo "Please install python2.7 or later or explicity define the python3 executable name with \$PYTHON2";\
	        echo "Exiting here";\
	        exit 1;\
	    else\
		export PYTHON2="python2.$$PY2_MINOR_VER";\
	    fi;\
	fi;\
	test -d venv || virtualenv --python=$$PYTHON2 venv;\
	pip install -r requirements.txt;\
	touch venv;\



# # install dependencies in virtualenv
# $(VENV):
# 	@which virtualenv > /dev/null || (\
# 		echo "please install virtualenv: http://docs.python-guide.org/en/latest/dev/virtualenvs/" \
# 		&& exit 1 \
# 	)
# 	virtualenv $(VENV)
# 	$(VENV)/bin/pip install -U "pip<9.0"
# 	$(VENV)/bin/pip install pyopenssl urllib3[secure] requests[security]
# 	$(VENV)/bin/pip install -r requirements.txt --ignore-installed
# 	virtualenv --relocatable $(VENV)

# ## Clean up
# clean:
# 	rm -f .make
# 	rm -rf $(VENV)
# 	rm -rf tests/roles

# ## Prints this help
# help:
# 	@awk -v skip=1 \
# 		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
# 		skip { next } \
# 		/^#/ { doc=doc "\n" substr($$0, 2); next } \
# 		/:/ { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
# 		$(MAKEFILE_LIST)

# .mk:
# 	echo "" > .mk
