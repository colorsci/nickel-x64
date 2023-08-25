# Copyright © 2017, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::
<#
	DESCRIPTION:	
	  RS_InformCustomer displays interaction with appropriate message
	ARGUMENTS:
	  
	RETURNS:
#>
#================================================================================
PARAM($DeviceName, $DeviceID)
#================================================================================
# Loading Utilities
#================================================================================
. .\CL_Utility.ps1
#================================================================================
# Initialize
#==================================================================================
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.Resolution_DriverNotFound
try
{
	$ProblemDevice = Get-WmiObject -Class Win32_PnPEntity | Where-Object -FilterScript {$_.DeviceID -eq $DeviceID}
	if(($ProblemDevice -ne $Null) -and ($ProblemDevice.ConfigManagerErrorCode -ne $Null))
	{
		switch($ProblemDevice.ConfigManagerErrorCode)
		{
			9 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error9Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error9Desc}
				 break
			  }

			12 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error12Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error12Desc}
				 break
			   }

			14 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error14Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error14Desc}
				 break
			   }

			16 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error16Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error16Desc}
				 break
			   }

			21 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error21Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error21Desc}
				 break
			   }

			24 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error24Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error24Desc}
				 break
			   }

			29 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error29Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error29Desc}
				 break
			   }

			33 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error33Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error33Desc}
				 break
			   }

			34 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error34Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error34Desc}
				 break
			   }

			35 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error35Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error35Desc}
				 break
			   }

			36 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error36Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error36Desc}
				 break
			   }

			38 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error38Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error38Desc}
				 break
			   }

			42 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error42Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error42Desc}
				 break
			   }

			44 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error44Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error44Desc}
				 break
			   }

			45 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error45Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error45Desc}
				 break
			   }

			46 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error46Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error46Desc}
				 break
			   }

			47 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error47Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error47Desc}
				 break
			   }

			49 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error49Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error49Desc}
				 break
			   }

			51 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error51Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error51Desc}
				 break
			   }

			52 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error52Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error52Desc}
				 break
			   }

			54 {
				 Get-DiagInput -Id "INT_Dynamic" -Parameter @{"Title" = $localizationString.Error54Title; "DeviceName" = $DeviceName; "ErrorCode" = $ProblemDevice.ConfigManagerErrorCode; "Desc" = $localizationString.Error54Desc}
				 break
			   }
		}
	}
}
Catch [System.Exception]
{
	Write-ExceptionTelemetry "RS_InformCustomer" $ProblemDevice.ConfigManagerErrorCode $_
	$errorMsg =  $_.Exception.Message
	$errorMsg | ConvertTo-Xml | Update-DiagReport -Id "RS_InformCustomer" -Name "RS_InformCustomer" -Verbosity Debug
}
