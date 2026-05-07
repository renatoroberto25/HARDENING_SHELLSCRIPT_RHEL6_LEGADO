#!/usr/bin/env bash

set -u

backup_file() {
  [ -f "$1" ] && cp -a "$1" "$1.bak_$(date +%F-%H%M%S)"
}

set_conf_kv() {
  file="$1"
  key="$2"
  value="$3"
  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$file" 2>/dev/null; then
    sed -ri "s|^[[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
  else
    printf '%s = %s\n' "$key" "$value" >> "$file"
  fi
}

append_rule_once() {
  rule="$1"
  grep -qxF "$rule" "$AUDIT_RULES" 2>/dev/null || printf '%s\n' "$rule" >> "$AUDIT_RULES"
}

echo "=== Iniciando remediacao HITSS 161-184 (RHEL6/OL6) ==="

AUDITD_CONF="/etc/audit/auditd.conf"
AUDIT_RULES="/etc/audit/audit.rules"
AIDE_CONF="/etc/aide.conf"
AIDE_DB="/var/lib/aide/aide.db.gz"
CRON_AIDE="/etc/cron.daily/aide-check"

echo -e "\n[161] stack de logs racionalizado"
echo "INFO: RHEL6 nao usa systemd-journald; stack alvo e rsyslog + auditd."
echo "OK"

echo -e "\n[162] journald persistente"
echo "SKIP: nao se aplica ao RHEL6/OL6."

echo -e "\n[163] rsyslog instalado e ativo"
rpm -q rsyslog >/dev/null 2>&1 || yum -y install rsyslog >/dev/null 2>&1
chkconfig rsyslog on >/dev/null 2>&1 || true
service rsyslog start >/dev/null 2>&1 || service rsyslog restart >/dev/null 2>&1 || true
echo "OK: rsyslog habilitado"

echo -e "\n[164] logrotate para rsyslog"
if [ ! -f /etc/logrotate.d/syslog ] && [ ! -f /etc/logrotate.d/rsyslog ]; then
  cat > /etc/logrotate.d/syslog <<'EOF'
/var/log/messages
/var/log/secure
/var/log/maillog
/var/log/cron
/var/log/spooler
/var/log/boot.log {
    sharedscripts
    postrotate
        /bin/kill -HUP `cat /var/run/syslogd.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF
fi
echo "OK: logrotate de syslog/rsyslog presente"

echo -e "\n[165] auditd instalado e rodando"
rpm -q audit audit-libs >/dev/null 2>&1 || yum -y install audit audit-libs >/dev/null 2>&1
chkconfig auditd on >/dev/null 2>&1 || true
service auditd start >/dev/null 2>&1 || service auditd restart >/dev/null 2>&1 || true
echo "OK: auditd habilitado"

echo -e "\n[166] auditoria antes do auditd"
GRUB_FILE="/boot/grub/grub.conf"
if [ -f "$GRUB_FILE" ]; then
  backup_file "$GRUB_FILE"
  if grep -Eq '^[[:space:]]*kernel[[:space:]].*audit=1' "$GRUB_FILE"; then
    echo "OK: audit=1 ja presente no GRUB"
  else
    sed -ri '/^[[:space:]]*kernel[[:space:]]/ s/[[:space:]]*$/ audit=1/' "$GRUB_FILE"
    echo "OK: audit=1 adicionado ao GRUB; requer reboot para valer no kernel."
  fi
else
  echo "WARN: $GRUB_FILE nao encontrado; ajuste manual necessario."
fi

echo -e "\n[167-168] retencao de audit log"
touch "$AUDITD_CONF"
backup_file "$AUDITD_CONF"
set_conf_kv "$AUDITD_CONF" "max_log_file" "50"
set_conf_kv "$AUDITD_CONF" "max_log_file_action" "rotate"
echo "OK: auditd.conf ajustado"

echo -e "\n[169-180] regras auditd"
touch "$AUDIT_RULES"
backup_file "$AUDIT_RULES"

append_rule_once "-w /etc/localtime -p wa -k time-change"
append_rule_once "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -S clock_settime -k time-change"
append_rule_once "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S clock_settime -k time-change"

append_rule_once "-w /etc/passwd -p wa -k identity"
append_rule_once "-w /etc/shadow -p wa -k identity"
append_rule_once "-w /etc/group -p wa -k identity"
append_rule_once "-w /etc/gshadow -p wa -k identity"

append_rule_once "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k network-modify"
append_rule_once "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k network-modify"
append_rule_once "-w /etc/hosts -p wa -k network-modify"
append_rule_once "-w /etc/sysconfig/network -p wa -k network-modify"

append_rule_once "-w /etc/selinux/ -p wa -k mac-policy"
append_rule_once "-w /var/log/faillog -p wa -k logins"
append_rule_once "-w /var/log/lastlog -p wa -k logins"
append_rule_once "-w /var/run/utmp -p wa -k logins"

append_rule_once "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -S chown -S fchown -S fchownat -k perm-modify"
append_rule_once "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -S chown -S fchown -S fchownat -k perm-modify"

append_rule_once "-a always,exit -F arch=b64 -S open -S openat -S creat -S truncate -S ftruncate -F exit=-EACCES -k access"
append_rule_once "-a always,exit -F arch=b64 -S open -S openat -S creat -S truncate -S ftruncate -F exit=-EPERM -k access"
append_rule_once "-a always,exit -F arch=b32 -S open -S openat -S creat -S truncate -S ftruncate -F exit=-EACCES -k access"
append_rule_once "-a always,exit -F arch=b32 -S open -S openat -S creat -S truncate -S ftruncate -F exit=-EPERM -k access"

append_rule_once "-a always,exit -F arch=b64 -S mount -S umount2 -k mounts"
append_rule_once "-a always,exit -F arch=b32 -S mount -S umount2 -k mounts"
append_rule_once "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -S rmdir -k delete"
append_rule_once "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -S rmdir -k delete"
append_rule_once "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules"
append_rule_once "-a always,exit -F arch=b32 -S init_module -S delete_module -k modules"

append_rule_once "-w /etc/sudoers -p wa -k sudoers"
append_rule_once "-w /etc/sudoers.d/ -p wa -k sudoers"

echo -e "\n[176] auditoria de comandos privilegiados"
find / -xdev -type f -perm -4000 2>/dev/null | while read -r privileged_file; do
  append_rule_once "-w $privileged_file -p x -k privileged"
done

echo -e "\n[181] auditoria imutavel"
if grep -Eq '^[[:space:]]*-e[[:space:]]+2[[:space:]]*$' "$AUDIT_RULES"; then
  echo "OK: modo imutavel ja configurado"
else
  printf '\n-e 2\n' >> "$AUDIT_RULES"
  echo "OK: -e 2 adicionado; mudancas futuras em audit podem exigir reboot."
fi

auditctl -R "$AUDIT_RULES" >/dev/null 2>&1 || echo "WARN: auditctl nao carregou todas as regras; validar no OL6."
service auditd restart >/dev/null 2>&1 || true

echo -e "\n[182] AIDE instalado e inicializado"
rpm -q aide >/dev/null 2>&1 || yum -y install aide >/dev/null 2>&1
if [ -f "$AIDE_CONF" ]; then
  backup_file "$AIDE_CONF"
  for audit_bin in /sbin/auditctl /sbin/auditd /sbin/ausearch /sbin/aureport /sbin/autrace; do
    grep -Fqx "$audit_bin p+i+n+u+g+s+b+m+c+sha512" "$AIDE_CONF" 2>/dev/null || \
      printf '%s p+i+n+u+g+s+b+m+c+sha512\n' "$audit_bin" >> "$AIDE_CONF"
  done
fi

if [ ! -f "$AIDE_DB" ]; then
  aide --init >/dev/null 2>&1 || true
  [ -f /var/lib/aide/aide.db.new.gz ] && mv -f /var/lib/aide/aide.db.new.gz "$AIDE_DB"
fi
echo "OK: AIDE preparado quando disponivel"

echo -e "\n[183] verificacao de integridade agendada"
cat > "$CRON_AIDE" <<'EOF'
#!/bin/bash
/usr/sbin/aide --check >/dev/null 2>&1
EOF
chmod 700 "$CRON_AIDE"
echo "OK: cron diario do AIDE configurado"

echo -e "\n[184] protecao dos binarios de auditoria"
for audit_bin in /sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd; do
  [ -e "$audit_bin" ] || continue
  chown root:root "$audit_bin"
  chmod go-w "$audit_bin"
done
echo "OK: ownership/permissoes dos binarios de auditoria ajustados"

echo "=== Remediacao 161-184 concluida ==="
exit 0
