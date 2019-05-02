$OUPath = "OU=***REMOVED***,OU=Users,OU=***REMOVED***,DC=***REMOVED***,DC=local"
$ImportedCSV = Import-Csv "C:\Users\***REMOVED***\Desktop\***REMOVED***"
Import-Module ActiveDirectory

$IMportedCSV | Foreach{
$NewPassword = ConvertTo-SecureString -AsPlainText "Password1" -Force
Set-ADAccountPassword -Identity $_.SamAccountName -NewPassword $NewPassword
}


