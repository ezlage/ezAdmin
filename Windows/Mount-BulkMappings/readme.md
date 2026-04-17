## ezAdmin

### Mount-BulkMappings.ps1

Mounts network shares locally, in bulk, for specific use cases.

It is designed to map multiple network drives to different users or groups across non-integrated domains, with some degree of automation.

#### Usage

```powershell
.\Mount-BulkMappings -MappingsCSV <".\BulkMappings.csv"> [-SkipCredPrompt]

# MappingsCSV: the CSV file containing the list of mappings to be carried out.

# SkipCredPrompt: avoid asking for credentials, which is useful when they are already saved via 'cmdkey'.
```

About the CSV file:

- It must must be separated by commas and have the following columns:

	**Entity, DriveLetter, FullPath, Persistent, CredPrompt, SaveCred**

	`Entity`: The target group or user account name.

	`DriveLetter`: The drive letter (A-Z or some special port like LPT/COM).

	`FullPath`: The full network path of the resource to be mapped (in some scenarios it could be a shared printer).

	`Persistent`: Will the mapping persist after logoff?

	`CredPrompt`: Will it be necessary to request credentials? if yes, it will be only once and apply to all mappings for the same user.

	`SaveCred`: Should the credentials be saved in the user profile vault? (it uses the cmdkey utility)

- Values interpreted as positive:  
        true, yes, y, 1

- Values interpreted as negative:  
        false, no, n, 0

- Some example lines:  

        "SomeUser","X","\\server\folderA",1,1,1
        "SomeGroup","Y","\\server\folderB",0,0,0

#### Highlights

Thanks to [Tim Brown](https://github.com/timbrownls20) for developing the *GetHostname*<sup>[1](https://codebuckets.com/2017/08/04/5-ways-to-extract-the-computer-name-from-a-network-file-path-with-powershell/)</sup> function, used in the *Mount-BulkMappings.ps1* script as *Get-Hostname*.
