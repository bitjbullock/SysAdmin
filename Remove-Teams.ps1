# PowerShell script to uninstall Microsoft Teams consumer version
# 
# Written by Jonathan Bullock
# 2023 - 02 - 01
#

# Function to write log
Function Write-Log {
    Param ([string]$logString)

    # You can change the log file path as needed
    $logFile = "C:\path\to\your\log\file.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $logString"
    Add-content -Path $logFile -Value $logEntry
}

try {
    # Log start of the process
    Write-Log -logString "Starting Microsoft Teams removal process."

    # Check if running with admin privileges
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not($currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        Write-Log -logString "Please run the script as an Administrator."
        throw "Please run the script as an Administrator."
    }

    # Stop Teams if it's running
    Get-Process -Name Teams -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Log -logString "Teams process has been stopped."

    # Find the Teams installation for the current user
    $teamsPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Microsoft', 'Teams')

    # Check if the path exists
    if (Test-Path -Path $teamsPath) {
        # Remove the Teams directory
        Remove-Item -Path $teamsPath -Recurse -Force
        Write-Log -logString "Teams directory has been removed."
    } else {
        Write-Log -logString "Teams is not installed for the current user."
        throw "Teams is not installed for the current user."
    }

    # Log the completion of the process
    Write-Log -logString "Microsoft Teams removal process completed."
}
catch {
    # Handle exceptions and write to the log
    Write-Log -logString "An error occurred: $_"
}
