Clear-Host;

Write-Host;
Write-Host "=========================================";
Write-Host "=                ezAdmin                =";
Write-Host "=========================================";
Write-Host "= Developed -by Ezequiel Lage (@ezlage) =";
Write-Host "= Sponsored -by Lageteck (lageteck.com) =";
Write-Host "= Material protected by a license (MIT) =";
Write-Host "=========================================";
Write-Host;

# Changing the default action on error
$OldEAP = $ErrorActionPreference;
$ErrorActionPreference = 'SilentlyContinue';

# Starting the work
Write-Host "Getting Windows Servers and their mounted volumes statistics...";
Write-Host;
$OKServers = @();
$AlertServers = @();
$FailedServers = @();
$WarningServers = @();
Try {  
  $Servers = Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
  ForEach ($Server in $Servers) {
    Try {
      Write-Host $Server.Name;        
      $Result = Invoke-Command -ComputerName $Server.Name -ScriptBlock {
        Try {          
          [System.Collections.ArrayList] $Return = @();          
          $DriveInfo = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ge 1}
          $DriveInfo | ForEach-Object {
            If  (($_.Free/($_.Used+$_.Free)) -gt 0.10) {
              $Return += $_.Name;
              $Return += "OK";
            } ElseIf (($_.Free/($_.Used+$_.Free)) -ge 0.05) {
              $Return += $_.Name;
              $Return += "WARN";
            } Else {
              $Return += $_.Name;
              $Return += "ALERT";
            }
          }         
          Return $Return;
        } Catch {
          Return "ERROR";
        }
      }
      If ($Result -eq "ERROR") {
        $FailedServers += $Server.Name;
      } ElseIf ($Result.Contains("ALERT")) {
        $AlertServers += $Server.Name;
      } ElseIf ($Result.Contains("WARN")) {
        $WarningServers += $Server.Name;
      } Else {
        $OKServers += $Server.Name;
      }    
    } Catch {
      $FailedServers += $Server.Name;
    }
  }
  Write-Host;
  If ($FailedServers.Count -gt 0) {
    Write-Host "It was not possible to evaluate the volumes of these servers:"
    Write-Host;
    ForEach($Srv in $FailedServers) {
      Write-Host $Srv -ForegroundColor Red;
    }
  } Else {
    Write-Host "There was no failure to query any server or volume!"
  }
  Write-Host;
  If ($AlertServers.Count -gt 0) {
    Write-Host "Some mounted volumes of these servers are over 95%:"
    Write-Host;
    ForEach($Srv in $AlertServers) {
      Write-Host $Srv -ForegroundColor Yellow;
    }    
  } Else {
    Write-Host "No server has volumes above 95%!"
  }
  Write-Host;
  If ($WarningServers.Count -gt 0) {
    Write-Host "Some mounted volumes of these servers are between 90% and 95%:"
    Write-Host;
    ForEach($Srv in $WarningServers) {
      Write-Host $Srv -ForegroundColor Yellow;
    }
  } Else {
    Write-Host "No server has volumes between 90% and 95%!"
  }
  Write-Host;
  If ($OKServers.Count -gt 0) {
    Write-Host "All mounted volumes of these servers are below 90%:"
    Write-Host;
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

# Issuing the last notice
Write-Host "Done."

# Restoring the default action on error
$ErrorActionPreference = $OldEAP;