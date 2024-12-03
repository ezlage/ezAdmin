@ECHO OFF & CLS

ECHO.
ECHO =========================================
ECHO =                ezAdmin                =
ECHO =========================================
ECHO = Developed -by Ezequiel Lage (@ezlage) =
ECHO = Sponsored -by Lageteck (lageteck.com) =
ECHO = Material protected by a license (MIT) =
ECHO =========================================
ECHO.

IF "%1"=="" GOTO HELP
ECHO %1 | FINDSTR /R "\<[0-9][0-9]*\>" 2>NUL 1>NUL || GOTO HELP
ECHO %2 | FINDSTR /I "\<all\>" 2>NUL 1>NUL || GOTO CURRENTUSER
COPY NUL "%WINDIR%\ezAdmin-SetIKI.privtest" 2>NUL 1>NUL || (
	ECHO Due to lack of privileges, only the current user will be modified!
	GOTO CURRENTUSER
)
DEL /Q "%WINDIR%\ezAdmin-SetIKI.privtest" 2>NUL 1>NUL
ECHO Due to the presence of privileges, all users will be modified!

FOR /F "TOKENS=*" %%I IN ('REG QUERY "HKEY_USERS" ^| FIND /I /V "_Classes"') DO (
	REG ADD "%%I\Control Panel\Keyboard" /V "InitialKeyboardIndicators" /T "REG_SZ" /D "%1" /F 2>NUL 1>NUL
)

FOR /F "TOKENS=3" %%I IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /V "Default"') DO (
	CMD /C "REG LOAD "HKEY_LOCAL_MACHINE\ezAdmin-SetIKI" "%%I\NTUSER.DAT" 2>NUL 1>NUL"
	REG ADD "HKEY_LOCAL_MACHINE\ezAdmin-SetIKI\Control Panel\Keyboard" /V "InitialKeyboardIndicators" /T "REG_SZ" /D "%1" /F 2>NUL 1>NUL
	REG UNLOAD "HKEY_LOCAL_MACHINE\ezAdmin-SetIKI" 2>NUL 1>NUL
)

FOR /F "TOKENS=3" %%I IN ('REG QUERY "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" /V "ProfilesDirectory"') DO SET "PROFDIR=%%I"
FOR /F "TOKENS=*" %%I IN ('DIR /B /A:D "%PROFDIR%"') DO (
	CMD /C "REG LOAD "HKEY_LOCAL_MACHINE\ezAdmin-SetIKI" "%PROFDIR%\%%I\NTUSER.DAT" 2>NUL 1>NUL"
	REG ADD "HKEY_LOCAL_MACHINE\ezAdmin-SetIKI\Control Panel\Keyboard" /V "InitialKeyboardIndicators" /T "REG_SZ" /D "%1" /F 2>NUL 1>NUL
	REG UNLOAD "HKEY_LOCAL_MACHINE\ezAdmin-SetIKI" 2>NUL 1>NUL
)

:CURRENTUSER
ECHO Running for current user...
REG ADD "HKEY_CURRENT_USER\Control Panel\Keyboard" /V "InitialKeyboardIndicators" /T "REG_SZ" /D "%1" /F 2>NUL 1>NUL || ECHO Failed to manipulate "HKEY_CURRENT_USER\Control Panel\Keyboard\InitialKeyboardIndicators"!
ECHO.
ECHO Done.
GOTO END

:HELP
ECHO Sets the initial keyboard indicators for the current user or for everyone.
ECHO.
ECHO Usage: %~N0%~X0 value [all]
ECHO.
ECHO   value		Some integer value (0 to turn Numlock off, 2 to turn it on)
ECHO   all  		Apply to all user profiles, including the default profile
ECHO.

:END