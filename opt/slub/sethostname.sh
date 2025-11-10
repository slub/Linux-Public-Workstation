#!/bin/bash

# This script sets the hostname based on the response from a reverse DNS lookup.
# Make sure you have correct reverse DNS (PTR) records for you workstation IPs.


LOGFILE=/tmp/hostname

# get ip address
IPADDR=$(ip a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | tail -n1 | awk '{print $2}' | cut -d/ -f1)

# get host name by reverse lookup
host $IPADDR &>/dev/null
if [ "$?" -neq 0 ]; then
    echo "No DNS entries for $IPADDR, aborting! Create a DNS record!" >> $LOGFILE
    exit 1
fi
if [ "$(host $IPADDR | wc -l)" -gt 1 ]; then
    echo "Multiple DNS entries for $IPADDR, aborting! Fix your DNS!" >> $LOGFILE
    exit 1
fi
NEWHOSTN=$(host $IPADDR | cut -d" " -f5 | cut -d. -f1)

# set new host name
hostname "$NEWHOSTN" &>/dev/null
hostnamectl set-hostname "$NEWHOSTN" &>/dev/null
echo "SET:$NEWHOSTN" >> $LOGFILE
