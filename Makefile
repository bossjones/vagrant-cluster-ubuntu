
SHELL=/bin/bash
ELASTIC_REGISTRY ?= docker.elastic.co

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
