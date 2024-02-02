#
# Alerts when user account created in last 1 day
# Handy for alerting to a RMM or even modify for a SMTP server to email your helpdesk
# 
# Brock IT, written by JBullock 
# v1.0 2021 October.
#


$When = ((Get-Date).AddDays(-1)).Date
$GetUsers = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated

foreach($user in $GetUsers){
$userchanges += "$($user.name) has been created at $($user.whencreated) `n"
}

if($UserChanges -eq $Null) { $UserChanges = "No Changes Detected"}
