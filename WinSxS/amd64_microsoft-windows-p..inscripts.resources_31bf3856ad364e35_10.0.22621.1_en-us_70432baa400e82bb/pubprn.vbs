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
'' SIG '' MIIlXgYJKoZIhvcNAQcCoIIlTzCCJUsCAQExDzANBglg
'' SIG '' hkgBZQMEAgEFADB3BgorBgEEAYI3AgEEoGkwZzAyBgor
'' SIG '' BgEEAYI3AgEeMCQCAQEEEE7wKRaZJ7VNj+Ws4Q8X66sC
'' SIG '' AQACAQACAQACAQACAQAwMTANBglghkgBZQMEAgEFAAQg
'' SIG '' bX5L2iwVxdNwgYz/bum9hpiY7tSWABk75hj61B/d9mGg
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
'' SIG '' ARUwLwYJKoZIhvcNAQkEMSIEIAzqtXfm1GQ71LVHrCDZ
'' SIG '' w7Sx4Nje4atwX+SJyHGrQDCgMDwGCisGAQQBgjcKAxwx
'' SIG '' LgwsU3RsZzROMWtFdFF6cFl3L1htaWxBRExVSi8vR0ZE
'' SIG '' aHEwRzJuZm52Nnc4ST0wWgYKKwYBBAGCNwIBDDFMMEqg
'' SIG '' JIAiAE0AaQBjAHIAbwBzAG8AZgB0ACAAVwBpAG4AZABv
'' SIG '' AHcAc6EigCBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
'' SIG '' d2luZG93czANBgkqhkiG9w0BAQEFAASCAQAePZ9RkTEP
'' SIG '' pOR3oL5ZP47nsSbQyd5cfBUOjgPXvA+T65Vw/D1s1MJ7
'' SIG '' ultdBYM/j383tzNDUb5W7Wkmwk5PZWxYoraIASTnxOp2
'' SIG '' lMD5iRRBbBfPujzPdmSLB4h0QmVRiupQfOP+BL1NCXXn
'' SIG '' fP6ExdUPY/JYxtG6DSvJARUhvZbedG2ChU4L+I2j+cLU
'' SIG '' ejkuQzCCbAbf7vcsnRzRCuunxbIsspJBsbgpCRIxjL2E
'' SIG '' QYXcjfzXjkgNRHUS4NdMWifBhEXizkOkUlRbGwVdxAuo
'' SIG '' IQ3NN7zgMpPPjf/YmqUAENDkUVF1JrQZ2tOTqmBKM3st
'' SIG '' dLd9va8AbMk3275Aq0dNYBHloYIW/TCCFvkGCisGAQQB
'' SIG '' gjcDAwExghbpMIIW5QYJKoZIhvcNAQcCoIIW1jCCFtIC
'' SIG '' AQMxDzANBglghkgBZQMEAgEFADCCAVEGCyqGSIb3DQEJ
'' SIG '' EAEEoIIBQASCATwwggE4AgEBBgorBgEEAYRZCgMBMDEw
'' SIG '' DQYJYIZIAWUDBAIBBQAEIKxauFJQ2N+AckyCCBZc9e5q
'' SIG '' cVqL7q/p6nagoVUSVo8lAgZiacqx8Q8YEzIwMjIwNTA3
'' SIG '' MDMyNzQ1LjAyMlowBIACAfSggdCkgc0wgcoxCzAJBgNV
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
'' SIG '' 9w0BCQQxIgQgsbo+tSz/AFF8I2rAl7SLUtYS+iXXHlqc
'' SIG '' E5JfNuABHuwwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHk
'' SIG '' MIG9BCDrCFTxOoGCaCCCjoRyBe1JSQrMJeCCTyErziiJ
'' SIG '' 347QhDCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
'' SIG '' VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
'' SIG '' MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
'' SIG '' JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
'' SIG '' QSAyMDEwAhMzAAABoQGFVZm5VF2KAAEAAAGhMCIEIKoe
'' SIG '' BFpjMIpxnc6S8Z//BguKjjVd30Z/v1UlXfD4RhRYMA0G
'' SIG '' CSqGSIb3DQEBCwUABIICACy+pLm+vAsZZc1M/WLXS8FC
'' SIG '' W7AtLHvWnlIJ1AyY14a2+d2gsJ0amVwXJFGdznYfcFAd
'' SIG '' HgfuVi7XNPP8rrLm0JA0QLyjDNPBz3qfsVQovm1H38Ui
'' SIG '' yDF66LQD+vxIJyxxgL2gGAOJP4qsXi6cg0Dva0rI6fbI
'' SIG '' 8DyIrPmA1NKLZWFKxMX/aIG73LE6Uc0604VC1c/TaZiO
'' SIG '' 4/Ahhe4fP7EGDGDI+ukWweY2RMSFd8Esi/OfPGoHs+EU
'' SIG '' C/4gH2phoLgIvErR++tfVcbIllfanQY5mHP4S1vzEXQm
'' SIG '' NupH9ho0TG74FxHu8BYqSR5mH90U7+/o8w67fCaRJPBS
'' SIG '' q4oOHFLoeW/QOlmbCCgLO9Xsfb2dG/IbzL/LQy3HBxWv
'' SIG '' wkfZURVXM8f7K3PnRB6hxB41/rapCK1oJzKiVOgJcodr
'' SIG '' 2ZESi0Mq0RPLw7XxMdaprB7NoPkuKQ4B6SdEpOlHJCnZ
'' SIG '' 1DusQp62ymo6dKIXAm43gqelA73d4K69Et6Zv7rJIA8x
'' SIG '' R8hEauZEATzJ3Pu/s+WmxTlPsNOOBs4joL5mfPmbjI7L
'' SIG '' v3Zsm8WGpGT7eFc9Ouztxfu4CQAth8QEnRsWPbRr0bB+
'' SIG '' Kz8ziBvopqYdNhT+PkpSe19wHRQpLxV4oQJxzgkVjpBX
'' SIG '' NUzdDk6014ZEJZmo4/6s3P/JfJB0Rpj55TcwZpxNee4y
'' SIG '' End signature block
