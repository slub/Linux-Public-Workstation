#!/bin/bash

# needs: zenity
# This is the Xsession script for the SLUB public workstations.
# It will mount a ramdisk on the home directory and copy the
# default profile into it. After that, it starts the Cinnamon desktop session.
# It needs appropriate sudoers rules for mounting the home ramdisk.

if [ $(cat /opt/slub/REFERENZ_PC) == "$HOSTNAME" ]; then
	# no profile reset for reference computer
	zenity --info --text="REFERENZ-PC"
else
	case "$USER" in
		# profile reset for public users
		"www"|"wwwen")
			# umount prev ramdisk and mount new ramdisk
			# the "noexec" parameter is important to disallow execution of downloaded (portable) executables
			sudo /bin/umount $HOME -l || true
			sudo /bin/mount -ttmpfs -onoexec none $HOME
		;;&
		"www")
			# copy default German profile
			cp -R /etc/skel.www/. $HOME | zenity --progress --no-cancel --pulsate --auto-close --auto-kill --text="Benutzerprofil wird zurückgesetzt ..."
		;;&
		"wwwen")
			# copy default English profile
			cp -R /etc/skel.wwwen/. $HOME | zenity --progress --no-cancel --pulsate --auto-close --auto-kill --text="Reset user profile ..."
		;;&
		"www"|"wwwen")
			/opt/slub/autostart.sh
			sudo /bin/chown root:root $(xdg-user-dir DESKTOP)/*.desktop
			sudo /bin/chown $USER:$USER $HOME
			sudo /bin/chmod 0755 $HOME
			# leave home dir and enter again to recognise the ramdisk
			cd / && cd $HOME
		;;
		*)
			zenity --info --text="Achtung: Das automatische Zurücksetzen des Profils ist nicht aktiv!"
		;;
	esac
fi

# start auto log-out script in background
/opt/slub/idle-logout.sh &

# log out from proxy
/opt/slub/proxy-logout.sh

# start cinnamon session
cinnamon-session-cinnamon
# at this point, user is logged out

# kill scripts, which are running in background
killall idle-logout.sh
