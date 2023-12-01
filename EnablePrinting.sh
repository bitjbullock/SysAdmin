#!/bin/bash
# This is a bash script for MacOS. It's basically just a reversal script of my DisablePrinting.sh one found here: https://github.com/bitjbullock/SysAdmin/blob/main/DisablePrinting.sh
# Written by Jonathan Bullock
# 2023-12-01

# Confirm running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Start the CUPS service
echo "Starting CUPS service..."
cupsctl --share-printers

# Enable CUPS service to start at boot
echo "Enabling CUPS service to start at boot..."
launchctl load -w /System/Library/LaunchDaemons/org.cups.cupsd.plist

echo "Printing has been enabled on this device."
