# Script function is to open the required ports for Veeam to connect to a hyperv server it's trying to install on or manage
# Script assumes server is a Standalone HyperV server
# This was modified from another script that we run on the Backup server itself.
#
# For a list of all ports used by Veeam in either direction check: https://helpcenter.veeam.com/docs/backup/hyperv/used_ports.html?ver=120
#
# Written by Jonathan Bullock
# 2023 - 11 - 27

# Define individual ports and protocols - > These are used by the Backup server to point to HyperV
$ports = @(
#    @{ Port = 135; Protocol = 'TCP' }, # RPC Endpoint Mapper Required for deploying Veeam Backup & Replication components.
#    @{ Port = 443; Protocol = 'TCP' }, # Default HTTPS port Required for deploying Veeam Backup & Replication components.
#    @{ Port = 6160; Protocol = 'TCP' }, # Default port used by the Veeam Installer Service.
#    @{ Port = 6162; Protocol = 'TCP' }, # Default port used by the Veeam Data Mover.
#    @{ Port = 6163; Protocol = 'TCP' }, # Default port used to communicate with Veeam Hyper-V Integration Service.
    
)

# Port range required on the HyperV server to connect to the Backup server
$portRange = @(
@{ StartPort = 2500; EndPort = 3300; Protocol = 'TCP' } # Default range of ports used as transmission channels for jobs. For every TCP connection that a job uses, one port from this range is assigned.
# @{ StartPort = 49152; EndPort = 65535; Protocol = 'TCP' } # Dynamic RPC port range for Microsoft Windows 2008 and later. For more information, see this Microsoft KB article.https://support.microsoft.com/kb/929851/en-us ## This is used by Backup server to connect to HyperV.
)

# Create firewall rules for individual ports
foreach ($port in $ports) {
    $ruleName = "Veeam - $($port.Port)/$($port.Protocol)"
    $portNumber = $port.Port
    $protocol = $port.Protocol

    # Check if the firewall rule already exists
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue
    if (-not $existingRule) {
        # Create a new firewall rule
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol $protocol -LocalPort $portNumber -Action Allow
        Write-Host "Created firewall rule for port $portNumber ($protocol)"
    } else {
        Write-Host "Firewall rule for port $portNumber ($protocol) already exists"
    }
}

# Create a firewall rule for the port range
$rangeRuleName = "Veeam - Port Range $($portRange.StartPort)-$($portRange.EndPort)/$($portRange.Protocol)"
$existingRangeRule = Get-NetFirewallRule -DisplayName $rangeRuleName -ErrorAction SilentlyContinue
if (-not $existingRangeRule) {
    # Create a new firewall rule for the range
    New-NetFirewallRule -DisplayName $rangeRuleName -Direction Inbound -Protocol $portRange.Protocol -LocalPort $($portRange.StartPort)-$($portRange.EndPort) -Action Allow
    Write-Host "Created firewall rule for port range $($portRange.StartPort)-$($portRange.EndPort) ($($portRange.Protocol))"
} else {
    Write-Host "Firewall rule for port range $($portRange.StartPort)-$($portRange.EndPort) ($($portRange.Protocol)) already exists"
}

Write-Host "All required firewall rules for Veeam Backup & Replication have been configured."
