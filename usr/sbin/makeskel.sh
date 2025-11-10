#!/bin/bash
set -e

# Regenerate the profile skeletons from /home/$user into /etc/skel.$user
# $1 = path to root file system
#      e.g. / for local system
#      e.g. /srv/tftp/linux-live/lm_x64_1 for usage on netboot server
# $2 = profile names, separated by whitespace
#      (optional, default "www wwwen")

if [ "$EUID" != "0" ]; then
	echo "Must execute as root!"
	exit 1
fi
if [ "$1" == "" ]; then
	echo "Please enter a folder path to the root fs as first parameter!"
	exit 1
fi
if [ ! -d "$1" ]; then
	echo "$1 is not a folder!"
	exit 1
fi

users="www wwwen"
if [ "$2" != "" ]; then
	users="$2"
fi

for user in $users; do
		echo "Creating skel for $user ..."

		if [ ! -d "$1/home/$user" ]; then
			echo "$1/home/$user does not exist, skipping this user!"
			continue
		fi

		rm -R "$1/etc/skel.$user" || true
		mkdir "$1/etc/skel.$user"
		cp -Ra "$1/home/$user/." "$1/etc/skel.$user"

		# adjust permissions, so that non-root user can read the skel
		chmod 775 "$1/etc/skel.$user"
		find "$1/etc/skel.$user/.config" \
			"$1/etc/skel.$user/.local" \
			"$1/etc/skel.$user/.cache" \
			-type d -exec chmod 775 {} \;
		chmod 664 "$1/etc/skel.$user/.bashrc" \
			"$1/etc/skel.$user/.bash_logout" \
			"$1/etc/skel.$user/.profile"

		# chown to root, so that skel cannot be modified -
		# this is not absolutely necessary for the default workstations
		# since the file system is mounted read-only there, but for
		# special workstations with r/w mounted root fs
		chown -R root:root "$1/etc/skel.$user"
done
