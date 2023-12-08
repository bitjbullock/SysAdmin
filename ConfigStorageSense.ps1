#
# Script is designed to enable storage sense for devices not in an AD Environment.
# In an AD environment, best practice would be to configure these via GPO. 
#
#
# Script originally written by Christopher Talke, github link: https://github.com/christopher-talke
# 
# Support the creator of the script and drop him a follow.
#
#
# Pulled into BrockIT Github for modification 2023 - 12 - 08
#
#

$storagePolicy = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"

# Function to write errors to the event log
function Write-ErrorLog {
    param(
        [string]$Message,
        [int]$EventId = 1
    )
    Write-EventLog -LogName "Application" -Source "BIT.StoragePolicyScript" -EntryType Error -EventId $EventId -Message $Message
}

try {
    # Enabling Storange Sense: 
    # 0x00000000 = Disabled
    # 0x00000001 = Enabled
    try {
        Set-ItemProperty $storagePolicy -Name "01" -Value 0x00000001
    } catch {
        Write-ErrorLog -Message "Error enabling Storage Sense: $_"
    }

    # Delete temporary files that my apps aren’t using
    # 0x00000000 = Disabled
    # 0x00000001 = Enabled
    try {
        Set-ItemProperty $storagePolicy -Name "04" -Value 0x00000001
    } catch {
        Write-ErrorLog -Message "Error setting policy for temporary files: $_"
    }

    # Delete files in my recycle bin settings
    # 0x00000000 = Never
    # 0x00000001 = 1 Day
    # Please note: 0x00000001 needs to be set if you want to utilise more than 1 Day with value "256"
    try {
        Set-ItemProperty $storagePolicy -Name "08" -Value 0x00000001
        Set-ItemProperty $storagePolicy -Name "256" -Value 0x0000001E # 30 Days
    } catch {
        Write-ErrorLog -Message "Error setting recycle bin policies: $_"
    }

    # Delete files in my recycle bin if they have been there for over
    # 0x00000000 = Never
    # 0x00000001 = 1 Day
    # 0x0000000E = 14 Days
    # 0x0000001E = 30 Days
    # 0x0000003C = 60 Days
    # Please Note: Value "04" needs to be set as a REG_DWORD with a data value of 0x00000001 in order for this to work for 1 Day or More, likewise for Never being 0x00000000
    try {
        Set-ItemProperty $storagePolicy -Name "32" -Value 0x00000000 # Never delete from downloads
        Set-ItemProperty $storagePolicy -Name "512" -Value 0x00000000 # Never delete from downloads
    } catch {
        Write-ErrorLog -Message "Error setting Downloads folder policies: $_"
    }

    # Run Storage Sense frequency setting
    # 0x00000001 = Everyday
    # 0x00000007 = Every 7 Days
    # 0x0000001E = Every Month
    # 0x00000000 = During Low Disk Space
    # Please note: 0x00000001 needs to be set if you want to utilise more than 1 Day with value "512"
    try {
        Set-ItemProperty $storagePolicy -Name "2048" -Value 0x00000007 # Runs every 7 days
    } catch {
        Write-ErrorLog -Message "Error setting Storage Sense frequency: $_"
    }

    # Processing OneDrive Accounts

    # Find the current logged-in user, and locate the associated Security Identifier
    $userSID = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value.Trim()   # Find the current logged-in user, and locate the associated Security Identifier

    # Find all the mapped OneDrive Account ID's, and ensure the StoragePolicy Registry Keys and Values are set
    $oneDriveAccounts = Get-ChildItem "HKCU:\software\Microsoft\OneDrive\Accounts" | Where-Object {$_.Name -Match "Business"} | Select-Object PSPath

    forEach ($accounts in $oneDriveAccounts) {
        try {
            $accountPath = $accounts.PSPath.Split('HKEY_CURRENT_USER')[-1] 
            $accountKey = ($accounts.PSPath -split '\\')[-1]

            $scopeIDPath = "HKCU:$accountPath\ScopeIdToMountPointPathCache"

            if (Test-Path $scopeIDPath) {
                (Get-ItemProperty $scopeIDPath).PSObject.Properties | ForEach-Object {
                    if ($_.Name -NotMatch "PS") {
                        $OneDriveID = "OneDrive!$($userSID)!$accountKey|$($_.Name)"
                        $BuiltPath = "$storagePolicy\$OneDriveID"

                        if ($OneDriveID -eq "OneDrive!!$accountKey|") {
                            Write-ErrorLog 'There was a problem consolidating the OneDrive Account ID'
                        }

                        if ((Test-Path $BuiltPath) -eq $false) {
                            New-Item -Path $storagePolicy -Name $OneDriveID -Force
                        }
                        # Content will become online-only if not opened for more than: 
                        # 0x00000000 = Disabled
                        # 0x00000001 = Enabled
                        Set-ItemProperty $BuiltPath -Name "02" -Value 0x00000001
                        
                        # Content will becme online-only if not opened for more than: 
                        # 0x00000001 = 1 Day
                        # 0x0000000E = 14 Days
                        # 0x0000001E = 30 Days
                        # 0x0000003C = 60 Days
                        Set-ItemProperty $BuiltPath -Name "128" -Value 0x0000000E # Set to 14 Days
                    }
                }
            }
        } catch {
            Write-ErrorLog -Message "Error processing OneDrive accounts: $_"
        }
    }
} catch {
    Write-ErrorLog -Message "An unexpected error occurred in the script: $_"
}

