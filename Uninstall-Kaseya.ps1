# Uninstall All versions of Kaseya on a machine
# Written by Jonathan Bullock
# 2023 - 11 - 20


# Get all dir under Kaseya folder
$agentDirectories = Get-ChildItem -Path "C:\Program Files (x86)\Kaseya\" -Directory

# Loop through each dir and run uninstall command
foreach ($dir in $agentDirectories) {
    $uninstallString = "C:\Program Files (x86)\Kaseya\$dir\KASetup.exe /s /r /g $dir /l '%TEMP%\kasetup_$dir.log'"
    Invoke-Expression $uninstallString
}
