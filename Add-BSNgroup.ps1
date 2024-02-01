# Script adds to BSN-Employees group for Breach Secure now integration with M365
#
# Written by Jonathan Bullock
# 2024 - 02 - 01

# Filter users with Business licenses
$licensedUsers = $users | Where-Object {
    $userLicenses = $_.Licenses
    $hasBusinessLicense = $false
    foreach ($license in $userLicenses) {
        if ($businessLicenses -contains $license) {
            $hasBusinessLicense = $true
            break
        }
    }
    $hasBusinessLicense
}

# ...

# Remove unlicensed or non-Business licensed users from the group
foreach ($member in $groupMembers) {
    if ($member.ObjectType -eq "User") {
        $memberLicenses = ($users | Where-Object { $_.User.ObjectId -eq $member.ObjectId }).Licenses
        $hasBusinessLicense = $false
        foreach ($license in $memberLicenses) {
            if ($businessLicenses -contains $license) {
                $hasBusinessLicense = $true
                break
            }
        }
        if (-not $hasBusinessLicense) {
            Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $member.ObjectId
        }
    }
}
