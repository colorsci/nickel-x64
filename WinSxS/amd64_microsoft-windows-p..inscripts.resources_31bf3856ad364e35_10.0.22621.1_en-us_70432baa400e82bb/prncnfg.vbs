'----------------------------------------------------------------------
'
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Abstract:
'
' prncnfg.vbs - printer configuration script for WMI on Windows used to get
'     and set printer configuration also used to rename a printer
'
' Usage:
' prncnfg [-gtx?] [-s server] [-p printer] [-u user name] [-w password]
'                 [-z new printer name] [-r port name] [-l location] [-m comment]
'                 [-h share name] [-f sep-file] [-y data-type] [-st start time]
'                 [-ut until time] [-o priority] [-i default priority]
'                 [<+|->rawonly][<+|->keepprintedjobs][<+|->queued][<+|->workoffline]
'                 [<+|->enabledevq][<+|->docompletefirst][<+|->enablebidi]
'
' Examples:
' prncnfg -g -s server -p printer
' prncnfg -x -p printer -w "new Printer"
' prncnfg -t -s server -p Printer -l "Building A/Floor 100/Office 1" -m "Color Printer"
' prncnfg -t -p printer -h "Share" +shared -direct
' prncnfg -t -p printer +rawonly +keepprintedjobs
' prncnfg -t -p printer -st 2300 -ut 0215 -o 10 -i 5
'
'----------------------------------------------------------------------

option explicit

'
' Debugging trace flags, to enable debug output trace message
' change gDebugFlag to true.
'
const kDebugTrace = 1
const kDebugError = 2
dim   gDebugFlag

gDebugFlag = false

const kFlagUpdateOnly = 1

'
' Operation action values.
'
const kActionUnknown   = 0
const kActionSet       = 1
const kActionGet       = 2
const kActionRename    = 3

const kErrorSuccess    = 0
const kErrorFailure    = 1

'
' Constants for the parameter dictionary
'
const kServerName      = 1
const kPrinterName     = 2
const kNewPrinterName  = 3
const kShareName       = 4
const kPortName        = 5
const kDriverName      = 6
const kComment         = 7
const kLocation        = 8
const kSepFile         = 9
const kPrintProc       = 10
const kDataType        = 11
const kParameters      = 12
const kPriority        = 13
const kDefaultPriority = 14
const kStartTime       = 15
const kUntilTime       = 16
const kQueued          = 17
const kDirect          = 18
const kDefault         = 19
const kShared          = 20
const kNetwork         = 21
const kHidden          = 23
const kLocal           = 24
const kEnableDevq      = 25
const kKeepPrintedJobs = 26
const kDoCompleteFirst = 27
const kWorkOffline     = 28
const kEnableBidi      = 29
const kRawOnly         = 30
const kPublished       = 31
const kUserName        = 32
const kPassword        = 33

const kNameSpace       = "root\cimv2"

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
const L_Help_Help_General01_Text   = "Usage: prncnfg [-gtx?] [-s server][-p printer][-z new printer name]"
const L_Help_Help_General02_Text   = "               [-u user name][-w password][-r port name][-l location]"
const L_Help_Help_General03_Text   = "               [-m comment][-h share name][-f sep file][-y datatype]"
const L_Help_Help_General04_Text   = "               [-st start time][-ut until time][-i default priority]"
const L_Help_Help_General05_Text   = "               [-o priority][<+|->shared][<+|->direct][<+|->hidden]"
const L_Help_Help_General06_Text   = "               [<+|->published][<+|->rawonly][<+|->queued][<+|->enablebidi]"
const L_Help_Help_General07_Text   = "               [<+|->keepprintedjobs][<+|->workoffline][<+|->enabledevq]"
const L_Help_Help_General08_Text   = "               [<+|->docompletefirst]"
const L_Help_Help_General09_Text   = "Arguments:"
const L_Help_Help_General10_Text   = "-f     - separator file name"
const L_Help_Help_General11_Text   = "-g     - get configuration"
const L_Help_Help_General12_Text   = "-h     - share name"
const L_Help_Help_General13_Text   = "-i     - default priority"
const L_Help_Help_General14_Text   = "-l     - location string"
const L_Help_Help_General15_Text   = "-m     - comment string"
const L_Help_Help_General16_Text   = "-o     - priority"
const L_Help_Help_General17_Text   = "-p     - printer name"
const L_Help_Help_General18_Text   = "-r     - port name"
const L_Help_Help_General19_Text   = "-s     - server name"
const L_Help_Help_General20_Text   = "-st    - start time"
const L_Help_Help_General21_Text   = "-t     - set configuration"
const L_Help_Help_General22_Text   = "-u     - user name"
const L_Help_Help_General23_Text   = "-ut    - until time"
const L_Help_Help_General24_Text   = "-w     - password"
const L_Help_Help_General25_Text   = "-x     - change printer name"
const L_Help_Help_General26_Text   = "-y     - data type string"
const L_Help_Help_General27_Text   = "-z     - new printer name"
const L_Help_Help_General28_Text   = "-?     - display command usage"
const L_Help_Help_General29_Text   = "Examples:"
const L_Help_Help_General30_Text   = "prncnfg -g -s server -p printer"
const L_Help_Help_General31_Text   = "prncnfg -x -s server -p printer -z ""new printer"""
const L_Help_Help_General32_Text   = "prncnfg -t -p printer -l ""Building A/Floor 100/Office 1"" -m ""Color Printer"""
const L_Help_Help_General33_Text   = "prncnfg -t -p printer -h ""Share"" +shared -direct"
const L_Help_Help_General34_Text   = "prncnfg -t -p printer +rawonly +keepprintedjobs"
const L_Help_Help_General35_Text   = "prncnfg -t -p printer -st 2300 -ut 0215 -o 1 -i 5"

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
const L_Text_Msg_General01_Text    = "Renamed printer"
const L_Text_Msg_General02_Text    = "New printer name"
const L_Text_Msg_General03_Text    = "Unable to rename printer"
const L_Text_Msg_General04_Text    = "Unable to get configuration for printer"
const L_Text_Msg_General05_Text    = "Printer always available"
const L_Text_Msg_General06_Text    = "Configured printer"
const L_Text_Msg_General07_Text    = "Unable to configure printer"
const L_Text_Msg_General08_Text    = "Unable to get SWbemLocator object"
const L_Text_Msg_General09_Text    = "Unable to connect to WMI service"
const L_Text_Msg_General10_Text    = "Printer status"
const L_Text_Msg_General11_Text    = "Extended printer status"
const L_Text_Msg_General12_Text    = "Detected error state"
const L_Text_Msg_General13_Text    = "Extended detected error state"

'
' Printer properties
'
const L_Text_Msg_Printer01_Text    = "Server name"
const L_Text_Msg_Printer02_Text    = "Printer name"
const L_Text_Msg_Printer03_Text    = "Share name"
const L_Text_Msg_Printer04_Text    = "Driver name"
const L_Text_Msg_Printer05_Text    = "Port name"
const L_Text_Msg_Printer06_Text    = "Comment"
const L_Text_Msg_Printer07_Text    = "Location"
const L_Text_Msg_Printer08_Text    = "Separator file"
const L_Text_Msg_Printer09_Text    = "Print processor"
const L_Text_Msg_Printer10_Text    = "Data type"
const L_Text_Msg_Printer11_Text    = "Parameters"
const L_Text_Msg_Printer12_Text    = "Attributes"
const L_Text_Msg_Printer13_Text    = "Priority"
const L_Text_Msg_Printer14_Text    = "Default priority"
const L_Text_Msg_Printer15_Text    = "Start time"
const L_Text_Msg_Printer16_Text    = "Until time"
const L_Text_Msg_Printer17_Text    = "Status"
const L_Text_Msg_Printer18_Text    = "Job count"
const L_Text_Msg_Printer19_Text    = "Average pages per minute"

'
' Printer attributes
'
const L_Text_Msg_Attrib01_Text     = "direct"
const L_Text_Msg_Attrib02_Text     = "raw_only"
const L_Text_Msg_Attrib03_Text     = "local"
const L_Text_Msg_Attrib04_Text     = "shared"
const L_Text_Msg_Attrib05_Text     = "keep_printed_jobs"
const L_Text_Msg_Attrib06_Text     = "published"
const L_Text_Msg_Attrib07_Text     = "queued"
const L_Text_Msg_Attrib08_Text     = "default"
const L_Text_Msg_Attrib09_Text     = "network"
const L_Text_Msg_Attrib10_Text     = "enable_bidi"
const L_Text_Msg_Attrib11_Text     = "do_complete_first"
const L_Text_Msg_Attrib12_Text     = "work_offline"
const L_Text_Msg_Attrib13_Text     = "hidden"
const L_Text_Msg_Attrib14_Text     = "enable_devq_print"

'
' Printer status
'
const L_Text_Msg_Status01_Text     = "Other"
const L_Text_Msg_Status02_Text     = "Unknown"
const L_Text_Msg_Status03_Text     = "Idle"
const L_Text_Msg_Status04_Text     = "Printing"
const L_Text_Msg_Status05_Text     = "Warmup"
const L_Text_Msg_Status06_Text     = "Stopped printing"
const L_Text_Msg_Status07_Text     = "Offline"
const L_Text_Msg_Status08_Text     = "Paused"
const L_Text_Msg_Status09_Text     = "Error"
const L_Text_Msg_Status10_Text     = "Busy"
const L_Text_Msg_Status11_Text     = "Not available"
const L_Text_Msg_Status12_Text     = "Waiting"
const L_Text_Msg_Status13_Text     = "Processing"
const L_Text_Msg_Status14_Text     = "Initializing"
const L_Text_Msg_Status15_Text     = "Power save"
const L_Text_Msg_Status16_Text     = "Pending deletion"
const L_Text_Msg_Status17_Text     = "I/O active"
const L_Text_Msg_Status18_Text     = "Manual feed"
const L_Text_Msg_Status19_Text     = "No error"
const L_Text_Msg_Status20_Text     = "Low paper"
const L_Text_Msg_Status21_Text     = "No paper"
const L_Text_Msg_Status22_Text     = "Low toner"
const L_Text_Msg_Status23_Text     = "No toner"
const L_Text_Msg_Status24_Text     = "Door open"
const L_Text_Msg_Status25_Text     = "Jammed"
const L_Text_Msg_Status26_Text     = "Service requested"
const L_Text_Msg_Status27_Text     = "Output bin full"
const L_Text_Msg_Status28_Text     = "Paper problem"
const L_Text_Msg_Status29_Text     = "Cannot print page"
const L_Text_Msg_Status30_Text     = "User intervention required"
const L_Text_Msg_Status31_Text     = "Out of memory"
const L_Text_Msg_Status32_Text     = "Server unknown"


'
' Debug messages
'
const L_Text_Dbg_Msg01_Text        = "In function RenamePrinter"
const L_Text_Dbg_Msg02_Text        = "New printer name"
const L_Text_Dbg_Msg03_Text        = "In function GetPrinter"
const L_Text_Dbg_Msg04_Text        = "In function SetPrinter"
const L_Text_Dbg_Msg05_Text        = "In function ParseCommandLine"

main

'
' Main execution starts here
'
sub main

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

    if iRetval = kErrorSuccess then

        select case iAction

            case kActionSet
                 iRetval = SetPrinter(oParamDict)

            case kActionGet
                 iRetval = GetPrinter(oParamDict)

            case kActionRename
                 iRetval = RenamePrinter(oParamDict)

            case else
                 Usage(True)
                 exit sub

        end select

    end if

end sub

'
' Rename printer
'
function RenamePrinter(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text
    DebugPrint kDebugTrace, L_Text_Msg_Printer01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Printer02_Text & L_Space_Text & oParamDict.Item(kPrinterName)
    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text & L_Space_Text & oParamDict.Item(kNewPrinterName)

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult
    dim strServer
    dim strPrinter
    dim strNewName
    dim strUser
    dim strPassword

    iRetval = kErrorFailure

    strServer   = oParamDict.Item(kServerName)
    strPrinter  = oParamDict.Item(kPrinterName)
    strNewName  = oParamDict.Item(kNewPrinterName)
    strUser     = oParamDict.Item(kUserName)
    strPassword = oParamDict.Item(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer.DeviceID='" & strPrinter & "'")

    else

        RenamePrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        uResult = oPrinter.RenamePrinter(strNewName)

        if Err.Number = kErrorSuccess then

            if uResult = kErrorSuccess then

                wscript.echo L_Text_Msg_General01_Text & L_Space_Text & strPrinter
                wscript.echo L_Text_Msg_General02_Text & L_Space_Text & strNewName

                iRetval = kErrorSuccess

            else

                wscript.echo L_Text_Msg_General03_Text & L_Space_Text & strPrinter & L_Space_Text _
                             & L_Text_Error_General03_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Text_Msg_General04_Text & L_Space_Text & strPrinter & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & strPrinter & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    RenamePrinter = iRetval

end function

'
' Get printer configuration
'
function GetPrinter(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text
    DebugPrint kDebugTrace, L_Text_Msg_Printer01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Printer02_Text & L_Space_Text & oParamDict.Item(kPrinterName)

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult
    dim strServer
    dim strPrinter
    dim strAttributes
    dim strStart
    dim strEnd
    dim strUser
    dim strPassword

    iRetval = kErrorFailure

    strServer  = oParamDict.Item(kServerName)
    strPrinter = oParamDict.Item(kPrinterName)
    strUser     = oParamDict.Item(kUserName)
    strPassword = oParamDict.Item(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer='" & strPrinter & "'")

    else

        GetPrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        wscript.echo L_Text_Msg_Printer01_Text & L_Space_Text & strServer
        wscript.echo L_Text_Msg_Printer02_Text & L_Space_Text & oPrinter.DeviceID
        wscript.echo L_Text_Msg_Printer03_Text & L_Space_Text & oPrinter.ShareName
        wscript.echo L_Text_Msg_Printer04_Text & L_Space_Text & oPrinter.DriverName
        wscript.echo L_Text_Msg_Printer05_Text & L_Space_Text & oPrinter.PortName
        wscript.echo L_Text_Msg_Printer06_Text & L_Space_Text & oPrinter.Comment
        wscript.echo L_Text_Msg_Printer07_Text & L_Space_Text & oPrinter.Location
        wscript.echo L_Text_Msg_Printer08_Text & L_Space_Text & oPrinter.SeparatorFile
        wscript.echo L_Text_Msg_Printer09_Text & L_Space_Text & oPrinter.PrintProcessor
        wscript.echo L_Text_Msg_Printer10_Text & L_Space_Text & oPrinter.PrintJobDatatype
        wscript.echo L_Text_Msg_Printer11_Text & L_Space_Text & oPrinter.Parameters
        wscript.echo L_Text_Msg_Printer13_Text & L_Space_Text & CStr(oPrinter.Priority)
        wscript.echo L_Text_Msg_Printer14_Text & L_Space_Text & CStr(oPrinter.DefaultPriority)

        strStart = Mid(CStr(oPrinter.StartTime), 9, 4)
        strEnd = Mid(CStr(oPrinter.UntilTime), 9, 4)

        if strStart <> "" and strEnd <> "" then

            wscript.echo L_Text_Msg_Printer15_Text & L_Space_Text & Mid(strStart, 1, 2) & "h" & Mid(strStart, 3, 2)
            wscript.echo L_Text_Msg_Printer16_Text & L_Space_Text & Mid(strEnd, 1, 2) & "h" & Mid(strEnd, 3, 2)

        else

            wscript.echo L_Text_Msg_General05_Text

        end if

        strAttributes = L_Text_Msg_Printer12_Text

        if oPrinter.Direct then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib01_Text

        end if

        if oPrinter.RawOnly then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib02_Text

        end if

        if oPrinter.Local then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib03_Text

        end if

        if oPrinter.Shared then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib04_Text

        end if

        if oPrinter.KeepPrintedJobs then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib05_Text

        end if

        if oPrinter.Published then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib06_Text

        end if

        if oPrinter.Queued then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib07_Text

        end if

        if oPrinter.Default then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib08_Text

        end if

        if oPrinter.Network then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib09_Text

        end if

        if oPrinter.EnableBiDi then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib10_Text

        end if

        if oPrinter.DoCompleteFirst then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib11_Text

        end if

        if oPrinter.WorkOffline then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib12_Text

        end if

        if oPrinter.Hidden then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib13_Text

        end if

        if oPrinter.EnableDevQueryPrint then

            strAttributes = strAttributes + L_Space_Text + L_Text_Msg_Attrib14_Text

        end if

        wscript.echo strAttributes
        wscript.echo
        wscript.echo L_Text_Msg_General10_Text & L_Space_Text & PrnStatusToString(oPrinter.PrinterStatus)
        wscript.echo L_Text_Msg_General11_Text & L_Space_Text & ExtPrnStatusToString(oPrinter.ExtendedPrinterStatus)
        wscript.echo L_Text_Msg_General12_Text & L_Space_Text & DetectedErrorStateToString(oPrinter.DetectedErrorState)
        wscript.echo L_Text_Msg_General13_Text & L_Space_Text & ExtDetectedErrorStateToString(oPrinter.ExtendedDetectedErrorState)

        iRetval = kErrorSuccess

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & oParamDict.Item(kPrinterName) & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    GetPrinter = iRetval

end function

'
' Configure a printer
'
function SetPrinter(oParamDict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text
    DebugPrint kDebugTrace, L_Text_Msg_Printer01_Text & L_Space_Text & oParamDict.Item(kServerName)
    DebugPrint kDebugTrace, L_Text_Msg_Printer02_Text & L_Space_Text & oParamDict.Item(kPrinterName)

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult
    dim strServer
    dim strPrinter
    dim strUser
    dim strPassword

    iRetval = kErrorFailure

    strServer   = oParamDict.Item(kServerName)
    strPrinter  = oParamDict.Item(kPrinterName)
    strNewName  = oParamDict.Item(kNewPrinterName)
    strUser     = oParamDict.Item(kUserName)
    strPassword = oParamDict.Item(kPassword)

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer='" & strPrinter & "'")

    else

        SetPrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if Get was successful
    '
    if Err.Number = kErrorSuccess then

        if oParamdict.Exists(kPortName)        then oPrinter.PortName            = oParamDict.Item(kPortName)        end if
        if oParamdict.Exists(kDriverName)      then oPrinter.DriverName          = oParamDict.Item(kDriverName)      end if
        if oParamdict.Exists(kShareName)       then oPrinter.ShareName           = oParamDict.Item(kShareName)       end if
        if oParamdict.Exists(kLocation)        then oPrinter.Location            = oParamDict.Item(kLocation)        end if
        if oParamdict.Exists(kComment)         then oPrinter.Comment             = oParamDict.Item(kComment)         end if
        if oParamdict.Exists(kDataType)        then oPrinter.PrintJobDataType    = oParamDict.Item(kDataType)        end if
        if oParamdict.Exists(kSepFile)         then oPrinter.SeparatorFile       = oParamDict.Item(kSepfile)         end if
        if oParamdict.Exists(kParameters)      then oPrinter.Parameters          = oParamDict.Item(kParameters)      end if
        if oParamdict.Exists(kPriority)        then oPrinter.Priority            = oParamDict.Item(kPriority)        end if
        if oParamdict.Exists(kDefaultPriority) then oPrinter.DefaultPriority     = oParamDict.Item(kDefaultPriority) end if
        if oParamdict.Exists(kPrintProc)       then oPrinter.PrintProc           = oParamDict.Item(kPrintProc)       end if
        if oParamdict.Exists(kStartTime)       then oPrinter.StartTime           = oParamDict.Item(kStartTime)       end if
        if oParamdict.Exists(kUntilTime)       then oPrinter.UntilTime           = oParamDict.Item(kUntilTime)       end if
        if oParamdict.Exists(kQueued)          then oPrinter.Queued              = oParamDict.Item(kQueued)          end if
        if oParamdict.Exists(kDirect)          then oPrinter.Direct              = oParamDict.Item(kDirect)          end if
        if oParamdict.Exists(kShared)          then oPrinter.Shared              = oParamDict.Item(kShared)          end if
        if oParamdict.Exists(kHidden)          then oPrinter.Hidden              = oParamDict.Item(kHidden)          end if
        if oParamdict.Exists(kEnabledevq)      then oPrinter.EnableDevQueryPrint = oParamDict.Item(kEnabledevq)      end if
        if oParamdict.Exists(kKeepPrintedJobs) then oPrinter.KeepPrintedJobs     = oParamDict.Item(kKeepPrintedJobs) end if
        if oParamdict.Exists(kDoCompleteFirst) then oPrinter.DoCompleteFirst     = oParamDict.Item(kDoCompleteFirst) end if
        if oParamdict.Exists(kWorkOffline)     then oPrinter.WorkOffline         = oParamDict.Item(kWorkOffline)     end if
        if oParamdict.Exists(kEnableBidi)      then oPrinter.EnableBidi          = oParamDict.Item(kEnableBidi)      end if
        if oParamdict.Exists(kRawonly)         then oPrinter.RawOnly             = oParamDict.Item(kRawonly)         end if
        if oParamdict.Exists(kPublished)       then oPrinter.Published           = oParamDict.Item(kPublished)       end if

        oPrinter.Put_(kFlagUpdateOnly)

        if Err.Number = kErrorSuccess then

            wscript.echo L_Text_Msg_General06_Text & L_Space_Text & strPrinter

            iRetval = kErrorSuccess

        else

            wscript.echo L_Text_Msg_General07_Text & L_Space_Text & strPrinter & L_Space_Text _
                         & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

        end if

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & strPrinter & L_Space_Text _
                     & L_Error_Text & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                     & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    SetPrinter = iRetval

end function

'
' Converts the printer status to a string
'
function PrnStatusToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status03_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status04_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status05_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status06_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

    end select

    PrnStatusToString = str

end function

'
' Converts the extended printer status to a string
'
function ExtPrnStatusToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status03_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status04_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status05_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status06_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

        case 8
            str = str + L_Text_Msg_Status08_Text + L_Space_Text

        case 9
            str = str + L_Text_Msg_Status09_Text + L_Space_Text

        case 10
            str = str + L_Text_Msg_Status10_Text + L_Space_Text

        case 11
            str = str + L_Text_Msg_Status11_Text + L_Space_Text

        case 12
            str = str + L_Text_Msg_Status12_Text + L_Space_Text

        case 13
            str = str + L_Text_Msg_Status13_Text + L_Space_Text

        case 14
            str = str + L_Text_Msg_Status14_Text + L_Space_Text

        case 15
            str = str + L_Text_Msg_Status15_Text + L_Space_Text

        case 16
            str = str + L_Text_Msg_Status16_Text + L_Space_Text

        case 17
            str = str + L_Text_Msg_Status17_Text + L_Space_Text

        case 18
            str = str + L_Text_Msg_Status18_Text + L_Space_Text

    end select

    ExtPrnStatusToString = str

end function

'
' Converts the detected error state to a string
'
function DetectedErrorStateToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 0
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status20_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status21_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status22_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status23_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status24_Text + L_Space_Text

        case 8
            str = str + L_Text_Msg_Status25_Text + L_Space_Text

        case 9
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

        case 10
            str = str + L_Text_Msg_Status26_Text + L_Space_Text

        case 11
            str = str + L_Text_Msg_Status27_Text + L_Space_Text

    end select

    DetectedErrorStateToString = str

end function

'
' Converts the extended detected error state to a string
'
function ExtDetectedErrorStateToString(Status)

    dim str

    str = L_Empty_Text

    select case Status

        case 0
            str = str + L_Text_Msg_Status02_Text + L_Space_Text

        case 1
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 2
            str = str + L_Text_Msg_Status01_Text + L_Space_Text

        case 3
            str = str + L_Text_Msg_Status20_Text + L_Space_Text

        case 4
            str = str + L_Text_Msg_Status21_Text + L_Space_Text

        case 5
            str = str + L_Text_Msg_Status22_Text + L_Space_Text

        case 6
            str = str + L_Text_Msg_Status23_Text + L_Space_Text

        case 7
            str = str + L_Text_Msg_Status24_Text + L_Space_Text

        case 8
            str = str + L_Text_Msg_Status25_Text + L_Space_Text

        case 9
            str = str + L_Text_Msg_Status07_Text + L_Space_Text

        case 10
            str = str + L_Text_Msg_Status26_Text + L_Space_Text

        case 11
            str = str + L_Text_Msg_Status27_Text + L_Space_Text

        case 12
            str = str + L_Text_Msg_Status28_Text + L_Space_Text

        case 13
            str = str + L_Text_Msg_Status29_Text + L_Space_Text

        case 14
            str = str + L_Text_Msg_Status30_Text + L_Space_Text

        case 15
            str = str + L_Text_Msg_Status31_Text + L_Space_Text

        case 16
            str = str + L_Text_Msg_Status32_Text + L_Space_Text

    end select

    ExtDetectedErrorStateToString = str

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
function ParseCommandLine(iAction, oParamdict)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg05_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown
    iIndex = 0

    set oArgs = wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-g"
                iAction = kActionGet

            case "-t"
                iAction = kActionSet

            case "-x"
                iAction = kActionRename

            case "-p"
                iIndex = iIndex + 1
                oParamdict.Add kPrinterName, oArgs(iIndex)

            case "-s"
                iIndex = iIndex + 1
                oParamdict.Add kServerName, RemoveBackslashes(oArgs(iIndex))

            case "-r"
                iIndex = iIndex + 1
                oParamdict.Add kPortName, oArgs(iIndex)

            case "-h"
                iIndex = iIndex + 1
                oParamdict.Add kShareName, oArgs(iIndex)

            case "-m"
                iIndex = iIndex + 1
                oParamdict.Add kComment, oArgs(iIndex)

            case "-l"
                iIndex = iIndex + 1
                oParamdict.Add kLocation, oArgs(iIndex)

            case "-y"
                iIndex = iIndex + 1
                oParamdict.Add kDataType, oArgs(iIndex)

            case "-f"
                iIndex = iIndex + 1
                oParamdict.Add kSepFile, oArgs(iIndex)

            case "-z"
                iIndex = iIndex + 1
                oParamdict.Add kNewPrinterName, oArgs(iIndex)

            case "-u"
                iIndex = iIndex + 1
                oParamdict.Add kUserName, oArgs(iIndex)

            case "-w"
                iIndex = iIndex + 1
                oParamdict.Add kPassword, oArgs(iIndex)

            case "-st"
                iIndex = iIndex + 1
                oParamdict.Add kStartTime, "********" & oArgs(iIndex) & "00.000000+000"

            case "-o"
                iIndex = iIndex + 1
                oParamdict.Add kPriority, oArgs(iIndex)

            case "-i"
                iIndex = iIndex + 1
                oParamdict.Add kDefaultPriority, oArgs(iIndex)

            case "-ut"
                iIndex = iIndex + 1
                oParamdict.Add kUntilTime, "********" & oArgs(iIndex) & "00.000000+000"

            case "-queued"
                oParamdict.Add kQueued, false

            case "+queued"
                oParamdict.Add kQueued, true

            case "-direct"
                oParamdict.Add kDirect, false

            case "+direct"
                oParamdict.Add kDirect, true

            case "-shared"
                oParamdict.Add kShared, false

            case "+shared"
                oParamdict.Add kShared, true

            case "-hidden"
                oParamdict.Add kHidden, false

            case "+hidden"
                oParamdict.Add kHidden, true

            case "-enabledevq"
                oParamdict.Add kEnabledevq, false

            case "+enabledevq"
                oParamdict.Add kEnabledevq, true

            case "-keepprintedjobs"
                oParamdict.Add kKeepprintedjobs, false

            case "+keepprintedjobs"
                oParamdict.Add kKeepprintedjobs, true

            case "-docompletefirst"
                oParamdict.Add kDocompletefirst, false

            case "+docompletefirst"
                oParamdict.Add kDocompletefirst, true

            case "-workoffline"
                oParamdict.Add kWorkoffline, false

            case "+workoffline"
                oParamdict.Add kWorkoffline, true

            case "-enablebidi"
                oParamdict.Add kEnablebidi, false

            case "+enablebidi"
                oParamdict.Add kEnablebidi, true

            case "-rawonly"
                oParamdict.Add kRawonly, false

            case "+rawonly"
                oParamdict.Add kRawonly, true

            case "-published"
                oParamdict.Add kPublished, false

            case "+published"
                oParamdict.Add kPublished, true

            case "-?"
                Usage(true)
                exit function

            case else
                Usage(true)
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

end function

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
    wscript.echo L_Help_Help_General23_Text
    wscript.echo L_Help_Help_General24_Text
    wscript.echo L_Help_Help_General25_Text
    wscript.echo L_Help_Help_General26_Text
    wscript.echo L_Help_Help_General27_Text
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General28_Text
    wscript.echo L_Help_Help_General29_Text
    wscript.echo L_Help_Help_General30_Text
    wscript.echo L_Help_Help_General31_Text
    wscript.echo L_Help_Help_General32_Text
    wscript.echo L_Help_Help_General33_Text
    wscript.echo L_Help_Help_General34_Text
    wscript.echo L_Help_Help_General35_Text

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

            wscript.echo L_Text_Msg_General08_Text & L_Space_Text & L_Error_Text _
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
'' SIG '' MIIlXgYJKoZIhvcNAQcCoIIlTzCCJUsCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' ie1efOwNeF5D8l67XxhZUjMjDFmogSjxo1MJEQP87/Wg
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
'' SIG '' 80W5n5efy1eAbzOpBM93pGIcWX4xghnRMIIZzQIBATCB
'' SIG '' nDCBhDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEuMCwGA1UEAxMl
'' SIG '' TWljcm9zb2Z0IFdpbmRvd3MgUHJvZHVjdGlvbiBQQ0Eg
'' SIG '' MjAxMQITMwAAAzyJxmp7RbsfvQAAAAADPDANBglghkgB
'' SIG '' ZQMEAgEFAKCCAQQwGQYJKoZIhvcNAQkDMQwGCisGAQQB
'' SIG '' gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
'' SIG '' ARUwLwYJKoZIhvcNAQkEMSIEIEHXr2fNkPIz71v/XM89
'' SIG '' 8g/jo6d0nlVsrO6ai8Bf2Tl8MDwGCisGAQQBgjcKAxwx
'' SIG '' LgwsRDlHUDNYOHVMTC9BRFFEMUNndGpodDVRdnNUcTRP
'' SIG '' MlRTc0IwbHFvN1ZKMD0wWgYKKwYBBAGCNwIBDDFMMEqg
'' SIG '' JIAiAE0AaQBjAHIAbwBzAG8AZgB0ACAAVwBpAG4AZABv
'' SIG '' AHcAc6EigCBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' d2luZG93czANBgkqhkiG9w0BAQEFAASCAQA4E85TSHj+
'' SIG '' DpdN2nPKaWuGO/pvQM9Hc5EWbBgMM7WZN2PxniA7zhtX
'' SIG '' QSft/oeoCpupUCJVScmFX6zlQ3yO1OHAMbblRGyA37O8
'' SIG '' G34b3ffFfwdyX95FP0RxcJCLY6S4HfG9LeFUe+SBgzNn
'' SIG '' 8P/eXJlGQRQe2pCFqGzlIoFDSIPT8lWM3GV8cbyIJKPt
'' SIG '' Jz/oUkKIfxJ6kIGFztdl55so4FINEPWxIKSZZeMH9shM
'' SIG '' RZtBYpQ8BsM5oY85r7cNe2JqbwNKjFnKFQuE0WmtS12j
'' SIG '' wWzwqjtcf2XnHDWW3Ui2Khq2AyIsRrdpDZ6j8gIZo8iI
'' SIG '' j9vkNFZY+FCieDWiZHYKHT4PoYIW/TCCFvkGCisGAQQB
'' SIG '' gjcDAwExghbpMIIW5QYJKoZIhvcNAQcCoIIW1jCCFtIC
'' SIG '' AQMxDzANBglghkgBZQMEAgEFADCCAVEGCyqGSIb3DQEJ
'' SIG '' EAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMBMDEw
'' SIG '' DQYJYIZIAWUDBAIBBQAEIG1i9AxZYsXN6rhm/hBmGIBU
'' SIG '' 4k1YdjLyNAp3szl93IExAgZiacqx8VEYEzIwMjIwNTA3
'' SIG '' MDMyNzQ3LjYxOFowBIACAfSggdCkgc0wgcoxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBB
'' SIG '' bWVyaWNhIE9wZXJhdGlvbnMxJjAkBgNVBAsTHVRoYWxl
'' SIG '' cyBUU1MgRVNOOjEyQkMtRTNBRS03NEVCMSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIR
'' SIG '' VDCCBwwwggT0oAMCAQICEzMAAAGhAYVVmblUXYoAAQAA
'' SIG '' AaEwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMx
'' SIG '' EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
'' SIG '' ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
'' SIG '' dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
'' SIG '' bXAgUENBIDIwMTAwHhcNMjExMjAyMTkwNTI0WhcNMjMw
'' SIG '' MjI4MTkwNTI0WjCByjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEl
'' SIG '' MCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0
'' SIG '' aW9uczEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MTJC
'' SIG '' Qy1FM0FFLTc0RUIxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
'' SIG '' AQUAA4ICDwAwggIKAoICAQDayTxe5WukkrYxxVuHLYW9
'' SIG '' BEWCD9kkjnnHsOKwGddIPbZlLY+l5ovLDNf+BEMQKAZQ
'' SIG '' I3DX91l1yCDuP9X7tOPC48ZRGXA/bf9ql0FK5438gIl7
'' SIG '' cV528XeEOFwc/A+UbIUfW296Omg8Z62xaQv3jrG4U/pr
'' SIG '' iArF/er1UA1HNuIGUyqjlygiSPwK2NnFApi1JD+Uef5c
'' SIG '' 47kh7pW1Kj7RnchpFeY9MekPQRia7cEaUYU4sqCiJVdD
'' SIG '' JpefLvPT9EdthlQx75ldx+AwZf2a9T7uQRSBh8tpxPdI
'' SIG '' DDkKiWMwjKTrAY09A3I/jidqPuc8PvX+sqxqyZEN2h4G
'' SIG '' A0Edjmk64nkIukAK18K5nALDLO9SMTxpAwQIHRDtZeTC
'' SIG '' lvAPCEoy1vtPD7f+eqHqStuu+XCkfRjXEpX9+h9frsB0
'' SIG '' /BgD5CBf3ELLAa8TefMfHZWEJRTPNrbXMKizSrUSkVv/
'' SIG '' 3HP/ZsJpwaz5My2Rbyc3Ah9bT76eBJkyfT5FN9v/KQ0H
'' SIG '' nxhRMs6HHhTmNx+LztYci+vHf0D3QH1eCjZWZRjp1mOy
'' SIG '' xpPU2mDMG6gelvJse1JzRADo7YIok/J3Ccbm8MbBbm85
'' SIG '' iogFltFHecHFEFwrsDGBFnNYHMhcbarQNA+gY2e2l9fA
'' SIG '' kX3MjI7Uklkoz74/P6KIqe5jcd9FPCbbSbYH9OLsteeY
'' SIG '' OQIDAQABo4IBNjCCATIwHQYDVR0OBBYEFBa/IDLbY475
'' SIG '' VQyKiZSw47l0/cypMB8GA1UdIwQYMBaAFJ+nFV0AXmJd
'' SIG '' g/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCGTmh0
'' SIG '' dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3Js
'' SIG '' L01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAy
'' SIG '' MDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4wXAYIKwYB
'' SIG '' BQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9w
'' SIG '' a2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFt
'' SIG '' cCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQC
'' SIG '' MAAwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcN
'' SIG '' AQELBQADggIBACDDIxElfXlG5YKcKrLPSS+f3JWZprwK
'' SIG '' EiASvivaHTBRlXtAs+TkadcsEei+9w5vmF5tCUzTH4c0
'' SIG '' nCI7bZxnsL+S6XsiOs3Z1V4WX+IwoXUJ4zLvs0+mT4vj
'' SIG '' GDtYfKQ/bsmJKar2c99m/fHv1Wm2CTcyaePvi86Jh3Uy
'' SIG '' LjdRILWbtzs4oImFMwwKbzHdPopxrBhgi+C1YZshosWL
'' SIG '' lgzyuxjUl+qNg1m52MJmf11loI7D9HJoaQzd+rf928Y8
'' SIG '' rvULmg2h/G50o+D0UJ1Fa/cJJaHfB3sfKw9X6GrtXYGj
'' SIG '' mM3+g+AhaVsfupKXNtOFu5tnLKvAH5OIjEDYV1YKmlXu
'' SIG '' BuhbYassygPFMmNgG2Ank3drEcDcZhCXXqpRszNo1F6G
'' SIG '' u5JCpQZXbOJM9Ue5PlJKtmImAYIGsw+pnHy/r5ggSYOp
'' SIG '' 4g5Z1oU9GhVCM3V0T9adee6OUXBk1rE4dZc/UsPlj0qo
'' SIG '' iljL+lN1A5gkmmz7k5tIObVGB7dJdz8J0FwXRE5qYu1A
'' SIG '' dvauVbZwGQkL1x8aK/svjEQW0NUyJ29znDHiXl5vLoRT
'' SIG '' jjFpshUBi2+IY+mNqbLmj24j5eT+bjDlE3HmNtLPpLcM
'' SIG '' DYqZ1H+6U6YmaiNmac2jRXDAaeEE/uoDMt2dArfJP7M+
'' SIG '' MDv3zzNNTINeuNEtDVgm9zwfgIUCXnDZuVtiMIIHcTCC
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
'' SIG '' je6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAsswggI0AgEB
'' SIG '' MIH4oYHQpIHNMIHKMQswCQYDVQQGEwJVUzETMBEGA1UE
'' SIG '' CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
'' SIG '' MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUw
'' SIG '' IwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRp
'' SIG '' b25zMSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjoxMkJD
'' SIG '' LUUzQUUtNzRFQjElMCMGA1UEAxMcTWljcm9zb2Z0IFRp
'' SIG '' bWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUA
'' SIG '' G3F2jO4LEMVLwgKGXdYMN4FBgOCggYMwgYCkfjB8MQsw
'' SIG '' CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
'' SIG '' MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
'' SIG '' b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3Nv
'' SIG '' ZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDANBgkqhkiG9w0B
'' SIG '' AQUFAAIFAOYgJmEwIhgPMjAyMjA1MDcwNjU3MzdaGA8y
'' SIG '' MDIyMDUwODA2NTczN1owdDA6BgorBgEEAYRZCgQBMSww
'' SIG '' KjAKAgUA5iAmYQIBADAHAgEAAgIBzjAHAgEAAgIRYzAK
'' SIG '' AgUA5iF34QIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgor
'' SIG '' BgEEAYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYag
'' SIG '' MA0GCSqGSIb3DQEBBQUAA4GBAJ+4HltStzt5O2E4NUBM
'' SIG '' SpAKki8QuBDBX577iop+83MxujIYPifjv7DG09MozG0j
'' SIG '' mLzkYThFIVum2wMYmhedvKYlbex1u9azjmTDZyqjhD6c
'' SIG '' iV/7d5BfofRTP79OL36mayRhmnH5uYYvUCS6HNIhmN/w
'' SIG '' LfBlAv0IO150edV97VNQMYIEDTCCBAkCAQEwgZMwfDEL
'' SIG '' MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
'' SIG '' EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
'' SIG '' c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9z
'' SIG '' b2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAGhAYVV
'' SIG '' mblUXYoAAQAAAaEwDQYJYIZIAWUDBAIBBQCgggFKMBoG
'' SIG '' CSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAvBgkqhkiG
'' SIG '' 9w0BCQQxIgQgWUFzSGgVw3273/9feRqDYw7gzoKMtSgH
'' SIG '' chnG4X8+57YwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHk
'' SIG '' MIG9BCDrCFTxOoGCaCCCjoRyBe1JSQrMJeCCTyErziiJ
'' SIG '' 347QhDCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
'' SIG '' VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
'' SIG '' MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
'' SIG '' JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
'' SIG '' QSAyMDEwAhMzAAABoQGFVZm5VF2KAAEAAAGhMCIEIKoe
'' SIG '' BFpjMIpxnc6S8Z//BguKjjVd30Z/v1UlXfD4RhRYMA0G
'' SIG '' CSqGSIb3DQEBCwUABIICADbEAeuZWVKVQOGuwJibiCwM
'' SIG '' 2uYcBM5KgF7sFa0vy90/Ia+08H0OW8zg9mTkBGSg0X8g
'' SIG '' ertXMAzCrzPofpvRckkhnWp0Trybn2D4wQ5/Go4IiUAw
'' SIG '' Ug264cpVRyHP1JN5JMfD+OaINPbxr/Fxdl8TnnBBDTW3
'' SIG '' DPhVV+rFmu7S8Zkp7LSdpGveoh8+9FvFVQrUacGHicxm
'' SIG '' DNTO5JeJ5trlrzATT/4iDt+wGpt+sn8VNqqBjo+YafHC
'' SIG '' FwKWLtpaDwk8eA78XvoAxSlbXrEbT/kNnLbyEfUcQc6h
'' SIG '' ULcSA+BIWWPMVLxz/QcPeqfM2/XfbwP/aS2+h5GjENGU
'' SIG '' k0eG2WxRT9WdZD2CObM17JJZj5HgKTBIA/Ekfq8F3yxs
'' SIG '' buU29usJ4BoShwOPM+N1tBqbzKk4whk55oC51iKEDks0
'' SIG '' we27klogdXqQiIS3e4tj+z+bCAomnizgXHJhVtyIPlgW
'' SIG '' cEx5e4QB/d+qjF+hIIXfhy8aa5vEMypVq4JtOf7otV9c
'' SIG '' 7iby6sFXgPKXNNXMtDUc2NGsaXwTHKlfyfeJp84KLkTV
'' SIG '' JWP2QQYfetPQu7DxVqGL7BKPQOXAOS1mJSvWLtUeoFh8
'' SIG '' qUlQKltfmYBzCKmP1RcMiTmrMAF7mFJlhL2D5H/r3ejk
'' SIG '' mlptwiDmH+nhrRg5L9RDc4AFheawECusQQD0s7pRMM+V
'' SIG '' End signature block
