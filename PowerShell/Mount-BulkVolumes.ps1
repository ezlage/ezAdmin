[CmdletBinding()]
param (
    [Parameter(Position=0,mandatory=$true)]
    [string] $VolListFile,
    [Parameter(Position=0,mandatory=$true)]
    [string] $EntityMapFile,    
    [Parameter(mandatory=$false)]
    [string] $ColSeparator=";",
    [Parameter(mandatory=$false)]
    [string] $RowSeparator="`n"
)

Clear-Host;
$PSDefaultParameterValues['*:Encoding'] = 'utf8';

Write-Host;
Write-Host "=========================================";
Write-Host "=                ezAdmin                =";
Write-Host "=========================================";
Write-Host "= Developed -by Ezequiel Lage (@ezlage) =";
Write-Host "= Sponsored -by Lageteck (lageteck.com) =";
Write-Host "= Material protected by a license (MIT) =";
Write-Host "=========================================";
Write-Host;

#Entity;DriveLetter;FullPath;Persistent
#[System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | ForEach-Object -Process {Write-Host $_.Translate([System.Security.Principal.NTAccount]);}

#try {
    $Content = Get-Content -Path $VolListFile -Delimiter $RowSeparator -Encoding utf8 -Force;
    $Vols = @{}
    foreach ($Line in $Content) {
        $Item = $Line.Split($ColSeparator);
        
        if (($Item.Count -eq 3) -or ($Item.Count -eq 4)) {
            $Obj = New-Object -TypeName System.Object;
            $Obj | Add-Member -MemberType NoteProperty -Name "Entity" -Value $Item[0];
            $Obj | Add-Member -MemberType NoteProperty -Name "DriveLetter" -Value $Item[1].ToUpper();
            $Obj | Add-Member -MemberType NoteProperty -Name "NetworkPath" -Value $Item[2];
            switch ($Item[3]) {
                {@("false","no","n","0") -contains $_} { 
                    $Obj | Add-Member -MemberType NoteProperty -Name "Persistent" -Value "NO";
                    break;
                 }
                default {$Obj | Add-Member -MemberType NoteProperty -Name "Persistent" -Value "YES";}
            }
            $Obj;
        } else {
            Write-Host "Line '$Line' ignored due to syntax error!" -ForegroundColor Yellow;
        }

        #
        # 
        #$Vols.Add($Line.Split($ColSeparator));
        #$Item.Count;
        #$Item;
    }
#}
#catch {    
#}

Write-Host;