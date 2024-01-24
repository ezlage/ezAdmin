[CmdletBinding()]
param (
    [Parameter(Position=0,mandatory=$true)]
    [string] $MappingsCSV
)

Clear-Host;
$PSDefaultParameterValues['*:Encoding'] = 'utf8';

# Changing the default action on error, warning or progress
$EPref = $ErrorActionPreference;
$WPref = $WarningPreference;
$PPref = $ProgressPreference;
$ErrorActionPreference = 'Stop';
$WarningPreference = 'SilentlyContinue';
$ProgressPreference = 'SilentlyContinue';

Write-Host;
Write-Host "=========================================";
Write-Host "=                ezAdmin                =";
Write-Host "=========================================";
Write-Host "= Developed -by Ezequiel Lage (@ezlage) =";
Write-Host "= Sponsored -by Lageteck (lageteck.com) =";
Write-Host "= Material protected by a license (MIT) =";
Write-Host "=========================================";
Write-Host;

$csvHeader = @("Entity", "DriveLetter", "FullPath", "CredPrompt", "Persistent");
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

if (Test-CSV -FilePath $MappingsCSV) {
    try {
        $Entities = @();
        $Entities += "$env:userdomain\$env:username";    
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | Where-Object {$null -ne $_.AccountDomainSid} |        
            ForEach-Object -Process {$Entities += $_.Translate([System.Security.Principal.NTAccount]).Value}
        $MappingsList = Import-Csv -Path $MappingsCSV;
        foreach ($Mapping in $MappingsList) {
            if (($Mapping.Entity).Split("\").Length -eq 1) {
                $Mapping.Entity = "$env:userdomain\$($Mapping.Entity)";                
            }
            $Mapping.DriveLetter = $Mapping.DriveLetter.ToUpper()[0];            
            switch ($Mapping.CredPrompt.toLower()) {
                {@("true","yes","y","1") -contains $_} {
                    $Mapping.CredPrompt = $true;                     
                    break;
                }
                    default {$Mapping.CredPrompt = $false}
            }
            switch ($Mapping.Persistent.toLower()) {
                {@("false","no","n","0") -contains $_} {
                    $Mapping.Persistent = $false;                     
                    break;
                }
                    default {$Mapping.Persistent = $true}
            }
        }
        $MappingsList;
    }
    catch {
        <#Do this if a terminating exception happens#>
    }   
} else {
    Write-Host "Invalid or missing CSV file!" -ForegroundColor Red;
}

# Restoring default behavior on error
$ErrorActionPreference = $EPref;
$WarningPreference = $WPref;
$ProgressPreference = $PPref;

Write-Host;

#[System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | ForEach-Object -Process {Write-Host $_.Translate([System.Security.Principal.NTAccount]);}

#try {
    #$Content = ConvertFrom-Csv -Header $csvHeader;
    
    #Get-Content -Path $VolListFile -Delimiter $RowSeparator -Encoding utf8 -Force;    

    #$Objs = @{}
    #foreach ($Line in $Content) {
        #$Item = $Line.Split($ColSeparator);
        
        #if ((($Item.Count -eq 4) -or ($Item.Count -eq 5)) -and ($Item[0])) {
        #    $Obj = New-Object -TypeName System.Object;
        #    $Obj | Add-Member -MemberType NoteProperty -Name "Entity" -Value "$($env:userdomain)\$($Item[0])";
        #    $Obj | Add-Member -MemberType NoteProperty -Name "DriveLetter" -Value $Item[1].ToUpper();
        #    $Obj | Add-Member -MemberType NoteProperty -Name "NetworkPath" -Value $Item[2];
        #    switch ($Item[3]) {
        #        {@("false","no","n","0") -contains $_} { 
        #            $Obj | Add-Member -MemberType NoteProperty -Name "Persistent" -Value "NO";
        #            break;
        #         }
        #        default {$Obj | Add-Member -MemberType NoteProperty -Name "Persistent" -Value "YES";}
        #    }            
        #    $Obj | ConvertTo-Csv -NoHeader;            
        #} else {
        #    Write-Host "Line '$Line' ignored due to syntax error!" -ForegroundColor Yellow;
        #}

        #
        # 
        #$Vols.Add($Line.Split($ColSeparator));
        #$Item.Count;
        #$Item;
    #}
#}
#catch {    
#}