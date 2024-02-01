# Script adds to BSN-Employees group for Breach Secure now integration with M365
#
# Written by Jonathan Bullock
# 2024 - 02 - 01


# Check if the "BSN-Employees" group exists, create if not
$groupName = "BSN-Employees"
$group = Get-AzureADGroup -Filter "DisplayName eq '$groupName'" -ErrorAction SilentlyContinue

if (-not $group) {
    # Group doesn't exist, create it
    $group = New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
    Write-Host "Group '$groupName' created."
} else {
    Write-Host "Group '$groupName' already exists."
}


# Define license SKUs
$businessLicenses = @("BUSINESS_ESSENTIALS", "EXCHANGESTANDARD", "O365_BUSINESS_PREMIUM", "BUSINESS_PREMIUM", "ENTERPRISEPACK" ) 

# Get all users and their license details
$users = Get-AzureADUser -All $true | ForEach-Object {
    $user = $_
    $licenseDetails = $user | Get-AzureADUserLicenseDetail
    $licenseSkus = $licenseDetails | ForEach-Object { $_.SkuPartNumber }
    [PSCustomObject]@{
        User = $user
        Licenses = $licenseSkus
    }
}

# Filter users with Business licenses
$licensedUsers = $users | Where-Object {
    $_.Licenses -intersect $businessLicenses -ne $null
}

# Get current members of the group
$groupMembers = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true

# Add licensed users to the group if they're not already members
foreach ($userObj in $licensedUsers) {
    if ($groupMembers.ObjectId -notcontains $userObj.User.ObjectId) {
        Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $userObj.User.ObjectId
    }
}

# Remove unlicensed or non-Business licensed users from the group
foreach ($member in $groupMembers) {
    if ($member.ObjectType -eq "User") {
        $memberLicenses = $users | Where-Object { $_.User.ObjectId -eq $member.ObjectId } | Select-Object -ExpandProperty Licenses
        if ($memberLicenses -intersect $businessLicenses -eq $null) {
            Remove-AzureADGroupMember -ObjectId $group.ObjectId -MemberId $member.ObjectId
        }
    }
}
