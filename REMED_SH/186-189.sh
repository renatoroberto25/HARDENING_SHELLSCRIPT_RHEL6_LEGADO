#!/usr/bin/env bash
set -euo pipefail

echo "[185-190] Remediacao best effort - controles legados RHEL6/OL6"

echo "[186] Remediacao: compiladores restritos a root e grupo compilers (RHEL6/OL6)"

COMPILERS="/usr/bin/gcc /usr/bin/g++ /usr/bin/cc /usr/bin/make /usr/bin/ld"
GROUP="compilers"

pkg_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

echo -e "\n[186] Grupo $GROUP"
if getent group "$GROUP" >/dev/null 2>&1; then
    echo "OK: grupo $GROUP ja existe"
else
    groupadd "$GROUP" && \
        echo "OK: grupo $GROUP criado" || \
        echo "WARN: falha ao criar grupo $GROUP"
fi

echo -e "\n[186] Permissoes nos binarios"
for bin in $COMPILERS; do
    [ -f "$bin" ] || continue
    chown root:"$GROUP" "$bin" >/dev/null 2>&1 && \
        chmod 750 "$bin" >/dev/null 2>&1 && \
        echo "OK: $bin restrito a root:$GROUP (750)" || \
        echo "WARN: falha ao ajustar $bin"
done

echo "OK"

echo -e "\n[187] SELinux ativo ou justificado"
if command -v getenforce >/dev/null 2>&1; then
    state="$(getenforce 2>/dev/null || echo Unknown)"
    case "$state" in
        Enforcing|Permissive)
            echo "OK: SELinux em estado aceitavel para o baseline: $state"
            ;;
        Disabled)
            echo "WARN: SELinux desabilitado; exige justificativa formal ou plano de ativacao validado."
            ;;
        *)
            echo "WARN: estado SELinux nao identificado: $state"
            ;;
    esac
else
    echo "SKIP: getenforce ausente; validar SELinux manualmente."
fi

echo -e "\n[188] Repositorios orfaos"
if [ -d /etc/yum.repos.d ]; then
    find /etc/yum.repos.d -maxdepth 1 -type f -name '*.repo' -print 2>/dev/null | sed 's/^/INFO: repo encontrado: /'
    echo "WARN: validar manualmente se os repositorios listados sao oficiais/suportados."
else
    echo "SKIP: /etc/yum.repos.d ausente."
fi

echo -e "\n[189] Java legado exposto"
if command -v java >/dev/null 2>&1; then
    java -version 2>&1 | sed 's/^/INFO: /'
    echo "WARN: validar se Java legado esta associado a servico exposto."
else
    echo "OK: Java nao encontrado no PATH."
fi

echo -e "\n[190] Aplicacoes web legadas expostas"
if command -v ps >/dev/null 2>&1; then
    ps -eo pid,comm,args 2>/dev/null | grep -Ei 'tomcat|jboss|weblogic|websphere|httpd|nginx|java' | grep -v grep | sed 's/^/INFO: processo web candidato: /' || true
fi
echo "WARN: validar aplicacoes web legadas expostas contra inventario e regras de firewall."

echo "OK"
exit 0
