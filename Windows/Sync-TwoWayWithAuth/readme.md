## ezAdmin

### Sync-TwoWayWithAuth.ps1

Synchronizes data bidirectionally between repositories.

This script allows you to synchronize data between two repositories, ensuring that changes made in one repository are reflected in the other. It supports authentication, allowing you to securely access both repositories.

#### Usage

Edit lines 11 to 12, inserting the synchronization tasks, run manually with the desired credential (saving it) and then create a scheduled task associated with the same credential. Saved credentials are recoverable only in the context of the user who saved them. Remember, renaming folders or files will lead to duplication on both sides.

```powershell
.\Sync-TwoWayWithAuth.ps1 [-SaveCreds]

# SaveCreds: Saves credentials in encrypted files for later use in scheduled tasks.

# Example for first run
.\Sync-TwoWayWithAuth.ps1 -SaveCreds

# Example for subsequent runs (already saved credentials)
.\Sync-TwoWayWithAuth.ps1
```
