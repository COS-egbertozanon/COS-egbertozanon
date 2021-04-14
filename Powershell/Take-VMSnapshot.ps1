Get-Module -Name VMware* -ListAvailable | Import-Module
Connect-VIServer vmware.surrey.ca
function GET-INFO {
$GLOBAL:SERVERLIST =  Read-Host -Prompt "Enter Server Name or list, comma separated. Ex: Server1,Server2"
$GLOBAL:SNAPNAME = Read-Host -Prompt "Enter Snapshot Name: EX: PATCHING"
$GLOBAL:SNAPDESC= Read-Host -Prompt "Enter Snapshot Description EX: TASK-XXXXX OR CHG-YYYYY"
$GLOBAL:SNAPDATE = Get-Date
}
 function TAKE-SNAP {
 $SERVERLIST=
FOREACH ($SERVER FROM $SERVERLIST) {
new-snapshot -vm  $SERVER -name "$SNAPNAME" -Description "$SNAPDESC - $SNAPDATE - $env:username" -Quiesce}
}
GET-INFO
TAKE-SNAP
