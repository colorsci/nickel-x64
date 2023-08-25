# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_BITSDLL -FileName CL_LocalizationData
$BitsDLLdetected = $false

#====================================================================================
# Load Utilities
#====================================================================================
. ./Cl_Service.ps1

#====================================================================================
# Main
#====================================================================================

try 
{
	$INT_GetPackageIDResult = Get-DiagInput -ID 'INT_EnableSFC' -EA SilentlyContinue
}
catch  
{
	# When pack runs alone, the answer file wont be present resulting in script error, that's why try catch block is introduced
}

if ($INT_GetPackageIDResult -eq 'false') 
{	
	return  $false
}

$cpu = gwmi -Query 'Select * from Win32_Processor'
if ( 5 -eq $cpu.Architecture ) 
{ 
	# Not detecting the root cause in case of ARM processor.
	return $false
}

SServicer 'bits' 'Stopped'

# Running SFC for Qmgr.dll
$output = sfc /scanfile="$env:windir\system32\Qmgr.dll"

# Processing the output for report
$sb = New-Object System.Text.StringBuilder
foreach($s in $output)
{
	if($s){$n = $sb.append($s)}
}
$output = $sb.Tostring().ToCharArray()

$sb = New-Object System.Text.StringBuilder
foreach($s in $output)
{
	if($s){$n = $sb.append($s)}
}
$output = $sb.Tostring()

$Global:sfcOputFile = "$env:temp\sfcOput.txt"
if (Test-Path $Global:sfcOputFile)
{
	del $Global:sfcOputFile -Force
}

if(![string]::IsNullOrEmpty($output))
{
	$output > $sfcOputFile	
	if($output.Trim().ToLower().IndexOf('cbs.log') -gt -1)
	{
		$BitsDLLdetected = $true
	}
}

SServicer 'bits' 'Running'

Update-DiagRootCause -ID 'RC_BITSDLL' -Detected $BitsDLLdetected

If(!$BitsDLLdetected)
{
	del $Global:sfcOputFile -Force
}

return $BitsDLLdetected