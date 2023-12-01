#!/bin/bash
# This is a bash script for MacOS. It just disables printing, created for a school so students wouldn't abuse the printers. As students obviously will. Here's the reversal script. https://github.com/bitjbullock/SysAdmin/blob/main/EnablePrinting.sh
# Written by Jonathan Bullock
# 2023 - 11 - 23

# Confirm running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Stop the CUPS service
echo "Stopping CUPS service..."
cupsctl --no-share-printers

# Disable CUPS service from starting at boot
echo "Disabling CUPS service from starting at boot..."
launchctl unload /System/Library/LaunchDaemons/org.cups.cupsd.plist

# Optionally, remove all existing printers
echo "Removing all existing printers..."
lpstat -p | awk '{print $2}' | xargs -I {} lpadmin -x {}

echo "Printing has been disabled on this device."
