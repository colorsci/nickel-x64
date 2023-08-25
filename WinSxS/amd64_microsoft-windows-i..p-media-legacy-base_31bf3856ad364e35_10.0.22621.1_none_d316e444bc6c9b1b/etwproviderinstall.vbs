Option Explicit

' Globals
'
Dim ObjShell, ObjFS

Dim manual,targetDir

Set ObjShell       = CreateObject ("WScript.Shell")
Set ObjFS          = CreateObject ("Scripting.FileSystemObject")

' Regular Expressions
'
Dim RegExFolderPart, RegExExtensionPart, RegExIsManifest

Set RegExFolderPart = New RegExp
RegExFolderPart.Pattern = "^.*\\"
RegExFolderPart.Global = True
RegExFolderPart.IgnoreCase = True
RegExFolderPart.MultiLine = False

Set RegExExtensionPart = New RegExp
RegExExtensionPart.Pattern = "\.[^.\\]+$"
RegExExtensionPart.Global = True
RegExExtensionPart.IgnoreCase = True
RegExExtensionPart.MultiLine = False

Set RegExIsManifest = New RegExp
RegExIsManifest.Pattern = ".+\.man$"
RegExIsManifest.Global = True
RegExIsManifest.IgnoreCase = True
RegExIsManifest.MultiLine = False

' There is no convenient way to check whether WScript is defined.
' This code captures the possible undefined error to perform the check.
' 
On Error Resume Next
manual = Not WScript Is Nothing
If Err.Number = 0 Then
    manual = True
Else
    manual = False
End If
On Error Goto 0

'''''''''''''''''''''' Manual Execution '''''''''''''''''''''' 
If True = manual Then

    Dim ObjCommandLine
    Dim result

    Set ObjCommandLine = WScript.Arguments


    ' Check parameters
    '
    If( 2 <> ObjCommandLine.Count ) Then
    PrintUsage()
    WScript.Quit(1)
    End If

    targetDir = objFS.GetAbsolutePathName(ObjCommandLine(1))

    ' Perform operation
    '
    If "install" = ObjCommandLine(0) Then
        result = ForEachManifest( GetRef("InstallProvider") )
    ElseIf "uninstall" = ObjCommandLine(0) Then
        result = ForEachManifest( GetRef("UninstallProvider") )
    Else 
        PrintUsage()
        result = 1
    End If

    WScript.Quit(result)

End If

'''''''''''''''''''''' Subroutines '''''''''''''''''''''' 

' Print usage syntax
'
Function PrintUsage()
                  '00000000000000000000000000000000000000000000000000000000000000000000000000000080
    WScript.Echo( "ETWProviderInstall.vbs installs and uninstalls the Microsoft Windows Setup ETW" + VbCR + VbLF + _
                  "Provider Manifests necessary to decode setup.etl files on computers running" + VbCR + VbLF + _
                  "Microsoft Windows Vista and Microsoft Windows Server 2008." + VbCR + VbLF + _
                  "" + VbCR + VbLF + _
                  "Usage: ETWProviderInstall.vbs { install | uninstall } <provider directory>" + VbCR + VbLF + _
                  "  install - installs the providers" + VbCR + VbLF + _
                  "  uninstall - uninstalls the providers" + VbCR + VbLF + _
                  "  provider directory - a relative or absolute path to the directory containing" + VbCR + VbLF + _
                  "  the provider manifests and resources." + VbCR + VbLF + _
                  "" )
End Function

' Install Providers
'
Function InstallProviders
    targetDir = Session.TargetPath("ETWProviders")
    ForEachManifest( GetRef("InstallProvider") )
End Function

' Uninstall Providers
'
Function UninstallProviders

    ' If this is msi mode, uninstall failures are not fatal
    '
    If False = manual Then
        On Error Resume Next
    End If

    targetDir = Session.TargetPath("ETWProviders")
    ForEachManifest( GetRef("UninstallProvider") )

    On Error Goto 0

End Function

' Enumerates over the provider manifests
'
Function ForEachManifest( performAction )
    Dim ObjCD, ObjFiles, File
 
    ' Remove possible trailing backslash
    '
    If Right(targetDir, 1) = "\" Then
        targetDir = Left(targetDir, Len(targetDir) - 1)
    End If

    Set ObjCD = ObjFs.GetFolder( targetDir )

    Set ObjFiles = ObjCD.Files
    For Each File In ObjFiles
        If RegExIsManifest.Test( File.name ) Then
            ForEachManifest = performAction( File.path )
            If ForEachManifest <> 0 AND manual Then 
                WScript.Echo(" Failed on " & File.name & " with error code " & ForEachManifest)
                Exit For
            End If
        End If
    Next

End Function
    
' Install an ETW Provider
'
Function InstallProvider( manifestName )
    Dim fixedManifest

    fixedManifest = FixManifest( manifestName )

    If Not fixedManifest = "" Then
        InstallProvider = ObjShell.Run( "wevtutil im """ & fixedManifest & """", 0, True )
        ObjFS.DeleteFile( fixedManifest )
    Else
        InstallProvider = 1
    End If
    
End Function

' Uninstall an ETW Provider
'
Function UninstallProvider( manifestName )
    UninstallProvider = ObjShell.Run( "wevtutil um """ & manifestName & """", 0, True )
End Function

' Create a fixed-up copy of a provider manifest
' 
Function FixManifest( manifestName )
    Dim ObjDom, ObjNodes, ObjNode, ObjAttributes
    Dim fixedName, messageFileName, resourceFileName

    Set ObjDom = CreateObject("msxml2.DOMDocument.3.0")
    ObjDom.async = false
    ObjDom.resolveExternals = false
    ObjDom.validateOnParse = false
    
    If Not ObjDom.load( manifestName ) Then
        FixManifest = ""
        Exit Function
    End If

    Set ObjNodes = ObjDom.SelectNodes("//*/provider")
    
    If ObjNodes Is Nothing Then
        FixManifest = ""
        Exit Function
    End If

    For Each ObjNode In ObjNodes
        Set ObjAttributes = ObjNode.attributes
    
        messageFileName  = ObjAttributes.getNamedItem("messageFileName").nodeValue
        resourceFileName = ObjAttributes.getNamedItem("resourceFileName").nodeValue
    
        messageFileName  = RegExFolderPart.Replace ( messageFileName,  targetDir + "\" ) 
        resourceFileName = RegExFolderPart.Replace ( resourceFileName, targetDir + "\" ) 
    
        ' If the resource DLLs referenced in the provider manifest are main OS DLLs 
        ' then we don't include them in the OPK, instead we include a resource-only
        ' dll with the etw.dll suffix.  For these DLLs we need to add the suffix here.
        '
        If 0 = InStr( messageFileName, "etw.dll" ) Then
            messageFileName  = RegExExtensionPart.Replace ( messageFileName,  "etw.dll" ) 
        End If

        If 0 = InStr( resourceFileName, "etw.dll" ) Then
            resourceFileName = RegExExtensionPart.Replace ( resourceFileName, "etw.dll" ) 
        End If

        ObjNode.SetAttribute "messageFileName",  messageFileName
        ObjNode.SetAttribute "resourceFileName", resourceFileName
    Next
    
    fixedName  = RegExFolderPart.Replace ( manifestName,  ObjShell.ExpandEnvironmentStrings("%TEMP%") + "\" ) + ".fixed.man"
    
    If ObjDom.save( fixedName ) Then
        FixManifest = ""
        Exit Function
    End If

    FixManifest = fixedName
End Function
