# Script to report on inactive users in m365 within the last 30 days. Change the "adddays" bit to change to whatever days you want
# Note: Relies on MgGraph
# written by jonathan bullock
# 2025 - 06 - 16

$cutoffDate = (Get-Date).AddDays(-30)

# collect users
$allUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,SignInActivity,AccountEnabled"

# Filter the following
# 1 User is enabled
# 2 User has at least one assigned license
# 3 User has not signed in in last 30 days OR never signed in
$inactiveLicensedEnabledUsers = $allUsers | Where-Object {
    $_.AccountEnabled -eq $true -and
    $_.AssignedLicenses.Count -gt 0 -and (
        -not $_.SignInActivity.LastSignInDateTime -or
        ([datetime]$_.SignInActivity.LastSignInDateTime -lt $cutoffDate)
    )
} | Select-Object DisplayName, UserPrincipalName, @{Name="LastSignIn"; Expression={$_.SignInActivity.LastSignInDateTime}}

# show results
$inactiveLicensedEnabledUsers | Format-Table -AutoSize

# export
$inactiveLicensedEnabledUsers | Export-Csv "c:\brockit\InactiveLicensedUsers.csv" -NoTypeInformation
