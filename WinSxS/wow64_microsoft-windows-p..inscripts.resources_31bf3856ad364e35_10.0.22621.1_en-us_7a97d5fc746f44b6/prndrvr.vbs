'----------------------------------------------------------------------
'
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Abstract:
' prndrvr.vbs - driver script for WMI on Windows 
'     used to add, delete, and list drivers.
'
' Usage:
' prndrvr [-adlx?] [-m model][-v version][-e environment][-s server]
'         [-u user name][-w password][-h file path][-i inf file]
'
' Example:
' prndrvr -a -m "driver" -v 3 -e "Windows NT x86"
' prndrvr -d -m "driver" -v 3 -e "Windows x64"
' prndrvr -d -m "driver" -v 3 -e "Windows IA64"
' prndrvr -x -s server
' prndrvr -l -s server
'
'----------------------------------------------------------------------

option explicit

'
' Debugging trace flags, to enable debug output trace message
' change gDebugFlag to true.
'
const kDebugTrace = 1
const kDebugError = 2
dim gDebugFlag

gDebugFlag = false

'
' Operation action values.
'
const kActionUnknown    = 0
const kActionAdd        = 1
const kActionDel        = 2
const kActionDelAll     = 3
const kActionList       = 4

const kErrorSuccess     = 0
const kErrorFailure     = 1

const kNameSpace        = "root\cimv2"

'
' Generic strings
'
const L_Empty_Text                 = ""
const L_Space_Text                 = " "
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
const L_Help_Help_General01_Text   = "Usage: prndrvr [-adlx?] [-m model][-v version][-e environment][-s server]"
const L_Help_Help_General02_Text   = "               [-u user name][-w password][-h path][-i inf file]"
const L_Help_Help_General03_Text   = "Arguments:"
const L_Help_Help_General04_Text   = "-a     - add the specified driver"
const L_Help_Help_General05_Text   = "-d     - delete the specified driver"
const L_Help_Help_General06_Text   = "-e     - environment  ""Windows {NT x86 | X64 | IA64}"""
const L_Help_Help_General07_Text   = "-h     - driver file path"
const L_Help_Help_General08_Text   = "-i     - fully qualified inf file name"
const L_Help_Help_General09_Text   = "-l     - list all drivers"
const L_Help_Help_General10_Text   = "-m     - driver model name"
const L_Help_Help_General11_Text   = "-s     - server name"
const L_Help_Help_General12_Text   = "-u     - user name"
const L_Help_Help_General13_Text   = "-v     - version"
const L_Help_Help_General14_Text   = "-w     - password"
const L_Help_Help_General15_Text   = "-x     - delete all drivers that are not in use"
const L_Help_Help_General16_Text   = "-?     - display command usage"
const L_Help_Help_General17_Text   = "Examples:"
const L_Help_Help_General18_Text   = "prndrvr -a -m ""driver"" -v 3 -e ""Windows NT x86"""
const L_Help_Help_General19_Text   = "prndrvr -d -m ""driver"" -v 3 -e ""Windows x64"""
const L_Help_Help_General20_Text   = "prndrvr -a -m ""driver"" -v 3 -e ""Windows IA64"" -i c:\temp\drv\drv.inf -h c:\temp\drv"
const L_Help_Help_General21_Text   = "prndrvr -l -s server"
const L_Help_Help_General22_Text   = "prndrvr -x -s server"
const L_Help_Help_General23_Text   = "Remarks:"
const L_Help_Help_General24_Text   = "The inf file name must be fully qualified. If the inf name is not specified, the script uses"
const L_Help_Help_General25_Text   = "one of the inbox printer inf files in the inf subdirectory of the Windows directory."
const L_Help_Help_General26_Text   = "If the driver path is not specified, the script searches for driver files in the driver.cab file."
const L_Help_Help_General27_Text   = "The -x option deletes all additional printer drivers (drivers installed for use on clients running"
const L_Help_Help_General28_Text   = "alternate versions of Windows), even if the primary driver is in use. If the fax component is installed,"
const L_Help_Help_General29_Text   = "this option deletes any additional fax drivers. The primary fax driver is also deleted if it is not"
const L_Help_Help_General30_Text   = "in use (i.e. if there is no queue using it). If the primary fax driver is deleted, the only way to"
const L_Help_Help_General31_Text   = "re-enable fax is to reinstall the fax component."

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
const L_Text_Msg_General01_Text    = "Added printer driver"
const L_Text_Msg_General02_Text    = "Unable to add printer driver"
const L_Text_Msg_General03_Text    = "Unable to delete printer driver"
const L_Text_Msg_General04_Text    = "Deleted printer driver"
const L_Text_Msg_General05_Text    = "Unable to enumerate printer drivers"
const L_Text_Msg_General06_Text    = "Number of printer drivers enumerated"
const L_Text_Msg_General07_Text    = "Number of printer drivers deleted"
const L_Text_Msg_General08_Text    = "Attempting to delete printer driver"
const L_Text_Msg_General09_Text    = "Unable to list dependent files"
const L_Text_Msg_General10_Text    = "Unable to get SWbemLocator object"
const L_Text_Msg_General11_Text    = "Unable to connect to WMI service"


'
' Printer driver properties
'
const L_Text_Msg_Driver01_Text     = "Server name"
const L_Text_Msg_Driver02_Text     = "Driver name"
const L_Text_Msg_Driver03_Text     = "Version"
const L_Text_Msg_Driver04_Text     = "Environment"
const L_Text_Msg_Driver05_Text     = "Monitor name"
const L_Text_Msg_Driver06_Text     = "Driver path"
const L_Text_Msg_Driver07_Text     = "Data file"
const L_Text_Msg_Driver08_Text     = "Config file"
const L_Text_Msg_Driver09_Text     = "Help file"
const L_Text_Msg_Driver10_Text     = "Dependent files"

'
' Debug messages
'
const L_Text_Dbg_Msg01_Text        = "In function AddDriver"
const L_Text_Dbg_Msg02_Text        = "In function DelDriver"
const L_Text_Dbg_Msg03_Text        = "In function DelAllDrivers"
const L_Text_Dbg_Msg04_Text        = "In function ListDrivers"
const L_Text_Dbg_Msg05_Text        = "In function ParseCommandLine"

main

'
' Main execution starts here
'
sub main

    dim iAction
    dim iRetval
    dim strServer
    dim strModel
    dim strPath
    dim uVersion
    dim strEnvironment
    dim strInfFile
    dim strUser
    dim strPassword

    '
    ' Abort if the host is not cscript
    '
    if not IsHostCscript() then

        call wscript.echo(L_Help_Help_Host01_Text & vbCRLF & L_Help_Help_Host02_Text & vbCRLF & _
                          L_Help_Help_Host03_Text & vbCRLF & L_Help_Help_Host04_Text & vbCRLF & _
                          L_Help_Help_Host05_Text & vbCRLF & L_Help_Help_Host06_Text & vbCRLF)

        wscript.quit

    end if

    '
    ' Get command line parameters
    '
    iRetval = ParseCommandLine(iAction, strServer, strModel, strPath, uVersion, _
                               strEnvironment, strInfFile, strUser, strPAssword)

    if iRetval = kErrorSuccess  then

        select case iAction

            case kActionAdd
                iRetval = AddDriver(strServer, strModel, strPath, uVersion, _
                                    strEnvironment, strInfFile, strUser, strPassword)

            case kActionDel
                iRetval = DelDriver(strServer, strModel, uVersion, strEnvironment, strUser, strPassword)

            case kActionDelAll
                iRetval = DelAllDrivers(strServer, strUser, strPassword)

            case kActionList
                iRetval = ListDrivers(strServer, strUser, strPassword)

            case kActionUnknown
                Usage(true)
                exit sub

            case else
                Usage(true)
                exit sub

        end select

    end if

end sub

'
' Add a driver
'
function AddDriver(strServer, strModel, strFilePath, uVersion, strEnvironment, strInfFile, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text

    dim oDriver
    dim oService
    dim iResult
    dim uResult

    '
    ' Initialize return value
    '
    iResult = kErrorFailure

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oDriver = oService.Get("Win32_PrinterDriver")

    else

        AddDriver = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        oDriver.Name              = strModel
        oDriver.SupportedPlatform = strEnvironment
        oDriver.Version           = uVersion
        oDriver.FilePath          = strFilePath
        oDriver.InfName           = strInfFile

        uResult = oDriver.AddPrinterDriver(oDriver)

        if Err.Number = kErrorSuccess then

            if uResult = kErrorSuccess then

                wscript.echo L_Text_Msg_General01_Text & L_Space_Text & oDriver.Name

                iResult = kErrorSuccess

            else

                wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                             & L_Text_Error_General03_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strModel & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

    end if

    AddDriver = iResult

end function

'
' Delete a driver
'
function DelDriver(strServer, strModel, uVersion, strEnvironment, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text

    dim oDriver
    dim oService
    dim iResult
    dim strObject

    '
    ' Initialize return value
    '
    iResult = kErrorFailure

    '
    ' Build the key that identifies the driver instance.
    '
    strObject = strModel & "," & CStr(uVersion) & "," & strEnvironment

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oDriver = oService.Get("Win32_PrinterDriver.Name='" & strObject & "'")

    else

        DelDriver = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        '
        ' Delete the printer driver instance
        '
        oDriver.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oDriver.Name

            iResult = kErrorSuccess

        else

            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strModel & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                         & L_Space_Text & Err.Description

            call LastError()

        end if

    else

        wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strModel & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                     & L_Space_Text & Err.Description

    end if

    DelDriver = iResult

end function

'
' Delete all drivers
'
function DelAllDrivers(strServer, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text

    dim Drivers
    dim oDriver
    dim oService
    dim iResult
    dim iTotal
    dim iTotalDeleted
    dim vntDependentFiles
    dim strDriverName

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Drivers = oService.InstancesOf("Win32_PrinterDriver")

    else

        DelAllDrivers = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        DelAllDrivers = kErrorFailure

        exit function

    end if

    iTotal = 0
    iTotalDeleted = 0

    for each oDriver in Drivers

        iTotal = iTotal + 1

        wscript.echo
        wscript.echo L_Text_Msg_General08_Text
        wscript.echo L_Text_Msg_Driver01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Driver02_Text & L_Space_Text & oDriver.Name
        wscript.echo L_Text_Msg_Driver03_Text & L_Space_Text & oDriver.Version
        wscript.echo L_Text_Msg_Driver04_Text & L_Space_Text & oDriver.SupportedPlatform

        strDriverName = oDriver.Name

        '
        ' Example of how to delete an instance of a printer driver
        '
        oDriver.Delete_

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oDriver.Name

            iTotalDeleted = iTotalDeleted + 1

        else

            '
            ' We cannot use oDriver.Name to display the driver name, because the SWbemLastError
            ' that the function LastError() looks at would be overwritten. For that reason we
            ' use strDriverName for accessing the driver name
            '
            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strDriverName & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) _
                         & L_Space_Text & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

            Err.Clear

        end if

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General06_Text & L_Space_Text & iTotal
    wscript.echo L_Text_Msg_General07_Text & L_Space_Text & iTotalDeleted

    DelAllDrivers = kErrorSuccess

end function

'
' List drivers
'
function ListDrivers(strServer, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text

    dim Drivers
    dim oDriver
    dim oService
    dim iResult
    dim iTotal
    dim vntDependentFiles

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Drivers = oService.InstancesOf("Win32_PrinterDriver")

    else

        ListDrivers = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        ListDrivers = kErrorFailure

        exit function

    end if

    iTotal = 0

    for each oDriver in Drivers

        iTotal = iTotal + 1

        wscript.echo
        wscript.echo L_Text_Msg_Driver01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Driver02_Text & L_Space_Text & oDriver.Name
        wscript.echo L_Text_Msg_Driver03_Text & L_Space_Text & oDriver.Version
        wscript.echo L_Text_Msg_Driver04_Text & L_Space_Text & oDriver.SupportedPlatform
        wscript.echo L_Text_Msg_Driver05_Text & L_Space_Text & oDriver.MonitorName
        wscript.echo L_Text_Msg_Driver06_Text & L_Space_Text & oDriver.DriverPath
        wscript.echo L_Text_Msg_Driver07_Text & L_Space_Text & oDriver.DataFile
        wscript.echo L_Text_Msg_Driver08_Text & L_Space_Text & oDriver.ConfigFile
        wscript.echo L_Text_Msg_Driver09_Text & L_Space_Text & oDriver.HelpFile

        vntDependentFiles = oDriver.DependentFiles

        '
        ' If there are no dependent files, the method will set DependentFiles to
        ' an empty variant, so we check if the variant is an array of variants
        '
        if VarType(vntDependentFiles) = (vbArray + vbVariant) then

            PrintDepFiles oDriver.DependentFiles

        end if

        Err.Clear

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General06_Text & L_Space_Text & iTotal

    ListDrivers = kErrorSuccess

end function

'
' Prints the contents of an array of variants
'
sub PrintDepFiles(Param)

   on error resume next

   dim iIndex

   iIndex = LBound(Param)

   if Err.Number = 0 then

      wscript.echo L_Text_Msg_Driver10_Text

      for iIndex = LBound(Param) to UBound(Param)

          wscript.echo L_Space_Text & Param(iIndex)

      next

   else

        wscript.echo L_Text_Msg_General09_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

   end if

end sub

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
function ParseCommandLine(iAction, strServer, strModel, strPath, uVersion, _
                          strEnvironment, strInfFile, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg05_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown
    iIndex = 0

    set oArgs = wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-a"
                iAction = kActionAdd

            case "-d"
                iAction = kActionDel

            case "-l"
                iAction = kActionList

            case "-x"
                iAction = kActionDelAll

            case "-s"
                iIndex = iIndex + 1
                strServer = RemoveBackslashes(oArgs(iIndex))

            case "-m"
                iIndex = iIndex + 1
                strModel = oArgs(iIndex)

            case "-h"
                iIndex = iIndex + 1
                strPath = oArgs(iIndex)

            case "-v"
                iIndex = iIndex + 1
                uVersion = oArgs(iIndex)

            case "-e"
                iIndex = iIndex + 1
                strEnvironment = oArgs(iIndex)

            case "-i"
                iIndex = iIndex + 1
                strInfFile = oArgs(iIndex)

            case "-u"
                iIndex = iIndex + 1
                strUser = oArgs(iIndex)

            case "-w"
                iIndex = iIndex + 1
                strPassword = oArgs(iIndex)

            case "-?"
                Usage(true)
                exit function

            case else
                Usage(true)
                exit function

        end select

        iIndex = iIndex + 1

    wend

    if Err.Number <> 0 then

        wscript.echo L_Text_Error_General02_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_text & Err.Description

        ParseCommandLine = kErrorFailure

    else

        ParseCommandLine = kErrorSuccess

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
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General17_Text
    wscript.echo L_Help_Help_General18_Text
    wscript.echo L_Help_Help_General19_Text
    wscript.echo L_Help_Help_General20_Text
    wscript.echo L_Help_Help_General21_Text
    wscript.echo L_Help_Help_General22_Text
    wscript.echo L_Help_Help_General23_Text
    wscript.echo L_Help_Help_General24_Text
    wscript.echo L_Help_Help_General25_Text
    wscript.echo L_Help_Help_General26_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General27_Text
    wscript.echo L_Help_Help_General28_Text
    wscript.echo L_Help_Help_General29_Text
    wscript.echo L_Help_Help_General30_Text
    wscript.echo L_Help_Help_General31_Text

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
        wscript.echo L_Text_Error_General03_Text & L_Space_Text & oError.StatusCode

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

            wscript.echo L_Text_Msg_General11_Text & L_Space_Text & L_Error_Text _
                         & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General10_Text & L_Space_Text & L_Error_Text _
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
'' SIG '' MIIldwYJKoZIhvcNAQcCoIIlaDCCJWQCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' mlUP3KOnaFb8M6G5M6AlnOFVzMN6IRQb2eB8kdGCjCig
'' SIG '' ggrlMIIFBjCCA+6gAwIBAgITMwAAAzyJxmp7RbsfvQAA
'' SIG '' AAADPDANBgkqhkiG9w0BAQsFADCBhDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEuMCwGA1UEAxMlTWljcm9zb2Z0IFdpbmRv
'' SIG '' d3MgUHJvZHVjdGlvbiBQQ0EgMjAxMTAeFw0yMTA5MDIx
'' SIG '' ODIzNDFaFw0yMjA5MDExODIzNDFaMHAxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xGjAYBgNVBAMTEU1pY3Jvc29mdCBXaW5k
'' SIG '' b3dzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKC
'' SIG '' AQEA0C1bs/cyz18F/sjVyPtMJbiPDuv1On88IsAkc4XN
'' SIG '' wCCSU2Tl+IdwjuJqz8f2Ma1JA4mldik+l51VmqKr6qxi
'' SIG '' /ukVtavRqYBr9TFs0WjoZttLvhiRlrARwfbQPOIIzZC0
'' SIG '' pq6BNTO1bN+njWBw1cNH9WBcW5NxuaV5wIZHbMWqvVPm
'' SIG '' ny0xc/MRoeg4FduG+luu/YjloRJs3V6otzGisFhy/n6k
'' SIG '' p6oMuAWSVaR7nzIvHVqL99A6biayntOfKnuJNut8HzCa
'' SIG '' cJGs/l0L/PB2rhIEJ1EpJYJaQXb7h/ZtE7/bebokdWnn
'' SIG '' shxUOvnGAteaCLVchlfIUr6aJVJToNeeGvgebwIDAQAB
'' SIG '' o4IBgjCCAX4wHwYDVR0lBBgwFgYKKwYBBAGCNwoDBgYI
'' SIG '' KwYBBQUHAwMwHQYDVR0OBBYEFEiFOkMS40DUq3mPeNLS
'' SIG '' ifgdMnk4MFQGA1UdEQRNMEukSTBHMS0wKwYDVQQLEyRN
'' SIG '' aWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0
'' SIG '' ZWQxFjAUBgNVBAUTDTIyOTg3OSs0Njc1ODAwHwYDVR0j
'' SIG '' BBgwFoAUqSkCOY4WxJd4zZD5nk+a4XxVr1MwVAYDVR0f
'' SIG '' BE0wSzBJoEegRYZDaHR0cDovL3d3dy5taWNyb3NvZnQu
'' SIG '' Y29tL3BraW9wcy9jcmwvTWljV2luUHJvUENBMjAxMV8y
'' SIG '' MDExLTEwLTE5LmNybDBhBggrBgEFBQcBAQRVMFMwUQYI
'' SIG '' KwYBBQUHMAKGRWh0dHA6Ly93d3cubWljcm9zb2Z0LmNv
'' SIG '' bS9wa2lvcHMvY2VydHMvTWljV2luUHJvUENBMjAxMV8y
'' SIG '' MDExLTEwLTE5LmNydDAMBgNVHRMBAf8EAjAAMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4IBAQBpkEV0LEA4Et4b356iviITLoKn
'' SIG '' wAarJ44Mn0YL1DU4Y0gDGmtcvfRQrlokMzHcssx+rOg3
'' SIG '' HPcew1pvZjFHvSEeo1dhTmphHurMpkhqd41M14gQat4S
'' SIG '' 1mJVdOeonsq06wu5kpXEmN1fVlaAotJr8lRecnxCBAI8
'' SIG '' SNgCG2CP2QHG/v0Wzgw6Zp+wznWNxnHyzddDTBY/nelF
'' SIG '' PlUj2Up4IFyCikYV5QMw2fUqinf3aD0rYf8TJDgtQNMQ
'' SIG '' AcUYtWsob7uMdU9pQFkMIHE4XtCpOHtSnAa/cf/4nHRj
'' SIG '' RVD8Mxs4nVWGlqzgV4cUTlr1PSCnWoSYG/g4DdrDdD9A
'' SIG '' fY/yfAieMIIF1zCCA7+gAwIBAgIKYQd2VgAAAAAACDAN
'' SIG '' BgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
'' SIG '' aWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTExMDE5MTg0
'' SIG '' MTQyWhcNMjYxMDE5MTg1MTQyWjCBhDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEuMCwGA1UEAxMlTWljcm9zb2Z0IFdpbmRv
'' SIG '' d3MgUHJvZHVjdGlvbiBQQ0EgMjAxMTCCASIwDQYJKoZI
'' SIG '' hvcNAQEBBQADggEPADCCAQoCggEBAN0Mu6LkLgnj58X3
'' SIG '' lmm8ACG9aTMz760Ey1SA7gaDu8UghNn30ovzOLCrpK0t
'' SIG '' fGJ5Bf/jSj8ENSBw48Tna+CcwDZ16Yox3Y1w5dw3tXRG
'' SIG '' lihbh2AjLL/cR6Vn91EnnnLrB6bJuR47UzV85dPsJ7mH
'' SIG '' HP65ySMJb6hGkcFuljxB08ujP10Cak3saR8lKFw2//1D
'' SIG '' FQqU4Bm0z9/CEuLCWyfuJ3gwi1sqCWsiiVNgFizAaB1T
'' SIG '' uuxJ851hjIVoCXNEXX2iVCvdefcVzzVdbBwrXM68nCOL
'' SIG '' b261Jtk2E8NP1ieuuTI7QZIs4cfNd+iqVE73XAsEh2W0
'' SIG '' QxiosuBtGXfsWiT6SAMCAwEAAaOCAUMwggE/MBAGCSsG
'' SIG '' AQQBgjcVAQQDAgEAMB0GA1UdDgQWBBSpKQI5jhbEl3jN
'' SIG '' kPmeT5rhfFWvUzAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
'' SIG '' AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB
'' SIG '' /zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoY
'' SIG '' xDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1p
'' SIG '' Y3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNS
'' SIG '' b29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUH
'' SIG '' AQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1p
'' SIG '' Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1
'' SIG '' dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsFAAOC
'' SIG '' AgEAFPx8cVGlecJusu85Prw8Ug9uKz8QE3P+qGjQSKY0
'' SIG '' TYqWBSbuMUaQYXnW/zguRWv0wOUouNodj4rbCdcax0wK
'' SIG '' NmZqjOwb1wSQqBgXpJu54kAyNnbEwVrGv+QEwOoW06zD
'' SIG '' aO9irN1UbFAwWKbrfP6Up06O9Ox8hnNXwlIhczRa86OK
'' SIG '' VsgE2gcJ7fiL4870fo6u8PYLigj7P8kdcn9TuOu+Y+Dj
'' SIG '' PTFlsIHl8qzNFqSfPaixm8JC0JCEX1Qd/4nquh1HkG+w
'' SIG '' c05Bn0CfX+WhKrIRkXOKISjwzt5zOV8+q1xg7N8DEKjT
'' SIG '' Cen09paFtn9RiGZHGY2isBI9gSpoBXe7kUxie7bBB8e6
'' SIG '' eoc0Aw5LYnqZ6cr8zko3yS2kV3wc/j3cuA9a+tbEswKF
'' SIG '' Ajrqs9lu5GkhN96B0fZ1GQVn05NXXikbOcjuLeHN5EVz
'' SIG '' W9DSznqrFhmCRljQXp2Bs2evbDXyvOU/JOI1ogp1BvYY
'' SIG '' VpnUeCzRBRvr0IgBnaoQ8QXfun4sY7cGmyMhxPl4bOJY
'' SIG '' FwY2K5ESA8yk2fItuvmUnUDtGEXxzopcaz6rA9NwGCoK
'' SIG '' auBfR9HVYwoy8q/XNh8qcFrlQlkIcUtXun6DgfAhPPQc
'' SIG '' wcW5kJMOiEWThumxIJm+mMvFlaRdYtagYwggvXUQd309
'' SIG '' 80W5n5efy1eAbzOpBM93pGIcWX4xghnqMIIZ5gIBATCB
'' SIG '' nDCBhDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEuMCwGA1UEAxMl
'' SIG '' TWljcm9zb2Z0IFdpbmRvd3MgUHJvZHVjdGlvbiBQQ0Eg
'' SIG '' MjAxMQITMwAAAzyJxmp7RbsfvQAAAAADPDANBglghkgB
'' SIG '' ZQMEAgEFAKCCAQQwGQYJKoZIhvcNAQkDMQwGCisGAQQB
'' SIG '' gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
'' SIG '' ARUwLwYJKoZIhvcNAQkEMSIEIHzQ3S/HJfQsF18gElR1
'' SIG '' iwpOGlHP8JWRjg0YO5l6qKz2MDwGCisGAQQBgjcKAxwx
'' SIG '' LgwseWFPZURNbGlWUDdEOUhydVNObWY4eG1YK2s3SkF4
'' SIG '' SG9KcTh4eElrc3Vkdz0wWgYKKwYBBAGCNwIBDDFMMEqg
'' SIG '' JIAiAE0AaQBjAHIAbwBzAG8AZgB0ACAAVwBpAG4AZABv
'' SIG '' AHcAc6EigCBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' d2luZG93czANBgkqhkiG9w0BAQEFAASCAQBp+YI4ye/b
'' SIG '' JiK0G3y6ga+2bErZY6HRgNW/fM9FBxWb04M/UJdXaVDS
'' SIG '' s9JB6MdAYbIUyYug8qabSmB2AeaXe3iyccz6FKwdkwwA
'' SIG '' 76ieDdIjUUbCtBKVpa2z7GJhGBOOXn4XPPzEufor/Fzs
'' SIG '' PVJIOge4UWb1MWeT9AClf96eI74tJOcJJvykgE8rRz32
'' SIG '' ltXfYmLBoibunzPQ5+nz/f0GcuWwo3IxXIUGeDzZsdIp
'' SIG '' hrT99OSxbW9fqb426tOU/5EUwc0JkqrpJ2h1Xd3i6nVQ
'' SIG '' rAWB2aAnALsn+P0XEeB/m9/OL5Pj1nJ63PRDAhNjuKHW
'' SIG '' fdr9HyIfDNJZ883lwANQew9loYIXFjCCFxIGCisGAQQB
'' SIG '' gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusC
'' SIG '' AQMxDzANBglghkgBZQMEAgEFADCCAVkGCyqGSIb3DQEJ
'' SIG '' EAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMBMDEw
'' SIG '' DQYJYIZIAWUDBAIBBQAEIANwRaS0JH1+HWT1OA8/KdmS
'' SIG '' 6pN1ySj6CP2RVo/raOXyAgZibEPCiyAYEzIwMjIwNTA3
'' SIG '' MDIyMDM2Ljc4M1owBIACAfSggdikgdUwgdIxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJ
'' SIG '' cmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UE
'' SIG '' CxMdVGhhbGVzIFRTUyBFU046MkFENC00QjkyLUZBMDEx
'' SIG '' JTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNl
'' SIG '' cnZpY2WgghFlMIIHFDCCBPygAwIBAgITMwAAAYZ45RmJ
'' SIG '' +CRLzAABAAABhjANBgkqhkiG9w0BAQsFADB8MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
'' SIG '' VGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMTEwMjgxOTI3
'' SIG '' MzlaFw0yMzAxMjYxOTI3MzlaMIHSMQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFu
'' SIG '' ZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRo
'' SIG '' YWxlcyBUU1MgRVNOOjJBRDQtNEI5Mi1GQTAxMSUwIwYD
'' SIG '' VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
'' SIG '' MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
'' SIG '' wI3G2Wpv6B4IjAfrgfJpndPOPYO1Yd8+vlfoIxMW3gdC
'' SIG '' DT+zIbafg14pOu0t0ekUQx60p7PadH4OjnqNIE1q6ldH
'' SIG '' 9ntj1gIdl4Hq4rdEHTZ6JFdE24DSbVoqqR+R4Iw4w3GP
'' SIG '' bfc2Q3kfyyFyj+DOhmCWw/FZiTVTlT4bdejyAW6r/Jn4
'' SIG '' fr3xLjbvhITatr36VyyzgQ0Y4Wr73H3gUcLjYu0qiHut
'' SIG '' DDb6+p+yDBGmKFznOW8wVt7D+u2VEJoE6JlK0EpVLZus
'' SIG '' dSzhecuUwJXxb2uygAZXlsa/fHlwW9YnlBqMHJ+im9Hu
'' SIG '' K5X4x8/5B5dkuIoX5lWGjFMbD2A6Lu/PmUB4hK0CF5G1
'' SIG '' YaUtBrME73DAKkypk7SEm3BlJXwY/GrVoXWYUGEHyfrk
'' SIG '' Lkws0RoEMpoIEgebZNKqjRynRJgR4fPCKrEhwEiTTAc4
'' SIG '' DXGci4HHOm64EQ1g/SDHMFqIKVSxoUbkGbdKNKHhmahu
'' SIG '' IrAy4we9s7rZJskveZYZiDmtAtBt/gQojxbZ1vO9C11S
'' SIG '' thkrmkkTMLQf9cDzlVEBeu6KmHX2Sze6ggne3I4cy/5I
'' SIG '' ULnHZ3rM4ZpJc0s2KpGLHaVrEQy4x/mAn4yaYfgeH3ME
'' SIG '' AWkVjy/qTDh6cDCF/gyz3TaQDtvFnAK70LqtbEvBPdBp
'' SIG '' eCG/hk9l0laYzwiyyGY/HqMCAwEAAaOCATYwggEyMB0G
'' SIG '' A1UdDgQWBBQZtqNFA+9mdEu/h33UhHMN6whcLjAfBgNV
'' SIG '' HSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
'' SIG '' HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29m
'' SIG '' dC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1l
'' SIG '' LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYIKwYB
'' SIG '' BQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jv
'' SIG '' c29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEp
'' SIG '' LmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
'' SIG '' AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4ICAQDD7mehJY3f
'' SIG '' THKC4hj+wBWB8544uaJiMMIHnhK9ONTM7VraTYzx0U/T
'' SIG '' cLJ6gxw1tRzM5uu8kswJNlHNp7RedsAiwviVQZV9AL8I
'' SIG '' bZRLJTwNehCwk+BVcY2gh3ZGZmx8uatPZrRueyhhTTD2
'' SIG '' PvFVLrfwh2liDG/dEPNIHTKj79DlEcPIWoOCUp7p0ORM
'' SIG '' wQ95kVaibpX89pvjhPl2Fm0CBO3pXXJg0bydpQ5dDDTv
'' SIG '' /qb0+WYF/vNVEU/MoMEQqlUWWuXECTqx6TayJuLJ6uU7
'' SIG '' K5QyTkQ/l24IhGjDzf5AEZOrINYzkWVyNfUOpIxnKsWT
'' SIG '' BN2ijpZ/Tun5qrmo9vNIDT0lobgnulae17NaEO9oiEJJ
'' SIG '' H1tQ353dhuRi+A00PR781iYlzF5JU1DrEfEyNx8CWgER
'' SIG '' i90LKsYghZBCDjQ3DiJjfUZLqONeHrJfcmhz5/bfm8+a
'' SIG '' AaUPpZFeP0g0Iond6XNk4YiYbWPFoofc0LwcqSALtuIA
'' SIG '' yz6f3d+UaZZsp41U4hCIoGj6hoDIuU839bo/mZ/AgESw
'' SIG '' GxIXs0gZU6A+2qIUe60QdA969wWSzucKOisng9HCSZLF
'' SIG '' 1dqc3QUawr0C0U41784Ko9vckAG3akwYuVGcs6hM/SqE
'' SIG '' hoe9jHwe4Xp81CrTB1l9+EIdukCbP0kyzx0WZzteeiDN
'' SIG '' 5rdiiQR9mBJuljCCB3EwggVZoAMCAQICEzMAAAAVxedr
'' SIG '' ngKbSZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29m
'' SIG '' dCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEw
'' SIG '' MB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVow
'' SIG '' fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0G
'' SIG '' CSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM57Ry
'' SIG '' IQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg
'' SIG '' 4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPP
'' SIG '' dzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFEx
'' SIG '' N6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTa
'' SIG '' mDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyF
'' SIG '' Vk3v3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIck
'' SIG '' w+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
'' SIG '' yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
'' SIG '' kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37Zy
'' SIG '' L9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0
'' SIG '' gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8
'' SIG '' QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDw
'' SIG '' wvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2
'' SIG '' BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y
'' SIG '' 7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJp
'' SIG '' xq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYBBAGC
'' SIG '' NxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTE
'' SIG '' mr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJd
'' SIG '' g/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGC
'' SIG '' N0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cu
'' SIG '' bWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0
'' SIG '' b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkr
'' SIG '' BgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
'' SIG '' AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
'' SIG '' 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEug
'' SIG '' SaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
'' SIG '' L2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0w
'' SIG '' Ni0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
'' SIG '' BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
'' SIG '' L2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNy
'' SIG '' dDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwEx
'' SIG '' JFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518JxNj/a
'' SIG '' ZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th54
'' SIG '' 2DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZ
'' SIG '' GN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2
'' SIG '' KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVC
'' SIG '' s/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8s
'' SIG '' CXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0
'' SIG '' j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
'' SIG '' Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
'' SIG '' HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nx
'' SIG '' t67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9
'' SIG '' af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcd
'' SIG '' FYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaM
'' SIG '' mdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE
'' SIG '' 0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNY
'' SIG '' s6FwZvKhggLUMIICPQIBATCCAQChgdikgdUwgdIxCzAJ
'' SIG '' BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
'' SIG '' DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
'' SIG '' ZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29m
'' SIG '' dCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQG
'' SIG '' A1UECxMdVGhhbGVzIFRTUyBFU046MkFENC00QjkyLUZB
'' SIG '' MDExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
'' SIG '' IFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAAGu2DRzWkKl
'' SIG '' jmXySX1korHL4fMnoIGDMIGApH4wfDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDm
'' SIG '' H/xWMCIYDzIwMjIwNTA3MDM1ODE0WhgPMjAyMjA1MDgw
'' SIG '' MzU4MTRaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOYf
'' SIG '' /FYCAQAwBwIBAAICFVYwBwIBAAICEWowCgIFAOYhTdYC
'' SIG '' AQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoD
'' SIG '' AqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
'' SIG '' 9w0BAQUFAAOBgQCuIGPPDIioWsGOOxkP9GIxXFvMDFdj
'' SIG '' NkglYNzrwGmoSSuNQj0Ij5zvkE4h3ms4CiJL8xdSdMFN
'' SIG '' Y+SvK86W74oy7MG68AiJGo1cvagQmDG5ONlE4D/K4HXv
'' SIG '' c3GADdBQhQDAkKhXf88NJod0aOx2rK1gpZ66rypCQmRz
'' SIG '' YSSlnse+rzGCBA0wggQJAgEBMIGTMHwxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFBDQSAyMDEwAhMzAAABhnjlGYn4JEvMAAEA
'' SIG '' AAGGMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0B
'' SIG '' CQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIE
'' SIG '' IF6YruDz5Z+Z2mpikHFEii8gq3NnBqABBWmHXJEKPqjy
'' SIG '' MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgGpmI
'' SIG '' 4LIsCFTGiYyfRAR7m7Fa2guxVNIw17mcAiq8Qn4wgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAYZ45RmJ+CRLzAABAAABhjAiBCCXCsx/Bbk9MJo1
'' SIG '' X3qXMVtzAU1v1cO9TdKlqMIsnNE+oDANBgkqhkiG9w0B
'' SIG '' AQsFAASCAgCDrvdrWjwRTNsDYV2mUZ8v64dJdTldIrJc
'' SIG '' OszzyQ46v8jHbJA2yrhag/MnnlPV2p4fIfiELL1p05Gt
'' SIG '' 8vnYq0SryE5ziWE6qbTmap5f3v68hAGiLGxDXD4tEbkU
'' SIG '' iTWA6W/u/Es0+kyqa2LreqkzUG8CRPlCDCMH0ppDebIZ
'' SIG '' POen61wyTWonavMxT9BI4H3jnVEGQhf0bfH3/FrRocr1
'' SIG '' AFkNpRVnnyRBuf8RY/qgbAf3mbIvxd3cnBADD5UcEpCa
'' SIG '' rnQja617tuhIUyIe9eVsxXVF138+1kr0C+B4tD9HqMy6
'' SIG '' lMJmH3FiXtq38uf4/nj7zPG2jgQUM6BY+VzjShRQReNB
'' SIG '' 1kllmeVWvqAOiDtPUUToPAt+v9vXOoAZoWjVyONV2a60
'' SIG '' /cN6MwFYvoIwgB1/sqZydY6fiqyegEJrmc590xg9aqB9
'' SIG '' 3EQNr1MFsWKOryFInGBZjvp9Aj2Y7X9GGa3wJiNBArrb
'' SIG '' MUqH9RvMFRuuM9tSr2+4nwtagTlDIlmkF8XmA1QeLqd5
'' SIG '' 2oF+hcGwqBWSIfK7rS5EYU3vSkS6uDdk9W61iI95uH1h
'' SIG '' oAN9RLmIchVQJVQlsdsbIK4IRS6Ryq85Kh1FzMT0mOdc
'' SIG '' msf4Glrq9Bb2OQpkn4HH4bfoVsrJt9R1MRti8bR2PxhP
'' SIG '' 2B5ekvF8sJ8KBOSXD0D3URYnNvecrDOryA==
'' SIG '' End signature block
