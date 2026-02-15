<#PSScriptInfo

.VERSION 2.0

.GUID 9320af4f-61f1-4e65-9579-62e6e14e3d4f

.AUTHOR Juan Granados

.COPYRIGHT 2021, Juan Granados

.TAGS Windows Desktop Lock Screen Background

.LICENSEURI https://github.com/juangranados/powershell-scripts/blob/main/LICENSE

.PROJECTURI https://github.com/juangranados/powershell-scripts/tree/main/Change%20Lock%20Screen%20and%20Desktop%20Background%20in%20Windows%2010%20Pro

.RELEASENOTES
v1.0: The original Set-Screen.ps1/Set-LockScreen.ps1 made by Juan Granados (@juangranados)
v2.0: Set-BgImages.ps1, an improved version made by Ezequiel Lage (@ezlage)

#>

<#
.SYNOPSIS
	Change the desktop and lock screen background image on any edition of Windows 10 or 11.

.DESCRIPTION
	This script aims to change the desktop and lock screen background image on any edition of Windows 10 or 11, being invoked with elevation via GPO.

.PARAMETER LockScreenImage (Optional)
	Path to the Lock Screen background image to copy locally in computer;
    Example: "\\srvfs01\folder\LockScreen.png".

.PARAMETER DesktopImage (Optional)
	Path to the Desktop background image to copy locally in computer;
    Example: "\\srvfs01\folder\Desktop.png".

.PARAMETER LogPath (Optional)
    Path where save log file; If it's not specified no log is recorded.

.EXAMPLE
    Set Lock Screen and Desktop background image with logs:
    .\Set-BgImages -LockScreenImage "\\srvfs01\folder\LockScreen.png" -DesktopImage "\\srvfs01\folder\Desktop.png" -LogPath "\\srvfs01\folder\Logs"

.EXAMPLE
    Set Lock Screen and Desktop Wallpaper without logs:
    .\Set-BgImages -LockScreenImage "\\srvfs01\folder\LockScreen.png" -DesktopImage "\\srvfs01\folder\Desktop.png"

.EXAMPLE
    Set Lock Screen only:
    .\Set-BgImages -LockScreenImage "\\srvfs01\folder\LockScreen.png" -LogPath "\\srvfs01\folder\Logs"

.EXAMPLE
	Set Desktop Wallpaper only:
    .\Set-BgImages -DesktopImage "\\srvfs01\folder\Desktop.png" -LogPath "\\srvfs01\folder\Logs"

.NOTES 
	Author:			Juan Granados (@juangranados)
	Date:			September, 2018
    
    Contributor:	Ezequiel Lage (@ezlage)
    Date:			January, 2024
#>

Param(
    [Parameter(Mandatory=$false,Position=0)] 
    [ValidateNotNullOrEmpty()]
    [string]$LockScreenImage,
    [Parameter(Mandatory=$false,Position=1)] 
    [ValidateNotNullOrEmpty()]
    [string]$DesktopImage,
    [Parameter(Mandatory=$false,Position=2)] 		
    [ValidateNotNullOrEmpty()]
    [string]$LogPath
)

#Requires -RunAsAdministrator;

$ErrorActionPreference = "Stop";
$ScriptName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name);

if ([string]::IsNullOrWhiteSpace($LogPath)) {
    $LogPath = $env:TEMP;
}

try {
    Start-Transcript -Path "$($LogPath)\$($ScriptName)_$($env:COMPUTERNAME).log" -Append | Out-Null;
} catch {
    Start-Transcript -Path "$($env:TEMP)\$($ScriptName)_$($env:COMPUTERNAME).log" -Append | Out-Null;
}

$RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP";
$DesktopPath = "DesktopImagePath";
$DesktopStatus = "DesktopImageStatus";
$DesktopUrl = "DesktopImageUrl";
$LockScreenPath = "LockScreenImagePath";
$LockScreenStatus = "LockScreenImageStatus";
$LockScreenUrl = "LockScreenImageUrl";
$StatusValue = "1";
$DesktopImageDest = "C:\Windows\Web";
$LockScreenImageDest = "C:\Windows\Web";

if (!$LockScreenImage -and !$DesktopImage) {
    Write-Host "Either LockScreenImage or DesktopImage must has a value!";
} else {
    try {
        Write-Host "Starting..." -ForegroundColor Yellow;
        if(!(Test-Path $RegKeyPath)) {
            Write-Host "Creating registry path '$($RegKeyPath)'...";
            New-Item -Path $RegKeyPath -Force | Out-Null;
        }
        if ($LockScreenImage) {
            Write-Host "Copying Lock Screen image from '$($LockScreenImage)' to '$($LockScreenImageDest)'...";
            Copy-Item $LockScreenImage $LockScreenImageDest -Force | Out-Null;
            $LockScreenImageDest = $LockScreenImageDest + "\" + [System.IO.Path]::GetFileName($LockScreenImage);            
            Write-Host "Creating registry entries for Lock Screen...";
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null;
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageDest -PropertyType STRING -Force | Out-Null;
            New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageDest -PropertyType STRING -Force | Out-Null;
        }
        if ($DesktopImage) {
            Write-Host "Copying Desktop image from '$($DesktopImage)' to '$($DesktopImageDest)'...";
            Copy-Item $DesktopImage $DesktopImageDest -Force | Out-Null;
            $DesktopImageDest = $DesktopImageDest + "\" + [System.IO.Path]::GetFileName($DesktopImage);            
            Write-Host "Creating registry entries for Desktop...";
            New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null;
            New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageDest -PropertyType STRING -Force | Out-Null;
            New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageDest -PropertyType STRING -Force | Out-Null;
        }
        Write-Host "Done." -ForegroundColor Green;
    } catch {
        Write-Host "Script execution was interrupted due to an error!" -ForegroundColor Red;
        Write-Host "        $($_.Exception.GetType().FullName)" -ForegroundColor Red;
        Write-Host "        $($_.Exception.Message)" -ForegroundColor Red;
    }
}

try {
    Stop-Transcript | Out-Null;
} finally {}
