$path = 'C:\Users\path to broken dir'
$lp = "\\?\$path"

# clr tag 
cmd /c "fsutil reparsepoint delete `"$lp`""

# drop all attributes
cmd /c "attrib -r -s -h `"$lp`" /s /d"

# force del
Remove-Item -LiteralPath $lp -Force -Recurse -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 300
cmd /c "rd /s /q `"$lp`""
