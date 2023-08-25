# Copyright © 2019, Microsoft Corporation. All rights reserved.

# Check the status of the Search App. If the app is not in a good state, add the root cause.

PARAM($Action)

# Load utility library
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_searchApp

if ($Action -eq "Diagnose")
{
	$testPath = "$Env:localappdata\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\AC\INetCache"
    if (Test-Path -Path "$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy") {
		$testPath = "$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AC\INetCache"
	}
	
	if (Test-Path -Path $testPath) {
		Update-DiagRootCause -id "RC_SearchApp" -Detected $true
		return $false
	} else {
		Update-DiagRootCause -id "RC_SearchApp" -Detected $false
		return $true
	}
}
else
{
    Update-DiagRootCause -id "RC_SearchApp" -Detected $false
    return $true
}
