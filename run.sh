#!/usr/bin/env bash

ansible-playbook -i inventory.yml playbooks/all.yml -u root
