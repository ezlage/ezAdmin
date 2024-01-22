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

IF EXIST "%PROGRAMFILES%\TeamViewer\uninstall.exe" (
    CALL :FOUND 64
    "%PROGRAMFILES%\TeamViewer\uninstall.exe" /S && CALL :SUCCESS 64 || CALL :FAILED 64
) ELSE CALL :NOTFOUND 64

IF EXIST "%PROGRAMFILES(X86)%\TeamViewer\uninstall.exe" (
    CALL :FOUND 32
    "%PROGRAMFILES(X86)%\TeamViewer\uninstall.exe" /S && CALL :SUCCESS 32 || CALL :FAILED 32
) ELSE CALL :NOTFOUND 32

GOTO END

:FOUND
ECHO TeamViewer %1-bit version found!
GOTO :EOF

:NOTFOUND
ECHO TeamViewer %1-bit version not found!
GOTO :EOF

:SUCCESS
ECHO TeamViewer %1-bit successfully uninstalled!
GOTO :EOF

:FAILED
ECHO Failed to uninstall %1-bit TeamViewer!
GOTO :EOF

:END