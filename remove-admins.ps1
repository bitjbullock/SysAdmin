# Script to enumerate members of the local admin group and remove them unless they match certain names
#
# Written by Jonathan Bullock
# 2024 - 07 - 02


# Get the Administrators group
$adminGroup = [ADSI]"WinNT://./Administrators,group"

# Get the members of the Administrators group
$members = @($adminGroup.psbase.Invoke("Members")) | ForEach-Object {
    $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
}

# Display the members list
Write-Host "Members of the Administrators group:"
$members | ForEach-Object { Write-Host $_ }

foreach ($member in $members) {
    Write-Host "Processing member: $member"
    if ($member -notmatch "Administrator" -and $member -notmatch "localadmin" -and $member -notmatch "Domain Admins") {
        try {
            # Construct the command to remove the user from the Administrators group
            $command = "net localgroup administrators $member /delete"
            Write-Host "Running command: $command"

            # Run the command
            Invoke-Expression $command

            Write-Host "Removed $member from Administrators group."
        } catch {
            # Handle and report specific exception details
            Write-Host "Failed to remove $member from Administrators group: $($_.Exception.Message)"
        }
    } else {
        Write-Host "$member is not removed from Administrators group."
    }
}
