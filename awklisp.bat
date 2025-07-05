@ECHO OFF
REM Makes running AWK Lisp easier.
REM Sets AWKPATH for loading modules.
REM See the following for help in BAT scripts.
REM https://en.wikibooks.org/wiki/Windows_Batch_Scripting

REM Local variables please.
SETLOCAL

REM The path to this batch file.
SET AWK_LISP_DIR=%~dp0

REM Add the AWK Lisp paths to AWKPATH.
IF DEFINED AWKPATH (
    ECHO. %AWKPATH% | FINDSTR /C:%AWK_LISP_DIR% > NUL || (
    SET AWKPATH=%AWK_LISP_DIR%;%AWK_LISP_DIR%Modules;%AWK_LISP_DIR%Extras;%AWKPATH%
    )
) else (
    SET AWKPATH=%AWK_LISP_DIR%;%AWK_LISP_DIR%Modules;%AWK_LISP_DIR%Extras
)

REM ----~~~~++++====#### Settings ####====++++~~~~----

REM The name of this script for help text.
SET THISSCRIPT=%0

REM The Gawk program file.
SET GawkProgram=gawk.exe

REM The AWK Lisp file.
SET AWKLispFile=%AWK_LISP_DIR%awklisp

REM Extra debugging output.
SET DebugEnabled=no

REM Interactive mode.
SET InteractiveEnabled=yes

REM Perform linting.
SET LintEnabled=no

REM Load modules.
SET ModulesEnabled=no

REM Display all objects after exit.
SET ObjectsEnabled=no

REM Reduce AWK Lisp output.
SET QuietEnabled=no

REM The command to execute AWK Lisp.
SET GawkCmd=

REM Options from the command line to pass to AWK Lisp.
SET GawkArgs=

REM       -----===== Process Command Line ======------

CALL :DebugMsg Processing command line options...
:ProcessArgs
    IF /I "%1"==""        GOTO :FinishedArgs
    IF /I "%1"=="/d"      GOTO :SetDebug
    IF /I "%1"=="-d"      GOTO :SetDebug
    IF /I "%1"=="/g"      GOTO :SetGawk
    IF /I "%1"=="-g"      GOTO :SetGawk
    IF /I "%1"=="/l"      GOTO :SetLint
    IF /I "%1"=="-l"      GOTO :SetLint
    IF /I "%1"=="/m"      GOTO :SetModules
    IF /I "%1"=="-m"      GOTO :SetModules
    IF /I "%1"=="/n"      GOTO :SetInteractive
    IF /I "%1"=="-n"      GOTO :SetInteractive
    IF /I "%1"=="/o"      GOTO :SetObjects
    IF /I "%1"=="-o"      GOTO :SetObjects
    IF /I "%1"=="/q"      GOTO :SetQuiet
    IF /I "%1"=="-q"      GOTO :SetQuiet
    IF /I "%1"=="help"    GOTO :ShowHelp
    IF /I "%1"=="/?"      GOTO :ShowHelp
    IF /I "%1"=="/h"      GOTO :ShowHelp
    IF /I "%1"=="-h"      GOTO :ShowHelp
    IF /I "%1"=="--help"  GOTO :ShowHelp
    SET z=%1
    IF /I "%z:~0,1%"=="/" GOTO :InvalidArg
    IF /I "%z:~0,1%"=="-" GOTO :InvalidArg
:FinishedArgs

REM Make sure Gawk is installed.
CALL :DebugMsg Checking the Gawk program...
CALL :CheckGawk
IF %ERRORLEVEL% NEQ 0 GOTO :ExitScript

REM Add remaining command line options.
:AddArgs
    IF "%~1"=="" GOTO :EndAddArgs
    SET GawkArgs=%GawkArgs% %1
    SHIFT
    GOTO :AddArgs
:EndAddArgs

REM Run AWK Lisp!
CALL :RunAWKLisp
GOTO :ExitScript

:InvalidArg
    ECHO Invalid command line option: %1
    GOTO :ExitScript

REM ----~~~~++++====#### Run AWK Lisp ####====++++~~~~----

REM Run AWK Lisp.
:RunAWKLisp
    CALL :DebugMsg Running AWK Lisp...

    REM Setup the command based on the options.
    CALL :BuildGawkCmd

    IF %DebugEnabled% == yes CALL :PrintDebug

    IF %InteractiveEnabled% == yes (
        %GawkCmd% -
        EXIT /B
    ) else (
        %GawkCmd% < NUL
        EXIT /B
    )
    EXIT /B

REM Build the Gawk command to run AWK Lisp
:BuildGawkCmd
    REM Start with the Gawk program.
    SET GawkCmd=%GawkProgram%

    REM Set the variable quiet for less output.
    IF %QuietEnabled% == yes (
        SET GawkCmd=%GawkCmd% -v quiet=1
    )

    REM Include the file that makes --lint less annoying.
    IF %LintEnabled% == yes (
        SET GawkCmd=%GawkCmd% --lint=no-ext -i lint.awk
    )

    REM Load the available modules.
    IF %ModulesEnabled% == yes (
        SET GawkCmd=%GawkCmd% -i all.awk
    )

    REM Print all objects after execution.
    IF %ObjectsEnabled% == yes (
        SET GawkCmd=%GawkCmd% -i world_objects.awk
    )

    REM Add the AWK Lisp program.
    SET GawkCmd=%GawkCmd% -f %AWKLispFile%

    REM Finally add any command line options.
    SET GawkCmd=%GawkCmd%%GawkArgs%
    EXIT /B

REM       -----===== Help Text ======------

REM Show some help text.
:ShowHelp
    ECHO Run AWK Lisp.
    ECHO Usage: %THISSCRIPT% [OPTIONS] FILE(S)
    ECHO.
    ECHO Options:
    ECHO /d or -d - Extra debugging output.
    ECHO /h or -h - Display this help text. Also -? or /?
    ECHO /g or -g - Specify the Gawk program.
    ECHO            Defaults to: %GawkProgram%
    ECHO /l or -l - Enable lint mode.
    ECHO /m or -m - Load all of the available modules.
    ECHO /n or -n - Non-Interactive mode.
    ECHO /o or -o - Display all objects after exit.
    ECHO /q or -q - Quite, reduced output from AWK Lisp.
    ECHO.
    ECHO (Case of options does not matter.)
    GOTO :ExitScript

REM ----~~~~++++====#### Helper Functions ####====++++~~~~----

REM Enable debug output.
:SetDebug
    SET DebugEnabled=yes
    SHIFT
    GOTO :ProcessArgs

REM Set the Gawk binary.
:SetGawk
    IF "%~2"=="" GOTO :ERRORGawk
    SET GawkProgram=%2
    SHIFT
    SHIFT
    GOTO :ProcessArgs

:ERRORGawk
    ECHO Option %1 requires the Gawk program.
    GOTO :Gawk

REM Disable interactive mode.
:SetInteractive
    SET InteractiveEnabled=no
    SHIFT
    GOTO :ProcessArgs

REM Enable Lint mode.
:SetLint
    SET LintEnabled=yes
    SHIFT
    GOTO :ProcessArgs

REM Load all modules.
:SetModules
    SET ModulesEnabled=yes
    SHIFT
    GOTO :ProcessArgs

REM Print all objects.
:SetObjects
    SET ObjectsEnabled=yes
    SHIFT
    GOTO :ProcessArgs

REM Quiet mode.
:SetQuiet
    SET QuietEnabled=yes
    SHIFT
    GOTO :ProcessArgs

REM Check if the Gawk program exists.
:CheckGawk
    %GawkProgram% --version > NUL 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        ECHO Gawk is not in the current path. Aborting!
        ECHO Gawk Command: %GawkProgram%
        EXIT /B 1
    )
    EXIT /B

REM Print hopefully useful debug information.
:PrintDebug
    ECHO DEBUG: Options
    ECHO   Lint:        %LintEnabled%
    ECHO   Modules:     %ModulesEnabled%
    ECHO   Interactive: %InteractiveEnabled%
    ECHO   Quiet:       %QuietEnabled%
    ECHO Program: %GawkProgram%
    ECHO Args: %GawkArgs%
    ECHO Gawk Command:
    ECHO %GawkCmd%
    ECHO.
    EXIT /B

REM Print the message if debug is enabled.
:DebugMsg
    IF %DebugEnabled% == yes ECHO DEBUG: %*
    EXIT /B

ECHO You should not see this message.
ECHO If you do please let me know.

REM ----~~~~++++====#### Done! ####====++++~~~~----

REM Exit the script.
:ExitScript
CALL :DebugMsg Exiting...
