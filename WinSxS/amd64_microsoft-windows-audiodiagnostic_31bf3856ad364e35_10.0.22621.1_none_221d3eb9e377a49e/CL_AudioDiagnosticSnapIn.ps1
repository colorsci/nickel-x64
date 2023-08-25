# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:	
	  CL_AudioDiagnosticSnapIn.ps1 is common library for audio troubleshooter.

	ARGUMENTS:
	  None

	RETURNS:
	  None

	FUNCTIONS:
	  Register-AudioDiagnosticSnapIn
	  Unregister-AudioDiagnosticSnapIn
#>

#====================================================================================
# Main
#====================================================================================

function Register-AudioDiagnosticSnapIn()
{
	<#
		DESCRIPTION
		  This function used to import AudioDiagnosticSnapIn.dll to current session.
		
		ARGUMENTS:
		  None

		RETURNS:
		  None
	#>
	
	Import-Module ".\AudioDiagnosticSnapIn.dll" -ErrorAction SilentlyContinue | Out-Null
}

function Unregister-AudioDiagnosticSnapIn()
{
	<#
		DESCRIPTION
		  This function used to remove AudioDiagnosticSnapIn.dll to current session.
		
		ARGUMENTS:
		  None

		RETURNS:
		  None
	#>

	Remove-Module AudioDiagnosticSnapIn -ErrorAction SilentlyContinue | Out-Null
}