@ECHO OFF
setlocal enabledelayedexpansion

SET RET=0

IF "%1" == "" (
    ECHO Usage: MergeTaefEtl.cmd [EtlFolderPath] [XperfLocation]
    REM Set exit code to ERROR_BAD_COMMAND
    SET RET=22
    GOTO EXIT
)

SET XperfDirectory=%CD%
IF NOT "%2" == "" (
   SET XperfDirectory=%2
)

SET MergeDirectory=%1
SET EtlFiles=

ECHO Directory is %MergeDirectory%

IF EXIST "%MergeDirectory%\TaefUserMode.etl" (  
    ECHO TaefUserMode.etl found
    SET EtlFiles=%MergeDirectory%\TaefUserMode.etl
)

IF EXIST "%MergeDirectory%\TaefKernelMode.etl" ( 
    ECHO TaefKernelMode.etl found
    SET EtlFiles=%EtlFiles% %MergeDirectory%\TaefKernelMode.etl
)

IF DEFINED EtlFiles (
    ECHO Looking for %XperfDirectory%\xperfcore.exe
    IF EXIST "%XperfDirectory%\xperfcore.exe" (        
        ECHO Merging %EtlFiles% into %MergeDirectory%\TaefEtl_Merged.etl        
        %XperfDirectory%\xperfcore.exe -compress -merge %EtlFiles% %MergeDirectory%\TaefEtl_Merged.etl

        SET RET=!ERRORLEVEL!
        
        IF "!RET!" == "0" (
          ECHO Deleting source ETL files: %EtlFiles%
          del %EtlFiles%
        )
    ) ELSE (
        ECHO XperfCore.exe does not exist
        REM Set exit code to ERROR_MOD_NOT_FOUND
        SET RET=126
    )    
) ELSE (
    ECHO No Files to merge
    REM Don't consider this to be an error as the user may have turned off /enableEtwLogging.
    SET RET=0
)

:EXIT
ECHO Exiting with return code %RET%
exit /b %RET%