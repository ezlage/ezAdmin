param(
    [switch]$SaveCreds = $false
)

begin {
    Clear-Host;
    CHCP 65001 | Out-Null;
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

    # Specifying sources and destinations
    $Maps = @(
        #@{Name = "Some name"; Source = "\\server\folder"; Destination = "D:\folder"}
    );

    function Get-LastFreeLetter {
        $All = 65..90 | ForEach-Object {[char] $_ + ":"}
        $Used = Get-WmiObject win32_logicaldisk | Select-Object -Expand deviceid;
        $Free = $All | Where-Object {$Used -notcontains $_}
        return $Free | Select-Object -Last 1;
    }

    # Changing current location
    $CDR = Get-Location;
    Set-Location (Split-Path -Parent $PSCommandPath);

    # Configuring and starting transcription
    $Workpath = (Get-Location).Path;
    $Scriptname = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name);
    $KeyFile = "$Workpath\$Scriptname.key";
    $UsrFile = "$Workpath\$Scriptname.usr";
    $PasFile = "$Workpath\$Scriptname.pas";
    $Username   = $env:USERNAME;
    $Hostname   = hostname;
    $Version    = $PSVersionTable.PSVersion.ToString();
    $Datetime   = Get-Date -f 'yyyyMMdd-HHmmss'
    $Filename   = "${Scriptname}-${Username}-${Hostname}-${Version}-${Datetime}.txt";
    $Transcript = Join-Path -Path "$Workpath\Logs" -ChildPath $Filename;        

    if ($SaveCreds) {
        $Key = New-Object Byte[] 32;
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key);
        $Key | Out-File $KeyFile;
        $User = Read-Host -Prompt "Provide a username" -AsSecureString;
        $User | ConvertFrom-SecureString -Key $Key | Out-File $UsrFile;
        $Pass = Read-Host -Prompt "Provide a password" -AsSecureString;
        $Pass | ConvertFrom-SecureString -Key $Key | Out-File $PasFile;
        Write-Host "Credentials have been saved!";
        Write-Host;
        exit;
    }

    if (-not((Test-Path $KeyFile) -and (Test-Path $UsrFile) -and (Test-Path $PasFile))) {
        Write-Host "No credentials stored! Do the following:"
        Write-Host;
        Write-Host "$($MyInvocation.MyCommand.Name) -SaveCreds"
        Write-Host;
        exit;
    }

    # Loading credential
    $Key = Get-Content $KeyFile;
    $User = Get-Content $UsrFile | ConvertTo-SecureString -Key $Key;
    $Pass = Get-Content $PasFile | ConvertTo-SecureString -Key $Key;

    # Issuing notice and starting the work
    Start-Transcript -Path $Transcript;
    Write-Host "Synchronizing repositories...";
    Write-Host;

    # Changing the default action on error or warning
    $EPref = $ErrorActionPreference;
    $WPref = $WarningPreference;
    $PPref = $ProgressPreference;
    $ErrorActionPreference = 'Stop';
    $WarningPreference = 'SilentlyContinue';
    $ProgressPreference = 'SilentlyContinue';

    foreach($Map in $Maps) {
        Write-Host "NAME: [$($Map.Name)]; FROM: [$($Map.Source)]; TO: [$($Map.Destination)]." -ForegroundColor Yellow;
        $MountPoint = Get-LastFreeLetter;
        try {
            Remove-SmbMapping -RemotePath $Map.Source -Force -ErrorAction SilentlyContinue | Out-Null;
            New-SmbMapping -LocalPath $MountPoint -RemotePath $Map.Source -Persistent $false -UserName ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($User))) -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass))) -ErrorAction Stop | Out-Null;
            New-Item -Path $Map.Destination -ItemType Directory -Force | Out-Null;            
            Robocopy.exe "$MountPoint" "$($Map.Destination)" /E /XO /COPY:DAT /DCOPY:DAT /R:1 /W:5 /V /NP /XF "autorun.inf";
            Robocopy.exe "$($Map.Destination)" "$MountPoint" /E /XO /COPY:DAT /DCOPY:DAT /R:1 /W:5 /V /NP /XF "autorun.inf";            
            Write-Host;
            Write-Host "[$($Map.Name)] synchronization success!" -ForegroundColor Green;
            Write-Host;
        } catch {
            Write-Host "[$($Map.Name)] synchronization failed!" -ForegroundColor Red;
        } finally {
            try {
                Remove-SmbMapping -RemotePath $Map.Source -Force -ErrorAction SilentlyContinue | Out-Null
            } finally {}
        }
    }

    # Issuing the last notice
    Write-Host;
    Write-Host "----------------------------------> Done.";
    Write-Host;
    Stop-Transcript;

    # Restoring location
    Set-Location $CDR;

    # Restoring location and default behavior on error
    $ErrorActionPreference = $EPref;
    $WarningPreference = $WPref;
    $ProgressPreference = $PPref;
}