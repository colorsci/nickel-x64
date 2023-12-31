'----------------------------------------------------------------------
'
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Abstract:
' prnport.vbs - Port script for WMI on Windows 
'     used to add, delete and list ports
'     also for getting and setting the port configuration
'
' Usage:
' prnport [-adlgt?] [-r port] [-s server] [-u user name] [-w password]
'                   [-o raw|lpr] [-h host address] [-q queue] [-n number]
'                   [-me | -md ] [-i SNMP index] [-y community] [-2e | -2d]"
'
' Examples
' prnport -a -s server -r IP_1.2.3.4 -e 1.2.3.4 -o raw -n 9100
' prnport -d -s server -r c:\temp\foo.prn
' prnport -l -s server
' prnport -g -s server -r IP_1.2.3.4
' prnport -t -s server -r IP_1.2.3.4 -me -y public -i 1 -n 9100
'
'----------------------------------------------------------------------

option explicit

'
' Debugging trace flags, to enable debug output trace message
' change gDebugFlag to true.
'
dim   gDebugFlag
const kDebugTrace = 1
const kDebugError = 2

gDebugFlag = false

'
' Operation action values.
'
const kActionAdd          = 0
const kActionDelete       = 1
const kActionList         = 2
const kActionUnknown      = 3
const kActionGet          = 4
const kActionSet          = 5

const kErrorSuccess       = 0
const KErrorFailure       = 1

const kFlagCreateOrUpdate = 0

const kNameSpace          = "root\cimv2"


'
' Constants for the parameter dictionary
'
const kServerName      = 1
const kPortName        = 2
const kDoubleSpool     = 3
const kPortNumber      = 4
const kPortType        = 5
const kHostAddress     = 6
const kSNMPDeviceIndex = 7
const kCommunityName   = 8
const kSNMP            = 9
const kQueueName       = 10
const kUserName        = 11
const kPassword        = 12

'
' Generic strings
'
const L_Empty_Text                 = ""
const L_Space_Text                 = " "
const L_Colon_Text                 = ":"
const L_LPR_Queue                  = "LPR"
const L_Error_Text                 = "Error"
const L_Success_Text               = "Success"
const L_Failed_Text                = "Failed"
const L_Hex_Text                   = "0x"
const L_Printer_Text               = "Printer"
const L_Operation_Text             = "Operation"
const L_Provider_Text              = "Provider"
const L_Description_Text           = "Description"
const L_Debug_Text                 = "Debug:"

'
' General usage messages
'
const L_Help_Help_General01_Text   = "Usage: prnport [-adlgt?] [-r port][-s server][-u user name][-w password]"
const L_Help_Help_General02_Text   = "               [-o raw|lpr][-h host address][-q queue][-n number]"
const L_Help_Help_General03_Text   = "               [-me | -md ][-i SNMP index][-y community][-2e | -2d]"
const L_Help_Help_General04_Text   = "Arguments:"
const L_Help_Help_General05_Text   = "-a     - add a port"
const L_Help_Help_General06_Text   = "-d     - delete the specified port"
const L_Help_Help_General07_Text   = "-g     - get configuration for a TCP port"
const L_Help_Help_General08_Text   = "-h     - IP address of the device"
const L_Help_Help_General09_Text   = "-i     - SNMP index, if SNMP is enabled"
const L_Help_Help_General10_Text   = "-l     - list all TCP ports"
const L_Help_Help_General11_Text   = "-m     - SNMP type. [e] enable, [d] disable"
const L_Help_Help_General12_Text   = "-n     - port number, applies to TCP RAW ports"
const L_Help_Help_General13_Text   = "-o     - port type, raw or lpr"
const L_Help_Help_General14_Text   = "-q     - queue name, applies to TCP LPR ports only"
const L_Help_Help_General15_Text   = "-r     - port name"
const L_Help_Help_General16_Text   = "-s     - server name"
const L_Help_Help_General17_Text   = "-t     - set configuration for a TCP port"
const L_Help_Help_General18_Text   = "-u     - user name"
const L_Help_Help_General19_Text   = "-w     - password"
const L_Help_Help_General20_Text   = "-y     - community name, if SNMP is enabled"
const L_Help_Help_General21_Text   = "-2     - double spool, applies to TCP LPR ports. [e] enable, [d] disable"
const L_Help_Help_General22_Text   = "-?     - display command usage"
const L_Help_Help_General23_Text   = "Examples:"
const L_Help_Help_General24_Text   = "prnport -l -s server"
const L_Help_Help_General25_Text   = "prnport -d -s server -r IP_1.2.3.4"
const L_Help_Help_General26_Text   = "prnport -a -s server -r IP_1.2.3.4 -h 1.2.3.4 -o raw -n 9100"
const L_Help_Help_General27_Text   = "prnport -t -s server -r IP_1.2.3.4 -me -y public -i 1 -n 9100"
const L_Help_Help_General28_Text   = "prnport -g -s server -r IP_1.2.3.4"
const L_Help_Help_General29_Text   = "prnport -a -r IP_1.2.3.4 -h 1.2.3.4"
const L_Help_Help_General30_Text   = "Remark:"
const L_Help_Help_General31_Text   = "The last example will try to get the device settings at the specified IP address."
const L_Help_Help_General32_Text   = "If a device is detected, then a TCP port is added with the preferred settings for that device."

'
' Messages to be displayed if the scripting host is not cscript
'
const L_Help_Help_Host01_Text      = "This script should be executed from the Command Prompt using CScript.exe."
const L_Help_Help_Host02_Text      = "For example: CScript script.vbs arguments"
const L_Help_Help_Host03_Text      = ""
const L_Help_Help_Host04_Text      = "To set CScript as the default application to run .VBS files run the following:"
const L_Help_Help_Host05_Text      = "     CScript //H:CScript //S"
const L_Help_Help_Host06_Text      = "You can then run ""script.vbs arguments"" without preceding the script with CScript."

'
' General error messages
'
const L_Text_Error_General01_Text  = "The scripting host could not be determined."
const L_Text_Error_General02_Text  = "Unable to parse command line."
const L_Text_Error_General03_Text  = "Win32 error code"

'
' Miscellaneous messages
'
const L_Text_Msg_General01_Text    = "Added port"
const L_Text_Msg_General02_Text    = "Unable to delete port"
const L_Text_Msg_General03_Text    = "Unable to get port"
const L_Text_Msg_General04_Text    = "Created/updated port"
const L_Text_Msg_General05_Text    = "Unable to create/update port"
const L_Text_Msg_General06_Text    = "Unable to enumerate ports"
const L_Text_Msg_General07_Text    = "Number of ports enumerated"
const L_Text_Msg_General08_Text    = "Deleted port"
const L_Text_Msg_General09_Text    = "Unable to get SWbemLocator object"
const L_Text_Msg_General10_Text    = "Unable to connect to WMI service"


'
' Port properties
'
const L_Text_Msg_Port01_Text       = "Server name"
const L_Text_Msg_Port02_Text       = "Port name"
const L_Text_Msg_Port03_Text       = "Host address"
const L_Text_Msg_Port04_Text       = "Protocol RAW"
const L_Text_Msg_Port05_Text       = "Protocol LPR"
const L_Text_Msg_Port06_Text       = "Port number"
const L_Text_Msg_Port07_Text       = "Queue"
const L_Text_Msg_Port08_Text       = "Byte Count Enabled"
const L_Text_Msg_Port09_Text       = "Byte Count Disabled"
const L_Text_Msg_Port10_Text       = "SNMP Enabled"
const L_Text_Msg_Port11_Text       = "SNMP Disabled"
const L_Text_Msg_Port12_Text       = "Community"
const L_Text_Msg_Port13_Text       = "Device index"

'
' Debug messages
'
const L_Text_Dbg_Msg01_Text        = "In function DelPort"
const L_Text_Dbg_Msg02_Text        = "In function CreateOrSetPort"
const L_Text_Dbg_Msg03_Text        = "In function ListPorts"
const L_Text_Dbg_Msg04_Text        = "In function GetPort"
const L_Text_Dbg_Msg05_Text        = "In function ParseCommandLine"

main

'
' Main execution starts here
'
sub main

    on error resume next

    dim iAction
    dim iRetval
    dim oParamDict

    '
    ' Abort if the host is not cscript
    '
    if not IsHostCscript() then

        call wscript.echo(L_Help_Help_Host01_Text & vbCRLF & L_Help_Help_Host02_Text & vbCRLF & _
                          L_Help_Help_Host03_Text & vbCRLF & L_Help_Help_Host04_Text & vbCRLF & _
                          L_Help_Help_Host05_Text & vbCRLF & L_Help_Help_Host06_Text & vbCRLF)

        wscript.quit

    end if

    set oParamDict = CreateObject("Scripting.Dictionary")

    iRetval = ParseCommandLine(iAction, oParamDict)

    if iRetval = 0 then

        select case iAction

            case kActionAdd
                iRetval = CreateOrSetPort(oParamDict)

            case kActionDelete
                iRetval = DelPort(oParamDict)

            case kActionList
                iRetval = ListPorts(oParamDict)

            case kActionGet
                iRetVal = GetPort(oParamDict)

            case kActionSet
                iRetVal = CreateOrSetPort(oParamDict)

            case else
                Usage(true)
                exit sub

        end select

    end if

end sub

'
' Delete a port
'
function DelPort(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text
    DebugPrint kDebugTrace, L_Text_Msg_Port01_Text & L_Space_Text & oParamDict(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Port02_Text & L_Space_Text & oParamDict(kPortName)

    dim oService
    dim oPort
    dim iResult
    dim strServer
    dim strPort
    dim strUser
    dim strPassword

    iResult = kErrorFailure

    strServer   = oParamDict(kServerName)
    strPort     = oParamDict(kPortName)
    strUser     = oParamDict(kUserName)
    strPassword = oParamDict(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPort = oService.Get("Win32_TCPIPPrinterPort='" & strPort & "'")

    else

        DelPort = kErrorFailure

        exit function

    end if

    '
    ' Check if Get succeeded
    '
    if Err.Number = kErrorSuccess then

        '
        ' Try deleting the instance
        '
        oPort.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General08_Text & L_Space_Text & strPort

        else

            wscript.echo L_Text_Msg_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                         & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

        end if

    else

        wscript.echo L_Text_Msg_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    DelPort = iResult

end function

'
' Add or update a port
'
function CreateOrSetPort(oParamDict)

    on error resume next

    dim oPort
    dim oService
    dim iResult
    dim PortType
    dim strServer
    dim strPort
    dim strUser
    dim strPassword

    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text
    DebugPrint kDebugTrace, L_Text_Msg_Port01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Port02_Text & L_Space_Text & oParamDict.Item(kPortName)
    DebugPrint kDebugTrace, L_Text_Msg_Port06_Text & L_Space_Text & oParamDict.Item(kPortNumber)
    DebugPrint kDebugTrace, L_Text_Msg_Port07_Text & L_Space_Text & oParamDict.Item(kQueueName)
    DebugPrint kDebugTrace, L_Text_Msg_Port13_Text & L_Space_Text & oParamDict.Item(kSNMPDeviceIndex)
    DebugPrint kDebugTrace, L_Text_Msg_Port12_Text & L_Space_Text & oParamDict.Item(kCommunityName)
    DebugPrint kDebugTrace, L_Text_Msg_Port03_Text & L_Space_Text & oParamDict.Item(kHostAddress)

    strServer   = oParamDict(kServerName)
    strPort     = oParamDict(kPortName)
    strUser     = oParamDict(kUserName)
    strPassword = oParamDict(kPassword)

    '
    ' If the port exists, then get the settings. Later PutInstance will do an update
    '
    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPort = oService.Get("Win32_TCPIPPrinterPort.Name='" & strPort & "'")

        '
        ' If get was unsuccessful then spawn a new port instance. Later PutInstance will do a create
        '
        if Err.Number <> kErrorSuccess then

            '
            ' Clear the previous error
            '
            Err.Clear

            set oPort = oService.Get("Win32_TCPIPPrinterPort").SpawnInstance_

        end if

    else

        CreateOrSetPort = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General03_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        CreateOrSetPort = kErrorFailure

        exit function

    end if

    oPort.Name          = oParamDict.Item(kPortName)
    oPort.HostAddress   = oParamDict.Item(kHostAddress)
    oPort.PortNumber    = oParamDict.Item(kPortNumber)
    oPort.SNMPEnabled   = oParamDict.Item(kSNMP)
    oPort.SNMPDevIndex  = oParamDict.Item(kSNMPDeviceIndex)
    oPort.SNMPCommunity = oParamDict.Item(kCommunityName)
    oPort.Queue         = oParamDict.Item(kQueueName)
    oPort.ByteCount     = oParamDict.Item(kDoubleSpool)

    PortType     = oParamDict.Item(kPortType)

    '
    ' Update the port object with the settings corresponding
    ' to the port type of the port to be added
    '
    select case lcase(PortType)

            case "raw"

                 oPort.Protocol      = 1

                 if Not IsNull(oPort.Queue) then

                     wscript.echo L_Error_Text & L_Colon_Text & L_Space_Text _
                     & L_Help_Help_General14_Text

                     CreateOrSetPort = kErrorFailure

                     exit function

                 end if

            case "lpr"

                 oPort.Protocol      = 2

                 if IsNull(oPort.Queue) then

                     oPort.Queue = L_LPR_Queue

                 end if

            case else

                 '
                 ' PutInstance will attempt to get the configuration of
                 ' the device based on its IP address. Those settings
                 ' will be used to add a new port
                 '
    end select

    '
    ' Try creating or updating the port
    '
    oPort.Put_(kFlagCreateOrUpdate)

    if Err.Number = kErrorSuccess then

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oPort.Name

        iResult = kErrorSuccess

    else

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & oPort.Name & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                     & L_Space_Text & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

        iResult = kErrorFailure

    end if

    CreateOrSetPort = iResult

end function

'
' List ports on a machine.
'
function ListPorts(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text

    dim Ports
    dim oPort
    dim oService
    dim iRetval
    dim iTotal
    dim strServer
    dim strUser
    dim strPassword

    iResult = kErrorFailure

    strServer   = oParamDict(kServerName)
    strUser     = oParamDict(kUserName)
    strPassword = oParamDict(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Ports = oService.InstancesOf("Win32_TCPIPPrinterPort")

    else

        ListPorts = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General06_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        ListPrinters = kErrorFailure

        exit function

    end if

    iTotal = 0

    for each oPort in Ports

        iTotal = iTotal + 1

        wscript.echo L_Empty_Text
        wscript.echo L_Text_Msg_Port01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Port02_Text & L_Space_Text & oPort.Name
        wscript.echo L_Text_Msg_Port03_Text & L_Space_Text & oPort.HostAddress

        if oPort.Protocol = 1 then

            wscript.echo L_Text_Msg_Port04_Text
            wscript.echo L_Text_Msg_Port06_Text & L_Space_Text & oPort.PortNumber

        else

            wscript.echo L_Text_Msg_Port05_Text
            wscript.echo L_Text_Msg_Port07_Text & L_Space_Text & oPort.Queue

            if oPort.ByteCount then

                wscript.echo L_Text_Msg_Port08_Text

            else

                wscript.echo L_Text_Msg_Port09_Text

            end if

        end if

        if oPort.SNMPEnabled then

            wscript.echo L_Text_Msg_Port10_Text
            wscript.echo L_Text_Msg_Port12_Text & L_Space_Text & oPort.SNMPCommunity
            wscript.echo L_Text_Msg_Port13_Text & L_Space_Text & oPort.SNMPDevIndex

        else

            wscript.echo L_Text_Msg_Port11_Text

        end if

        Err.Clear

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General07_Text & L_Space_Text & iTotal

    ListPorts = kErrorSuccess

end function

'
' Gets the configuration of a port
'
function GetPort(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text
    DebugPrint kDebugTrace, L_Text_Msg_Port01_Text & L_Space_Text & oParamDict(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Port02_Text & L_Space_Text & oParamDict(kPortName)

    dim oService
    dim oPort
    dim iResult
    dim strServer
    dim strPort
    dim strUser
    dim strPassword

    iResult = kErrorFailure

    strServer   = oParamDict(kServerName)
    strPort     = oParamDict(kPortName)
    strUser     = oParamDict(kUserName)
    strPassword = oParamDict(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPort = oService.Get("Win32_TCPIPPrinterPort.Name='" & strPort & "'")

    else

        GetPort = kErrorFailure

        exit function

    end if

    if Err.Number = kErrorSuccess then

        wscript.echo L_Empty_Text
        wscript.echo L_Text_Msg_Port01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Port02_Text & L_Space_Text & oPort.Name
        wscript.echo L_Text_Msg_Port03_Text & L_Space_Text & oPort.HostAddress

        if oPort.Protocol = 1 then

            wscript.echo L_Text_Msg_Port04_Text
            wscript.echo L_Text_Msg_Port06_Text & L_Space_Text & oPort.PortNumber

        else

            wscript.echo L_Text_Msg_Port05_Text
            wscript.echo L_Text_Msg_Port07_Text & L_Space_Text & oPort.Queue

            if oPort.ByteCount then

                wscript.echo L_Text_Msg_Port08_Text

            else

                wscript.echo L_Text_Msg_Port09_Text

            end if

        end if

        if oPort.SNMPEnabled then

            wscript.echo L_Text_Msg_Port10_Text
            wscript.echo L_Text_Msg_Port12_Text & L_Space_Text & oPort.SNMPCommunity
            wscript.echo L_Text_Msg_Port13_Text & L_Space_Text & oPort.SNMPDevIndex

        else

            wscript.echo L_Text_Msg_Port11_Text

        end if

        iResult = kErrorSuccess

    else

        wscript.echo L_Text_Msg_General03_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    GetPort = iResult

end function

'
' Debug display helper function
'
sub DebugPrint(uFlags, strString)

    if gDebugFlag = true then

        if uFlags = kDebugTrace then

            wscript.echo L_Debug_Text & L_Space_Text & strString

        end if

        if uFlags = kDebugError then

            if Err <> 0 then

                wscript.echo L_Debug_Text & L_Space_Text & strString & L_Space_Text _
                             & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                             & L_Space_Text & Err.Description

            end if

        end if

    end if

end sub

'
' Parse the command line into its components
'
function ParseCommandLine(iAction, oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg05_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown

    set oArgs = Wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-g"
                iAction = kActionGet

            case "-t"
                iAction = kActionSet

            case "-a"
                iAction = kActionAdd

            case "-d"
                iAction = kActionDelete

            case "-l"
                iAction = kActionList

            case "-2e"
                oParamDict.Add kDoubleSpool, true

            case "-2d"
                oParamDict.Add kDoubleSpool, false

            case "-s"
                iIndex = iIndex + 1
                oParamDict.Add kServerName, RemoveBackslashes(oArgs(iIndex))

            case "-u"
                iIndex = iIndex + 1
                oParamDict.Add kUserName, oArgs(iIndex)

            case "-w"
                iIndex = iIndex + 1
                oParamDict.Add kPassword, oArgs(iIndex)

            case "-n"
                iIndex = iIndex + 1
                oParamDict.Add kPortNumber, oArgs(iIndex)

            case "-r"
                iIndex = iIndex + 1
                oParamDict.Add kPortName, oArgs(iIndex)

            case "-o"
                iIndex = iIndex + 1
                oParamDict.Add kPortType, oArgs(iIndex)

            case "-h"
                iIndex = iIndex + 1
                oParamDict.Add kHostAddress, oArgs(iIndex)

            case "-q"
                iIndex = iIndex + 1
                oParamDict.Add kQueueName, oArgs(iIndex)

            case "-i"
                iIndex = iIndex + 1
                oParamDict.Add kSNMPDeviceIndex, oArgs(iIndex)

            case "-y"
                iIndex = iIndex + 1
                oParamDict.Add kCommunityName, oArgs(iIndex)

            case "-me"
                oParamDict.Add kSNMP, true

            case "-md"
                oParamDict.Add kSNMP, false

            case "-?"
                Usage(True)
                exit function

            case else
                Usage(True)
                exit function

        end select

        iIndex = iIndex + 1

    wend

    if Err = kErrorSuccess then

        ParseCommandLine = kErrorSuccess

    else

        wscript.echo L_Text_Error_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_text & Err.Description


        ParseCommandLine = kErrorFailure

    end if

end  function

'
' Display command usage.
'
sub Usage(bExit)

    wscript.echo L_Help_Help_General01_Text
    wscript.echo L_Help_Help_General02_Text
    wscript.echo L_Help_Help_General03_Text
    wscript.echo L_Help_Help_General04_Text
    wscript.echo L_Help_Help_General05_Text
    wscript.echo L_Help_Help_General06_Text
    wscript.echo L_Help_Help_General07_Text
    wscript.echo L_Help_Help_General08_Text
    wscript.echo L_Help_Help_General09_Text
    wscript.echo L_Help_Help_General10_Text
    wscript.echo L_Help_Help_General11_Text
    wscript.echo L_Help_Help_General12_Text
    wscript.echo L_Help_Help_General13_Text
    wscript.echo L_Help_Help_General14_Text
    wscript.echo L_Help_Help_General15_Text
    wscript.echo L_Help_Help_General16_Text
    wscript.echo L_Help_Help_General17_Text
    wscript.echo L_Help_Help_General18_Text
    wscript.echo L_Help_Help_General19_Text
    wscript.echo L_Help_Help_General20_Text
    wscript.echo L_Help_Help_General21_Text
    wscript.echo L_Help_Help_General22_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General23_Text
    wscript.echo L_Help_Help_General24_Text
    wscript.echo L_Help_Help_General25_Text
    wscript.echo L_Help_Help_General26_Text
    wscript.echo L_Help_Help_General27_Text
    wscript.echo L_Help_Help_General28_Text
    wscript.echo L_Help_Help_General29_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General30_Text
    wscript.echo L_Help_Help_General31_Text
    wscript.echo L_Help_Help_General32_Text

    if bExit then

        wscript.quit(1)

    end if

end sub

'
' Determines which program is being used to run this script.
' Returns true if the script host is cscript.exe
'
function IsHostCscript()

    on error resume next

    dim strFullName
    dim strCommand
    dim i, j
    dim bReturn

    bReturn = false

    strFullName = WScript.FullName

    i = InStr(1, strFullName, ".exe", 1)

    if i <> 0 then

        j = InStrRev(strFullName, "\", i, 1)

        if j <> 0 then

            strCommand = Mid(strFullName, j+1, i-j-1)

            if LCase(strCommand) = "cscript" then

                bReturn = true

            end if

        end if

    end if

    if Err <> 0 then

        wscript.echo L_Text_Error_General01_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    IsHostCscript = bReturn

end function

'
' Retrieves extended information about the last error that occurred
' during a WBEM operation. The methods that set an SWbemLastError
' object are GetObject, PutInstance, DeleteInstance
'
sub LastError()

    on error resume next

    dim oError

    set oError = CreateObject("WbemScripting.SWbemLastError")

    if Err = kErrorSuccess then

        wscript.echo L_Operation_Text            & L_Space_Text & oError.Operation
        wscript.echo L_Provider_Text             & L_Space_Text & oError.ProviderName
        wscript.echo L_Description_Text          & L_Space_Text & oError.Description
        wscript.echo L_Text_Error_General04_Text & L_Space_Text & oError.StatusCode

    end if

end sub

'
' Connects to the WMI service on a server. oService is returned as a service
' object (SWbemServices)
'
function WmiConnect(strServer, strNameSpace, strUser, strPassword, oService)

   on error resume next

   dim oLocator
   dim bResult

   oService = null

   bResult  = false

   set oLocator = CreateObject("WbemScripting.SWbemLocator")

   if Err = kErrorSuccess then

      set oService = oLocator.ConnectServer(strServer, strNameSpace, strUser, strPassword)

      if Err = kErrorSuccess then

          bResult = true

          oService.Security_.impersonationlevel = 3

          '
          ' Required to perform administrative tasks on the spooler service
          '
          oService.Security_.Privileges.AddAsString "SeLoadDriverPrivilege"

          Err.Clear

      else

          wscript.echo L_Text_Msg_General10_Text & L_Space_Text & L_Error_Text _
                       & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                       & Err.Description

      end if

   else

       wscript.echo L_Text_Msg_General09_Text & L_Space_Text & L_Error_Text _
                    & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                    & Err.Description

   end if

   WmiConnect = bResult

end function

'
' Remove leading "\\" from server name
'
function RemoveBackslashes(strServer)

    dim strRet

    strRet = strServer

    if Left(strServer, 2) = "\\" and Len(strServer) > 2 then

        strRet = Mid(strServer, 3)

    end if

    RemoveBackslashes = strRet

end function

'' SIG '' Begin signature block
'' SIG '' MIIlZgYJKoZIhvcNAQcCoIIlVzCCJVMCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' JP2OI/dGh8Dr4i1IHJc1kEljUqgI55azox+O936+ZZqg
'' SIG '' ggrhMIIFAjCCA+qgAwIBAgITMwAAAztlX67623Xp1gAA
'' SIG '' AAADOzANBgkqhkiG9w0BAQsFADCBhDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEuMCwGA1UEAxMlTWljcm9zb2Z0IFdpbmRv
'' SIG '' d3MgUHJvZHVjdGlvbiBQQ0EgMjAxMTAeFw0yMTA5MDIx
'' SIG '' ODIzNDFaFw0yMjA5MDExODIzNDFaMHAxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xGjAYBgNVBAMTEU1pY3Jvc29mdCBXaW5k
'' SIG '' b3dzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
'' SIG '' AQEAs0fMLkmGRLB23RrMrtMahzf8J7c5c5MCQHCYHh6a
'' SIG '' 4ZU0cLLIFr0iNuL5LMDyA+yYhao3hzqzDVRLeao5T2Ny
'' SIG '' NNnnIMldoc2WCGeSqRfwovlFsbEVT0q/jhLalxjYVEpY
'' SIG '' hmVK7FvZj7cbpTbo9umh5mSVMhvn08+yfKZPBd8bn3cW
'' SIG '' 0IweT/iSExXjc9gwEbyiTQwj5IOBZiMPCMXg7+QFAPza
'' SIG '' iQjowQWkIAJsM7DffzOS+4lSp/A9vvXWzzGMFNEvFhfQ
'' SIG '' jz2X8i7Q5d7mWruq+CO52OJHZV1MKqTFUoSByHJI5fkj
'' SIG '' zMZ060WnZt+V2pvh9YBaNXR7BdZ+JCSohETpqwIDAQAB
'' SIG '' o4IBfjCCAXowHwYDVR0lBBgwFgYKKwYBBAGCNwoDBgYI
'' SIG '' KwYBBQUHAwMwHQYDVR0OBBYEFFQvNAHaQy3TdBujh7mk
'' SIG '' 4YGuHetNMFAGA1UdEQRJMEekRTBDMSkwJwYDVQQLEyBN
'' SIG '' aWNyb3NvZnQgT3BlcmF0aW9ucyBQdWVydG8gUmljbzEW
'' SIG '' MBQGA1UEBRMNMjI5ODc5KzQ2NzU3OTAfBgNVHSMEGDAW
'' SIG '' gBSpKQI5jhbEl3jNkPmeT5rhfFWvUzBUBgNVHR8ETTBL
'' SIG '' MEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' cGtpb3BzL2NybC9NaWNXaW5Qcm9QQ0EyMDExXzIwMTEt
'' SIG '' MTAtMTkuY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEF
'' SIG '' BQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
'' SIG '' aW9wcy9jZXJ0cy9NaWNXaW5Qcm9QQ0EyMDExXzIwMTEt
'' SIG '' MTAtMTkuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcN
'' SIG '' AQELBQADggEBAGSt4A47oowWu0fKMom5sEd0GjauFG+P
'' SIG '' VWX2h+Uyf74Lin+uYopDO84j7x8ufz/VnFPubYjPK96F
'' SIG '' QDiT5L3hVT023vuaWhgDVVi3ifKhOSXgMsum/HJSf/mj
'' SIG '' /GC6DYkO95gGmZ+/Mv1c2+HQd5yd30fLkr4YFDzpmWTW
'' SIG '' pq38QoETkyjuzffrU4LChJQbKxQtq999w2pGdGcpXf76
'' SIG '' pDoSWPlRfmKBcrxTGt8cQrWtWvC8BA3QuUbU1eh/BQQq
'' SIG '' SBMakZQ3u9Jdw+aoJan8DT372rbqxj/wje2cTDJlACs9
'' SIG '' Vj4FJM16t+BDNyrmsVTV0WLmsMqCxOS4IQUVBUkf4FGQ
'' SIG '' 0r8wggXXMIIDv6ADAgECAgphB3ZWAAAAAAAIMA0GCSqG
'' SIG '' SIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw
'' SIG '' MAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
'' SIG '' ZSBBdXRob3JpdHkgMjAxMDAeFw0xMTEwMTkxODQxNDJa
'' SIG '' Fw0yNjEwMTkxODUxNDJaMIGEMQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMS4wLAYDVQQDEyVNaWNyb3NvZnQgV2luZG93cyBQ
'' SIG '' cm9kdWN0aW9uIFBDQSAyMDExMIIBIjANBgkqhkiG9w0B
'' SIG '' AQEFAAOCAQ8AMIIBCgKCAQEA3Qy7ouQuCePnxfeWabwA
'' SIG '' Ib1pMzPvrQTLVIDuBoO7xSCE2ffSi/M4sKukrS18YnkF
'' SIG '' /+NKPwQ1IHDjxOdr4JzANnXpijHdjXDl3De1dEaWKFuH
'' SIG '' YCMsv9xHpWf3USeecusHpsm5HjtTNXzl0+wnuYcc/rnJ
'' SIG '' IwlvqEaRwW6WPEHTy6M/XQJqTexpHyUoXDb//UMVCpTg
'' SIG '' GbTP38IS4sJbJ+4neDCLWyoJayKJU2AWLMBoHVO67Enz
'' SIG '' nWGMhWgJc0RdfaJUK9159xXPNV1sHCtczrycI4tvbrUm
'' SIG '' 2TYTw0/WJ665MjtBkizhx8136KpUTvdcCwSHZbRDGKiy
'' SIG '' 4G0Zd+xaJPpIAwIDAQABo4IBQzCCAT8wEAYJKwYBBAGC
'' SIG '' NxUBBAMCAQAwHQYDVR0OBBYEFKkpAjmOFsSXeM2Q+Z5P
'' SIG '' muF8Va9TMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBB
'' SIG '' MAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8G
'' SIG '' A1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYG
'' SIG '' A1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0Nl
'' SIG '' ckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQRO
'' SIG '' MEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9z
'' SIG '' b2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIw
'' SIG '' MTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQAU
'' SIG '' /HxxUaV5wm6y7zk+vDxSD24rPxATc/6oaNBIpjRNipYF
'' SIG '' Ju4xRpBhedb/OC5Fa/TA5Si42h2PitsJ1xrHTAo2ZmqM
'' SIG '' 7BvXBJCoGBekm7niQDI2dsTBWsa/5ATA6hbTrMNo72Ks
'' SIG '' 3VRsUDBYput8/pSnTo707HyGc1fCUiFzNFrzo4pWyATa
'' SIG '' Bwnt+IvjzvR+jq7w9guKCPs/yR1yf1O4675j4OM9MWWw
'' SIG '' geXyrM0WpJ89qLGbwkLQkIRfVB3/ieq6HUeQb7BzTkGf
'' SIG '' QJ9f5aEqshGRc4ohKPDO3nM5Xz6rXGDs3wMQqNMJ6fT2
'' SIG '' loW2f1GIZkcZjaKwEj2BKmgFd7uRTGJ7tsEHx7p6hzQD
'' SIG '' DktiepnpyvzOSjfJLaRXfBz+Pdy4D1r61sSzAoUCOuqz
'' SIG '' 2W7kaSE33oHR9nUZBWfTk1deKRs5yO4t4c3kRXNb0NLO
'' SIG '' eqsWGYJGWNBenYGzZ69sNfK85T8k4jWiCnUG9hhWmdR4
'' SIG '' LNEFG+vQiAGdqhDxBd+6fixjtwabIyHE+Xhs4lgXBjYr
'' SIG '' kRIDzKTZ8i26+ZSdQO0YRfHOilxrPqsD03AYKgpq4F9H
'' SIG '' 0dVjCjLyr9c2HypwWuVCWQhxS1e6foOB8CE89BzBxbmQ
'' SIG '' kw6IRZOG6bEgmb6Yy8WVpF1i1qBjCCC9dRB3fT3zRbmf
'' SIG '' l5/LV4BvM6kEz3ekYhxZfjGCGd0wghnZAgEBMIGcMIGE
'' SIG '' MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
'' SIG '' bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
'' SIG '' cm9zb2Z0IENvcnBvcmF0aW9uMS4wLAYDVQQDEyVNaWNy
'' SIG '' b3NvZnQgV2luZG93cyBQcm9kdWN0aW9uIFBDQSAyMDEx
'' SIG '' AhMzAAADO2VfrvrbdenWAAAAAAM7MA0GCWCGSAFlAwQC
'' SIG '' AQUAoIIBBDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
'' SIG '' BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
'' SIG '' BgkqhkiG9w0BCQQxIgQgoHcpO+Mc7CMnH+Gft3DbkYb1
'' SIG '' lVjfqUe4eHB2V3ES4jEwPAYKKwYBBAGCNwoDHDEuDCxu
'' SIG '' YmxyOTUxbElzNFl5bWpVa1lHU0pMWkZVMFE3cWZONVRX
'' SIG '' aGRIcUxwRFA0PTBaBgorBgEEAYI3AgEMMUwwSqAkgCIA
'' SIG '' TQBpAGMAcgBvAHMAbwBmAHQAIABXAGkAbgBkAG8AdwBz
'' SIG '' oSKAIGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS93aW5k
'' SIG '' b3dzMA0GCSqGSIb3DQEBAQUABIIBAAu/EGboXrapVZOt
'' SIG '' 5CZtpN/6MZMo5/mA+FIv6FXoCr/S7A+lCqMKt1quBEnP
'' SIG '' s7JhR9qw3GABMg4YVy84VYQ+vgkQBd+rz5hPyEYxfTO2
'' SIG '' TiYpLvql2qZ0cja0uLQpcSMougQZX8n2FwfWFmL0VjrY
'' SIG '' Sqv+6Ui1bKo37r9xmToZIHrN3KUyWIl+vFGw9tWDtm72
'' SIG '' k15vGYP6ba6wMtq0IegJTObyytT7c4i/tJqkZurGu+QJ
'' SIG '' e7+zZ0mVW0LryFN/B3q7Pbcc8BfYmrNHapXtqwEG4sZf
'' SIG '' hdjXACX5f9trROQUzdVNwHJ6K93nDw97IuBVHwZiA3W6
'' SIG '' iRmzkduNEUFPFEUHBnqhghcJMIIXBQYKKwYBBAGCNwMD
'' SIG '' ATGCFvUwghbxBgkqhkiG9w0BBwKgghbiMIIW3gIBAzEP
'' SIG '' MA0GCWCGSAFlAwQCAQUAMIIBVQYLKoZIhvcNAQkQAQSg
'' SIG '' ggFEBIIBQDCCATwCAQEGCisGAQQBhFkKAwEwMTANBglg
'' SIG '' hkgBZQMEAgEFAAQgfLzxa4hLNwBTw0j/HCN2z6E6+YTW
'' SIG '' dNsFzmKJy1OfUAYCBmJrR5JwTxgTMjAyMjA1MDcwMjIw
'' SIG '' NTYuMzI0WjAEgAIB9KCB1KSB0TCBzjELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEpMCcGA1UECxMgTWljcm9zb2Z0IE9wZXJh
'' SIG '' dGlvbnMgUHVlcnRvIFJpY28xJjAkBgNVBAsTHVRoYWxl
'' SIG '' cyBUU1MgRVNOOkY3QTYtRTI1MS0xNTBBMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIR
'' SIG '' XDCCBxAwggT4oAMCAQICEzMAAAGlAN4IxEAHcU4AAQAA
'' SIG '' AaUwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMx
'' SIG '' EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
'' SIG '' ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
'' SIG '' dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
'' SIG '' bXAgUENBIDIwMTAwHhcNMjIwMzAyMTg1MTE5WhcNMjMw
'' SIG '' NTExMTg1MTE5WjCBzjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEp
'' SIG '' MCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVl
'' SIG '' cnRvIFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNO
'' SIG '' OkY3QTYtRTI1MS0xNTBBMSUwIwYDVQQDExxNaWNyb3Nv
'' SIG '' ZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG
'' SIG '' 9w0BAQEFAAOCAg8AMIICCgKCAgEAurGG6CBqSLzC6g4w
'' SIG '' x3uuwRCeYCG1XyJTVjSK2werfRN0JckOa9mNpnzK84dg
'' SIG '' VWFPIPVvkkYm3BmNbPV+CUKqzHmoHE/VbHUJmexDW2JG
'' SIG '' xFZBzXZWQROaRjzHjoyAewbICaE8+myBGeSUZqLsepAU
'' SIG '' HfXH9COTHutsCWvo9uUHi06ZpHWcrGXhUiCy0PB+d4pq
'' SIG '' gQTDiI3/FN3O1mPDIaJjmE2npt562RyLOAkU7f/JEdiH
'' SIG '' SC2T5tESGuYiBtquuuBvPsyycDu2Uq8Zw72Idzr7azKa
'' SIG '' sBXLcLNDggw08VxNPHzBNn6Sm/qUWzV4bzGV+y7Y0NYq
'' SIG '' yGsyUofYmljNYBbV8I4PmKtewTgs6+LFlC9ud5ATr6IZ
'' SIG '' 8hDBpuP59F2i4BTYCIT6Jo2wgNql0ppvxYvHPpU9FsQv
'' SIG '' 4zowWRyyiK4oceiyEKnsmGZn2IzTKsTHZd5s6Fr9dDfj
'' SIG '' YqxEazaHTaClfrAHLJPx4PcwlUjFJGbgwsiKW9Zyl303
'' SIG '' euihrBstTqB2TuCgpZLr37DaO2i5cIRi3og99mryV2LQ
'' SIG '' v8LBhu2/uZseYhn05zQkQlzpv2BxUN+g+J6YwpzPXkEt
'' SIG '' 6nLHuelDYyIMoixw6oqFe5kj49l6s04eGL++zLb8WP2U
'' SIG '' HqQmsxhJ9XQXZ+u8FIFcwHvGO/ymCpflBdR7ydPFvhR8
'' SIG '' nRwMC8ECAwEAAaOCATYwggEyMB0GA1UdDgQWBBRfpo8D
'' SIG '' AJeurq1w7vvcWRdLaKka3zAfBgNVHSMEGDAWgBSfpxVd
'' SIG '' AF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQ
'' SIG '' hk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
'' SIG '' L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
'' SIG '' JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwG
'' SIG '' CCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
'' SIG '' b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUt
'' SIG '' U3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMB
'' SIG '' Af8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4ICAQCWmwsX5TAwooRHanRYmejgboYY
'' SIG '' ad+DeqMN1odzm69di0boqYeuoB/9ioeSY2i1KvpkQSeU
'' SIG '' YIlhHtbe4n7lum+PTfAWoZ5+9CwohHb6rpOvOjO8/g2y
'' SIG '' h1ZNPlJWn8LpMQMa4sL2Y5AoDi3IvjQdNbu3FvRwB1+C
'' SIG '' fIcWgj8Gxmj8Vpd7NDyE7jFSOEOnI014npZi9fk0L4e/
'' SIG '' 2eZPLOOrISD8vZxcA6bERa988BDWV/G+u1TAbvmMZ5Rp
'' SIG '' 7CSHC3NqcKc/eXpiPAkUoHqfv9Ne2t+KTXFjWSB6/UnB
'' SIG '' DlpR0/HBJ0OYYThdM3azqk86Lwg7X305/oAS+HjV4PFH
'' SIG '' P7XVVRym4afu0lR5JNRIey/NDwQI6PnDvsy/nn8XyFa7
'' SIG '' Tt6CcbxKtaPn5MXE08KnH8AU2/PP6h1NFNl3gta6iZww
'' SIG '' dSYsWJQY4B160XpKh8cbkRwWfQNMPVqkFnMI/zGwZBxm
'' SIG '' DBWqjui/bf+4gmUwIsDJNhlX0hMI/T1yJQlsoFUJA2sY
'' SIG '' SdD9csU72bKzLINGu8eFTm4Y91fPgm3b9k3slBhG5U1K
'' SIG '' 4Kk3CgrQmvWzpyIO8cR4vKJzPGgh70YfdLJ9sfHq/+mE
'' SIG '' j6ITcNajVMIrvkQvqm3qTmLfr+Sfa5JVd1MfjhlWSHf+
'' SIG '' KFXe8TCzvy4aW+yIxysoGCmjcd1yMMeIehaxR/gYjDCC
'' SIG '' B3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUw
'' SIG '' DQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMw
'' SIG '' EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
'' SIG '' b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
'' SIG '' b24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRp
'' SIG '' ZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4
'' SIG '' MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUA
'' SIG '' A4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC
'' SIG '' 0/3unAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm
'' SIG '' 95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNE
'' SIG '' t6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZT
'' SIG '' fDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBbfowQ
'' SIG '' HJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5
'' SIG '' LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVV
'' SIG '' mG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKy
'' SIG '' zbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpG
'' SIG '' dc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2
'' SIG '' TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZ
'' SIG '' fD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
'' SIG '' GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
'' SIG '' W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLU
'' SIG '' HMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXb
'' SIG '' GjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQID
'' SIG '' AQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAj
'' SIG '' BgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8v
'' SIG '' BO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1Gely
'' SIG '' MFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYI
'' SIG '' KwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNv
'' SIG '' bS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNV
'' SIG '' HSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4K
'' SIG '' AFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/
'' SIG '' BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2U
'' SIG '' kFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8v
'' SIG '' Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
'' SIG '' cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
'' SIG '' KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
'' SIG '' d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jv
'' SIG '' b0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0B
'' SIG '' AQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwU
'' SIG '' tj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTC
'' SIG '' j/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+
'' SIG '' iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhT
'' SIG '' dSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYS
'' SIG '' EhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefwC2qB
'' SIG '' woEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0
'' SIG '' DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxy
'' SIG '' bxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFORy3BFARx
'' SIG '' v2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+k
'' SIG '' KNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2
'' SIG '' tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4
'' SIG '' O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
'' SIG '' jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
'' SIG '' dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/Z
'' SIG '' cGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLPMIIC
'' SIG '' OAIBATCB/KGB1KSB0TCBzjELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEpMCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMg
'' SIG '' UHVlcnRvIFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
'' SIG '' RVNOOkY3QTYtRTI1MS0xNTBBMSUwIwYDVQQDExxNaWNy
'' SIG '' b3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYF
'' SIG '' Kw4DAhoDFQCzyXDbRbObEMqI3UuGHuZlZe60qKCBgzCB
'' SIG '' gKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
'' SIG '' aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
'' SIG '' ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
'' SIG '' HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0G
'' SIG '' CSqGSIb3DQEBBQUAAgUA5h+pCzAiGA8yMDIyMDUwNjE4
'' SIG '' MDI1MVoYDzIwMjIwNTA3MTgwMjUxWjB0MDoGCisGAQQB
'' SIG '' hFkKBAExLDAqMAoCBQDmH6kLAgEAMAcCAQACAg2OMAcC
'' SIG '' AQACAhHAMAoCBQDmIPqLAgEAMDYGCisGAQQBhFkKBAIx
'' SIG '' KDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAI
'' SIG '' AgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAYQid+nme
'' SIG '' ARpMGVVfm1J2Fs3NAeTUkzd8Ezq/H8cTA2v2sfxZtTSA
'' SIG '' oRrpANc9ZQN6U/e83YFSoUjUxpBd6ufO/UiwhiWOxqtp
'' SIG '' FDejW+XUp62X+zcQtJcLZHd8/VyuNgqKRZ2Dj5RQ9Azh
'' SIG '' TaZS3qsJ5kgQJFXMcs3zfa5LZQlTkd0xggQNMIIECQIB
'' SIG '' ATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAaUA3gjEQAdxTgABAAABpTANBglghkgBZQMEAgEF
'' SIG '' AKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
'' SIG '' MC8GCSqGSIb3DQEJBDEiBCA52RyYrVaOijU5GERIiZOR
'' SIG '' v5lqFqcNk6ta0Emij5JtnzCB+gYLKoZIhvcNAQkQAi8x
'' SIG '' geowgecwgeQwgb0EILgKOHF+ZgSxoK3YBTzcqGH7okeX
'' SIG '' KTcHvS98wcyUEtxcMIGYMIGApH4wfDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgUENBIDIwMTACEzMAAAGlAN4IxEAHcU4AAQAA
'' SIG '' AaUwIgQgGBbYfD6VF/RCW1pksxKs85qFsEjdHhSgkRHf
'' SIG '' iNlJoK0wDQYJKoZIhvcNAQELBQAEggIAjbtxmLiTfP4C
'' SIG '' 8irQGPwVo1VxjruXGASnwOas6vOVLWme/weQmBTdPMkt
'' SIG '' fmA5PWmVeHPy22Gwu89fYb9DBxRSBZHM+oM1NOuWtDPD
'' SIG '' JUQ9Hw4nvbk0GHvyvUVY277r/4LHCHk0RXQxvTIuPLzV
'' SIG '' CNjgINAj/VSEdDuxIwOLbeqHnmtlSc7BU9+I+vMRhKE5
'' SIG '' OMXtNv7THgTNUMVoOMQKVsrDmNLABrnwZyGrZuRDa5rZ
'' SIG '' D4DL2P5jf4tHr7VpwG8WNVUsYKegnKQLyCEMiKf3GshK
'' SIG '' d7ZRL/Eymx9pJokO3VF6eMunFOX2RPVjkOeFtl0glAJ7
'' SIG '' L1AghZmAnPCc1WxoWQsP472rxryLosLPp7SwDLTvTjAK
'' SIG '' 1IJcp37mtHf3OrtvrEAjQnPPVczEJzVM0VIvqgEmdYFB
'' SIG '' SjqI1jyAWiHNLNzet5JRV4c5f4zXaLdUh+mgBT4lnUBH
'' SIG '' Fm0WKH4H1YeQOwsyOYOZ3MNtQRG+69Ez+u/pcvWxDP2g
'' SIG '' Fh1/+HtsXYYtsIksgMOUEcFjRElZJvfKuxrjEOpcptcM
'' SIG '' pJQjXXPRD8vD4dUjhFRfXZxDDsb0eDuTrBtfrUoKuruu
'' SIG '' hT9PTKPKDxR/sA+fxzgnf2GroTLoxNP9e+5HE4iBp1GP
'' SIG '' lnJu5eYyl6pFsF3tEoxV6r9GtM09GDrYqiEQNGkDZ9Ym
'' SIG '' gJhfpS4yggo=
'' SIG '' End signature block
