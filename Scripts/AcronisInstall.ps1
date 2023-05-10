#Replace $RegToken with Acronis Registration Token for Customer
$RegToken = ""

$ComputerInfo = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem
$Domain = $ComputerInfo.Domain


$Applications = Get-WmiObject -Class Win32_Product

Write-Host "Detecting Acronis..."
$Acronis = $Applications | Where {$_.Name -like "*Cyber*"}

if (-not $Acronis) {

    Write-Host "Extracting Acronis Installer..."
    Expand-Archive -Path "AcronisInstall.zip"

    Write-Host "Start Acronis Installer..."
    Start-Process "msiexec.exe" -ArgumentList "/i", "BackupClient64.msi", "/Qn", "TRANSFORMS=BackupClient64.msi.mst" -Wait -NoNewWindow

    Start-Sleep -Seconds 60

    $Output = cmd /c "`"C:\Program Files\BackupClient\PyShell\bin\acropsh.exe`" -m dmldump -s mms -vs `"Msp::Agent::Dto::Configuration`"" | Select-String -Pattern "UserName"
    $notRegistered = $Output -match "\(\'\.Authentication\.UserName\'\, \'string\'\, \'\'\)\,"

    if($notRegistered){

        Write-Host "Registering Machine..."
        cmd /c "`"C:\Program Files\BackupClient\RegisterAgentTool\register_agent.exe`" -a https://eu-cloud.acronis.com --token $RegToken -o register -t cloud"

    } else {

        Write-Host "Machine already registered!"

    }


} else {

EXIT

}