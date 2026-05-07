#!/usr/bin/env bash

echo "[130-147] Remediacao: senhas e contas PAM (RHEL6/OL6)"

PAM_FILES="/etc/pam.d/system-auth /etc/pam.d/password-auth"
LOGIN_DEFS="/etc/login.defs"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

ensure_pam_line() {
    file="$1"
    match="$2"
    line="$3"
    anchor="$4"

    [ -f "$file" ] || return

    if grep -Eq "$match" "$file"; then
        sed -ri "s|^.*${match}.*|${line}|" "$file"
    elif grep -Eq "$anchor" "$file"; then
        sed -ri "/${anchor}/i ${line}" "$file"
    else
        printf '%s\n' "$line" >> "$file"
    fi
}

set_login_def() {
    key="$1"
    value="$2"

    if grep -Eq "^[[:space:]]*${key}[[:space:]]+" "$LOGIN_DEFS"; then
        sed -ri "s|^[[:space:]]*${key}[[:space:]]+.*|${key}   ${value}|" "$LOGIN_DEFS"
    else
        printf '%s   %s\n' "$key" "$value" >> "$LOGIN_DEFS"
    fi
}

CRACKLIB_LINE="password    requisite     pam_cracklib.so retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1 maxrepeat=3"
TALLY_LINE="auth        required      pam_tally2.so deny=5 unlock_time=900 onerr=fail audit"

echo -e "\n[130-138] pam_cracklib"
for file in $PAM_FILES; do
    [ -f "$file" ] || continue
    backup "$file"
    ensure_pam_line "$file" "pam_cracklib\\.so" "$CRACKLIB_LINE" "pam_unix\\.so"
    echo "OK: pam_cracklib configurado em $file"
done

echo -e "\n[132-133/141-142] pam_tally2"
for file in $PAM_FILES; do
    [ -f "$file" ] || continue
    backup "$file"
    ensure_pam_line "$file" "pam_tally2\\.so" "$TALLY_LINE" "pam_unix\\.so"
    echo "OK: pam_tally2 configurado em $file"
done

echo -e "\n[134/140] Historico via pam_unix remember"
for file in $PAM_FILES; do
    [ -f "$file" ] || continue
    backup "$file"
    if grep -Eq 'pam_unix\.so' "$file"; then
        if grep -Eq 'pam_unix\.so.*remember=' "$file"; then
            sed -ri 's/(pam_unix\.so.*)remember=[0-9]+/\1remember=5/' "$file"
        else
            sed -ri '/pam_unix\.so/ s/$/ remember=5/' "$file"
        fi
        echo "OK: remember=5 configurado em $file"
    fi
done

touch /etc/security/opasswd 2>/dev/null || true
chown root:root /etc/security/opasswd 2>/dev/null || true
chmod 600 /etc/security/opasswd 2>/dev/null || true

echo -e "\n[139] Hash forte sha512"
backup "$LOGIN_DEFS"
set_login_def "ENCRYPT_METHOD" "SHA512"
for file in $PAM_FILES; do
    [ -f "$file" ] || continue
    if grep -Eq 'pam_unix\.so' "$file" && ! grep -Eq 'pam_unix\.so.*sha512' "$file"; then
        sed -ri '/pam_unix\.so/ s/$/ sha512/' "$file"
    fi
done
echo "OK: SHA512 configurado"

echo -e "\n[143-145] Politica login.defs"
set_login_def "PASS_MAX_DAYS" "365"
set_login_def "PASS_MIN_DAYS" "1"
set_login_def "PASS_WARN_AGE" "7"
echo "OK: login.defs ajustado"

echo -e "\n[146] INACTIVE maior igual a 30"
awk -F: '$2~/^\$/{print $1}' /etc/shadow 2>/dev/null | while read -r user; do
    chage --inactive 30 "$user" >/dev/null 2>&1 || true
done
echo "OK: INACTIVE aplicado para contas locais com senha"

echo -e "\n[147] Data de ultima troca valida"
awk -F: '$2~/^\$/{print $1":"$3}' /etc/shadow 2>/dev/null | while IFS=: read -r user lastchg; do
    if [ -z "$lastchg" ] || [ "$lastchg" = "0" ]; then
        chage --lastday 1 "$user" >/dev/null 2>&1 || true
    fi
done
echo "OK: datas inconsistentes ajustadas quando aplicavel"

echo "OK"
exit 0
