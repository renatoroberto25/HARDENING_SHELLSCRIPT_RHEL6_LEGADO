#!/usr/bin/env bash

echo "[87-88] Remediacao: yum gpgcheck e patches (RHEL6/OL6)"

YUMCONF="/etc/yum.conf"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

set_key() {
    file="$1"
    key="$2"
    value="$3"

    [ -f "$file" ] || return 1

    if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$file"; then
        sed -ri "s|^[[:space:]]*${key}[[:space:]]*=.*|${key}=${value}|" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

echo -e "\n[87] Assinaturas de pacotes habilitadas"
if [ -f "$YUMCONF" ]; then
    backup "$YUMCONF"
    set_key "$YUMCONF" gpgcheck 1
    set_key "$YUMCONF" localpkg_gpgcheck 1
    echo "OK: yum.conf ajustado"
else
    echo "SKIP: $YUMCONF nao encontrado"
fi

for repo in /etc/yum.repos.d/*.repo; do
    [ -f "$repo" ] || continue
    backup "$repo"
    set_key "$repo" gpgcheck 1 && echo "OK: gpgcheck habilitado em $repo"
done

echo -e "\n[88] Patches de seguranca aplicados"
if command -v yum >/dev/null 2>&1; then
    yum -y update --security >/dev/null 2>&1 && \
        echo "OK: yum update --security executado" || \
        echo "INFO: yum update --security nao aplicado; pode exigir repos/plugin yum-security ou janela manual"
else
    echo "SKIP: yum nao encontrado"
fi

echo "OK"
exit 0
