# Download and run Loki from Github
# Loki is an Open Source Vulnerability scanner, this script is obviously for Windows (powershell) 
# Loki - Simple IOC Scanner Copyright (c) 2015 Florian Roth
# Florian Roth is a God, please follow him on github https://github.com/Neo23x0
# 
# Written by Jonathan Bullock
# 2023 - 11 - 17

# Pre-Reqs
#$lokiUrl = "https://github.com/Neo23x0/Loki/releases/download/v0.51.0/loki_0.51.0.zip" # Replace with the latest release URL
$destinationPath = "C:\brockit\loki"
$lokiZipPath = "$destinationPath\Loki.zip"

# Confirm Brock IT folder exists
if (-not (Test-Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}

# get the architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "i686" }

Write-Host "Detected architecture: $arch"

# get latest releases from github
$apiUrl = "https://api.github.com/repos/Neo23x0/Loki-RS/releases/latest"
try {
    $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }
} catch {
    Write-Error "Failed to fetch release info: $_"
    exit 1
}


#  
$asset = $release.assets | Where-Object { $_.name -match "windows" -and $_.name -match $arch } | Select-Object -First 1

if (-not $asset) {
    Write-Error "No matching Loki-RS binary found"
    exit 1
}


# Download it
try {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $lokiZipPath
    Write-Host "Download complete."
} catch {
    Write-Error "Download failed: $_"
    exit 1
}



# Extract file
Expand-Archive -LiteralPath $lokiZipPath -DestinationPath $destinationPath

# Change to the Loki directory
$lokiExtractedFolder = Get-ChildItem -Path $destinationPath -Directory | Where-Object { $_.Name -match 'Loki' }
cd $destinationpath

# Run Loki-Upgrader.exe first to download the latest signatures
.\loki-util.exe update

# Run Loki to scan for IOCs
# Review readme on github https://github.com/Neo23x0/Loki
.\loki.exe --intense --onlyrelevant

