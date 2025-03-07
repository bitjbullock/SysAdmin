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
    if ($env:customFieldName -and $env:customFieldName -notlike "null") {
        $CustomField = $env:customFieldName
    }
    if ($env:delimiter -and $env:delimiter -notlike "null") {
        $Delimiter = $env:delimiter
    }
    $CheckNinjaCommand  = "Ninja-Property-Set"
    $LocalComputerName  = $env:COMPUTERNAME
    
    # Build a case-insensitive regex to match "COMPUTERNAME\" at the start
    $LocalPrefixRegex   = '^(?i)' + [Regex]::Escape($LocalComputerName) + '\\'
}

process {
    # 1) Grab raw items from net localgroup Administrators
    $RawUsers = net.exe localgroup "Administrators" |
        Where-Object { $_ -and $_ -notmatch "command completed successfully" } |
        Select-Object -Skip 4

    if (-not $RawUsers) {
        Write-Error "[Error] No users found! Something might be blocking 'net localgroup administrators'."
        exit 1
    }

    $ProcessedUsers = @()

    foreach ($item in $RawUsers) {
        # If entry starts with COMPUTERNAME\ (case-insensitive), Then its local
        if ($item -match $LocalPrefixRegex) {
            # Example: COMPUTERNAME\Administrator -> strip COMPUTERNAME\
            $localName = $item -replace $LocalPrefixRegex, ''

            # Check if it's a *local user* (e.g. "Administrator", "LocalTestUser", etc.)
            $localUser = Get-LocalUser -Name $localName -ErrorAction SilentlyContinue
            if ($null -ne $localUser) {
                # It's a local user. Only add if actually enabled
                if ($localUser.Enabled) {
                    $ProcessedUsers += $localName
                }
                else {
                    # It's disabled => Skip it
                }
            }
            else {
                # Not local user => check if it's a local group
                $localGroup = Get-LocalGroup -Name $localName -ErrorAction SilentlyContinue
                if ($null -ne $localGroup) {
                    # It's a local group, keep it (without COMPUTERNAME\)
                    $ProcessedUsers += $localName
                }
                else {
                    # It's not a local user or a local group,skip it entirely to avoid re-listing a disabled or unknown object                    
                }
            }
        }
        else {
            # If it doesn't start with COMPUTERNAME\ (e.g. domain account, NT AUTHORITY, etc.)
            $ProcessedUsers += $item
        }
    }

    # Output
    Write-Host "Local Admins (excluding disabled local accounts, keeping domain & local groups):"
    Write-Host "  $($ProcessedUsers -join $Delimiter)"

    # Optionally set the Ninja property
    if ( (Get-Command $CheckNinjaCommand -ErrorAction SilentlyContinue).Name -eq $CheckNinjaCommand `
         -and -not [string]::IsNullOrEmpty($CustomField) `
         -and -not [string]::IsNullOrWhiteSpace($CustomField)) {

        Write-Host "Attempting to set Custom Field: $CustomField"
        Ninja-Property-Set -Name $CustomField -Value ($ProcessedUsers -join $Delimiter)
    }
    else {
        Write-Warning "Unable to set custom field (maybe lack of elevation or legacy OS)."
    }
}


