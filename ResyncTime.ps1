# Sync time with Pool.NTP.Org time server
# Written by Jonathan Bullock  
# 2023 - 06 - 21
#

# Set the time service to automatically start
Set-Service -Name w32time -StartupType 'Automatic'

# Start the time service if it isn't running
Start-Service w32time

# Configure the time service to sync with a public NTP server
w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:YES /update

# Restart the time service
Restart-Service w32time

# Force synchronization
w32tm /resync

Write-Host "Time synchronization complete."
