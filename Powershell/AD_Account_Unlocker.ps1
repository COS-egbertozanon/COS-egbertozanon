# This script check if a AD Account is locked and if it is unlocks it.
# By: Egberto Zanon

# get account to perfom action
$cred = Get-Credential -Message "Enter Account that has sufficient rights to unlock account:"

# get account to be checked
$account = Read-Host -Prompt 'Who is locked out(SAMACCOUNT ex: sryad10)?'
 Search-ADAccount -lockedout | Select-Object Name, SamAccountName | findstr.exe -s $account

# if account is locked, unlock
 if ($? -like 'True') {Unlock-ADAccount -Identity $account -Credential  $cred
 ; Write-Host -f green -NoNewline  " Unlocked" ; Write-Host -f y -NoNewline " $account."}
 else {Write-Host -f green  -NoNewline  "Account " ; Write-Host -f y -NoNewline "$account";Write-Host -f green -NoNewline " is";Write-Host -f red -NoNewline " not";Write-Host -f green -NoNewline " locked out."}

# cleanup variables
 rv -Name cred;  rv -Name account
