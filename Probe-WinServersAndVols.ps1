#https://github.com/ezlage/ezAdmin
#2020-02-10 14:31 UTC
Try {
  $ErrorActionPreference='SilentlyContinue';
  Write-Host "Probing Windows Servers and their mounted volumes... " -NoNewline;
  $Servers = Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
  [System.Collections.ArrayList] $OKServers=@();
  [System.Collections.ArrayList] $AlertServers=@();
  [System.Collections.ArrayList] $FailedServers=@();
  [System.Collections.ArrayList] $WarningServers=@();
  ForEach ($Server in $Servers) {
    Try {          
      $Result=Invoke-Command -ComputerName $Server.Name -ScriptBlock {
        Try {          
          [System.Collections.ArrayList] $Return=@();          
          $DriveInfo=Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ge 1}
          $DriveInfo | ForEach-Object {
            if  (($_.Free/($_.Used+$_.Free)) -gt 0.10) {
              $null=$Return.Add($_.Name);
              $null=$Return.Add("OK");
            } ElseIf (($_.Free/($_.Used+$_.Free)) -gt 0.05) {
              $null=$Return.Add($_.Name);
              $null=$Return.Add("WARN");
            } Else {
              $null=$Return.Add($_.Name);
              $null=$Return.Add("ALERT");
            }
          }         
          return $Return;
        } Catch {
          return "ERROR";
        }
      }
      If ($Result -eq "ERROR") {
        $null=$FailedServers.Add($Server.Name);
      } ElseIf ($Result.Contains("ALERT")) {
        $null=$AlertServers.Add($Server.Name);
      } ElseIf ($Result.Contains("WARN")) {
        $null=$WarningServers.Add($Server.Name);
      } Else {
        $null=$OKServers.Add($Server.Name);
      }    
    } Catch {
      $null=$FailedServers.Add($Server.Name);
    }
  }
  Write-Host "OK!"
  Write-Host;
  if ($FailedServers.Count -gt 0) {
    Write-Host "It was not possible to evaluate the volumes of these servers:"
    ForEach($Srv in $FailedServers) {
      Write-Host $Srv -ForegroundColor Red;
    }
    Write-Host;
  }
  if ($AlertServers.Count -gt 0) {
    Write-Host "Some mounted volumes of these servers are over 95%:"
    ForEach($Srv in $AlertServers) {
      Write-Host $Srv -ForegroundColor Yellow;
    }
    Write-Host;
  }
  if ($WarningServers.Count -gt 0) {
    Write-Host "Some mounted volumes of these servers are over 90%:"
    ForEach($Srv in $WarningServers) {
      Write-Host $Srv -ForegroundColor Yellow;
    }
    Write-Host;
  }
  if ($OKServers.Count -gt 0) {
    Write-Host "All mounted volumes of these servers are below 90%:"
    ForEach($Srv in $OKServers) {
      Write-Host $Srv -ForegroundColor Green;
    }
    Write-Host;
  }
} Catch {
  Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}