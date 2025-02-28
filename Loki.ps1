# Download and run Loki from Github
# Loki is an Open Source Vulnerability scanner, this script is obviously for Windows (powershell) 
# Loki - Simple IOC Scanner Copyright (c) 2015 Florian Roth
# Florian Roth is a God, please follow him on github https://github.com/Neo23x0
# 
# Written by Jonathan Bullock
# 2023 - 11 - 17

# Pre-Reqs
$lokiUrl = "https://github.com/Neo23x0/Loki/releases/download/v0.51.0/loki_0.51.0.zip" # Replace with the latest release URL
$destinationPath = "C:\brockit"
$lokiZipPath = "$destinationPath\Loki.zip"

# Confirm Brock IT folder exists
if (-not (Test-Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# Download Loki from GitHub
Invoke-WebRequest -Uri $lokiUrl -OutFile $lokiZipPath

# Extract file
Expand-Archive -LiteralPath $lokiZipPath -DestinationPath $destinationPath

# Change to the Loki directory
$lokiExtractedFolder = Get-ChildItem -Path $destinationPath -Directory | Where-Object { $_.Name -match 'Loki' }
cd $lokiExtractedFolder.FullName

# Run Loki-Upgrader.exe first to download the latest signatures
.\loki-upgrader.exe

# Run Loki to scan for IOCs
# Review readme on github https://github.com/Neo23x0/Loki
.\loki.exe --intense --onlyrelevant


