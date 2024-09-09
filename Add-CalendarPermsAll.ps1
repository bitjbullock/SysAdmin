# Adds a user as Editor permissions to all mailboxs in an org
# Written by Jonathan Bullock
# 2024-09-09

# Prompt the script runner to enter the user who should get access to the mailboxes
$UserToGrant = Read-Host "Please enter the email address of the user to whom you want to grant access (e.g., lisa@domain.com)"

# Get all mailboxes in the organization
$Mailboxes = Get-Mailbox -ResultSize Unlimited

# Loop through each mailbox and grant "Editor" permission to the specified user
foreach ($Mailbox in $Mailboxes) {
    $MailboxIdentity = $Mailbox.PrimarySmtpAddress

    # Try to get existing permissions for the Calendar folder
    $existingPermission = Get-MailboxFolderPermission -Identity "${MailboxIdentity}:\Calendar" -User $UserToGrant -ErrorAction SilentlyContinue

    if ($existingPermission) {
        # If permissions exist, update them to "Editor"
        Set-MailboxFolderPermission -Identity "${MailboxIdentity}:\Calendar" -User $UserToGrant -AccessRights Editor
        Write-Host "Updated $UserToGrant's access to Editor for $MailboxIdentity's Calendar"
    }
    else {
        # If no permissions exist, add new "Editor" permission
        Add-MailboxFolderPermission -Identity "${MailboxIdentity}:\Calendar" -User $UserToGrant -AccessRights Editor
        Write-Host "Granted Editor access to $MailboxIdentity's Calendar for $UserToGrant"
    }
}
