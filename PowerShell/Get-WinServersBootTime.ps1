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
Write-Host "Getting Windows Servers and their last boot up times...";
Write-Host;
$FailedServers = @();
$ServersLBUT = @();
Try {
  $Servers = Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
  ForEach ($Server in $Servers) {
    Try {
      Write-Host $Server.Name;
      $Result = Invoke-Command -ComputerName $Server.Name -ScriptBlock {
        Try {
          $LastBoot = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime;
          Return $LastBoot;      
        } Catch {
          Return "ERROR";
        }
      }
      If ($Result -eq "ERROR") {
        $FailedServers += $Server.Name;
      } Else {
        $ServersLBUT += $Result;
      }
    } Catch {
      $FailedServers += $Server.Name;
    }
  }
  Write-Host;
  If ($FailedServers.Count -gt 0) {
    Write-Host "It was not possible to evaluate the last boot time of these servers:"
    Write-Host;
    ForEach($FailedServer in $FailedServers) {
      Write-Host $FailedServer -ForegroundColor Red;
    }    
  } Else {
    Write-Host "There was no failure to query any server!"
  }
  Write-Host;  
  $ServersLBUT | Select-Object PSComputerName, LastBootUpTime | Sort-Object LastBootUpTime -Descending | Format-Table;
} Catch {
  Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}

# Issuing the last notice
Write-Host "Done."

# Restoring the default action on error
$ErrorActionPreference = $OldEAP;