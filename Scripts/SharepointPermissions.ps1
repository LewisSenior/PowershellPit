$AdminCenterSubDomain = ""
$SiteSubDomain = ""

$ExportDirectory = "C:\Users\LewisSenior\"
$SiteNames = @("finance", "HR")


Import-Module Microsoft.Online.SharePoint.PowerShell
Import-Module AzureAD

Foreach ($SiteName in $SiteNames) {

$AllUsers = @()

#Variables for Admin Center & Site Collection URL
$AdminCenterURL = "https://$AdminCenterSubDomain.sharepoint.com/"
$SiteURL = "https://$SiteSubDomain.sharepoint.com/sites/$SiteName"

#Connect to SharePoint Online and Azure AD
Connect-SPOService -url $AdminCenterURL
Connect-AzureAD

#Get the Site Collection
$Site = Get-SPOSite $SiteURL

#Get Group Owners
$GroupOwners = (Get-AzureADGroupOwner -ObjectId $Site.GroupID | Select UserPrincipalName, DisplayName)
$GroupMembers = (Get-AzureADGroupMember -ObjectId $Site.GroupID | Select UserPrincipalName, DisplayName)
$SiteUsers = Get-SPOUser -Site $SiteURL -Limit all | Select DisplayName,LoginName,IsSiteAdmin,UserPrincialName


Foreach ($SiteUser in $SiteUsers){
    If($SiteUser.IsSiteAdmin) {
        $Admins = [PSCustomObject]@{
        "Full Name" = $SiteUser.DisplayName
        "Email" = $SiteUser.UserPrincipalName
        "Permission" = "Admin"
        }
        $AllUsers += $Admins
    }
}


    foreach($GroupOwner in $GroupOwners){
           $Owners = [PSCustomObject]@{
                "Full Name" = $GroupOwner.DisplayName
                "Email" = $GroupOwner.UserPrincipalName
                "Permission" = "Owner"
           }
           $AllUsers += $Owners
        }


foreach($GroupMember in $GroupMembers){
        $Members = [PSCustomObject]@{
        "Full Name" = $GroupMember.DisplayName
        "Email" = $GroupMember.UserPrincipalName
        "Permission" = "Member"
        }
            
    $AllUsers += $Members
}


$AllUsers | Export-Excel "$ExportDirectory$SiteName.xlsx" -WorksheetName "Membership"

 $users = Get-SPOUser -Site $Site
 foreach ($user in $users){
     $data = [PSCustomObject]@{
         "Site Url" = $site.url
         "User Login" = $user.loginname
         "Groups" = $user.Groups -join "; "
         "User Type" = $user.usertype
     }

$data | Export-Excel -Path "$ExportDirectory$SiteName.xlsx" -Append -WorksheetName "Permissions"
    }
}