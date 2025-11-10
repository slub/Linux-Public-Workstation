#!/bin/bash

# needs: ethtool
# startup script, called once on computer startup via systemd service

# try to mount swap partition
/opt/slub/tryswap.sh &

# set hostname based on IP given from DHCP server when booting from the network
/opt/slub/sethostname.sh

# initial (empty) home dir ramdisks, needed by lightdm
if [ $(cat /opt/slub/REFERENZ_PC) != "$HOSTNAME" ]; then
	mount -ttmpfs -onoexec none /home/www
	mount -ttmpfs -onoexec none /home/wwwen
fi

# Schorschii's WOLenabler(TM) to enable WOL on all interfaces for next startup
for iface in $(ip addr list | awk -F': ' '/^[0-9]/ {print $2}'); do
	if [ "$iface" == "lo" ]; then continue; fi
	echo "Enabling WOL on interface: $iface" >> /tmp/wolenabler.log
	ethtool -s "$iface" wol g || true
done
