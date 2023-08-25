# Copyright © 2008, Microsoft Corporation. All rights reserved.

PARAM($RootCauseID, $instanceID)

#include utility functions
. .\UtilityFunctions.ps1
Import-LocalizedData -BindingVariable localizationString -FileName LocalizationData

#execute validation only once, and don't execute if repair skipped
$validationCalled = $false
if($Global:ValidateResult -eq $null -and ($Global:RepairSkipped -eq $false))
{
    $waitHandle =  $Global:ndf.Validate($ValidateWaitTime);
    if($waitHandle -eq $null)
    {
       throw "Validate call failed"
    }

    WaitWithProgress $localizationString.progress_Vaildating_NoDetails $waitHandle $Global:ndf
    $Global:ValidateResult = $Global:ndf.ValidateResult

    #add the trace log to the session
    AddTraceFileToSession $Global:ndf $localizationString.TraceFileReportName "Verify"

    $validationCalled  = $true
}
else
{
    if(!$Global:ValidateResult -eq $null)
    {
        "ID:" + $RootCauseID + " InstanceId:" + $instanceID  | convertto-xml | Update-DiagReport -id ValidateSkipped -name "Validation Skipped" -description "Validation was already executed, NDF only has one validation per session." -verbosity Debug
    }
    elseif($Global:RepairSkipped)
    {
        "ID:" + $RootCauseID + " InstanceId:" + $instanceID  | convertto-xml | Update-DiagReport -id ValidateSkipped -name "Validation Skipped" -description "Validation skipped because repair was skipped." -verbosity Debug
    }
    elseif($Global:ndf.SessionStatus -eq $NDF_STOP_STATUS_SUCCESSDIAG)
    {
        "ID:" + $RootCauseID + " InstanceId:" + $instanceID  | convertto-xml | Update-DiagReport -id ValidateSkipped -name "Validation Skipped" -description "Validation skipped because a repair has not yet been executed. Marking root cause as not fixed." -verbosity Debug
        Update-DiagRootCause -InstanceId $instanceID -ID $RootCauseID -Detected $true
        return;
    }
    else
    {
        "ID:" + $RootCauseID + " InstanceId:" + $instanceID  | convertto-xml | Update-DiagReport -id ValidateSkipped -name "Validation Skipped" -description "Validation skipped because an error ocurred during repair." -verbosity Debug
    }
}

#get session status to make sure this isn't a repair failure scenario
$sessionStatus = $Global:ndf.SessionStatus;

#explicit validation failure
if(!($Global:ValidateResult -eq $null) -and  !($Global:ValidateResult -eq $S_OK) -and ($sessionStatus -eq $NDF_STOP_STATUS_FAILEDVALIDATE))
{
    $diagResult = $S_OK;
    if(!$Global:ndfRerun)
    {
        "Rediagnosing within Verify stage because Validation failed" | convertto-xml | Update-DiagReport -id RediagnoseAfterValidate -name "Rediagnosing after Validate"  -verbosity Debug

        #if validation failed, we need to rediagnose at this point to fit within the model of the scripted troubleshooting platform
        $Global:ndfRerun = new-object -comObject ndfapi.NetworkDiagnostics.1 -strict
        $Global:ndfRerun.CreateIncident($Global:incidentData["HelperClassName"], $Global:incidentData["HelperAttributes"])

        #execute diagnosis
        $waitHandle =  $Global:ndfRerun.Diagnose($DiagnoseWaitTime, 0)
        if($waitHandle -eq $null)
        {
            throw "Diagnose call failed"
        }

        WaitWithProgress $localizationString.progress_Diagnosing_NoDetails $waitHandle $Global:ndf

        $diagResult = $Global:ndfRerun.DiagnoseResult
        if($diagResult -eq $S_OK)
        {
            #set the previous session so that we can pick it up if we re-diagnose
            $Global:ndf.SetFollowUpSession($Global:ndfRerun);

            #collect catch-all information for use when recovering the instance ID
            $Global:rerunCatchAlls = @{}; #will contain the RC's with catch all repairs, indexed by HC it applies to
            $Global:rerunCatchAllsAltRC = @{}; #will contain the alternate RC ID for the catch all, if available, indexed by root cause
            GetCatchAllInformation ($Global:ndfRerun.RootCauses) ([ref]$Global:rerunCatchAlls)  ($null)  ([ref]$Global:rerunCatchAllsAltRC);
        }

        #add tracelog to report
        AddTraceFileToSession $Global:ndfRerun $localizationString.TraceFileReportName "Diagnose"
    }
    else
    {
        $diagResult = $Global:ndfRerun.DiagnoseResult
    }

    if($diagResult -eq $S_OK)
    {
        #check whether the current verify RC is part of the new diagnosis session
        #if so, we report the issue as not fixed, and we continue to attempt to fix the problem
        #if not, we leave the RC as 'detected' by not calling back to the scripted platform, which will cause it to skip this root cause from this point on

        $rootCause = $null
        $newRootCauseEnum = $Global:ndfRerun.RootCauses
        $rootCauseCount = $newRootCauseEnum.Count
        $newRootCauseEnum.Reset()
        for($i=0; $i -lt $rootCauseCount; $i++)
        {
            $curRootCause = $newRootCauseEnum.Next;
            $newInstanceID = GetInstanceIDRC ($curRootCause) ($Global:rerunCatchAlls) ($Global:rerunCatchAllsAltRC)
            #if the instance ID's match, we've found a match
            if($newInstanceID -eq $instanceID)
            {
                $rootCause  = $curRootCause
                break;
            }
        }

        if($rootCause)
        {
            #root cause is present in new diagnosis, if it isn't part of the list to skip then we should report it as not fixed
            $skipReason = $Global:ndf.ShouldSkipRootCause($rootCause);
            if($skipReason -eq $NDF_SKIPREASON_NONE)
            {
                #if RC was previously marked as "detected", make sure we don't reset it to "not fixed"
                if($Global:RCInDetectedState -and $Global:RCInDetectedState[$instanceID])
                {
                    "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseDetected -name "Root Cause Detected" -description "Reporting that the Root Cause was detected. (Root Cause was found on re-diagnosis, and previously marked as detected)" -verbosity Debug
                }
                else
                {
                    "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseNotFixed -name "Root Cause Not Fixed" -description "Reporting that the Root Cause was not fixed. (validation failed and it was found on re-diagnosis)" -verbosity Debug
                    Update-DiagRootCause -InstanceId $instanceID -ID $RootCauseID -Detected $true
                }
            }
            else
            {
                $skipText = GetSkipReasonText($skipReason)
                $RootCauseID + " reported as Detected because it is skipped due to reason: " + $skipText | convertto-xml | Update-DiagReport -id VerificationRootCauseSkipped -name "Verification Root Cause Skipped" -verbosity Debug
                $Global:RCInDetectedState += @{$instanceID=$true};
            }
        }
        else
        {
            "ID:" + $RootCauseID + " reported as Detected because it was not found on re-diagnosis" | convertto-xml | Update-DiagReport -id VerificationRootCauseSkipped -name "Verification Root Cause Skipped" -verbosity Debug
        }
    }
}
#validation succeeded
elseif($Global:ValidateResult -eq $S_OK)
{
    #only report fixed root cause as fixed, others are 'detected'
    if($Global:LastRepairRCInstanceID -eq $instanceID)
    {
        "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseFixed -name "Root Cause Fixed" -description "Reporting that the Root Cause was fixed. (validation succeeded)" -verbosity Debug
        #for the root cause validated, if validation succeeded we say it's fixed. All others will be "detected"
        Update-DiagRootCause -InstanceId $instanceID -ID $RootCauseID -Detected $false
    }
    else
    {
        "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseDetected -name "Root Cause Detected" -description "Other Root Cause fixed, reporting that this Root Cause was detected." -verbosity Debug
    }
}
#validation skipped
elseif($Global:RepairSkipped)
{
    #the repair was either skipped, or was info only
    if($Global:LastRepairRCInstanceID -eq $instanceID)
    {
        #for the repair shown, if skipped it should be failed, if HT/IO it should be detected
        if($Global:HTorIO)
        {
            "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseDetected -name "Root Cause Detected" -description "Reporting that the Root Cause was detected. (repair was info only/help topic)" -verbosity Debug
            #remember that this RC was set to detected state to avoid resetting it to "not fixed" later
            $Global:RCInDetectedState += @{$instanceID=$true};
        }
        else
        {
            "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseNotFixed -name "Root Cause Not Fixed" -description "Reporting that the Root Cause was not fixed. (repair skipped)" -verbosity Debug
            #validation failed, add the root cause, troubleshooting will rerun
            Update-DiagRootCause -InstanceId $instanceID -ID $RootCauseID -Detected $true
        }
    }
    else
    {
        #if RC was previously marked as "detected", make sure we don't reset it to "not fixed"
        if($Global:RCInDetectedState -and $Global:RCInDetectedState[$instanceID])
        {
            "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseDetected -name "Root Cause Detected" -description "Reporting that the Root Cause was detected. (Root Cause was previously marked as detected)" -verbosity Debug
        }
        else
        {
            #a repair was skipped, but not for this root cause, so we need to report it as not fixed to be sure it's addressed
            "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseNotFixed -name "Root Cause Not Fixed" -description "Reporting that the Root Cause was not fixed. (another repair was skipped or was info only/help topic)" -verbosity Debug
            #validation failed, add the root cause, troubleshooting will rerun
            Update-DiagRootCause -InstanceId $instanceID -ID $RootCauseID -Detected $true
        }
    }
}
elseif($sessionStatus -eq $NDF_STOP_STATUS_FAILEDREPAIR)
{
    "ID:" + $RootCauseID + " InstanceId:" + $instanceID | convertto-xml | Update-DiagReport -id RootCauseNotFixed -name "Root Cause Not Fixed" -description "Reporting that the Root Cause was not fixed because last repair was a failure." -verbosity Debug
    #An error occurred, report all as detected to continue resolving
    Update-DiagRootCause -InstanceId $instanceID -ID $RootCauseID -Detected $true
}
