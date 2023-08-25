# Copyright © 2019, Microsoft Corporation. All rights reserved.

# Restart the Windows Search App

# Load utility library
. .\CL_Utility.ps1

function Kill-Process {
    [CmdletBinding()]
    Param(
        [String] $processName
    )

    # Get initial searchui
    $processList = Get-Process $processName -ErrorAction SilentlyContinue

    # Setup Timer
    $startTime = $(get-date).AddSeconds(30)
    $currentTime = $(get-date)

    # While the timeout hasn't been hit
    while ((($startTime - $currentTime) -gt 0) -and $processList) {
        $currentTime = $(get-date)

        $processList = Get-Process $processName -ErrorAction SilentlyContinue
        if ($processList) {
            $processList.CloseMainWindow() | Out-Null
            Stop-Process -Id $processList.Id -Force
        }

        $processList = Get-Process $processName -ErrorAction SilentlyContinue
    }
}

function Delete-FilesInFolder {
    [CmdletBinding()]
    Param(
        [string[]] $folderNames
    )

    foreach ($folder in $folderNames) {
        if (Test-Path -Path $folder) {
            Remove-Item -Recurse -Force $folder -ErrorAction SilentlyContinue
        }
    }
}

function Delete-WindowsSearchCache {
    [CmdletBinding()]
    Param(
        [String] $processName
    )
	
	if ($processName -eq "searchapp") {
		$folderNames = @("$Env:localappdata\Packages\Microsoft.Search_8wekyb3d8bbwe\AC\AppCache",
		"$Env:localappdata\Packages\Microsoft.Search_8wekyb3d8bbwe\AC\INetCache",
		"$Env:localappdata\Packages\Microsoft.Search_8wekyb3d8bbwe\AC\INetCookies",
		"$Env:localappdata\Packages\Microsoft.Search_8wekyb3d8bbwe\AC\INetHistory",
		"$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AC\AppCache",
		"$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AC\INetCache",
		"$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AC\INetCookies",
		"$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AC\INetHistory")

		Delete-FilesInFolder $folderNames
		return (Test-Path -Path "$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\AC\INetCache")
	}
	else {
		$folderNames = @("$Env:localappdata\Packages\Microsoft.Cortana_8wekyb3d8bbwe\AC\AppCache",
			"$Env:localappdata\Packages\Microsoft.Cortana_8wekyb3d8bbwe\AC\INetCache",
			"$Env:localappdata\Packages\Microsoft.Cortana_8wekyb3d8bbwe\AC\INetCookies",
			"$Env:localappdata\Packages\Microsoft.Cortana_8wekyb3d8bbwe\AC\INetHistory",
			"$Env:localappdata\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\AC\AppCache",
			"$Env:localappdata\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\AC\INetCache",
			"$Env:localappdata\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\AC\INetCookies",
			"$Env:localappdata\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\AC\INetHistory")

		Delete-FilesInFolder $folderNames
		return (Test-Path -Path "$Env:localappdata\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\AC\INetCache")
	}
}

function ResetAndLaunch-SearchApp {
    [CmdletBinding()]
    Param(
        [String] $processName
    )

    Kill-Process $processName 
    $return = Delete-WindowsSearchCache $processName
    Kill-Process $processName 
	return $return
 }
 
Write-DiagProgress -activity $localizationString.progress_rs_restoreSearchApp

# Set Environment Variables
$searchAppProcess = "searchui"
$searchPackageName = "$Env:localappdata\Packages\Microsoft.Windows.Search_cw5n1h2txyewy"

if (Test-Path -Path $searchPackageName) {
    $searchAppProcess = "searchapp"
} 

$result = ResetAndLaunch-SearchApp $searchAppProcess

# Returning Error back to the troubleshooter
if ($result) {
    Update-DiagRootCause -Id "RC_ResetWindowsSearchApp" -Detected $false
    return $true
} else {
    Update-DiagRootCause -Id "RC_ResetWindowsSearchApp" -Detected $true
    return $false
}
