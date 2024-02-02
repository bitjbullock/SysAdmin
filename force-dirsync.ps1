# two line code just to force a dirsync with AAD
# Written by Jonathan Bullock
# 2020 sometime?


Start-ADSyncSyncCycle -PolicyType Delta

Write-Host "Press any key to continue ..."

$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
