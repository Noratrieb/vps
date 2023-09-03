#!/usr/bin/env bash

ansible-playbook -i playbooks/inventory.yml playbooks/all.yml -u root
