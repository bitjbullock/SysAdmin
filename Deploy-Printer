# Define the printer name and IP address
$printerName = "2nd floor"
$printerIP = "10.18.3.51"

# Add the printer port
Add-PrinterPort -Name $printerIP -PrinterHostAddress $printerIP

# Add the printer using the port
Add-Printer -Name $printerName -PortName $printerIP -DriverName "Microsoft IPP Class Driver"

# Install the printer driver from Windows Update
Start-Service -Name "wuauserv"
Install-WindowsFeature -Name Print-Server
Add-WindowsDriver -Driver "Microsoft IPP Class Driver" -Force
