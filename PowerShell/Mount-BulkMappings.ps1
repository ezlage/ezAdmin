[CmdletBinding()]
param (
    [Parameter(Position=0,mandatory=$true)]
    [string] $MappingsCSV,
    [Parameter(mandatory=$false)]
    [switch]$SkipCredPrompt
)

$PSDefaultParameterValues['*:Encoding'] = 'utf8';

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
$ErrorActionPreference = 'Stop';
$WarningPreference = 'SilentlyContinue';
$ProgressPreference = 'SilentlyContinue';

$csvHeader = @("Entity", "DriveLetter", "FullPath", "Persistent", "CredPrompt", "SaveCred");
function Test-CSV {
    param(
        [string]$FilePath
    )

    if (-not (Test-Path $FilePath)) {            
        return $false;
    }

    try {
        $csvData = Import-Csv -Path $FilePath -ErrorAction Stop;
    } catch {        
        return $false;
    }

    $DesiredColumns = $csvHeader;
    $MissingColumns = Compare-Object -ReferenceObject $DesiredColumns -DifferenceObject $csvData[0].PSObject.Properties.Name;

    if ($MissingColumns.Count -gt 0) {                
        return $false;
    }

    return $true;
}

function Get-HostName {
    param (
        [string] $FilePath
    )
    $FilePath | Select-String -Pattern "(?<=\\\\)(.*?)(?=\\)" | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value;
}

if (Test-CSV -FilePath $MappingsCSV) {
    try {     
        $Username = $null;
        $Password = $null;        
        $CredPrompt = $false;
        $MappedLetters = @();
        $Entities = @();
        $Entities += "$env:userdomain\$env:username";    
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | Where-Object {$null -ne $_.AccountDomainSid} |        
            ForEach-Object -Process {$Entities += $_.Translate([System.Security.Principal.NTAccount]).Value}
        $MappingsList = Import-Csv -Path $MappingsCSV;
        foreach ($Mapping in $MappingsList) {
            if (($Mapping.Entity.Trim()).Split("\").Length -eq 1) {
                $Mapping.Entity = "$env:userdomain\$($Mapping.Entity.Trim())";                
            }
            $Mapping.DriveLetter = "$($Mapping.DriveLetter.ToUpper().Trim()):";            
            switch ($Mapping.Persistent.toLower().Trim()) {
                {@("false","no","n","0") -contains $_} {
                    $Mapping.Persistent = $false;                     
                    break;
                }
                    default {$Mapping.Persistent = $true}
            }
            switch ($Mapping.CredPrompt.toLower().Trim()) {
                {@("true","yes","y","1") -contains $_} {
                    $CredPrompt = $true;
                    $Mapping.CredPrompt = $true;                     
                    break;
                }
                    default {$Mapping.CredPrompt = $false}
            }
            switch ($Mapping.SaveCred.toLower().Trim()) {
                {@("true","yes","y","1") -contains $_} {
                    $CredPrompt = $true;
                    $Mapping.SaveCred = $true;                     
                    break;
                }
                    default {$Mapping.SaveCred = $false}
            }                                     
        }        
        foreach ($Mapping in $MappingsList) {            
            if (($Entities -contains $Mapping.Entity) -and ($MappedLetters -notcontains $Mapping.DriveLetter)) {  
                if (($CredPrompt) -and (-not $SkipCredPrompt)) {
                    $Username = Read-Host -Prompt "Enter the username to be used in the mappings";
                    $Password = Read-Host -AsSecureString -Prompt "Enter the password to be used in the mappings";
                    Write-Host;                    
                    $CredPrompt = $false;
                }                              
                Write-Host "-----------------------------------------";
                $Mapping | Format-Table;
                Remove-SmbMapping -LocalPath $Mapping.DriveLetter -Force -ErrorAction SilentlyContinue;
                switch(($Mapping.CredPrompt -and $Username -and $Password)) {
                    $true {
                        if ($Mapping.SaveCred) {                            
                            Start-Process -Wait -NoNewWindow -FilePath "$env:SystemRoot\System32\cmdkey.exe" -ArgumentList "/delete:`"$(Get-HostName -FilePath $Mapping.FullPath)`"" -RedirectStandardError NUL;
                            Start-Process -Wait -NoNewWindow -FilePath "$env:SystemRoot\System32\cmdkey.exe" -ArgumentList "/add:`"$(Get-HostName -FilePath $Mapping.FullPath)`" /user:`"$Username`" /pass:`"$Password`"";
                            New-SmbMapping -LocalPath $Mapping.DriveLetter -RemotePath $Mapping.FullPath -Persistent $Mapping.Persistent;
                        } else {
                            New-SmbMapping -LocalPath $Mapping.DriveLetter -RemotePath $Mapping.FullPath -Persistent $Mapping.Persistent -UserName $Username -Password $Password;
                        }
                        break;
                    }
                    default {
                        New-SmbMapping -LocalPath $Mapping.DriveLetter -RemotePath $Mapping.FullPath -Persistent $Mapping.Persistent;
                    }
                }    
                $MappedLetters += $Mapping.DriveLetter;
                Write-Host "-----------------------------------------";                
            }            
        }
    }
    catch {
        Write-Host "There was a failure when carrying out the actions!" -ForegroundColor Red;
        Write-Host $_.Exception.GetType().FullName -ForegroundColor Red;
        Write-Host $_.Exception.Message -ForegroundColor Red;  
    }   
} else {
    Write-Host "Invalid or missing CSV file!" -ForegroundColor Red;
}

# Restoring default behavior on error
$ErrorActionPreference = $EPref;
$WarningPreference = $WPref;
$ProgressPreference = $PPref;

Write-Host;
