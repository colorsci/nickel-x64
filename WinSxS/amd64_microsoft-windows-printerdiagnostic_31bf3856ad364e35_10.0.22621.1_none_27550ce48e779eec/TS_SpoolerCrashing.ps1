# Copyright © 2008, Microsoft Corporation. All rights reserved.


#
# Spooler service is functioning incorrectly
#
Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Write-DiagProgress -activity $localizationString.progress_ts_spoolerCrashing

$date = Date
$date = $date.AddDays(-1)
$event = get-winevent -FilterHashTable @{ ProviderName = 'Application Error'; StartTime = $date; Data="spoolsv.exe"; Id = 1000 } -ErrorAction SilentlyContinue

if($event -ne $null -and $event.Count -gt 1)
{
    $addRootCause = $true
    $PrintKey = get-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows NT\Printers"
    if($printKey -ne $null)
    {
        $executionPolicy = $PrintKey.PrintDriverIsolationExecutionPolicy
        $overrideCompat = $PrintKey.PrintDriverIsolationOverrideCompat
        if($executionPolicy -eq 1 -and $overrideCompat -eq 1)
        {
            $addRootCause = $false
        }
    }
    if($addRootCause)
    {
        Update-DiagRootCause -id "RC_SpoolerCrashing" -Detected $true	

        $event | convertto-xml | Update-DiagReport -id SpoolerEvent -name $String_TS_SpoolerCrushing.spoolerEvent_name -description $String_TS_SpoolerCrushing.spoolerEvent_description -verbosity Error -rid "RC_SpoolerCrashing"
        return
    }
}
Update-DiagRootCause -id "RC_SpoolerCrashing" -Detected $false