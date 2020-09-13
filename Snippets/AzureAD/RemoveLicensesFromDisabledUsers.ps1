$users = Get-MsolUser -All -EnabledFilter DisabledOnly | where {$_.isLicensed -eq $true}

foreach ($user in $users) {
Echo ($user.Licenses.AccountSkuId + " for user " + $user.UserPrincipalName + " has been removed")
Set-MsolUserLicense -UserPrincipalName $user.UserPrincipalName -RemoveLicenses $user.Licenses.AccountSkuId
Echo " "
Echo " "
Echo " "
}
