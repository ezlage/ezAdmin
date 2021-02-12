#https://github.com/ezlage/ezAdmin
#2020-02-12 19:26 UTC
#2020-02-10 14:31 UTC
Try {
  $ErrorActionPreference='SilentlyContinue';
  Write-Host "Probing Windows Servers and their mounted volumes... " -NoNewline;
  $Servers = Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
  $OKServers=@();
  $AlertServers=@();
  $FailedServers=@();
  $WarningServers=@();
  ForEach ($Server in $Servers) {
    Try {          
      $Result=Invoke-Command -ComputerName $Server.Name -ScriptBlock {
        Try {          
          [System.Collections.ArrayList] $Return=@();          
          $DriveInfo=Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ge 1}
          $DriveInfo | ForEach-Object {
            If  (($_.Free/($_.Used+$_.Free)) -gt 0.10) {
              $Return+=$_.Name;
              $Return+="OK";
            } ElseIf (($_.Free/($_.Used+$_.Free)) -ge 0.05) {
              $Return+=$_.Name;
              $Return+="WARN";
            } Else {
              $Return+=$_.Name;
              $Return+="ALERT";
            }
          }         
          Return $Return;
        } Catch {
          Return "ERROR";
        }
      }
      If ($Result -eq "ERROR") {
        $FailedServers+=$Server.Name;
      } ElseIf ($Result.Contains("ALERT")) {
        $AlertServers+=$Server.Name;
      } ElseIf ($Result.Contains("WARN")) {
        $WarningServers+=$Server.Name;
      } Else {
        $OKServers+=$Server.Name;
      }    
    } Catch {
      $FailedServers+=$Server.Name;
    }
  }
  Write-Host "OK!"
  Write-Host;
  If ($FailedServers.Count -gt 0) {
    Write-Host "It was not possible to evaluate the volumes of these servers:"
    ForEach($Srv in $FailedServers) {
      Write-Host $Srv -ForegroundColor Red;
    }
  } Else {
    Write-Host "There was no failure to query any server or volume!"
  }
  Write-Host;
  If ($AlertServers.Count -gt 0) {
    Write-Host "Some mounted volumes of these servers are over 95%:"
    ForEach($Srv in $AlertServers) {
      Write-Host $Srv -ForegroundColor Yellow;
    }    
  } Else {
    Write-Host "No server has volumes above 95%!"
  }
  Write-Host;
  If ($WarningServers.Count -gt 0) {
    Write-Host "Some mounted volumes of these servers are between 90% and 95%:"
    ForEach($Srv in $WarningServers) {
      Write-Host $Srv -ForegroundColor Yellow;
    }
  } Else {
    Write-Host "No server has volumes between 90% and 95%!"
  }
  Write-Host;
  If ($OKServers.Count -gt 0) {
    Write-Host "All mounted volumes of these servers are below 90%:"
    ForEach($Srv in $OKServers) {
      Write-Host $Srv -ForegroundColor Green;
    }
  } Else {
    Write-Host "No server has volumes below 90%!"
  }
  Write-Host;
} Catch {
  Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}