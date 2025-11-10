#!/bin/bash

# wait for SSH session (from bootserver) to successfully exit
sleep 4

# enable WOL on network card
ethtool -s enp1s0 wol g # Fujitsu Q

# instant power off
halt -pfh
