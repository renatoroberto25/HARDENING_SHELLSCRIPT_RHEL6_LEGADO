#!/usr/bin/env bash

echo "[49-51] Remediacao: bootloader e single user mode (RHEL6/OL6)"

GRUBCFG="/boot/grub/grub.conf"
SYSCONFIG_INIT="/etc/sysconfig/init"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

set_or_append_param() {
    file="$1"
    key="$2"
    value="$3"

    if grep -Eq "^[[:space:]]*${key}=" "$file" 2>/dev/null; then
        sed -ri "s|^[[:space:]]*${key}=.*|${key}=${value}|" "$file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$file"
    fi
}

echo -e "\n[49] Senha no GRUB Legacy"
if [ ! -f "$GRUBCFG" ]; then
    echo "SKIP: $GRUBCFG nao encontrado"
elif grep -Eq '^[[:space:]]*password[[:space:]]+--md5[[:space:]]+' "$GRUBCFG"; then
    echo "OK: senha do GRUB Legacy ja configurada"
elif [ -n "${GRUB_MD5_PASSWORD:-}" ]; then
    backup "$GRUBCFG"
    awk -v pass="password --md5 ${GRUB_MD5_PASSWORD}" '
        BEGIN { inserted = 0 }
        /^[[:space:]]*timeout[[:space:]]*=/ && !inserted {
            print
            print pass
            inserted = 1
            next
        }
        { print }
        END {
            if (!inserted) {
                print pass
            }
        }
    ' "$GRUBCFG" > "${GRUBCFG}.tmp" && mv "${GRUBCFG}.tmp" "$GRUBCFG"
    echo "OK: senha MD5 adicionada ao GRUB Legacy"
else
    echo "SKIP: informe GRUB_MD5_PASSWORD com hash gerado por grub-md5-crypt"
fi

echo -e "\n[50] Permissoes seguras no grub.conf"
if [ -f "$GRUBCFG" ]; then
    chown root:root "$GRUBCFG" 2>/dev/null || echo "WARN: falha ao ajustar dono de $GRUBCFG"
    chmod 600 "$GRUBCFG" 2>/dev/null && \
        echo "OK: $GRUBCFG ajustado para 600 root:root" || \
        echo "WARN: falha ao ajustar permissoes de $GRUBCFG"
else
    echo "SKIP: $GRUBCFG nao encontrado"
fi

echo -e "\n[51] Single user mode com autenticacao SysV"
if [ -f "$SYSCONFIG_INIT" ]; then
    if grep -Eq '^[[:space:]]*SINGLE=/sbin/sulogin[[:space:]]*$' "$SYSCONFIG_INIT"; then
        echo "OK: single user mode ja exige sulogin"
    else
        backup "$SYSCONFIG_INIT"
        set_or_append_param "$SYSCONFIG_INIT" "SINGLE" "/sbin/sulogin"
        echo "OK: SINGLE=/sbin/sulogin configurado"
    fi
else
    echo "SKIP: $SYSCONFIG_INIT nao encontrado"
fi

echo "OK"
exit 0
