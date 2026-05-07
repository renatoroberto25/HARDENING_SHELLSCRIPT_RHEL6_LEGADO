#!/usr/bin/env bash
set -euo pipefail
TS="$(date +%Y%m%d_%H%M%S)"

echo "[185-194] Remediacao - permissoes de arquivos sensiveis"

backup_file() {
    local f="$1"
    [ -f "$f" ] && cp -a "$f" "${f}.bkp-${TS}"
}

fix_file() {
    local lbl="$1"
    local file="$2"
    local mode="$3"
    local owner="$4"
    local group="$5"

    echo -e "\n[$lbl] Remediando $file"

    [ -f "$file" ] || { echo "SKIP: $file ausente"; return 0; }

    backup_file "$file"

    local cur_mode cur_owner cur_group
    cur_mode="$(stat -Lc '%a' "$file" 2>/dev/null || echo "")"
    cur_owner="$(stat -Lc '%u' "$file" 2>/dev/null || echo "")"
    cur_group="$(stat -Lc '%g' "$file" 2>/dev/null || echo "")"

    # altera só quando necessário
    [ "$cur_mode"  != "$mode" ]  && chmod "$mode"  "$file"
    [ "$cur_owner" -ne "$owner" ] && chown "$owner" "$file"
    [ "$cur_group" -ne "$group" ] && chgrp "$group" "$file"

    command -v restorecon &>/dev/null && restorecon "$file" &>/dev/null || true

    echo "OK: $file ajustado"
}

fix_file 185 /etc/passwd       644 0 0
fix_file 186 /etc/passwd-      644 0 0
fix_file 187 /etc/shadow       000 0 0
fix_file 188 /etc/shadow-      000 0 0
fix_file 189 /etc/gshadow-     600 0 0
fix_file 190 /etc/gshadow      600 0 0
fix_file 191 /etc/group        644 0 0
fix_file 192 /etc/group-       644 0 0

echo -e "\n[193] Garantir /sbin/nologin em /etc/shells"
touch /etc/shells
backup_file /etc/shells
if grep -Eq '^(\/usr)?\/sbin\/nologin$' /etc/shells; then
    echo "OK: nologin ja presente"
else
    echo "/sbin/nologin" >> /etc/shells
    echo "OK: /sbin/nologin adicionado"
fi

echo -e "\n[194] Remediando /etc/security/opasswd"
touch /etc/security/opasswd
fix_file 194 /etc/security/opasswd 600 0 0

echo
echo "OK: Remediacao 185-194 finalizada"

echo "OK"
exit 0
