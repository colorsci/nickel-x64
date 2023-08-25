# Copyright © 2018, Microsoft Corporation. All rights reserved.

#*=================================================================================
# Parameters
#*=================================================================================

#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1


#*=================================================================================
# Initialize 
#*=================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#*=================================================================================
# Run detection logic
#*=================================================================================

Write-DiagProgress -Activity $Strings_Main.ID_Check_DisplayTopology

$isLowRes = $false
$string = ""
$stDisplayTopologyMapXML = New-Object System.Collections.ArrayList

$stDisplayTopologyMap = [VideoDiagnostic.VideoConfigManager]::IsDiagnosticDone()

if($stDisplayTopologyMap.hr -ne 0 )
{
	update-diagrootcause -id "RC_genericfailure" -detected $true -Parameter @{"HRESULT"= $stDisplayTopologyMap.hr}
}
else
{
	# create a string to display to the user
	For ($i = 0; $i -lt $stDisplayTopologyMap.uiNumAdapters; $i++){
		$string += "Adapter:" + $i + " Device ID " +  $($stDisplayTopologyMap.rgAdapterInfo[$i].uiDeviceId) + " `n"

		#convert char array to string to remove the null operator
		$strDescription = New-Object System.String($stDisplayTopologyMap.rgAdapterInfo[$i].chDescription,0,$stDisplayTopologyMap.rgAdapterInfo[$i].chDescription.Length)
		$string +=  " Adapter Name: " + $strDescription.Trim([char]0) + " `n"
		$numMonitors = $stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[0].uiNumMonitorsAttached
		$string += " Monitors Attached " +  $($numMonitors) + " `n"

		$stDisplayTopologyMapXML.Add((New-Object PSObject -Property @{
			'Adapter'= $i
			'Device ID'= $stDisplayTopologyMap.rgAdapterInfo[$i].uiDeviceId
			'Adapter Name'= $strDescription.Trim([char]0)
			'Monitors Attached' = $numMonitors
			}))

		For ($j = 0; $j -lt $stDisplayTopologyMap.rgAdapterInfo[$i].uiNumOutputs; $j++){
			$string += "Output:" + $j + " `n"
			$object = New-Object –TypeName PSObject
			$object | Add-Member –MemberType NoteProperty –Name "Output" –Value $j
			$string +=  " Primary " +  $($stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiIsPrimary) + " `n"
			$object | Add-Member –MemberType NoteProperty –Name "Primary" –Value $stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiIsPrimary

			For ($k = 0; $k -lt $stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiNumMonitorsAttached; $k++){
				$strConnectorType = New-Object System.String($stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].rgMonitorInfo[$k].chConnectorType,
																0,
																$stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].rgMonitorInfo[$k].chConnectorType.Length)
				$string +=  " Connector Type " +  $strConnectorType.Trim([char]0) + " `n"
				$object | Add-Member –MemberType NoteProperty –Name "Connector Type" –Value $strConnectorType.Trim([char]0)
			}
		
			$string +=  " ResolutionX " +  $($stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiResolutionX) + " `n"
			$object | Add-Member –MemberType NoteProperty –Name "ResolutionX" –Value $stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiResolutionX
			if ($stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiResolutionX -lt 1280)
			{
				$isLowRes = $true
			}
			$string +=  " ResolutionY " +  $($stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiResolutionY) + " `n"
			$object | Add-Member –MemberType NoteProperty –Name "ResolutionY" –Value $stDisplayTopologyMap.rgAdapterInfo[$i].rgOutputInfo[$j].uiResolutionY
			$stDisplayTopologyMapXML.Add($object)
		}
	}

	# send to detailed information page
	$stDisplayTopologyMapXML | convertto-xml | update-diagreport -id "Display Topology" -name "Display Topology" -verbosity informational

	if ($isLowRes -eq $true)
	{
		update-diagrootcause -id "RC_LowResolution" -detected $true -Parameter @{'DisplayInfo' = $string}
	}
}
