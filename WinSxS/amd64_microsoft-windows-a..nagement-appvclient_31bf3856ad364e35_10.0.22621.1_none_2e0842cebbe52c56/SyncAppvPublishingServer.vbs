'---------------------------------------------------------------------------------------------
' Copyright: Microsoft Corp.
'
' This script is designed to be used only for scheduled tasks(s).
' There is no extensive error check, and will not dump the output from the Powershell CmdLet.
'
' Usage: SyncAppvPublishingServer {cmdline-args(passthrough to cmdlet)}
'---------------------------------------------------------------------------------------------

Option Explicit


Dim g_cmdArgs
g_cmdArgs = ""


' main entrance

' Enable error handling
On Error Resume Next

ParseCmdLine

if g_cmdArgs = "" Then
	Wscript.echo "Command line arguments are required."
	Wscript.quit 0
End If	
	

Dim syncCmd
syncCmd = "$env:psmodulepath = [IO.Directory]::GetCurrentDirectory(); " & _
          "import-module AppvClient; " & _
          "Sync-AppvPublishingServer " & g_cmdArgs

Dim psCmd
psCmd = "powershell.exe -NonInteractive -WindowStyle Hidden -ExecutionPolicy RemoteSigned -Command &{" & syncCmd & "}"


Dim WshShell
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.Run psCmd, 0


' Reset error handling
On Error Goto 0
WScript.Quit 0


	
'---------------------------------------------------------------------------------------------
' Sub:  ParseCmdLine
'       Reading the parameters provided by the user in the command line
'---------------------------------------------------------------------------------------------
Sub ParseCmdLine()

	dim objArgs
	dim argsCount
	dim x
	
	Set objArgs = Wscript.Arguments
	argsCount = objArgs.count
	
	x = 0
	While x < argsCount
		g_cmdArgs = g_cmdArgs & " " & objArgs(x) 
		x = x + 1
	Wend
	
End Sub

