#!/usr/bin/env bash

set -u

backup_file() {
    [ -f "$1" ] && cp "$1" "$1.bak_$(date +%F-%H%M%S)"
}

ensure_line() {
    file="$1"
    line="$2"
    grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

echo "=== Iniciando remediacao HITSS 148-160 (RHEL6/OL6) ==="

########################################
# 148 - root unico UID 0
########################################
echo -e "\n[148] root unico UID 0"
UID0_USERS=$(awk -F: '($3==0 && $1!="root"){print $1}' /etc/passwd)
if [ -n "$UID0_USERS" ]; then
    echo "WARN: usuarios com UID 0 encontrados: $UID0_USERS"
    echo "INFO: correcao automatica nao aplicada; revisar manualmente para nao quebrar ownership/permissoes."
else
    echo "OK: somente root possui UID 0"
fi

########################################
# 149 - root unico grupo GID 0
########################################
echo -e "\n[149] root unico grupo GID 0"
GID0_GROUPS=$(awk -F: '($3==0 && $1!="root"){print $1}' /etc/group)
if [ -n "$GID0_GROUPS" ]; then
    echo "WARN: grupos com GID 0 encontrados: $GID0_GROUPS"
    echo "INFO: correcao automatica nao aplicada; revisar /etc/group manualmente."
else
    echo "OK: somente grupo root possui GID 0"
fi

########################################
# 150 - Contas de sistema sem shell interativo
########################################
echo -e "\n[150] travar contas de sistema com shell interativo (UID < 500)"
backup_file /etc/passwd
FOUND_SYSTEM_SHELL=0
for u in $(awk -F: '($3<500 && $1!="root" && $7 ~ /(bash|sh|zsh)$/){print $1}' /etc/passwd); do
    FOUND_SYSTEM_SHELL=1
    echo "INFO: trocando shell para /sbin/nologin: $u"
    usermod -s /sbin/nologin "$u"
done
if [ "$FOUND_SYSTEM_SHELL" -eq 0 ]; then
    echo "OK: nenhuma conta de sistema interativa encontrada"
else
    echo "OK: contas de sistema interativas convertidas para nologin"
fi

########################################
# 151 - /sbin/nologin em /etc/shells
########################################
echo -e "\n[151] garantir /sbin/nologin em /etc/shells"
backup_file /etc/shells
ensure_line /etc/shells "/sbin/nologin"
echo "OK: /sbin/nologin presente em /etc/shells"

########################################
# 152 - PATH do root
########################################
echo -e "\n[152] ajustando PATH do root"
SAFE_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

backup_file /root/.bash_profile
touch /root/.bash_profile
if grep -q '^PATH=' /root/.bash_profile; then
    sed -i "s|^PATH=.*|PATH=$SAFE_PATH|" /root/.bash_profile
else
    echo "PATH=$SAFE_PATH" >> /root/.bash_profile
fi
echo "OK: PATH do root ajustado"

########################################
# 153 - umask 027
########################################
echo -e "\n[153] configurando umask"
FILE="/etc/profile.d/hardening.sh"
backup_file "$FILE"
touch "$FILE"
grep -q '^umask' "$FILE" 2>/dev/null && \
sed -ri 's/^umask.*/umask 027/' "$FILE" || \
echo "umask 027" >> "$FILE"
chmod 644 "$FILE"
echo "OK: umask 027 configurado"

########################################
# 154 - TMOUT 900
########################################
echo -e "\n[154] configurando TMOUT"
backup_file "$FILE"
grep -q '^TMOUT=' "$FILE" 2>/dev/null && \
sed -ri 's/^TMOUT=.*/TMOUT=900/' "$FILE" || \
echo "TMOUT=900" >> "$FILE"
grep -q '^readonly TMOUT' "$FILE" || echo "readonly TMOUT" >> "$FILE"
grep -q '^export TMOUT' "$FILE" || echo "export TMOUT" >> "$FILE"
chmod 644 "$FILE"
echo "OK: TMOUT 900 configurado"

########################################
# 155-159 - Ajustes de sudoers
########################################
SUDO_HARD="/etc/sudoers.d/hardening-hitss"
backup_file "$SUDO_HARD"

echo -e "\n[155-159] aplicando ajustes de sudo em arquivo dedicado"
if grep -RqsE '^%.*ALL=\(ALL\)' /etc/sudoers /etc/sudoers.d 2>/dev/null; then
    echo "WARN: existe regra ampla de grupo no sudoers; revisar manualmente antes de remover."
else
    echo "OK: nenhuma regra ampla de grupo sudo encontrada"
fi

if grep -Rqs '!authenticate' /etc/sudoers /etc/sudoers.d 2>/dev/null; then
    echo "WARN: existe regra !authenticate no sudoers; revisar manualmente antes de remover."
else
    echo "OK: nenhuma regra !authenticate encontrada"
fi

cat > "$SUDO_HARD" <<EOF
# Arquivo de hardening HITSS - RHEL6/OL6

# [156] sudo usa terminal real no RHEL6.
Defaults requiretty

# [157] log dedicado para sudo.
Defaults logfile="/var/log/sudo.log"

# [159] timeout do timestamp sudo.
Defaults timestamp_timeout=5
EOF

chmod 440 "$SUDO_HARD"

if visudo -cf "$SUDO_HARD" >/dev/null 2>&1; then
    touch /var/log/sudo.log
    chmod 600 /var/log/sudo.log
    echo "OK: sudoers.d/hardening-hitss criado com sucesso"
else
    echo "WARN: erro de sintaxe no sudoers dedicado; revisar $SUDO_HARD"
fi

########################################
# 160 - su restrito ao grupo wheel
########################################
echo -e "\n[160] restringindo su ao grupo wheel"

if ! grep -Eq '^auth\s+(required|requisite)\s+pam_wheel\.so' /etc/pam.d/su; then
    backup_file /etc/pam.d/su
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su
    echo "OK: pam_wheel ativado"
else
    echo "OK: pam_wheel ja configurado"
fi

echo "=== Remediacao 148-160 concluida ==="
exit 0
