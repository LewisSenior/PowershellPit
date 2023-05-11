$SharedMailboxEmail = ""
$UserMailbox = ""
$Access = "FullAccess"

Connect-ExchangeOnline

Remove-MailboxPermission -Identity $SharedMailboxEmail -User $UserMailbox -AccessRights $Access
Add-MailboxPermission -Identity $SharedMailboxEmail -User $UserMailbox -AccessRights $Access -AutoMapping:$false