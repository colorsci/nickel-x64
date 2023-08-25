# Copyright © 2008, Microsoft Corporation. All rights reserved.


#RS_NetworkCacheCorrupted

Push-Location
Set-Location Env:

#
#Get window media player version info
#
$WMPVersion = "11.0"

$ProgramFilesPath = Get-Item -path ProgramFiles

$WMPBinaryPath = $ProgramFilesPath.Value + "\Windows Media Player\wmplayer.exe"

[System.Diagnostics.FileVersionInfo]$WMPVersionInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($WMPBinaryPath)

if($WMPVersionInfo -ne $Null)
{
    $WMPVersion = $WMPVersionInfo.FileMajorPart.ToString() + "." + $WMPVersionInfo.FileMinorPart.ToString()
}

$Localdatapath = Get-Item -path LOCALAPPDATA

Set-Location $Localdatapath.Value

$FilePath = ".\Microsoft\Windows Media\" + $WMPVersion + "\WMSDKNS.xml"

$OldFilePath = ".\Microsoft\Windows Media\" + $WMPVersion + "\WMSDKNS.old.xml"

$IsExist = Test-Path $FilePath

if ($IsExist -eq $True)
{
    $IsExist = Test-Path $OldFilePath

    if($IsExist -eq $true)
    {
        Remove-Item -path $OldFilePath -Recurse -Force
    }

    Rename-Item $FilePath -NewName "WMSDKNS.old.xml"
}

Pop-Location
