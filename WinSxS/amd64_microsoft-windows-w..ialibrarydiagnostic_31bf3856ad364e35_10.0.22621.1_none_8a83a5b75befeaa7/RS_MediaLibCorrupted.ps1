# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_WindowsMediaPlayer

Push-Location
Set-Location Env:

$Localdatapath = Get-Item -path LOCALAPPDATA

Set-Location $Localdatapath.Value

$IsExist = Test-Path ".\Microsoft\Media Player.old"

if($IsExist -eq $true)
{
    Remove-Item -path ".\Microsoft\Media Player.old" -Recurse -Force
}

$IsExist = Test-path ".\Microsoft\Media Player"
if($IsExist -eq $True)
{
    $MedialibPath = Get-Item -path ".\Microsoft\Media Player"

    Rename-Item $MedialibPath -NewName "Media Player.old"
}

Pop-Location
