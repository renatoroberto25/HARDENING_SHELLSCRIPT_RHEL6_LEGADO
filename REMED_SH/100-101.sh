#!/usr/bin/env bash

echo "[100-101] Remediacao: ICMP timestamp via iptables (RHEL6/OL6)"

add_rule() {
    icmp_type="$1"

    if ! command -v iptables >/dev/null 2>&1; then
        echo "SKIP: iptables nao encontrado"
        return
    fi

    iptables -C INPUT -p icmp --icmp-type "$icmp_type" -j DROP 2>/dev/null || \
        iptables -A INPUT -p icmp --icmp-type "$icmp_type" -j DROP
    echo "OK: DROP para ICMP $icmp_type"
}

echo -e "\n[100] ICMP timestamp-request drop"
add_rule timestamp-request

echo -e "\n[101] ICMP timestamp-reply drop"
add_rule timestamp-reply

if command -v service >/dev/null 2>&1; then
    service iptables save >/dev/null 2>&1 || echo "INFO: regra aplicada em runtime; persistencia pode exigir service iptables save"
fi

echo "OK"
exit 0
