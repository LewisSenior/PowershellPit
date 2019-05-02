$OUPath = "OU=People,OU=Users,OU=Main,DC=domain,DC=local"
$ImportedCSV = Import-Csv "C:\Users\user\Desktop\csv.csv"
Import-Module ActiveDirectory

$IMportedCSV | Foreach{
$NewPassword = ConvertTo-SecureString -AsPlainText "Password1" -Force
Set-ADAccountPassword -Identity $_.SamAccountName -NewPassword $NewPassword
}


