'----------------------------------------------------------------------
'    pubprn.vbs - publish printers from a non Windows 2000 server into Windows 2000 DS
'    
'
'     Arguments are:-
'        server - format server
'        DS container - format "LDAP:\\CN=...,DC=...."
'
'
'    Copyright (c) Microsoft Corporation 1997
'   All Rights Reserved
'----------------------------------------------------------------------

'--- Begin Error Strings ---

Dim L_PubprnUsage1_text
Dim L_PubprnUsage2_text
Dim L_PubprnUsage3_text      
Dim L_PubprnUsage4_text      
Dim L_PubprnUsage5_text      
Dim L_PubprnUsage6_text      

Dim L_GetObjectError1_text
Dim L_GetObjectError2_text

Dim L_PublishError1_text
Dim L_PublishError2_text     
Dim L_PublishError3_text
Dim L_PublishSuccess1_text


L_PubprnUsage1_text      =   "Usage: [cscript] pubprn.vbs server ""LDAP://OU=..,DC=..."""
L_PubprnUsage2_text      =   "       server is a Windows server name (e.g.: Server) or UNC printer name (\\Server\Printer)"
L_PubprnUsage3_text      =   "       ""LDAP://CN=...,DC=..."" is the DS path of the target container"
L_PubprnUsage4_text      =   ""
L_PubprnUsage5_text      =   "Example 1: pubprn.vbs MyServer ""LDAP://CN=MyContainer,DC=MyDomain,DC=Company,DC=Com"""
L_PubprnUsage6_text      =   "Example 2: pubprn.vbs \\MyServer\Printer ""LDAP://CN=MyContainer,DC=MyDomain,DC=Company,DC=Com"""

L_GetObjectError1_text   =   "Error: Path "
L_GetObjectError2_text   =   " not found."
L_GetObjectError3_text   =   "Error: Unable to access "

L_PublishError1_text     =   "Error: Pubprn cannot publish printers from "
L_PublishError2_text     =   " because it is running Windows 2000, or later."
L_PublishError3_text     =   "Failed to publish printer "
L_PublishError4_text     =   "Error: "
L_PublishSuccess1_text   =   "Published printer: "

'--- End Error Strings ---


set Args = Wscript.Arguments
if args.count < 2 then
    wscript.echo L_PubprnUsage1_text
    wscript.echo L_PubprnUsage2_text
    wscript.echo L_PubprnUsage3_text
    wscript.echo L_PubprnUsage4_text
    wscript.echo L_PubprnUsage5_text
    wscript.echo L_PubprnUsage6_text
    wscript.quit(1)
end if

ServerName= args(0)
Container = args(1)

if 1 <> InStr(1, Container, "LDAP://", vbTextCompare) then
    wscript.echo L_GetObjectError1_text & Container & L_GetObjectError2_text
    wscript.quit(1)
end if

on error resume next
Set PQContainer = GetObject(Container)

if err then
    wscript.echo L_GetObjectError1_text & Container & L_GetObjectError2_text
    wscript.quit(1)
end if
on error goto 0



if left(ServerName,1) = "\" then

    PublishPrinter ServerName, ServerName, Container

else

    on error resume next

    Set PrintServer = GetObject("WinNT://" & ServerName & ",computer")

    if err then
        wscript.echo L_GetObjectError3_text & ServerName & ": " & err.Description
        wscript.quit(1)
    end if

    on error goto 0


    For Each Printer In PrintServer
        if Printer.class = "PrintQueue" then PublishPrinter Printer.PrinterPath, ServerName, Container
    Next


end if




sub PublishPrinter(UNC, ServerName, Container)

    
    Set PQ = WScript.CreateObject("OlePrn.DSPrintQueue.1")

    PQ.UNCName = UNC
    PQ.Container = Container

    on error resume next

    PQ.Publish(2)

    if err then
        if err.number = -2147024772 then
            wscript.echo L_PublishError1_text & Chr(34) & ServerName & Chr(34) & L_PublishError2_text
            wscript.quit(1)
        else
            wscript.echo L_PublishError3_text & Chr(34) & UNC & Chr(34) & "."
            wscript.echo L_PublishError4_text & err.Description
        end if
    else
        wscript.echo L_PublishSuccess1_text & PQ.Path
    end if

    Set PQ = nothing

end sub

'' SIG '' Begin signature block
'' SIG '' MIIlZgYJKoZIhvcNAQcCoIIlVzCCJVMCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' bX5L2iwVxdNwgYz/bum9hpiY7tSWABk75hj61B/d9mGg
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
'' SIG '' BgkqhkiG9w0BCQQxIgQgDOq1d+bUZDvUtUesINnDtLHg
'' SIG '' 2N7hq3Bf5InIcatAMKAwPAYKKwYBBAGCNwoDHDEuDCx3
'' SIG '' aXNqRWF4Q0ZwSW9CeTl6cTdUL0NGZWpZeTJEYXdLZ2Q1
'' SIG '' S3pXZGQrbGY4PTBaBgorBgEEAYI3AgEMMUwwSqAkgCIA
'' SIG '' TQBpAGMAcgBvAHMAbwBmAHQAIABXAGkAbgBkAG8AdwBz
'' SIG '' oSKAIGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS93aW5k
'' SIG '' b3dzMA0GCSqGSIb3DQEBAQUABIIBAKe4WtSK8feU3nl2
'' SIG '' obcAsov1gMkNP4GRa1qgBbXITi2Qx7snFeM5nuW18TxZ
'' SIG '' w9RKTYtXIo9/+Jk35Pnqc47eNEpaWgh3fGpu5PKPkwrk
'' SIG '' 3a7Q18f6YAIn+5BY/0PuvxYluYpBd4ReMnHje4n4A70o
'' SIG '' bP9ad+CFVOOrRVWgs1et/Z0xaqOR0dGJT37CVsVEJ/vH
'' SIG '' GsYu2ESMDZYSm4pIsolMPhK3RHIXoaGvC2y8B6d4Qm7V
'' SIG '' RfoNf+Oa6UHEP3hi7yswPyB2ojAbUHjuzatQ3XvGiS/l
'' SIG '' DKTPihtT2xf1IXYXLQQSjfLCpykhdfDfPZTMCAbymUQe
'' SIG '' +YitVDyivc1J5qgTyb2hghcJMIIXBQYKKwYBBAGCNwMD
'' SIG '' ATGCFvUwghbxBgkqhkiG9w0BBwKgghbiMIIW3gIBAzEP
'' SIG '' MA0GCWCGSAFlAwQCAQUAMIIBVQYLKoZIhvcNAQkQAQSg
'' SIG '' ggFEBIIBQDCCATwCAQEGCisGAQQBhFkKAwEwMTANBglg
'' SIG '' hkgBZQMEAgEFAAQgLJJj/Is/G1yGmmd4/A8bBLd8YfUb
'' SIG '' yIRMvDkkslrftVQCBmJrR5JvBRgTMjAyMjA1MDcwMjIw
'' SIG '' MzUuOTYxWjAEgAIB9KCB1KSB0TCBzjELMAkGA1UEBhMC
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
'' SIG '' MC8GCSqGSIb3DQEJBDEiBCBQZnCSHdDMe2NoTF3PWeTx
'' SIG '' Jm4JwcYuIp64t3YGpry5UTCB+gYLKoZIhvcNAQkQAi8x
'' SIG '' geowgecwgeQwgb0EILgKOHF+ZgSxoK3YBTzcqGH7okeX
'' SIG '' KTcHvS98wcyUEtxcMIGYMIGApH4wfDELMAkGA1UEBhMC
'' SIG '' VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
'' SIG '' B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
'' SIG '' b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUt
'' SIG '' U3RhbXAgUENBIDIwMTACEzMAAAGlAN4IxEAHcU4AAQAA
'' SIG '' AaUwIgQgGBbYfD6VF/RCW1pksxKs85qFsEjdHhSgkRHf
'' SIG '' iNlJoK0wDQYJKoZIhvcNAQELBQAEggIAUW4hc+9kcIyi
'' SIG '' sQL2H0lcLVwR3/2Gu5lKU7dYL0bj7tuosHTcJJ4BzaU2
'' SIG '' qDBvR8owZEMK/Ux+S/zmaSrZcUlKcTmza+jWQQ5/UvB5
'' SIG '' D6f8jjFJeBOtrBn1geQn10Jj0RoyaBil7yrsR3g2Rlsp
'' SIG '' vsOk+UbnZ6seXhUd5b/yWeCZT4ThhSuMEO36nRack+CN
'' SIG '' hPxk+IXrH4EMU+iHSDe6yquU8CYd19lbSX86IordM+J9
'' SIG '' ziuxodH6Awin7b2SwAoG0lx6B4GKyauY7Vipy9MdRzUH
'' SIG '' iwnp/KhP2xLhjawstDsprE1uyp/l4FFnox18He09Vgew
'' SIG '' tjF/9UMqB0qgAbv2CI63LckdNZy6Ip4AEeVY7lOyoaot
'' SIG '' BVeCWkbmJp2qpco2wLX/cVL5S7iHuVZyIOgcZ2DQ7EJt
'' SIG '' M7raPFYCSYipX5PtsJnlNOFCxSeRFKo+PI7zkCoq2riP
'' SIG '' Ob6cQb/33Pq7rqhf/zNKy042u5HXQHJXpYM7kNwOKqJk
'' SIG '' Z/uopIh8w3dK8YtJPSba6cD38oEas0DoDMROxOcHuvao
'' SIG '' IuL0ty4xtokLtf2z6QrA02tBK2Rw+/0ce7CXI+oFr/in
'' SIG '' POeLzrgfjqV+K4f7HO36LU0vChcqQERwoLnhWS7QPaQ+
'' SIG '' gb11tPIBzYvbr7r13LY/rCCJaB0po+K9xU0Gkn1XizUT
'' SIG '' WbtlSEawthI=
'' SIG '' End signature block
