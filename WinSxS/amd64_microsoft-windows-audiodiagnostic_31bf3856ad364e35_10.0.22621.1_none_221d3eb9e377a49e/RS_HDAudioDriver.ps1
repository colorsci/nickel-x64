# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  RS_HDAudioDriver rollback audio device to HD audio driver based on user selection

	ARGUMENTS:
	 deviceType : String value of Audio device ID
	 $pnpdevname : Name of the device type selected

	RETURNS:
	  None
#>

PARAM($deviceID,$pnpdevname,$PNPDevID,$deviceType)
#====================================================================================
# Load Utilities
#*===================================================================================
. .\CL_Utility.ps1
#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
#==================================================================================
# Functions
#==================================================================================
 
#==================================================================================
# Main
#==================================================================================

[int]$devCount = Get-AudioEndPointsCount

$devices = Get-WmiObject Win32_SoundDevice -Filter "name= '$pnpdevname'"
foreach ($device in $devices)
{
	$pnpdevid = $device.PNPDeviceID
}

$audioDetails = Get-WmiObject -Class Win32_PnPSignedDriver | Where-Object -FilterScript {$_.DeviceID -eq $pnpdevid}

if ([system.environment]::Is64BitOperatingSystem)
{
	$ChangeAudioDriver = Get-AudioDriverSource
}
else
{
	$ChangeAudioDriver = Get-AudioDriverSource32
}
$currentDriver = $ChangeAudioDriver::GetCurrentDriverINF($pnpdevid);

try
{
	$audioTestChoice = Get-DiagInput -ID "IT_AudioHDTest" 

	if($audioTestChoice -eq "IT_PlayTest")
    {	
        # Create a text file in temp to store filenames of SymLinks
	    New-Item -path "$env:temp" -name "AudioTest.txt" -itemtype file -force 
	    $AudioTestFile = Join-Path "$env:temp" "AudioTest.txt"	
        
        # Play sound for test
		Write-DiagProgress -activity $localizationString.Playtest_progress
		PlaySound
		$int_desc_1 = $localizationString.INT_Playtest_opt1_desc
		$int_desc_2 = $localizationString.INT_Playtest_opt3_desc
		$int_desc = $localizationString.INT_Playtest_desc

		$choices = Get-DiagInput -ID "IT_AudioHD" -Parameter @{'INT_Desc' = $int_desc; 'INT_Good_Desc' = $int_desc_1; 'INT_Bad_Desc' = $int_desc_2; 'INT_Did_Desc' = $int_desc_2}
        if(($choices -eq "IT_Bad") -or ($choices -eq "IT_NotHeard"))
        {
			# ReInstalling current Audio
			$outPut = $ChangeAudioDriver::ForceInstallDriver($pnpdevid, $currentDriver);
		
		    if($output -eq "0")
		    {
			    #Checking if service is started. Else start the service forcefully
			    Start-AudioService
			    [int]$currentDevCount = Get-AudioEndPointsCount
			    if(!($devCount -eq $currentDevCount))
			    {
					Start-Sleep -s 20
			    }
			}

			Set-DefaultEndpoint $PNPDevID

			Write-DiagProgress -activity $localizationString.Playtest_progress
			# Play sound for test
			PlaySound

			$int_desc_2 = $localizationString.INT_Playtest_opt2_desc
			$int_desc = $localizationString.INT_Playtest_desc

			$choices1 = Get-DiagInput -ID "IT_AudioHD" -Parameter @{'INT_Desc' = $int_desc; 'INT_Good_Desc' = $int_desc_1; 'INT_Bad_Desc' = $int_desc_2; 'INT_Did_Desc' = $int_desc_2}
            if(($choices1 -eq "IT_Bad") -or ($choices1 -eq "IT_NotHeard"))
			{
                Stop-AudioService
			
	            # Installing HD Audio
	            $output = $ChangeAudioDriver::ForceInstallHDAudio($pnpdevid);
			
	            if($output -eq "0")
	            {
		            #Checking if service is started. Else start the service forcefully
		            Start-AudioService
		            [int]$currentDevCount = Get-AudioEndPointsCount
		            if(!($devCount -eq $currentDevCount))
		            {
			            Start-Sleep -s 20
		            }
	            }
				Set-DefaultEndpoint $PNPDevID
				 
				$resSet = Set-AudioEndpointProperty $deviceType

                Write-DiagProgress -activity $localizationString.Playtest_progress

	            # Play sound for test
	            PlaySound
                if($choices -eq "IT_Bad")
			    {  
				    $combo1 = $localizationString.IT_Choice2
			    }
			    elseif($choices -eq "IT_NotHeard")
			    {  
				    $combo1 = $localizationString.IT_Choice3
			    }
	            $int_desc_1 = $localizationString.INT_ReCheck_opt1_desc
	            $int_desc_2 = $localizationString.INT_ReCheck_opt2_desc
	            $int_desc = $localizationString.INT_ReCheck_desc
	            $reCheckChoices = Get-DiagInput -ID "IT_AudioHD" -Parameter @{'INT_Desc' = $int_desc; 'INT_Good_Desc' = $int_desc_1; 'INT_Bad_Desc' = $int_desc_2; 'INT_Did_Desc' = " "}
	            if($reCheckChoices -eq "IT_NotHeard")
	            {
	                Write-DiagProgress -activity $localizationString.Playtest_progress
	                # Play sound for test
	                PlaySound
	                $int_desc_again = $localizationString.INT_ReCheck_desc_1
		            $reCheckChoicesAgain = Get-DiagInput -ID "IT_AudioHD" -Parameter @{'INT_Desc' = $int_desc_again; 'INT_Good_Desc' = $int_desc_1; 'INT_Bad_Desc' = $int_desc_2; 'INT_Did_Desc' = $int_desc_2}
	            }
	            if(($reCheckChoices -eq "IT_Bad") -or ($reCheckChoicesAgain -eq "IT_Bad") -or ($reCheckChoicesAgain -eq "IT_NotHeard"))
	            {
		            Write-DiagProgress " "
		            $outPut = $ChangeAudioDriver::ForceInstallDriver($pnpdevid, $currentDriver);
				 
		            if(($reCheckChoices -eq "IT_Bad") -or ($reCheckChoicesAgain -eq "IT_Bad"))
		            {  
			            $combo2 = $localizationString.IT_Choice2
		            }
		            elseif($reCheckChoicesAgain -eq "IT_NotHeard")
		            {  
			            $combo2 = $localizationString.IT_Choice3
		            }
	            }
	            else
	            {
		            $combo2 = $localizationString.IT_Choice1 
	            }
                $combo1 + "/" + $combo2 >> $AudioTestFile
            }
            else
			{
				$tmpString = $localizationString.genericTestTone_verifierString_2
				$tmpString >> $AudioTestFile
			}
        }
        else
        {
            $tmpString =  $localizationString.genericTestTone_verifierString_1
			$tmpString >> $AudioTestFile
        }
	    $AudioDescpt = $pnpdevname + ":" + $pnpdevid + "," + "Version :" + $audioDetails.DriverVersion
	    $pnpdevname | ConvertTo-Xml | Update-DiagReport -Id "RS_HDAudioDriver" -Name "RS_HDAudioDriver" -Description $AudioDescpt -Verbosity Debug
    }
}
catch [System.Exception]
{
	Write-ExceptionTelemetry "MAIN" $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_HDAudioDriver" -Name "RS_HDAudioDriver" -Verbosity Debug
}