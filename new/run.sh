#!/usr/bin/env bash

ansible-playbook -i inventory.yml playbooks/vps2.yml -u root
