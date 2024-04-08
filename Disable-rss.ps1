# Script to Disable RSS feeds in Outlook via Registry Key
#
# Jonathan Bullock
# 2024 - 04 - 08

# Definitions
$registryPath = "HKCU:\software\policies\microsoft\office\16.0\outlook\options\rss"
$registryName = "Disable"
$registryValue = 1


# Check if the RSS registry key exists and remove it
if (Test-Path $registryPath) {
    Remove-Item -Path $registryPath -Recurse
    Write-Host "RSS Feeds have been disabled in Outlook."
} else {
    Write-Host "RSS Feeds are not enabled or already disabled in Outlook."
}

# Check if the path exists, if not create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the value to disable RSS Feeds
Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue

Write-Host "RSS Feeds have been successfully disabled in Outlook through registry."
