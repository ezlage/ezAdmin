# ezAdmin

A set of scripts to make life easier for SysAdmins in large environments.

## Requirements and Dependencies

- On Windows, some scripts require Active Directory Domain Services, Remote Server Administration Tools (RSAT) and/or at least PowerShell 5.1.

## Usage Instructions

Just choose a script and run it! Some may work locally, others remotely if there is an Active Directory domain.

- **Close-UserSession.bat**: Logs off an user locally or remotely

    ```powershell
    Close-UserSession username [computer]
    ```

- **Set-InitialKeyboardIndicators.bat**: Sets the initial keyboard indicators for the current user or all users

    ```powershell
    Set-InitialKeyboardIndicators value [all]

    # value: some integer (0 to disable Numlock, 2 to enable it; supports any other integer value)

    # all: applies to all user profiles, including standard and system profiles; otherwise only the current user

    # Example to disable NumLock according to the computer model
    SYSTEMINFO | FIND /I "computer-model" && Set-InitialKeyboardIndicators 0 all
    ```

- **Uninstall-AnyDesk.bat**: Detects and silently uninstalls AnyDesk

- **Uninstall-TeamViewer.bat**: Detects and silently uninstalls TeamViewer

- **Convert-AdSidToHex.ps1**: Converts an AD SID to hexadecimal format

    ```powershell
    .\Convert-AdSidToHex "S-1-5-21-3623811015-3361044348-30300820-1013"
    ```

- **Set-BgImages.ps1**: Change the desktop and lock screen background image on any edition of Windows 10 and 11

    ```powershell
    .\Set-BgImages [-LockScreenImage <"network-path-to-the-image">] [-DesktopImage <"network-path-to-the-image">] [-LogPath "log-folder-network-path"]
    
    # Example
    .\Set-BgImages -LockScreenImage "\\srvfs01\folder\LockScreen.png" -DesktopImage "\\srvfs01\folder\Desktop.png" -LogPath "\\srvfs01\folder"
    ```

- **Mount-BulkMappings.ps1**: Mounts network shares locally, in bulk, for specific use cases

    ```powershell
    .\Mount-BulkMappings -MappingsCSV <".\BulkMappings.csv"> [-SkipCredPrompt]
    
    # MappingsCSV: the CSV file containing the list of mappings to be carried out.
    
    # SkipCredPrompt: don't prompt for credentials, useful for silent execution via GPO
    
    # You can run the script via GPO with the SkipCredPrompt parameter and create a shortcut for it on the user's desktop. This way, the user can run the script only to save the credential, if it is different from the one already logged in.

    # About the CSV file:
    
    #   - It must must be separated by commas and have the following columns:    
    
    #       Entity, DriveLetter, FullPath, Persistent, CredPrompt, SaveCred
    
    #       Entity
    #           The target group or user account name
    #       DriveLetter
    #           The drive letter (A-Z or some special port like LPT/COM)
    #       FullPath
    #           The full network path of the resource to be mapped
    #           (in some specific cases it could be a shared printer)
    #       Persistent
    #           Will the mapping persist after logoff?
    #       CredPrompt
    #           Will it be necessary to request credentials?
    #           (it will be only once and apply to all mappings for the same user)
    #       SaveCred
    #           Should the credentials be saved in the user profile?
    #           (it uses the cmdkey utility)
    
    #   - Values interpreted as positive:
    #           true, yes, y, 1
    
    #   - Values interpreted as negative:
    #           false, no, n, 0
    
    #   - Some example lines:
    
    #           "SomeUser","Z","\\server\folderA",1,1,1
    #           "SomeGroup","Y","\\server\folderB",0,0,0   
    ```

### Tips and tricks

- If you notice changes or increments that could be beneficial for some use case, start a discussion or submit a pull request!
- For some scripts, you must first enable and configure PSRemoting, WinRM, Firewall, etc.
- Remember: unlike Batchfiles, PowerShell scripts require the ".\\" prefix to run!

## Roadmap and Changelog

This repository is based on and inspired by - but not limited to - [Keep a Changelog](https://keepachangelog.com/), [Semantic Versioning](https://semver.org/) and the [ezGTR](https://github.com/ezlage/ezGTR) template. Therefore, any changes made, expected or intended will be documented in the [Roadmap and Changelog](./RMAP_CLOG.md) file.  

## Credits, Sponsorship and Licensing

Developed by [Ezequiel Lage](https://github.com/ezlage), Sponsored by [Lageteck](https://lageteck.com) and Published under the [MIT License](./LICENSE.txt).  

Credits to [Raymond Chen](https://github.com/oldnewthing) for the explanation<sup>[1](https://devblogs.microsoft.com/oldnewthing/20040315-00/?p=40253)</sup> that made the *Convert-AdSidToHex.ps1* script possible. Credits to [Juan Granados](https://github.com/juangranados) for the original version of *Set-BgImages.ps1*, formely *Set-Screen.ps1*<sup>[2](https://web.archive.org/web/20200318093921/https://gallery.technet.microsoft.com/scriptcenter/Change-Lock-Screen-and-245b63a0)</sup> or *Set-LockScreen.ps1*<sup>[3](https://github.com/juangranados/powershell-scripts/tree/main/Change%20Lock%20Screen%20and%20Desktop%20Background%20in%20Windows%2010%20Pro)</sup>. Credits also to [Tim Brown](https://github.com/timbrownls20) for developing the *GetHostname*<sup>[4](https://codebuckets.com/2017/08/04/5-ways-to-extract-the-computer-name-from-a-network-file-path-with-powershell/)</sup> function, used in the *Mount-BulkMappings.ps1* script as *Get-Hostname*.

All suggestions, criticisms and contributions are welcome!  

### Support this initiative!

BTC: 1Nw2fzDgtXM5X219Q9VtJ7WaSTDPua3oe8  
ERC20*: 0x089499f57ee20fd2c19f57612d9af69d645dff0d  
\* Any ERC20 token supported by Binance (ETH, USDC, USDT, etc)  