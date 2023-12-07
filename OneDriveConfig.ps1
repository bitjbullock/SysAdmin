# Script to configure multiple OneDrive settings. This is not necessary with Intune but for local Group policy usage you can't configure these without a script. Set script to run on logon for users.
# 
# Recommend you tie this with best practice GPOs for Onedrive AND Storage Sense. Storage Sense will keep user files from growing out of control. 
#
# Written by Jonathan Bullock
# 2023 - 12 - 05




# Define the registry path and values
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$settings = @{
    "DehydrateSyncedTeamSites" = 1             # Keeps team sites set to Cloud only so it doesn't keep files locally
    "SilentAccountConfig" = 1                  # Silently signs the user in based on their windows account. This works with a hybrid AD. Have not tested with a local on prem AD disconnected from AAD. Assuming the same domain naming scheme should work.
    "KFMSilentOptIn" = "1111-2222-3333-4444"   # Requires tenant ID to be assigned here.
    "FilesOnDemandEnabled" = 1                 # Files on Demand enabled so files are stored in the cloud by default and not all downloaded to a system
    "DisableNewAccountDetection" = 1           # Removes Microsofts annoying "sign in with your personal" account nonsense. 
}

# Define Event Log source (run script once as admin to create this)
$eventSource = "OneDriveSettingsChecker"
$eventLog = "Application"

# Check if the source exists, if not, create it
if (-not [System.Diagnostics.EventLog]::SourceExists($eventSource)) {
    [System.Diagnostics.EventLog]::CreateEventSource($eventSource, $eventLog)
    Write-Host "Event Source $eventSource created in $eventLog log."
}

# Check each setting and update if necessary
foreach ($setting in $settings.Keys) {
    $value = Get-ItemPropertyValue -Path $registryPath -Name $setting -ErrorAction SilentlyContinue
    if ($value -ne $settings[$setting]) {
        Set-ItemProperty -Path $registryPath -Name $setting -Value $settings[$setting]
        Write-EventLog -LogName $eventLog -Source $eventSource -EntryType Information -EventId 1001 -Message "Updated $setting to $($settings[$setting]) in OneDrive settings."
    } else {
        Write-EventLog -LogName $eventLog -Source $eventSource -EntryType Information -EventId 1002 -Message "Checked $setting, no update needed in OneDrive settings."
    }
}

# Output completion message
Write-Host "Registry settings check complete."