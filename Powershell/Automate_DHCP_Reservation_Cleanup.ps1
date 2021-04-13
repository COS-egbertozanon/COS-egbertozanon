#####################################
#SN-TASK-DELETE DHCP ENTRY           #
#####################################
# By: Egberto Zanon v1.0 
# last update: March 12, 2021 - 14:43
######################################
#
#  This script will receive a $SERVERNAME from ServiceNow
#  Step1 - Search for a DHCP RESERVATION 
#  Step2 - remove the items found
#  Step3 - Verify if items were removed 
#  Outputs:
#   Success or FAILED
#Pre-Requisites:
$DHCPSERVERNAME="{ENTER:YOURSERVERNAMEHERE}" ex: mydhcpserver
#####################################
#Step1 - Search for DHCP RESERVATION#
#####################################
$TEST1  = Resolve-DnsName $SERVERNAME
$SERVERIP = $($TEST1.Address)
$TEST1 = Get-DhcpServerv4Lease -ComputerName prddhcp01.surrey.ca  -IPAddress $SERVERIP 
if (!$TEST1) {
 write-host -f red "FAILED"
}
################################################################
# Step2 - Delete DHCP Reservation                              #
################################################################
else { 
   write-host -f green  "Deleting dhcp reservation "
   Remove-DhcpServerv4Reservation -IPAddress "$SERVERIP" -ComputerName $DHCPSERVERNAME -ErrorAction SilentlyContinue
   Remove-Variable -Name "TEST1" -ErrorAction SilentlyContinue
}
#####################################
# step 3 verify if value was delete #
#####################################
$TEST2 = Get-DhcpServerv4Lease -ComputerName $DHCPSERVERNAME -IPAddress $SERVERIP -ErrorAction SilentlyContinue
if (!$TEST2.AddressState) {
   write-host -f Green "SUCCESS "
}
else {
    write-host -f Yellow "FAILED"
}
