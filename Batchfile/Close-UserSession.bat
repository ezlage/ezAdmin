@ECHO OFF & CLS
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO.
ECHO =========================================
ECHO =                ezAdmin                =
ECHO =========================================
ECHO = Developed -by Ezequiel Lage (@ezlage) =
ECHO = Sponsored -by Lageteck (lageteck.com) =
ECHO = Material protected by a license (MIT) =
ECHO =========================================
ECHO.

SET "SESSIONS="
SET "SSFOUND=FALSE"
IF "%1" EQU "" GOTO END
IF "%2" NEQ "" GOTO REMOTE
IF "%3" NEQ "" GOTO END
GOTO LOCAL

:LOCAL
SET "COMPUTER=%COMPUTERNAME%"
FOR /F "USEBACKQ TOKENS=2" %%U IN (`QUSER 2^>nul ^| FINDSTR /I "\<%1\>"`) DO (
	SET "SSFOUND=TRUE"
	SET "SESSIONS=%%U; %SESSIONS%"
	LOGOFF %%U
)
GOTO END

:REMOTE
SET "COMPUTER=%2"
FOR /F "USEBACKQ TOKENS=2" %%U IN (`QUSER /SERVER:%2 2^>nul ^| FINDSTR /I "\<%1\>"`) DO (
	SET "SSFOUND=TRUE"
	SET "SESSIONS=%%U; %SESSIONS%"
	LOGOFF %%U /SERVER:%2
)
GOTO END

:END
IF "%SSFOUND%" EQU "FALSE" ECHO No sessions found with the given parameters^^!
IF "%SSFOUND%" EQU "TRUE" (
	ECHO  User "%1" had the following sessions on "%COMPUTER%":
	ECHO.
	ECHO    %SESSIONS:~0,-2%
	ECHO.
	ECHO  All listed sessions have been terminated^^!
)
SET "SSFOUND="
SET "SESSIONS="
SET "COMPUTER="