

#!/bin/bash

if [[ $EUID -ne 0 ]]; then
        echo "You must be root to do this DOH...." 1>&2
    exit 100
fi

clear

clear
echo -e "DISCLAIMER
# This script is made available to you without any express, implied or 
# statutory warranty, not even the implied warranty of 
# merchantability or fitness for a particular purpose, or the 
# warranty of title. The entire risk of the use or the results from the use of this script remains with you.

\033[1;33m # This script was written by Zombu2. Questions? visit me on IRC @ irc.synIRC.net #nZEDb\033[0m\n
---------------------------------------------------------------------------------------------------------------"
echo -n "Do you Agree? [y=YES] [n=NO] : "

shopt -s nocasematch

read CHOICE
if ! [[ $CHOICE =~ ^(y|yes)$ ]]; then
        exit
fi

shopt -u nocasematch

clear

# creating files
touch /etc/cron.d/voipbl
touch /usr/local/bin/voipbl.sh
touch /etc/fail2ban/action.d/voipbl.conf

echo "# update blacklist each 4 hours
0 */4 * * * * root /usr/local/bin/voipbl.sh" >> /etc/cron.d/voipbl

echo "#!/bin/bash
wget -qO - http://www.voipbl.org/update/ | awk '{print \"iptables -A INPUT -source \"\$1\" -j DROP\"}'" >> /usr/local/bin/voipbl.sh

echo "[asterisk-iptables]
action   = iptables-allports[name=ASTERISK, protocol=all]
voipbl[serial=XXXXXXXXXX]" >> /etc/fail2ban/jail.conf

echo "# Description: Configuration for Fail2Ban
[Definition]
actionban   = <getcmd> \"<url>/ban/?serial=<serial>&ip=<ip>&count=<failures>\"
actionunban = <getcmd> \"<url>/unban/?serial=<serial>&ip=<ip>&count=<failures>\"
[Init]
getcmd = wget --no-verbose --tries=3 --waitretry=10 --connect-timeout=10 --read-timeout=60 --retry-connrefused --output-document=- --user-agent=Fail2Ban
url = http://www.voipbl.org" >> /etc/fail2ban/action.d/voipbl.conf

service fail2ban restart

echo "Script install complete"

sleep 5
exit

