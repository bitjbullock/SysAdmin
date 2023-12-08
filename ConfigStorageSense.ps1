# Script is designed to enable storage sense for devices not in an AD Environment.
# In an AD environment, best practice would be to configure these via GPO. 
#
# Note: Script will require customization for your environment, don't just deploy it org wide and be surprised if it breaks stuff!
#
# Written by Jonathan Bullock
# 2023 - 12 - 08
#
#
#
# Check if running with administrative privileges
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    # Relaunch the script with administrative privileges
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

# Function to set registry value if not already set
Function Set-RegistryValueIfNeeded {
    Param (
        [string]$Path,
        [string]$Name,
        [int]$Value
    )

    $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Name
    if ($currentValue -ne $Value) {
        Set-ItemProperty -Path $Path -Name $Name -Value $Value
        Write-Host "Updated $Name to $Value"
    }
    else {
        Write-Host "$Name is already set to $Value"
    }
}

# Enable Storage Sense if not already enabled
Set-RegistryValueIfNeeded -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 1

# Set recycle bin cleanup to 30 days if not already set
Set-RegistryValueIfNeeded -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "2048" -Value 30

# Never delete files in Downloads folder if not already set
Set-RegistryValueIfNeeded -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "256" -Value 0

# Set OneDrive for Business setting to dehydrate synced team sites
Set-RegistryValueIfNeeded -Path "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" -Name "DehydrateSyncedTeamSites" -Value 1

# Enable OneDrive Files On-Demand
Set-RegistryValueIfNeeded -Path "HKLM\SOFTWARE\Policies\Microsoft\OneDrive" -Name "FilesOnDemandEnabled" -Value 1


