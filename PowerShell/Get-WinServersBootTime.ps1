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

# Changing the default action on error, warning or progress
$EPref = $ErrorActionPreference;
$WPref = $WarningPreference;
$PPref = $ProgressPreference;
$ErrorActionPreference = 'SilentlyContinue';
$WarningPreference = 'SilentlyContinue';
$ProgressPreference = 'SilentlyContinue';

# Starting the work
Write-Host "Getting Windows Servers and their last boot up times...";
Write-Host;
$FailedServers = @();
$ServersLBUT = @();
try {
	$Servers = Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
	foreach ($Server in $Servers) {
		try {
			Write-Host $Server.Name;
			$Result = Invoke-Command -ComputerName $Server.Name -ErrorAction Stop -ScriptBlock {
				try {
					$LastBoot = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime;
					return $LastBoot;			
				} catch {
					return "ERROR";
				}
			}
			if ($Result -eq "ERROR") {
				$FailedServers += $Server.Name;
			} else {
				$ServersLBUT += $Result;
			}
		} catch {
			$FailedServers += $Server.Name;
		}
	}
	Write-Host;
	if ($FailedServers.Count -gt 0) {
		Write-Host "It was not possible to evaluate the last boot time of these servers:"
		Write-Host;
		foreach($FailedServer in $FailedServers) {
			Write-Host $FailedServer -ForegroundColor Red;
		}		
	} else {
		Write-Host "There was no failure to query any server!"
	}
	Write-Host;
    Write-Host "Results:";
    Write-Host;
	$ServersLBUT | Select-Object PSComputerName, LastBootUpTime | Sort-Object LastBootUpTime -Descending | Format-Table;
} catch {
	Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}

# Issuing the last notice
Write-Host "Done."

# Restoring default behavior on error
$ErrorActionPreference = $EPref;
$WarningPreference = $WPref;
$ProgressPreference = $PPref;