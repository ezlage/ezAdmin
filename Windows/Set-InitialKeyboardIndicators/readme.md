## ezAdmin

### Set-InitialKeyboardIndicators.bat

Sets the initial keyboard indicators for the current user or all users

```powershell
Set-InitialKeyboardIndicators value [all]

# value: some integer (0 to disable Numlock, 2 to enable it; supports any other integer value)

# all: applies to all user profiles, including standard and system profiles; otherwise only the current user

# Example to disable NumLock according to the computer model using PowerShell: 
systeminfo | find /i "computer-model"; if ($?) {Set-InitialKeyboardIndicators 0 all}

# Example to disable NumLock according to the computer model using Command Prompt: 
systeminfo | find /i "computer-model" && Set-InitialKeyboardIndicators 0 all
```