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
try {
	Write-Host "Probing replication groups, their member servers and last status information...";
	Write-Host;
	$Wait = $false;
	$PrefSite = $null;
	$ReportPath = $null;
	$Indent = [char]9+[char]9+[char]9+[char]9;
	foreach ($Arg in $Args) {
		$Value = $null;
		if ($Arg -ilike "PrefSite=*") {		 
			$Value = $Arg.Split("=");		
			$PrefSite = Get-ADReplicationSite -Identity $Value[$Value.Count-1];
			continue;
		}
		if ($Arg -ilike "ReportPath=*") {
			$Value = $Arg.Split("=");
			$ReportPath = $Value[$Value.Count-1];
			continue;
		}
		if ($Arg -ilike "Wait") {
			$Wait = $true;
			continue;
		}
	}
	if ($null -eq $PrefSite) {
		$PrefSite = Get-ADReplicationSite;
	}
	if (($null -eq $ReportPath) -or -not (Test-Path $ReportPath)) {
		$ReportPath = $env:TEMP+"\DFSreports";
		New-Item -ItemType Directory -Path $ReportPath | Out-Null;
	}
	$Groups = Get-DfsReplicationGroup;
	Write-Host ("Repl. Group", [char]9, "Members");
	Write-Host ("-----------", [char]9, "-------");
	foreach ($Group in $Groups) {
		switch ($Group.State.ToString()) {
			"Normal" {Write-Host -ForegroundColor Green ($Group.GroupName)}
			"In Error" {Write-Host -ForegroundColor Red ($Group.GroupName)}
			default {Write-Host -ForegroundColor Yellow ($Group.GroupName)}
		} 
		$Members = Get-DfsrMember $Group.GroupName;
		$RefMember = $null;
		$MemberList = @();
		foreach ($Member in $Members) {
			if ($null -eq $RefMember) {
				$RefMember = $Member;
			} elseif (($RefMember.Site -ne $PrefSite) -and ($Member.ComputerName.Length -lt $RefMember.ComputerName.Length)) {
				$RefMember = $Member;
			}
			switch ($Member.State.ToString()) {
				"Normal" {Write-Host -ForegroundColor Green ($Indent, $Member.ComputerName)}
				"In Error" {Write-Host -ForegroundColor Yellow ($Indent, $Member.ComputerName)}
				default {Write-Host -ForegroundColor Red ($Indent, $Indent, $Member.ComputerName,"($($Member.State))")}
			} 
			$MemberList += $Member.ComputerName;
		}
		Start-Job -ArgumentList ($($ReportPath),$($Group.GroupName),$($RefMember.ComputerName),$($MemberList)) -ScriptBlock {
			Write-DfsrHealthReport -Path $($args[0]) -CountFiles -GroupName $($args[1]) -ReferenceComputerName $($args[2]) -MemberComputerName $($args[3]);
		} | Out-Null
	}
	Write-Host;
	Write-Host "Preferred reference site: $($PrefSite.Name). Do not close this console, window or session until all jobs have completed!";
	Write-Host;
	if ($Wait) {
		Write-Host "Awaiting jobs completion (it can take a very long time)... " -NoNewline;
		do {
			Start-Sleep -Seconds 4;
			$Jobs = Get-Job | Where-Object {
				($_.JobStateInfo.State.ToString() -eq "Running")
			} | Measure-Object;
		} while ($Jobs.Count -gt 0);
		Write-Host "All health reports completed!";
	} else {
		Write-Host "All health reports started!"
	}
	Write-Host "Use the 'Get-Job' and 'Receive-Job' commands to check the background tasks. Take a look at '$ReportPath' to find the reports!";
} catch {
	Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}

# Restoring default behavior on error
$ErrorActionPreference = $EPref;
$WarningPreference = $WPref;
$ProgressPreference = $PPref;