#!/bin/bash

# This script calls the proxy logout PHP script when the user logs out from the Linux workstation.

wget --no-check-certificate -qO- https://proxyserver.example.com/index.php?logout=1
