#!/bin/bash

# This script is called when a new audio device is plugged in
# to automatically switch from dummy output to the new audio device.
# (/etc/acpi/events/headphone-jack)

export XDG_RUNTIME_DIR=/run/user/1000

sleep 2

#if [ "$1" = "jack/headphone" -a "$2" = "HEADPHONE" ]; then
#	case "$3" in
#		plug)
#		*)
			su www -c "pacmd unload-module module-udev-detect" #&>> /tmp/pulse.log
			su www -c "pacmd load-module module-udev-detect" #&>> /tmp/pulse.log
#			;;
#		esac
#fi
