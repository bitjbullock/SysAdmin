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
}
process {
    # Get objects in the Administrators group, includes user objects and groups
    $Users = net.exe localgroup "Administrators" | Where-Object { $_ -AND $_ -notmatch "command completed successfully" } | Select-Object -Skip 4

    if (-not $Users) {
        Write-Error "[Error] No user's found! This is extremely unlikely is something blocking access to 'net localgroup administrators'?"
        exit 1
    }

    Write-Host "Local Admins Found (Users & Groups): $($Users -join $Delimiter)"
    if ($(Get-Command $CheckNinjaCommand -ErrorAction SilentlyContinue).Name -like $CheckNinjaCommand -and -not [string]::IsNullOrEmpty($CustomField) -and -not [string]::IsNullOrWhiteSpace($CustomField)) {
        Write-Host "Attempting to set Custom Field: $CustomField"
        Ninja-Property-Set -Name $CustomField -Value $($Users -join $Delimiter)
    }
    else {
        Write-Warning "Unable to set customfield either due to legacy OS or this script is not running as an elevated user."
    }
}
end {
    
    
    
}

