#!/usr/bin/env bash

ansible-playbook -i inventory.yml playbooks/basic-setup.yml -u root
