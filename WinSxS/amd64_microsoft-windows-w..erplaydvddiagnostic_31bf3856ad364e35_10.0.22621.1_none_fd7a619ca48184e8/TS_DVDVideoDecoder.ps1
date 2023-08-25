# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_DVDVideoDecoder

trap { break }

$RootCLSIDPath = "Registry::HKEY_CLASSES_ROOT\CLSID\"

if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Media Center\Decoder") -eq $False)
{
    return $False
}

$VideoDecoder = Get-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Media Center\Decoder" -Name "PreferredMPEG2VideoDecoderCLSID" -ErrorAction silentlycontinue

if ($VideoDecoder -eq $Null)
{
    return $False
}

$VideoDecoderCLSID = $VideoDecoder.PreferredMPEG2VideoDecoderCLSID

if ((Test-Path ($RootCLSIDPath + $VideoDecoder.PreferredMPEG2VideoDecoderCLSID + "\InprocServer32")) -eq $False)
{
    return $False
}

$VideoDecoderBin =  Get-ItemProperty -path ($RootCLSIDPath + $VideoDecoder.PreferredMPEG2VideoDecoderCLSID + "\InprocServer32") -Name "(Default)" -ErrorAction silentlycontinue

if ($VideoDecoderBin -eq $Null)
{
    return $False
}

if ((Test-Path $VideoDecoderBin."(default)") -ne $True)
{
    return $False
}

return $True
