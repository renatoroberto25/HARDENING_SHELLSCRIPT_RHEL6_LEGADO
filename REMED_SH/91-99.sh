#!/usr/bin/env bash

echo "[91-99] Remediacao: hardening de rede via sysctl (RHEL6/OL6)"

SYSCTL="/etc/sysctl.conf"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

set_sysctl() {
    key="$1"
    val="$2"

    if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$SYSCTL" 2>/dev/null; then
        sed -ri "s|^[[:space:]]*${key}[[:space:]]*=.*|${key} = ${val}|" "$SYSCTL"
    else
        printf '%s = %s\n' "$key" "$val" >> "$SYSCTL"
    fi

    sysctl -w "$key=$val" >/dev/null 2>&1 || true
    echo "OK: $key = $val"
}

[ -f "$SYSCTL" ] || touch "$SYSCTL" 2>/dev/null
backup "$SYSCTL"

echo -e "\n[91] IP forwarding desabilitado"
set_sysctl net.ipv4.ip_forward 0
set_sysctl net.ipv6.conf.all.forwarding 0

echo -e "\n[92] Redirecionamentos de pacotes desabilitados"
set_sysctl net.ipv4.conf.all.send_redirects 0
set_sysctl net.ipv4.conf.default.send_redirects 0

echo -e "\n[93] Source-routed packets bloqueados"
set_sysctl net.ipv4.conf.all.accept_source_route 0
set_sysctl net.ipv4.conf.default.accept_source_route 0

echo -e "\n[94] ICMP redirects bloqueados"
set_sysctl net.ipv4.conf.all.accept_redirects 0
set_sysctl net.ipv4.conf.default.accept_redirects 0
set_sysctl net.ipv4.conf.all.secure_redirects 0
set_sysctl net.ipv4.conf.default.secure_redirects 0

echo -e "\n[95] Reverse path filtering habilitado"
set_sysctl net.ipv4.conf.all.rp_filter 1
set_sysctl net.ipv4.conf.default.rp_filter 1

echo -e "\n[96] ICMP broadcast ignorado"
set_sysctl net.ipv4.icmp_echo_ignore_broadcasts 1

echo -e "\n[97] Respostas ICMP invalidas ignoradas"
set_sysctl net.ipv4.icmp_ignore_bogus_error_responses 1

echo -e "\n[98] TCP SYN cookies habilitados"
set_sysctl net.ipv4.tcp_syncookies 1

echo -e "\n[99] IPv6 desabilitado ou endurecido"
set_sysctl net.ipv6.conf.all.disable_ipv6 1
set_sysctl net.ipv6.conf.default.disable_ipv6 1

echo "OK"
exit 0
