#
# Script changes the name of a computer based on the input of a script variable in NinjaRMM. 
# Script variable name is "newcomputername" and is set to mandatory
#
# written by Jonathan Bullock
# 2024 - 10 - 22
#


# Retrieve the input from the script variable
# Retrieve the input from the NinjaRMM environment variable
$NewComputerName = $env:newcomputername


# Ensure the script runs with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script needs to be run as an Administrator." -ForegroundColor Red
    exit 1
}

# Validate the new computer name length
if ($NewComputerName.Length -gt 15) {
    Write-Host "Error: The computer name must be 15 characters or less." -ForegroundColor Red
    exit 1
}

# Get current computer name
$currentComputerName = (Get-WmiObject Win32_ComputerSystem).Name
Write-Host "Current Computer Name: $currentComputerName"

# Check if the new name is different
if ($NewComputerName -eq $currentComputerName) {
    Write-Host "The new name is the same as the current name. No changes made." -ForegroundColor Yellow
    exit 0
}

# Rename the computer
try {
    Rename-Computer -NewName $NewComputerName -Force
    Write-Host "Computer renamed successfully to $NewComputerName." -ForegroundColor Green

    # Notify the user to restart later
    $message = "Your computer has been renamed to $NewComputerName. Please restart your computer at the end of the day for the changes to take effect."
    [System.Windows.MessageBox]::Show($message, "Restart Reminder", 'OK', 'Information')

} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
