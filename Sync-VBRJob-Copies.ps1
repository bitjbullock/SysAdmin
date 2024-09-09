# Restarts all VBR Copy jobs 
# Useful after backup copy job failures
# Written by Jonathan Bullock
# 2024-09-09

# Import the Veeam PowerShell module
Import-Module Veeam.Backup.PowerShell

# Check if the module is loaded
if (Get-Module -ListAvailable -Name "Veeam.Backup.PowerShell") {
    Write-Host "Veeam Backup PowerShell module loaded successfully."
    
    # Get all Backup Copy Jobs
    $backupCopyJobs = Get-VBRJob | Where-Object {$_.JobType -eq "BackupCopy"}

    # Start Sync for each Backup Copy Job
    foreach ($job in $backupCopyJobs) {
        Write-Host "Starting Sync for job: $($job.Name)"
        Sync-VBRJob -Job $job
    }

    Write-Host "All Backup Copy jobs have been triggered for synchronization."
} else {
    Write-Host "Veeam Backup PowerShell module could not be loaded. Please ensure Veeam is installed and the module is available."
}
