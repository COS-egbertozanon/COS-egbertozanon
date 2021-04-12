# POWERSHELL SCIPT TO CHECK IF A USER IS A MEMBER OF AD GROUP and in case not add him
# By Egberto

# required modulkes:
# Get-Module ActiveDirectory 
# Import-Module ActiveDirectory
#   How to add RSAT features to windows 10 machines
# Add-WindowsCapability -Online -Name RSAT.Active*

$global:userlist = [System.Collections.ArrayList]@()
function GetUserList {
[string[]]$userlista = Read-Host "Enter list separated by semi-colon (;). Ex:P132456;LastName, First;ABC :"
#splitting the list of input as array by Empty Space
$userlista = $userlista.Split(';')
foreach ($user in $userlista) { $userlist.Add($user) }
 write-host -f Cyan -NoNewline "Total users:"; write-host -f Yellow $userlist.Count
#do { write-host -f Cyan -NoNewline "Total:"; write-host -f Yellow "$usercount"; #$confirm = read-host -Prompt "Is this list correct?[y-n]" } until (($confirm -eq "y") -or ($confirm -eq "n")) 
 #if ($confirm -eq "n") { Write-Host -f Yellow "ok, please re-enter userlist" ; Getuserlist}
}

$SamAccountNamelist = [System.Collections.ArrayList]@()

function TestUserList { 
  foreach ($user in $userlist) {
   Write-Host -f Yellow "Checking: $user .."
  if ($user.Split(",")[1] -ne $null) {
  $SamAccountName =  Get-ADUser -filter "givenname -eq '$($user.Split(",")[1])' -and surname -eq '$($user.Split(",")[0])' "
   }else { $SamAccountName = Get-ADUser -Identity $user}
  if ($($SamAccountName.SamAccountName) -Ne $null) {
  write-host -f Green "Found $user SAMAccountName:"; Write-Host -NoNewline -F Cyan "$SamAccountName"; write-host -f Green " proceeding.."; 
  $SamAccountNamelist.Add($SamAccountName.SamAccountName)
  }else { Write-host -NoNewline -f red "AD Account " ;  Write-host -NoNewline -f Yellow "$user" ;Write-host -f red " not found"; }
 }
 }

function GetGroupList {
[string[]] $global:grouplist = READ-HOST "Enter Group list separated by comma ex: Group 1,Group 2,Group 3"
#splitting the list of input as array by Comma
$grouplist = $grouplist.Split(',')
#  [int]$groupcount='0'
#foreach ($group in $grouplist) { Write-Host -f green "$group";  $groupcount++ }
#do { write-host -f Cyan -NoNewline "Total:"; write-host -f Yellow "$groupcount"; $confirm = read-host -Prompt "Is this list correct?[y-n]" } until (($confirm -eq "y") -or ($confirm -eq "n")) 
#     if ($confirm -eq "n") { Write-Host -f Yellow "ok, please re-enter group list"; Getgrouplist}
}
# function to verify if the groups  entered exist on AD:
function TestGroupList {
$grouplist = $grouplist.Split(',')
foreach ($group in $grouplist) {
 Write-Host -f Yellow "Checking: $group .."
if ($(Get-ADGroupMember -Identity "$group") -eq $null) { 
    write-host -f Red "Group: $group does not exist" ; $failed+="$group"}
    if ($failed.count -gt 0) {  Write-Host -f Yellow "The following $($failed.count) Groups could not be found on AD, please review, and rerun this script"
Write-Host -f red ($failed | Format-List | Out-String)
    break} else {Write-Host -f Green "verfified that group $group subbmited exist, proceeding"}
    }
}
#   function to check  is  user is member of a group and if not add
function CheckGroupMembership { 
  foreach ($SamAccountName in $SamAccountNamelist) {
$grouplist = $grouplist.Split(',')
   foreach ($group in $grouplist) { 
  IF ($(Get-ADGroupMember -Identity $group | Where-Object SamAccountName -Like $SamAccountName)-eq $null) { 
  write-host -f green "$SamAccountName not a member of $group, adding"
     Add-ADGroupMember -Identity "$group" -Members "$SamAccountName" 
  } else { write-host -f Yellow "$SamAccountName is already a member of $group, skipping"} } }
    foreach ($group in $grouplist) {
     write-host "Verifying if $SamAccountName has been added to $group."
   IF ($(Get-ADGroupMember -Identity $group | Where-Object SamAccountName -Like $SamAccountName)-eq $null) { 
  write-host -f Red "Failed"} else {write-host -f green "Success"}}
  }
 
GetUserList
GetGroupList
TestUserList
TestGroupList
CheckGroupMembership
