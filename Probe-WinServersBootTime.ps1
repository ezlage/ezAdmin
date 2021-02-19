#https://github.com/ezlage/ezAdmin
#2021-02-19 20:21 UTC
#2021-02-12 20:43 UTC
#2021-02-12 19:26 UTC
$OldEAP=$ErrorActionPreference;
$ErrorActionPreference='SilentlyContinue';
Try {
  Write-Host "Probing Windows Servers and their last boot up times... " -NoNewline;
  $Servers=Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
  $FailedServers=@();
  $ServersLB=@();
  ForEach ($Server in $Servers) {
    Try {
      $Result=Invoke-Command -ComputerName $Server.Name -ScriptBlock {
        Try {
          $LastBoot=Get-CimInstance -ClassName Win32_OperatingSystem | Select LastBootUpTime;
          Return $LastBoot;      
        } Catch {
          Return "ERROR";
        }
      }
      If ($Result -eq "ERROR") {
        $FailedServers+=$Server.Name;
      } Else {
        $ServersLB+=$Result;
      }
    } Catch {
      $FailedServers+=$Server.Name;
    }
  }
  Write-Host "OK!"
  Write-Host;
  If ($FailedServers.Count -gt 0) {
    Write-Host "It was not possible to evaluate the last boot time of these servers:"
    ForEach($Srv in $FailedServers) {
      Write-Host $Srv -ForegroundColor Red;
    }
    Write-Host;
  } Else {
    Write-Host "There was no failure to query any server!"
  }
  $ServersLB | Select PSComputerName, LastBootUpTime | Sort-Object LastBootUpTime | Format-Table
} Catch {
  Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}
$ErrorActionPreference=$OldEAP;