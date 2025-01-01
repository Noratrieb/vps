#!/usr/bin/env bash

# This script does a few basic smoke tests to ensure the servers haven't completely died.

set -eux

check_dig_answer() {
    type="$1"
    host="$2"
    grep="$3"

    dig @dns1.infra.noratrieb.dev "$type" "$host" +noall +answer | grep "$grep"
    dig @dns2.infra.noratrieb.dev "$type" "$host" +noall +answer | grep "$grep"

}

# Check DNS name servers
check_dig_answer A "dns1.infra.noratrieb.dev" "154.38.163.74"

check_dig_answer A "nilstrieb.dev" "161.97.165.1"

# Check the NS records. The trailing dot matters!
check_dig_answer NS noratrieb.dev "noratrieb.dev..*3600.*IN.*NS.*ns1.noratrieb.dev."

# Mail stuff
check_dig_answer MX noratrieb.dev "mail.protonmail.ch."
check_dig_answer MX noratrieb.dev "mailsec.protonmail.ch."
check_dig_answer TXT noratrieb.dev "protonmail-verification=09106d260e40df267109be219d9c7b2759e808b5"
check_dig_answer TXT noratrieb.dev "v=spf1 include:_spf.protonmail.ch ~all"

# Check HTTP responses
http_hosts=(
    noratrieb.dev
    nilstrieb.dev
    vps1.infra.noratrieb.dev
    vps3.infra.noratrieb.dev
    vps4.infra.noratrieb.dev
    vps5.infra.noratrieb.dev
    bisect-rustc.noratrieb.dev
    docker.noratrieb.dev
    does-it-build.noratrieb.dev
    grafana.noratrieb.dev
    hugo-chat.noratrieb.dev
    api.hugo-chat.noratrieb.dev/api/v2/rooms
    uptime.noratrieb.dev
    www.noratrieb.dev

    # legacy:
    blog.noratrieb.dev
)

for http_host in "${http_hosts[@]}"; do
    curl --fail -s "https://${http_host}/" -o /dev/null
done
