if [[ $EUID -ne 0 ]]; then
echo "You must be root to do this DOH...." 1>&2
        exit 100
        fi

        clear


clear
echo "DISCLAIMER"
echo " # This script is made available to you without any express, implied or "
echo " # statutory warranty, not even the implied warranty of "
echo " # merchantability or fitness for a particular purpose, or the "
echo " # warranty of title. The entire risk of the use or the results from the use of this script remains with you."
echo
echo -e "\033[1;33m # This script was written by Zombu2. Questions? visit me on IRC @ irc.synIRC.net #nZEDb\033[0m"
echo
echo "---------------------------------------------------------------------------------------------------------------"
echo "Do you Agree?"
echo "y=YES n=NO"

read CHOICE
if [[ $CHOICE != "y" ]]; then
exit
fi

clear

# creating files
touch /home/voipbl
touch /home/voipbl.sh
touch /home/voipbl.conf

echo "# update blacklist each 4 hours" >> /etc/cron.d/voipbl
echo "0 */4 * * * * root /usr/local/bin/voipbl.sh" >> /etc/cron.d/voipbl

echo "#!/bin/bash" >> /usr/local/bin/voipbl.sh
echo "wget -qO - http://www.voipbl.org/update/ | awk '{print "iptables -A INPUT -source "$1" -j DROP"}'" >> /usr/local/bin/voipbl.sh

echo "[asterisk-iptables]" >> /etc/fail2ban/jail.conf
echo "action   = iptables-allports[name=ASTERISK, protocol=all]" >> /etc/fail2ban/jail.conf
echo "voipbl[serial=XXXXXXXXXX]" >> /etc/fail2ban/jail.conf

echo "# Description: Configuration for Fail2Ban" >> /etc/fail2ban/action.d/voipbl.conf
echo "[Definition]" >> /etc/fail2ban/action.d/voipbl.conf
echo "actionban   = <getcmd> \"<url>/ban/?serial=<serial>&ip=<ip>&count=<failures>\"" >> /etc/fail2ban/action.d/voipbl.conf
echo "actionunban = <getcmd> \"<url>/unban/?serial=<serial>&ip=<ip>&count=<failures>\"" >> /etc/fail2ban/action.d/voipbl.conf
echo "[Init]" >> /etc/fail2ban/action.d/voipbl.conf
echo "getcmd = wget --no-verbose --tries=3 --waitretry=10 --connect-timeout=10 --read-timeout=60 --retry-connrefused --output-document=- --user-agent=Fail2Ban " >> /etc/fail2ban/action.d/voipbl.conf
echo "url = http://www.voipbl.org" >> /etc/fail2ban/action.d/voipbl.conf
chmod 700 /usr/local/bin/voipbl.sh
service fail2ban restart
