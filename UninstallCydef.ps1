# Finds and removes software related to Cydef Smart Monitor
# Written by Jonathan Bullock
# 2023 - 11 - 21

#
# Defining Cydef related software
$softwareName = "CyDef"

# Get the list of installed software with cydef in the name
$softwareList = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$softwareName*" }

# Check if any software was found
if ($softwareList) {
    foreach ($software in $softwareList) {
        # Output the name of the software being uninstalled
        Write-Host "Uninstalling $($software.Name)..."
        
        # Attempt to uninstall the software
        $uninstallResult = $software.Uninstall()

        # Check the result of the uninstallation
        if ($uninstallResult.ReturnValue -eq 0) {
            Write-Host "Successfully uninstalled $($software.Name)."
        } else {
            Write-Host "Failed to uninstall $($software.Name). Error code: $($uninstallResult.ReturnValue)"
        }
    }
} else {
    Write-Host "No software found with the name containing '$softwareName'."
}
