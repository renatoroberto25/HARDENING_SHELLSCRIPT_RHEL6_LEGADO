#!/usr/bin/env bash
set -u

echo "[52 - 57] MAC e serviços legados"

# -----------------------------
# Helpers
# -----------------------------
backup() {
  local f="$1"
  [ -f "$f" ] || return 0
  local ts
  ts="$(date +%Y%m%d%H%M%S)"
  cp -a "$f" "${f}.bak.${ts}" 2>/dev/null || true
}

in_list() {
  local needle="$1"; shift
  local x
  for x in "$@"; do
    [ "$x" = "$needle" ] && return 0
  done
  return 1
}

PKG_RM() {
  if command -v dnf >/dev/null 2>&1; then
    dnf remove -y "$@" >/dev/null 2>&1
  else
    yum remove -y "$@" >/dev/null 2>&1
  fi
}

unit_from_pid() {
  # PID -> systemd unit (melhor esforço)
  local pid="$1"
  local cg="/proc/$pid/cgroup"
  [ -r "$cg" ] || return 1

  # Preferir system.slice/*.service
  local u
  u="$(grep -E '/system\.slice/[^/]+\.service' "$cg" 2>/dev/null \
        | head -n1 | sed -n 's#.*/system\.slice/\([^/]*\.service\).*#\1#p')"
  [ -n "$u" ] && { printf '%s\n' "$u"; return 0; }

  # Fallback: qualquer *.service
  grep -E '\.service' "$cg" 2>/dev/null \
    | head -n1 \
    | sed -n 's#.*/\([^/]*\.service\).*#\1#p' \
    | head -n1
}

exec_from_unit() {
  local u="$1"
  local line first
  line="$(systemctl show -p ExecStart --value "$u" 2>/dev/null || true)"
  [ -n "$line" ] || return 1
  first="$(printf '%s\n' "$line" | awk -F';' '{print $1}' \
          | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/^[[:space:]]+//; s/[[:space:]]+$//')"
  printf '%s\n' "$first" | awk '{print $1}'
}

file_ctx() {
  local f="$1"
  [ -e "$f" ] || return 0
  ls -Z "$f" 2>/dev/null | awk '{print $1}' || true
}

safe_restorecon_exec() {
  local bin="$1"
  command -v restorecon >/dev/null 2>&1 || return 0
  [ -e "$bin" ] || return 0
  restorecon -v "$bin" 2>/dev/null || true
}

# -----------------------------
# Baseline gates
# -----------------------------
# Somente serviços explicitamente autorizados pelo baseline podem sofrer ação (try-restart e/ou stop/disable)
ALLOWLIST_SERVICES=(
  # EXEMPLOS de legados "meio bosta" (ajuste ao seu baseline REAL)
  "avahi-daemon.service"
  "cups.service"
  "rpcbind.service"
  "xinetd.service"
  "telnet.service"
  "tftp.service"
  "vsftpd.service"
)

# Nunca mexer
DENYLIST_SERVICES=(
  "sshd.service"
  "systemd.service"
  "dbus.service"
  "NetworkManager.service"
  "chronyd.service"
  "rsyslog.service"
  "auditd.service"
)

DENYLIST_COMMS=(
  "sshd" "systemd" "sudo" "su" "bash" "sh" "ps" "tee"
)

# Flags
DRYRUN="${DRYRUN:-0}" # 1 = não aplica stop/disable nem restart
DISABLE_LEGACY="${DISABLE_LEGACY:-1}" # 1 = se unit allowlisted estiver unconfined*, pode stop/disable (baseline FULL)

# -----------------------------
# [52] SELinux enforcing + [53] targeted
# -----------------------------
CONFIG="/etc/selinux/config"

echo -e "\n[52] Forçar SELinux para ENFORCING"
backup "$CONFIG"
if grep -q '^SELINUX=' "$CONFIG" 2>/dev/null; then
  sed -i 's/^SELINUX=.*/SELINUX=enforcing/' "$CONFIG"
else
  echo "SELINUX=enforcing" >> "$CONFIG"
fi
getenforce 2>/dev/null | grep -q "Enforcing" || setenforce 1 2>/dev/null || true
echo "✔ SELinux configurado como enforcing (pode exigir reboot)"

echo -e "\n[53] Forçar política SELinux 'targeted'"
backup "$CONFIG"
if grep -q '^SELINUXTYPE=' "$CONFIG" 2>/dev/null; then
  sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=targeted/' "$CONFIG"
else
  echo "SELINUXTYPE=targeted" >> "$CONFIG"
fi
echo "✔ Política SELinux ajustada para targeted"

SELINUX_STATE="$(getenforce 2>/dev/null || echo Unknown)"
if ! printf '%s' "$SELINUX_STATE" | grep -q '^Enforcing$'; then
  echo -e "\n[54/55] SELinux não está Enforcing agora ($SELINUX_STATE)"
  echo "⚠️ PENDENTE REBOOT: não tentar consertar 54/55 neste boot"
  exit 0
fi

# -----------------------------
# Auditor/recheck helper: PID ainda está unconfined?
# -----------------------------
pid_has_unconf_label() {
  local pid="$1"
  local pat="$2"   # ex: unconfined_t|unconfined_service_t
  ps -p "$pid" -eZ -o label= 2>/dev/null | grep -q "$pat"
}

# -----------------------------
# [54] unconfined_service_t
# -----------------------------
echo -e "\n[54] unconfined_service_t"
echo -e "Presença de unconfined_service_t depende dos serviços efetivamente instalados e em execução após o provisionamento"

# -----------------------------
# [55] unconfined_t
# -----------------------------
echo -e "\n[55] unconfined_t (ação mínima; baseline manda)"
echo -e "Presença de unconfined_t só pode ser avaliada corretamente quando o sistema já estiver em uso com seus processos reais carregados"

echo -e "\n[56] Prelink"
if rpm -q prelink &>/dev/null; then
  command -v prelink >/dev/null 2>&1 && prelink -ua >/dev/null 2>&1 || true
  PKG_RM prelink || true
  echo " prelink removido"
else
  echo " prelink não instalado"
fi

echo -e "\n[57] xinetd"
if rpm -q xinetd &>/dev/null; then
  PKG_RM xinetd || true
  rm -f /etc/xinetd.conf /etc/xinetd.d/* 2>/dev/null || true
  echo " xinetd removido"
else
  echo " xinetd não instalado"
fi

echo "OK"
exit 0
