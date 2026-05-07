#!/bin/bash

echo "[HARDENING] Remediacoes 1-24 (Kernel e Sysctl - RHEL6/OL6)"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

set_or_replace() {
    file="$1"
    key="$2"
    value="$3"

    grep -q "^[[:space:]]*$key[[:space:]]*=" "$file" 2>/dev/null && \
        sed -i "s|^[[:space:]]*$key[[:space:]]*=.*|$key = $value|" "$file" || \
        echo "$key = $value" >> "$file"
}

sysctl_supported() {
    [ -e "/proc/sys/${1//./\/}" ]
}

set_sysctl_if_supported() {
    key="$1"
    value="$2"

    if sysctl_supported "$key"; then
        set_or_replace "$SYSCTLFILE" "$key" "$value"
        sysctl -w "$key=$value" >/dev/null 2>&1 && \
            echo "OK: $key=$value" || \
            echo "WARN: nao foi possivel aplicar $key em runtime"
    else
        echo "SKIP: $key nao suportado neste kernel"
    fi
}

MODFILE="/etc/modprobe.d/hardening-rhel6.conf"
SYSCTLFILE="/etc/sysctl.conf"
LIMITSFILE="/etc/security/limits.conf"

touch "$MODFILE" "$SYSCTLFILE"
backup "$MODFILE"
backup "$SYSCTLFILE"
backup "$LIMITSFILE"

echo "[1-13] Bloquear modulos de kernel quando presentes"

MODS="cramfs squashfs udf hfs hfsplus jffs2 freevxfs overlay usb_storage dccp sctp rds tipc"

for m in $MODS; do
    grep -q "^[[:space:]]*install[[:space:]]*$m[[:space:]]*/bin/true" "$MODFILE" 2>/dev/null || \
        echo "install $m /bin/true" >> "$MODFILE"

    grep -q "^[[:space:]]*blacklist[[:space:]]*$m\\b" "$MODFILE" 2>/dev/null || \
        echo "blacklist $m" >> "$MODFILE"

    if lsmod | awk '{print $1}' | grep -qx "$m"; then
        modprobe -r "$m" >/dev/null 2>&1 && \
            echo "OK: modulo descarregado $m" || \
            echo "WARN: modulo $m carregado e nao foi possivel descarregar"
    else
        echo "OK: modulo bloqueado $m"
    fi
done

echo "[14-15] Restringir core dumps e suid_dumpable"
set_sysctl_if_supported fs.suid_dumpable 0

grep -q '^[[:space:]]*\*[[:space:]]*hard[[:space:]]*core[[:space:]]*0' "$LIMITSFILE" 2>/dev/null || \
    echo "* hard core 0" >> "$LIMITSFILE"

grep -q '^[[:space:]]*\*[[:space:]]*soft[[:space:]]*core[[:space:]]*0' "$LIMITSFILE" 2>/dev/null || \
    echo "* soft core 0" >> "$LIMITSFILE"

ulimit -c 0 2>/dev/null
echo "OK: limites de core dump configurados"

echo "[16] NX/XD"
if grep -qw nx /proc/cpuinfo 2>/dev/null; then
    echo "OK: CPU informa suporte a NX"
else
    echo "WARN: NX/XD depende de suporte de hardware/BIOS e nao tem remediacao segura via script"
fi

echo "[17-18] ASLR completo"
set_sysctl_if_supported kernel.randomize_va_space 2

echo "[19-20] perf_event restrito quando suportado"
set_sysctl_if_supported kernel.perf_event_paranoid 3

echo "[21] dmesg restrito quando suportado"
set_sysctl_if_supported kernel.dmesg_restrict 1

echo "[22-23] protected_symlinks quando suportado"
set_sysctl_if_supported fs.protected_symlinks 1

echo "[24] protected_hardlinks quando suportado"
set_sysctl_if_supported fs.protected_hardlinks 1

echo "OK"
exit 0
