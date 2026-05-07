#!/usr/bin/env bash

echo "[61-86] Remediacao: servicos e clientes desnecessarios (RHEL6/OL6)"

backup() {
    [ -f "$1" ] && cp "$1" "$1.bkp_$(date +%Y%m%d_%H%M%S)"
}

pkg_installed() {
    rpm -q "$1" >/dev/null 2>&1
}

remove_pkg() {
    pkg="$1"

    if pkg_installed "$pkg"; then
        yum remove -y "$pkg" >/dev/null 2>&1 && \
            echo "OK: pacote removido: $pkg" || \
            echo "WARN: falha ao remover pacote: $pkg"
    else
        echo "OK: $pkg nao instalado"
    fi
}

svc_exists() {
    chkconfig --list "$1" >/dev/null 2>&1
}

disable_service() {
    svc="$1"

    if svc_exists "$svc"; then
        service "$svc" stop >/dev/null 2>&1 || true
        chkconfig "$svc" off >/dev/null 2>&1 && \
            echo "OK: servico desabilitado: $svc" || \
            echo "WARN: falha ao desabilitar servico: $svc"
    else
        echo "OK: servico nao encontrado: $svc"
    fi
}

echo -e "\n[61] X11 removido"
remove_pkg xorg-x11-server-common
remove_pkg xorg-x11-server-Xorg

echo -e "\n[62] Avahi desabilitado/removido"
disable_service avahi-daemon
remove_pkg avahi

echo -e "\n[63] CUPS desabilitado/removido"
disable_service cups
remove_pkg cups

echo -e "\n[64] DHCP server ausente"
disable_service dhcpd
remove_pkg dhcp
remove_pkg dhcp-server

echo -e "\n[65] LDAP server ausente"
disable_service slapd
remove_pkg openldap-servers

echo -e "\n[66] DNS server ausente"
disable_service named
remove_pkg bind

echo -e "\n[67] FTP server ausente"
disable_service vsftpd
remove_pkg vsftpd

echo -e "\n[68] HTTP server ausente"
disable_service httpd
remove_pkg httpd

echo -e "\n[69] IMAP/POP3 server ausente"
disable_service dovecot
remove_pkg dovecot

echo -e "\n[70] Samba ausente"
disable_service smb
disable_service nmb
remove_pkg samba

echo -e "\n[71] Proxy HTTP ausente"
disable_service squid
remove_pkg squid

echo -e "\n[72] SNMP desabilitado/removido"
disable_service snmpd
remove_pkg net-snmp

echo -e "\n[73] NIS server ausente"
disable_service ypserv
remove_pkg ypserv

echo -e "\n[74] Telnet server ausente"
disable_service telnet
remove_pkg telnet-server

echo -e "\n[75] MTA em modo local-only"
POSTFIX_CF="/etc/postfix/main.cf"
SENDMAIL_CF="/etc/mail/sendmail.mc"
if [ -f "$POSTFIX_CF" ]; then
    backup "$POSTFIX_CF"
    if grep -Eq '^[[:space:]]*inet_interfaces[[:space:]]*=' "$POSTFIX_CF"; then
        sed -ri 's/^[[:space:]]*inet_interfaces[[:space:]]*=.*/inet_interfaces = loopback-only/' "$POSTFIX_CF"
    else
        printf '\ninet_interfaces = loopback-only\n' >> "$POSTFIX_CF"
    fi
    service postfix restart >/dev/null 2>&1 || true
    echo "OK: postfix ajustado para loopback-only"
elif [ -f "$SENDMAIL_CF" ]; then
    echo "INFO: sendmail detectado; validar DAEMON_OPTIONS para loopback manualmente"
else
    echo "OK: MTA nao detectado"
fi

echo -e "\n[76] NFS server desabilitado"
disable_service nfs
disable_service nfslock

echo -e "\n[77] rpcbind desabilitado"
disable_service rpcbind

echo -e "\n[78] rsync daemon desabilitado"
disable_service rsync
if [ -f /etc/xinetd.d/rsync ]; then
    backup /etc/xinetd.d/rsync
    sed -ri 's/^[[:space:]]*disable[[:space:]]*=.*/disable = yes/' /etc/xinetd.d/rsync
    echo "OK: rsync via xinetd desabilitado"
fi

echo -e "\n[79] Cliente NIS removido"
disable_service ypbind
remove_pkg ypbind

echo -e "\n[80] Cliente rsh removido"
remove_pkg rsh

echo -e "\n[81] Cliente talk removido"
remove_pkg talk

echo -e "\n[82] Cliente telnet removido"
remove_pkg telnet

echo -e "\n[83] Cliente LDAP removido"
remove_pkg openldap-clients

echo -e "\n[84] Servicos superfluos SysV"
for svc in avahi-daemon cups telnet vsftpd xinetd tftp ypserv ypbind; do
    disable_service "$svc"
done

echo -e "\n[85] TFTP server removido"
disable_service tftp
remove_pkg tftp-server

echo -e "\n[86] PolicyKit RHEL6 seguro"
echo "INFO: PolicyKit legado usa regras pkla; revisar concessoes ResultActive=yes conforme politica aprovada"

echo "OK"
exit 0
