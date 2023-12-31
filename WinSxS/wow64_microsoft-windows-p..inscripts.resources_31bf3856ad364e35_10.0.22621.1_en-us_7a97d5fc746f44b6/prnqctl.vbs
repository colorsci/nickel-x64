'----------------------------------------------------------------------
'
' Copyright (c) Microsoft Corporation. All rights reserved.
'
' Abstract:
' prnqctl.vbs - printer control script for WMI on Windows 
'    used to pause, resume and purge a printer
'    also used to print a test page on a printer
'
' Usage:
' prnqctl [-zmex?] [-s server] [-p printer] [-u user name] [-w password]
'
' Examples:
' prnqctl -m -s server -p printer
' prnqctl -x -s server -p printer
' prnqctl -e -b printer
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
const kActionPurge      = 3
const kActionTestPage   = 4

const kErrorSuccess     = 0
const KErrorFailure     = 1

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
const L_Help_Help_General01_Text   = "Usage: prnqctl [-zmex?] [-s server][-p printer][-u user name][-w password]"
const L_Help_Help_General02_Text   = "Arguments:"
const L_Help_Help_General03_Text   = "-e     - print test page"
const L_Help_Help_General04_Text   = "-m     - resume the printer"
const L_Help_Help_General05_Text   = "-p     - printer name"
const L_Help_Help_General06_Text   = "-s     - server name"
const L_Help_Help_General07_Text   = "-u     - user name"
const L_Help_Help_General08_Text   = "-w     - password"
const L_Help_Help_General09_Text   = "-x     - purge the printer (cancel all jobs)"
const L_Help_Help_General10_Text   = "-z     - pause the printer"
const L_Help_Help_General11_Text   = "-?     - display command usage"
const L_Help_Help_General12_Text   = "Examples:"
const L_Help_Help_General13_Text   = "prnqctl -e -s server -p printer"
const L_Help_Help_General14_Text   = "prnqctl -m -p printer"
const L_Help_Help_General15_Text   = "prnqctl -x -p printer"

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
const L_Text_Error_General03_Text  = "Unable to get printer instance."
const L_Text_Error_General04_Text  = "Win32 error code"
const L_Text_Error_General05_Text  = "Unable to get SWbemLocator object"
const L_Text_Error_General06_Text  = "Unable to connect to WMI service"


'
' Action strings
'
const L_Text_Action_General01_Text = "Pause"
const L_Text_Action_General02_Text = "Resume"
const L_Text_Action_General03_Text = "Purge"
const L_Text_Action_General04_Text = "Print Test Page"

'
' Debug messages
'
const L_Text_Dbg_Msg01_Text        = "In function ExecPrinter"
const L_Text_Dbg_Msg02_Text        = "Server name"
const L_Text_Dbg_Msg03_Text        = "Printer name"
const L_Text_Dbg_Msg04_Text        = "In function ParseCommandLine"

main

'
' Main execution starts here
'
sub main

    dim iAction
    dim iRetval
    dim strServer
    dim strPrinter
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
    iRetval = ParseCommandLine(iAction, strServer, strPrinter, strUser, strPassword)

    if iRetval = kErrorSuccess then

        select case iAction

            case kActionPause
                 iRetval = ExecPrinter(strServer, strPrinter, strUser, strPassword, L_Text_Action_General01_Text)

            case kActionResume
                 iRetval = ExecPrinter(strServer, strPrinter, strUser, strPassword, L_Text_Action_General02_Text)

            case kActionPurge
                 iRetval = ExecPrinter(strServer, strPrinter, strUser, strPassword, L_Text_Action_General03_Text)

            case kActionTestPage
                 iRetval = ExecPrinter(strServer, strPrinter, strUser, strPassword, L_Text_Action_General04_Text)

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
' Pause/Resume/Purge printer and print test page
'
function ExecPrinter(strServer, strPrinter, strUser, strPassword, strCommand)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg01_Text
    DebugPrint kDebugTrace, L_Text_Dbg_Msg02_Text & L_Space_Text & strServer
    DebugPrint kDebugTrace, L_Text_Dbg_Msg03_Text & L_Space_Text & strPrinter

    dim oPrinter
    dim oService
    dim iRetval
    dim uResult

    iRetval = kErrorFailure

    if WmiConnect(strServer, kNameSpace, strUser, strPassword, oService) then

        set oPrinter = oService.Get("Win32_Printer.DeviceID='" & strPrinter & "'")

    else

        ExecPrinter = kErrorFailure

        exit function

    end if

    '
    ' Check if getting a printer instance succeeded
    '
    if Err.Number = kErrorSuccess then

        select case strCommand

            case L_Text_Action_General01_Text
                 uResult = oPrinter.Pause()

            case L_Text_Action_General02_Text
                 uResult = oPrinter.Resume()

            case L_Text_Action_General03_Text
                 uResult = oPrinter.CancelAllJobs()

            case L_Text_Action_General04_Text
                 uResult = oPrinter.PrintTestPage()

            case else
                 Usage(true)

        end select

        '
        ' Err set by WMI
        '
        if Err.Number = kErrorSuccess then

            '
            ' uResult set by printer methods
            '
            if uResult = kErrorSuccess then

                wscript.echo L_Success_Text & L_Space_Text & strCommand & L_Space_Text _
                             & L_Printer_Text & L_Space_Text & strPrinter

                iRetval = kErrorSuccess

            else

                wscript.echo L_Failed_Text & L_Space_Text & strCommand & L_Space_Text _
                             & L_Text_Error_General04_Text & L_Space_Text & uResult

            end if

        else

            wscript.echo L_Failed_Text & L_Space_Text & strCommand & L_Space_Text & L_Error_Text _
                         & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        end if

    else

        wscript.echo L_Text_Error_General03_Text & L_Space_Text & L_Error_Text & L_Space_Text _
                     & L_Hex_Text & hex(Err.Number) & L_Space_Text & Err.Description

        '
        ' Try getting extended error information
        '
        call LastError()

    end if

    ExecPrinter = iRetval

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
function ParseCommandLine(iAction, strServer, strPrinter, strUser, strPassword)

    on error resume next

    DebugPrint kDebugTrace, L_Text_Dbg_Msg04_Text

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
                iAction = kActionPurge

            case "-e"
                iAction = kActionTestPage

            case "-p"
                iIndex = iIndex + 1
                strPrinter = oArgs(iIndex)

            case "-s"
                iIndex = iIndex + 1
                strServer = RemoveBackslashes(oArgs(iIndex))

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
    wscript.echo L_Empty_Text
    wscript.echo L_Help_Help_General12_Text
    wscript.echo L_Help_Help_General13_Text
    wscript.echo L_Help_Help_General14_Text
    wscript.echo L_Help_Help_General15_Text

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

          Err.Clear

      else

          wscript.echo L_Text_Error_General06_Text & L_Space_Text & L_Error_Text _
                       & L_Space_Text & L_Hex_Text & hex(Err.Number) & L_Space_Text _
                       & Err.Description

      end if

   else

       wscript.echo L_Text_Error_General05_Text & L_Space_Text & L_Error_Text _
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
'' SIG '' MIIlaQYJKoZIhvcNAQcCoIIlWjCCJVYCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' bC2hk3cvC4yTgr8z1VD7j98e4AUJNisLu9VlGTQcB1Gg
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
'' SIG '' l5/LV4BvM6kEz3ekYhxZfjGCGeAwghncAgEBMIGcMIGE
'' SIG '' MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
'' SIG '' bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
'' SIG '' cm9zb2Z0IENvcnBvcmF0aW9uMS4wLAYDVQQDEyVNaWNy
'' SIG '' b3NvZnQgV2luZG93cyBQcm9kdWN0aW9uIFBDQSAyMDEx
'' SIG '' AhMzAAADO2VfrvrbdenWAAAAAAM7MA0GCWCGSAFlAwQC
'' SIG '' AQUAoIIBBDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
'' SIG '' BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
'' SIG '' BgkqhkiG9w0BCQQxIgQgpOivkxBpxkA4g5pmp0AzZNDL
'' SIG '' a+cSvBt7D0xQ8URqbs8wPAYKKwYBBAGCNwoDHDEuDCw2
'' SIG '' RXl1R2lPOHBLYUNTVXVncmVLTW9Kd2NWK0pQdWp3VExy
'' SIG '' UDdHdzI5WDhRPTBaBgorBgEEAYI3AgEMMUwwSqAkgCIA
'' SIG '' TQBpAGMAcgBvAHMAbwBmAHQAIABXAGkAbgBkAG8AdwBz
'' SIG '' oSKAIGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS93aW5k
'' SIG '' b3dzMA0GCSqGSIb3DQEBAQUABIIBAA0TP1nX24IpUIpl
'' SIG '' 0+6fGDz57YPCQnAj6XosLcy/NKWeeWZHDVfSPptpNFay
'' SIG '' F0yx+uo1ju52cpDAwEHxlq4+WwfD/+PuEN5F8V+7Mbhx
'' SIG '' XGFZtvgm7rMQVdeB3TqNCwlc/tFXX4GdxF8EAaKJrXiv
'' SIG '' aGgvWWHrh5dCwWw9EQZNgddMc14tlOVnlC9WRkoBHK2I
'' SIG '' atARaZnymByAWxmHndlV7vvtg6ra3wCbjuGGM2wmr+Ig
'' SIG '' xwaJK0ybeAT/Oc/e3GSRskHxJ6a9e9/aBY+4gUGriLD5
'' SIG '' S1FQGPy3WfEEcRIMK7QthkDyeC/b4dYcQRRL1Nx1Wjck
'' SIG '' nRBGv5UYt8LdGBBuDkqhghcMMIIXCAYKKwYBBAGCNwMD
'' SIG '' ATGCFvgwghb0BgkqhkiG9w0BBwKgghblMIIW4QIBAzEP
'' SIG '' MA0GCWCGSAFlAwQCAQUAMIIBVQYLKoZIhvcNAQkQAQSg
'' SIG '' ggFEBIIBQDCCATwCAQEGCisGAQQBhFkKAwEwMTANBglg
'' SIG '' hkgBZQMEAgEFAAQgZ/roieJV9PQPLuTy3qngoooZpXCj
'' SIG '' 1MtgdGezABp9F10CBmJrSl6LphgTMjAyMjA1MDcwMjIw
'' SIG '' MzcuMDg3WjAEgAIB9KCB1KSB0TCBzjELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEpMCcGA1UECxMgTWljcm9zb2Z0IE9wZXJh
'' SIG '' dGlvbnMgUHVlcnRvIFJpY28xJjAkBgNVBAsTHVRoYWxl
'' SIG '' cyBUU1MgRVNOOjYwQkMtRTM4My0yNjM1MSUwIwYDVQQD
'' SIG '' ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIR
'' SIG '' XzCCBxAwggT4oAMCAQICEzMAAAGmWUWDOU2e60sAAQAA
'' SIG '' AaYwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMx
'' SIG '' EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
'' SIG '' ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
'' SIG '' dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3Rh
'' SIG '' bXAgUENBIDIwMTAwHhcNMjIwMzAyMTg1MTIxWhcNMjMw
'' SIG '' NTExMTg1MTIxWjCBzjELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEp
'' SIG '' MCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMgUHVl
'' SIG '' cnRvIFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNO
'' SIG '' OjYwQkMtRTM4My0yNjM1MSUwIwYDVQQDExxNaWNyb3Nv
'' SIG '' ZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG
'' SIG '' 9w0BAQEFAAOCAg8AMIICCgKCAgEA2Zi/e1Ij58n81Ame
'' SIG '' PPsm8Kdz5ebSsqh71goPgy8xgK6Xt6B2tP/O/m8VtCCM
'' SIG '' 1DvjrvZ83B5rO2RHrlXzLb27k8vax/TWn65yF7Rm7i1K
'' SIG '' KD4axDplCX22M9EBj/chMEcN4hjK+rxad737s2g8uHEN
'' SIG '' I7p21ftgK5DjNxM/dIToy8Hhvk2KCF22+hlVpiTWVemN
'' SIG '' RN92YqhfUAGrWwltQtKdKLRB3i++XeZn2PHC/11H+eVk
'' SIG '' /raWtlhmrss+0cPoGWZyUHk9Pz0OdKbWyNpmcUesrM6y
'' SIG '' arkaWYvlIW6AIJk6grPXfcUl5BoUxxcFlIJCM0AFYFsc
'' SIG '' hEITXKwccbzcN2idGacLwQ6Vh5HBNbP9ALPqrSuI4htj
'' SIG '' IL8DYGBQSm73/0TKatOzIyvb/NLwZ0TJtDlbt/RatyuY
'' SIG '' oH9jrb6DpOZ85Lw21T4vWMago0bpDlGV8nBm7wn9D12X
'' SIG '' g7HIcq7Lvz7CboewXu4CLOmxaHrdRRqgr84ZCIEbc0n6
'' SIG '' R5/l5ame9rhkl+ECephMBkPW4eB/xV9COeXQEHZhfMr1
'' SIG '' ZpOp17x37yoLFUqvmEli9s75ff7aTk8KKtQr9Juit5f7
'' SIG '' FSFVpASFUNiqVq3I+20jtnYiuSEzPAW9z6nRB7IyI2aj
'' SIG '' ZwFl6PHyJwM5xSJ3DKYNRioY8TswDy+0pbd955JJgmwI
'' SIG '' SS5Q7+8CAwEAAaOCATYwggEyMB0GA1UdDgQWBBQ6VCE7
'' SIG '' /MaWor31SQ0v8a78CvI32DAfBgNVHSMEGDAWgBSfpxVd
'' SIG '' AF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQ
'' SIG '' hk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
'' SIG '' L2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENB
'' SIG '' JTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwG
'' SIG '' CCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
'' SIG '' b20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUt
'' SIG '' U3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMB
'' SIG '' Af8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqG
'' SIG '' SIb3DQEBCwUAA4ICAQCAwPFYNOkaoucWg+Gb+IN/AcYX
'' SIG '' zGvY1usmXx6ASDZOFMmxN/TAET5lCydh+tGZcFt7qwJc
'' SIG '' tU3vSo+4j44Rs3kw5qLsG57X/iPlVORaq4fkZl5Vq3Y3
'' SIG '' 50PuVJRanR1TyP64GEEvkYVKagNVWb7NbYZHaO48jW/b
'' SIG '' ngAlNvaXjnxqeWQmMa+ZifYG1FLXeH/ANHuGtBojsGB3
'' SIG '' IdYBXn4cSPlSGsiuu+3AmKK9JpQQDeorpkr+tkhC/+45
'' SIG '' EOQ43D7akccgTVJeb9YiWGtVLYciiB+vcmOq9mKifosl
'' SIG '' IPvjWPzFUMuIKXABuykehUWPG3EFwyOo/HppYIlLy+NK
'' SIG '' hOeGRXg87nmaqwztDxdBEZCEDvDjM1A4m72QPjEV1ik9
'' SIG '' SYs391ohwQSWh8GMbP6wR3UHjKqoiTe7YbhXKBNcWa2E
'' SIG '' vxyFKjuv4Yi9OpYqFID+xqdLg3eMKAIJ7cVNImyniDmf
'' SIG '' Bq8u9YC3Nw4i9JGisaYB43SbbCDMEr3lP+qCsYYNdKiz
'' SIG '' Uk0NZFUGc/SqzDVCirkbQPyHG9A+zdfjcoG/UYmXTCjm
'' SIG '' twL704xbEmUHreC1OhCwDUIStihgsxm1TMkvviPBmT+C
'' SIG '' ukcRCEiEHeyd4LzDMYom5+3tg78dYKm7B0KEiPKdOcGH
'' SIG '' 7IUYx2DfBGshs5zD+IqZdmikxNAw5yYh4jAkB7MDsDCC
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
'' SIG '' cGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLSMIIC
'' SIG '' OwIBATCB/KGB1KSB0TCBzjELMAkGA1UEBhMCVVMxEzAR
'' SIG '' BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
'' SIG '' bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
'' SIG '' bjEpMCcGA1UECxMgTWljcm9zb2Z0IE9wZXJhdGlvbnMg
'' SIG '' UHVlcnRvIFJpY28xJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
'' SIG '' RVNOOjYwQkMtRTM4My0yNjM1MSUwIwYDVQQDExxNaWNy
'' SIG '' b3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYF
'' SIG '' Kw4DAhoDFQBqdDOtlb1MH3dV7s9rhQ9qjZ98raCBgzCB
'' SIG '' gKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
'' SIG '' aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
'' SIG '' ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
'' SIG '' HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0G
'' SIG '' CSqGSIb3DQEBBQUAAgUA5iBUfzAiGA8yMDIyMDUwNzA2
'' SIG '' MTQyM1oYDzIwMjIwNTA4MDYxNDIzWjB3MD0GCisGAQQB
'' SIG '' hFkKBAExLzAtMAoCBQDmIFR/AgEAMAoCAQACAiZEAgH/
'' SIG '' MAcCAQACAhEzMAoCBQDmIaX/AgEAMDYGCisGAQQBhFkK
'' SIG '' BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
'' SIG '' CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAfVsN
'' SIG '' Y3rkDu24KvA/dTdaQglR8yC7vW0hkxZmSGLc/80V6LNJ
'' SIG '' V3lGKLhuGqV4NZ29Dy7G9A6S1omMCIyB6KK7IKjR+gOI
'' SIG '' RUpLVAS2yNJ3aCQvVszmI8a7LAwH7KNQezybktzYpXR6
'' SIG '' Vb7j1lvObB/w3CPI51TI/+AwKbe3KszyaWIxggQNMIIE
'' SIG '' CQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
'' SIG '' VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
'' SIG '' MAITMwAAAaZZRYM5TZ7rSwABAAABpjANBglghkgBZQME
'' SIG '' AgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJ
'' SIG '' EAEEMC8GCSqGSIb3DQEJBDEiBCDFWtJlDX8F5R+ji+aa
'' SIG '' KHnp3aMydY1bUHVCfnVIs9ppqDCB+gYLKoZIhvcNAQkQ
'' SIG '' Ai8xgeowgecwgeQwgb0EIIMLGYvDP3R9a+EwpslMBBoq
'' SIG '' 3cOhd6ICF+nxMP22BKsNMIGYMIGApH4wfDELMAkGA1UE
'' SIG '' BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
'' SIG '' BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
'' SIG '' b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
'' SIG '' bWUtU3RhbXAgUENBIDIwMTACEzMAAAGmWUWDOU2e60sA
'' SIG '' AQAAAaYwIgQgX3paZTEikDK2Ym8Lv36qzSN1RQbTD2Th
'' SIG '' heeRNYCpEoIwDQYJKoZIhvcNAQELBQAEggIAXGgEDAve
'' SIG '' +Y5jJP8/aPGCbGBT58CezD5IwqUaOIU10yM2QhUj5x36
'' SIG '' DaiQmH3Zy0DtBQ6JUVZgGLj01Cg3CYdwP0hCDiZfnD/C
'' SIG '' /euCmLxv4nlJq8tpHiTxf3ct0IV053fzPLC3RyFjidyR
'' SIG '' EgvaI/bcdwX0QK1To5qL4QXlXfHLTyoJiCXPPbBXmd4d
'' SIG '' LZvbssuCel4RolFVazSTAT+2QaYW2fyzfCLupUpH83vv
'' SIG '' 0uYxQAUSw79onQNAWI2owsGSuAeyY0lpgPdNQEzvLz/o
'' SIG '' v5+//hrbcgLiydSMDU83U8rAtwWJkXcYvXAgkTRM5oFm
'' SIG '' ZjX0FsBvLlWDvuoTvKSSVL/W+OCVPPPhtgFUVxqU/7Yb
'' SIG '' vcJSvJfyRkUXcbiXVheKIsuL95+xhUsEbJb3bXOaqcWo
'' SIG '' SRggTOqtOI1Tf6/KuPwmBChUZYJfMSP1pzrt01KO7vPR
'' SIG '' jFV84C+WKs7EBv4hpaDw0osRx1ZClCRR8NNeuRMVL+zx
'' SIG '' dvbimGkWKRpXYR7LtRlzMR1wS0Z86UjbsMoPW34rN6BH
'' SIG '' J96uuo5N67DjX5RhmUj8zm9USwyWlcQag9U9SH1xVWkf
'' SIG '' gn4iHifLr6+reZ6Lvqcmd7lpUa0vnKIAaJAUn9eoLZsT
'' SIG '' I5DRMtz5xo2fd/xIfjIZCNiOV0p6UW3G6E8kE60MdrTz
'' SIG '' 1W625TjEE8S13Co=
'' SIG '' End signature block
