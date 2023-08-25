# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_NetworkCacheCorrupted

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

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

    $WMPInformation = New-Object -TypeName System.Management.Automation.PSObject
    Add-Member -InputObject $WMPInformation -MemberType NoteProperty -Name $localizationString.BinaryPath -Value $WMPBinaryPath.ToString()
    Add-Member -InputObject $WMPInformation -MemberType NoteProperty -Name $localizationString.Version -Value $WMPVersion
    $WMPInformation | ConvertTo-XML | Update-DiagReport -ID WMPInformation -Name $localizationString.Report_Name_WMPInformation -Description $localizationString.Report_Description_WMPInformation -Verbosity Informational -rid RC_NetworkCacheCorrupted
}

$Localdatapath = Get-Item -path LOCALAPPDATA

Set-Location $Localdatapath.Value

$FilePath = ".\Microsoft\Windows Media\" + $WMPVersion + "\WMSDKNS.xml"

$IsFileExist = Test-Path $FilePath

if ($IsFileExist -eq $False)
{
    Pop-Location
    return $True
}

$FileFullPath = $Localdatapath.Value.ToString() + "\Microsoft\Windows Media\" + $WMPVersion + "\WMSDKNS.xml"
Update-DiagReport -ID NetWorkCachedFile -File $FileFullPath -Name $localizationString.Report_Name_NetWorkCachedFile -Verbosity Informational -rid RC_NetworkCacheCorrupted

$CacheFile = Get-Item -path $FilePath

$XmlDoc = New-Object -TypeName System.Xml.XmlDocument

try
{
    $XmlDoc.Load($CacheFile.FullName)
}
catch
{
    Pop-Location
    return $False
}

$root = $XmlDoc.DocumentElement

if($root -eq $Null)
{
    Pop-Location
    return $False
}

if($root.HasChildNodes -eq $False)
{
    Pop-Location
    return $False
}

$HashNodes = @{"Network Source" = "Network Source"; "Control Protocol" = "Control Protocol"; "Data Protocol" = "Data Protocol"; "Feedback Protocol" = "Feedback Protocol"}

foreach($ChildNode in $root.ChildNodes)
{
    if($ChildNode.Name -eq "#comment")
    {
        continue
    }

    if($HashNodes.Contains($ChildNode.Name) -eq $False)
    {
        Pop-Location
        return $False
    }

    if($ChildNode.HasChiledNodes -eq $False)
    {
        Pop-Location
        return $False
    }

    $ObjectStore = $ChildNode.ChildNodes.Item(0)
    if($ObjectStore.Name -ne "Object Store")
    {
        Pop-Location
        return $False
    }

    if($ObjectStore.HasChildNodes -eq $False)
    {
        Pop-Location
        return $False
    }

}

Pop-Location
return $True
