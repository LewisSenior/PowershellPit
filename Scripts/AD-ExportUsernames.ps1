$OUPath = "OU=People,OU=Users,OU=Main,DC=domain,DC=local"
$ExportPath = "C:\Users\user\desktop\csv.csv"
Import-Module ActiveDirectory
Get-ADUser -Filter * -SearchBase $OUPath | Select-Object -Property SamAccountName | Export-Csv $ExportPath


