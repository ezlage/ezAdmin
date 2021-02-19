# ezAdmin

A set of scripts to make life easier for SysAdmins in Windows environments.

### Dependencies

- Windows PowerShell
- Command Prompt (cmd)
- Remote Server Administration Tools (RSAT)

### Usage

Just choose a script and run it! Some will be able to work locally, others remotely on an Active Directory domain.

- **Generate-DFSHealthReports.ps1**: Finds all DFSr groups, get statuses and generate all full reports in parallel!;

```PowerShell
.\Generate-DFSHealthReports.ps1 [ReportPath="<path-to-save-reports>"] [PrefSite=<preferred-ad-site>] [Wait]
```

- **Probe-WinServersBootTime.ps1**: Finds active Windows Servers in Active Directory and checks the date and time of the last boot;

- **Probe-WinServersVols.ps1**: Finds active Windows Servers in Active Directory and checks disk space consumption for all letter-mounted volumes.

### Tips, tricks and suggestions

- If you notice changes or increments that may be beneficial for any use case, give the suggestion or send a pull request
- For some scripts, you must first enable and configure PSRemoting, WinRM and Firewall
- What is ok will be displayed in green, errors in red and the rest in yellow

### Change log and roadmap

#### Pending development

New scripts to/that:

- Automate cleaning routines for WSUS servers
- Deploy EXE packages to servers
- Deploy MSI packages to servers
- Detect, disable, and move inactive computer accounts in AD
- Detect, disable, and move inactive user accounts in AD
- Detect and remove the temporary attribute from files
- Facilitate cleaning user profiles on servers
- Make it easier to check the hosts file for multiple servers

#### v0.2.2: Another script and some changes
- Generate-DFSHealthReports.ps1 created, tested and added
- Correction of dates in comments in other scripts

#### v0.1.1: New script and changes
- Probe-WinServersBootTime.ps1 created, tested and added
- Probe-WinServersAndVols.ps1 renamed to Probe-WinServersVols.ps1 and improved

#### v0.0.0: First public pre-release
- Probe-WinServersAndVols.ps1 created, tested and added

### License, credits, feedback and donation

Creative Commons Zero v1.0 Universal  
Developed by [Ezequiel Lage](https://twitter.com/ezlage), Sponsored by [Lageteck](https://lageteck.com)  
For feedback, contact@lageteck.com

#### Please, support this initiative!
BTC: 1KMBgg1h3TGPCWZyi4iFo55QvYrdo5JyRc  
DASH: Xt7BNFyCBxPdnubx5Yp1MjTn7sJLSnEd5i  
DCR: Dscy8ziqa2qz1oFNcbTXDyt3V1ZFZttdRcn  
ETH: 0x06f1382300723600b3fa9c16ae254e20264cb955  
LTC: LZJPrFv7a7moL6oUHPo8ecCC9FcbY49uRe  
USDC: 0x38be157daf7448616ba5d4d500543c6dec8214cc  
ZEC: t1eGBTghmxVbPVf4cco3MrEiQ8MZPQAzBFo   