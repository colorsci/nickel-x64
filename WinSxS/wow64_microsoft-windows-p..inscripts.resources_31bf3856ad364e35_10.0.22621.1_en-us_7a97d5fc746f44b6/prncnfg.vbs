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
'' SIG '' MIIldwYJKoZIhvcNAQcCoIIlaDCCJWQCAQExDzANBglg
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
'' SIG '' 80W5n5efy1eAbzOpBM93pGIcWX4xghnqMIIZ5gIBATCB
'' SIG '' nDCBhDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
'' SIG '' bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
'' SIG '' FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEuMCwGA1UEAxMl
'' SIG '' TWljcm9zb2Z0IFdpbmRvd3MgUHJvZHVjdGlvbiBQQ0Eg
'' SIG '' MjAxMQITMwAAAzyJxmp7RbsfvQAAAAADPDANBglghkgB
'' SIG '' ZQMEAgEFAKCCAQQwGQYJKoZIhvcNAQkDMQwGCisGAQQB
'' SIG '' gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
'' SIG '' ARUwLwYJKoZIhvcNAQkEMSIEIEHXr2fNkPIz71v/XM89
'' SIG '' 8g/jo6d0nlVsrO6ai8Bf2Tl8MDwGCisGAQQBgjcKAxwx
'' SIG '' LgwsS0NKbE9CRlZTZEk2N29BRjN2Z2duNU5HQ1Fhb21z
'' SIG '' QThJWGtaejZHbitFdz0wWgYKKwYBBAGCNwIBDDFMMEqg
'' SIG '' JIAiAE0AaQBjAHIAbwBzAG8AZgB0ACAAVwBpAG4AZABv
'' SIG '' AHcAc6EigCBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' d2luZG93czANBgkqhkiG9w0BAQEFAASCAQBIMmhZ8SIT
'' SIG '' tKfNEmGWyU2qljVF9/iNM0v4tsV6w5VsnRoXO9oZMkvx
'' SIG '' 7REpWHPHprdCCg5ge3ncRlJBwGiUEKKWNmI3Ch4UBqZe
'' SIG '' jSfVfZawotI4alt/c3VQ3QW7OCjLipve0QvGPM0I1ndx
'' SIG '' IxeqCs45xq6m/nL6tIot5efbzvalBPgsqBjWq0tqw2+m
'' SIG '' nP2vSjI3nbK4qchF/NLoO1v4jO/qSNsPxQuEnEMOXy5u
'' SIG '' CF3hWVti7fnHe4Z0fYud9+WHuh69aXn3+5Eq4E5QMdS6
'' SIG '' hE7yMEU2wRkuThP+NUYqcqeJ07dmq49/oBl7K9l2k4jj
'' SIG '' lnTcfDUiLKz5FZuu6W+c3Cs+oYIXFjCCFxIGCisGAQQB
'' SIG '' gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusC
'' SIG '' AQMxDzANBglghkgBZQMEAgEFADCCAVkGCyqGSIb3DQEJ
'' SIG '' EAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMBMDEw
'' SIG '' DQYJYIZIAWUDBAIBBQAEIFfYpSJJTltSWOC79dLSl432
'' SIG '' bN5hzCYA/kcQT/tc6idYAgZibErUbBUYEzIwMjIwNTA3
'' SIG '' MDIyMDQwLjM5N1owBIACAfSggdikgdUwgdIxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJ
'' SIG '' cmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UE
'' SIG '' CxMdVGhhbGVzIFRTUyBFU046MTc5RS00QkIwLTgyNDYx
'' SIG '' JTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNl
'' SIG '' cnZpY2WgghFlMIIHFDCCBPygAwIBAgITMwAAAYo+OI3S
'' SIG '' DgL66AABAAABijANBgkqhkiG9w0BAQsFADB8MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
'' SIG '' VGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMTEwMjgxOTI3
'' SIG '' NDJaFw0yMzAxMjYxOTI3NDJaMIHSMQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFu
'' SIG '' ZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRo
'' SIG '' YWxlcyBUU1MgRVNOOjE3OUUtNEJCMC04MjQ2MSUwIwYD
'' SIG '' VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
'' SIG '' MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
'' SIG '' t/+ut6GDAyAZvegBhagWd0GoqT8lFHMepoWNOLPPEEoL
'' SIG '' uya4X3n+K14FvlZwFmKwqap6B+6EkITSjkecTSB6QRA4
'' SIG '' kivdJydlLvKrg8udtBu67LKyjQqwRzDQTRhECxpU30td
'' SIG '' BE/AeyP95k7qndhIu/OpT4QGyGJUiMDlmZAiDPY5FJki
'' SIG '' tUgGvwMBHwogJz8FVEBFnViAURTJ4kBDiU6ppbv4PI97
'' SIG '' +vQhpspDK+83gayaiRC3gNTGy3iOie6Psl03cvYIiFcA
'' SIG '' JRP4O0RkeFlv/SQoomz3JtsMd9ooS/XO0vSN9h2DVKON
'' SIG '' MjaFOgnN5Rk5iCqwmn6qsme+haoR/TrCBS0zXjXsWTgk
'' SIG '' ljUBtt17UBbW8RL+9LNw3cjPJ8EYRglMNXCYLM6GzCDX
'' SIG '' EvE9T//sAv+k1c84tmoiZDZBqBgr/SvL+gVsOz3EoDZQ
'' SIG '' 26qTa1bEn/npxMmXctoZSe8SRDqgK0JUWhjKXgnyaOAD
'' SIG '' EB+FtfIi+jdcUJbpPtAL4kWvVSRKipVv8MEuYRLexXED
'' SIG '' EBi+V4tfKApZhE4ga0p+QCiawHLBZNoj3UQNzM5QVmGa
'' SIG '' i3MnQFbZkhqbUDypo9vaWEeVeO35JfdLWjwRgvMX3VKZ
'' SIG '' L57d7jmRjiVlluXjZFLx+rhJL7JYVptOPtF1MAtMYlp6
'' SIG '' OugnOpG+4W4MGHqj7YYfP0UCAwEAAaOCATYwggEyMB0G
'' SIG '' A1UdDgQWBBQj2kPY/WwZ1Jeup0lHhD4xkGkkAzAfBgNV
'' SIG '' HSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
'' SIG '' HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29m
'' SIG '' dC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1l
'' SIG '' LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYIKwYB
'' SIG '' BQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jv
'' SIG '' c29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEp
'' SIG '' LmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
'' SIG '' AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4ICAQDF9MESsPXD
'' SIG '' eRtfFo1f575iPfF9ARWbeuuNfM583IfTxfzZf2dv/me3
'' SIG '' DNi/KcNNEnR1TKbZtG7Lsg0cy/pKIEQOJG2fYaWwIIKY
'' SIG '' wuyDJI2Q4kVi5mzbV/0C5+vQQsQcCvfsM8K5X2ffifJi
'' SIG '' 7tqeG0r58Cjgwe7xBYvguPmjUNxwTWvEjZIPfpjVUoaP
'' SIG '' Cl6qqs0eFUb7bcLhzTEEYBnAj8MENhiP5IJd4Pp5lFqH
'' SIG '' Ttpec67YFmGuO/uIA/TjPBfctM5kUI+uzfyh/yIdtDNt
'' SIG '' kIz+e/xmXSFhiQER0uBjRobQZV6c+0TNtvRNLayU4u7E
'' SIG '' ekd7OaDXzQR0RuWGaSiwtN6Xc/PoNP0rezG6Ovcyow1q
'' SIG '' MoUkUEQ7qqD0Qq8QFwK0DKCdZSJtyBKMBpjUYCnNUZbY
'' SIG '' vTTWm4DXK5RYgf23bVBJW4Xo5w490HHo4TjWNqz17PqP
'' SIG '' yMCTnM8HcAqTnPeME0dPYvbdwzDMgbumydbJaq/06FIm
'' SIG '' kJ7KXs9jxqDiE2PTeYnaj82n6Q//PqbHuxxJmwQO4fzd
'' SIG '' OgVqAEkG1XDmppVKW/rJxBN3IxyVr6QP9chY2MYVa0bb
'' SIG '' ACI2dvU+R2QJlE5AjoMKy68WI1pmFT3JKBrracpy6HUj
'' SIG '' GrtV+/1U52brrElClVy5Fb8+UZWZLp82cuCztJMMSqW+
'' SIG '' kP5zyVBSvLM+4DCCB3EwggVZoAMCAQICEzMAAAAVxedr
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
'' SIG '' A1UECxMdVGhhbGVzIFRTUyBFU046MTc5RS00QkIwLTgy
'' SIG '' NDYxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
'' SIG '' IFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAIDw82OvG1MF
'' SIG '' BB2n/4weVqpzV8ShoIGDMIGApH4wfDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDm
'' SIG '' IANvMCIYDzIwMjIwNTA3MDQyODMxWhgPMjAyMjA1MDgw
'' SIG '' NDI4MzFaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOYg
'' SIG '' A28CAQAwBwIBAAICHD4wBwIBAAICEccwCgIFAOYhVO8C
'' SIG '' AQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoD
'' SIG '' AqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
'' SIG '' 9w0BAQUFAAOBgQBiQ/LBZUApdKGLnlXhIa24a1nhX/fW
'' SIG '' lt+Q7l0Q9ti8QCzoyZ1l9bMrz38rQGaG1ZuG7gSpOUm5
'' SIG '' MqMu2H4yrjRw/wo8/FZ1KWZc0FCsKMuqvzbsVY8wKUue
'' SIG '' SdfhT5YPTUNhHkGiWInEg8AenRDlLa6JLs+hEWYkaMxv
'' SIG '' jANZ/OLwvzGCBA0wggQJAgEBMIGTMHwxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFBDQSAyMDEwAhMzAAABij44jdIOAvroAAEA
'' SIG '' AAGKMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0B
'' SIG '' CQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIE
'' SIG '' IDoExv1Z9TJ1LBIrjTI8g6UTmDxuS4IRoiE1/F8PNSuR
'' SIG '' MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQg9L3g
'' SIG '' q3XfSr5+879/MPgxtZCFBoTtEeQ4foCSOU1UKb0wgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAYo+OI3SDgL66AABAAABijAiBCDR/xXgGRwnE+jX
'' SIG '' wSgl2xKPRhwXvAZgzz3rxzYQijDn4jANBgkqhkiG9w0B
'' SIG '' AQsFAASCAgBuheC5Vlp088INJFwDFrWVvhZFdVOCMr69
'' SIG '' LIAJXGcahOisv6ieeQ2HRcRs/alfslt+qXGsWPTHuqGj
'' SIG '' 0fSvU1TJwQr1ZNvRECYwyurAx55qIm45PRDl0oVB5s4N
'' SIG '' mE3qFlKLKGFs65kYEXSjW0/xrscP35Lxi2q9bcWT9nt2
'' SIG '' 5Tejli5USzzNMtjiimeq2/Skm9aHZVNaVu6VVlkDtCI+
'' SIG '' BIybhwr2IiWM2jdy6JQQv7B90oknn0YuKczXPJkaLZbO
'' SIG '' 508Y+B7khZKLYV9RxzZek70Mtgm5XH+6z2jm5RDX6pPv
'' SIG '' rgQlaR5gkHXPggR0J9qn42tvL9tD1Q3CjtUG4uDBhfx4
'' SIG '' PhNIDsx1o49MHG12jUj33PO/DpCnhCpUd5gqCfj1a8kd
'' SIG '' cSZKNen0j4UNL/rQQX7G4wZsFCmiGaPXDj0y+XPBuM/9
'' SIG '' xEgiBbT9zeiW4Se/TwGI5H3VQjE12y4Hr6YmsHrKn7Jz
'' SIG '' Tus63UC5E0CMcu6xC0nzUYQrgeN4uSuqn0J6S7KOxRZy
'' SIG '' Og29/R2YH49XNrQBD4oZUJ/U4w2VVkkvsgwTrppXDZIX
'' SIG '' 6PXc45uhWC2VFz46tnqVj2dMJ0EqGSHxB5pijk9vCc+a
'' SIG '' aYzhuyoeJTWba7iPurGsEtSa7OOXENQoV5j7E0CEqkRW
'' SIG '' Mawlh/3YP6uFQd+eQdMDcyOae8bhLGf7iA==
'' SIG '' End signature block
