'----------------------------------------------------------------------
'
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Abstract:
' prnjobs.vbs - job control script for WMI on Windows 
'     used to pause, resume, cancel and list jobs
'
' Usage:
' prnjobs [-zmxl?] [-s server] [-p printer] [-j jobid] [-u user name] [-w password]
'
' Examples:
' prnjobs -z -j jobid -p printer
' prnjobs -l -p printer
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

'
' Operation action values.
'
const kActionUnknown    = 0
const kActionPause      = 1
const kActionResume     = 2
const kActionCancel     = 3
const kActionList       = 4

const kErrorSuccess     = 0
const KErrorFailure     = 1

const kNameSpace        = "root\cimv2"

'
' Job status constants
'
const kJobPaused        = 1
const kJobError         = 2
const kJobDeleting      = 4
const kJobSpooling      = 8
const kJobPrinting      = 16
const kJobOffline       = 32
const kJobPaperOut      = 64
const kJobPrinted       = 128
const kJobDeleted       = 256
const kJobBlockedDevq   = 512
const kJobUserInt       = 1024
const kJobRestarted     = 2048
const kJobComplete      = 4096

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
const L_Help_Help_General01_Text   = "Usage: prnjobs [-zmxl?] [-s server][-p printer][-j jobid][-u user name][-w password]"
const L_Help_Help_General02_Text   = "Arguments:"
const L_Help_Help_General03_Text   = "-j     - job id"
const L_Help_Help_General04_Text   = "-l     - list all jobs"
const L_Help_Help_General05_Text   = "-m     - resume the job"
const L_Help_Help_General06_Text   = "-p     - printer name"
const L_Help_Help_General07_Text   = "-s     - server name"
const L_Help_Help_General08_Text   = "-u     - user name"
const L_Help_Help_General09_Text   = "-w     - password"
const L_Help_Help_General10_Text   = "-x     - cancel the job"
const L_Help_Help_General11_Text   = "-z     - pause the job"
const L_Help_Help_General12_Text   = "-?     - display command usage"
const L_Help_Help_General13_Text   = "Examples:"
const L_Help_Help_General14_Text   = "prnjobs -z -p printer -j jobid"
const L_Help_Help_General15_Text   = "prnjobs -l -p printer"
const L_Help_Help_General16_Text   = "prnjobs -l"

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
const L_Text_Msg_General01_Text    = "Unable to enumerate print jobs"
const L_Text_Msg_General02_Text    = "Number of print jobs enumerated"
const L_Text_Msg_General03_Text    = "Unable to set print job"
const L_Text_Msg_General04_Text    = "Unable to get SWbemLocator object"
const L_Text_Msg_General05_Text    = "Unable to connect to WMI service"


'
' Print job properties
'
const L_Text_Msg_Job01_Text        = "Job id"
const L_Text_Msg_Job02_Text        = "Printer"
const L_Text_Msg_Job03_Text        = "Document"
const L_Text_Msg_Job04_Text        = "Data type"
const L_Text_Msg_Job05_Text        = "Driver name"
const L_Text_Msg_Job06_Text        = "Description"
const L_Text_Msg_Job07_Text        = "Elapsed time"
const L_Text_Msg_Job08_Text        = "Machine name"
const L_Text_Msg_Job09_Text        = "Notify"
const L_Text_Msg_Job10_Text        = "Owner"
const L_Text_Msg_Job11_Text        = "Pages printed"
const L_Text_Msg_Job12_Text        = "Parameters"
const L_Text_Msg_Job13_Text        = "Size"
const L_Text_Msg_Job14_Text        = "Start time"
const L_Text_Msg_Job15_Text        = "Until time"
const L_Text_Msg_Job16_Text        = "Status"
const L_Text_Msg_Job17_Text        = "Time submitted"
const L_Text_Msg_Job18_Text        = "Total pages"
const L_Text_Msg_Job19_Text        = "SizeHigh"
const L_Text_Msg_Job20_Text        = "PaperSize"
const L_Text_Msg_Job21_Text        = "PaperWidth"
const L_Text_Msg_Job22_Text        = "PaperLength"
const L_Text_Msg_Job23_Text        = "Color"

'
' Job status strings
'
const L_Text_Msg_Status01_Text     = "The driver cannot print the job"
const L_Text_Msg_Status02_Text     = "Sent to the printer"
const L_Text_Msg_Status03_Text     = "Job has been deleted"
const L_Text_Msg_Status04_Text     = "Job is being deleted"
const L_Text_Msg_Status05_Text     = "An error is associated with the job"
const L_Text_Msg_Status06_Text     = "Printer is offline"
const L_Text_Msg_Status07_Text     = "Printer is out of paper"
const L_Text_Msg_Status08_Text     = "Job is paused"
const L_Text_Msg_Status09_Text     = "Job has printed"
const L_Text_Msg_Status10_Text     = "Job is printing"
const L_Text_Msg_Status11_Text     = "Job has been restarted"
const L_Text_Msg_Status12_Text     = "Job is spooling"
const L_Text_Msg_Status13_Text     = "Printer has an error that requires user intervention"

'
' Action strings
'
const L_Text_Action_General01_Text = "Pause"
const L_Text_Action_General02_Text = "Resume"
const L_Text_Action_General03_Text = "Cancel"

'
' Debug messages
'
const L_Text_Dbg_Msg01_Text        = "In function ListJobs"
const L_Text_Dbg_Msg02_Text        = "In function ExecJob"
const L_Text_Dbg_Msg03_Text        = "In function ParseCommandLine"

main

'
' Main execution starts here
'
sub main

    dim iAction
    dim iRetval
    dim strServer
    dim strPrinter
    dim strJob
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

    iRetval = ParseCommandLine(iAction, strServer, strPrinter, strJob, strUser, strPassword)

    if iRetval = kErrorSuccess then

        select case iAction

            case kActionPause
                 iRetval = ExecJob(strServer, strJob, strPrinter, strUser, strPassword, L_Text_Action_General01_Text)

            case kActionResume
                 iRetval = ExecJob(strServer, strJob, strPrinter, strUser, strPassword, L_Text_Action_General02_Text)

            case kActionCancel
                 iRetval = ExecJob(strServer, strJob, strPrinter, strUser, strPassword, L_Text_Action_General03_Text)

            case kActionList
                 iRetval = ListJobs(strServer, strPrinter, strUser, strPassword)

            case else
                 Usage(true)
                 exit sub

        end select

    end if

end sub

'
' Enumerate all print jobs on a printer
'
function ListJobs(strServer, strPrinter, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text

    dim Jobs
    dim oJob
    dim oService
    dim iRetval
    dim strTemp
    dim iTotal

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set Jobs = oService.InstancesOf("Win32_PrintJob")

    else

        ListJobs = kErrorFailure

        exit function

    end if

    if Err.Number <> kErrorSuccess then

        wscript.echo L_Text_Msg_General01_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        ListJobs = kErrorFailure

        exit function

    end if

    iTotal = 0

    for each oJob in Jobs

        '
        ' oJob.Name has the form "printer name, job id". We are isolating the printer name
        '
        strTemp = Mid(oJob.Name, 1, InStr(1, oJob.Name, ",", 1)-1 )

        '
        ' If no printer was specified, then enumerate all jobs
        '
        if strPrinter = null or strPrinter = "" or LCase(strTemp) = LCase(strPrinter) then

            iTotal = iTotal + 1

            wscript.echo L_Empty_Text
            wscript.echo L_Text_Msg_Job01_Text & L_Space_Text & oJob.JobId
            wscript.echo L_Text_Msg_Job02_Text & L_Space_Text & strTemp
            wscript.echo L_Text_Msg_Job03_Text & L_Space_Text & oJob.Document
            wscript.echo L_Text_Msg_Job04_Text & L_Space_Text & oJob.DataType
            wscript.echo L_Text_Msg_Job05_Text & L_Space_Text & oJob.DriverName
            wscript.echo L_Text_Msg_Job06_Text & L_Space_Text & oJob.Description
            wscript.echo L_Text_Msg_Job07_Text & L_Space_Text & Mid(CStr(oJob.ElapsedTime), 9, 2) & ":" _
                                                              & Mid(CStr(oJob.ElapsedTime), 11, 2) & ":" _
                                                              & Mid(CStr(oJob.ElapsedTime), 13, 2)
            wscript.echo L_Text_Msg_Job08_Text & L_Space_Text & oJob.HostPrintQueue
            wscript.echo L_Text_Msg_Job09_Text & L_Space_Text & oJob.Notify
            wscript.echo L_Text_Msg_Job10_Text & L_Space_Text & oJob.Owner
            wscript.echo L_Text_Msg_Job11_Text & L_Space_Text & oJob.PagesPrinted
            wscript.echo L_Text_Msg_Job12_Text & L_Space_Text & oJob.Parameters
            wscript.echo L_Text_Msg_Job13_Text & L_Space_Text & oJob.Size
            wscript.echo L_Text_Msg_Job19_Text & L_Space_Text & oJob.SizeHigh
            wscript.echo L_Text_Msg_Job20_Text & L_Space_Text & oJob.PaperSize
            wscript.echo L_Text_Msg_Job21_Text & L_Space_Text & oJob.PaperWidth
            wscript.echo L_Text_Msg_Job22_Text & L_Space_Text & oJob.PaperLength
            wscript.echo L_Text_Msg_Job23_Text & L_Space_Text & oJob.Color

            if CStr(oJob.StartTime) <> "********000000.000000+000" and _
               CStr(oJob.UntilTime) <> "********000000.000000+000" then

                wscript.echo L_Text_Msg_Job14_Text & L_Space_Text & Mid(Mid(CStr(oJob.StartTime), 9, 4), 1, 2) & "h" _
                                                                  & Mid(Mid(CStr(oJob.StartTime), 9, 4), 3, 2)
                wscript.echo L_Text_Msg_Job15_Text & L_Space_Text & Mid(Mid(CStr(oJob.UntilTime), 9, 4), 1, 2) & "h" _
                                                                  & Mid(Mid(CStr(oJob.UntilTime), 9, 4), 3, 2)
            end if

            wscript.echo L_Text_Msg_Job16_Text & L_Space_Text & JobStatusToString(oJob.StatusMask)
            wscript.echo L_Text_Msg_Job17_Text & L_Space_Text & Mid(CStr(oJob.TimeSubmitted), 5, 2) & "/" _
                                                              & Mid(CStr(oJob.TimeSubmitted), 7, 2) & "/" _
                                                              & Mid(CStr(oJob.TimeSubmitted), 1, 4) & " " _
                                                              & Mid(CStr(oJob.TimeSubmitted), 9, 2) & ":" _
                                                              & Mid(CStr(oJob.TimeSubmitted), 11, 2) & ":" _
                                                              & Mid(CStr(oJob.TimeSubmitted), 13, 2)
            wscript.echo L_Text_Msg_Job18_Text & L_Space_Text & oJob.TotalPages

            Err.Clear

        end if

    next

    wscript.echo L_Empty_Text
    wscript.echo L_Text_Msg_General02_Text & L_Space_Text & iTotal

    ListJobs = kErrorSuccess

end function

'
' Convert the job status from bit mask to string
'
function JobStatusToString(Status)

    on error resume next

    dim strString

    strString = L_Empty_Text

    if (Status and kJobPaused)      = kJobPaused      then strString = strString & L_Text_Msg_Status08_Text & L_Space_Text end if
    if (Status and kJobError)       = kJobError       then strString = strString & L_Text_Msg_Status05_Text & L_Space_Text end if
    if (Status and kJobDeleting)    = kJobDeleting    then strString = strString & L_Text_Msg_Status04_Text & L_Space_Text end if
    if (Status and kJobSpooling)    = kJobSpooling    then strString = strString & L_Text_Msg_Status12_Text & L_Space_Text end if
    if (Status and kJobPrinting)    = kJobPrinting    then strString = strString & L_Text_Msg_Status10_Text & L_Space_Text end if
    if (Status and kJobOffline)     = kJobOffline     then strString = strString & L_Text_Msg_Status06_Text & L_Space_Text end if
    if (Status and kJobPaperOut)    = kJobPaperOut    then strString = strString & L_Text_Msg_Status07_Text & L_Space_Text end if
    if (Status and kJobPrinted)     = kJobPrinted     then strString = strString & L_Text_Msg_Status09_Text & L_Space_Text end if
    if (Status and kJobDeleted)     = kJobDeleted     then strString = strString & L_Text_Msg_Status03_Text & L_Space_Text end if
    if (Status and kJobBlockedDevq) = kJobBlockedDevq then strString = strString & L_Text_Msg_Status01_Text & L_Space_Text end if
    if (Status and kJobUserInt)     = kJobUserInt     then strString = strString & L_Text_Msg_Status13_Text & L_Space_Text end if
    if (Status and kJobRestarted)   = kJobRestarted   then strString = strString & L_Text_Msg_Status11_Text & L_Space_Text end if
    if (Status and kJobComplete)    = kJobComplete    then strString = strString & L_Text_Msg_Status02_Text & L_Space_Text end if

    JobStatusToString = strString

end function

'
' Pause/Resume/Cancel jobs
'
function ExecJob(strServer, strJob, strPrinter, strUser, strPassword, strCommand)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text

    dim oJob
    dim oService
    dim iRetval
    dim uResult
    dim strName

    '
    ' Build up the key. The key for print jobs is "printer-name, job-id"
    '
    strName = strPrinter & ", " & strJob

    iRetval = kErrorFailure

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oJob = oService.Get("Win32_PrintJob.Name='" & strName & "'")

    else

        ExecJob = kErrorFailure

        exit function

    end if

    '
    ' Check if getting job instance succeeded
    '
    if Err.Number = kErrorSuccess then

        uResult = kErrorSuccess

        select case strCommand

            case L_Text_Action_General01_Text
                 uResult = oJob.Pause()

            case L_Text_Action_General02_Text
                 uResult = oJob.Resume()

            case L_Text_Action_General03_Text
                 oJob.Delete_()

             case else
                 Usage(true)

        end select

        if Err.Number = kErrorSuccess then

            if uResult = kErrorSuccess then

                wscript.echo L_Success_Text & L_Space_Text & strCommand & L_Space_Text _
                             & L_Text_Msg_Job01_Text & L_Space_Text & strJob _
                             & L_Space_Text & L_Printer_Text & L_Space_Text & strPrinter

                iRetval = kErrorSuccess

            else

                wscript.echo L_Failed_Text & L_Space_Text & strCommand & L_Space_Text _
                             & L_Text_Error_General03_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Text_Msg_General03_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                         & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

            '
            ' Try getting extended error information
            '
            call LastError()

        end if

   else

        wscript.echo L_Text_Msg_General03_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    ExecJob = iRetval

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
function ParseCommandLine(iAction, strServer, strPrinter, strJob, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text

    dim oArgs
    dim iIndex

    iAction = kActionUnknown
    iIndex = 0

    set oArgs = wscript.Arguments

    while iIndex < oArgs.Count

        select case oArgs(iIndex)

            case "-z"
                iAction = kActionPause

            case "-m"
                iAction = kActionResume

            case "-x"
                iAction = kActionCancel

            case "-l"
                iAction = kActionList

            case "-p"
                iIndex = iIndex + 1
                strPrinter = oArgs(iIndex)

            case "-s"
                iIndex = iIndex + 1
                strServer = RemoveBackslashes(oArgs(iIndex))

            case "-j"
                iIndex = iIndex + 1
                strJob = oArgs(iIndex)

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

    if Err.Number = kErrorSuccess then

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
    wscript.echo L_Empty_Text
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
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General13_Text
    wscript.echo L_Help_Help_General14_Text
    wscript.echo L_Help_Help_General15_Text
    wscript.echo L_Help_Help_General16_Text

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

            wscript.echo L_Text_Msg_General05_Text & L_Space_Text & L_Error_Text _
                         & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                         & Err.Description

        end if

    else

        wscript.echo L_Text_Msg_General04_Text & L_Space_Text & L_Error_Text _
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
'' SIG '' KB4xm2kUt3OhuuVqyIMeDTFOGLaCpXJYI64NQQxGXLqg
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
'' SIG '' ARUwLwYJKoZIhvcNAQkEMSIEIEwHNDVL7Ac8Zck/Q3ix
'' SIG '' LQVKRUMjMJWh1B84XuPtI/SNMDwGCisGAQQBgjcKAxwx
'' SIG '' LgwsUDVpMmFwbndUOTI2ME9jd0tuU0lQak1WTXZNamxx
'' SIG '' b3Q5eEo3OWxaQXVMND0wWgYKKwYBBAGCNwIBDDFMMEqg
'' SIG '' JIAiAE0AaQBjAHIAbwBzAG8AZgB0ACAAVwBpAG4AZABv
'' SIG '' AHcAc6EigCBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' d2luZG93czANBgkqhkiG9w0BAQEFAASCAQAjfZNaWruW
'' SIG '' 8BtqGhML8Zstm8EtuLpaRDmRMvDuxKM2VBM/77P9U1Mc
'' SIG '' bTEmsDJe/kF8SNmg9Lsk9O/ZDcgrMpFyL331y6QwLgtQ
'' SIG '' TlW84D1foo2sbbHf2xiYCAmGpZvnXkKZ9n/0gbHU/YAy
'' SIG '' +r1v5XxtHOfQy67naAdLap9xQbsE1/M1laoi3mtg727x
'' SIG '' 7dTzaWU3WfFlAuMyov4jZDsZMJ+fO7c39LGyDvTPq9ew
'' SIG '' dlgpmRK+nT5XT7KGB7vsoixzxnvzOXKZ7KGFy1CdHYnI
'' SIG '' /jBmsbf3B3yASqisN77dq/DtClTSGpgqTw82lqVz0Sa8
'' SIG '' rPNMZuVJV3Lsq8p3SM9G8bg3oYIXFjCCFxIGCisGAQQB
'' SIG '' gjcDAwExghcCMIIW/gYJKoZIhvcNAQcCoIIW7zCCFusC
'' SIG '' AQMxDzANBglghkgBZQMEAgEFADCCAVkGCyqGSIb3DQEJ
'' SIG '' EAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMBMDEw
'' SIG '' DQYJYIZIAWUDBAIBBQAEINPLKuKeMzPvz1DtyTpFMlo4
'' SIG '' +W5Q90hGJI3iuzHkQFQUAgZibEot4DAYEzIwMjIwNTA3
'' SIG '' MDIyMDM2LjM5N1owBIACAfSggdikgdUwgdIxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJ
'' SIG '' cmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UE
'' SIG '' CxMdVGhhbGVzIFRTUyBFU046M0JENC00QjgwLTY5QzMx
'' SIG '' JTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNl
'' SIG '' cnZpY2WgghFlMIIHFDCCBPygAwIBAgITMwAAAYm0v4Yw
'' SIG '' hBxLjwABAAABiTANBgkqhkiG9w0BAQsFADB8MQswCQYD
'' SIG '' VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
'' SIG '' A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
'' SIG '' IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQg
'' SIG '' VGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMTEwMjgxOTI3
'' SIG '' NDFaFw0yMzAxMjYxOTI3NDFaMIHSMQswCQYDVQQGEwJV
'' SIG '' UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
'' SIG '' UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
'' SIG '' cmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFu
'' SIG '' ZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRo
'' SIG '' YWxlcyBUU1MgRVNOOjNCRDQtNEI4MC02OUMzMSUwIwYD
'' SIG '' VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNl
'' SIG '' MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA
'' SIG '' vQZXxZFma6plmuOyvNpV8xONOwcYolZG/BjyZWGSk5JO
'' SIG '' GaLyrKId5VxVHWHlsmJE4SvnzsdpsKmVx8otONveIUFv
'' SIG '' SceEZp8VXmu5m1fu8L7c+3lwXcibjccqtEvtQslokQVx
'' SIG '' 0r+L54abrNDarwFG73IaRidIS1i9c+unJ8oYyhDRLrCy
'' SIG '' sFAVxyQhPNZkWK7Z8/VGukaKLAWHXCh/+R53h42gFL+9
'' SIG '' /mAALxzCXXuofi8f/XKCm7xNwVc1hONCCz6oq94AufzV
'' SIG '' NkkIW4brUQgYpCcJm9U0XNmQvtropYDn9UtY8YQ0NKen
'' SIG '' XPtdgLHdQ8Nnv3igErKLrWI0a5n5jjdKfwk+8mvakqdZ
'' SIG '' mlOseeOS1XspQNJAK1uZllAITcnQZOcO5ofjOQ33ujWc
'' SIG '' kAXdz+/x3o7l4AU/TSOMzGZMwhUdtVwC3dSbItpSVFgn
'' SIG '' jM2COEJ9zgCadvOirGDLN471jZI2jClkjsJTdgPk343T
'' SIG '' QA4JFvds/unZq0uLr+niZ3X44OBx2x+gVlln2c4UbZXN
'' SIG '' ueA4yS1TJGbbJFIILAmTUA9Auj5eISGTbNiyWx79HnCO
'' SIG '' Tar39QEKozm4LnTmDXy0/KI/H/nYZGKuTHfckP28wQS0
'' SIG '' 6rD+fDS5xLwcRMCW92DkHXmtbhGyRilBOL5LxZelQfxt
'' SIG '' 54wl4WUC0AdAEolPekODwO8CAwEAAaOCATYwggEyMB0G
'' SIG '' A1UdDgQWBBSXbx+zR1p4IIAeguA6rHKkrfl7UDAfBgNV
'' SIG '' HSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNV
'' SIG '' HR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29m
'' SIG '' dC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1l
'' SIG '' LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYIKwYB
'' SIG '' BQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
'' SIG '' Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jv
'' SIG '' c29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEp
'' SIG '' LmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsG
'' SIG '' AQUFBwMIMA0GCSqGSIb3DQEBCwUAA4ICAQCOtLdpWUI4
'' SIG '' KwfLLrfaKrLB92DqbAspGWM41TaO4Jl+sHxPo522uu3G
'' SIG '' KQCjmkRWreHtlfyy9kOk7LWax3k3ke8Gtfetfbh7qH0L
'' SIG '' eV2XOWg39BOnHf6mTcZq7FYSZZch1JDQjc98+Odlow+o
'' SIG '' Wih0Dbt4CV/e19ZcE+1n1zzWkskUEd0f5jPIUis33p+v
'' SIG '' kY8szduAtCcIcPFUhI8Hb5alPUAPMjGzwKb7NIKbnf8j
'' SIG '' 8cP18As5IveckF0oh1cw63RY/vPK62LDYdpi7WnG2Obv
'' SIG '' ngfWVKtwiwTI4jHj2cO9q37HDe/PPl216gSpUZh0ap24
'' SIG '' mKmMDfcKp1N4mEdsxz4oseOrPYeFsHHWJFJ6Aivvqn70
'' SIG '' KTeJpp5r+DxSqbeSy0mxIUOq/lAaUxgNSQVUX26t8r+f
'' SIG '' cikofKv23WHrtRV3t7rVTsB9YzrRaiikmz68K5HWdt9M
'' SIG '' qULxPQPo+ppZ0LRqkOae466+UKRY0JxWtdrMc5vHlHZf
'' SIG '' nqjawj/RsM2S6Q6fa9T9CnY1Nz7DYBG3yZJyCPFsrgU0
'' SIG '' 5s9ljqfsSptpFdUh9R4ce+L71SWDLM2x/1MFLLHAMbXs
'' SIG '' Ep8KloEGtaDULnxtfS2tYhfuKGqRXoEfDPAMnIdTvQPh
'' SIG '' 3GHQ4SjkkBARHL0MY75alhGTKHWjC2aLVOo8obKIBk8h
'' SIG '' fnFDUf/EyVw4uTCCB3EwggVZoAMCAQICEzMAAAAVxedr
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
'' SIG '' A1UECxMdVGhhbGVzIFRTUyBFU046M0JENC00QjgwLTY5
'' SIG '' QzMxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1w
'' SIG '' IFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVACGlCa3ketye
'' SIG '' uey7bJNpWkMuiCcQoIGDMIGApH4wfDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgUENBIDIwMTAwDQYJKoZIhvcNAQEFBQACBQDm
'' SIG '' IALfMCIYDzIwMjIwNTA3MDQyNjA3WhgPMjAyMjA1MDgw
'' SIG '' NDI2MDdaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOYg
'' SIG '' At8CAQAwBwIBAAICBvswBwIBAAICEnIwCgIFAOYhVF8C
'' SIG '' AQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYBBAGEWQoD
'' SIG '' AqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG
'' SIG '' 9w0BAQUFAAOBgQCLTZxqG2Tvc5IVEkGcEKsfxUWIg3BG
'' SIG '' mzNhWwIq75+Ldf6/T6fSqno5oAoTl3nkre6sRWiAAoLv
'' SIG '' RnS8MAdp36eU+OxhZ0EEoPFHc7fOyvOVEOy8A2YfDE74
'' SIG '' wun2GZcNC3epK/6KmPF8319N4sOAdvVW2uXX0iFsC8/j
'' SIG '' bDqhB39FvjGCBA0wggQJAgEBMIGTMHwxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
'' SIG '' LVN0YW1wIFBDQSAyMDEwAhMzAAABibS/hjCEHEuPAAEA
'' SIG '' AAGJMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0B
'' SIG '' CQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZIhvcNAQkEMSIE
'' SIG '' IDPssui9D2roSgx3oJ8CwajSA7rkp/9h77rGerAOEbcx
'' SIG '' MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgZndH
'' SIG '' MdxQV1VsbpWHOTHqWEycvcRJm7cY69l/UmT8j0UwgZgw
'' SIG '' gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
'' SIG '' aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
'' SIG '' ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQD
'' SIG '' Ex1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAIT
'' SIG '' MwAAAYm0v4YwhBxLjwABAAABiTAiBCB7yMSaNdIlM3Cq
'' SIG '' KNK7E64Vfh/5pWyUsspYm+2ieNMxSTANBgkqhkiG9w0B
'' SIG '' AQsFAASCAgAF9WnEkbxjY63aNlwmtUe8ghVkCkMiOF+A
'' SIG '' cLJKVrM7mOoyK/idFr6Vw0Vlc+g7b4wbMWwr01cwGUyW
'' SIG '' hgaywTbbk+SJIoUehRdLhkkev6QmxLXyoW7ed/jzDC/Z
'' SIG '' KYxtK2vFsYDJYacu7pxyk3MbaMhHvviw07zRuXXBi2Fr
'' SIG '' Le79AyjqcV1Jx1l8dwFxnrsVJz55lwvmkK+hxLODtyGG
'' SIG '' vsRXQOYWB8uLMH6qnLBnyM8DBEjv2cvueT8w7N8jQn+v
'' SIG '' gYqwreEA9L+RMks0RCKGNMxLxEFpUCQIeLrh3j7F+1v2
'' SIG '' jt2Fg0+iWOBqKiKbwrz807uwh8ksR1qBecriRd8G8B/e
'' SIG '' WWK+FiZ13zEw5Jq1o607Od9+8wHnU6dxm0RbirEdMFuu
'' SIG '' R3MmTW55KL2qz5kyX22SZhlxkEY6xm9qIKn2PkRVwfYP
'' SIG '' bacfeIPnqKMDq2o22S8dtqeE1xvf6Y5sCcaq6snZl7N6
'' SIG '' KXWSOJyB1Gu5xFgh8/qwMTj+AmdJ2ojHTFEVjRuaMRni
'' SIG '' 62s03D3tnDCGJDW3QW4mg2PFsi6RMXStXjeeun/+vVuq
'' SIG '' QjYWCx/D29aXKm4iXUyDN8T8JryP5LDTyBKItmdO0omw
'' SIG '' viPyWZf6br0tGv5xBCIw9ZWZT9hVQfYNuTWnNSYSyHHu
'' SIG '' asQfsbtfhOP9XsV7fNHODUC10D3SzHegew==
'' SIG '' End signature block
