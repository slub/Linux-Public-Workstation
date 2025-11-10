#!/bin/bash

# autostart applications based on workstation type


case "$HOSTNAME" in
	BRE080|BRE081|BRE082|BRE083|BRE084|BRE085|BRE086|BRE087|BRE088|BRE089|BRE090|BRE091|BRE092|BRE093|BRE094|BRE095|BRE096|BRE097|BRE098|BRE099)
		if [ "$HOSTNAME" == "BRE082" ]; then
			# mirror screen <-> projector
			(sleep 15 && xrandr --output HDMI-1 --mode 1920x1200 --fb 1920x1200 --panning 1920x1200* --output DP-1 --mode 1920x1200 --same-as HDMI-1) &
			if [ "$USER" == "wwwen" ]; then
				ln -s /opt/slub/desktop-icons/schulcontrol.desktop "$HOME/Desktop"
			else
				ln -s /opt/slub/desktop-icons/schulcontrol.desktop "$HOME/Schreibtisch"
			fi
		fi
		if [ "$HOSTNAME" == "BRE091" ]; then
			# mirror screen <-> projector
			(sleep 15 && xrandr --output HDMI-1 --mode 1920x1200 --fb 1920x1200 --panning 1920x1200* --output DP-1 --mode 1920x1200 --same-as HDMI-1) &
			if [ "$USER" == "wwwen" ]; then
				ln -s /opt/slub/desktop-icons/schulcontrol.desktop "$HOME/Desktop"
			else
				ln -s /opt/slub/desktop-icons/schulcontrol.desktop "$HOME/Schreibtisch"
			fi
		fi
		if [ "$HOSTNAME" == "BRE080" ]; then
			# mirror screen <-> projector
			(sleep 15 && xrandr --output HDMI-1 --mode 1680x1050 --fb 1680x1050 --panning 1680x1050* --output DP-1 --mode 1680x1050 --same-as HDMI-1) &
		fi
		# no idle logout
		(sleep 2 && killall idle-logout.sh) &
		(sleep 12 && google-chrome) &
		;;

	*)
		# automatically start Chrome without update warning
		(sleep 12 && google-chrome --simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT') &
		;;
esac
