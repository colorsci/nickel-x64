# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Initialize
# =============================================================
param($errorCodes, $instanceValue)
Import-LocalizedData -BindingVariable RS_GenWUError_LocalizedStrings -FileName CL_LocalizationData 

$wuErrorReportFile = 'WUErrorReportFile.txt'
$components =@( 'atl.dll','urlmon.dll','mshtml.dll','shdocvw.dll','browseui.dll','jscript.dll','vbscript.dll','scrrun.dll','msxml.dll','msxml3.dll','msxml6.dll','actxprxy.dll','softpub.dll','wintrust.dll','dssenh.dll','rsaenh.dll','gpkcsp.dll','sccbase.dll','slbcsp.dll','cryptdlg.dll','oleaut32.dll','ole32.dll','shell32.dll','initpki.dll','wuapi.dll','wuaueng.dll','wuaueng1.dll','wucltui.dll','wups.dll','wups2.dll','wuweb.dll','qmgr.dll','qmgrprxy.dll','wucltux.dll','muweb.dll','wuwebv.dll')
[int]$winVista=60

# ============================================================
# Load Utilities
# ============================================================
. .\CL_Utility.ps1
. .\CL_Service.ps1

#====================================================================================
# Functions
#====================================================================================
# resets the CryptService
function Reset-WUSpecificServices()
{
	Write-DiagProgress -activity (($RS_GenWUError_LocalizedStrings.ID_STATUS_STOP_SERVICE).Replace("%servicename%","CryptSvc"))
	#stop service CryptSvc
	&{
		$stopService = Test-ServiceState "CryptSvc" "Stopped"
		# debug information
		if($stopService)
		{
			"RS_GenWUError : CryptSvc is stopped" >> $wuErrorReportFile
		}
		else
		{
			"RS_GenWUError : CryptSvc is not stopped" >> $wuErrorReportFile
		}
	}trap [Exception]{
			[string]$messageString = ($DC_Strings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%","CryptSvc")
			$messageString | ConvertTo-Xml | Update-Diagreport -Id "RC_GenWUError" -Name "$messageString" -Verbosity informational
	}
	Write-DiagProgress -Activity (($RS_GenWUError_LocalizedStrings.ID_CLEAR_SERVICE).Replace("%servicename%","Bits"))

    # Apply this to only TH1 & TH2
    if([System.Environment]::OSVersion.Version.Build -lt 14393)
    {
        sc.exe sdset bits "D:(A;CI;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;IU)(A;;CCLCSWLOCRRC;;;SU)S:(AU;SAFA;WDWO;;;BA)"
    }

	Write-DiagProgress -Activity (($RS_GenWUError_LocalizedStrings.ID_STATUS_START_SERVICE).Replace("%servicename%","CryptSvc"))

	#startServices "CryptSvc"
	&{
		Fix-ServiceWithDebugFile "CryptSvc" ($wuErrorReportFile) "RS_GenWUError : "
	 } trap [Exception]{
		[string]$messageString = ($DC_Strings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%","CryptSvc")
		$messageString | ConvertTo-Xml | Update-Diagreport -Id "RC_GenWUError" -Name "$messageString" -Verbosity informational
	}
}

#================================================================================
# Main
#================================================================================

Write-DiagProgress -activity (($RS_GenWUError_LocalizedStrings.ID_STATUS_STOP_SERVICE).Replace("%servicename%","Bits"))

$winVersion = Check-WindowsVersion
$stopService = Test-ServiceState "bits" "Stopped"

if($stopService)
{
	"RS_GenWUError : Bits is stopped" >> $wuErrorReportFile
}
else
{
	"RS_GenWUError : Bits is not stopped" >> $wuErrorReportFile
}
if(Test-Path "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat")
{
	Remove-Item  "$env:ALLUSERSPROFILE\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -Force  -ErrorAction SilentlyContinue
}

Reset-WUSpecificServices

foreach($component in $components )
{
	regsvr32 "$($env:windir)\System32\$component" /s
}

netsh winhttp reset proxy

Write-DiagProgress -activity (($RS_GenWUError_LocalizedStrings.ID_STATUS_START_SERVICE).Replace("%servicename%","Bits")) 
	
&{
	Fix-ServiceWithDebugFile  "bits" ($wuErrorReportFile) "RS_GenWUError : "
} trap [Exception]{
	[string]$messageString = ($DC_Strings.ID_ERROR_MSG_SERVICE).replace("%ServiceName%","bits")
	$messageString | ConvertTo-Xml | Update-Diagreport -Id "RC_GenWUError" -Name "$messageString" -Verbosity informational
}
