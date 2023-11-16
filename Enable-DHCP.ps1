# Enables DHCP for both IPv4 and DNS on all network adapters
# Written by Jonathan Bullock
# 2023 - 11 - 16

# Get all network adapters that are up and not loopback
$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.InterfaceDescription -notlike "*Loopback*"}

foreach ($adapter in $adapters) {
    # Set IPv4 address to be obtained automatically
    Set-NetIPInterface -InterfaceAlias $adapter.Name -Dhcp Enabled

    # Set DNS server address to be obtained automatically
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
}

Write-Host "All network adapters have been set to obtain IPv4 and DNS automatically."
