#!/usr/bin/env bash
echo "[103-107] Remediação: Firewall (firewalld)"
systemctl enable firewalld >/dev/null 2>&1
systemctl start firewalld >/dev/null 2>&1
OK=0
for i in 1 2 3 4 5 6 7 8 9 10; do
    if firewall-cmd --state >/dev/null 2>&1; then
        OK=1
        break
    fi
    sleep 1
done
if [ "$OK" -eq 0 ]; then
    echo "⚠️ firewalld não ficou pronto em até 10 segundos"
    exit 0
fi
ZONE=$(firewall-cmd --get-default-zone 2>/dev/null)
if [ -n "$ZONE" ]; then
    firewall-cmd --permanent --zone="$ZONE" --set-target=default >/dev/null 2>&1
fi
systemctl disable nftables >/dev/null 2>&1
systemctl stop nftables >/dev/null 2>&1
firewall-cmd --reload >/dev/null 2>&1
echo "OK"
exit 0
