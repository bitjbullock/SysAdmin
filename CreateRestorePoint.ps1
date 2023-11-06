# PowerShell script to enable System Restore and create a restore point
# Written by Jonathan Bullock  
# 2023 - 10 - 14
#

# Function to check if System Restore is enabled
function Check-SystemRestoreEnabled {
    param (
        [string]$drive = "C:"
    )

    $restoreSettings = Get-ComputerRestorePoint | Select-Object -First 1
    if ($null -eq $restoreSettings) {
        Write-Host "System Restore appears to be disabled. Attempting to enable..."
        Enable-ComputerRestore -Drive $drive
    } else {
        Write-Host "System Restore is enabled."
    }
}

# Function to create a System Restore point
function Create-RestorePoint {
    param (
        [string]$description = "Manual Restore Point",
        [string]$restoreType = "Modify_Settings"
    )

    Checkpoint-Computer -Description $description -RestorePointType $restoreType -ErrorAction Stop
    if ($?) {
        Write-Host "Restore point created successfully."
    } else {
        Write-Error "Failed to create restore point."
    }
}

# Main script execution
try {
    Check-SystemRestoreEnabled -drive "C:"
    Create-RestorePoint -description "Snapshot before changes $(Get-Date -Format 'yyyyMMddHHmmss')"
} catch {
    Write-Error "An error occurred: $_"
}
