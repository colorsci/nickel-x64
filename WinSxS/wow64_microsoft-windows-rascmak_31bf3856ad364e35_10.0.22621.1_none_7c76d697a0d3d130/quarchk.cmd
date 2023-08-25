  @echo off

:CLEARVARS
  @rem ***
  @rem * Clear all used environment variables in the current users's context 
  @rem * before starting the script
  @rem *

  set RQCLOC=
  set RQC_CONNNAME=
  set RQC_SIGNATURE=
  set RQC_DOMAIN=
  set RQC_USERNAME=
  set RQC_PORT=
  set RQS_LOGMESSAGE=

:INITIALIZATION
  @rem ***
  @rem * Define the locations for the source file (remove quarantine if this file exists) and
  @rem * the target file (the file to copy if the source file does not exist).
  @rem *
  @rem Use %ServiceDir% macro to locate rqc.exe.
  SET RQCLOC=%1\rqc.exe

  @rem Use %ServiceName% macro.
  if not -%2- == -- SET RQC_CONNNAME=/conn %2
 
  @rem RQC_SIGNATURE string used to validate the client
  @rem * Default String RASQuarantineConfigPassed
  @rem *
  if not -%3- == -- (SET RQC_SIGNATURE=/sig %3) else (set RQC_SIGNATURE=/sig RASQuarantineConfigPassed)

  @rem Use %DOMAIN% macro.
  if not -%4- == -- SET RQC_DOMAIN=/domain %4

  @rem Use %USERNAME% CM macro for this value.
  if not -%5- == -- SET RQC_USERNAME=/user %5

  @rem  PORT field is optional.
  if not -%6- == -- SET RQC_PORT=/port %6

  @rem @echo 1=%1. '%RQCLOC%'
  @rem @echo 2=%2. '%RQC_CONNNAME%'
  @rem @echo 3=%3. '%RQC_SIGNATURE%'
  @rem @echo 4=%4. '%RQC_DOMAIN%'
  @rem @echo 5=%5. '%RQC_USERNAME%'
  @rem @echo 6=%6. '%RQC_PORT%'

  @rem Log message that will be sent to the server - on Pass or fail. Currently pass
  SET RQS_LOGMESSAGE=/log "Security checks are passed"

@rem VALIDATION
@rem Do all the Validations here ...
@rem 

:ICF_VALIDATION
  @rem ***
  @rem * ICF Checking
  @rem * IF %ERRORLEVEL%==0 GOTO ICS_VALIDATION
  @rem * Log message that will be sent to the server - on Failure (ICF)
  @rem * SET RQS_LOGMESSAGE=/log "ICF CHECK FAILED"
  @rem * GOTO VALIDATION_FAILED

:ICS_VALIDATION
  @rem ***
  @rem * ICS Checking
  @rem * IF %ERRORLEVEL%==0 GOTO MORE_VALIDATION
  @rem * Log message that will be sent to the server - on Failure (ICS)
  @rem * SET RQS_LOGMESSAGE=/log "ICS CHECK FAILED"
  @rem * GOTO VALIDATION_FAILED

:MORE_VALIDATION
@rem add more validations as required 
@rem ...
@rem if %ERRORLEVEL%==0 GOTO REMOVE_QUARANTINE

  @rem ***
  @rem *
  @rem * Security checks have been completed.
  @rem Remove the client from qurantine network
 
:REMOVE_QUARANTINE
  @rem ***
  @rem * The client now must be removed from quarantine.

  set CmdToExecute=%RQCLOC% %RQC_CONNNAME% %RQC_PORT% %RQC_DOMAIN% %RQC_USERNAME% %RQC_SIGNATURE% %RQS_LOGMESSAGE%
  @rem echo.
  @rem echo %CmdToExecute%
  %CmdToExecute%

  IF %ERRORLEVEL%==0 GOTO QUARANTINE_REMOVED
  IF %ERRORLEVEL%==1 GOTO QUARANTINE_INVALIDLOC
  IF %ERRORLEVEL%==2 GOTO QUARANTINE_INVALIDSTRING

  @rem Generic failure.
  echo.
  GOTO QUARANTINE_FAIL

:VALIDATION_FAILED
  @rem ***
  @rem *

  set CmdToExecute=%RQCLOC% %RQC_CONNNAME% %RQC_PORT% %RQC_DOMAIN% %RQC_USERNAME% %RQS_LOGMESSAGE%
  @rem echo.
  @rem echo %CmdToExecute%
  %CmdToExecute%

  IF %ERRORLEVEL%==1 GOTO QUARANTINE_INVALIDLOC
  IF %ERRORLEVEL%==2 GOTO QUARANTINE_INVALIDSTRING

  @rem Generic failure.
  echo.
  GOTO QUARANTINE_FAIL

:QUARANTINE_REMOVED
  @rem ***
  @rem * client has been removed from the quarantine.
  @rem * quarantine.
  echo.
  echo The client meets the current requirements for network access and has been removed from quarantine.
  goto EXIT_SCRIPT

:QUARANTINE_INVALIDSTRING
  echo.
  echo The client does not meet the current requirements for full network access. 
  goto QUARANTINE_FAIL

:QUARANTINE_INVALIDLOC
  echo.
  echo Unable to contact remote access server. 
  GOTO QUARANTINE_FAIL

:QUARANTINE_FAIL
  echo Client remains in Quarantine Network. 
  echo If the problem persists, please contact your administrator.
  PAUSE

:EXIT_SCRIPT
  @rem ***
  @rem * Exit script.
  @rem *

  @rem label :eof does not exist. This is a common way to exit script.
  goto :eof
