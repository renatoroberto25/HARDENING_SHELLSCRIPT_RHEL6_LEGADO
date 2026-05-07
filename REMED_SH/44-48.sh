#!/usr/bin/env bash

echo "[44-48] Remediacao: sticky bit e autofs (RHEL6/OL6)"

svc_exists() {
    chkconfig --list "$1" >/dev/null 2>&1
}

svc_enabled() {
    chkconfig --list "$1" 2>/dev/null | grep -Eq '(^|[[:space:]])[2-5]:on'
}

svc_running() {
    service "$1" status >/dev/null 2>&1
}

apply_sticky() {
    dir="$1"

    if [ ! -d "$dir" ]; then
        echo "SKIP: $dir nao existe"
        return
    fi

    if stat -c "%A" "$dir" 2>/dev/null | grep -q 't'; then
        echo "OK: $dir ja contem sticky bit"
    else
        chmod +t "$dir" 2>/dev/null && \
            echo "OK: sticky aplicado em $dir" || \
            echo "WARN: falha ao aplicar sticky em $dir"
    fi
}

echo "[44] Aplicar sticky bit em diretorios world-writable"
find / -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | while IFS= read -r dir; do
    apply_sticky "$dir"
done

echo "[45] Sticky bit em /tmp"
apply_sticky "/tmp"

echo "[46] Sticky bit em /var/tmp"
apply_sticky "/var/tmp"

echo "[47] Sticky bit em /dev/shm"
apply_sticky "/dev/shm"

echo "[48] Desabilitar autofs"
if svc_exists autofs; then
    if svc_running autofs; then
        service autofs stop >/dev/null 2>&1 && \
            echo "OK: autofs parado" || \
            echo "WARN: falha ao parar autofs"
    else
        echo "OK: autofs ja estava parado"
    fi

    if svc_enabled autofs; then
        chkconfig autofs off >/dev/null 2>&1 && \
            echo "OK: autofs desabilitado no boot" || \
            echo "WARN: falha ao desabilitar autofs no boot"
    else
        echo "OK: autofs ja estava desabilitado no boot"
    fi
else
    echo "OK: autofs nao instalado"
fi

echo "OK"
exit 0
