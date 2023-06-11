## Script Pulls Enabled and CloudOnly Accounts and lists their phone details used for MFA

$OutputFilePath = "" ## "C:\temp\example.csv

Connect-AzureAD
Connect-MgGraph -Scopes 'User.Read.All'

$Users = Get-AzureADUser -All $true | Where {$_.AccountEnabled -eq $TRUE -and $_.DirSyncEnabled -eq $NULL -and $_.usertype -ne "guest"} | Select DisplayName,UserPrincipalName,DirSyncEnabled,ObjectId

$output = @()

foreach($User in $Users){

    $Number = Get-MgUserAuthenticationPhoneMethod -UserId $User.ObjectId -All
    $User.DisplayName
    $User.UserPrincipalName

        if($Number.PhoneNumber -eq $NULL -or $Number.PhoneNumber -eq ""){

            Write-Host "NO NUMBER"

        } else {

            $Number.PhoneNumber

        }

    $Object = [PSCustomObject]@{

        DisplayName = $User.DisplayName
        UserPrincipalName = $User.UserPrincipalName
        Number = $Number.PhoneNumber

       }
              
    $output += $object

    }

$output | Export-CSV $OutputFilePath