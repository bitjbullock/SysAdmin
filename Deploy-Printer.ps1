# Define the printer name and IP address
$printerName = "2nd floor"
$printerIP = "10.18.3.51"

# Define the URL for the INF file and where to save it locally
$driverInfUrl = "https://bitimages.nyc3.digitaloceanspaces.com/Uploads/Drivers/KOBxxK__01.inf"
$localDriverPath = "$env:TEMP\konica_minolta_v4_PLC.inf"

# Download the driver INF file from the internet
try {
    Write-Output "Downloading driver INF file from $driverInfUrl..."
    Invoke-WebRequest -Uri $driverInfUrl -OutFile $localDriverPath -ErrorAction Stop
    Write-Output "Download complete. Saved to $localDriverPath."
}
catch {
    Write-Error "Failed to download the driver INF file: $_"
    exit 1
}

# Install the driver using pnputil
# The /add-driver option adds the driver to the driver store.
# The /install option installs the driver on matching devices.
try {
    Write-Output "Installing driver using pnputil..."
    $pnputilOutput = pnputil.exe /add-driver $localDriverPath /install
    Write-Output $pnputilOutput
}
catch {
    Write-Error "Failed to install the driver: $_"
    exit 1
}

# Driver Name
$driverName = "KONICA MINOLTA Univeral V4 PCL"  





# Create the printer port
try {
    Write-Output "Creating printer port for IP $printerIP..."
    Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP
    Write-Output "Printer port created."
}
catch {
    Write-Error "Failed to create printer port: $_"
    exit 1
}


# Add the printer using the newly installed driver
try {
    Write-Output "Adding printer '$printerName'..."
    Add-Printer -Name $printerName -PortName $printerIP -DriverName $driverName
    Write-Output "Printer added successfully."
}
catch {
    Write-Error "Failed to add the printer: $_"
    exit 1
}

