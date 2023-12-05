# Script to configure multiple OneDrive settings. This is not necessary with Intune but for local Group policy usage you can't configure these without a script. Set script to run on logon for users.
# 
# Written by Jonathan Bullock
# 2023 - 12 - 05

# Define the registry path and values
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$settings = @{
    "DehydrateSyncedTeamSites" = 1
    "SilentAccountConfig" = 1
    "KFMSilentOptIn" = "1111-2222-3333-4444"
    "FilesOnDemandEnabled" = 1
    "DisableNewAccountDetection" = 1
}

# Check each setting and update if necessary
foreach ($setting in $settings.Keys) {
    $value = Get-ItemPropertyValue -Path $registryPath -Name $setting -ErrorAction SilentlyContinue
    if ($value -ne $settings[$setting]) {
        Set-ItemProperty -Path $registryPath -Name $setting -Value $settings[$setting]
        Write-Host "Updated $setting to $($settings[$setting])"
    }
}

# Output completion message
Write-Host "Registry settings check complete."
