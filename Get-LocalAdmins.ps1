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
# Rerewritten by ChatGPT to help me get rid of it inaccurately showing disabled accounts. I feel immense shame. 
#
# 2025-03-07

[CmdletBinding()]
param (
    [Parameter()]
    [String]$CustomField = "LocalAdmins",

    [Parameter()]
    [String]$Delimiter = ', '
)

begin {
    # Optional: let environment variables override parameters
    if ($env:customFieldName -and $env:customFieldName -notlike "null") {
        $CustomField = $env:customFieldName
    }
    if ($env:delimiter -and $env:delimiter -notlike "null") {
        $Delimiter = $env:delimiter
    }

    $CheckNinjaCommand  = "Ninja-Property-Set"
    $LocalComputerName  = $env:COMPUTERNAME

    # Build a case-insensitive regex to match COMPUTERNAME\ at the start
    # Example: if $LocalComputerName = 'MYPC', it will match 'mypc\' or 'MYPC\' ...
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
        # 1) Trim each line to remove trailing/leading whitespace
        $line = $item.Trim()

        # 2) Remove COMPUTERNAME\ if it exists (case-insensitive)
        $localName = $line -replace $LocalPrefixRegex, ''
        $localName = $localName.Trim()

        # 3) Check if that changed anything
        if ($localName -eq $line) {
            #
            # => This means there was NO "COMPUTERNAME\" prefix
            # => Possibly a bare "Administrator" or a domain account
            #
            # Try to see if it's actually a local user by enumerating
            $localUser = Get-LocalUser -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ieq $line }

            if ($localUser) {
                # It's a local user
                if ($localUser.Enabled) {
                    # Only add if enabled
                    $ProcessedUsers += $line
                }
                else {
                    # Disabled => skip
                }
            }
            else {
                # Not found as a local user => treat it as domain/built-in => keep as-is
                $ProcessedUsers += $line
            }
        }
        else {
            #
            # => A prefix WAS removed. So $line started with "COMPUTERNAME\"
            # => $localName is what's left after removing it
            #
            # Check if it's a local user
            $localUser = Get-LocalUser -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ieq $localName }

            if ($localUser) {
                # It's a local user
                if ($localUser.Enabled) {
                    # Only add if enabled
                    $ProcessedUsers += $localName
                }
                else {
                    # Disabled => skip
                }
            }
            else {
                # Not found as a local user => see if it's a local group
                $localGroup = Get-LocalGroup -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -ieq $localName }

                if ($localGroup) {
                    # Keep local groups, minus the COMPUTERNAME\ prefix
                    $ProcessedUsers += $localName
                }
                else {
                    # It's neither a local user nor a local group => skip
                    # (avoid adding disabled or unknown items)
                }
            }
        }
    }

    # Show final list
    Write-Host "Local Admins (excluding disabled local users, keeping domain accounts/groups):"
    Write-Host "  $($ProcessedUsers -join $Delimiter)"

    # If Ninja-Property-Set is available, set the custom field
    if ( (Get-Command $CheckNinjaCommand -ErrorAction SilentlyContinue).Name -eq $CheckNinjaCommand `
         -and -not [string]::IsNullOrEmpty($CustomField) `
         -and -not [string]::IsNullOrWhiteSpace($CustomField)) {

        Write-Host "Attempting to set Custom Field: $CustomField"
        Ninja-Property-Set -Name $CustomField -Value ($ProcessedUsers -join $Delimiter)
    }
    else {
        Write-Warning "Unable to set custom field (lack of elevation or Ninja not found?)."
    }
}




