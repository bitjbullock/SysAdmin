# Restarts all VBR Copy jobs 
# Useful after backup copy job failures
# Written by Jonathan Bullock
# 2024-09-09

# Import the Veeam Backup PowerShell module
Import-Module Veeam.Backup.PowerShell

# Get all Backup Copy Jobs
$backupCopyJobs = Get-VBRBackupCopyJob

if ($backupCopyJobs.Count -eq 0) {
    Write-Host "No Backup Copy Jobs found."
} else {
    # Sync each Backup Copy Job
    foreach ($job in $backupCopyJobs) {
        Write-Host "Syncing job: $($job.Name)"
        Sync-VBRBackupCopyJob -Job $job.Name
    }
    Write-Host "All Backup Copy jobs have been triggered for synchronization."
}

