# Disable Chrome Notifications in Windows 10/11
# Written by Jonathan Bullock
# 2023 - 10 - 21


# Define the path to the Chrome policies key in the registry
$registryPath = "HKCU:\Software\Policies\Google\Chrome"
$backupFolder = "C:\brockit"
$backupFile = "C:\brockit\ChromePolicyBackup.reg"

# confirm BrockIT folder exists
if (-not (Test-Path $backupFolder)) {
    New-Item -Path $backupFolder -ItemType Directory
}

# Check if the Chrome policy registry path exists
if (Test-Path $registryPath) {
    # Backup the registry key
    Export-RegistryKey -Path $registryPath -Destination $backupFile
    Write-Host "Backup of Chrome policies created at $backupFile"
} else {
    Write-Host "Chrome policy registry key does not exist. No backup needed."
}

# Check if the path exists, if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the policy for disabling notifications
# 2 means to block all notifications
Set-ItemProperty -Path $registryPath -Name "DefaultNotificationsSetting" -Value 2

# Output the status
if (Get-ItemProperty -Path $registryPath -Name "DefaultNotificationsSetting") {
    Write-Host "Chrome notifications have been successfully blocked."
} else {
    Write-Host "Failed to block Chrome notifications."
}

# Function to export a registry key
function Export-RegistryKey {
    param (
        [string]$Path,
        [string]$Destination
    )

    try {
        Export-Registry -Path $Path -File $Destination
        Write-Host "Registry key exported successfully."
    } catch {
        Write-Host "Error exporting registry key: $_"
    }
}
