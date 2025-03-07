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

    # Build a case-insensitive regex to match COMPUTERNAME\ at start
    # Example: if $LocalComputerName = 'MYPC', it matches "mypc\" or "MYPC\" or "MyPc\" ...
    $LocalPrefixRegex   = '^(?i)' + [Regex]::Escape($LocalComputerName) + '\\'
}

process {
    # Get raw lines from net localgroup Administrators
    $RawUsers = net.exe localgroup "Administrators" |
        Where-Object { $_ -and $_ -notmatch "command completed successfully" } |
        Select-Object -Skip 4

    if (-not $RawUsers) {
        Write-Error "[Error] No users found in local Administrators group!"
        exit 1
    }

    $ProcessedUsers = @()

    foreach ($item in $RawUsers) {
        # Trim leading/trailing whitespace just in case
        $line = $item.Trim()

        # Check if it starts with COMPUTERNAME\ (case-insensitive)
        if ($line -match $LocalPrefixRegex) {
            # Strip the COMPUTERNAME\ portion
            $localName = $line -replace $LocalPrefixRegex, ''
            # Also trim again in case there's trailing space
            $localName = $localName.Trim()

            # --- TRY local user ---
            # Use a *case-insensitive* check by enumerating & comparing:
            $localUser = Get-LocalUser -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ieq $localName }

            if ($localUser) {
                # Found as a local user
                if ($localUser.Enabled) {
                    # Only add if enabled
                    $ProcessedUsers += $localName
                }
                # If disabled, do nothing (skip)
            }
            else {
                # --- TRY local group ---
                $localGroup = Get-LocalGroup -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -ieq $localName }

                if ($localGroup) {
                    # It's a valid local group, keep it (without COMPUTERNAME\)
                    $ProcessedUsers += $localName
                }
                # If neither found -> skip entirely
            }
        }
        else {
            # It's not local (doesn't start with COMPUTERNAME\),
            # so it might be a domain account, or "NT AUTHORITY\SYSTEM", etc.
            # Keep it as-is.
            $ProcessedUsers += $line
        }
    }

    # Show final list
    Write-Host "Local Admins (excluding disabled local users, keeping domain accounts/groups):"
    Write-Host "  $($ProcessedUsers -join $Delimiter)"

    # Optionally set custom field in Ninja
    if ( (Get-Command $CheckNinjaCommand -ErrorAction SilentlyContinue).Name -eq $CheckNinjaCommand `
         -and -not [string]::IsNullOrEmpty($CustomField) `
         -and -not [string]::IsNullOrWhiteSpace($CustomField)) {

        Write-Host "Attempting to set Custom Field: $CustomField"
        Ninja-Property-Set -Name $CustomField -Value ($ProcessedUsers -join $Delimiter)
    }
    else {
        Write-Warning "Unable to set custom field (lack of elevation or Ninja command not found)."
    }
}



