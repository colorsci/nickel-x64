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
'' SIG '' MIIlXQYJKoZIhvcNAQcCoIIlTjCCJUoCAQExDzANBglg
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
'' SIG '' l5/LV4BvM6kEz3ekYhxZfjGCGdQwghnQAgEBMIGcMIGE
'' SIG '' MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
'' SIG '' bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
'' SIG '' cm9zb2Z0IENvcnBvcmF0aW9uMS4wLAYDVQQDEyVNaWNy
'' SIG '' b3NvZnQgV2luZG93cyBQcm9kdWN0aW9uIFBDQSAyMDEx
'' SIG '' AhMzAAADO2VfrvrbdenWAAAAAAM7MA0GCWCGSAFlAwQC
'' SIG '' AQUAoIIBBDAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
'' SIG '' BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAv
'' SIG '' BgkqhkiG9w0BCQQxIgQgpOivkxBpxkA4g5pmp0AzZNDL
'' SIG '' a+cSvBt7D0xQ8URqbs8wPAYKKwYBBAGCNwoDHDEuDCxR
'' SIG '' N3dBWGcxVGQvY2NFRTJXNU5OcmcrRkY2TllHZEdVbGNO
'' SIG '' L05NbHZPWGUwPTBaBgorBgEEAYI3AgEMMUwwSqAkgCIA
'' SIG '' TQBpAGMAcgBvAHMAbwBmAHQAIABXAGkAbgBkAG8AdwBz
'' SIG '' oSKAIGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS93aW5k
'' SIG '' b3dzMA0GCSqGSIb3DQEBAQUABIIBAIWwcxVHE+DCBk69
'' SIG '' rNxkxi67QWa+pbWZ61XJgcyfH3QPKfFVMtt41C0D5U3i
'' SIG '' tzC37tBpaCvr7F6aRtM0ExyoL+cQZdj5f+ksrwo1XSg4
'' SIG '' 9i5buOkLPe7Z26EumW79muVrpyixcdjAbUXqQwd4Ogfu
'' SIG '' WxJ/NeqE5XeS0wq1tqm4giBUHIClRYgi76ok6lfjY+kn
'' SIG '' Is6Xqz6hdo3baGOE+HGry/7dncxM4S5HtzwEDWPWmPSZ
'' SIG '' 8KIuFX/Sflrzq01F+k2fHqUpslgZFenLG6LcYqF+J3Kx
'' SIG '' X0Wi3bvo8lVX1jB/P8kmzTGNvSd1lgznEofB9pXQkNyj
'' SIG '' fo2AK81aRpvSQfDpAd6hghcAMIIW/AYKKwYBBAGCNwMD
'' SIG '' ATGCFuwwghboBgkqhkiG9w0BBwKgghbZMIIW1QIBAzEP
'' SIG '' MA0GCWCGSAFlAwQCAQUAMIIBUQYLKoZIhvcNAQkQAQSg
'' SIG '' ggFABIIBPDCCATgCAQEGCisGAQQBhFkKAwEwMTANBglg
'' SIG '' hkgBZQMEAgEFAAQgqznKv9fecd1MBJnKnhyS2FMfb1T8
'' SIG '' FSKzZI2GNwoi2ecCBmJpvkEdkBgTMjAyMjA1MDcwMzI3
'' SIG '' NDMuOTIzWjAEgAIB9KCB0KSBzTCByjELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
'' SIG '' Y2EgT3BlcmF0aW9uczEmMCQGA1UECxMdVGhhbGVzIFRT
'' SIG '' UyBFU046REQ4Qy1FMzM3LTJGQUUxJTAjBgNVBAMTHE1p
'' SIG '' Y3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghFXMIIH
'' SIG '' DDCCBPSgAwIBAgITMwAAAZwPpk1h0p5LKAABAAABnDAN
'' SIG '' BgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEG
'' SIG '' A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
'' SIG '' ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
'' SIG '' MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
'' SIG '' Q0EgMjAxMDAeFw0yMTEyMDIxOTA1MTlaFw0yMzAyMjgx
'' SIG '' OTA1MTlaMIHKMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYD
'' SIG '' VQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
'' SIG '' MSYwJAYDVQQLEx1UaGFsZXMgVFNTIEVTTjpERDhDLUUz
'' SIG '' MzctMkZBRTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQAD
'' SIG '' ggIPADCCAgoCggIBANtSKgwZXUkWP6zrXazTaYq7bco9
'' SIG '' Q2zvU6MN4ka3GRMX2tJZOK4DxeBiQACL/n7YV/sKTslw
'' SIG '' pD0f9cPU4rCDX9sfcTWo7XPxdHLQ+WkaGbKKWATsqw69
'' SIG '' bw8hkJ/bjcp2V2A6vGsvwcqJCh07BK3JPmUtZikyy5PZ
'' SIG '' 8fyTyiKGN7hOWlaIU9oIoucUNoAHQJzLq8h20eNgHUh7
'' SIG '' eI5k+Kyq4v6810LHuA6EHyKJOZN2xTw5JSkLy0FN5Mhg
'' SIG '' /OaFrFBl3iag2Tqp4InKLt+Jbh/Jd0etnei2aDHFrmlf
'' SIG '' PmlRSv5wSNX5zAhgEyRpjmQcz1zp0QaSAefRkMm923/n
'' SIG '' gU51IbrVbAeHj569SHC9doHgsIxkh0K3lpw582+0ONXc
'' SIG '' IfIU6nkBT+qADAZ+0dT1uu/gRTBy614QAofjo258TbSX
'' SIG '' 9aOU1SHuAC+3bMoyM7jNdHEJROH+msFDBcmJRl4VKsRe
'' SIG '' I5+S69KUGeLIBhhmnmQ6drF8Ip0ZiO+vhAsD3e9AnqnY
'' SIG '' 7Hcge850I9oKvwuwpVwWnKnwwSGElMz7UvCocmoUMXk7
'' SIG '' Vn2aNti+bdH28+GQb5EMsqhOmvuZOCRpOWN33G+b3g5u
'' SIG '' nwEP0eTiY+LnWa2AuK43z/pplURJVle29K42QPkOcglB
'' SIG '' 6sjLmNpEpb9basJ72eA0Mlp1LtH3oYZGXsggTfuXAgMB
'' SIG '' AAGjggE2MIIBMjAdBgNVHQ4EFgQUu2kJZ1Ndjl2112Sy
'' SIG '' nL6jGMID+rIwHwYDVR0jBBgwFoAUn6cVXQBeYl2D9OXS
'' SIG '' ZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDov
'' SIG '' L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWlj
'' SIG '' cm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAo
'' SIG '' MSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcw
'' SIG '' AoZQaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
'' SIG '' cy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIw
'' SIG '' UENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAT
'' SIG '' BgNVHSUEDDAKBggrBgEFBQcDCDANBgkqhkiG9w0BAQsF
'' SIG '' AAOCAgEApwAqpiMYRzNNYyz3PSbtijbeyCpUXcvIrqA4
'' SIG '' zPtMIcAk34W9u9mRDndWS+tlR3WwTpr1OgaV1wmc6YFz
'' SIG '' qK6EGWm903UEsFE7xBJMPXjfdVOPhcJB3vfvA0PX56oo
'' SIG '' bcF2OvNsOSwTB8bi/ns+Cs39Puzs+QSNQZd8iAVBCSvx
'' SIG '' NCL78dln2RGU1xyB4AKqV9vi4Y/Gfmx2FA+jF0y+YLeo
'' SIG '' b0M40nlSxL0q075t7L6iFRMNr0u8ROhzhDPLl+4ePYfU
'' SIG '' myYJoobvydel9anAEsHFlhKl+aXb2ic3yNwbsoPycZJL
'' SIG '' /vo8OVvYYxCy+/5FrQmAvoW0ZEaBiYcKkzrNWt/hX9r5
'' SIG '' KgdwL61x0ZiTZopTko6W/58UTefTbhX7Pni0MApH3Pvy
'' SIG '' t6N0IFap+/LlwFRD1zn7e6ccPTwESnuo/auCmgPznq80
'' SIG '' OATA7vufsRZPvqeX8jKtsraSNscvNQymEWlcqdXV9hYk
'' SIG '' jb4T/Qse9cUYaoXg68wFHFuslWfTdPYPLl1vqzlPMnNJ
'' SIG '' pC8KtdioDgcq+y1BaSqSm8EdNfwzT37+/JFtVc3Gs915
'' SIG '' fDqgPZDgOSzKQIV+fw3aPYt2LET3AbmKKW/r13Oy8cg3
'' SIG '' +D0D362GQBAJVv0NRI5NowgaCw6oNgWOFPrN72WSEcca
'' SIG '' /8QQiTGP2XpLiGpRDJZ6sWRpRYNdydkwggdxMIIFWaAD
'' SIG '' AgECAhMzAAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3
'' SIG '' DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
'' SIG '' V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
'' SIG '' A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
'' SIG '' VQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBB
'' SIG '' dXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0z
'' SIG '' MDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYD
'' SIG '' VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
'' SIG '' MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
'' SIG '' JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
'' SIG '' QSAyMDEwMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
'' SIG '' CgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP97pwHB9Kp
'' SIG '' bE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5K
'' SIG '' Wv64NmeFRiMMtY0Tz3cywBAY6GB9alKDRLemjkZrBxTz
'' SIG '' xXb1hlDcwUTIcVxRMTegCjhuje3XD9gmU3w5YQJ6xKr9
'' SIG '' cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl
'' SIG '' 3GoPz130/o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3K
'' SIG '' Ni1wjjHINSi947SHJMPgyY9+tVSP3PoFVZhtaDuaRr3t
'' SIG '' pK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5Jas
'' SIG '' AUq7vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ
'' SIG '' 1v2lIH1+/NmeRd+2ci/bfV+AutuqfjbsNkz2K26oElHo
'' SIG '' vwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz
'' SIG '' 1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymei
'' SIG '' XtcodgLiMxhy16cg8ML6EgrXY28MyTZki1ugpoMhXV8w
'' SIG '' dJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/ZcUlFd
'' SIG '' Etsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94
'' SIG '' q0W29R6HXtqPnhZyacaue7e3PmriLq0CAwEAAaOCAd0w
'' SIG '' ggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJKwYBBAGC
'' SIG '' NxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1Ud
'' SIG '' DgQWBBSfpxVdAF5iXYP05dJlpxtTNRnpcjBcBgNVHSAE
'' SIG '' VTBTMFEGDCsGAQQBgjdMg30BATBBMD8GCCsGAQUFBwIB
'' SIG '' FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3Bz
'' SIG '' L0RvY3MvUmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYI
'' SIG '' KwYBBQUHAwgwGQYJKwYBBAGCNxQCBAweCgBTAHUAYgBD
'' SIG '' AEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8w
'' SIG '' HwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQw
'' SIG '' VgYDVR0fBE8wTTBLoEmgR4ZFaHR0cDovL2NybC5taWNy
'' SIG '' b3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9v
'' SIG '' Q2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEB
'' SIG '' BE4wTDBKBggrBgEFBQcwAoY+aHR0cDovL3d3dy5taWNy
'' SIG '' b3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXRf
'' SIG '' MjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIB
'' SIG '' AJ1VffwqreEsH2cBMSRb4Z5yS/ypb+pcFLY+TkdkeLEG
'' SIG '' k5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7bNGhlBgi
'' SIG '' 7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce57
'' SIG '' 32pvvinLbtg/SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OO
'' SIG '' PcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2EhIRXT0n4ECW
'' SIG '' OKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWK
'' SIG '' NsIdw2FzLixre24/LAl4FOmRsqlb30mjdAy87JGA0j3m
'' SIG '' Sj5mO0+7hvoyGtmW9I/2kQH2zsZ0/fZMcm8Qq3UwxTSw
'' SIG '' ethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23K
'' SIG '' jgm9swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4
'' SIG '' S5pu+yFUa2pFEUep8beuyOiJXk+d0tBMdrVXVAmxaQFE
'' SIG '' fnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+
'' SIG '' pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/
'' SIG '' Cuk0+CQ1ZyvgDbjmjJnW4SLq8CdCPSWU5nR0W2rRnj7t
'' SIG '' fqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N7oJt
'' SIG '' pQUQwXEGahC0HVUzWLOhcGbyoYICzjCCAjcCAQEwgfih
'' SIG '' gdCkgc0wgcoxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
'' SIG '' YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD
'' SIG '' VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNV
'' SIG '' BAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMx
'' SIG '' JjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOkREOEMtRTMz
'' SIG '' Ny0yRkFFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1T
'' SIG '' dGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQDN2Wnq
'' SIG '' 3fCz9ucStub1zQz7129TQKCBgzCBgKR+MHwxCzAJBgNV
'' SIG '' BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
'' SIG '' VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
'' SIG '' Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBU
'' SIG '' aW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBBQUA
'' SIG '' AgUA5iAZ6DAiGA8yMDIyMDUwNzA2MDQyNFoYDzIwMjIw
'' SIG '' NTA4MDYwNDI0WjB3MD0GCisGAQQBhFkKBAExLzAtMAoC
'' SIG '' BQDmIBnoAgEAMAoCAQACAhQcAgH/MAcCAQACAhJHMAoC
'' SIG '' BQDmIWtoAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisG
'' SIG '' AQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAw
'' SIG '' DQYJKoZIhvcNAQEFBQADgYEAua+R2AVMP2JabVktGxGn
'' SIG '' knEDRl63mrU/6D4Dhc8DUpJBtIhUAzYiwNLDPbMTOq3d
'' SIG '' sbi0OTbYqc+hbmIISaJfGFBSCzqmE2MLWPYspOC8oBBT
'' SIG '' CzSPr4+sy8Hegi+a/LvtwhXEsMxmqkVwtqivnCV4Uwdm
'' SIG '' cyazJHgjSbvc0U6lYLIxggQNMIIECQIBATCBkzB8MQsw
'' SIG '' CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
'' SIG '' MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
'' SIG '' b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3Nv
'' SIG '' ZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAZwPpk1h
'' SIG '' 0p5LKAABAAABnDANBglghkgBZQMEAgEFAKCCAUowGgYJ
'' SIG '' KoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3
'' SIG '' DQEJBDEiBCAAUg8UYe75GYgY0D/qKC8zZaVI7NBQ+DgN
'' SIG '' tUlXxTB8vzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQw
'' SIG '' gb0EIDcPRYUgjSzKOhF39d4QgbRZQgrPO7Lo/qE5GtvS
'' SIG '' eqa8MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNV
'' SIG '' BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
'' SIG '' HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEm
'' SIG '' MCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
'' SIG '' IDIwMTACEzMAAAGcD6ZNYdKeSygAAQAAAZwwIgQgAHAq
'' SIG '' EnvUlGbVLtNwco330WEFviEiDM8ExKGcA4vOrQgwDQYJ
'' SIG '' KoZIhvcNAQELBQAEggIAzuWF8QbkwabHreaaYAhUlOoH
'' SIG '' AAUgH7qOu4qEQpyOw4gubmCI3LlL4dVDN8a7ck54dvJ0
'' SIG '' Lykhj2MCIyXZzXn34RutSsDo0QO8w5RoNdzcQckQRNBA
'' SIG '' 9+HH0uM/NPSXSjmXawTJ/IFfLsx3navjYf/f4j77Y97N
'' SIG '' 8TDFxreggQvwAH7kgcCtEma8h3YRbpQzhtz9WX+vdHif
'' SIG '' bBqbWq5GmJ0+aDWV1r3TIhNYnmDd+LccbMf3/Es1aGAF
'' SIG '' Pe01AAUyOmaE8wwdU7cOXOalhCF1lwcEgH4jHyFn3esj
'' SIG '' GxNUS/HSS701ER384CrU/BmPROkDCv9sVlmIqUF43Y7b
'' SIG '' vOmiO0+mV8M8Oaw85BS4u98eIloyrbunDoTm/AbCyBef
'' SIG '' lHl5rzZs0O/VEGq2gzJjUrkBFi2vLOTKwVGmwD7MFk88
'' SIG '' RsTkMhTHEZWNBNx6HDjyT/9KSosPTJBuAqmHSWlmQ8PB
'' SIG '' 3IC3TCQK+3bEWznsn9dCk91FVX+fbpTGCmLg5bWqr9qs
'' SIG '' kuF9ntbrqOW9muMlHQQeYCwzoW6NlJ2w8sAOLxUTZVHS
'' SIG '' 0YHiMKRFxVIwfRB2xA9QCXCC6esbVI0Tdy4awwOEugFO
'' SIG '' GI2UTh+yCfHAIxzTPHmqXe5KSri/Bu/9nZJj378fqG4f
'' SIG '' JNT389MekupdeR0D0q7wUOZ36FslhrVJOO71USZspAg=
'' SIG '' End signature block
