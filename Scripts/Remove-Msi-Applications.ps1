$programs = @('') #Comma seperate list of apps e.g. @('iTarian', 'Sophos') It can also be one value


$64bitPrograms = Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty
$32bitPrograms = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | Get-ItemProperty

Foreach ($program in $programs) {
    Foreach ($program64 in $64bitPrograms){ 

      $p64 = $program64 | Where-Object {($_.DisplayName -like $('*' + $program + '*'))}
      if ($p64){
            if ($p64.UninstallString -like "*msiexec.exe*") {
               Write-Host $("64 bit Msiexec uninstaller detected, " + $p64.DisplayName + " - " + $p64.UninstallString + " - Uninstalling...")
               $p64.UninstallString -match '{[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}}'
               Write-Host " "
               Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList '/X', $Matches[0], '/qn' -Wait
               Start-Sleep -Seconds 10
            } 

         }
         $p64 = $null
        }
     
    Foreach ($program32 in $32bitPrograms){       
      $p32 = $program32 | Where-Object {($_.DisplayName -like $('*' + $program + '*'))}
      if ($p32){
         
         if ($p32.UninstallString -like "*msiexec.exe*") {
            Write-Host $("32 bit Msiexec uninstaller detected, " + $p32.DisplayName + " - " + $p32.UninstallString + " - Uninstalling...")
            $p32.UninstallString -match '{[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}}'
            Write-Host " "
            Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList '/X', $Matches[0], '/qn' -Wait
            Start-Sleep -Seconds 10
             }

        }
        $p32 = $null 
     }
   }