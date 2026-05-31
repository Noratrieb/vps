#!/usr/bin/env bash

# This script does a few basic smoke tests to ensure the servers haven't completely died.

set -eux

check_single_dig_answer() {
    dns="$1"
    type="$2"
    host="$3"
    grep="$4"

    dig "@$dns.infra.noratrieb.dev" "$type" "$host" +noall +answer | grep "$grep"
}

check_dig_answer() {
    type="$1"
    host="$2"
    grep="$3"

    check_single_dig_answer "dns1" "$type" "$host" "$grep"
    check_single_dig_answer "dns2" "$type" "$host" "$grep"
}

# Check DNS name servers
check_dig_answer A "dns1.infra.noratrieb.dev" "154.38.163.74"

check_single_dig_answer "dns1" A "nilstrieb.dev" "161.97.165.1"

# Check the NS records. The trailing dot matters!
check_dig_answer NS noratrieb.dev "noratrieb.dev..*3600.*IN.*NS.*ns1.noratrieb.dev."

# Mail stuff
check_dig_answer MX noratrieb.dev "mail.tutanota.de."
check_dig_answer TXT noratrieb.dev "t-verify=dae826f2ae9f73a71cc247183616b6c9"
check_dig_answer TXT noratrieb.dev "v=spf1 include:spf.tutanota.de -all"

# Check HTTP responses
http_hosts=(
    noratrieb.dev
    nilstrieb.dev
    vps1.infra.noratrieb.dev
    vps3.infra.noratrieb.dev
    vps4.infra.noratrieb.dev
    vps5.infra.noratrieb.dev
    docker.noratrieb.dev
    does-it-build.noratrieb.dev
    grafana.noratrieb.dev
    hugo-chat.noratrieb.dev
    api.hugo-chat.noratrieb.dev/api/v2/rooms
    www.noratrieb.dev

    # legacy:
    blog.noratrieb.dev
)

for http_host in "${http_hosts[@]}"; do
    curl --fail -s "https://${http_host}/" -o /dev/null
done
