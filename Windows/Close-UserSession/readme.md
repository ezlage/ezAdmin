## ezAdmin

### Close-UserSession.bat

Terminates sessions for a given username locally or remotely.

The script uses the *query user* command to find all sessions for the specified username, and then uses the *logoff* command to terminate each session. If a computer name is provided, it will execute the commands remotely on that computer; otherwise, it will execute them locally.

#### Usage

```cmd
Close-UserSession username [computer]
```