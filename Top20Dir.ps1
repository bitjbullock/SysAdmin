# Script is designed to pull the top 20 directories by size on a machine, hopefully reducing the need for 3rd party tools such as windirstat
#
# Written by Jonathan Bullock
# 2023 - 12 - 08

# Define the root path to scan
$rootPath = "C:\"  # Replace with the directory you want to scan

# Get all directories in the specified path recursively
$directories = Get-ChildItem -Path $rootPath -Recurse -Directory

# Calculate the size of each directory
$dirSizes = $directories | ForEach-Object {
    $size = (Get-ChildItem -Path $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum
    [PSCustomObject]@{
        Directory = $_.FullName
        Size = $size
    }
}

# Sort the directories by size and select the top 20
$topDirs = $dirSizes | Sort-Object Size -Descending | Select-Object -First 20

# Format the output for both file and console
$formattedOutput = $topDirs | Format-Table -AutoSize | Out-String -Width 4096

# Save the output to a text file
$formattedOutput | Out-File "C:\brockit\Top20Directories.txt"

# Output the result to the command line
Write-Output $formattedOutput
