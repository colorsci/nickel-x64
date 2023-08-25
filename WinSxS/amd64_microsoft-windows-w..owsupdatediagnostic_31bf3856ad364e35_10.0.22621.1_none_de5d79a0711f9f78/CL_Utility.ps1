# Copyright © 2017, Microsoft Corporation. All rights reserved.
# =============================================================

#*================================================================================
#Check-WindowsVersion
#*================================================================================	
function Check-WindowsVersion()
{
	# check the Windows version
	
	$OS = Get-WmiObject -Namespace root\CIMV2 -Class Win32_OperatingSystem
	$temp = $OS.Version.Split(".")
    $OSVersion = ($temp[0] + "." + $temp[1])
	if($OS)
	{
		if( ([int]::Parse($OS.version[0]) -eq 6) ){
			return ( [int]::Parse($OS.version[0])*10 + [int]::Parse($OS.version[2])  ) # greater than windows vista
		}elseif(([int]::Parse($OS.version[0]) -eq 6) -and ([int]::Parse($OS.version[2]) -eq 1)){
			return 61 # windows 7
		}elseif(([int]::Parse($OS.version[0]) -eq 6) -and ([int]::Parse($OS.version[2]) -eq 0)){
	
			return 60 # windows vista
		}elseif(([int]::Parse($OS.version[0]) -eq 5) -and ([int]::Parse($OS.version[2]) -eq 1)){
			return 51 # win xp 32 bit
		}elseif(([int]::Parse($OS.version[0]) -eq 5) -and ([int]::Parse($OS.version[2]) -eq 2)){
			return 52 # win xp 64 bit
		}elseif([Float]$OSVersion -gt [Float](6.2)){
			 return 100 # Windows 10
		}
        else{
            return 13 # below win xp
        }
	}
}

#*================================================================================
#Get-AppDataExpectedString
#*================================================================================
function Get-AppDataExpectedString()
{	
	$correctValue = '%USERPROFILE%\AppData\Roaming'
	$currWinVersion = Check-WindowsVersion
	if( ($currwinversion -eq 51) -or ($currwinversion -eq 52) ) # for win xp 32 bit and 64 bit
	{ 
		$correctValue = '%USERPROFILE%\Application Data'
	}
	return $correctValue
}

#*================================================================================
#ImportLocalizedData
#*================================================================================
Function ImportLocalizedData()
{
	if ($localizationString -eq $null)
	{
		$localizationString = @{};
	}
	
	if (-not $Global:IsDevEnv -and $localizationString.Count -eq 0)
	{
		Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData		
	}
	return $localizationString
}

#*================================================================================
#SetDiagProgress
#*================================================================================
Function SetDiagProgress([string]$stringID)
{
	$str = GetDiagString $stringID
	if ($Global:IsDevEnv)
	{
		Write-Host "Write-DiagProgress -activity $str"
	}
	else
	{
		Write-DiagProgress -activity $str
	}
}

#*================================================================================
#GetDiagString
#*================================================================================
Function GetDiagString([string]$stringID)
{
	if ($Global:IsDevEnv)
	{
		return $stringID
	}
	else
	{
		$localizationString = ImportLocalizedData
		$str = $localizationString[$stringID]
		return $str
	}
}