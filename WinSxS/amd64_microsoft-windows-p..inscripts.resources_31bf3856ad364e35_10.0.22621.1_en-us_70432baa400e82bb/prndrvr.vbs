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
'' SIG '' MIIlYQYJKoZIhvcNAQcCoIIlUjCCJU4CAQExDzANBglg
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
'' SIG '' 80W5n5efy1eAbzOpBM93pGIcWX4xghnUMIIZ0AIBATCB
'' SIG '' nDCBhDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEuMCwGA1UEAxMl
'' SIG '' TWljcm9zb2Z0IFdpbmRvd3MgUHJvZHVjdGlvbiBQQ0Eg
'' SIG '' MjAxMQITMwAAAzyJxmp7RbsfvQAAAAADPDANBglghkgB
'' SIG '' ZQMEAgEFAKCCAQQwGQYJKoZIhvcNAQkDMQwGCisGAQQB
'' SIG '' gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
'' SIG '' ARUwLwYJKoZIhvcNAQkEMSIEIHzQ3S/HJfQsF18gElR1
'' SIG '' iwpOGlHP8JWRjg0YO5l6qKz2MDwGCisGAQQBgjcKAxwx
'' SIG '' LgwseHplR2pxSHBHS3N5WjQ4S1RycXpYVjlVb2NNeHVj
'' SIG '' SFVScjFMbjJEWDBmUT0wWgYKKwYBBAGCNwIBDDFMMEqg
'' SIG '' JIAiAE0AaQBjAHIAbwBzAG8AZgB0ACAAVwBpAG4AZABv
'' SIG '' AHcAc6EigCBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' d2luZG93czANBgkqhkiG9w0BAQEFAASCAQCxYW1QHhl1
'' SIG '' irJXuXyJw6Ii7vVtCNerEK9NtSV2w42dZ3R1vgIdkbZP
'' SIG '' ReHPVTJ078BXA2eJ+nGwgq4B9eejK0kHtYnOw3qozGvS
'' SIG '' ZvMbjusO0gAwrenYYAXCnjABzABZe4fn+Sc+P2sHOgYx
'' SIG '' QMSVxTIpHBV5TaoUbxRFYJxf28hxDePbBCd3DIkEoJWL
'' SIG '' q9dj7HqQbO939gNd+JkXw1eEpg76O5nl0FR7Xa51uNVV
'' SIG '' 9hS9TLYH4O0Oh+sVPkzFP7ExcwSI0pEvFrOpwH9r8kpT
'' SIG '' nff9gmK8D624MZTAUSGy0x56fwzRB0doyLx/z7RSBUXO
'' SIG '' 6ea58RzWBrEBu5xuPbjtB+qCoYIXADCCFvwGCisGAQQB
'' SIG '' gjcDAwExghbsMIIW6AYJKoZIhvcNAQcCoIIW2TCCFtUC
'' SIG '' AQMxDzANBglghkgBZQMEAgEFADCCAVEGCyqGSIb3DQEJ
'' SIG '' EAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMBMDEw
'' SIG '' DQYJYIZIAWUDBAIBBQAEIA4G6bVhF0OxG7DMr3bQGYZd
'' SIG '' PK41kyfZPYm3Inx0W+M7AgZiab5BHdgYEzIwMjIwNTA3
'' SIG '' MDMyNzQ1LjMxMVowBIACAfSggdCkgc0wgcoxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBB
'' SIG '' bWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxl
'' SIG '' cyBUU1MgRVNOOkREOEMtRTMzNy0yRkFFMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIR
'' SIG '' VzCCBwwwggT0oAMCAQICEzMAAAGcD6ZNYdKeSygAAQAA
'' SIG '' AZwwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMx
'' SIG '' EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
'' SIG '' ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
'' SIG '' dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
'' SIG '' bXAgUENBIDIwMTAwHhcNMjExMjAyMTkwNTE5WhcNMjMw
'' SIG '' MjI4MTkwNTE5WjCByjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEl
'' SIG '' MCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
'' SIG '' aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046REQ4
'' SIG '' Qy1FMzM3LTJGQUUxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
'' SIG '' AQUAA4ICDwAwggIKAoICAQDbUioMGV1JFj+s612s02mK
'' SIG '' u23KPUNs71OjDeJGtxkTF9rSWTiuA8XgYkAAi/5+2Ff7
'' SIG '' Ck7JcKQ9H/XD1OKwg1/bH3E1qO1z8XRy0PlpGhmyilgE
'' SIG '' 7KsOvW8PIZCf243KdldgOrxrL8HKiQodOwStyT5lLWYp
'' SIG '' MsuT2fH8k8oihje4TlpWiFPaCKLnFDaAB0Ccy6vIdtHj
'' SIG '' YB1Ie3iOZPisquL+vNdCx7gOhB8iiTmTdsU8OSUpC8tB
'' SIG '' TeTIYPzmhaxQZd4moNk6qeCJyi7fiW4fyXdHrZ3otmgx
'' SIG '' xa5pXz5pUUr+cEjV+cwIYBMkaY5kHM9c6dEGkgHn0ZDJ
'' SIG '' vdt/54FOdSG61WwHh4+evUhwvXaB4LCMZIdCt5acOfNv
'' SIG '' tDjV3CHyFOp5AU/qgAwGftHU9brv4EUwcuteEAKH46Nu
'' SIG '' fE20l/WjlNUh7gAvt2zKMjO4zXRxCUTh/prBQwXJiUZe
'' SIG '' FSrEXiOfkuvSlBniyAYYZp5kOnaxfCKdGYjvr4QLA93v
'' SIG '' QJ6p2Ox3IHvOdCPaCr8LsKVcFpyp8MEhhJTM+1LwqHJq
'' SIG '' FDF5O1Z9mjbYvm3R9vPhkG+RDLKoTpr7mTgkaTljd9xv
'' SIG '' m94Obp8BD9Hk4mPi51mtgLiuN8/6aZVESVZXtvSuNkD5
'' SIG '' DnIJQerIy5jaRKW/W2rCe9ngNDJadS7R96GGRl7IIE37
'' SIG '' lwIDAQABo4IBNjCCATIwHQYDVR0OBBYEFLtpCWdTXY5d
'' SIG '' tddkspy+oxjCA/qyMB8GA1UdIwQYMBaAFJ+nFV0AXmJd
'' SIG '' g/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCGTmh0
'' SIG '' dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3Js
'' SIG '' L01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
'' SIG '' MDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4wXAYIKwYB
'' SIG '' BQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
'' SIG '' a2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFt
'' SIG '' cCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQC
'' SIG '' MAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcN
'' SIG '' AQELBQADggIBAKcAKqYjGEczTWMs9z0m7Yo23sgqVF3L
'' SIG '' yK6gOMz7TCHAJN+FvbvZkQ53VkvrZUd1sE6a9ToGldcJ
'' SIG '' nOmBc6iuhBlpvdN1BLBRO8QSTD1433VTj4XCQd737wND
'' SIG '' 1+eqKG3BdjrzbDksEwfG4v57PgrN/T7s7PkEjUGXfIgF
'' SIG '' QQkr8TQi+/HZZ9kRlNccgeACqlfb4uGPxn5sdhQPoxdM
'' SIG '' vmC3qG9DONJ5UsS9KtO+bey+ohUTDa9LvEToc4Qzy5fu
'' SIG '' Hj2H1JsmCaKG78nXpfWpwBLBxZYSpfml29onN8jcG7KD
'' SIG '' 8nGSS/76PDlb2GMQsvv+Ra0JgL6FtGRGgYmHCpM6zVrf
'' SIG '' 4V/a+SoHcC+tcdGYk2aKU5KOlv+fFE3n024V+z54tDAK
'' SIG '' R9z78rejdCBWqfvy5cBUQ9c5+3unHD08BEp7qP2rgpoD
'' SIG '' 856vNDgEwO77n7EWT76nl/IyrbK2kjbHLzUMphFpXKnV
'' SIG '' 1fYWJI2+E/0LHvXFGGqF4OvMBRxbrJVn03T2Dy5db6s5
'' SIG '' TzJzSaQvCrXYqA4HKvstQWkqkpvBHTX8M09+/vyRbVXN
'' SIG '' xrPdeXw6oD2Q4DksykCFfn8N2j2LdixE9wG5iilv69dz
'' SIG '' svHIN/g9A9+thkAQCVb9DUSOTaMIGgsOqDYFjhT6ze9l
'' SIG '' khHHGv/EEIkxj9l6S4hqUQyWerFkaUWDXcnZMIIHcTCC
'' SIG '' BVmgAwIBAgITMwAAABXF52ueAptJmQAAAAAAFTANBgkq
'' SIG '' hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEy
'' SIG '' MDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNh
'' SIG '' dGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
'' SIG '' WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzET
'' SIG '' MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
'' SIG '' bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
'' SIG '' aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFt
'' SIG '' cCBQQ0EgMjAxMDCCAiIwDQYJKoZIhvcNAQEBBQADggIP
'' SIG '' ADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O1YLT/e6c
'' SIG '' BwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNx
'' SIG '' WuJ+Slr+uDZnhUYjDLWNE893MsAQGOhgfWpSg0S3po5G
'' SIG '' awcU88V29YZQ3MFEyHFcUTE3oAo4bo3t1w/YJlN8OWEC
'' SIG '' esSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+
'' SIG '' tuhiJdxqD89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzp
'' SIG '' cGkNyjYtcI4xyDUoveO0hyTD4MmPfrVUj9z6BVWYbWg7
'' SIG '' mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKN
'' SIG '' iOSWrAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRf
'' SIG '' NN0Sidb9pSB9fvzZnkXftnIv231fgLrbqn427DZM9itu
'' SIG '' qBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
'' SIG '' r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEB
'' SIG '' c8pnol7XKHYC4jMYctenIPDC+hIK12NvDMk2ZItboKaD
'' SIG '' IV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQcxWv2
'' SIG '' XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cI
'' SIG '' FRg/eKtFtvUeh17aj54WcmnGrnu3tz5q4i6tAgMBAAGj
'' SIG '' ggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsG
'' SIG '' AQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAd
'' SIG '' BgNVHQ4EFgQUn6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYD
'' SIG '' VR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEF
'' SIG '' BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3Br
'' SIG '' aW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQM
'' SIG '' MAoGCCsGAQUFBwMIMBkGCSsGAQQBgjcUAgQMHgoAUwB1
'' SIG '' AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
'' SIG '' AQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fO
'' SIG '' mhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwu
'' SIG '' bWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
'' SIG '' Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEF
'' SIG '' BQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cu
'' SIG '' bWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2Vy
'' SIG '' QXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUA
'' SIG '' A4ICAQCdVX38Kq3hLB9nATEkW+Geckv8qW/qXBS2Pk5H
'' SIG '' ZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x5MKP+2zR
'' SIG '' oZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gng
'' SIG '' ugnue99qb74py27YP0h1AdkY3m2CDPVtI1TkeFN1JFe5
'' SIG '' 3Z/zjj3G82jfZfakVqr3lbYoVSfQJL1AoL8ZthISEV09
'' SIG '' J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlC
'' SIG '' GVJ1ijbCHcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyR
'' SIG '' gNI95ko+ZjtPu4b6MhrZlvSP9pEB9s7GdP32THJvEKt1
'' SIG '' MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkk
'' SIG '' vnNtyo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZ
'' SIG '' KCS6OEuabvshVGtqRRFHqfG3rsjoiV5PndLQTHa1V1QJ
'' SIG '' sWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
'' SIG '' v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6
'' SIG '' TPmb/wrpNPgkNWcr4A245oyZ1uEi6vAnQj0llOZ0dFtq
'' SIG '' 0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lwY1NN
'' SIG '' je6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAs4wggI3AgEB
'' SIG '' MIH4oYHQpIHNMIHKMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUw
'' SIG '' IwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRp
'' SIG '' b25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpERDhD
'' SIG '' LUUzMzctMkZBRTElMCMGA1UEAxMcTWljcm9zb2Z0IFRp
'' SIG '' bWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUA
'' SIG '' zdlp6t3ws/bnErbm9c0M+9dvU0CggYMwgYCkfjB8MQsw
'' SIG '' CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
'' SIG '' MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
'' SIG '' b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3Nv
'' SIG '' ZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0B
'' SIG '' AQUFAAIFAOYgGegwIhgPMjAyMjA1MDcwNjA0MjRaGA8y
'' SIG '' MDIyMDUwODA2MDQyNFowdzA9BgorBgEEAYRZCgQBMS8w
'' SIG '' LTAKAgUA5iAZ6AIBADAKAgEAAgIUHAIB/zAHAgEAAgIS
'' SIG '' RzAKAgUA5iFraAIBADA2BgorBgEEAYRZCgQCMSgwJjAM
'' SIG '' BgorBgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAID
'' SIG '' AYagMA0GCSqGSIb3DQEBBQUAA4GBALmvkdgFTD9iWm1Z
'' SIG '' LRsRp5JxA0Zet5q1P+g+A4XPA1KSQbSIVAM2IsDSwz2z
'' SIG '' Ezqt3bG4tDk22KnPoW5iCEmiXxhQUgs6phNjC1j2LKTg
'' SIG '' vKAQUws0j6+PrMvB3oIvmvy77cIVxLDMZqpFcLaor5wl
'' SIG '' eFMHZnMmsyR4I0m73NFOpWCyMYIEDTCCBAkCAQEwgZMw
'' SIG '' fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGc
'' SIG '' D6ZNYdKeSygAAQAAAZwwDQYJYIZIAWUDBAIBBQCgggFK
'' SIG '' MBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkq
'' SIG '' hkiG9w0BCQQxIgQgwkYKKto9GIro5q3Z4RTNIvZc/VOA
'' SIG '' B0r1oDGOP11GP2wwgfoGCyqGSIb3DQEJEAIvMYHqMIHn
'' SIG '' MIHkMIG9BCA3D0WFII0syjoRd/XeEIG0WUIKzzuy6P6h
'' SIG '' ORrb0nqmvDCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMw
'' SIG '' EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
'' SIG '' b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
'' SIG '' b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
'' SIG '' IFBDQSAyMDEwAhMzAAABnA+mTWHSnksoAAEAAAGcMCIE
'' SIG '' IABwKhJ71JRm1S7TcHKN99FhBb4hIgzPBMShnAOLzq0I
'' SIG '' MA0GCSqGSIb3DQEBCwUABIICAMy2OEDQObUBC6bhKr2L
'' SIG '' MeZWz+rwOPmaQYEHMFKYb+cb6ZeSo8RRx3wirWsv0+Xf
'' SIG '' cfUAGyBZ4r09wTkrhGdozXw2CQlaYEsxUOmjz4YI3hsv
'' SIG '' ANyAP4nQ7zeE23BanthP/yGZGKH/E3A+562kGl/PlQoW
'' SIG '' vtXQevzxb6lQDvGtCl4EGPgQxcHDUaa72eNBiJ7jGs3g
'' SIG '' CqfCRymwbwgaYWnP/KAEN2M/63Q876uLl+0FStTkfLXY
'' SIG '' Mq3iXWKfjFJU7jsI9HivwqP4KQWvSJDplKYb5I3pfvEF
'' SIG '' PjvxE1P7KyTK3EZSQCQA6Lu3jAqU3F56jnxOiV/+43+D
'' SIG '' zE9kY8V8NU4XljzqP5ZRhBwq27/WsbWomsNoIE2r1GZy
'' SIG '' sVsx6yu+c0iX86md5v/brNZCThfyW2aQPu6wGbXdEvEP
'' SIG '' kTmu87+PPUruyo7+1apnMF+LImZJn7IpgE5MzGh2zb0T
'' SIG '' LrpLqE0VKCNznkUtUuv0Nz/lKGmqL9BwbLnYiOteRhRS
'' SIG '' /SYFI+buZ6ng8uY1/UG81/CZwscf/IFx+Y7AtAdEf7Tv
'' SIG '' NhCbjPM1PJ2aRqXYM4pS1bw17TEYxd7HiHU2+M7as+56
'' SIG '' P9hyXpY7C81kAsz5BP4mRzxwdYr0QfH2NBE2u4pQWGLM
'' SIG '' szNlpFrrf3RRqDZm2HUbkRkaeZIXekuqB511JO1sqUpc
'' SIG '' KvEZ
'' SIG '' End signature block
