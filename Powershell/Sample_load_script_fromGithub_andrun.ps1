# This Script loads credentials from an encrypted file then loads a script  and a string paramter to variables then it displays the script and executes it
# Author: Egberto Zanon
# Usage: 
# powershell.exe -f ./Sample_load_script_fromGithub_andrun.ps1 PARAMETER 
# SAMPLE:
# powershell.exe -f ./Sample_load_script_fromGithub_andrun.ps1 "I AM AWSOME" 
# powershell.exe -f ./Sample_load_script_fromGithub_andrun.ps1 "servername" 

#DEFINING THAT A PARAMETER IS MANDATORY AND 
Param(
[parameter(Mandatory=$true)]
[string] $ARGUMENT1
)
 #LOADING CREDS FROM ENCRIPTED FILE -  refer to my other script EncryptCreds.ps1 
$gituser = Get-Content C:\secured\gituser.txt | ConvertTo-SecureString
$BSTR =  [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($gituser)
$gituser = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
$gitkey = get-content C:\secured\gitkey.txt  | convertto-securestring
$BSTR =  [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($gitkey)
$gitkey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

#CONVERTING CREDS TO A BASE64 STRING TO BE PASSED ON THE HTML HEADER REQUEST
$pair = "${gituser}:${gitkey}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)

# PUTTING TOGETHER THE HEADER
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue; "Cache-Control" = "no-cache"}
$RAWGITURL = "https://raw.githubusercontent.com/COS-egbertozanon/COS-egbertozanon/main/Powershell/SAMPLE_Hello_World.ps1"

#PASSING THE SCRIPT TO A VARIABLE
$SCRIPT = Invoke-WebRequest -Uri $RAWGITURL -Headers $headers -Verbose -UseBasicParsing

#EXECUTING THE SCRIPT
Invoke-Expression $($SCRIPT.content)
