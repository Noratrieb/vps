#!/usr/bin/env bash

# This script does a few basic smoke tests to ensure the servers haven't completely died.

set -eux

# Check DNS name servers
dig @dns1.infra.noratrieb.dev dns1.infra.noratrieb.dev +noall +answer | grep 154.38.163.74
dig @dns2.infra.noratrieb.dev dns1.infra.noratrieb.dev +noall +answer | grep 154.38.163.74

dig @dns1.infra.noratrieb.dev nilstrieb.dev +noall +answer | grep 161.97.165.1
dig @dns2.infra.noratrieb.dev nilstrieb.dev +noall +answer | grep 161.97.165.1

# Check the NS records. The trailing dot matters!
dig @dns1.infra.noratrieb.dev NS noratrieb.dev | grep "noratrieb.dev..*3600.*IN.*NS.*ns1.noratrieb.dev."
dig @dns2.infra.noratrieb.dev NS noratrieb.dev | grep "noratrieb.dev..*3600.*IN.*NS.*ns1.noratrieb.dev."

# Check HTTP responses
curl --fail -s https://vps1.infra.noratrieb.dev -o /dev/null
curl --fail -s https://vps3.infra.noratrieb.dev -o /dev/null
curl --fail -s https://vps4.infra.noratrieb.dev -o /dev/null
curl --fail -s https://vps5.infra.noratrieb.dev -o /dev/null
curl --fail -s https://noratrieb.dev -o /dev/null
