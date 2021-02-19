#https://github.com/ezlage/ezAdmin
#2021-02-19 22:26 UTC
$OldEAP=$ErrorActionPreference;
$ErrorActionPreference='SilentlyContinue';
Try {
  Write-Host "Probing replication groups, their member servers and last status information...";
  Write-Host;
  $Wait=$False;
  $PrefSite=$Null;
  $ReportPath=$Null;
  $Indent=[char]9+[char]9+[char]9+[char]9;
  ForEach ($Arg in $Args) {
    $Value=$Null;
    If ($Arg -ilike "PrefSite=*") {     
      $Value=$Arg.Split("=");    
      $PrefSite=Get-ADReplicationSite -Identity $Value[$Value.Count-1];
      Continue;
    }
    If ($Arg -ilike "ReportPath=*") {
      $Value=$Arg.Split("=");
      $ReportPath=$Value[$Value.Count-1];
      Continue;
    }
    If ($Arg -ilike "Wait") {
      $Wait=$True;
      Continue;
    }
  }
  If ($PrefSite -eq $Null) {
    $PrefSite=Get-ADReplicationSite;
  }
  If (($ReportPath -eq $Null) -or -not (Test-Path $ReportPath)) {
    $ReportPath=$env:TEMP+"\DFSreports";
    New-Item -ItemType Directory -Path $ReportPath | Out-Null;
  }
  $Groups=Get-DfsReplicationGroup;
  Write-Host ("Repl. Group", [char]9, "Members");
  Write-Host ("-----------", [char]9, "-------");
  ForEach ($Group in $Groups) {
    Switch ($Group.State.ToString()) {
      "Normal" {Write-Host -ForegroundColor Green ($Group.GroupName)}
      "In Error" {Write-Host -ForegroundColor Red ($Group.GroupName)}
      Default {Write-Host -ForegroundColor Yellow ($Group.GroupName)}
    } 
    $Members=Get-DfsrMember $Group.GroupName;
    $RefMember=$Null;
    $MemberList=@();
    ForEach ($Member in $Members) {
      If ($RefMember -eq $Null) {
        $RefMember=$Member;
      } ElseIf (($RefMember.Site -ne $PrefSite) -and ($Member.ComputerName.Length -lt $RefMember.ComputerName.Length)) {
        $RefMember=$Member;
      }
      Switch ($Member.State.ToString()) {
        "Normal" {Write-Host -ForegroundColor Green ($Indent, $Member.ComputerName)}
        "In Error" {Write-Host -ForegroundColor Yellow ($Indent, $Member.ComputerName)}
        Default {Write-Host -ForegroundColor Red ($Indent, $Indent, $Member.ComputerName,"($($Member.State))")}
      } 
      $MemberList+=$Member.ComputerName;
    }
    Start-Job -ArgumentList ($($ReportPath),$($Group.GroupName),$($RefMember.ComputerName),$($MemberList)) -ScriptBlock {
      Write-DfsrHealthReport -Path $($args[0]) -CountFiles -GroupName $($args[1]) -ReferenceComputerName $($args[2]) -MemberComputerName $($args[3]);
    } | Out-Null
  }
  Write-Host;
  Write-Host "Preferred reference site: $($PrefSite.Name). Do not close this console, window or session until all jobs have completed!";
  Write-Host;
  If ($Wait) {
    Write-Host "Awaiting jobs completion (it takes a very long time)... " -NoNewline;
    Do {
      Start-Sleep -Seconds 4;
      $Jobs=Get-Job | Where-Object {
        ($_.JobStateInfo.State.ToString() -eq "Running")
      } | Measure;
    } While ($Jobs.Count -gt 0);
    Write-Host "All health reports completed!";
  } Else {
    Write-Host "All health reports started!"
  }
  Write-Host "Use the 'Get-Job' and 'Receive-Job' commands to check the background tasks. Take a look at '$ReportPath' to find the reports!";
} Catch {
  Write-Host $_.Exception.GetType().FullName, $_.Exception.Message -ForegroundColor Red;
}
$ErrorActionPreference=$OldEAP;