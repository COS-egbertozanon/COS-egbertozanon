#####################################
#SN-TASK-DELETE DNS ENTRY           #
#####################################
# By: Egberto Zanon v1.0 
# last update: March 26, 2021 - 15:08
######################################
#
#  This script will receive a $SERVERNAME from ServiceNow
#  Step1 - Search for a DNS Alias and CNAME records
#  Step2 - remove the items found
#  Step3 - Verify if items were removed 
#  Outputs:
#   Success or FAILED
# Pre-requisites
$ZONENAME="{ENTER:DOMAINZONEHERE.COM}" EX:DOMAIN.COM
$DNSSERVER="{ENTER:DNSSERVERNAMEHERE}" EX:192.168.0.1 OR MYDNSSERVER
#####################################
#Step1 - Search for Alias Entries   #
#####################################
$TEST1 = Get-DnsServerResourceRecord -ZoneName "$ZONENAME" -ComputerName "$DNSSERVER" -Name $SERVERNAME
if (!$TEST1) {  write-host -f red "FAILED"}
##############################################
#Step1.a - Search for MULTIPLE ALIAS entries #
##############################################
$SERVERIP = $($TEST1.RecordData.IPv4Address.IPAddressToString)
$ALIASLIST = @()
$ALIASLIST = Get-DnsServerResourceRecord -ZoneName "$ZONENAME" -ComputerName "$DNSSERVER" -RRType  "A" 
 $A=0
 $B=0
 foreach ($DNSALIAS in $ALIASLIST)
 {
  if (($DNSALIAS.RecordData.IPv4Address.IPAddressToString -like "$SERVERIP") -and ($DNSALIAS.HostName.Split('.')[1] -notlike "*$ZONENAME.Split('.')[0]*" )) {
    $A++
    RV -Name "DNSALIAS$A" -ErrorAction SilentlyContinue
    New-Variable -Name "DNSALIAS$A" -Value "$($DNSALIAS.HostName)"
    Get-Variable -Name "DNSALIAS$A"
      }
 }

#####################################
#Step1.b - Search for CNAME entries #
#####################################
$CNAMELIST = @()
$CNAMELIST = Get-DnsServerResourceRecord -ZoneName "$ZONENAME" -ComputerName "$DNSSERVER" -RRType  "CName"
   $i=0
 foreach ($CNANE in $CNAMELIST)
 {
   if (( $CNANE.RecordData.HostNameAlias.Split('.')[0] -like $SERVERNAME) -and ($CNANE.HostName.Split('.')[1] -notlike "*$ZONENAME.Split('.')[0]*" )) {
    $i++
    RV -Name "CNAME$i" -ErrorAction SilentlyContinue
    New-Variable -Name "CNAME$i" -Value "$($CNANE.HostName)"
    Get-Variable -Name "CNAME$i"
      }
 }
################################################################
# Step2 - Delete DNS Reservation                              #
################################################################
 Write-Host -f Yellow "Found: $A  Alias entries" 
 if ($A -gt 0) {
   do {  
       if ($(Get-Variable -Name "DNSALIAS$A" -ValueOnly)){ 
             Remove-DnsServerResourceRecord -ZoneName "$ZONENAME" -RRType "A" -Name "$SERVERNAME" -RecordData "$SERVERIP" -computername "$DNSSERVER"  -force -Confirm:$false -ErrorAction SilentlyContinue
             }
            
        rv -Name "DNSALIAS$A"
        $A--
        } until ($A -eq 0)
 Write-Host -f Yellow "Found: $A  Cname entries" 
 }
 if ($i -gt 0) {
   do {  if ($(Get-Variable -Name "CNAME$i" -ValueOnly)){
               Remove-DnsServerResourceRecord -ZoneName "$ZONENAME" -Computername "$DNSSERVER" -Name "$(Get-Variable -Name "CNAME$i" -ValueOnly)" -RRType CNAME -force  -Confirm:$false -ErrorAction SilentlyContinue 
               }
       rv -Name "CNAME$i"
       $i--
       } until ($i -eq 0)

       }
##########################################
# step 3-  verify if values were deleted #
#########################################
 
$TEST2 =  Get-DnsServerResourceRecord -ZoneName "$ZONENAME" -ComputerName "$DNSSERVER" -Name $SERVERNAME -ErrorAction SilentlyContinue
if ($TEST2) { write-host -f red "FAILED"} else  {  write-host -f green "SUCCESS"} 
