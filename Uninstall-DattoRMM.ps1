# PowerShell script to uninstall Datto RMM. Could be useful for other defined uninstallers as well.

# Define the path to the uninstaller
$uninstallerPath = "C:\Program Files (x86)\CentraStage\uninst.exe"

# Check if the uninstaller exists
if (Test-Path -Path $uninstallerPath) {
    
    # Run the uninstaller
    Start-Process -FilePath $uninstallerPath 

    Write-Output "Datto RMM uninstallation process has been initiated."
} else {
    Write-Warning "Uninstaller not found at $uninstallerPath."
}
