#!/usr/bin/env bash

echo "[52-57] Remediacao: MAC, prelink e xinetd (RHEL6/OL6)"

SELINUX_CONFIG="/etc/selinux/config"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

set_config_key() {
    file="$1"
    key="$2"
    value="$3"

    [ -f "$file" ] || return 1

    if grep -Eq "^[[:space:]]*${key}=" "$file"; then
        sed -ri "s|^[[:space:]]*${key}=.*|${key}=${value}|" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

pkg_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

remove_pkg() {
    pkg="$1"

    if ! pkg_installed "$pkg"; then
        echo "OK: $pkg nao instalado"
        return
    fi

    yum remove -y "$pkg" >/dev/null 2>&1 && \
        echo "OK: $pkg removido" || \
        echo "WARN: falha ao remover $pkg"
}

svc_exists() {
    chkconfig --list "$1" >/dev/null 2>&1
}

disable_service() {
    svc="$1"

    if svc_exists "$svc"; then
        service "$svc" stop >/dev/null 2>&1 || true
        chkconfig "$svc" off >/dev/null 2>&1 || true
    fi
}

echo -e "\n[52] MAC SELinux ativo"
if [ -f "$SELINUX_CONFIG" ]; then
    backup "$SELINUX_CONFIG"
    set_config_key "$SELINUX_CONFIG" "SELINUX" "enforcing" && \
        echo "OK: SELINUX=enforcing configurado" || \
        echo "WARN: falha ao ajustar $SELINUX_CONFIG"

    echo "INFO: nao aplicado setenforce 1 em runtime; em RHEL6/OL6 legado, validar labels e usar reboot/relabel quando necessario"
else
    echo "SKIP: $SELINUX_CONFIG nao encontrado"
fi

echo -e "\n[53] Politica MAC definida"
if [ -f "$SELINUX_CONFIG" ]; then
    backup "$SELINUX_CONFIG"
    set_config_key "$SELINUX_CONFIG" "SELINUXTYPE" "targeted" && \
        echo "OK: SELINUXTYPE=targeted configurado" || \
        echo "WARN: falha ao ajustar $SELINUX_CONFIG"
else
    echo "SKIP: $SELINUX_CONFIG nao encontrado"
fi

echo -e "\n[54] Servicos unconfined_service_t"
echo "INFO: remediacao depende do servico especifico; revisar saida do audit e aplicar politica SELinux apropriada"

echo -e "\n[55] Processos unconfined_t"
echo "INFO: remediacao depende do processo especifico; revisar saida do audit e aplicar politica SELinux apropriada"

echo -e "\n[56] Prelink removido"
if pkg_installed prelink; then
    if command -v prelink >/dev/null 2>&1; then
        prelink -ua >/dev/null 2>&1 || echo "WARN: falha ao desfazer prelink; seguindo com remocao do pacote"
    fi
    remove_pkg prelink
else
    echo "OK: prelink nao instalado"
fi

echo -e "\n[57] xinetd removido"
if pkg_installed xinetd; then
    disable_service xinetd
    remove_pkg xinetd
else
    echo "OK: xinetd nao instalado"
fi

echo "OK"
exit 0
