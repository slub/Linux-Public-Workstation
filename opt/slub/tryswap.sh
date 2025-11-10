#!/bin/bash

# Try to mount a swap partition
# - not in fstab because not on every computer present and on some computers on other partiton than /dev/sda1.

while true; do
	swapon /dev/sda1  &>> /dev/null
	if [ "$?" == "0" ]; then
		exit 0;
	fi
	swapon /dev/sdb1  &>> /dev/null
	if [ "$?" == "0" ]; then
		exit 0;
	fi
	swapon /dev/sda2  &>> /dev/null
	if [ "$?" == "0" ]; then
		exit 0;
	fi
	sleep 10
done
