## Script adds Out Of Office to all users in $SecurityGroupName and all shared mailboxes.

$SecurityGroupName = "Security - Staff"

$TemplateFile = ".\OOOTemplate.html" #Template file supports HTML tags

$StartTime = "02/10/2023 16:00:00" #Date in American Format
$EndTime = "02/20/2023 07:30:00" #Date in American Format

$EmailTemplate = Get-Content $TemplateFile -Raw

Connect-ExchangeOnline
Connect-AzureAD

$Group = Get-AzureADGroup -All $True | Where-Object {$_.DisplayName -eq $SecurityGroupName}
$GroupMembers = $Group | Get-AzureAdGroupMember

$SharedMailboxes = Get-EXOMailbox -ResultSize unlimited | Where-Object {$_.RecipientTypeDetails -like "*Shared*"}

foreach($GroupMember in $GroupMembers){

    Write-Progress -Activity "Adding auto-reply message to $($GroupMember.UserPrincipalName)"

    Set-MailboxAutoReplyConfiguration -Identity $GroupMember.UserPrincipalName -AutoReplyState Scheduled -StartTime $StartTime -EndTime $EndTime -InternalMessage $EmailTemplate -ExternalMessage $EmailTemplate -ExternalAudience All
    
}

foreach($SharedMailbox in $SharedMailboxes){

    Write-Progress -Activity "Adding auto-reply message to $($SharedMailbox.UserPrincipalName)"

    Set-MailboxAutoReplyConfiguration -Identity $SharedMailbox.UserPrincipalName -AutoReplyState Scheduled -StartTime $StartTime -EndTime $EndTime -InternalMessage $EmailTemplate -ExternalMessage $EmailTemplate -ExternalAudience All
    
}