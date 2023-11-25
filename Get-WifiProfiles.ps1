# PS Script to pull all wireless profile SSIDs and Passwords for documention
# Goes without saying, don't be an asshole with this.
# Written by Jonathan Bullock
# 2023 - 11 - 25
#
# Get all Wi-Fi profiles
$profiles = netsh wlan show profiles | Select-String -Pattern "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

# create array to hold profile details
$profileDetails = @()

foreach ($profile in $profiles) {
    # Get the security key for each profile
    $key = netsh wlan show profile name="$profile" key=clear | Select-String -Pattern "Key Content" | ForEach-Object { $_.ToString().Split(":")[1].Trim() }

    # Create an object to hold the profile details
    $profileDetail = New-Object PSObject -Property @{
        SSID = $profile
        Password = $key
    }

    # Add the details to the array
    $profileDetails += $profileDetail
}

# Output the profile details
$profileDetails | Format-Table -AutoSize | Out-File -FilePath "C:\brockit\wifiprofiles.txt"
