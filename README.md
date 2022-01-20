Bash скрипт для настройки нового форвардера Aruba или Hetzner на базе Ubuntu. 
Что он делает: обновление системы, установка часового пояса Europe/Moscow, включение автообновлений, установка софта, замена sshd.conf, iptables, sysctl, zabbix_agentd и т.д.

Загрузка и запуск скрипта:
cd /home/;
wget https://github.com/bokhanych/newforwarder/archive/refs/heads/main.zip;
unzip main.zip;
chmod 770 /home/newforwarder-main/newforwarder.sh;
/home/newforwarder-main/newforwarder.sh;
