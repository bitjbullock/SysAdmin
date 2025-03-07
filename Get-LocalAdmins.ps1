# This script was originally written by, I assume?, NinjaRMM as there was no author listed and their repo is where I took this from initially.
# I've placed it here so I can modify it to my requirements. 
#
#
#PARAMETER: -CustomField "ReplaceWithAnyTextCustomField"    
#    Updates the custom field you specified (defaults to "LocalAdmins"). The Custom Field needs to be writable by scripts (otherwise the script will report it as not found).
#
#PARAMETER: -Delimiter "ReplaceWithYourDesiredDelimiter"
#    Places whatever is entered encased of quotes between each user name. See below example.
#
# Rewritten by Jonathan Bullock
# 2025-03-07

[CmdletBinding()]
param (
    [Parameter()]
    [String]$CustomField = "LocalAdmins",
    [Parameter()]
    [String]$Delimiter = ', '
)

begin {
    if ($env:customFieldName -and $env:customFieldName -notlike "null") { $CustomField = $env:customFieldName }
    if ($env:delimiter -and $env:delimiter -notlike "null") { $Delimiter = $env:delimiter }
    $CheckNinjaCommand = "Ninja-Property-Set"
    
    # Grab the local computer name once here
    $LocalComputerName = $env:COMPUTERNAME
    
    # Prepare a regex to match exactly 'COMPUTERNAME\' at the start
    $LocalPrefixRegex  = '^' + [Regex]::Escape($LocalComputerName) + '\\'
}
process {
    # Get objects in the Administrators group (both local and domain accounts/groups)
    $RawUsers = net.exe localgroup "Administrators" |
        Where-Object { $_ -and $_ -notmatch "command completed successfully" } |
        Select-Object -Skip 4

    if (-not $RawUsers) {
        Write-Error "[Error] No user's found! This is extremely unlikely is something blocking access to 'net localgroup administrators'?"
        exit 1
    }

# This will be our final list of processed accounts
    $ProcessedUsers = @()

    foreach ($item in $RawUsers) {
        # If this entry starts with COMPUTERNAME\, remove just that portion
        if ($item -match $LocalPrefixRegex) {
            # 'LocalName' is the part after "COMPUTERNAME\"
            $localName = $item -replace $LocalPrefixRegex, ''

            # Try to see if it corresponds to a *local user* object
            # (If it's a local group, this call will fail and $localUser will be $null)
            $localUser = Get-LocalUser -Name $localName -ErrorAction SilentlyContinue
            
            if ($null -ne $localUser) {
                # It's a local user. Keep only if enabled
                if ($localUser.Enabled) {
                    $ProcessedUsers += $localName
                }
                else {
                    # It's a local user but disabled—skip it
                }
            }
            else {
                # Probably a local group (e.g., "Administrators", "Remote Desktop Users", etc.)
                # Keep it in the list, with the COMPUTERNAME\ portion stripped away
                $ProcessedUsers += $localName
            }
        }
        else {
            # It's not local or doesn't start with COMPUTERNAME\, so leave it as-is
            # (Domain user/group, NT AUTHORITY account, etc.)
            $ProcessedUsers += $item
        }
    }

    Write-Host "Local Admins (with local prefix removed and only enabled local users):"
    Write-Host "  $($ProcessedUsers -join $Delimiter)"

    # Optionally set the Ninja property, if available
    if ( (Get-Command $CheckNinjaCommand -ErrorAction SilentlyContinue).Name -like $CheckNinjaCommand `
         -and -not [string]::IsNullOrEmpty($CustomField) `
         -and -not [string]::IsNullOrWhiteSpace($CustomField)) {
        
        Write-Host "Attempting to set Custom Field: $CustomField"
        Ninja-Property-Set -Name $CustomField -Value ($ProcessedUsers -join $Delimiter)
    }
    else {
        Write-Warning "Unable to set custom field (legacy OS or missing elevation?)."
    }
}


