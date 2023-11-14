# Capture the current execution policy
$currentPolicy = Get-ExecutionPolicy

# Set the execution policy to Unrestricted
Set-ExecutionPolicy Unrestricted -Force

try {
    # Define the URL of the MSI file
    $msiUrl = "url_of_the_msi"

    # Define the local path where the MSI file will be saved
    $localDir = "C:\BrockIT"
    $localPath = Join-Path -Path $localDir -ChildPath "installer.msi"

    # Check if the directory exists, if not, create it
    if (-not (Test-Path -Path $localDir)) {
        New-Item -Path $localDir -ItemType Directory
    }

    # Use WebClient to download the MSI file
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($msiUrl, $localPath)

    # Install the MSI file
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$localPath`" /quiet /norestart"

    # Clean up and delete the MSI file if needed
    Remove-Item -Path $localPath
}
finally {
    # Reset the execution policy to its original state
    Set-ExecutionPolicy -ExecutionPolicy $currentPolicy -Force
}
