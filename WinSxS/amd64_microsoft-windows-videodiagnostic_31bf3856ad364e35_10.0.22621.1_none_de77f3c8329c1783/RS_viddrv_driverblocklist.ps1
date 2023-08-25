# Copyright © 2018, Microsoft Corporation. All rights reserved.

#*=================================================================================
# Parameters
#*=================================================================================
PARAM ($DName, $Dversion)

#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1

#*=================================================================================
# Initialize 
#*=================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#*=================================================================================
# Run resolver logic
#*=================================================================================

Write-DiagProgress -Activity $Strings_Main.ID_Fix_Driver_Blocklist

# Registry path definitions
$useHkcr = $false

# import module
$runPath = Split-Path $MyInvocation.MyCommand.Path
if (-not $runPath)
{
    $runPath = '.'
}
import-module $runPath\GraphicsDriverRegTool-Definitions.psm1

# init
$HeciArray = @()
$HeciArrayWow = @()
$HeciArrayWowClassPath = @()
$HdcpArray = @()
$HdcpArrayWow = @()
$HdcpArrayWowClassPath = @()

# HECI Svc
if ($useHkcr)
{
    $HeciArray += $heciHkcrAppIdPath = "HKCR:\AppID\$global:intelCpHeciSvcAppId"
    #   No HKCR CLSID path on update.  Ever?  See HKCR\IntelCpHeciSvc.CphsSession\CLSID and HKCR\IntelCpHeciSvc.CphsSession.1\CLSID
    #    Correct:  Intel native caller reads and uses WOW CLSID registration
    $HeciArray += $heciHkcrClsidPath = "HKCR:\CLSID\$global:intelCphsSessionClsid"
    $HeciArray += $heciHkcrTypeLibPath = "HKCR:\TypeLib\$global:intelCpHeciSvcTypeLibId"
    $HeciArray += $heciHkcrWowAppIdPath = "HKCR:\WOW6432Node\AppID\$global:intelCpHeciSvcAppId"
    $HeciArray += $heciHkcrWowClsidPath = "HKCR:\WOW6432Node\CLSID\$global:intelCphsSessionClsid"        # (Default)
    $HeciArray += $heciHkcrWowTypeLibPath = "HKCR:\WOW6432Node\TypeLib\$global:intelCpHeciSvcTypeLibId"
}

#   No HKLM CLSID path on update.  See note above
$HeciArray += $heciHklmClassesAppIdNamePath = "HKLM:\SOFTWARE\Classes\AppID\$global:intelCpHeciSvcBinaryName"
$HeciArray += $heciHklmClassesAppIdPath = "HKLM:\SOFTWARE\Classes\AppID\$global:intelCpHeciSvcAppId"
$HeciArray += $heciHklmClassesClsidPath = "HKLM:\SOFTWARE\Classes\CLSID\$global:intelCphsSessionClsid"
$HeciArray += $heciHklmClassesInterfacePath = "HKLM:\SOFTWARE\Classes\Interface\$global:intelCphsSessionInterfaceId"
$HeciArray += $heciHklmClassesTypeLibPath = "HKLM:\SOFTWARE\Classes\TypeLib\$global:intelCpHeciSvcTypeLibId"
$HeciArrayWow += $heciHklmClassesWowAppIdNamePath = "HKLM:\SOFTWARE\Classes\WOW6432Node\AppID\$global:intelCpHeciSvcBinaryName"
$HeciArrayWow += $heciHklmClassesWowAppIdPath = "HKLM:\SOFTWARE\Classes\WOW6432Node\AppID\$global:intelCpHeciSvcAppId"
$HeciArrayWow += $heciHklmClassesWowClsidPath = "HKLM:\SOFTWARE\Classes\WOW6432Node\CLSID\$global:intelCphsSessionClsid"          # (Default)
$HeciArrayWow += $heciHklmClassesWowInterfacePath = "HKLM:\SOFTWARE\Classes\WOW6432Node\Interface\$global:intelCphsSessionInterfaceId"
$HeciArrayWow += $heciHklmClassesWowTypeLibPath = "HKLM:\SOFTWARE\Classes\WOW6432Node\TypeLib\$global:intelCpHeciSvcTypeLibId"

# HKLM:\SOFTWARE\WOW6432Node provides an alternate view of HKLM:\SOFTWARE for 32-bit apps on 64-bit OS
# HKLM:\SOFTWARE\WOW6432Node\Classes is an alias of HKLM:\SOFTWARE\Classes\WOW6432Node
$HeciArrayWowClassPath += $heciHklmWowAppIdNamePath = "HKLM:\SOFTWARE\WOW6432Node\Classes\AppID\$global:intelCpHeciSvcBinaryName"
$HeciArrayWowClassPath += $heciHklmWowAppIdPath = "HKLM:\SOFTWARE\WOW6432Node\Classes\AppID\$global:intelCpHeciSvcAppId"
$HeciArrayWowClassPath += $heciHklmWowClsidPath = "HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\$global:intelCphsSessionClsid"
$HeciArrayWowClassPath += $heciHklmWowInterfacePath = "HKLM:\SOFTWARE\WOW6432Node\Classes\Interface\$global:intelCphsSessionInterfaceId"
$HeciArrayWowClassPath += $heciHklmWowTypeLibPath = "HKLM:\SOFTWARE\WOW6432Node\Classes\TypeLib\$global:intelCpHeciSvcTypeLibId"

$heciHklmControlSet001CphsPath = "HKLM:\SYSTEM\ControlSet001\Services\cphs"

# HDCP Svc
if ($useHkcr)
{
    $HdcpArray += $hdcpHkcrAppIdPath = "HKCR:\AppID\$global:intelCpHdcpSvcAppId"
    $HdcpArray +=$hdcpHkcrClsidPath = "HKCR:\CLSID\$global:intelCLSPCONSvcCOMChannelClsid"       # (Default) and ServerExecutable
    $HdcpArray +=$hdcpHkcrTypeLibPath = "HKCR:\TypeLib\$global:intelCpLSPConSvcTypeLibId"
    # No HKCR WOW CLSID path.  Appears to be by design
    $HdcpArray +=$hdcpHkcrWowAppIdPath = "HKCR:\WOW6432Node\AppID\$global:intelCpHdcpSvcAppId"
    $HdcpArray +=$hdcpHkcrWowClsidPath = "HKCR:\WOW6432Node\CLSID\$global:intelCLSPCONSvcCOMChannelClsid"
    $HdcpArray +=$hdcpHkcrWowTypeLibPath = "HKCR:\WOW6432Node\TypeLib\$global:intelCpLSPConSvcTypeLibId"
}

$HdcpArray += $hdcpHklmClassesAppIdNamePath = "HKLM:\SOFTWARE\Classes\AppID\$global:intelCpHdcpSvcBinaryName"
$HdcpArray += $hdcpHklmClassesAppIdPath = "HKLM:\SOFTWARE\Classes\AppID\$global:intelCpHdcpSvcAppId"
$HdcpArray += $hdcpHklmClassesClsidPath = "HKLM:\SOFTWARE\Classes\CLSID\$global:intelCLSPCONSvcCOMChannelClsid"       # (Default) and ServerExecutable
$HdcpArray += $hdcpHklmClassesInterfacePath = "HKLM:\SOFTWARE\Classes\Interface\$global:intelLSPCONSvcCOMChannelInterfaceId"
$HdcpArray += $hdcpHklmClassesTypeLibPath = "HKLM:\SOFTWARE\Classes\TypeLib\$global:intelCpLSPConSvcTypeLibId"
# No HKLM Classes WOW CLSID path.  Appears to be by design
$HdcpArrayWow += $hdcpHklmClassesWowAppIdNamePath = "HKLM:\SOFTWARE\Classes\WOW6432Node\AppID\$global:intelCpHdcpSvcBinaryName"
$HdcpArrayWow += $hdcpHklmClassesWowAppIdPath = "HKLM:\SOFTWARE\Classes\WOW6432Node\AppID\$global:intelCpHdcpSvcAppId"
$HdcpArrayWow += $hdcpHklmClassesWowClsidPath = "HKLM:\SOFTWARE\Classes\WOW6432Node\CLSID\$global:intelCLSPCONSvcCOMChannelClsid"
$HdcpArrayWow += $hdcpHklmClassesWowInterfacePath = "HKLM:\SOFTWARE\Classes\WOW6432Node\Interface\$global:intelLSPCONSvcCOMChannelInterfaceId"
$HdcpArrayWow += $hdcpHklmClassesWowTypeLibPath = "HKLM:\SOFTWARE\Classes\WOW6432Node\TypeLib\$global:intelCpLSPConSvcTypeLibId"

# No HKLM WOW CSLID path. 
# HKLM:\SOFTWARE\WOW6432Node provides an alternate view of HKLM:\SOFTWARE for 32-bit apps on 64-bit OS
# HKLM:\SOFTWARE\WOW6432Node\Classes is an alias of HKLM:\SOFTWARE\Classes\WOW6432Node
$HdcpArrayWowClassPath += $hdcpHklmWowAppIdNamePath = "HKLM:\SOFTWARE\WOW6432Node\Classes\AppID\$global:intelCpHdcpSvcBinaryName"
$HdcpArrayWowClassPath += $hdcpHklmWowAppIdPath = "HKLM:\SOFTWARE\WOW6432Node\Classes\AppID\$global:intelCpHdcpSvcAppId"
$HdcpArrayWowClassPath += $hdcpHklmWowClsidPath = "HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID\$global:intelCLSPCONSvcCOMChannelClsid"
$HdcpArrayWowClassPath += $hdcpHklmWowInterfacePath = "HKLM:\SOFTWARE\WOW6432Node\Classes\Interface\$global:intelLSPCONSvcCOMChannelInterfaceId"
$HdcpArrayWowClassPath += $hdcpHklmWowTypeLibPath = "HKLM:\SOFTWARE\WOW6432Node\Classes\TypeLib\$global:intelCpLSPConSvcTypeLibId"

$hdcpHklmControlSet001LspconPath = "HKLM:\SYSTEM\ControlSet001\Services\cplspcon"

$success = $true

# stop HECI and HDCP service
NET STOP cphs
$status = (Get-Service -Name cphs).Status
if ($status -ne 'Stopped')
{
    $success = $false
}

NET STOP cplspcon
$status = (Get-Service -Name cplspcon).Status
if ($status -ne 'Stopped')
{
    $success = $false
}

if ($success -eq $true)
{
	# delete time
	$delCmd = 'Remove-Item $delPath'
	$delCmdArgs = ' -Recurse -WhatIf'

	# To use inline
	$delCmdFull = $delCmd + $delPath + $delCmdArgs

	foreach ($elem in $HeciArray)
	{
		$delPath = $elem
		echo "$delCmdFull"
		Invoke-Expression $delCmdFull
	}

	foreach ($elem in $HdcpArray)
	{
		$delPath = $elem
		echo "$delCmdFull"
		Invoke-Expression $delCmdFull
	}
}

# start HECI and HDCP service
NET START cphs
$status = (Get-Service -Name cphs).Status
if ($status -ne 'Running')
{
    $success = $false
}

NET START cplspcon
$status = (Get-Service -Name cplspcon).Status
if ($status -ne 'Running')
{
    $success = $false
}

if ($success -eq $false)
{
	# the resolver runs silently unless there is an error
	Update-DiagReport -id "RS_viddrv_driverblocklist"  -verbosity Error -rid "RS_viddrv_driverblocklist"

	# do nothing here for the end user, the Verifier will report it
}

