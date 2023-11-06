#
# Script to configure Bitlocker and output the key. 
# !!!!! Recommend outputting to RMM or having your AD document the key.
#
# Written by Jonathan Bullock
# 2023 - 10 - 01
#
#
# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "You need to run this script as an Administrator."
    Exit
}

# Check if TPM is present
$tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm
if (-not $tpm) {
    Write-Error "TPM (Trusted Platform Module) is not present on this machine."
    Exit
} elseif ($tpm.IsActivated_InitialValue -eq $false) {
    Write-Error "TPM is not activated. Please activate TPM manually."
    Exit
}

# Check if C: drive is not already encrypted
$bitlockerStatus = Get-BitLockerVolume -MountPoint "C:"
if ($bitlockerStatus.ProtectionStatus -eq "On") {
    Write-Error "BitLocker is already enabled on the C: drive."
    Exit
}

# If all checks pass, enable BitLocker
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256

# Retrieve and output the BitLocker recovery key
$bitlockerVolume = Get-BitLockerVolume -MountPoint "C:"
$recoveryKey = $bitlockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }
Write-Output "BitLocker has been enabled on the C: drive."
Write-Output ("Recovery Key: " + $recoveryKey.KeyProtectorId)
Write-Host "Enabling the bitlocker recovery agent in case this has been disabled by OS upgrades"
reagentc /enable
Write-Host "Checking if Bitlocker is already enabled, and if so, documenting keys"
$Bitlockervolumes = Get-BitLockerVolume | Where-Object -Property mountpoint -EQ $env:SystemDrive
Write-Host "We've found the following Bitlocker capable volumes:"
$Bitlockervolumes | Format-List
if ($Bitlockervolumes.volumeStatus -eq "FullyEncrypted" -and $Bitlockervolumes.ProtectionStatus -eq "On") { 
    Write-Host "Bitlocker is enabled. We're going to document the keys." 
}
else {
    Write-Host "Bitlocker is not enabled. We're checking if Bitlocker can be enabled."
    $TPMState = Get-Tpm
    if ($TPMState.TPMReady -eq $true) {
        Write-Host "We have found TPM is ready, so we are going to try to enable Bitlocker"

        try {
            Write-Host "TPM is ready, we're going to try to encrypt the system volume."
            Enable-BitLocker -MountPoint $env:SystemDrive -UsedSpaceOnly -SkipHardwareTest -TpmProtector -ErrorAction Stop
            Write-Host "We have enabled bitlocker succesfully"
            Add-BitLockerKeyProtector -RecoveryPasswordProtector -MountPoint $env:SystemDrive
            Write-Host "We have added a Bitlocker Key Protector succesfully"
            Resume-BitLocker $env:SystemDrive
            Write-Host "We have resumed bitlocker protection if it was disabled by the user."


        }
        catch {
            Write-Host "Could not enable bitlocker $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "The device is not ready for bitlocker. The TPM is reporting that it is not ready for use. Reported TPM information:"
        $TPMState
        exit 1
    }
}
$BitlockerKey = ((Get-BitLockerVolume -MountPoint $env:SystemDrive).keyprotector | Where-Object { $_.KeyProtectorType -EQ "RecoveryPassword" -and $_.RecoveryPassword -ne $null } | Select-Object -Last 1).recoverypassword
if ($BitlockerKey) {
    Write-Host "We're documenting the bitlocker key: $BitlockerKey"
    Write-Host $BitlockerKey
}
else {
    Write-Host "We could not detect a bitlocker key. Enabling Bitlocker failed. This is the current bitlocker status:"
    Get-BitLockerVolume -MountPoint $env:SystemDrive
    exit 1
}
