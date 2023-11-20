# Uninstall All versions of Kaseya on a machine
# Written by Jonathan Bullock
# 2023 - 11 - 20


# Function to uninstall software using MSI
function Uninstall-MSI {
    param (
        [string]$uninstallString
    )

    try {
        Start-Process "msiexec.exe" -ArgumentList "/x $uninstallString /quiet /norestart" -Wait
        return $true
    } catch {
        Write-Error "MSI uninstallation failed: $_"
        return $false
    }
}

# Function to find and run setup.exe with switches
function Run-SetupExe {
    param (
        [string]$installDir
    )

    $setupExe = Get-ChildItem -Path $installDir -Filter "setup*.exe" -Recurse | Select-Object -First 1

    if ($setupExe) {
        try {
            Start-Process $setupExe.FullName -ArgumentList "/s /r" -Wait
            Write-Host "Setup.exe run successfully."
        } catch {
            Write-Error "Failed to run setup.exe: $_"
        }
    } else {
        Write-Error "No setup.exe found in $installDir"
    }
}

# Main script logic
$softwareName = "Kaseya"
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $registryPaths) {
    $software = Get-ItemProperty $path | Where-Object { $_.DisplayName -like "*$softwareName*" }

    if ($software) {
        Write-Host "Found $softwareName at $($software.InstallLocation)"
        $uninstalled = Uninstall-MSI -uninstallString $software.UninstallString

        if (-not $uninstalled) {
            Write-Host "Attempting to run setup.exe uninstallation..."
            Run-SetupExe -installDir $software.InstallLocation
        }
        break
    }
}

Write-Host "Script execution completed."
