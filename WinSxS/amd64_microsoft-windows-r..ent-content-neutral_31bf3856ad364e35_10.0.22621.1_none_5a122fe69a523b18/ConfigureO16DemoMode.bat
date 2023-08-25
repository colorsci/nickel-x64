@echo off
setlocal enabledelayedexpansion

rem ===========================================================================
rem 		RETAIL DEMO INSTALLATION SCRIPT FOR OFFICE16 CENTENNIAL

rem This script will install the Office16 Retail Demo licenses and the product
rem key. It will also set the Retail Demo Mode registry settings.
rem ===========================================================================

rem ===========================================================================
rem 								MAIN PROGRAM
rem ===========================================================================

rem ============================
rem Setting up the registry keys
rem ============================

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set OEMOOBE_REGPATH="HKLM\Software\Wow6432Node\Microsoft\Office\16.0\Common\OEM"
	set RETAILDEMO_REGPATH="HKLM\Software\Wow6432Node\Microsoft\Office\16.0\Common\Licensing"

	set EULA_REGPATH="HKCU\Software\Wow6432Node\Microsoft\Office\16.0\Registration\%computername%\{90160000-008C-0000-0000-0000000FF1CE}\O365HomePremRetail\EULA"
	set EULA_ACCEPT_REGPATH="HKCU\Software\Wow6432Node\Microsoft\Office\16.0\Registration"
	set TWC_OPT_IN_REGPATH="HKCU\Software\Wow6432Node\Microsoft\Office\16.0\Common"
	set UPDATE_OPT_IN_REGPATH="HKCU\Software\Wow6432Node\Microsoft\Office\16.0\Common\General"
)

if "%PROCESSOR_ARCHITECTURE%"=="x86" (
	set OEMOOBE_REGPATH="HKLM\Software\Microsoft\Office\16.0\Common\OEM"
	set RETAILDEMO_REGPATH="HKLM\Software\Microsoft\Office\16.0\Common\Licensing"

	set EULA_REGPATH="HKCU\Software\Microsoft\Office\16.0\Registration\%computername%\{90160000-008C-0000-0000-0000000FF1CE}\O365HomePremRetail\EULA"
	set EULA_ACCEPT_REGPATH="HKCU\Software\Microsoft\Office\16.0\Registration"
	set TWC_OPT_IN_REGPATH="HKCU\Software\Microsoft\Office\16.0\Common"
	set UPDATE_OPT_IN_REGPATH="HKCU\Software\Microsoft\Office\16.0\Common\General"
)

set RETAILDEMO_REGPATH2="HKLM\Software\Microsoft\Office\16.0\Common\Licensing"
set OEMOOBE_REGPATH2="HKLM\Software\Microsoft\Office\16.0\Common\OEM"

set EULA_REGPATH2="HKCU\Software\Microsoft\Office\16.0\Registration\%computername%\{90160000-008C-0000-0000-0000000FF1CE}\O365HomePremRetail\EULA"
set EULA_ACCEPT_REGPATH2="HKCU\Software\Microsoft\Office\16.0\Registration"
set TWC_OPT_IN_REGPATH2="HKCU\Software\Microsoft\Office\16.0\Common"
set UPDATE_OPT_IN_REGPATH2="HKCU\Software\Microsoft\Office\16.0\Common\General"

echo Setting Retail Demo Registry...
reg add %RETAILDEMO_REGPATH% /f
reg add %RETAILDEMO_REGPATH2% /f
echo.

reg add %RETAILDEMO_REGPATH% /f /v "RetailDemo" /t REG_DWORD /d 1
reg add %RETAILDEMO_REGPATH2% /f /v "RetailDemo" /t REG_DWORD /d 1

echo Accepting EULA...
reg add %EULA_REGPATH% /f /v "18" /t REG_SZ /d "1"
reg add %EULA_REGPATH2% /f /v "18" /t REG_SZ /d "1"
echo.

echo Accept ALL EULAS...
reg add %EULA_ACCEPT_REGPATH% /f /v AcceptAllEulas /t REG_DWORD /d 1
reg add %EULA_ACCEPT_REGPATH2% /f /v AcceptAllEulas /t REG_DWORD /d 1
echo.

echo Turning off Trust Center Opt In...
reg add %TWC_OPT_IN_REGPATH% /f /v OptEnable /t REG_DWORD /d 0
reg add %TWC_OPT_IN_REGPATH2% /f /v OptEnable /t REG_DWORD /d 0
echo.

echo Turn off Update Opt In...
reg add %UPDATE_OPT_IN_REGPATH% /f /v OptInDisable /t REG_DWORD /d 1
reg add %UPDATE_OPT_IN_REGPATH2% /f /v OptInDisable /t REG_DWORD /d 1
echo.

echo Turn off OOBE...
reg delete %OEMOOBE_REGPATH% /f
reg delete %OEMOOBE_REGPATH2% /f
echo.

rem ====================
rem Getting the User SID
rem ====================

echo Getting the currently logged user's SID...

for /F "usebackq tokens=2 delims=," %%G in (`whoami /user /fo csv /nh`) do (
	set UserSID=%%G
)

rem Remove quotes from variable. This is needed later for icacls.
set UserSID=%UserSID:"=%

echo %UserSID%
echo.

rem =========================================
rem Taking ownership of WindowsApps directory
rem =========================================

set WindowsAppsDirPath="C:\Program Files\WindowsApps"
set WindowsAppsDirACLFile="%TEMP%\WindowsAppsACL.txt"

echo Saving permissions of WindowsApps directory...
call:SAVE_OWNERSHIP %WindowsAppsDirPath%,%WindowsAppsDirACLFile%

echo Taking ownership of the WindowsApps directory...
call:TAKE_OWNERSHIP %WindowsAppsDirPath%,%UserSID%,"false"

echo.

rem ===========================================================
rem Taking ownership of the Centennial Office package directory
rem ===========================================================

rem Find the Centennial Office package directory
echo Finding the Centennial Office package directory...

for /f "usebackq delims=" %%G in (`dir /b /s "C:\Program Files\WindowsApps\Microsoft.Office.Desktop_*_x86__8wekyb3d8bbwe"`) do (
	set CentennialDirPath="%%G"
)

echo %CentennialDirPath%
echo.

rem Save the permissions and take ownership of the Centennial Office package directory
set CentennialDirACLFile="%TEMP%\CentennialDirACL.txt"

echo Saving permissions of Centennial Office package directory...
call:SAVE_OWNERSHIP %CentennialDirPath%,%CentennialDirACLFile%

echo Taking ownership of the Centennial Office package directory...
call:TAKE_OWNERSHIP %CentennialDirPath%,%UserSID%,"false"

echo.

rem Save the permissions and take ownership of the Centennial Office Licenses directory
set CentennialLicensesDirPath="%CentennialDirPath:"=%\Licenses16"
set CentennialLicensesDirACLFile="%TEMP%\CentennialLicensesDirACL.txt"

echo Saving permissions of Centennial Office Licenses directory recursively...
call:SAVE_OWNERSHIP %CentennialLicensesDirPath%,%CentennialLicensesDirACLFile%

echo Taking ownership of the Centennial Office Licenses directory recursively...
call:TAKE_OWNERSHIP %CentennialLicensesDirPath%,%UserSID%,"true"

echo.

rem ========================================
rem Install the licenses and the product key
rem ========================================

set SLMgrPath="C:\Windows\System32\slmgr.vbs"

pushd %CentennialLicensesDirPath%

echo Installing license files...
echo Installing "pkeyconfig-office.xrm-ms" ...
cscript %SLMgrPath% /ilc ".\pkeyconfig-office.xrm-ms"

for /f "usebackq delims=" %%G in (`dir /b ".\client-issuance*xrm-ms"`) do (
	echo Installing "%%G" ...
	cscript %SLMgrPath% /ilc ".\%%G"
)

for /f "usebackq delims=" %%G in (`dir /b ".\o365homepremdemor_bypasstrial365*xrm-ms"`) do (
	echo Installing "%%G" ...
	cscript %SLMgrPath% /ilc ".\%%G"
)

popd

echo Installing product key...
cscript %SLMgrPath% /ipk "NG3HB-Y326P-PHCH3-9F96F-KBVH9"

rem ============================================================================
rem Restore permissions and ownership of the Centennial Office package directory
rem ============================================================================

rem Restore permissions and ownership of the Centennial Office Licenses directory
echo Restoring permissions and ownership of the Centennial Office Licenses directory recursively...
call:RESTORE_OWNERSHIP %CentennialLicensesDirPath%,%CentennialLicensesDirACLFile%,"true"
echo.

rem Restore permissions and ownership of the Centennial Office package directory
echo Restoring permissions and ownership of the Centennial Office package directory...
call:RESTORE_OWNERSHIP %CentennialDirPath%,%CentennialDirACLFile%,"false"
echo.

rem ==============================================================
rem Restore permissions and ownership of the WindowsApps directory
rem ==============================================================

echo Restoring permissions and ownership of the WindowsApps directory...
call:RESTORE_OWNERSHIP %WindowsAppsDirPath%,%WindowsAppsDirACLFile%,"false"
echo.

rem =====================
rem Delete leftover files
rem =====================

echo Deleting leftover ACL files...
del /f /q %CentennialLicensesDirACLFile%
del /f /q %CentennialDirACLFile%
del /f /q %WindowsAppsDirACLFile%

goto:EOF

rem ===========================================================================
rem 								FUNCTIONS
rem ===========================================================================

rem ===========================
rem Prompt to continue function
rem ===========================

:SAVE_OWNERSHIP
rem %1 Directory or file path
rem %2 ACL file path

echo icacls "%~1" /save "%~2" /q
icacls "%~1" /save "%~2" /q
echo Saved to "%~2"
echo.

goto:EOF
rem ---------------------------------------------------------------------------

:TAKE_OWNERSHIP
rem %1 Directory or file path
rem %2 User SID
rem %3 Do it recursively?

rem Do not quote the SID
if /I "%~3"=="true" (
	takeown /f "%~1" /r /d y > nul
	icacls "%~1" /grant *%~2:F /t /q
	icacls "%~1" /grant administrators:F /t /q
) else (
	takeown /f "%~1"
	icacls "%~1" /grant *%~2:F /q
	icacls "%~1" /grant administrators:F /q
)

goto:EOF
rem ---------------------------------------------------------------------------

:RESTORE_OWNERSHIP
rem %1 Directory or file path
rem %2 ACL file path
rem %3 Do it recursively?

if /I "%~3"=="true" (
	echo icacls "%~1" /setowner "SYSTEM" /t /q
	icacls "%~1" /setowner "SYSTEM" /t /q
) else (
	echo icacls "%~1" /setowner "SYSTEM" /q
	icacls "%~1" /setowner "SYSTEM" /q
)

rem icacls /restore requires the parent directory
echo icacls "%~1\.." /restore %2 /q
icacls "%~1\.." /restore %2 /q

goto:EOF
rem ---------------------------------------------------------------------------

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Retail Demo Installation script for O16
::  Will install O16 retail demo key and set retail demo mode registry setting
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set EULA_REGPATH="HKCU\Software\Microsoft\Office\16.0\Registration\%computername%\{90160000-000F-0000-0000-0000000FF1CE}\O365HomePremRetail\EULA"
set EULA_ACCEPT_REGPATH="HKCU\Software\Microsoft\Office\16.0\Registration"
set TWC_OPT_IN_REGPATH="HKCU\Software\Microsoft\Office\16.0\Common"
set UPDATE_OPT_IN_REGPATH="HKCU\Software\Microsoft\Office\16.0\Common\General"
set OEMOOBE_REGPATH="HKLM\Software\Microsoft\Office\16.0\Common\OEM"
set RETAILDEMO_REGPATH="HKLM\Software\Microsoft\Office\16.0\Common\Licensing"
set OFFICE16_FOLDER="C:\Program Files\Microsoft Office\Office16\"
set OFFICE16_FOLDER_X86="C:\Program Files (x86)\Microsoft Office\Office16\"

if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    if exist %OFFICE16_FOLDER_X86% (
        set OFFICE16_FOLDER=%OFFICE16_FOLDER_X86%
        set OEMOOBE_REGPATH="HKLM\Software\Wow6432Node\Microsoft\Office\16.0\Common\OEM"
        set RETAILDEMO_REGPATH="HKLM\Software\Wow6432Node\Microsoft\Office\16.0\Common\Licensing"
    )
)

:: If the Office 16 directory doesn't exist, then return error 1168 (ERROR_NOT_FOUND) immediately,
:: as there's no need to run the rest of this script.
if not exist %OFFICE16_FOLDER% exit 1168

set OFFICE_KEY=NG3HB-Y326P-PHCH3-9F96F-KBVH9

echo Setting Retail Demo Registry
reg add %RETAILDEMO_REGPATH% /f
reg add %RETAILDEMO_REGPATH% /f /v "RetailDemo" /t REG_DWORD /d 1

echo Accepting EULA
reg add %EULA_REGPATH% /f /v "1" /t REG_SZ /d "1"

echo Accept ALL EULAS
reg add %EULA_ACCEPT_REGPATH% /f /v AcceptAllEulas /t REG_DWORD /d 1

echo Turn off Trust Center Opt In
reg add %TWC_OPT_IN_REGPATH% /f /v OptEnable /t REG_DWORD /d 0

echo Turn off Update Opt In
reg add %UPDATE_OPT_IN_REGPATH% /f /v OptInDisable /t REG_DWORD /d 1

echo Turn off OOBE
reg delete %OEMOOBE_REGPATH% /f

:: Clear %ERRORLEVEL% so it falls back on ERRORLEVEL, then run cscript and make sure we propagate its exit code.
:: (For more explanation, see http://blogs.msdn.com/b/oldnewthing/archive/2008/09/26/8965755.aspx.)
set ERRORLEVEL=
cd /d %OFFICE16_FOLDER%
cscript ospp.vbs /inpkey:%OFFICE_KEY%

echo DONE
exit %ERRORLEVEL%