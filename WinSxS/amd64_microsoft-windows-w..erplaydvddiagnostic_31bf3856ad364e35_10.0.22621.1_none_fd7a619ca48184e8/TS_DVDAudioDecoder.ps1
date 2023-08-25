# Copyright © 2008, Microsoft Corporation. All rights reserved.


#TS_DVDAudioDecoder

trap { break }

$RootCLSIDPath = "Registry::HKEY_CLASSES_ROOT\CLSID\"

if ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Media Center\Decoder") -eq $False)
{
    return $False
}

$AudioDecoder=Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Media Center\Decoder" -name "PreferredMPEG2AudioDecoderCLSID" -ErrorAction silentlycontinue

if ($AudioDecoder -eq $Null)
{
    return $False
}

$AudioDecoderCLSID = $AudioDecoder.PreferredMPEG2AudioDecoderCLSID


if ((Test-Path ($RootCLSIDPath + $AudioDecoder.PreferredMPEG2AudioDecoderCLSID + "\InprocServer32")) -eq $False)
{
    return $False
}

$AudioDecoderBin =  Get-ItemProperty -path ($RootCLSIDPath + $AudioDecoder.PreferredMPEG2AudioDecoderCLSID + "\InprocServer32") -Name "(Default)" -ErrorAction silentlycontinue

if ($AudioDecoderBin -eq $Null)
{
    return $False
}

if ((Test-Path $AudioDecoderBin."(default)") -ne $True)
{
    return $False
}


return $True
