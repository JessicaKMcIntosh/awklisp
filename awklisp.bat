@ECHO OFF
REM Makes running AWK Lisp easier.
REM Sets AWKPATH for loading modules.

ECHO Running AWK Lisp...

REM Local variables please.
SETLOCAL

REM Make sure GAWK is installed.
CALL :CheckGAWK

REM The path to this batch file.
SET AWK_LISP_DIR=%~dp0

REM Add the AWK Lisp paths to AWKPATH.
IF DEFINED AWKPATH (
    ECHO. %AWKPATH% | FINDSTR /C:%AWK_LISP_DIR% > NUL || (
    SET AWKPATH=%AWK_LISP_DIR%;%AWK_LISP_DIR%Modules;%AWKPATH%
    )
) else (
    SET AWKPATH=%AWK_LISP_DIR%;%AWK_LISP_DIR%Modules
)


REM The name of this script for help text.
SET THISSCRIPT=%0

REM       -----===== Defaults ======------

REM Do not load modules by default.
SET AWKLispModules=

REM Disable Lint by default.
SET LintOption=

REM Interactive mode by default.
SET InteractiveMode=yes

REM       -----===== Process Command Line ======------

REM Figure out what we were given on the command line.
:ProcessArgs
    IF /I "%1"=="/l"     (GOTO :LintEnable)
    IF /I "%1"=="-l"     (GOTO :LintEnable)
    IF /I "%1"=="/m"     (GOTO :LoadAllModules)
    IF /I "%1"=="-m"     (GOTO :LoadAllModules)
    IF /I "%1"=="/q"     (GOTO :NonInteractive)
    IF /I "%1"=="-q"     (GOTO :NonInteractive)
    IF /I "%1"=="help"   GOTO :ShowHelp
    IF /I "%1"=="/?"     GOTO :ShowHelp
    IF /I "%1"=="/h"     GOTO :ShowHelp
    IF /I "%1"=="-h"     GOTO :ShowHelp
    IF /I "%1"=="--help" GOTO :ShowHelp

Goto :RunAWKLisp
GOTO :exitscript
ECHO You should not see this message.

REM       -----===== Functions ======------

REM Run AWK Lisp.
:RunAWKLisp
    @REM ECHO ON
    SET GawkCmd=%LintOption% %AWKLispModules% -f %AWK_LISP_DIR%awklisp %1 %2 %3 %4 %5 %6 %7 %8 %9
    ECHO gawk %GawkCmd%
    IF %InteractiveMode% == yes (
        gawk %GawkCmd%
        EXIT /B
    ) else (
        gawk %GawkCmd% < NUL
        EXIT /B
    )
    GOTO :exitscript

REM       -----===== Help Text ======------

REM Show some help text.
:ShowHelp
    ECHO Run AWK Lisp.
    ECHO Usage: %THISSCRIPT% [OPTIONS] FILE(S)
    ECHO.
    ECHO Options:
    ECHO /h     - Display this help text. Also -h or /?
    ECHO /l     - Enable lint mode.
    ECHO /m     - Load all of the available modules.
    ECHO /q     - Non-Interactive mode.
    GOTO :exitscript

REM       -----===== Helper Functions ======------

REM Check if Docker is installed.
:CheckGAWK
    gawk --version > NUL 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        ECHO GAWK is not in the current path.
        GOTO exitscript
    )
    EXIT /B

ECHO You should not see this message.

REM Enable Lint mode.
:LintEnable
    SET LintOption=--lint=no-ext -i lint.awk
    SHIFT
    GOTO :ProcessArgs


REM Load all modules.
:LoadAllModules
    SET AWKLispModules=-i all.awk
    SHIFT
    GOTO :ProcessArgs

REM Disable interactive mode.
:NonInteractive
    SET InteractiveMode=no
    SHIFT
    GOTO :ProcessArgs

REM Exit the script.
:exitscript