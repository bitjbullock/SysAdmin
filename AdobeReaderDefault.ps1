# Sets Adobe Reader as the default PDF viewer. Not really tested.
# Written by Jonathan Bullock
# Not sure when I wrote it. Sometime 2021? 
#
#
# Ensure script is being run as an administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
  Break
}

$adobeExePath = "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"  # Replace this with your Adobe Reader path

# Check if Adobe Reader exists
If (!(Test-Path -Path $adobeExePath)) {
  Write-Warning "Adobe Reader does not exist at $adobeExePath`nPlease update the path to the Adobe Reader executable!"
  Break
}

# Set Adobe Reader as the default PDF viewer
Try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice" -Name "ProgId" -Value "AcroExch.Document.DC" -ErrorAction Stop
}
Catch {
    Write-Warning "Could not set Adobe Reader as the default PDF viewer!"
    Break
}

Write-Output "Successfully set Adobe Reader as the default PDF viewer!"
