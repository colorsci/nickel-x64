# Copyright © 2008, Microsoft Corporation. All rights reserved.
PARAM($printerName)

. .\CL_Utility.ps1

# Check the default printer
# The root cause will be caught if the default printer is not the diagnosed printer..
#
Import-LocalizedData -BindingVariable Strings_TS_DefaultPrinter -FileName CL_LocalizationData

Write-DiagProgress -activity $Strings_TS_DefaultPrinter.progress_ts_defaultPrinter

$defaultPrinter = Get-WmiObject -query "Select * From Win32_Printer Where default=true" -ErrorAction SilentlyContinue

# Store the original default printer 
if ((Test-Path "$pwd\prevDefaultPrinter.txt") -eq $false)
{
	$prevDefaultPrinter = $defaultprinter.name
    echo $prevDefaultPrinter > "$pwd\prevDefaultPrinter.txt"
}
else
{
	# retrieve the previous default printer during verification phase
    $prevDefaultPrinter = get-content "$pwd\prevDefaultPrinter.txt" -ErrorAction SilentlyContinue
}

#
# The root cause will be caught if at least one physical printer is already installed and the default printer is not a physical printer.
#
if($defaultPrinter -eq $null -or $defaultPrinter.Name -ne $printerName)
{
    Update-DiagRootCause -id "RC_WrongDefaultPrinter" -instanceId $prevDefaultPrinter -Detected $true  -parameter @{ "PRINTERNAME" = $printerName}
} else {
    Update-DiagRootCause -id "RC_WrongDefaultPrinter" -instanceId $prevDefaultPrinter -Detected $false  -parameter @{ "PRINTERNAME" = $printerName}
}
