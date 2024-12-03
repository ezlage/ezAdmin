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
Write-Host "Getting Windows Servers and their mounted volumes statistics...";
Write-Host;
$OKServers = @();
$AlertServers = @();
$FailedServers = @();
$WarningServers = @();
try {	
	$Servers = Get-ADComputer -Filter '(Enabled -eq $True) -and (OperatingSystem -like "Windows Server*")';
	foreach ($Server in $Servers) {
		try {
			Write-Host $Server.Name;				
			$Result = Invoke-Command -ComputerName $Server.Name -ScriptBlock {
				try {					
					[System.Collections.ArrayList] $Return = @();					
					$DriveInfo = Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -ge 1}
					$DriveInfo | ForEach-Object {
						if	(($_.Free/($_.Used+$_.Free)) -gt 0.10) {
							$Return += $_.Name;
							$Return += "OK";
						} elseif (($_.Free/($_.Used+$_.Free)) -ge 0.05) {
							$Return += $_.Name;
							$Return += "WARN";
						} else {
							$Return += $_.Name;
							$Return += "ALERT";
						}
					}				 
					return $Return;
				} catch {
					return "ERROR";
				}
			}
			if ($Result -eq "ERROR") {
				$FailedServers += $Server.Name;
			} elseif ($Result.Contains("ALERT")) {
				$AlertServers += $Server.Name;
			} elseif ($Result.Contains("WARN")) {
				$WarningServers += $Server.Name;
			} else {
				$OKServers += $Server.Name;
			}		
		} catch {
			$FailedServers += $Server.Name;
		}
	}
	Write-Host;
	if ($FailedServers.Count -gt 0) {
		Write-Host "It was not possible to evaluate the volumes of these servers:"
		Write-Host;
		foreach ($Srv in $FailedServers) {
			Write-Host $Srv -ForegroundColor Red;
		}
	} else {
		Write-Host "There was no failure to query any server or volume!"
	}
	Write-Host;
	if ($AlertServers.Count -gt 0) {
		Write-Host "Some mounted volumes of these servers are over 95%:"
		Write-Host;
		foreach ($Srv in $AlertServers) {
			Write-Host $Srv -ForegroundColor Yellow;
		}		
	} else {
		Write-Host "No server has volumes above 95%!"
	}
	Write-Host;
	if ($WarningServers.Count -gt 0) {
		Write-Host "Some mounted volumes of these servers are between 90% and 95%:"
		Write-Host;
		foreach ($Srv in $WarningServers) {
			Write-Host $Srv -ForegroundColor Yellow;
		}
	} else {
		Write-Host "No server has volumes between 90% and 95%!"
	}
	Write-Host;
	if ($OKServers.Count -gt 0) {
		Write-Host "All mounted volumes of these servers are below 90%:"
		Write-Host;
		foreach($Srv in $OKServers) {
			Write-Host $Srv -ForegroundColor Green;
		}
	} else {
		Write-Host "No server has volumes below 90%!"
	}
	Write-Host;
} catch {
	Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}

# Issuing the last notice
Write-Host "Done."

# Restoring default behavior on error
$ErrorActionPreference = $EPref;
$WarningPreference = $WPref;
$ProgressPreference = $PPref;