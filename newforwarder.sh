#!/bin/bash
function zabbixconf {
 sed -i "12iHostname=$HOSTNAME" /etc/zabbix/zabbix_agentd.conf;
 sed -i '24izabbix ALL=(root) NOPASSWD: /usr/bin/fail2ban-client' /etc/sudoers;
 echo -n "Enter TLSPSKIdentity (Example 1000): "
 read tlsid
 if [[ -n $tlsid ]]
  then
  sed -i "14iTLSPSKIdentity=ID$tlsid" /etc/zabbix/zabbix_agentd.conf;
  else
  echo "Incorrect TLSPSKIdentity"
 fi
}

function sshport {
 echo -n "Enter SSH port: "
 read newssh
 if [[ -n $newssh ]]
  then
  sed -i "s%SSHPort%$newssh%g" /etc/ssh/sshd_config
  sed -i "s%port    = ssh%port    = $newssh%g" /etc/fail2ban/jail.conf
  sed -i "s%EEE_SSH_PORT%$newssh%g" /etc/iptables/rules.v4
  else
  echo "Incorrect port"
 fi
}

function iface {
 hetz_if='eth0'
 arb_if='ens160'
 read -r -p "Change iptables interface eth0 to ens160? [y/N] " response
 if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
 then
        sed -i "s%$hetz_if%$arb_if%g" /etc/iptables/rules.v4
 fi        
}

function vps_ext_ip {
 echo -n "Check and enter external IP" $HOSTNAME
 echo -e
 read vps_ext_ip
 if [[ -n $vps_ext_ip ]]
  then
  sed -i "s%AAA_VPS_EXT_IP%$vps_ext_ip%g" /etc/iptables/rules.v4
  else
  echo "Incorrect value!"
 fi
}

function ddd_rem_ip {
 echo -n "Enter IP destination pfsense"
 echo -e
 read ddd_rem_ip
 if [[ -n $ddd_rem_ip ]]
  then
  sed -i "s%DDD_REM_IP%$ddd_rem_ip%g" /etc/iptables/rules.v4
  else
  echo "Incorrect value!"
 fi
}

function bbb_vps_loc_port {
 echo -n "Enter prerouting ovpn port"
 echo -e
 read bbb_vps_loc_port
 if [[ -n $bbb_vps_loc_port ]]
  then
  sed -i "s%BBB_VPS_LOC_PORT%$bbb_vps_loc_port%g" /etc/iptables/rules.v4
  sed -i "s%CCC_REM_PORT%$bbb_vps_loc_port%g" /etc/iptables/rules.v4
  else
  echo "Incorrect value!"
 fi
}

function back_to_menu {
 read -p "Press enter to continue";
 /home/newforwarder-main/newforwarder.sh;
}

function misha {
echo "IP address: ";
hostname  -I | cut -f1 -d' ';
echo "Hostname: "$HOSTNAME;
sed -n '14p' < /etc/zabbix/zabbix_agentd.conf;
echo "PSK : ";
cat /etc/zabbix/zabbix_agentd.psk;
}

clear
echo -n
echo "1. Start"
echo "2. Clear and notificate Misha"
read number
case $number in
1)
apt update -y;
apt upgrade --allow-downgrades --allow-remove-essential --allow-change-held-packages -y;
timedatectl set-timezone Europe/Moscow;
apt install ssh -y;
apt install openssl -y;
apt install openssh-server -y;
apt install dialog -y;
apt install htop -y;
apt install iptables-persistent -y;
apt install fail2ban -y;
apt install net-tools -y;
apt install unattended-upgrades -y; 
apt install apt-listchanges -y;
dpkg-reconfigure -plow unattended-upgrades;
adduser yura;

mv /etc/sysctl.conf /etc/sysctl.conf.bakapa;
cp /home/newforwarder-main/sysctl-forwarder-2020.conf /etc/sysctl.conf;
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bakapa;
cp /home/newforwarder-main/sshd_config.vpn /etc/ssh/sshd_config;
mv /etc/iptables/rules.v4 /etc/iptables/rules.v4.bakapa;
cp /home/newforwarder-main/iptables/rules.v4 /etc/iptables/rules.v4;
sshport;
echo "Current interface: ";
ifconfig;
iface;
vps_ext_ip;
ddd_rem_ip;
bbb_vps_loc_port;

wget https://repo.zabbix.com/zabbix/5.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.0-1+focal_all.deb;
dpkg -i zabbix-release_5.0-1+focal_all.deb;
apt update --force-yes;
apt install -y zabbix-agent;
mv /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.bakapa;
cp /home/newforwarder-main/zabbix_agentd.conf /etc/zabbix/;
> /etc/zabbix/zabbix_agentd.psk;
openssl rand -hex 32 | tee -a /etc/zabbix/zabbix_agentd.psk;
chmod 400 /etc/zabbix/zabbix_agentd.psk;
chown zabbix:zabbix /etc/zabbix/zabbix_agentd.psk;
zabbixconf;
systemctl restart zabbix-agent;
systemctl enable zabbix-agent;
back_to_menu;
;;

2)
cd /home/;
rm -r /home/newforwarder-main*;
rm zabbix*;
apt-get autoremove --purge;
clear;
misha;
shutdown -r +1 "Server will restart in 1 minutes."
;;

*)
echo "Wrong number!";
back_to_menu;
;;

esac
