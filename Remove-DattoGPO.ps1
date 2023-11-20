# Removed Datto Deployment policy
#  * Run on Domain Controller
# Written by Jonathan Bullock
# 2023 - 11- 20


# Define Datto as name
$gpoName = "Datto"

# Find the GPO
$gpo = Get-GPO -All | Where-Object { $_.DisplayName -eq $gpoName }

# Check if the GPO was found
if ($gpo) {
    # GPO found, proceed to delete
    Remove-GPO -Name $gpoName -Confirm:$false
    Write-Host "GPO '$gpoName' has been deleted."
} else {
    # GPO not found
    Write-Host "GPO '$gpoName' not found."
}
