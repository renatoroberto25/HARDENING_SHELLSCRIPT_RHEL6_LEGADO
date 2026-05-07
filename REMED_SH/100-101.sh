#!/usr/bin/env bash
echo "[100-101] Remediação: ICMP timestamp"

if systemctl is-active firewalld &>/dev/null; then
    firewall-cmd --direct --add-rule ipv4 filter INPUT 0 -p icmp --icmp-type timestamp-request -j DROP &>/dev/null || true
    firewall-cmd --direct --add-rule ipv4 filter INPUT 0 -p icmp --icmp-type timestamp-reply -j DROP &>/dev/null || true
    firewall-cmd --runtime-to-permanent &>/dev/null
elif command -v nft &>/dev/null; then
    nft add rule inet filter input icmp type timestamp-request drop 2>/dev/null || true
    nft add rule inet filter input icmp type timestamp-reply drop 2>/dev/null || true
elif command -v iptables &>/dev/null; then
    iptables -C INPUT -p icmp --icmp-type timestamp-request -j DROP 2>/dev/null || iptables -A INPUT -p icmp --icmp-type timestamp-request -j DROP
    iptables -C INPUT -p icmp --icmp-type timestamp-reply -j DROP 2>/dev/null || iptables -A INPUT -p icmp --icmp-type timestamp-reply -j DROP
fi

echo "OK"
exit 0
