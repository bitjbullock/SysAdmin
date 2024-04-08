# Script to Disable RSS feeds in Outlook via Registry Key
#
# Jonathan Bullock
# 2024 - 04 - 08

$registryPath = "HKCU:\software\policies\microsoft\office\16.0\outlook\options\rss"

# Define the name of the value you want to change
$valueName = "disable"

# Define the new value (1 to enable, 0 to disable)
$newValue = 1

# Check if the registry key exists, and if not, create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the new value
Set-ItemProperty -Path $registryPath -Name $valueName -Value $newValue -Type DWord
