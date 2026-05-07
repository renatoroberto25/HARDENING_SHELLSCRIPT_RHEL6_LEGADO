#!/usr/bin/env bash

echo "[103-107] Remediacao: firewall iptables (RHEL6/OL6)"

pkg_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

svc_exists() {
    chkconfig --list "$1" >/dev/null 2>&1
}

if ! pkg_installed iptables; then
    yum install -y iptables >/dev/null 2>&1 && \
        echo "OK: pacote iptables instalado" || \
        echo "WARN: falha ao instalar iptables"
fi

echo -e "\n[103] Politica default deny"
if command -v iptables >/dev/null 2>&1; then
    iptables -C INPUT -i lo -j ACCEPT 2>/dev/null || iptables -A INPUT -i lo -j ACCEPT
    iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -C INPUT -p tcp --dport 22 -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    iptables -P INPUT DROP 2>/dev/null || echo "WARN: falha ao definir INPUT DROP"
    iptables -P FORWARD DROP 2>/dev/null || echo "WARN: falha ao definir FORWARD DROP"
    iptables -P OUTPUT ACCEPT 2>/dev/null || true

    echo "OK: politicas basicas aplicadas com SSH preservado"
else
    echo "WARN: comando iptables nao encontrado"
fi

echo -e "\n[104] Apenas iptables como firewall"
echo "INFO: RHEL6 usa iptables; firewalld/nftables nao sao esperados"

echo -e "\n[105] Firewall ativo"
if svc_exists iptables; then
    service iptables start >/dev/null 2>&1 && \
        echo "OK: iptables iniciado" || \
        echo "WARN: falha ao iniciar iptables"
else
    echo "WARN: servico iptables nao encontrado"
fi

echo -e "\n[106] Politicas iptables definidas"
iptables -S INPUT 2>/dev/null | grep -Eq '^-P INPUT (DROP|REJECT)' && \
    echo "OK: INPUT default deny" || \
    echo "WARN: INPUT nao esta default deny"

echo -e "\n[107] Configuracao permanente do firewall"
if svc_exists iptables; then
    chkconfig iptables on >/dev/null 2>&1 || echo "WARN: falha ao habilitar iptables no boot"
    service iptables save >/dev/null 2>&1 && \
        echo "OK: regras salvas em /etc/sysconfig/iptables" || \
        echo "WARN: falha ao salvar regras iptables"
else
    echo "WARN: servico iptables nao encontrado"
fi

echo "OK"
exit 0
