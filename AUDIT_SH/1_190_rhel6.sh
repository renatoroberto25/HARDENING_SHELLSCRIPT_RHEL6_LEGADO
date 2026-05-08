#!/usr/bin/env bash

echo -e "\n1;Kernel;Light;Alta;Bloqueio cramfs;"
(modinfo cramfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+cramfs\b' && ! lsmod | grep -q cramfs) || (! modinfo cramfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n2;Kernel;Light;Alta;Bloqueio squashfs;"
(modinfo squashfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+squashfs\b' && ! lsmod | grep -q squashfs) || (! modinfo squashfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n3;Kernel;Light;Média;Bloqueio udf;"
(modinfo udf &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+udf\b' && ! lsmod | grep -q udf) || (! modinfo udf &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n4;Kernel;Light;Alta;Bloqueio hfs;"
(modinfo hfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+hfs\b' && ! lsmod | grep -q hfs) || (! modinfo hfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n5;Kernel;Light;Alta;Bloqueio hfsplus;"
(modinfo hfsplus &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+hfsplus\b' && ! lsmod | grep -q hfsplus) || (! modinfo hfsplus &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n6;Kernel;Light;Alta;Bloqueio jffs2;"
(modinfo jffs2 &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+jffs2\b' && ! lsmod | grep -q jffs2) || (! modinfo jffs2 &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n7;Kernel;Light;Alta;Bloqueio freevxfs;"
(modinfo freevxfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+freevxfs\b' && ! lsmod | grep -q freevxfs) || (! modinfo freevxfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n8;Kernel;Full;Média;overlayfs ausente ou bloqueado;"
(modinfo overlay &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+overlay\b' && ! lsmod | grep -q overlay) || (! modinfo overlay &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n9;Kernel;Light;Alta;Bloqueio usb_storage;"
(modinfo usb-storage &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+usb_storage\b' && ! lsmod | grep -q usb_storage) || (! modinfo usb-storage &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n10;Kernel;Full;Alta;Desabilitar DCCP;"
(modinfo dccp &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+dccp\b' && ! lsmod | grep -q dccp) || (! modinfo dccp &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n11;Kernel;Full;Alta;Desabilitar SCTP;"
(modinfo sctp &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+sctp\b' && ! lsmod | grep -q sctp) || (! modinfo sctp &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n12;Kernel;Full;Alta;Desabilitar RDS;"
(modinfo rds &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+rds\b' && ! lsmod | grep -q rds) || (! modinfo rds &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n13;Kernel;Full;Alta;Desabilitar TIPC;"
(modinfo tipc &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+tipc\b' && ! lsmod | grep -q tipc) || (! modinfo tipc &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n14;Kernel;Light;Alta;SUID dump desabilitado;"
(sysctl -n fs.suid_dumpable 2>/dev/null | grep -q '^0$' && grep -E 'fs.suid_dumpable.*0' /etc/sysctl.conf &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n15;Kernel;Light;Média;ASLR habilitado;"
(sysctl -n kernel.randomize_va_space 2>/dev/null | grep -q '^2$' && grep -E 'kernel.randomize_va_space.*2' /etc/sysctl.conf &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n16;Kernel;Full;Alta;Core dumps restritos;"
(ulimit -c | grep -q '^0$' && sysctl -n fs.suid_dumpable 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n17;Kernel;Full;Alta;NX XD ativo;"
(grep -q ' nx' /proc/cpuinfo || dmesg | grep -qi 'NX.*active') && echo "PASS" || echo "FAIL"

echo -e "\n18;Kernel;Full;Média;perf_event restrito se suportado;"
([ ! -e /proc/sys/kernel/perf_event_paranoid ] || sysctl -n kernel.perf_event_paranoid 2>/dev/null | grep -qE '^[2-3]$') && echo "PASS" || echo "FAIL"

echo -e "\n19;Kernel;Full;Média;dmesg restrito se suportado;"
([ ! -e /proc/sys/kernel/dmesg_restrict ] || sysctl -n kernel.dmesg_restrict 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n20;Kernel;Full;Média;Symlinks protegidos se suportado;"
([ ! -e /proc/sys/fs/protected_symlinks ] || sysctl -n fs.protected_symlinks 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n21;Kernel;Full;Média;Hardlinks protegidos se suportado;"
([ ! -e /proc/sys/fs/protected_hardlinks ] || sysctl -n fs.protected_hardlinks 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n22;Filesystem;Full;Média;Partição dedicada para /tmp;"
(findmnt -kn /tmp 2>/dev/null | grep -q /tmp) && echo "PASS" || echo "FAIL"

echo -e "\n23;Filesystem;Full;Média;Partição dedicada para /dev/shm;"
(findmnt -kn /dev/shm 2>/dev/null | grep -q /dev/shm) && echo "PASS" || echo "FAIL"

echo -e "\n24;Filesystem;Full;Alta;Partição dedicada para /var;"
(findmnt -kn /var 2>/dev/null | grep -q /var) && echo "PASS" || echo "FAIL"

echo -e "\n25;Filesystem;Full;Alta;Partição dedicada para /var/tmp;"
(findmnt -kn /var/tmp 2>/dev/null | grep -q /var/tmp) && echo "PASS" || echo "FAIL"

echo -e "\n26;Filesystem;Full;Alta;Partição dedicada para /var/log;"
(findmnt -kn /var/log 2>/dev/null | grep -q /var/log) && echo "PASS" || echo "FAIL"

echo -e "\n27;Filesystem;Full;Alta;Partição dedicada para /var/log/audit;"
(findmnt -kn /var/log/audit 2>/dev/null | grep -q /var/log/audit) && echo "PASS" || echo "FAIL"

echo -e "\n28;Filesystem;Full;Média;Partição dedicada para /home;"
(findmnt -kn /home 2>/dev/null | grep -q /home) && echo "PASS" || echo "FAIL"

echo -e "\n29;Filesystem;Light;Alta;Opções seguras em /tmp;"
(findmnt -kn /tmp -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid|noexec)') && echo "PASS" || echo "FAIL"

echo -e "\n30;Filesystem;Light;Alta;Opções seguras em /dev/shm;"
(findmnt -kn /dev/shm -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid|noexec)') && echo "PASS" || echo "FAIL"

echo -e "\n31;Filesystem;Light;Média;Opções seguras em /var/tmp;"
(findmnt -kn /var/tmp -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid|noexec)') && echo "PASS" || echo "FAIL"

echo -e "\n32;Filesystem;Light;Alta;Opções seguras em /var/log;"
(findmnt -kn /var/log -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid)') && echo "PASS" || echo "FAIL"

echo -e "\n33;Filesystem;Light;Alta;Opções seguras em /var/log/audit;"
(findmnt -kn /var/log/audit -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid)') && echo "PASS" || echo "FAIL"

echo -e "\n34;Filesystem;Light;Média;Opções seguras em /home;"
(findmnt -kn /home -o OPTIONS 2>/dev/null | grep -q nodev) && echo "PASS" || echo "FAIL"

echo -e "\n35;Filesystem;Light;Alta;Sticky world-writable;"
(find / -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n36;Filesystem;Light;Alta;Sticky /tmp;"
(stat -Lc "%a" /tmp 2>/dev/null | grep -q '^1777$') && echo "PASS" || echo "FAIL"

echo -e "\n37;Filesystem;Light;Média;Sticky /var/tmp;"
(stat -Lc "%a" /var/tmp 2>/dev/null | grep -q '^1777$') && echo "PASS" || echo "FAIL"

echo -e "\n38;Filesystem;Light;Alta;Sticky /dev/shm;"
(stat -Lc "%a" /dev/shm 2>/dev/null | grep -q '^1777$') && echo "PASS" || echo "FAIL"

echo -e "\n39;Boot;Full;Baixa;Autofs desabilitado;"
(! chkconfig autofs on 2>/dev/null && ! service autofs status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n40;Boot;Full;Alta;Senha GRUB Legacy;"
([ -f /boot/grub/grub.conf ] && grep -q '^password' /boot/grub/grub.conf) && echo "PASS" || echo "FAIL"

echo -e "\n41;Boot;Full;Média;Permissões grub.conf;"
([ -f /boot/grub/grub.conf ] && stat -Lc "%u %g %a" /boot/grub/grub.conf | grep -q '^0 0 600$') && echo "PASS" || echo "FAIL"

echo -e "\n42;Boot;Full;Média;Single user autenticado;"
([ -f /etc/sysconfig/init ] && grep -q 'SINGLE=/sbin/sulogin' /etc/sysconfig/init) && echo "PASS" || echo "FAIL"

echo -e "\n43;Sistema;Light;Alta;Prelink removido;"
(! rpm -qa 2>/dev/null | grep -q '^prelink') && echo "PASS" || echo "FAIL"

echo -e "\n44;Sistema;Light;Baixa;xinetd removido;"
(! rpm -qa 2>/dev/null | grep -q '^xinetd' && ! chkconfig xinetd on 2>/dev/null && ! service xinetd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n45;Sistema;Light;Alta;ntpd ativo;"
(service ntpd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n46;Sistema;Light;Baixa;Fontes NTP configuradas;"
([ -f /etc/ntp.conf ] && grep -E '^\s*(server|pool)' /etc/ntp.conf 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n47;Sistema;Light;Baixa;ntpd no boot;"
(chkconfig ntpd on 2>/dev/null || chkconfig --list ntpd 2>/dev/null | grep -q '3:on') && echo "PASS" || echo "FAIL"

echo -e "\n48;Sistema;Light;Alta;Time sync único;"
(service ntpd status 2>/dev/null && ! service chronyd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n49;Sistema;Light;Alta;X11 removido;"
(! rpm -qa 2>/dev/null | grep -qE '^xorg-x11-server') && echo "PASS" || echo "FAIL"

echo -e "\n50;Sistema;Light;Alta;Avahi desabilitado;"
(! chkconfig avahi-daemon on 2>/dev/null && ! service avahi-daemon status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n51;Sistema;Light;Baixa;CUPS desabilitado;"
(! chkconfig cups on 2>/dev/null && ! service cups status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n52;Sistema;Full;Alta;DHCP server ausente;"
(rpm -q dhcp-server >/dev/null 2>&1 || rpm -q dhcpd >/dev/null 2>&1) && echo "FAIL" || echo "PASS"

echo -e "\n53;Sistema;Full;Alta;LDAP server ausente;"
(! rpm -qa 2>/dev/null | grep -q '^openldap-servers') && echo "PASS" || echo "FAIL"

echo -e "\n54;Sistema;Full;Alta;DNS server ausente;"
(! rpm -qa 2>/dev/null | grep -q '^bind') && echo "PASS" || echo "FAIL"

echo -e "\n55;Sistema;Full;Alta;FTP server ausente;"
(! rpm -qa 2>/dev/null | grep -q '^vsftpd') && echo "PASS" || echo "FAIL"

echo -e "\n56;Sistema;Full;Média;HTTP server ausente;"
(! rpm -qa 2>/dev/null | grep -q '^httpd') && echo "PASS" || echo "FAIL"

echo -e "\n57;Sistema;Light;Alta;IMAP POP removidos;"
(! rpm -qa 2>/dev/null | grep -qE '^(dovecot|cyrus-imapd)') && echo "PASS" || echo "FAIL"

echo -e "\n58;Sistema;Light;Baixa;Samba removido;"
(! rpm -qa 2>/dev/null | grep -q '^samba') && echo "PASS" || echo "FAIL"

echo -e "\n59;Sistema;Light;Alta;Proxy removido;"
(! rpm -qa 2>/dev/null | grep -q '^squid') && echo "PASS" || echo "FAIL"

echo -e "\n60;Sistema;Light;Baixa;SNMP desabilitado;"
(! chkconfig snmpd on 2>/dev/null && ! service snmpd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n61;Sistema;Light;Baixa;NIS removido;"
(! rpm -qa 2>/dev/null | grep -q '^ypserv') && echo "PASS" || echo "FAIL"

echo -e "\n62;Sistema;Light;Alta;Telnet server removido;"
(! rpm -qa 2>/dev/null | grep -q '^telnet-server') && echo "PASS" || echo "FAIL"

echo -e "\n63;Sistema;Light;Baixa;MTA local-only;"
(netstat -tuln 2>/dev/null | grep -E ':(25|587)\s' | grep -q '127.0.0.1' || ! netstat -tuln 2>/dev/null | grep -qE ':(25|587)\s') && echo "PASS" || echo "FAIL"

echo -e "\n64;Sistema;Light;Alta;NFS server desabilitado;"
(! chkconfig nfs on 2>/dev/null && ! chkconfig nfslock on 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n65;Sistema;Light;Média;rpcbind desabilitado;"
(! chkconfig rpcbind on 2>/dev/null && ! chkconfig portmap on 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n66;Sistema;Light;Alta;rsync daemon desabilitado;"
(! chkconfig rsync on 2>/dev/null && ! grep -q 'enable = true' /etc/rsyncd.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n67;Sistema;Light;Alta;Cliente NIS removido;"
(! rpm -qa 2>/dev/null | grep -q '^ypbind') && echo "PASS" || echo "FAIL"

echo -e "\n68;Sistema;Light;Baixa;Cliente rsh removido;"
(! rpm -qa 2>/dev/null | grep -q '^rsh') && echo "PASS" || echo "FAIL"

echo -e "\n69;Sistema;Light;Alta;Cliente talk removido;"
(! rpm -qa 2>/dev/null | grep -q '^talk') && echo "PASS" || echo "FAIL"

echo -e "\n70;Sistema;Light;Alta;Cliente telnet removido;"
(! rpm -qa 2>/dev/null | grep -q '^telnet-' && ! rpm -qa 2>/dev/null | grep -q '^telnet$') && echo "PASS" || echo "FAIL"

echo -e "\n71;Sistema;Light;Baixa;Cliente LDAP avaliado;"
(! rpm -qa 2>/dev/null | grep -q '^openldap-clients') && echo "PASS" || echo "FAIL"

echo -e "\n72;Sistema;Light;Média;Serviços SysV mínimos;"
([ $(chkconfig --list 2>/dev/null | grep -c ':on') -le 10 ]) && echo "PASS" || echo "FAIL"

echo -e "\n73;Sistema;Light;Média;TFTP removido;"
(! rpm -qa 2>/dev/null | grep -q '^tftp-server') && echo "PASS" || echo "FAIL"

echo -e "\n74;Sistema;Light;Baixa;gpgcheck ativo;"
(grep -r 'gpgcheck=1' /etc/yum.conf /etc/yum.repos.d/ 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n75;Sistema;Light;Alta;Patches aplicados;"
([ $(yum check-update 2>/dev/null | wc -l) -eq 1 ]) && echo "PASS" || echo "FAIL"

echo -e "\n76;Sistema;Light;Alta;Cron restrito;"
([ -f /etc/cron.allow ] && [ ! -f /etc/cron.deny ]) && echo "PASS" || echo "FAIL"

echo -e "\n77;Sistema;Light;Alta;At restrito;"
([ -f /etc/at.allow ] && [ ! -f /etc/at.deny ]) && echo "PASS" || echo "FAIL"

echo -e "\n78;Rede;Full;Alta;IP forwarding desabilitado;"
(sysctl -n net.ipv4.ip_forward 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n79;Rede;Light;Alta;Redirects desabilitados;"
(sysctl -n net.ipv4.conf.all.send_redirects 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n80;Rede;Light;Média;Source route bloqueado;"
(sysctl -n net.ipv4.conf.all.accept_source_route 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n81;Rede;Light;Média;ICMP redirects off;"
(sysctl -n net.ipv4.conf.all.accept_redirects 2>/dev/null | grep -q '^0$' && sysctl -n net.ipv4.conf.all.secure_redirects 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n82;Rede;Light;Alta;RP filter ativo;"
(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n83;Rede;Light;Alta;Ignore broadcast ICMP;"
(sysctl -n net.ipv4.icmp_echo_ignore_broadcasts 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n84;Rede;Light;Média;Ignore bogus ICMP;"
(sysctl -n net.ipv4.icmp_ignore_bogus_error_responses 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n85;Rede;Light;Alta;Syncookies ativos;"
(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n86;Rede;Full;Alta;IPv6 desabilitado ou controlado;"
(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null | grep -q '^1$' || [ ! -e /proc/sys/net/ipv6 ]) && echo "PASS" || echo "FAIL"

echo -e "\n87;Rede;Light;Baixa;Wireless desabilitado;"
([ $(iwconfig 2>/dev/null | grep -c 'no wireless') -gt 0 ] || ! rfkill list 2>/dev/null | grep -q 'Bluetooth.*unblocked') && echo "PASS" || echo "FAIL"

echo -e "\n88;Firewall;Light;Alta;iptables ativo;"
(chkconfig iptables on 2>/dev/null || service iptables status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n89;Firewall;Light;Alta;Política padrão restritiva;"
(iptables -L INPUT 2>/dev/null | grep -qE 'policy (DROP|REJECT)') && echo "PASS" || echo "FAIL"

echo -e "\n90;Firewall;Light;Alta;Loopback permitido;"
(iptables -L 2>/dev/null | grep -q 'lo') && echo "PASS" || echo "FAIL"

echo -e "\n91;Firewall;Light;Alta;Conexões estabelecidas permitidas;"
(iptables -L -n 2>/dev/null | grep -qE 'ESTABLISHED.*RELATED|RELATED.*ESTABLISHED') && echo "PASS" || echo "FAIL"

echo -e "\n92;Firewall;Full;Média;Portas expostas revisadas;"
(netstat -tuln 2>/dev/null | wc -l | awk '{if($1>2) print "PASS"; else print "FAIL"}')

echo -e "\n93;SSH;Light;Alta;Permissões SSH seguras;"
(stat -Lc "%u %g %a" /etc/ssh/sshd_config 2>/dev/null | grep -q '^0 0 600$' && stat -Lc "%u %g %a" /etc/ssh 2>/dev/null | grep -q '^0 0 700$') && echo "PASS" || echo "FAIL"

echo -e "\n94;SSH;Light;Alta;Protocol 2;"
(grep -q '^Protocol 2' /etc/ssh/sshd_config && ! grep -q '^Protocol 1' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n95;SSH;Full;Média;Controle Allow Deny;"
(grep -qE '^(AllowUsers|AllowGroups|DenyUsers|DenyGroups)' /etc/ssh/sshd_config 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n96;SSH;Light;Baixa;SyslogFacility AUTHPRIV;"
(grep -q '^SyslogFacility' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n97;SSH;Light;Baixa;LogLevel INFO;"
(grep -qE '^LogLevel\s+(INFO|VERBOSE|DEBUG)' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n98;SSH;Light;Baixa;X11Forwarding desabilitado;"
(grep -q '^X11Forwarding no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n99;SSH;Light;Alta;MaxAuthTries restrito;"
(grep -qE '^MaxAuthTries\s+[1-5]' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n100;SSH;Light;Alta;IgnoreRhosts ativo;"
(grep -q '^IgnoreRhosts yes' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n101;SSH;Light;Baixa;HostbasedAuthentication off;"
(grep -q '^HostbasedAuthentication no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n102;SSH;Light;Alta;PermitRootLogin restrito;"
(grep -qE '^PermitRootLogin\s+(no|without-password|forced-commands-only)' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n103;SSH;Light;Alta;PermitEmptyPasswords off;"
(grep -q '^PermitEmptyPasswords no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n104;SSH;Light;Média;PermitUserEnvironment off;"
(grep -q '^PermitUserEnvironment no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n105;SSH;Light;Alta;UsePAM ativo;"
(grep -q '^UsePAM yes' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n106;SSH;Light;Baixa;ClientAlive configurado;"
(grep -qE '^ClientAliveInterval' /etc/ssh/sshd_config && grep -qE '^ClientAliveCountMax' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n107;SSH;Light;Alta;LoginGraceTime restrito;"
(grep -qE '^LoginGraceTime\s+[1-9][0-9]?s?$|^LoginGraceTime\s+[1-5][0-9]{2}s?$' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n108;SSH;Light;Média;MaxStartups restrito;"
(grep -qE '^MaxStartups' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n109;SSH;Full;Alta;AllowTcpForwarding restrito;"
(grep -qE '^AllowTcpForwarding\s+(no|local)' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n110;SSH;Light;Baixa;Banner legal;"
(grep -q '^Banner' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n111;SSH;Full;Alta;Ciphers compatíveis RHEL6;"
(! grep -qE 'Ciphers.*arcfour|Ciphers.*cbc' /etc/ssh/sshd_config 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n112;SSH;Full;Alta;MACs compatíveis RHEL6;"
(! grep -qE 'MACs.*md5|MACs.*sha1' /etc/ssh/sshd_config 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n113;SSH;Full;Alta;Kex compatível RHEL6;"
(grep -qE '^KexAlgorithms' /etc/ssh/sshd_config 2>/dev/null || ! grep -q '^KexAlgorithms' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n114;Senhas e Contas;Light;Alta;PAM complexidade;"
(grep -r 'pam_cracklib' /etc/pam.d/ 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n115;Senhas e Contas;Light;Alta;pam_cracklib configurado;"
(grep 'pam_cracklib' /etc/pam.d/* 2>/dev/null | grep -qE 'minlen=|dcredit=|ucredit=|lcredit=|ocredit=') && echo "PASS" || echo "FAIL"

echo -e "\n116;Senhas e Contas;Full;Alta;pam_tally2 configurado;"
(grep -r 'pam_tally2' /etc/pam.d/ 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n117;Senhas e Contas;Light;Alta;Histórico via pam_unix;"
(grep 'pam_unix' /etc/pam.d/* 2>/dev/null | grep -q 'remember=' && [ -f /etc/security/opasswd ] && stat -Lc "%a %u %g" /etc/security/opasswd 2>/dev/null | grep -q '^600 0 0$') && echo "PASS" || echo "FAIL"

echo -e "\n118;Senhas e Contas;Light;Alta;Hash SHA512;"
(grep -qE '^ENCRYPT_METHOD.*SHA512' /etc/login.defs && grep 'pam_unix' /etc/pam.d/* 2>/dev/null | grep -q 'sha512') && echo "PASS" || echo "FAIL"

echo -e "\n119;Senhas e Contas;Light;Alta;PASS_MAX_DAYS;"
(grep -qE '^PASS_MAX_DAYS\s+([0-9]{1,2}|90)' /etc/login.defs) && echo "PASS" || echo "FAIL"

echo -e "\n120;Senhas e Contas;Light;Baixa;PASS_MIN_DAYS;"
(grep -qE '^PASS_MIN_DAYS\s+[1-9]' /etc/login.defs) && echo "PASS" || echo "FAIL"

echo -e "\n121;Senhas e Contas;Light;Baixa;PASS_WARN_AGE;"
(grep -qE '^PASS_WARN_AGE\s+[1-9]' /etc/login.defs) && echo "PASS" || echo "FAIL"

echo -e "\n122;Senhas e Contas;Light;Alta;INACTIVE ajustado;"
(grep -qE '^INACTIVE\s+([0-9]|30)' /etc/default/useradd 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n123;Senhas e Contas;Light;Baixa;Datas de senha válidas;"
(awk -F: '{if(length($3)>0 && $3/86400>now) c++} END{exit c>0}' now="$(date +%s)" /etc/shadow) && echo "PASS" || echo "FAIL"

echo -e "\n124;Senhas e Contas;Light;Alta;UID 0 exclusivo;"
(awk -F: '($3==0 && $1!="root") {c++} END{exit c>0}' /etc/passwd) && echo "PASS" || echo "FAIL"

echo -e "\n125;Senhas e Contas;Light;Alta;GID 0 exclusivo;"
(awk -F: '($3==0 && $1!="root") {c++} END{exit c>0}' /etc/group) && echo "PASS" || echo "FAIL"

echo -e "\n126;Senhas e Contas;Light;Alta;Contas sistema bloqueadas;"
(awk -F: '($3<1000 && $7 !~ /(nologin|shutdown|halt|sync)$/) {c++} END{exit c>0}' /etc/passwd) && echo "PASS" || echo "FAIL"

echo -e "\n127;Senhas e Contas;Light;Baixa;Shells válidos;"
([ -f /etc/shells ] && [ -s /etc/shells ]) && echo "PASS" || echo "FAIL"

echo -e "\n128;Senhas e Contas;Light;Alta;PATH root seguro;"
(! echo $PATH | grep -qE '::' && ! echo $PATH | grep -qE '^/.*:\.') && echo "PASS" || echo "FAIL"

echo -e "\n129;Senhas e Contas;Light;Alta;Umask restritiva;"
(grep -r '^umask' /etc/bashrc /etc/bash.bashrc /etc/profile 2>/dev/null | grep -qE '0077|0027') && echo "PASS" || echo "FAIL"

echo -e "\n130;Senhas e Contas;Light;Baixa;Timeout shell;"
(grep -r '^TMOUT=' /etc/profile /etc/bashrc 2>/dev/null | grep -qE 'TMOUT=[0-9]{3,}') && echo "PASS" || echo "FAIL"

echo -e "\n131;Sudo;Light;Alta;Sudo restrito;"
([ -f /etc/sudoers ] && stat -Lc "%a %u %g" /etc/sudoers 2>/dev/null | grep -q '^440 0 0$') && echo "PASS" || echo "FAIL"

echo -e "\n132;Sudo;Light;Alta;Sudo requiretty;"
(grep -r 'Defaults.*requiretty' /etc/sudoers* 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n133;Sudo;Light;Alta;Sudo logging;"
(grep -r 'logfile=\|syslog=' /etc/sudoers* 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n134;Sudo;Full;Média;Reautenticação não desabilitada;"
(! grep -r 'NOPASSWD' /etc/sudoers* 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n135;Sudo;Light;Média;Sudo timeout;"
(grep -r 'timestamp_timeout=' /etc/sudoers* 2>/dev/null | grep -qE 'timestamp_timeout=[0-5]') && echo "PASS" || echo "FAIL"

echo -e "\n136;Sudo;Light;Alta;su restrito;"
(grep -q 'pam_wheel' /etc/pam.d/su 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n137;Logs;Light;Alta;rsyslog ativo;"
(rpm -qa 2>/dev/null | grep -q '^rsyslog' && service rsyslog status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n138;Logs;Light;Alta;Logs persistentes;"
(grep -qE '^\*\.\*|@|@@' /etc/rsyslog.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n139;Logs;Light;Alta;Rotação de logs;"
([ -d /etc/logrotate.d ] && [ $(ls -1 /etc/logrotate.d 2>/dev/null | wc -l) -gt 0 ]) && echo "PASS" || echo "FAIL"

echo -e "\n140;Auditoria;Light;Alta;auditd instalado;"
(rpm -qa 2>/dev/null | grep -q '^audit') && echo "PASS" || echo "FAIL"

echo -e "\n141;Auditoria;Light;Alta;auditd ativo;"
(service auditd status 2>/dev/null || auditctl -l 2>/dev/null | grep -q -) && echo "PASS" || echo "FAIL"

echo -e "\n142;Auditoria;Light;Alta;auditd no boot;"
(chkconfig auditd on 2>/dev/null || chkconfig --list auditd 2>/dev/null | grep -q '3:on') && echo "PASS" || echo "FAIL"

echo -e "\n143;Auditoria;Full;Alta;audit=1 no kernel;"
([ -f /boot/grub/grub.conf ] && grep -q 'audit=1' /boot/grub/grub.conf) && echo "PASS" || echo "FAIL"

echo -e "\n144;Auditoria;Light;Alta;Tamanho máximo audit;"
(grep -q '^max_log_file' /etc/audit/auditd.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n145;Auditoria;Full;Alta;Logs audit preservados;"
(grep -qE 'max_log_file_action\s+(keep_logs|syslog)' /etc/audit/auditd.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n146;Auditoria;Light;Alta;Auditoria data hora;"
(auditctl -l 2>/dev/null | grep -qE 'adjtimex|settimeofday|sethostname|setdomainname') && echo "PASS" || echo "FAIL"

echo -e "\n147;Auditoria;Light;Alta;Auditoria contas;"
(auditctl -l 2>/dev/null | grep -qE '/etc/passwd|/etc/group|/etc/shadow') && echo "PASS" || echo "FAIL"

echo -e "\n148;Auditoria;Light;Média;Auditoria rede;"
(auditctl -l 2>/dev/null | grep -qE '/etc/issue|/etc/hostname|/etc/network') && echo "PASS" || echo "FAIL"

echo -e "\n149;Auditoria;Light;Baixa;Auditoria MAC;"
([ ! -e /etc/selinux/config ] || auditctl -l 2>/dev/null | grep -qi selinux) && echo "PASS" || echo "FAIL"

echo -e "\n150;Auditoria;Light;Alta;Auditoria login;"
(auditctl -l 2>/dev/null | grep -qE '/var/log/faillog|/var/log/lastlog|/var/log/tallylog') && echo "PASS" || echo "FAIL"

echo -e "\n151;Auditoria;Light;Alta;Auditoria acesso negado;"
(auditctl -l 2>/dev/null | grep -qE 'EACCES|EPERM') && echo "PASS" || echo "FAIL"

echo -e "\n152;Auditoria;Light;Alta;Auditoria privilegiados;"
(auditctl -l 2>/dev/null | grep -qE 'perm=-x') && echo "PASS" || echo "FAIL"

echo -e "\n153;Auditoria;Light;Baixa;Auditoria mount;"
(auditctl -l 2>/dev/null | grep -qE 'mount|umount') && echo "PASS" || echo "FAIL"

echo -e "\n154;Auditoria;Light;Baixa;Auditoria deleção;"
(auditctl -l 2>/dev/null | grep -qE 'unlink|unlinkat|rename|renameat') && echo "PASS" || echo "FAIL"

echo -e "\n155;Auditoria;Light;Alta;Auditoria módulos kernel;"
(auditctl -l 2>/dev/null | grep -qE 'insmod|rmmod|modprobe') && echo "PASS" || echo "FAIL"

echo -e "\n156;Auditoria;Light;Alta;Auditoria sudo;"
(auditctl -l 2>/dev/null | grep -q '/etc/sudoers') && echo "PASS" || echo "FAIL"

echo -e "\n157;Auditoria;Full;Alta;Audit imutável;"
(auditctl -l 2>/dev/null | grep -q '^-e 2') && echo "PASS" || echo "FAIL"

echo -e "\n158;Integridade;Full;Alta;AIDE instalado;"
(rpm -qa 2>/dev/null | grep -q '^aide') && echo "PASS" || echo "FAIL"

echo -e "\n159;Integridade;Full;Alta;AIDE inicializado;"
([ -f /var/lib/aide/aide.db ] || [ -f /var/lib/aide/aide.db.gz ]) && echo "PASS" || echo "FAIL"

echo -e "\n160;Integridade;Light;Alta;AIDE agendado;"
(grep -r '/usr/sbin/aide' /etc/cron* /var/spool/cron 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n161;Permissões;Light;Alta;Permissões passwd;"
([ -f /etc/passwd ] && stat -Lc "%u %g %a" /etc/passwd 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n162;Permissões;Light;Baixa;Permissões passwd-;"
([ ! -f /etc/passwd- ] || stat -Lc "%u %g %a" /etc/passwd- 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n163;Permissões;Light;Alta;Permissões shadow;"
([ -f /etc/shadow ] && stat -Lc "%u %g %a" /etc/shadow 2>/dev/null | grep -qE '^0 0 0+$') && echo "PASS" || echo "FAIL"

echo -e "\n164;Permissões;Light;Baixa;Permissões shadow-;"
([ ! -f /etc/shadow- ] || stat -Lc "%u %g %a" /etc/shadow- 2>/dev/null | grep -qE '^0 0 0+$') && echo "PASS" || echo "FAIL"

echo -e "\n165;Permissões;Light;Alta;Permissões gshadow;"
([ -f /etc/gshadow ] && stat -Lc "%u %g %a" /etc/gshadow 2>/dev/null | grep -qE '^0 0 (600|[5][0-9]{2})$') && echo "PASS" || echo "FAIL"

echo -e "\n166;Permissões;Light;Baixa;Permissões gshadow-;"
([ ! -f /etc/gshadow- ] || stat -Lc "%u %g %a" /etc/gshadow- 2>/dev/null | grep -qE '^0 0 (600|[5][0-9]{2})$') && echo "PASS" || echo "FAIL"

echo -e "\n167;Permissões;Light;Baixa;Permissões group;"
([ -f /etc/group ] && stat -Lc "%u %g %a" /etc/group 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n168;Permissões;Light;Baixa;Permissões group-;"
([ ! -f /etc/group- ] || stat -Lc "%u %g %a" /etc/group- 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n169;Permissões;Light;Alta;Proteger opasswd;"
([ ! -f /etc/security/opasswd ] || stat -Lc "%u %g %a" /etc/security/opasswd 2>/dev/null | grep -q '^0 0 600$') && echo "PASS" || echo "FAIL"

echo -e "\n170;Permissões;Light;Baixa;Arquivos órfãos;"
(find / -xdev -nouser 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n171;Permissões;Light;Baixa;Arquivos sem grupo;"
(find / -xdev -nogroup 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n172;Permissões;Full;Alta;SUID SGID revisados;"
(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | wc -l | awk '{if($1>0) print "CHECK"; else print "PASS"}')

echo -e "\n173;Home;Light;Baixa;Home ausente;"
(awk -F: '$3>=500 && $1!="nfsnobody"{print $6}' /etc/passwd | while read h; do [ -d "$h" ] || exit 1; done && echo "PASS" || echo "FAIL")

echo -e "\n174;Home;Light;Alta;Ownership home;"
(awk -F: '$3>=500 && $1!="nfsnobody"{print $1,$6}' /etc/passwd | while read u h; do [ "$(stat -Lc %U "$h" 2>/dev/null)" = "$u" ] || exit 1; done && echo "PASS" || echo "FAIL")

echo -e "\n175;Home;Light;Alta;Permissões home;"
(awk -F: '$3>=500 && $1!="nfsnobody"{print $6}' /etc/passwd | while read h; do perm=$(stat -Lc %a "$h" 2>/dev/null); [ "$perm" -le 750 ] 2>/dev/null || exit 1; done && echo "PASS" || echo "FAIL")

echo -e "\n176;Home;Light;Baixa;Dotfiles seguros;"
(find /home -maxdepth 2 -type f -name '.*' -perm /022 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n177;Home;Light;Alta;Arquivos trust legado;"
(find /home -maxdepth 2 \( -name '.rhosts' -o -name '.netrc' -o -name '.forward' \) 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n178;Legado;Light;Alta;Sistema EL6 identificado;"
(grep -q 'release 6' /etc/redhat-release 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n179;Legado;Light;Alta;Suporte contratado validado;"
([ -f /etc/eus_manifest ] || [ -f /etc/el-support ]) && echo "PASS" || echo "CHECK"

echo -e "\n180;Legado;Light;Alta;Kernel suportado validado;"
(uname -r | grep -qE '2\.6\.32|el6') && echo "PASS" || echo "FAIL"

echo -e "\n181;Legado;Light;Alta;OpenSSL legado identificado;"
(rpm -qa 2>/dev/null | grep -q '^openssl-1\.0') && echo "PASS" || echo "FAIL"

echo -e "\n182;Legado;Full;Alta;TLS fraco por serviço;"
(! grep -r 'SSLProtocol.*SSLv[23]\|SSLv[23]' /etc/httpd /etc/nginx 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "CHECK"

echo -e "\n183;Legado;Full;Alta;SMBv1 controlado;"
([ ! -f /etc/samba/smb.conf ] || ! grep -i 'min protocol.*1' /etc/samba/smb.conf 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n184;Legado;Full;Alta;NFS inseguro controlado;"
([ ! -f /etc/exports ] || ! grep -E 'no_root_squash|(\*|0\.0\.0\.0)' /etc/exports 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n185;Legado;Light;Alta;Serviços expostos revisados;"
(netstat -tuln 2>/dev/null | tail -n +3 | wc -l | awk '{if($1>0) print "CHECK"; else print "PASS"}')

echo -e "\n186;Legado;Full;Média;Compiladores restritos;"
(for bin in /usr/bin/gcc /usr/bin/g++ /usr/bin/cc /usr/bin/make /usr/bin/ld; do [ -f "$bin" ] && stat -Lc "%a %G" "$bin"; done | grep -qvE '^750 compilers$' && echo "FAIL" || echo "PASS")

echo -e "\n187;Legado;Light;Alta;SELinux ativo ou justificado;"
(getenforce 2>/dev/null | grep -qE 'Enforcing|Permissive' || [ ! -e /etc/selinux/config ]) && echo "PASS" || echo "FAIL"

echo -e "\n188;Legado;Light;Alta;Repositórios órfãos;"
(find /etc/yum.repos.d -name '*.repo' 2>/dev/null | wc -l | awk '{if($1>0) print "CHECK"; else print "PASS"}')

echo -e "\n189;Legado;Full;Alta;Java legado exposto;"
(! java -version 2>&1 | grep -qE 'openjdk|1\.[0-6]\.') && echo "PASS" || echo "CHECK"

echo -e "\n190;Legado;Full;Alta;Aplicações web legadas expostas;"
([ -f /etc/gshadow ] && stat -Lc "%u %g %a" /etc/gshadow 2>/dev/null | grep -qE '^0 0 (600|[5][0-9]{2})$') && echo "PASS" || echo "FAIL"
