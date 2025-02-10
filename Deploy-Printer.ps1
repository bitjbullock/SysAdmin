# Set the execution policy for the current process to Unrestricted without prompting
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force


# Define the printer name and IP address
$printerName = "2nd floor"
$printerIP = "10.18.3.51"

# Define the URL for the zip, download location and extracted path
$driverZipUrl = "https://bitimages.nyc3.digitaloceanspaces.com/Uploads/Drivers/KM_v4UPD_UniversalDriver_PCL_2.4.0.1.zip"
$localZipPath   = "$env:TEMP\KM_v4UPD_UniversalDriver_PCL.zip"
$extractFolder  = "$env:TEMP\KM_v4UPD_UniversalDriver_PCL"



# Download the driver ZIP file from the internet
try {
    Write-Output "Downloading driver ZIP file from $driverZipUrl..."
    Invoke-WebRequest -Uri $driverZipUrl -OutFile $localZipPath -ErrorAction Stop
    Write-Output "Download complete. Saved to $localZipPath."
}
catch {
    Write-Error "Failed to download the driver ZIP file: $_"
    exit 1
}



# Unzip the file
try {
    # Remove the extraction folder if it already exists for a clean extraction.
    if (Test-Path $extractFolder) {
        Remove-Item -Path $extractFolder -Recurse -Force
    }
    Write-Output "Extracting driver ZIP file to $extractFolder..."
    Expand-Archive -Path $localZipPath -DestinationPath $extractFolder -Force
    Write-Output "Extraction complete."
}
catch {
    Write-Error "Failed to extract the driver ZIP file: $_"
    exit 1
}




# Locate the INF file in the extracted folder (search recursively) Tell Windows to use x64 because its dumb and will use ARM 
try {
    $infFiles = Get-ChildItem -Path $extractFolder -Filter *.inf -Recurse
    if ($infFiles.Count -eq 0) {
        Write-Error "No INF file found in the extracted folder. Exiting."
        exit 1
    }
    
    # Filter for INF files that are for x64 Windows 10
    $x64Win10InfFiles = $infFiles | Where-Object { $_.FullName -match "x64" -and $_.FullName -match "Win10" }
    if ($x64Win10InfFiles.Count -gt 0) {
        $driverInfPath = $x64Win10InfFiles[0].FullName
        Write-Output "Found x64 Win10 INF file: $driverInfPath"
    }
    else {
        if ($infFiles.Count -eq 1) {
            $driverInfPath = $infFiles[0].FullName
            Write-Output "Found single INF file: $driverInfPath"
        }
        else {
            Write-Output "Multiple INF files found. Using the first found: $($infFiles[0].FullName)"
            $driverInfPath = $infFiles[0].FullName
        }
    }
}
catch {
    Write-Error "Error locating INF file: $_"
    exit 1
}




# Install the driver using pnputil (with /subdirs in case additional files are in nested folders)
try {
    Write-Output "Installing driver using pnputil..."
    $pnputilOutput = pnputil.exe /add-driver "$driverInfPath" /install /subdirs
    Write-Output $pnputilOutput
}
catch {
    Write-Error "Failed to install the driver: $_"
    exit 1
}

# Find driver name with pnputil
$publishedNameLine = $pnputilOutput | Where-Object { $_ -match "Published Name:" }
if ($publishedNameLine) {
    $publishedInfName = ($publishedNameLine -replace "Published Name:\s*", "").Trim()
    Write-Output "Driver published INF: $publishedInfName"
} else {
    Write-Error "Published name not found in pnputil output. Please verify driver installation."
    exit 1
}

# Set Driver name because "windows"

$driverName = "KONICA MINOLTA Universal V4 PCL"
Write-Output "Using driver name: $driverName"





# Check if the printer port already exists; if not, create it
if (-not (Get-PrinterPort -Name $printerIP -ErrorAction SilentlyContinue)) {
    try {
        Write-Output "Creating printer port for IP $printerIP..."
        Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP
        Write-Output "Printer port created."
    }
    catch {
        Write-Error "Failed to create printer port: $_"
        exit 1
    }
}
else {
    Write-Output "Printer port for IP $printerIP already exists. Skipping creation."
}



# Add the printer using the newly installed driver
try {
    Write-Output "Adding printer '$printerName' with driver '$driverName'..."
    Add-Printer -Name $printerName -PortName $printerIP -DriverName $driverName
    Write-Output "Printer added successfully."
}
catch {
    Write-Error "Failed to add the printer: $_"
    exit 1
}
