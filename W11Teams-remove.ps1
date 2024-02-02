#Script detects the new Microsoft Teams consumer app on Windows 11.
# Written by Chris Macleod @ Brock IT
# May 3, 2022


if ($null -eq (Get-AppxPackage -Name MicrosoftTeams)) {
	Write-Host "Microsoft Teams client not found"
	exit 0
} Else {
	Write-Host "Microsoft Teams client found - Now Removing..."
	try{
    		Get-AppxPackage -Name MicrosoftTeams | Remove-AppxPackage -ErrorAction stop
   		Write-Host "Microsoft Teams app successfully removed"

	}
	catch{
    		Write-Error "Error removing Microsoft Teams app"
	}

}
