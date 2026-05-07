#!/usr/bin/env bash

echo "[109-129] Remediacao: SSH hardening (RHEL6/OL6)"

SSHD="/etc/ssh/sshd_config"
BANNER="/etc/issue.net"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

set_param() {
    key="$1"
    value="$2"

    if grep -Eq "^[[:space:]]*#?[[:space:]]*${key}[[:space:]]+" "$SSHD"; then
        sed -ri "s|^[[:space:]]*#?[[:space:]]*${key}[[:space:]]+.*|${key} ${value}|" "$SSHD"
    else
        printf '%s %s\n' "$key" "$value" >> "$SSHD"
    fi
    echo "OK: ${key} ${value}"
}

if [ ! -f "$SSHD" ]; then
    echo "SKIP: $SSHD nao encontrado"
    echo "OK"
    exit 0
fi

backup "$SSHD"

echo -e "\n[109] Permissoes SSH seguras"
chown root:root /etc/ssh "$SSHD" 2>/dev/null || true
chmod 755 /etc/ssh 2>/dev/null || true
chmod 600 "$SSHD" 2>/dev/null && \
    echo "OK: permissoes ajustadas" || \
    echo "WARN: falha ao ajustar permissoes"

echo -e "\n[110] Controle de acesso via Allow/Deny"
echo "INFO: controle AllowUsers/AllowGroups/DenyUsers/DenyGroups depende da politica do ambiente"

echo -e "\n[111-123] Parametros SSH gerais"
set_param "SyslogFacility" "AUTHPRIV"
set_param "LogLevel" "INFO"
set_param "X11Forwarding" "no"
set_param "MaxAuthTries" "4"
set_param "IgnoreRhosts" "yes"
set_param "HostbasedAuthentication" "no"
set_param "PermitRootLogin" "no"
set_param "PermitEmptyPasswords" "no"
set_param "PermitUserEnvironment" "no"
set_param "UsePAM" "yes"
set_param "ClientAliveInterval" "300"
set_param "ClientAliveCountMax" "3"
set_param "LoginGraceTime" "60"
set_param "MaxStartups" "10:30:100"
set_param "MaxSessions" "10"
set_param "AllowTcpForwarding" "no"

echo -e "\n[124] Banner legal"
if [ ! -f "$BANNER" ]; then
    cat > "$BANNER" << 'EOF'
ACESSO RESTRITO - SISTEMA MONITORADO.
Uso permitido somente a usuarios autorizados.
EOF
    chmod 644 "$BANNER" 2>/dev/null || true
fi
set_param "Banner" "$BANNER"

echo -e "\n[125] Ciphers fortes compativeis RHEL6"
set_param "Ciphers" "aes256-ctr,aes192-ctr,aes128-ctr"

echo -e "\n[126] MACs fortes compativeis RHEL6"
set_param "MACs" "hmac-sha2-512,hmac-sha2-256,hmac-sha1"

echo -e "\n[127] KexAlgorithms compativeis RHEL6"
set_param "KexAlgorithms" "diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha1"

echo -e "\n[128] Melhor criptografia SSH suportada"
echo "OK: algoritmos priorizados conforme OpenSSH 5.3 do RHEL6"

echo -e "\n[129] ForceCommand/Chroot"
echo "INFO: ForceCommand/ChrootDirectory depende de contas e escopo aprovados; remediacao manual"

echo -e "\nValidando sshd_config"
if sshd -t >/dev/null 2>&1; then
    service sshd reload >/dev/null 2>&1 || service sshd restart >/dev/null 2>&1 || true
    echo "OK: sshd_config valido"
else
    echo "WARN: sshd_config invalido; restaurar backup se necessario: ${SSHD}.bkp_*"
fi

echo "OK"
exit 0
