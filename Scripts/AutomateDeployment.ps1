## ENTER ZIP FILE NAME WITHOUT THE .ZIP EXTENTION
$ZipFileName = ""

## Web URL of LabTech/Automate Server
$LabTechServer = ""

## URL of CDN Web Address that holds Zip File
$CDNWebAddress = ""

$GetLabTechServerSetting = "Placeholder"

$LabTechReg = "HKLM:\SOFTWARE\LabTech"
$TestLabTechReg = Test-Path $LabTechReg

$LabTech64Reg = "HKLM:\SOFTWARE\WOW6432Node\LabTech"
$TestLabTech64Reg = Test-Path $LabTech64Reg

$LabTechServerSetting = "HKLM:\SOFTWARE\LabTech\Service"
$TestLabTechServerSetting = Test-Path $LabTechServerSetting


if($TestLabTechServerSetting) {

    $GetLabTechServerSetting = Get-ItemPropertyValue -Path $LabTechServerSetting -Name "Server Address"

}

$LabTechDir = "C:\Windows\LTSvc"
$TestLabTechDir = Test-Path $LabTechDir

$Services = Get-Service
$LTService = $false
$LTSvcMon = $false

foreach($Service in $Services){

    if($Service.Name -eq "LTService"){

        $LTServiceName = $Service.Name
        $LTService = $True

    } elseif($Service.Name -eq "LTSvcMon"){

        $LTSvcMonName = $Service.Name
        $LTSvcMon = $True

    }

}

if($LTService -and $LTSvcMon -and $LabTechDir -and $LabTechReg -and $LabTech64Reg -and ($GetLabTechServerSetting -match $LabTechServer)){

    Write-Host "Connectwise Installed!"
    Exit

} elseif((-not $LTService) -and (-not $LTSvcMon) -and (-not $TestLabTechDir) -and (-not $TestLabTechReg) -and (-not $TestLabTech64Reg)) {

    Write-Host "Connectwise Automate not Installed!"
    Invoke-WebRequest -Uri "$CDNWebAddress/$ZipFileName.zip" -OutFile "$ZipFileName.zip" -UseBasicParsing
    Expand-Archive -Path ".\$ZipFileName.zip"
    Start-Process -FilePath ".\$ZipFileName\Agent_Install.exe" -ArgumentList "/s" -NoNewWindow -Wait
    Remove-Item -Path ".\$ZipFileName" -Recurse
    Remove-Item -Path ".\$ZipFileName.zip"

} else {

    Write-Host "Connectwise Corrupt, reinstalling..."

    if($LTService){

        Stop-Service -NoWait $LTServiceName
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c 'sc delete $LTServiceName'" -NoNewWindow -Wait

    }

    if ($LTSvcMon) {

        Stop-Service -Name $LTSvcMonName
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c 'sc delete $LTSvcMonName'" -NoNewWindow -Wait

    }
     
    if($TestLabTechDir){

        Remove-Item -Path $LabTechDir -Recurse -Force

    }
     
    if($TestLabTechReg) {

        Remove-Item -Path $LabTechReg -Recurse -Force

    }
     
    if($TestLabTech64Reg) {
    
        Remove-Item -Path $LabTech64Reg -Recurse -Force

    }

    Invoke-WebRequest -Uri "http://files.blueboxg.co.uk/$ZipFileName.zip" -OutFile "$ZipFileName.zip" -UseBasicParsing
    Expand-Archive -Path ".\$ZipFileName.zip"
    Start-Process -FilePath ".\$ZipFileName\Uninstall\Agent_Uninstall.exe" -ArgumentList "/s" -NoNewWindow -Wait
    Start-Process -FilePath ".\$ZipFileName\Agent_Install.exe" -ArgumentList "/s" -NoNewWindow -Wait
    Remove-Item -Path ".\$ZipFileName" -Recurse
    Remove-Item -Path ".\$ZipFileName.zip"

}