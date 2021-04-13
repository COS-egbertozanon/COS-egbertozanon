# Sample Hello World Script
# Author: Egberto Zanon
# This script Prints Hello World Colorized
 Write-host -nonewline "HELLO" ;Write-host -f red -nonewline " W";Write-host -f yellow -nonewline "o";Write-host -f green -nonewline "r"; Write-host -f blue -nonewline "d"; Write-host -nonewline "!!!!"
 Write-host -nonewline "The following parameter was passed via command line:";Write-host -f yellow  " $ARGUMENT1" 
 Write-host "This could be usefull for scheduling repetitive tasks like , cleanup vmware snapshots of diferent servers, or getting info on users " 
