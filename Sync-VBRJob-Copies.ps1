# Restarts all VBR Copy jobs 
# Useful after backup copy job failures
# Written by Jonathan Bullock
# 2024-09-09

# Load the Veeam PowerShell module
Add-PSSnapin VeeamPSSnapin

# Get all Backup Copy Jobs
$backupCopyJobs = Get-VBRJob | Where-Object {$_.JobType -eq "BackupCopy"}

# Start Sync for each Backup Copy Job
foreach ($job in $backupCopyJobs) {
    Write-Host "Starting Sync for job: $($job.Name)"
    Sync-VBRJob -Job $job
}

Write-Host "All Backup Copy jobs have been triggered for synchronization."
