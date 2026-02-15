## ezAdmin

### Set-BgImages.ps1

Changes the desktop and lock screen background image on any edition of Windows 10 and 11.

```powershell
# Usage
.\Set-BgImages [-LockScreenImage <"network-path-to-the-image">] [-DesktopImage <"network-path-to-the-image">] [-LogPath "log-folder-network-path"]

# Example
.\Set-BgImages -LockScreenImage "\\srvfs01\folder\LockScreen.png" -DesktopImage "\\srvfs01\folder\Desktop.png" -LogPath "\\srvfs01\folder"
```

Credits to [Juan Granados](https://github.com/juangranados) for the original version of *Set-BgImages.ps1*, formely *Set-Screen.ps1*<sup>[2](https://web.archive.org/web/20200318093921/https://gallery.technet.microsoft.com/scriptcenter/Change-Lock-Screen-and-245b63a0)</sup> or *Set-LockScreen.ps1*<sup>[3](https://github.com/juangranados/powershell-scripts/tree/main/Change%20Lock%20Screen%20and%20Desktop%20Background%20in%20Windows%2010%20Pro)</sup>.