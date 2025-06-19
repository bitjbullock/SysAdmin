# Written to update Dymo Connect because it's a manual software update according to them
# Jonathan Bullock
# 2025 - 06 - 19
# PS Sorry but this software is shit


# set the download url
# Tried to get it to parse the site but cloudflare blocks scraping and im too smooth brained to figure that out for this shit software.
$installerUrl = "https://download.dymo.com/dymo/Software/Win/DCDSetup1.4.9.12.exe"
$installerPath = "$env:TEMP\DymoConnectInstaller.exe"



# get version number from the filename
if ($installerUrl -match "DCDSetup([\d\.]+)\.exe") {
    $latestVersion = $matches[1]
    Write-Output "Parsed version from URL: $latestVersion"
} else {
    Write-Error "Failed to parse version from installer URL"
    exit 1
}



function Get-InstalledDymoVersion {
    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($path in $registryPaths) {
        $app = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*DYMO Connect*" }

        if ($app) {
            return $app.DisplayVersion
        }
    }
    return $null
}



function Install-Dymo {
    param (
        [string]$Url,
        [string]$Path
    )

    Write-Output "Downloading DYMO installer..."
    Invoke-WebRequest -Uri $Url -OutFile $Path -UseBasicParsing

    Write-Output "Installing DYMO Connect silently..."
    Start-Process -FilePath $Path -ArgumentList "/quiet" -Wait

    Write-Output "Cleaning up installer..."
    Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue
}




# install or not 
$installedVersion = Get-InstalledDymoVersion
Write-Output "Installed version: $installedVersion"
Write-Output "Latest available version: $latestVersion"

if (-not $installedVersion -or ([version]$latestVersion -gt [version]$installedVersion)) {
    Write-Output "An update or install is required. Proceeding..."
    Install-Dymo -Url $installerUrl -Path $installerPath
} else {
    Write-Output "DYMO Connect is up to date. No action required."
}




