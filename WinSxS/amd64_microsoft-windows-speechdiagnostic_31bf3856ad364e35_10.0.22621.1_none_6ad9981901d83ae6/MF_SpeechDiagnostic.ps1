# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:
	MF_SpeechDiagnostic.ps1 is the main entry point for the troubleshooter and defines the workflow the diagnostics.

	ARGUMENTS:
	None

	RETURNS:
	None
#>

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable localizedStrings -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utilities.ps1

#====================================================================================
# Main
#====================================================================================

if(Test-RemoteSession) 
{
	Get-DiagInput -ID 'IT_RunningOnRemoteSession'
	return
}

if(-not(Test-PostBack -CurrentScriptName MF_SpeechDiagnostic))
{
	try
	{
		# Select capture or render workflow
		$AudioWorkflow = Get-DiagInput -id IT_SelectCaptureOrRender

		if ($AudioWorkflow -eq "render")
		{
			Update-DiagRootCause -ID RC_SpeakerProblem -Detected $true -Parameter @{'SkipAudioPlaybackDiagnostic' = $false}
		}
		elseif ($AudioWorkflow -eq "capture")
		{
			# Getting audio endpoint devices
			$audioDevices = Get-AudioCapturingDevices
			
			if(([array]$audioDevices).Count -eq 0)
			{
				Update-DiagRootCause -ID RC_MicProblem -Detected $true -Parameter @{'SkipAudioRecordingDiagnostic' = $false}

			}
			elseif(([array]$audioDevices).Count -eq 1)
			{
                Diagnose-AudioSpeech -DeviceID ($audioDevices.DeviceId)
			}
			elseif(([array]$audioDevices).Count -gt 1)
			{
				# Get one device from user
				$choices = @()
				foreach ($audioDevice in $audioDevices)
				{
					$deviceName = "{0} - {1} {3}{2}.{3}{3}" -f ($audioDevice.Description), ($audioDevice.AdapterName), ($audioDevice.JackDescription), ([System.Environment]::NewLine)
					$choice = @{'Name' = ($deviceName); 'Description' = ($deviceName); 'Value' = ($audioDevice.DeviceId); 'ExtensionPoint' = ''}
			
					if(($audioDevice.IsDefault) -eq $true)
					{
						$choice.ExtensionPoint = '<Default />'
					}

					$choices += $choice
				}
				
				$deviceId = Get-DiagInput -id 'IT_SelectDevice' -Choice $choices

				$deviceId[0] > SelectedDevice.log
                
                Diagnose-AudioSpeech -DeviceID $deviceId[0] #$audioDevices                

			}
		}
	}
	Catch [System.Exception]
	{
		Write-ExceptionTelemetry 'MAIN' $_
		$_ | ConvertTo-Xml | Update-DiagReport -ID 'MF_SpeechDiagnostic' -Name 'MF_SpeechDiagnostic' -Verbosity Debug
	}
}
