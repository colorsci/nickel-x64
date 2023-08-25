# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================
# Initialize
# =============================================================
param($errorCodes)

# =============================================================
# Functions
# =============================================================

Function Get-UpdatedPackDetails
{
	PARAM( [string]$packName, $errorType, $errorCode = '0x8007000D')
	$cemCollection = $null
	try
	{
		if($errorType -eq 'Known')
		{
			$messageUrl = "https://cem.services.microsoft.com/v2.0/products/Troubleshooter-WindowsUpdate/errors/$errorCode/message"
			$cemCollection = (Invoke-WebRequest $messageUrl -TimeoutSec 5).Content | ConvertFrom-Json | %{ $_.LongDescription}
		}
		else
		{
			$messageUrl = 'https://cem.services.microsoft.com/v2.0/products/Troubleshooter-WindowsUpdate/errors/Unknown/message'
			$cemCollection = (Invoke-WebRequest $messageUrl -TimeoutSec 5).Content | ConvertFrom-Json | %{ $_.LongDescription}
		}
	}
	catch
	{
		$cemCollection = 'Timeout Exception'   
	}  
	return $cemCollection
}

# ===============================================================
# Main
# ===============================================================
if($errorCodes -eq $null)
{
	$finalMessage = 'None'
}

$errorList = @('0x8007000D','0x800F081F','0x80073712','0x800736CC','0x800705B9','0x80070246','0x8007370D',
'0x8007370B','0x8007370A','0x800B0100','0x80092003','0x800B0101','0x8007371B','0x80070490')
foreach($item in $errorCodes.Split(';'))
{
	$item = $item.Trim()
	if(![string]::IsNullOrEmpty($item))
	{
		$cemMessage = ''
		if($errorList -contains $item)
		{
			$cemReturnValue = Get-UpdatedPackDetails 'WindowsUpdate' 'Known' $item
		}
		else
		{
			$cemReturnValue = Get-UpdatedPackDetails 'WindowsUpdate' 'Unknown' $item
		}

		if($cemReturnValue -eq 'Timeout Exception')
		{
			$cemMessage = 'FAIL'
		}
		else
		{
			if($cemReturnValue -eq $null)
			{
				$cemMessage = 'NO'
			}
			else
			{
				$cemMessage = 'YES'
			}
		}
		$finalMessage += "$cemMessage;"  
	}
}

# Adding the CEM message to Telemetry
if([System.Environment]::OSVersion.Version.Build -gt 15000)
{
	Write-DiagTelemetry -Property "WU:CEMMessage" -Value $finalMessage
}
else
{
	"WU:CEMMessage - $finalMessage" | ConvertTo-Xml | Update-Diagreport -Id RC_GENWUError -Name CEMMessage -Verbosity informational
}

if($finalMessage -ne 'None')
{
	Update-DiagRootCause -Id RC_GENWUError -InstanceId $finalMessage -Detected $true -Parameter @{"error"=$errorCodes; "instanceValue" = $finalMessage}
}
else
{
	Update-DiagRootCause -Id RC_GENWUError -InstanceId $finalMessage -Detected $false -Parameter @{"error"=$errorCodes; "instanceValue" = $finalMessage}
}

