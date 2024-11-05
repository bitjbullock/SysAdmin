# This script was not written by me, I found it here: https://www.reddit.com/r/msp/comments/138stge/ninjarmm_scripting_advice/ and the pastebin link is here: https://pastebin.com/63yK9qbV
# Credit to Braintek

# Modified by Jonathan Bullock
# 2024 - 11 - 05

# Required fields:
# slapsusername
# slapspassword
# slapspassworddate

[string]$script:dateFieldName = "slapspassworddate"
[string]$script:passFieldName = "slapspassword"
[datetime]$script:OldestDate = ([datetime]::now)
[int]$script:OldestIndex = 0

$script:iDebugLine=0
Function dbg{$lineNumber = $MyInvocation.ScriptLineNumber; " -debug line $lineNumber, Count: $global:iDebugLine`n"; $global:iDebugLine++; }

Function main{
  
  #Start-Transcript C:\!MSP\btlocal.txt
  #Declare variables and create new user/password with QA
  $username = "btlocal"
  $temp = (([char[]]([char]48..[char]57) + [char[]]([char]65..[char]90) + [char[]]([char]97..[char]122)) + 0..9 | Sort-Object {Get-Random})[0..14] -join ''
  #$password = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..9 | Sort-Object {Get-Random})[0..12] -join ''
  
  #Update username custom field and current password
  Ninja-Property-Set slapsusername $username
  ChangeOldest $temp

  #Wash password
  $SecurePassword = ConvertTo-SecureString $temp –asplaintext –force
  $temp = $null
  
  #net user /add $username $temp
  try {
    get-localuser $username -erroraction stop;
    Set-LocalUser $username -Password $SecurePassword -FullName "Local Admin" -Description "Local administrator account for IT Support only" -AccountNeverExpires -PasswordNeverExpires 1
  }catch{
    New-LocalUser $username -Password $SecurePassword -FullName "Local Admin" -Description "Local administrator account for IT Support only" -AccountNeverExpires -PasswordNeverExpires
  }
  
  #net localgroup administrators /add $username
  try {Get-LocalGroupMember -group administrators -member $username -ErrorAction stop}
  catch{
    Write-host "Adding $username to administrators group"
    Add-LocalGroupMember -group administrators -member $username -ErrorAction SilentlyContinue
  }
  
  #net localgroup users /delete $username
  try {
    Get-LocalGroupMember -group users -member $username -ErrorAction stop
    Remove-LocalGroupMember -group users -member $username
  }catch{Write-host "$username not in users group, no need to remove"}
}


function ChangeOldest{
  param(
      $temp
    )

  [int]$numberOfFields = 4
  
  For ($i=1; $i -le $numberOfFields; $i++){
    CompareDates $i
  }
  SetFields $temp
  return "Entry #" + $script:OldestIndex + " updated"
}



Function CompareDates {
  param (
    [int]$CurrentIndex,
    [datetime]$PreviousDate = $script:OldestDate
  )
  
  [string]$ComparedDateField = $script:dateFieldName+$CurrentIndex
  try{
    [datetime]$ComparedDate = Ninja-Property-Get $ComparedDateField
  }catch{
    [datetime]$ComparedDate = "01/01/2001 01:01:01" #$null #([datetime]::now)
    Write-host "Error: Possible casting error, field may be empty"
  }
  
  write-host "Previous: $PreviousDate, Comparing to $ComparedDate. Field name $ComparedDateField"
  If ($ComparedDate -lt $PreviousDate ){
    $script:OldestDate = $ComparedDate
    write-host "previous index - $script:OldestIndex , current index $CurrentIndex"
    $script:OldestIndex = $CurrentIndex
    return "New current index $CurrentIndex, new date to set $script:OldestDate"
  }
  write-host "Current index $script:OldestIndex (old)"
}



Function SetFields{
  param(
    $temp
  )
  
  Write-host "Setting fields"
  [string]$PassField = $script:passFieldName + $script:OldestIndex
  [string]$DateField = $script:dateFieldName + $script:OldestIndex
  write-host $DateField
  write-host $PassField
  #$DateField = $script:dateFieldName+$script:OldestIndex; dbg
  #$PassField = $PassField+$script:OldestIndex; dbg

  Write-Host "date field is $DateField , and password field is $PassField"
  
  Ninja-Property-Set $PassField $temp
  Ninja-Property-Set $DateField ([datetime]::now)
  $temp = $null

  Return "`n$DateField updated"
}


main; 
