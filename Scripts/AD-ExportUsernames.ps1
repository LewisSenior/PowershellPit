$OUPath = "OU=***REMOVED***,OU=Users,OU=***REMOVED***,DC=***REMOVED***,DC=local"
$ExportPath = "C:\Users\***REMOVED***\desktop\***REMOVED***"
Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase $OUPath | Select-Object -Property SamAccountName | Export-Csv $ExportPath


