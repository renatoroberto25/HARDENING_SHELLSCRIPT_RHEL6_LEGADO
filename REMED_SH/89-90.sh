#!/usr/bin/env bash

echo "[89-90] Remediacao: time sync unico e cron/at restritos (RHEL6/OL6)"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

svc_exists() {
    chkconfig --list "$1" >/dev/null 2>&1
}

disable_service() {
    svc="$1"
    if svc_exists "$svc"; then
        service "$svc" stop >/dev/null 2>&1 || true
        chkconfig "$svc" off >/dev/null 2>&1 || true
        echo "OK: $svc desabilitado"
    fi
}

echo -e "\n[89] Apenas ntpd como daemon de time sync"
disable_service chronyd
if svc_exists ntpd; then
    chkconfig ntpd on >/dev/null 2>&1 || echo "WARN: falha ao habilitar ntpd"
    service ntpd start >/dev/null 2>&1 || echo "WARN: falha ao iniciar ntpd"
    echo "OK: ntpd mantido como mecanismo de tempo"
else
    echo "WARN: ntpd nao encontrado; execute o bloco 58-60 ou instale pacote ntp"
fi

echo -e "\n[90] Cron/at seguros e restritos"
for deny in /etc/cron.deny /etc/at.deny; do
    if [ -f "$deny" ]; then
        backup "$deny"
        rm -f "$deny" 2>/dev/null || echo "WARN: falha ao remover $deny"
    fi
done

for allow in /etc/cron.allow /etc/at.allow; do
    if [ ! -f "$allow" ]; then
        printf 'root\n' > "$allow" 2>/dev/null || echo "WARN: falha ao criar $allow"
    else
        backup "$allow"
        grep -qx 'root' "$allow" 2>/dev/null || printf 'root\n' >> "$allow"
    fi
    chown root:root "$allow" 2>/dev/null || true
    chmod 640 "$allow" 2>/dev/null || true
    echo "OK: $allow restrito"
done

echo "OK"
exit 0
