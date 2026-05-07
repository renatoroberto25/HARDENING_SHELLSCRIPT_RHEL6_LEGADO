#!/usr/bin/env bash

echo -e "\n[1] Verificar se módulo cramfs está bloqueado"
(modinfo cramfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+cramfs\b' && ! lsmod | grep -q cramfs) || (! modinfo cramfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[2] Verificar se módulo squashfs está bloqueado"
(modinfo squashfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+squashfs\b' && ! lsmod | grep -q squashfs) || (! modinfo squashfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[3] Verificar se módulo udf está bloqueado"
(modinfo udf &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+udf\b' && ! lsmod | grep -q udf) || (! modinfo udf &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[4] Verificar se módulo hfs está bloqueado"
(modinfo hfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+hfs\b' && ! lsmod | grep -q hfs) || (! modinfo hfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[5] Verificar se módulo hfsplus está bloqueado"
(modinfo hfsplus &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+hfsplus\b' && ! lsmod | grep -q hfsplus) || (! modinfo hfsplus &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[6] Verificar se módulo jffs2 está bloqueado"
(modinfo jffs2 &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+jffs2\b' && ! lsmod | grep -q jffs2) || (! modinfo jffs2 &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[7] Verificar se módulo freevxfs está bloqueado"
(modinfo freevxfs &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+freevxfs\b' && ! lsmod | grep -q freevxfs) || (! modinfo freevxfs &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[8] Verificar se overlayfs não está carregado e está bloqueado quando existir"
(modinfo overlay &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+overlay\b' && ! lsmod | grep -q overlay) || (! modinfo overlay &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[9] Verificar se usb_storage está bloqueado"
(modinfo usb-storage &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+usb_storage\b' && ! lsmod | grep -q usb_storage) || (! modinfo usb-storage &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[10] Verificar se dccp não está carregado e está bloqueado"
(modinfo dccp &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+dccp\b' && ! lsmod | grep -q dccp) || (! modinfo dccp &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[11] Verificar se sctp não está carregado e está bloqueado"
(modinfo sctp &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+sctp\b' && ! lsmod | grep -q sctp) || (! modinfo sctp &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[12] Verificar se rds não está carregado e está bloqueado"
(modinfo rds &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+rds\b' && ! lsmod | grep -q rds) || (! modinfo rds &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[13] Verificar se tipc não está carregado e está bloqueado"
(modinfo tipc &>/dev/null && modprobe --showconfig | grep -Pq '\b(install|blacklist)\h+tipc\b' && ! lsmod | grep -q tipc) || (! modinfo tipc &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[14] Verificar valor runtime e persistente de fs.suid_dumpable"
(sysctl -n fs.suid_dumpable 2>/dev/null | grep -q '^0$' && grep -E 'fs.suid_dumpable.*0' /etc/sysctl.conf &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[15] Verificar valor runtime e persistente de randomize_va_space"
(sysctl -n kernel.randomize_va_space 2>/dev/null | grep -q '^2$' && grep -E 'kernel.randomize_va_space.*2' /etc/sysctl.conf &>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[16] Verificar limite de core e fs.suid_dumpable"
(ulimit -c | grep -q '^0$' && sysctl -n fs.suid_dumpable 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n[17] Verificar flag nx na CPU ou evidência de NX ativo"
(grep -q ' nx' /proc/cpuinfo || dmesg | grep -qi 'NX.*active') && echo "PASS" || echo "FAIL"

echo -e "\n[18] Verificar existência e valor restritivo de perf_event_paranoid"
([ ! -e /proc/sys/kernel/perf_event_paranoid ] || sysctl -n kernel.perf_event_paranoid 2>/dev/null | grep -qE '^[2-3]$') && echo "PASS" || echo "FAIL"

echo -e "\n[19] Verificar existência e valor de dmesg_restrict"
([ ! -e /proc/sys/kernel/dmesg_restrict ] || sysctl -n kernel.dmesg_restrict 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[20] Verificar existência e valor de protected_symlinks"
([ ! -e /proc/sys/fs/protected_symlinks ] || sysctl -n fs.protected_symlinks 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[21] Verificar existência e valor de protected_hardlinks"
([ ! -e /proc/sys/fs/protected_hardlinks ] || sysctl -n fs.protected_hardlinks 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[22] Verificar montagem independente para /tmp"
(findmnt -kn /tmp 2>/dev/null | grep -q /tmp) && echo "PASS" || echo "FAIL"

echo -e "\n[23] Verificar montagem independente para /dev/shm"
(findmnt -kn /dev/shm 2>/dev/null | grep -q /dev/shm) && echo "PASS" || echo "FAIL"

echo -e "\n[24] Verificar montagem independente para /var"
(findmnt -kn /var 2>/dev/null | grep -q /var) && echo "PASS" || echo "FAIL"

echo -e "\n[25] Verificar montagem independente para /var/tmp"
(findmnt -kn /var/tmp 2>/dev/null | grep -q /var/tmp) && echo "PASS" || echo "FAIL"

echo -e "\n[26] Verificar montagem independente para /var/log"
(findmnt -kn /var/log 2>/dev/null | grep -q /var/log) && echo "PASS" || echo "FAIL"

echo -e "\n[27] Verificar montagem independente para /var/log/audit"
(findmnt -kn /var/log/audit 2>/dev/null | grep -q /var/log/audit) && echo "PASS" || echo "FAIL"

echo -e "\n[28] Verificar montagem independente para /home"
(findmnt -kn /home 2>/dev/null | grep -q /home) && echo "PASS" || echo "FAIL"

echo -e "\n[29] Verificar nodev nosuid noexec em /tmp"
(findmnt -kn /tmp -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid|noexec)') && echo "PASS" || echo "FAIL"

echo -e "\n[30] Verificar nodev nosuid noexec em /dev/shm"
(findmnt -kn /dev/shm -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid|noexec)') && echo "PASS" || echo "FAIL"

echo -e "\n[31] Verificar nodev nosuid noexec em /var/tmp"
(findmnt -kn /var/tmp -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid|noexec)') && echo "PASS" || echo "FAIL"

echo -e "\n[32] Verificar nodev nosuid em /var/log"
(findmnt -kn /var/log -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid)') && echo "PASS" || echo "FAIL"

echo -e "\n[33] Verificar nodev nosuid em /var/log/audit"
(findmnt -kn /var/log/audit -o OPTIONS 2>/dev/null | grep -qE '(nodev|nosuid)') && echo "PASS" || echo "FAIL"

echo -e "\n[34] Verificar nodev em /home"
(findmnt -kn /home -o OPTIONS 2>/dev/null | grep -q nodev) && echo "PASS" || echo "FAIL"

echo -e "\n[35] Verificar diretórios world-writable sem sticky bit"
(find / -xdev -type d -perm -0002 ! -perm -1000 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n[36] Verificar permissão de /tmp"
(stat -Lc "%a" /tmp 2>/dev/null | grep -q '^1777$') && echo "PASS" || echo "FAIL"

echo -e "\n[37] Verificar permissão de /var/tmp"
(stat -Lc "%a" /var/tmp 2>/dev/null | grep -q '^1777$') && echo "PASS" || echo "FAIL"

echo -e "\n[38] Verificar permissão de /dev/shm"
(stat -Lc "%a" /dev/shm 2>/dev/null | grep -q '^1777$') && echo "PASS" || echo "FAIL"

echo -e "\n[39] Verificar status e chkconfig do autofs"
(! chkconfig autofs on 2>/dev/null && ! service autofs status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[40] Verificar password em /boot/grub/grub.conf"
([ -f /boot/grub/grub.conf ] && grep -q '^password' /boot/grub/grub.conf) && echo "PASS" || echo "FAIL"

echo -e "\n[41] Verificar owner e modo de /boot/grub/grub.conf"
([ -f /boot/grub/grub.conf ] && stat -Lc "%u %g %a" /boot/grub/grub.conf | grep -q '^0 0 600$') && echo "PASS" || echo "FAIL"

echo -e "\n[42] Verificar SINGLE=/sbin/sulogin em /etc/sysconfig/init"
([ -f /etc/sysconfig/init ] && grep -q 'SINGLE=/sbin/sulogin' /etc/sysconfig/init) && echo "PASS" || echo "FAIL"

echo -e "\n[43] Verificar se pacote prelink está ausente"
(! rpm -qa 2>/dev/null | grep -q '^prelink') && echo "PASS" || echo "FAIL"

echo -e "\n[44] Verificar pacote e serviço xinetd"
(! rpm -qa 2>/dev/null | grep -q '^xinetd' && ! chkconfig xinetd on 2>/dev/null && ! service xinetd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[45] Verificar service ntpd status"
(service ntpd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[46] Verificar server ou pool válido no ntp.conf"
([ -f /etc/ntp.conf ] && grep -E '^\s*(server|pool)' /etc/ntp.conf 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[47] Verificar chkconfig ntpd on"
(chkconfig ntpd on 2>/dev/null || chkconfig --list ntpd 2>/dev/null | grep -q '3:on') && echo "PASS" || echo "FAIL"

echo -e "\n[48] Verificar ntpd ativo e ausência de serviço concorrente ativo"
(service ntpd status 2>/dev/null && ! service chronyd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[49] Verificar pacotes X11 instalados"
(! rpm -qa 2>/dev/null | grep -qE '^xorg-x11-server') && echo "PASS" || echo "FAIL"

echo -e "\n[50] Verificar serviço avahi-daemon"
(! chkconfig avahi-daemon on 2>/dev/null && ! service avahi-daemon status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[51] Verificar serviço cups"
(! chkconfig cups on 2>/dev/null && ! service cups status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[52] Verificar servidor DHCP"
(rpm -q dhcp-server >/dev/null 2>&1 || rpm -q dhcpd >/dev/null 2>&1) && echo "FAIL" || echo "PASS"

echo -e "\n[53] Verificar pacote openldap-servers"
(! rpm -qa 2>/dev/null | grep -q '^openldap-servers') && echo "PASS" || echo "FAIL"

echo -e "\n[54] Verificar pacote bind"
(! rpm -qa 2>/dev/null | grep -q '^bind') && echo "PASS" || echo "FAIL"

echo -e "\n[55] Verificar pacote vsftpd"
(! rpm -qa 2>/dev/null | grep -q '^vsftpd') && echo "PASS" || echo "FAIL"

echo -e "\n[56] Verificar pacote httpd"
(! rpm -qa 2>/dev/null | grep -q '^httpd') && echo "PASS" || echo "FAIL"

echo -e "\n[57] Verificar pacotes dovecot e cyrus-imapd"
(! rpm -qa 2>/dev/null | grep -qE '^(dovecot|cyrus-imapd)') && echo "PASS" || echo "FAIL"

echo -e "\n[58] Verificar pacotes samba"
(! rpm -qa 2>/dev/null | grep -q '^samba') && echo "PASS" || echo "FAIL"

echo -e "\n[59] Verificar pacotes squid"
(! rpm -qa 2>/dev/null | grep -q '^squid') && echo "PASS" || echo "FAIL"

echo -e "\n[60] Verificar serviço snmpd"
(! chkconfig snmpd on 2>/dev/null && ! service snmpd status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[61] Verificar pacotes ypserv"
(! rpm -qa 2>/dev/null | grep -q '^ypserv') && echo "PASS" || echo "FAIL"

echo -e "\n[62] Verificar pacote telnet-server"
(! rpm -qa 2>/dev/null | grep -q '^telnet-server') && echo "PASS" || echo "FAIL"

echo -e "\n[63] Verificar bind em 127.0.0.1 ou ausência de escuta externa"
(netstat -tuln 2>/dev/null | grep -E ':(25|587)\s' | grep -q '127.0.0.1' || ! netstat -tuln 2>/dev/null | grep -qE ':(25|587)\s') && echo "PASS" || echo "FAIL"

echo -e "\n[64] Verificar nfs e nfslock"
(! chkconfig nfs on 2>/dev/null && ! chkconfig nfslock on 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[65] Verificar serviço rpcbind ou portmap"
(! chkconfig rpcbind on 2>/dev/null && ! chkconfig portmap on 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[66] Verificar rsync em modo daemon"
(! chkconfig rsync on 2>/dev/null && ! grep -q 'enable = true' /etc/rsyncd.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[67] Verificar pacote ypbind"
(! rpm -qa 2>/dev/null | grep -q '^ypbind') && echo "PASS" || echo "FAIL"

echo -e "\n[68] Verificar pacote rsh"
(! rpm -qa 2>/dev/null | grep -q '^rsh') && echo "PASS" || echo "FAIL"

echo -e "\n[69] Verificar pacote talk"
(! rpm -qa 2>/dev/null | grep -q '^talk') && echo "PASS" || echo "FAIL"

echo -e "\n[70] Verificar pacote telnet"
(! rpm -qa 2>/dev/null | grep -q '^telnet-' && ! rpm -qa 2>/dev/null | grep -q '^telnet$') && echo "PASS" || echo "FAIL"

echo -e "\n[71] Verificar pacote openldap-clients"
(! rpm -qa 2>/dev/null | grep -q '^openldap-clients') && echo "PASS" || echo "FAIL"

echo -e "\n[72] Verificar serviços ativos no chkconfig"
([ $(chkconfig --list 2>/dev/null | grep -c ':on') -le 10 ]) && echo "PASS" || echo "FAIL"

echo -e "\n[73] Verificar pacote tftp-server"
(! rpm -qa 2>/dev/null | grep -q '^tftp-server') && echo "PASS" || echo "FAIL"

echo -e "\n[74] Verificar gpgcheck=1 em yum.conf e repos"
(grep -r 'gpgcheck=1' /etc/yum.conf /etc/yum.repos.d/ 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[75] Verificar atualizações pendentes"
([ $(yum check-update 2>/dev/null | wc -l) -eq 1 ]) && echo "PASS" || echo "FAIL"

echo -e "\n[76] Verificar cron.allow e cron.deny"
([ -f /etc/cron.allow ] && [ ! -f /etc/cron.deny ]) && echo "PASS" || echo "FAIL"

echo -e "\n[77] Verificar at.allow e at.deny"
([ -f /etc/at.allow ] && [ ! -f /etc/at.deny ]) && echo "PASS" || echo "FAIL"

echo -e "\n[78] Verificar net.ipv4.ip_forward"
(sysctl -n net.ipv4.ip_forward 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n[79] Verificar sysctl de redirects"
(sysctl -n net.ipv4.conf.all.send_redirects 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n[80] Verificar accept_source_route"
(sysctl -n net.ipv4.conf.all.accept_source_route 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n[81] Verificar parâmetros ICMP redirects"
(sysctl -n net.ipv4.conf.all.accept_redirects 2>/dev/null | grep -q '^0$' && sysctl -n net.ipv4.conf.all.secure_redirects 2>/dev/null | grep -q '^0$') && echo "PASS" || echo "FAIL"

echo -e "\n[82] Verificar rp_filter"
(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[83] Verificar icmp_echo_ignore_broadcasts"
(sysctl -n net.ipv4.icmp_echo_ignore_broadcasts 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[84] Verificar icmp_ignore_bogus_error_responses"
(sysctl -n net.ipv4.icmp_ignore_bogus_error_responses 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[85] Verificar tcp_syncookies"
(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null | grep -q '^1$') && echo "PASS" || echo "FAIL"

echo -e "\n[86] Verificar política IPv6 conforme baseline"
(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null | grep -q '^1$' || [ ! -e /proc/sys/net/ipv6 ]) && echo "PASS" || echo "FAIL"

echo -e "\n[87] Verificar interfaces wireless e bluetooth ativas"
([ $(iwconfig 2>/dev/null | grep -c 'no wireless') -gt 0 ] || ! rfkill list 2>/dev/null | grep -q 'Bluetooth.*unblocked') && echo "PASS" || echo "FAIL"

echo -e "\n[88] Verificar serviço iptables e chkconfig"
(chkconfig iptables on 2>/dev/null || service iptables status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[89] Verificar policy INPUT DROP ou regras equivalentes"
(iptables -L INPUT 2>/dev/null | grep -qE 'policy (DROP|REJECT)') && echo "PASS" || echo "FAIL"

echo -e "\n[90] Verificar regras de loopback no iptables"
(iptables -L 2>/dev/null | grep -q 'lo') && echo "PASS" || echo "FAIL"

echo -e "\n[91] Verificar regra state ESTABLISHED,RELATED"
(iptables -L -n 2>/dev/null | grep -qE 'ESTABLISHED.*RELATED|RELATED.*ESTABLISHED') && echo "PASS" || echo "FAIL"

echo -e "\n[92] Verificar listeners e regras correspondentes"
(netstat -tuln 2>/dev/null | wc -l | awk '{if($1>2) print "PASS"; else print "FAIL"}')

echo -e "\n[93] Verificar owner e modo de arquivos SSH"
(stat -Lc "%u %g %a" /etc/ssh/sshd_config 2>/dev/null | grep -q '^0 0 600$' && stat -Lc "%u %g %a" /etc/ssh 2>/dev/null | grep -q '^0 0 700$') && echo "PASS" || echo "FAIL"

echo -e "\n[94] Verificar Protocol 2 no sshd_config"
(grep -q '^Protocol 2' /etc/ssh/sshd_config && ! grep -q '^Protocol 1' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[95] Verificar diretivas Allow/Deny no sshd_config"
(grep -qE '^(AllowUsers|AllowGroups|DenyUsers|DenyGroups)' /etc/ssh/sshd_config 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[96] Verificar SyslogFacility"
(grep -q '^SyslogFacility' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[97] Verificar LogLevel"
(grep -qE '^LogLevel\s+(INFO|VERBOSE|DEBUG)' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[98] Verificar X11Forwarding no"
(grep -q '^X11Forwarding no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[99] Verificar MaxAuthTries"
(grep -qE '^MaxAuthTries\s+[1-5]' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[100] Verificar IgnoreRhosts"
(grep -q '^IgnoreRhosts yes' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[101] Verificar HostbasedAuthentication no"
(grep -q '^HostbasedAuthentication no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[102] Verificar PermitRootLogin"
(grep -qE '^PermitRootLogin\s+(no|without-password|forced-commands-only)' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[103] Verificar PermitEmptyPasswords no"
(grep -q '^PermitEmptyPasswords no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[104] Verificar PermitUserEnvironment no"
(grep -q '^PermitUserEnvironment no' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[105] Verificar UsePAM"
(grep -q '^UsePAM yes' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[106] Verificar parâmetros ClientAlive"
(grep -qE '^ClientAliveInterval' /etc/ssh/sshd_config && grep -qE '^ClientAliveCountMax' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[107] Verificar LoginGraceTime"
(grep -qE '^LoginGraceTime\s+[1-9][0-9]?s?$|^LoginGraceTime\s+[1-5][0-9]{2}s?$' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[108] Verificar MaxStartups"
(grep -qE '^MaxStartups' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[109] Verificar AllowTcpForwarding"
(grep -qE '^AllowTcpForwarding\s+(no|local)' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[110] Verificar diretiva Banner"
(grep -q '^Banner' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[111] Verificar Ciphers e ausência de algoritmos fracos"
(! grep -qE 'Ciphers.*arcfour|Ciphers.*cbc' /etc/ssh/sshd_config 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[112] Verificar MACs e ausência de algoritmos fracos"
(! grep -qE 'MACs.*md5|MACs.*sha1' /etc/ssh/sshd_config 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[113] Verificar KexAlgorithms quando aplicável"
(grep -qE '^KexAlgorithms' /etc/ssh/sshd_config 2>/dev/null || ! grep -q '^KexAlgorithms' /etc/ssh/sshd_config) && echo "PASS" || echo "FAIL"

echo -e "\n[114] Verificar pam_cracklib ou equivalente na stack PAM"
(grep -r 'pam_cracklib' /etc/pam.d/ 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[115] Verificar minlen dcredit ucredit lcredit ocredit"
(grep 'pam_cracklib' /etc/pam.d/* 2>/dev/null | grep -qE 'minlen=|dcredit=|ucredit=|lcredit=|ocredit=') && echo "PASS" || echo "FAIL"

echo -e "\n[116] Verificar pam_tally2 nas stacks PAM"
(grep -r 'pam_tally2' /etc/pam.d/ 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[117] Verificar remember e permissões de opasswd"
(grep 'pam_unix' /etc/pam.d/* 2>/dev/null | grep -q 'remember=' && [ -f /etc/security/opasswd ] && stat -Lc "%a %u %g" /etc/security/opasswd 2>/dev/null | grep -q '^600 0 0$') && echo "PASS" || echo "FAIL"

echo -e "\n[118] Verificar ENCRYPT_METHOD SHA512 e pam_unix sha512"
(grep -qE '^ENCRYPT_METHOD.*SHA512' /etc/login.defs && grep 'pam_unix' /etc/pam.d/* 2>/dev/null | grep -q 'sha512') && echo "PASS" || echo "FAIL"

echo -e "\n[119] Verificar PASS_MAX_DAYS"
(grep -qE '^PASS_MAX_DAYS\s+([0-9]{1,2}|90)' /etc/login.defs) && echo "PASS" || echo "FAIL"

echo -e "\n[120] Verificar PASS_MIN_DAYS"
(grep -qE '^PASS_MIN_DAYS\s+[1-9]' /etc/login.defs) && echo "PASS" || echo "FAIL"

echo -e "\n[121] Verificar PASS_WARN_AGE"
(grep -qE '^PASS_WARN_AGE\s+[1-9]' /etc/login.defs) && echo "PASS" || echo "FAIL"

echo -e "\n[122] Verificar useradd -D INACTIVE"
(grep -qE '^INACTIVE\s+([0-9]|30)' /etc/default/useradd 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[123] Verificar last password change no futuro"
(awk -F: '{if(length($3)>0 && $3/86400>now) c++} END{exit c>0}' now="$(date +%s)" /etc/shadow) && echo "PASS" || echo "FAIL"

echo -e "\n[124] Verificar contas UID 0"
(awk -F: '($3==0 && $1!="root") {c++} END{exit c>0}' /etc/passwd) && echo "PASS" || echo "FAIL"

echo -e "\n[125] Verificar grupos GID 0"
(awk -F: '($3==0 && $1!="root") {c++} END{exit c>0}' /etc/group) && echo "PASS" || echo "FAIL"

echo -e "\n[126] Verificar shells de contas de sistema"
(awk -F: '($3<1000 && $7 !~ /(nologin|shutdown|halt|sync)$/) {c++} END{exit c>0}' /etc/passwd) && echo "PASS" || echo "FAIL"

echo -e "\n[127] Verificar conteúdo de /etc/shells"
([ -f /etc/shells ] && [ -s /etc/shells ]) && echo "PASS" || echo "FAIL"

echo -e "\n[128] Verificar PATH do root"
(! echo $PATH | grep -qE '::' && ! echo $PATH | grep -qE '^/.*:\.') && echo "PASS" || echo "FAIL"

echo -e "\n[129] Verificar umask em perfis globais"
(grep -r '^umask' /etc/bashrc /etc/bash.bashrc /etc/profile 2>/dev/null | grep -qE '0077|0027') && echo "PASS" || echo "FAIL"

echo -e "\n[130] Verificar TMOUT em perfis globais"
(grep -r '^TMOUT=' /etc/profile /etc/bashrc 2>/dev/null | grep -qE 'TMOUT=[0-9]{3,}') && echo "PASS" || echo "FAIL"

echo -e "\n[131] Verificar sudoers e arquivos em sudoers.d"
([ -f /etc/sudoers ] && stat -Lc "%a %u %g" /etc/sudoers 2>/dev/null | grep -q '^440 0 0$') && echo "PASS" || echo "FAIL"

echo -e "\n[132] Verificar Defaults requiretty"
(grep -r 'Defaults.*requiretty' /etc/sudoers* 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[133] Verificar logfile ou syslog no sudoers"
(grep -r 'logfile=\|syslog=' /etc/sudoers* 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[134] Verificar sudoers por exceções de autenticação"
(! grep -r 'NOPASSWD' /etc/sudoers* 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[135] Verificar timestamp_timeout"
(grep -r 'timestamp_timeout=' /etc/sudoers* 2>/dev/null | grep -qE 'timestamp_timeout=[0-5]') && echo "PASS" || echo "FAIL"

echo -e "\n[136] Verificar pam_wheel no su"
(grep -q 'pam_wheel' /etc/pam.d/su 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[137] Verificar pacote e serviço rsyslog"
(rpm -qa 2>/dev/null | grep -q '^rsyslog' && service rsyslog status 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[138] Verificar destinos em /etc/rsyslog.conf"
(grep -qE '^\*\.\*|@|@@' /etc/rsyslog.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[139] Verificar configuração de logrotate"
([ -d /etc/logrotate.d ] && [ $(ls -1 /etc/logrotate.d 2>/dev/null | wc -l) -gt 0 ]) && echo "PASS" || echo "FAIL"

echo -e "\n[140] Verificar pacote audit"
(rpm -qa 2>/dev/null | grep -q '^audit') && echo "PASS" || echo "FAIL"

echo -e "\n[141] Verificar service auditd status"
(service auditd status 2>/dev/null || auditctl -l 2>/dev/null | grep -q -) && echo "PASS" || echo "FAIL"

echo -e "\n[142] Verificar chkconfig auditd on"
(chkconfig auditd on 2>/dev/null || chkconfig --list auditd 2>/dev/null | grep -q '3:on') && echo "PASS" || echo "FAIL"

echo -e "\n[143] Verificar audit=1 no grub.conf"
([ -f /boot/grub/grub.conf ] && grep -q 'audit=1' /boot/grub/grub.conf) && echo "PASS" || echo "FAIL"

echo -e "\n[144] Verificar max_log_file em auditd.conf"
(grep -q '^max_log_file' /etc/audit/auditd.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[145] Verificar max_log_file_action"
(grep -qE 'max_log_file_action\s+(keep_logs|syslog)' /etc/audit/auditd.conf 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[146] Verificar regras audit de time-change"
(auditctl -l 2>/dev/null | grep -qE 'adjtimex|settimeofday|sethostname|setdomainname') && echo "PASS" || echo "FAIL"

echo -e "\n[147] Verificar regras audit de identity"
(auditctl -l 2>/dev/null | grep -qE '/etc/passwd|/etc/group|/etc/shadow') && echo "PASS" || echo "FAIL"

echo -e "\n[148] Verificar regras audit de system-locale e network"
(auditctl -l 2>/dev/null | grep -qE '/etc/issue|/etc/hostname|/etc/network') && echo "PASS" || echo "FAIL"

echo -e "\n[149] Verificar regras audit de MAC-policy"
([ ! -e /etc/selinux/config ] || auditctl -l 2>/dev/null | grep -qi selinux) && echo "PASS" || echo "FAIL"

echo -e "\n[150] Verificar regras audit de logins"
(auditctl -l 2>/dev/null | grep -qE '/var/log/faillog|/var/log/lastlog|/var/log/tallylog') && echo "PASS" || echo "FAIL"

echo -e "\n[151] Verificar regras audit EACCES EPERM"
(auditctl -l 2>/dev/null | grep -qE 'EACCES|EPERM') && echo "PASS" || echo "FAIL"

echo -e "\n[152] Verificar regras audit para SUID SGID"
(auditctl -l 2>/dev/null | grep -qE 'perm=-x') && echo "PASS" || echo "FAIL"

echo -e "\n[153] Verificar regras audit de mount"
(auditctl -l 2>/dev/null | grep -qE 'mount|umount') && echo "PASS" || echo "FAIL"

echo -e "\n[154] Verificar regras audit delete"
(auditctl -l 2>/dev/null | grep -qE 'unlink|unlinkat|rename|renameat') && echo "PASS" || echo "FAIL"

echo -e "\n[155] Verificar regras audit de insmod rmmod modprobe"
(auditctl -l 2>/dev/null | grep -qE 'insmod|rmmod|modprobe') && echo "PASS" || echo "FAIL"

echo -e "\n[156] Verificar regras audit de sudoers"
(auditctl -l 2>/dev/null | grep -q '/etc/sudoers') && echo "PASS" || echo "FAIL"

echo -e "\n[157] Verificar -e 2 em regras audit"
(auditctl -l 2>/dev/null | grep -q '^-e 2') && echo "PASS" || echo "FAIL"

echo -e "\n[158] Verificar pacote aide"
(rpm -qa 2>/dev/null | grep -q '^aide') && echo "PASS" || echo "FAIL"

echo -e "\n[159] Verificar existência da base AIDE"
([ -f /var/lib/aide/aide.db ] || [ -f /var/lib/aide/aide.db.gz ]) && echo "PASS" || echo "FAIL"

echo -e "\n[160] Verificar cron de execução do AIDE"
(grep -r '/usr/sbin/aide' /etc/cron* /var/spool/cron 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[161] Verificar owner e modo de /etc/passwd"
([ -f /etc/passwd ] && stat -Lc "%u %g %a" /etc/passwd 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n[162] Verificar owner e modo de /etc/passwd-"
([ ! -f /etc/passwd- ] || stat -Lc "%u %g %a" /etc/passwd- 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n[163] Verificar owner e modo de /etc/shadow"
([ -f /etc/shadow ] && stat -Lc "%u %g %a" /etc/shadow 2>/dev/null | grep -qE '^0 0 0+$') && echo "PASS" || echo "FAIL"

echo -e "\n[164] Verificar owner e modo de /etc/shadow-"
([ ! -f /etc/shadow- ] || stat -Lc "%u %g %a" /etc/shadow- 2>/dev/null | grep -qE '^0 0 0+$') && echo "PASS" || echo "FAIL"

echo -e "\n[165] Verificar owner e modo de /etc/gshadow"
([ -f /etc/gshadow ] && stat -Lc "%u %g %a" /etc/gshadow 2>/dev/null | grep -qE '^0 0 (600|[5][0-9]{2})$') && echo "PASS" || echo "FAIL"

echo -e "\n[166] Verificar owner e modo de /etc/gshadow-"
([ ! -f /etc/gshadow- ] || stat -Lc "%u %g %a" /etc/gshadow- 2>/dev/null | grep -qE '^0 0 (600|[5][0-9]{2})$') && echo "PASS" || echo "FAIL"

echo -e "\n[167] Verificar owner e modo de /etc/group"
([ -f /etc/group ] && stat -Lc "%u %g %a" /etc/group 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n[168] Verificar owner e modo de /etc/group-"
([ ! -f /etc/group- ] || stat -Lc "%u %g %a" /etc/group- 2>/dev/null | grep -qE '^0 0 64[0-4]$') && echo "PASS" || echo "FAIL"

echo -e "\n[169] Verificar owner e modo de opasswd quando existir"
([ ! -f /etc/security/opasswd ] || stat -Lc "%u %g %a" /etc/security/opasswd 2>/dev/null | grep -q '^0 0 600$') && echo "PASS" || echo "FAIL"

echo -e "\n[170] Verificar arquivos sem usuário válido"
(find / -xdev -nouser 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n[171] Verificar arquivos sem grupo válido"
(find / -xdev -nogroup 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n[172] Listar arquivos SUID SGID locais"
(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | wc -l | awk '{if($1>0) print "CHECK"; else print "PASS"}')

echo -e "\n[173] Verificar usuários com home inexistente"
(awk -F: '$3>=500 && $1!="nfsnobody"{print $6}' /etc/passwd | while read h; do [ -d "$h" ] || exit 1; done && echo "PASS" || echo "FAIL")

echo -e "\n[174] Verificar owner dos diretórios home"
(awk -F: '$3>=500 && $1!="nfsnobody"{print $1,$6}' /etc/passwd | while read u h; do [ "$(stat -Lc %U "$h" 2>/dev/null)" = "$u" ] || exit 1; done && echo "PASS" || echo "FAIL")

echo -e "\n[175] Verificar permissões de home"
(awk -F: '$3>=500 && $1!="nfsnobody"{print $6}' /etc/passwd | while read h; do perm=$(stat -Lc %a "$h" 2>/dev/null); [ "$perm" -le 750 ] 2>/dev/null || exit 1; done && echo "PASS" || echo "FAIL")

echo -e "\n[176] Verificar permissões de dotfiles"
(find /home -maxdepth 2 -type f -name '.*' -perm /022 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n[177] Verificar arquivos de trust legado"
(find /home -maxdepth 2 \( -name '.rhosts' -o -name '.netrc' -o -name '.forward' \) 2>/dev/null | wc -l | awk '{if($1==0) print "PASS"; else print "FAIL"}')

echo -e "\n[178] Verificar /etc/redhat-release e versão principal"
(grep -q 'release 6' /etc/redhat-release 2>/dev/null) && echo "PASS" || echo "FAIL"

echo -e "\n[179] Verificar evidência de suporte ou exceção operacional"
([ -f /etc/eus_manifest ] || [ -f /etc/el-support ]) && echo "PASS" || echo "CHECK"

echo -e "\n[180] Verificar versão do kernel em execução"
(uname -r | grep -qE '2\.6\.32|el6') && echo "PASS" || echo "FAIL"

echo -e "\n[181] Verificar versão do pacote openssl"
(rpm -qa 2>/dev/null | grep -q '^openssl-1\.0') && echo "PASS" || echo "FAIL"

echo -e "\n[182] Verificar configuração TLS por serviço"
(! grep -r 'SSLProtocol.*SSLv[23]\|SSLv[23]' /etc/httpd /etc/nginx 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "CHECK"

echo -e "\n[183] Verificar configuração min protocol no Samba quando aplicável"
([ ! -f /etc/samba/smb.conf ] || ! grep -i 'min protocol.*1' /etc/samba/smb.conf 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[184] Verificar /etc/exports"
([ ! -f /etc/exports ] || ! grep -E 'no_root_squash|(\*|0\.0\.0\.0)' /etc/exports 2>/dev/null | grep -qv '^#') && echo "PASS" || echo "FAIL"

echo -e "\n[185] Verificar portas em escuta com netstat"
(netstat -tuln 2>/dev/null | tail -n +3 | wc -l | awk '{if($1>0) print "CHECK"; else print "PASS"}')

echo -e "\n[186] Verificar pacotes de compilação instalados"
(! rpm -qa 2>/dev/null | grep -qEo '^(gcc|make|gcc-c\+\+)') && echo "PASS" || echo "FAIL"

echo -e "\n[187] Verificar estado SELinux"
(getenforce 2>/dev/null | grep -qE 'Enforcing|Permissive' || [ ! -e /etc/selinux/config ]) && echo "PASS" || echo "FAIL"

echo -e "\n[188] Verificar arquivos em /etc/yum.repos.d"
(find /etc/yum.repos.d -name '*.repo' 2>/dev/null | wc -l | awk '{if($1>0) print "CHECK"; else print "PASS"}')

echo -e "\n[189] Verificar versões Java e processos associados"
(! java -version 2>&1 | grep -qE 'openjdk|1\.[0-6]\.') && echo "PASS" || echo "CHECK"

echo -e "\n[190] Verificar permissões de /etc/gshadow"
([ -f /etc/gshadow ] && stat -Lc "%u %g %a" /etc/gshadow 2>/dev/null | grep -qE '^0 0 (600|[5][0-9]{2})$') && echo "PASS" || echo "FAIL"
