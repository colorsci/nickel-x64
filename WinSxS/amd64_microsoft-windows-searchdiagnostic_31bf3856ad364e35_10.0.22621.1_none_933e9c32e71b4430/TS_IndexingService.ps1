# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Check the status of the indexing service. If the service is not running, add the root cause.

PARAM($Action)

# Load utility library
. .\CL_Utility.ps1

# HACK: we now run the UI from this troubleshooter since we converted to a local TS and have nowhere else to run it from.
if ($Action -eq "Diagnose")
{
    # Display problem selection dialog
    $responses = Get-DiagInput -id IT_ProblemDisplay
    if ($responses -ne $null)
    {
        $unknown = $false
        $responses | foreach-object -process { if ($_ -eq "UnknownProblem") { $unknown = $true } }
        $objArray = ConvertStringArrayToPSObjectArray $responses "problemType"
        $objArray | select-object -Property @{Name=$localizationString.problemType_name; Expression={$_.problemType}} | convertto-xml | Update-DiagReport -id UserReportedProblems -name $localizationString.problemType_description -verbosity Informational
        Write-DiagTelemetry -Property "ProblemCheckboxes" -Value ($responses -join ",")
        # If the user selected "Unknown Problem", then give them a chance to describe it
        if ($unknown -eq $true)
        {
            $description = Get-DiagInput -id IT_UnknownProblem
            if (-not [string]::IsNullOrEmpty($description))
            {
                Write-DiagTelemetry -Property "UserProblemDescription" -Value $description[0] # Return value for single input is an array of length 1
                $description | convertto-xml | Update-DiagReport -id UserReportedProblems -name $localizationString.userProblem_description -verbosity Informational
            }
        }
    }
}

Write-DiagProgress -activity $localizationString.progress_ts_indexingService

if ((get-service wsearch).status -ne "Running")
{
    Update-DiagRootCause -id "RC_IndexingService" -Detected $true
    return $false
}
else
{
    Update-DiagRootCause -id "RC_IndexingService" -Detected $false
    return $true
}
