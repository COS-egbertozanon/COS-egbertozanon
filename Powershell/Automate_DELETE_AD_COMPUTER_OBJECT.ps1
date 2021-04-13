#####################################
#SN-TASK-DELETE AD COMPUTER OBJECT  #
#####################################
# By: Egberto Zanon v1.0 
# last update: March 26, 2021 - 15:24
######################################
#
#  This script will receive a $SERVERNAME from ServiceNow
#  Step1 - Search for a AD COMPUTER OBJECT
#  Step2 - remove the items found
#  Step3 - Verify if items were removed 
#  Outputs:
#   Success or FAILED
#####################################
#Step1 - Search AD OBJECT #
#####################################
$TEST1 = $(Get-ADComputer -Identity $SERVERNAME -EA SilentlyContinue)
if (!$TEST1) {
 write-host -f Yellow "FAILED"
}
################################################################
# Step2 - Delete DHCP Reservation                              #
################################################################
else {
   #write-host -f green  "Deleting AD Computer " 
   Remove-ADComputer -Identity $SERVERNAME -Confirm:$False -EA SilentlyContinue
   Remove-Variable -Name "TEST1"
}
#####################################
# step 3 verify if value was delete #
#####################################
try { Get-ADComputer -Identity $SERVERNAME -EA SilentlyContinue }
catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        write-host -f Green "SUCCESS"
}
    write-host -f RED "FAILED"
