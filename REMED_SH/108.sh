#!/usr/bin/env bash

echo "[108] Remediacao: TLS minimo por servico (RHEL6/OL6)"

echo "INFO: RHEL6 nao possui update-crypto-policies global"
echo "INFO: TLS deve ser configurado por servico quando suportado"
echo "INFO: revisar httpd, nginx, postfix, dovecot, vsftpd e aplicacoes locais"
echo "SKIP: remediacao automatica global nao aplicavel em RHEL6"

echo "OK"
exit 0
