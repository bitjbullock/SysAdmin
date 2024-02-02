# Script to run through all your M365 users and disable powershell for all users who are NOT GA
#
# Like most of my scripts, this assumes you're already connected to msolservice, aad and exchange
# written by Jonathan Bullock
# 2024-02-02

# Get the Global Administrator role object
$globalAdminRole = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Global Administrator" }

# Get all members of the Global Administrator role
$globalAdmins = Get-AzureADDirectoryRoleMember -ObjectId $globalAdminRole.ObjectId

# Convert the list of Global Admins to a list of their user principal names (UPNs)
$globalAdminUPNs = $globalAdmins | ForEach-Object { $_.UserPrincipalName }

# Iterate over all users with Remote PowerShell enabled and exclude Global Admins
Get-User -ResultSize Unlimited | Where-Object {
    $_.RemotePowerShellEnabled -eq $true -and $globalAdminUPNs -notcontains $_.UserPrincipalName
} | Set-User -RemotePowerShellEnabled:$False
