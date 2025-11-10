#!/bin/bash

# needs: zenity xprintidle
# This script shows a warning and automatically logs out the user after a certain time.

WARN_TIME=$((10*60*1000)) # time in seconds for warning message
IDLE_TIME=$((11*60*1000)) # time in seconds for auto logout
WARNED=no

while true; do

	idle=$(xprintidle)
	if [ $idle -lt $WARN_TIME ]; then
		WARNED=no
	fi
	if [ $idle -ge $WARN_TIME ]; then
		if [ "$WARNED" == "no" ]; then
			zenity --warning --text="Seit 10 Minuten erfolgte keine Interaktion mit diesem Rechner.\nSie werden deshalb in Kürze automatisch abgemeldet." --title="Warnung: automatische Abmeldung in Kürze" --ok-label="Nicht automatisch abmelden" --icon-name=gnome-panel-clock --no-wrap &
			WARNED=yes
		fi
	fi
	if [ $idle -ge $IDLE_TIME ]; then
		cinnamon-session-quit --logout --no-prompt
		exit 0;
	fi

	sleep 1;

done
