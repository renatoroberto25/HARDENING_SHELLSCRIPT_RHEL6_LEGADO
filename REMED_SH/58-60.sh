#!/usr/bin/env bash

echo "[58-60] Remediacao: sincronizacao de tempo ntpd (RHEL6/OL6)"

NTP_CONF="/etc/ntp.conf"
NTP_SERVER="${NTP_SERVER:-pool.ntp.org}"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

pkg_installed() {
    rpm -q "$1" >/dev/null 2>&1
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

echo -e "\n[58] ntpd ativo"
if ! pkg_installed ntp; then
    yum install -y ntp >/dev/null 2>&1 && \
        echo "OK: pacote ntp instalado" || \
        echo "WARN: falha ao instalar ntp"
fi

disable_service chronyd

if svc_exists ntpd; then
    service ntpd start >/dev/null 2>&1 && \
        echo "OK: ntpd iniciado" || \
        echo "WARN: falha ao iniciar ntpd"
else
    echo "WARN: servico ntpd nao encontrado"
fi

echo -e "\n[59] Fontes NTP confiaveis"
if [ -f "$NTP_CONF" ]; then
    backup "$NTP_CONF"
    if grep -Eq '^[[:space:]]*(server|pool)[[:space:]]+' "$NTP_CONF"; then
        echo "OK: $NTP_CONF ja possui fonte de tempo"
    else
        printf 'server %s iburst\n' "$NTP_SERVER" >> "$NTP_CONF"
        echo "OK: fonte NTP adicionada em $NTP_CONF"
    fi
else
    printf 'server %s iburst\n' "$NTP_SERVER" > "$NTP_CONF" 2>/dev/null && \
        echo "OK: $NTP_CONF criado" || \
        echo "WARN: falha ao criar $NTP_CONF"
fi

echo -e "\n[60] ntpd no boot"
if svc_exists ntpd; then
    chkconfig ntpd on >/dev/null 2>&1 && \
        echo "OK: ntpd habilitado no boot" || \
        echo "WARN: falha ao habilitar ntpd no boot"
else
    echo "WARN: servico ntpd nao encontrado"
fi

echo "OK"
exit 0
