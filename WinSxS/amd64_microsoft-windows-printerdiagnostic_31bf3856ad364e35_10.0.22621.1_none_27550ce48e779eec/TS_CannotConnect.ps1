# Copyright © 2008, Microsoft Corporation. All rights reserved.


PARAM($printerName)
#
# check the default printer's connection
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData
. .\CL_Utility.ps1

Write-DiagProgress -activity $localizationString.progress_ts_cannotConnect

function PingServerName([string]$serverName)
{
    if([string]::IsNullorEmpty($ServerName))
    {
        return $false
    }
    else
    {
        $pingSender = New-Object System.Net.NetworkInformation.Ping

        try {
            $reply = $pingSender.Send($ServerName.SubString($ServerName.IndexOf('\')+2))
        } catch {
            return $false
        }
        if($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success)
        {
            return $true
        }
        else
        {
            return $false
        }
    }
}

$printerSelected = GetPrinterFromPrinterName $printerName

if($printerSelected.NetWork)
{
    if(-not (PingServerName $printerSelected.ServerName))
    {
        Update-DiagRootCause -id "RC_CannotConnect" -instanceId "SMB" -Detected $true -parameter @{ "PRINTERTYPE" = "SMB";"SMBSHARE" = $printerSelected.ServerName; "TCP_PRINTERADDRESS" = ""; "PRINTERNAME" = $printerName }
    } else {
        Update-DiagRootCause -id "RC_CannotConnect" -instanceId "SMB" -Detected $false -parameter @{ "PRINTERTYPE" = "SMB";"SMBSHARE" = $printerSelected.ServerName; "TCP_PRINTERADDRESS" = ""; "PRINTERNAME" = $printerName }
    }
}
else
{
    #
    # Get printer port information
    #
    $ports = Get-WmiObject Win32_TCPIPPrinterPort

    $connectPort = $null

    foreach($port in $ports)
    {
        if($printerSelected.PortName -eq $port.Name)
        {
            $connectPort = $port
        }
    }

    if($connectPort -ne $null)
    {
        #
        # Check the printer port connection using TcpClient
        #
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        try
        {
            #
            # Some ports perhaps cause the exception of the function. We need not catch it out of program.
            #
            try
            {
                $tcpClient.Connect($connectPort.HostAddress, $connectPort.PortNumber)
            }
            catch
            {
                WriteFileExceptionReport "TS_CannotConnect" "$_"
            }

            $hostAddress = $connectPort.HostAddress
            $portNumber = $connectPort.PortNumber
            if(-not $tcpClient.Connected)
            {
                 Update-DiagRootCause -id "RC_CannotConnect" -instanceId "TCP" -Detected $true -parameter @{ "PRINTERTYPE" = "Winsock";"SMBSHARE" = ""; "TCP_PRINTERADDRESS" = "${hostAddress}:$portNumber"; "PRINTERNAME" = $printerName }
            } else {
                 Update-DiagRootCause -id "RC_CannotConnect" -instanceId "TCP" -Detected $false -parameter @{ "PRINTERTYPE" = "Winsock";"SMBSHARE" = ""; "TCP_PRINTERADDRESS" = "${hostAddress}:$portNumber"; "PRINTERNAME" = $printerName }
            }
        }
        finally
        {
            $tcpClient.Close()
        }

        $connectPort | select-object -Property @{Name=$localizationString.printerPort_portName; Expression={$_.Name}}, @{Name=$localizationString.printerPort_portNumber; Expression={$_.portNumber}} | convertto-xml | Update-DiagReport -id PrinterPort -name $localizationString.printerPort_name -verbosity Informational -rid "RC_CannotConnect" -instanceId “TCP”
    }
    elseif(-not [string]::IsNullorEmpty($printerSelected.ServerName))
    {
        if(-not (PingServerName $printerSelected.ServerName))
        {
            Update-DiagRootCause -id "RC_CannotConnect" -instanceId "SMB" -Detected $true -parameter @{ "PRINTERTYPE" = "SMB";"SMBSHARE" = $printerSelected.ServerName; "TCP_PRINTERADDRESS" = ""; "PRINTERNAME" = $printerName }
        } else {
            Update-DiagRootCause -id "RC_CannotConnect" -instanceId "SMB" -Detected $false -parameter @{ "PRINTERTYPE" = "SMB";"SMBSHARE" = $printerSelected.ServerName; "TCP_PRINTERADDRESS" = ""; "PRINTERNAME" = $printerName }
        }
    }
}
