#!/usr/bin/env bash

# This script does a few basic smoke tests to ensure the servers haven't completely died.

set -eux

# Check DNS name servers
dig @dns1.infra.noratrieb.dev dns1.infra.noratrieb.dev +noall +answer | grep 154.38.163.74
dig @dns2.infra.noratrieb.dev dns1.infra.noratrieb.dev +noall +answer | grep 154.38.163.74

dig @dns1.infra.noratrieb.dev nilstrieb.dev +noall +answer | grep 185.199.108.153
dig @dns2.infra.noratrieb.dev nilstrieb.dev +noall +answer | grep 185.199.108.153

# Check HTTP responses
curl --fail https://vps1.infra.noratrieb.dev
