#!/usr/bin/env bash
set -euo pipefail
TS="$(date +%Y%m%d_%H%M%S)"

echo "[195-203] Remediacao - seguranca de homes e arquivos especiais"

backup_file() {
    local f="$1"
    [ -f "$f" ] && cp -a "$f" "${f}.bkp-${TS}"
}

usuarios() {
    awk -F: '$3>=500 && $1!="nfsnobody"{print $1,$6}' /etc/passwd
}

echo -e "\n[195] Corrigir arquivos órfãos (nouser/nogroup)"
orphans=$(find / -xdev \( -nouser -o -nogroup \) 2>/dev/null || true)
if [ -n "${orphans}" ]; then
    while read -r f; do
        chown 0:0 "$f" 2>/dev/null || true
    done <<< "$orphans"
    echo "OK: ownership ajustado"
else
    echo "OK: nenhum arquivo orfao encontrado"
fi

echo -e "\n[196] Remover world-writable fora das áreas permitidas"
/usr/bin/find / -xdev \
    -not -path "/tmp/*" \
    -not -path "/var/tmp/*" \
    -not -path "/dev/shm/*" \
    -perm -0002 2>/dev/null |
while read -r f; do
    chmod o-w "$f" 2>/dev/null || true
done
echo "OK: permissoes ajustadas"

echo -e "\n[198] Listar SUID/SGID fora da whitelist"

WHITELIST=(
    /usr/bin/sudo
    /usr/bin/su
    /bin/su
    /usr/bin/passwd
    /usr/bin/chage
    /usr/bin/chsh
    /usr/bin/chfn
    /usr/bin/newgrp
    /usr/bin/gpasswd
    /usr/sbin/unix_chkpwd
    /sbin/unix_chkpwd
    /usr/sbin/pam_timestamp_check
    /usr/bin/mount
    /bin/mount
    /usr/bin/umount
    /bin/umount
    /usr/bin/fusermount
    /usr/bin/pkexec
    /usr/bin/crontab
    /usr/bin/ssh-agent
    /usr/bin/ksu
    /usr/libexec/openssh/ssh-keysign
    /usr/bin/ping
    /bin/ping
    /usr/bin/ping6
    /bin/ping6
    /usr/bin/traceroute
    /bin/traceroute
    /usr/bin/traceroute6
    /bin/traceroute6
)

is_whitelisted() {
    local file="$1"
    for w in "${WHITELIST[@]}"; do
        [[ "$file" == "$w" ]] && return 0
    done
    return 1
}

find / -xdev \( -perm -4000 -o -perm -2000 \) 2>/dev/null |
while read -r f; do
    if is_whitelisted "$f"; then
        :
    else
        echo "WARN: revisar SUID/SGID manualmente: $f"
    fi
done
echo "INFO: bits SUID/SGID nao removidos automaticamente"

echo -e "\n[199-201] Ajustar homes dos usuarios"
usuarios | while read -r user home; do
    if [ -z "$home" ] || [ "$home" = "/" ]; then
        echo "WARN: home invalida para $user: $home"
        continue
    fi

    if [ ! -d "$home" ]; then
        mkdir -p "$home"
        chown "$user":"$user" "$home" 2>/dev/null || chown "$user" "$home" 2>/dev/null || true
        chmod 750 "$home"
        echo "OK: home criada para $user: $home"
        continue
    fi

    chown "$user" "$home" 2>/dev/null || true
    chmod go-rwx "$home" 2>/dev/null || true
    chmod u+rwx "$home" 2>/dev/null || true
    echo "OK: home ajustada para $user: $home"
done

echo -e "\n[202] Corrigir dotfiles inseguros"
while read -r user home; do
    [ -d "$home" ] || continue
    find "$home" -maxdepth 1 -type f -name ".*" -perm /022 2>/dev/null |
    while read -r f; do
        chmod go-w "$f" 2>/dev/null || true
    done
done < <(usuarios)
echo "OK: dotfiles corrigidos"

echo -e "\n[203] Remover .forward/.netrc/.rhosts"
while read -r user home; do
    [ -d "$home" ] || continue
    for f in "$home/.forward" "$home/.netrc" "$home/.rhosts"; do
        if [ -f "$f" ]; then
            backup_file "$f"
            rm -f "$f"
        fi
    done
done < <(usuarios)
echo "OK: arquivos sensiveis removidos quando encontrados"

echo "OK"

exit 0
