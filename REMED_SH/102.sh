#!/usr/bin/env bash

echo "[102] Remediacao: desabilitar Wireless/Bluetooth (RHEL6/OL6)"

MODFILE="/etc/modprobe.d/hardening-wireless.conf"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

backup "$MODFILE"

for module in bluetooth iwlwifi; do
    if lsmod | grep -q "^${module}[[:space:]]"; then
        modprobe -r "$module" >/dev/null 2>&1 && \
            echo "OK: modulo removido: $module" || \
            echo "WARN: falha ao remover modulo carregado: $module"
    else
        echo "OK: modulo nao carregado: $module"
    fi
done

{
    echo "blacklist bluetooth"
    echo "install bluetooth /bin/true"
    echo "blacklist iwlwifi"
    echo "install iwlwifi /bin/true"
} > "$MODFILE"

echo "OK: blacklist persistente em $MODFILE"
echo "OK"
exit 0
