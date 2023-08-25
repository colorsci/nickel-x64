# Copyright © 2016, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:
	RS_CalibrationRequired.ps1 adjusts microphone levels based on the users voice and environment.

	ARGUMENTS:
	CalibrationReason:	Legacy|Uncertified|Calibrate
	CalibrationConsent: True|False
	AdapterName:		The name of the device which is being calibrated
	DeviceID:			The identifier of the device which is being calibrated

	RETURNS:
	None
#>

#====================================================================================
# Initialize
#====================================================================================
PARAM($CalibrationReason, $CalibrationConsent, $AdapterName, $DeviceID)
Import-LocalizedData -BindingVariable localizedStrings -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. .\CL_Utilities.ps1

#====================================================================================
# Main
#====================================================================================

if ($CalibrationConsent -ieq 'True')
{
	Get-DiagInput -ID IT_CalibrationNotification
	
	$calibrationResult = 'MicDiagnosticSilence'
	$retryCount = 3
	while($retryCount -gt 0)
	{
		$retryCount--
		
		Write-DiagProgress -Activity ($localizedStrings.Calibration_Prompt) -Status ($localizedStrings.Calibration_Activity)

		[SpeechDiagnostic.SpeechConfigManager]::StartDiagnostic();
		try {
			while(-not [SpeechDiagnostic.SpeechConfigManager]::IsDiagnosticDone())
			{
				$level = [SpeechDiagnostic.SpeechConfigManager]::GetLevel();
				if($level)
				{
					$progressColor = 'Play';
					if($level -ge 90)
					{
						$progressColor = 'Stop' #Red
					} 
					elseif($level -ge 70)
					{
						$progressColor = 'Pause' #Yellow
					}
					else
					{
						$progressColor = 'Play' #Green
					}

					if ($level -lt 1){ $level = 1 }
					elseif ($level -gt 100){ $level = 100 }
					Write-DiagProgress -Activity ($localizedStrings.Calibration_Prompt) -Status ($localizedStrings.Calibration_Activity) -Progress ($level.ToString()) -Color $progressColor
				}

				Start-Sleep -Milliseconds 10
			}

			$calibrationResult = [SpeechDiagnostic.SpeechConfigManager]::GetResult();

			if($calibrationResult -eq 'MicDiagnosticPass')
			{
				[SpeechDiagnostic.SpeechConfigManager]::UpdateRegistry($false);
				break # No need for retries.
			}
			else
			{
				[SpeechDiagnostic.SpeechConfigManager]::UpdateRegistry($true);
				if($retryCount -gt 0)
				{
					$canRetryCalibration = Get-DiagInput -ID IT_RetryCalibration
					if($canRetryCalibration[0] -eq 'no')
					{
						break # User didn't want to retry.
					}
				}
			}
		}
		Finally
		{
			[SpeechDiagnostic.SpeechConfigManager]::StopDiagnostic();
		}
	}


	$calibrationResult > 'CalibrationResult.log';
}