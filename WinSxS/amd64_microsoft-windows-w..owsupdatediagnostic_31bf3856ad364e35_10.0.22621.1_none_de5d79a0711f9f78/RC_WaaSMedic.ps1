# Copyright © 2017, Microsoft Corporation. All rights reserved.

Import-LocalizedData -BindingVariable DataSore_LocalizedStrings -FileName CL_LocalizationData

$WaaS = 0
Try{
    $WaaS = New-Object -ComObject "Microsoft.WaaSMedic.1"
}
Catch
{
    Write-DiagTelemetry -Property "WU:WaaSMedicSupport" -Value "No"
}

Try
{
    if ($WaaS -ne 0)
    {
        Write-DiagTelemetry -Property "WU:WaaSMedicSupport" -Value "Yes"
        $Plugins = $WaaS.LaunchDetectionOnly("Troubleshooter")

        if ($Plugins -eq "")
        {
            Update-DiagRootCause -Id RC_WaaSMedic -Detected $false  -Parameter @{"error"=$Plugins}
        }
        else
        {
            Update-DiagRootCause -Id RC_WaaSMedic -Detected $true -Parameter @{"error"=$Plugins}
            [string]$str = ($DataSore_LocalizedStrings.ID_WAAS_MEDIC_ISSUE_FOUND) + $Plugins
            $str | ConvertTo-Xml | Update-Diagreport -Id TS_Main -Name WaaSMedicService -Verbosity informational
        }
    }
}
Catch
{
    Write-DiagTelemetry -Property "WU:WaaSMedicDetection" -Value "Failed"
}
Finally
{
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WaaS)
}
