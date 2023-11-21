# Disk cleanup script mostly taken from geeksforgeeks.org 
#
# *Fixed Path3/path4 mismatch
# *Removed colours
# *Corrected Grammar
#
# Modified by Jonathan Bullock
# 2023 - 11 - 21


# Set the paths to clean 
$Path = 'C' + ':\$Recycle.Bin'
$Path1 = 'C' + ':\Windows\Temp' # Specify the path where temporary files are stored in the Windows Temp folder
$Path2 = 'C' + ':\Windows\Prefetch' # Specify the path where temporary files are stored in the Windows Prefetch folder
$Path3 = 'C' + ':\Users\*\AppData\Local\Temp' # Specify the path where temporary files are stored in the user's AppData\Local\Temp folder

# Get all items (files and directories) within the recycle bin path, including hidden ones and remove them
Get-ChildItem $Path -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Exclude *.ini -ErrorAction SilentlyContinue

# Display a success message
write-Host "All the necessary data removed from recycle bin successfully"

# Remove Temp files from various locations 
write-Host "Erasing temporary files from various locations"

# Remove all items (files and directories) from the Windows Temp folder
Get-ChildItem $Path1 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
# Remove all items (files and directories) from the Windows Prefetch folder
Get-ChildItem $Path2 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
# Remove all items (files and directories) from the specified user's Temp folder
Get-ChildItem $Path3 -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
# Display a success message
write-Host "Removed all the temp files successfully"


# Display a message indicating the usage of the Disk Cleanup tool
write-Host "Using Disk cleanup Tool"

# Run the Disk Cleanup tool with the specified sagerun parameter
cleanmgr /sagerun:1 | out-Null  
