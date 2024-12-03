# Reference: https://devblogs.microsoft.com/oldnewthing/20040315-00/?p=40253 (Raymond Chen, @oldnewthing, 2004)

param (
    [string]$SID
)

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

function CheckSID {
    param(
        [string]$SID
    )    
    if (($SID -replace ("[^0-9.]","") | Measure-Object -Character).Characters -eq (($SID -replace "-","" | Measure-Object -Character).Characters) -and ($SID.Split("-").Count -eq 7)) {
        return $true;
    }
    return $false;
}

$SID = $SID.toUpper().Replace("S-","").Trim();
$Segments = $SID.Split("-");

if (CheckSID($SID)) {
    Write-Host "Original SID: $SID";   
    
    $HexSid = "";
    for ($i = 0; $i -lt $Segments.Count; $i++) {
      switch ($i) {
        0 {
            $HexSid += '{0:X2}' -f [Convert]::ToInt64($Segments[$i]);
        }
        1 {
            $HexSid += '{0:X2}' -f [Convert]::ToInt64($Segments[$i]);
            $HexSid += '{0:X12}' -f ($Segments.Count - 2);
        }
        default {                      
            $HexStr = "0x" + '{0:X8}' -f [Convert]::ToInt64($Segments[$i]);
            $Bytes = [byte[]] ($HexStr -replace '^0x' -split '(..)' -ne '' -replace '^', '0x');
            if ([BitConverter]::IsLittleEndian) {
                [Array]::Reverse($Bytes);
            }                        
            foreach ($Byte in $Bytes) {
                $HexSid += '{0:X2}' -f $Byte;
            }           
        }
      }
    }

    $CharArray = $HexSid.ToCharArray();
    $HexSid = "";
    for ($i = 0; $i -lt $CharArray.Count; $i++) {
        if ($i % 2 -eq 1) {
            $HexSid = $HexSid + $CharArray[$i] + " ";
        } else {
            $HexSid = $HexSid + $CharArray[$i];
        } 
    }

    Write-Host "Equivalent in hexadecimal: " -NoNewline;
    Write-Host $HexSid;
    Write-Host;    
} else {
    Write-Host -ForegroundColor Red "'$SID' is not a valid SID!";
    Write-Host;
}
