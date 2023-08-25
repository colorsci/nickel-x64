# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Initialize
# =============================================================
param($oldTimestamp)
Import-LocalizedData -BindingVariable RS_DataSore_LocalizedStrings -FileName CL_LocalizationData
$wuLogSourceFile = 'WUDiagTempFolder\DataStoreCollectedFiles'
New-Item -Path $wuLogSourceFile -ItemType directory -ErrorAction SilentlyContinue
$wuLogDestnFile = 'WUDiagTempFolder\DataStoreAndWULogFiles.zip'
$wuReport = 'WUDiagTempFolder\outputreport.txt'

# ============================================================
# Load Utilities
# ============================================================
. .\CL_SetupEnv.ps1
. .\CL_Service.ps1
. .\CL_Utility.ps1

# ============================================================
# Functions
# ============================================================

function DeleteBakFolder()
{
	$bak = "softwaredistribution.bak"
	if(test-path (join-path $env:windir "$bak")){
        del (join-path $env:windir "$bak*")  -force -Recurse
	}
}


function AddEDBBacK()
{
    sleep 2
	$BakPath = join-path $env:windir "\$global:SDFbak\DataStore\DataStore.edb"
	$SDFPath = join-path "$env:windir" "SoftwareDistribution\DataStore" 	
	
	if(!(test-path $BakPath))
	{
		return
	}

	$timeout = [Timespan]"0:0:15"
	$start = Get-Date
	do{
			if(Test-path $SDFPath)
			{
				Test-ServiceState wuauserv "stopped"
				Copy-Item $BakPath $SDFPath -force
				
				break;
			}
			sleep 1
	}while (((Get-Date) - $start) -le $timeout)
	if(!(Test-path $SDFPath))
	{
		 Test-ServiceState wuauserv "stopped"
		 $d = new-item $SDFPath -type directory -force
		 Copy-Item $BakPath $SDFPath -force
	}
}


function Renamesoftwaredistribution()
{
	[int]$i=1
	trap [Exception] {
		[string]$str=$Error[0]
		$str | convertto-xml | Update-DiagReport -Id "RS_DataStore" -Name "Error$i" -Verbosity informational
		
		#$str+$i
		Continue
	}

	[int]$j=1
	$folder = join-path "$env:systemroot" "softwaredistribution" 	

 	$bak = "softwaredistribution.bak"
	if(!(test-path (join-path $env:systemroot "$bak"))){
              
	}else{
	while((test-path (join-path $env:systemroot ("$bak"+$j))))
	{
			$j=$j+1
			#$j
	}
	$bak += $j
	}
	
	$global:SDFbak = $bak
	ren $folder $bak -Force  -ErrorAction Stop	

	SetDiagProgress "id_name_rc_datastoreprogress"
	return $true
}

#Collect and copy files to zip folder
Function Backup-EDBFile()
{
	SetDiagProgress "ID_CollectFileProgressActivity"
	
	$datastorefile = "$env:Windir\softwaredistribution\datastore\datastore.edb"
	$dismlog = "$env:windir\logs\DISM\dism.log"

	Copy-Item $datastorefile $wuLogSourceFile -Recurse -Force -ErrorAction SilentlyContinue
	Copy-Item $dismlog $wuLogSourceFile -Recurse -Force -ErrorAction SilentlyContinue

	if((Check-WindowsVersion) -eq 61)
	{
		Create-ZipFromDirectory -Source $wuLogSourceFile -ZipFileName $wuLogDestnFile -Force 
		$size = Get-SizeFormat(dir $wuLogDestnFile | Select-Object -ExpandProperty Length)
        Update-DiagReport -File $wuLogDestnFile -Id "RS_DataStore" `
        -Name ([System.IO.Path]::GetFileName($wuLogDestnFile)) `
        -Description $size `
        -Verbosity Informational
	}
	else
	{ 
		Arm-Zip ($wuLogSourceFile) ($wuLogDestnFile)
		Remove-Item -Path $wuLogSourceFile -Recurse -Force -ErrorAction SilentlyContinue
	
		$size = Get-SizeFormat(dir $wuLogDestnFile | Select-Object -ExpandProperty Length)
		Update-DiagReport -Id "RS_DataStore" -File $wuLogDestnFile -Name "DataStoreAndWULogFiles.zip" -Description ($size) -Verbosity Informational
	}
}

# ============================================================
# Main
# ============================================================
try
{
	if((Check-WindowsVersion) -eq 61)
	{
		$logsFolderName = "DataStoreAndWULogFiles"
		$ResultRootDirectory = $env:TEMP
		$wuLogDestnFile = "DataStoreAndWULogFiles.zip"
		
		$wuLogSourceFile = [System.IO.Path]::Combine($ResultRootDirectory, $logsFolderName)
		New-Item -ItemType Directory -Path $wuLogSourceFile -Force | Out-Null
	}

	#Stop wuauserv service
    Test-ServiceState wuauserv "stopped"

	#Stop dosvc service which is present only in Windows 10
	if((Check-WindowsVersion) -ge 100)
	{	
		Test-ServiceState dosvc "stopped"
	}
	#Taking backup of EDB file after a second timespan
	Sleep 1
	Backup-EDBFile

	Renamesoftwaredistribution

	#Delete the registry entries
	$regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Jobs"
	If(Test-Path -Path $regKey)
    {
        Remove-Item -Path $regKey -Recurse -Force
    }

	# Adding EDB File Back
	AddEDBBack
	DeleteBakFolder

	&{
		Fix-ServiceWithDebugFile  "wuauserv" ($wuReport) "RS_DataStore : "
	} trap [Exception]{
		[string]$errorString = GetDiagString "ID_Error_MSG_Service"
		$errorString.Replace("%ServiceName%","wuauserv") | ConvertTo-Xml | Update-Diagreport -Id "RS_DataStore" -Name "$errorString" -Verbosity informational
	}

	#Start wuauserv service
    Test-ServiceState wuauserv "Running"

	#Start dosvc service which is present only in Windows 10
	if((Check-WindowsVersion) -ge 100)
	{	
		Test-ServiceState dosvc "Running"
	}

	$true > $verifierLogFileName
}
catch
{
    $false > $verifierLogFileName
}
