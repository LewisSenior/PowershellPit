# Gets time stamps for all computers in the domain that have NOT logged in since after specified date
import-module activedirectory

# Domain FQDN
$domain = "example.local"

# How many days users and computers need to be inactive for this script to disable them
$DaysInactive = 365
$time = (Get-Date).Adddays(-($DaysInactive))

# Name of OU for old users and computers to drop into
$OU = "OU=_Decommisioned,DC=example,DC=local"
$OUc = "OU=_Computers," + $OU
$OUu = "OU=_Users," + $OU

# Test state - True: Outputs what will be moved and disabled - False: Executes the script - 
#(User true first and check output, if happy with what the script will do change to false and run again)
$testMode = $true

# Excludes users with a prefix of Svc by default
$SVCusrExclusion = "svc*"
 
# Get all AD computers with lastLogonTimestamp less than our time and store in variable
$OldPCs = Get-ADComputer -Filter {(LastLogonTimeStamp -lt $time)} -Properties LastLogonTimeStamp
$OldUSERS = Get-ADUser -Filter {(LastLogonTimeStamp -lt $time -AND Name -notlike $SVCusrExclusion)} -Properties LastLogonTimeStamp

# Pipe results into csv
$OldPCs | select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv OLD_Computer.csv -notypeinformation
$OldUSERS | select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv OLD_User.csv -notypeinformation

# Test to see if Archive OU exists
$OUtest_Decommisioned = Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU'"
$OUtest_Users = Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUu'"
$OUtest_Computers = Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUc'"

# If Archive OU exists disable Computer objects and move
if($testMode){
    If($OUtest_Decommisioned){
        $OldPCs | Set-ADComputer -Enabled $false -WhatIf
        $OldUSERS | Set-ADUser -Enabled $false -WhatIf

        If($OUtest_Users){
            $OldUSERS | Move-ADObject -TargetPath $OUu -WhatIf
        } else {
            New-ADOrganizationalUnit -Name "_Users" -Path $OU -WhatIf
            $OldUSERS | Move-ADObject -TargetPath $OUu -WhatIf
        }

        If($OUtest_Computers){
            $OldPCs | Move-AdObject -TargetPath $OUc -WhatIf
        } else {
            New-ADOrganizationalUnit -Name "_Computers" -Path $OU -WhatIf
            $OldPCs | Move-AdObject -TargetPath $OUc -WhatIf
        }
    
    } 
    # Otherwise create _Decommisioned, _Users, and _Computers OU at the root of the domain, disable Computer objects and move
    else {
        New-ADOrganizationalUnit -Name "_Decommisioned" -WhatIf
        New-ADOrganizationalUnit -Name "_Users" -Path $OU -WhatIf
        New-ADOrganizationalUnit -Name "_Computers" -Path $OU -WhatIf

        $OldPCs | Set-ADComputer -Enabled $false -WhatIf
        $OldUSERS | Set-ADUser -Enabled $false -WhatIf

        $OldPCs | Move-AdObject -TargetPath $OUc -WhatIf
        $OldUSERS | Move-ADObject -TargetPath $OUu -WhatIf
    }
} else {
    If($OUtest_Decommisioned){
            $OldPCs | Set-ADComputer -Enabled $false
            $OldUSERS | Set-ADUser -Enabled $false

            If($OUtest_Users){
                $OldUSERS | Move-ADObject -TargetPath $OUu
            } else {
                New-ADOrganizationalUnit -Name "_Users" -Path $OU
                $OldUSERS | Move-ADObject -TargetPath $OUu
            }

            If($OUtest_Computers){
                $OldPCs | Move-AdObject -TargetPath $OUc
            } else {
                New-ADOrganizationalUnit -Name "_Computers" -Path $OU
                $OldPCs | Move-AdObject -TargetPath $OUc
            }
    
        } 
        # Otherwise create _Decommisioned, _Users, and _Computers OU at the root of the domain, disable Computer objects and move
        else {
            New-ADOrganizationalUnit -Name "_Decommisioned"
            New-ADOrganizationalUnit -Name "_Users" -Path $OU
            New-ADOrganizationalUnit -Name "_Computers" -Path $OU

            $OldPCs | Set-ADComputer -Enabled $false
            $OldUSERS | Set-ADUser -Enabled $false

            $OldPCs | Move-AdObject -TargetPath $OUc
            $OldUSERS | Move-ADObject -TargetPath $OUu
        }

}