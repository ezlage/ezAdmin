## ezAdmin

### Set-BgImages.ps1

Changes the desktop and lock screen background image on any edition of Windows 10 and 11.

The script accepts network paths to the images to be set as the lock screen and desktop backgrounds, and an optional log path to save the execution logs. It circunvents the limitations of the Windows Settings app and Group Policy for changing these backgrounds, allowing administrators to deploy custom images across their organization regardless of the Windows edition in use.

#### Usage

```powershell
.\Set-BgImages [-LockScreenImage <"network-path-to-the-image">] [-DesktopImage <"network-path-to-the-image">] [-LogPath "log-folder-network-path"]

# Example
.\Set-BgImages -LockScreenImage "\\srvfs01\folder\LockScreen.png" -DesktopImage "\\srvfs01\folder\Desktop.png" -LogPath "\\srvfs01\folder"
```

#### Highlights

Credits to [Juan Granados](https://github.com/juangranados) for the original version of *Set-BgImages.ps1*, formely *Set-Screen.ps1*<sup>[1](https://web.archive.org/web/20200318093921/https://gallery.technet.microsoft.com/scriptcenter/Change-Lock-Screen-and-245b63a0)</sup> or *Set-LockScreen.ps1*<sup>[2](https://github.com/juangranados/powershell-scripts/tree/main/Change%20Lock%20Screen%20and%20Desktop%20Background%20in%20Windows%2010%20Pro)</sup>.