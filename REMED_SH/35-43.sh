#!/usr/bin/env bash

echo "[35-43] Remediacao de opcoes de montagem seguras (RHEL6/OL6)"

FSTAB="/etc/fstab"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

is_mounted() {
    awk -v m="$1" '$2 == m {found=1} END{exit !found}' /proc/mounts
}

fstab_has_mount() {
    awk -v m="$1" '$0 !~ /^[[:space:]]*#/ && $2 == m {found=1} END{exit !found}' "$FSTAB"
}

add_opts() {
    mnt="$1"
    needed="$2"

    if ! fstab_has_mount "$mnt"; then
        echo "SKIP: $mnt sem entrada em /etc/fstab"
        return
    fi

    backup "$FSTAB"

    awk -v tgt="$mnt" -v needed="$needed" '
        BEGIN {
            n = split(needed, req, ",")
        }
        $0 ~ /^[[:space:]]*#/ || $2 != tgt {
            print
            next
        }
        {
            split($4, have, ",")
            opts = "," $4 ","
            for (i = 1; i <= n; i++) {
                if (opts !~ "," req[i] ",") {
                    $4 = $4 "," req[i]
                    opts = opts req[i] ","
                }
            }
            print
        }
    ' "$FSTAB" > "${FSTAB}.tmp" && mv "${FSTAB}.tmp" "$FSTAB"

    if is_mounted "$mnt"; then
        mount -o remount "$mnt" >/dev/null 2>&1 && \
            echo "OK: $mnt remount com $needed" || \
            echo "WARN: $mnt ajustado no fstab; remount falhou ou exige janela"
    else
        echo "OK: $mnt ajustado no fstab; nao estava montado"
    fi
}

echo "[35] Midias removiveis no fstab"
add_opts "/media" "nodev,nosuid,noexec"
add_opts "/run/media" "nodev,nosuid,noexec"

echo "[36] Particoes criticas"
add_opts "/var" "nodev,nosuid"

echo "[37] /tmp"
add_opts "/tmp" "nodev,nosuid,noexec"

echo "[38] /dev/shm"
add_opts "/dev/shm" "nodev,nosuid,noexec"

echo "[39] /var/tmp"
add_opts "/var/tmp" "nodev,nosuid,noexec"

echo "[40] /var/log"
add_opts "/var/log" "nodev,nosuid"

echo "[41] /var/log/audit"
add_opts "/var/log/audit" "nodev,nosuid"

echo "[42] /home"
add_opts "/home" "nodev"

echo "[43] Midias removiveis"
add_opts "/media" "nodev,nosuid,noexec"
add_opts "/run/media" "nodev,nosuid,noexec"

echo "OK"
exit 0
