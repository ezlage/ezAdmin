## ezAdmin

### Convert-AdSidToHex.ps1

Converts an Active Directory SID to hexadecimal format for specific use cases.

The script takes an Active Directory SID as input and converts it to a hexadecimal string. This can be useful in scenarios where the hexadecimal representation of the SID is required, such as when working with certain APIs or tools that expect SIDs in this format.

#### Usage

```powershell
.\Convert-AdSidToHex "some-ad-sid"

# Example:
.\Convert-AdSidToHex "S-1-5-21-3623811015-3361044348-30300820-1013"

# Example output:
# 01 05 00 00 00 00 00 05 15 00 00 00 C7 F7 FE D7 7C 77 55 C8 94 5A CE 01 F5 03 00 00
```

#### Highlights

Thanks to [Raymond Chen](https://github.com/oldnewthing) for the explanation<sup>[1](https://devblogs.microsoft.com/oldnewthing/20040315-00/?p=40253)</sup> that made this script possible.