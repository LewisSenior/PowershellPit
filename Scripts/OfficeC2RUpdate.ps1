$Click2RunDirectory = "C:\Program Files\Common Files\microsoft shared\ClickToRun\"
$TestC2RDirectory = Test-Path $Click2RunDirectory

If ($TestC2RDirectory) {

Start-Process -FilePath "$Click2RunDirectory\OfficeC2RClient.exe" -ArgumentList "/update user" -Wait

} else {

    Write-Host "Click2Run exe not detected."

}