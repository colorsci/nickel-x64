# Copyright © 2008, Microsoft Corporation. All rights reserved.

PARAM($InstanceID, $RepairID, $RepairID1)

#include utility functions
. .\UtilityFunctions.ps1
Import-LocalizedData -BindingVariable localizationString -FileName LocalizationData

<# function Pop-Msg {
	 param([string]$msg ="message",
	 [string]$ttl = "Title",
	 [int]$type = 64) 
	 $popwin = new-object -comobject wscript.shell
	 $null = $popwin.popup($msg,0,$ttl,$type)
	 remove-variable popwin
} #>


$script:ExpectingException = $false
$selectedRepair = $null
#pop-msg $InstanceID
#list of repairs to execute
if($InstanceID -eq $null)
{
     throw "No InstanceID specified"
}
else
{
    # if we re-ran diagnostics after validation failure and found the same issues we'll get the repair call to the original session
    # in these cases, we should use the new session instead to avoid unexpected behavior
    if($Global:ndfRerun -ne $null)
    {
        "Replacing original incident " + $Global:ndf.IncidentID + " with rerun incident " + $Global:ndfRerun.IncidentID | convertto-xml | Update-DiagReport -id RepairAfterRerun -name "Repair After Rerun" -description "Repair run in original session after rerun" -verbosity Debug
        # take a reference to previous session so that it's not closed
        $Global:ndfBackuSessions += @{$Global:ndf.IncidentID=$Global:ndf};
        # replace existing session with rerun session
        $Global:previousNdf = $Global:ndf;
        $Global:ndf = $Global:ndfRerun;
        # make sure we re-diagnose if validation fails again
        $Global:ndfRerun = $null;
    }

    $repairToMatch = $RepairID;
    if($repairToMatch -eq $null)
    {
        $repairToMatch = $RepairID1;
        if($repairToMatch -eq $null)
        {
            throw "No RepairID specified"
        }
    }
    $repairToMatch = $repairToMatch.ToUpper();

    #find selected repair
    $rootCauseCount = $Global:rootCauseEnum.Count
    $Global:rootCauseEnum.Reset()

    #global array to store unmanifested root causes
    for($i=0; ($i -lt $rootCauseCount) -and ($selectedRepair -eq $null); $i++)
    {
        $rootCause=$Global:rootCauseEnum.Next;

        #root cause index is the index of the root cause in the root cause list
        #find the specific root cause
        $rootCauseInstanceID = GetInstanceIDRC ($rootCause) ($Global:catchAlls) ($Global:catchAllsAltRC)
        if($rootCauseInstanceID -eq $InstanceID)
        {
            #now enumerate the repairs and find the matching one
            $repairEnum = $rootCause.Repairs
            $repairCount = $repairEnum.Count
            $repairEnum.Reset()
            for($j=0; $j -lt $repairCount; $j++)
            {
                $repair = $repairEnum.Next
                if($repair.RepairID.ToUpper() -eq $repairToMatch)
                {
                    $selectedRepair = $repair;
                    break;
                }
            }
        }
    }
}

if($selectedRepair)
{
    #verify we should not skip this repair (query both current session, and if available the previous session)
    $skipReason = $Global:ndf.ShouldSkipRepair($selectedRepair);
    if(($skipReason -eq $NDF_SKIPREASON_NONE) -and ($Global:previousNdf))
    {
        $skipReason = $Global:previousNdf.ShouldSkipRepair($selectedRepair);
    }

    #reset validation result so we re-validate
    $Global:ValidateResult = $null;
    $Global:ndfRerun = $null;
    $Global:LastRepairRCInstanceID = $InstanceID; #the instanceID for the last repair executed
    $Global:HTorIO = $false; #whether the last repair was help topic or info only

    $repair = $selectedRepair;
    #$uiInfo = $repair.UiInfo;
    try { $uiInfo = $repair.UiInfo; } catch{ $uiInfo = $null }
    $repairFlags = $repair.Flags;
    $repairText = $repair.Description;
    $selectedRepairId = $repair.RepairID;

    if($skipReason -ne $NDF_SKIPREASON_NONE)
    {
        #set the appropriate states for a skipped repair
        #mimic logic from further below when determining HTorIO, to avoid mis-labeling mis-annotated repairs
        if($repairFlags -band $RF_CONTACT_ADMIN)
        {
            $Global:HTorIO = $true;
        }
        elseif($uiInfo)
        {
            $uiInfoType = $uiInfo.Type;
            if($uiInfoType)
            {
                $Global:HTorIO = (($uiInfoType -eq $UIT_HELP_PANE) -and !($repairFlags -band $RF_VALIDATE_HELPTOPIC));
            }
        }
        elseif($repairFlags -band $RF_INFORMATION_ONLY)
        {
            $Global:HTorIO = $true;
        }
        $Global:RepairSkipped = $true;
        $Global:ndf.SkipRepair($repair.Rank);

        #throw an exception to skip the repair
        $skipText = GetSkipReasonText($skipReason)
        throw $selectedRepair.RepairID + " skipped due to reason: " + $skipText
    }

    $repairName = "";
    $repairDescription = "";
    SplitString $repairText  ([ref]$repairName) ([ref]$repairDescription)

    $params = @{"IT_P_Name"=$repairName; "IT_P_Description"=$repairDescription;}

    $answer = "Validate";
    if($repairFlags -band $RF_CONTACT_ADMIN)
    {
        #contact admin repairs do not result in an interaction, we skip to the next repair (or end screen if none available)
        $Global:HTorIO = $true;
        $answer = "Skip"
    }
    elseif($uiInfo)
    {
        #we are about to show this repair to the user, mark it as shown
        $Global:ndf.RepairShown($repair.Rank);

        $uiInfoType = $uiInfo.Type;
        if($uiInfoType -eq $UIT_HELP_PANE)
        {
            $isHelpTopicAllowed = IsHelpTopicAllowed $uiInfo.HelpTopicLink;
            if ($isHelpTopicAllowed)
            {
                #retrieve customized text
                $helpTopicText = GetExtensionValue ($repair.DescriptionEx) ("LinkButtonText")
                if(!$helpTopicText)
                {
                    #use the default if the link text is not customized
                    $helpTopicText = $localizationString.DefaultHelpTopicText;
                }

                $params += @{"IT_P_HelpTopicText"=$helpTopicText; "IT_P_HelpTopicLink" = $uiInfo.HelpTopicLink}
                if($repairFlags -band $RF_VALIDATE_HELPTOPIC)
                {
                    GetContinueButtonParams $repair ([ref]$params)
                    $answer = Get-DiagInput -ID "IT_ValidateHelpTopicRepair" -Parameter $params
                }
                else
                {
                    Get-DiagInput -ID "IT_HelpTopicRepair" -Parameter $params
                    $Global:HTorIO = $true;
                    $answer = "Skip"
                }
            }
            else
            {
                # The help topic is not allowed -- behave as if informational only
                $Global:ndf.RepairShown($repair.Rank);

                Get-DiagInput -ID "IT_InfoOnlyRepair" -Parameter $params
                $Global:HTorIO = $true;
                $answer = "Skip"
            }
        }
        else
        {
            GetLaunchButtonParams $repair ([ref]$params)
            $answer = Get-DiagInput -ID "IT_UIRepair" -Parameter $params
        }
    }
    elseif($repairFlags -band $RF_USER_ACTION)
    {
        #we are about to show this repair to the user, mark it as shown
        $Global:ndf.RepairShown($repair.Rank);

        GetContinueButtonParams $repair ([ref]$params)
        $answer = Get-DiagInput -ID "IT_UserActionRepair" -Parameter $params
    }
    elseif($repairFlags -band $RF_INFORMATION_ONLY)
    {
        #we are about to show this repair to the user, mark it as shown
        $Global:ndf.RepairShown($repair.Rank);

        Get-DiagInput -ID "IT_InfoOnlyRepair" -Parameter $params
        $Global:HTorIO = $true;
        $answer = "Skip"
    }
    elseif($repairFlags -band $RF_USER_CONFIRMATION)
    {
        #we are about to show this repair to the user, mark it as shown
        $Global:ndf.RepairShown($repair.Rank);

        #Networking push button reset will reboot the machine
        if($selectedRepairId -eq "{a009e5ec-a635-4155-bb08-483d4017c1e5}")
        {
            $answer = Get-DiagInput -ID "IT_UserConfirmationReboot" -Parameter $params
        }
        else
        {
            $answer = Get-DiagInput -ID "IT_UserConfirmation" -Parameter $params
        }
    }

    if(($answer -eq "LaunchUI") -or  ($answer -eq "Validate"))
    {
        $Global:RepairSkipped = $false;
        if($uiInfo -and ($answer -eq "LaunchUI"))
        {
            #launch the UI
            $Global:uiLaunchSucceess = 1;
            & {
                $script:ExpectingException = $true
                #TODO: Make modal to the msdt UI?
                $uiInfo.LaunchUI();
                $script:ExpectingException = $false
            }
            trap [Exception]
            {
                if($script:ExpectingException)
                {
                    $_.Exception.GetType().FullName | convertto-xml | Update-DiagReport -id UILaunchFailed -name "UI Launch Failed" -description "Launching of UI for UI based repair failed." -verbosity Debug
                    $Global:uiLaunchSucceess = 0;
                    $script:ExpectingException = $false
                    continue;
                }
                else
                {
                    #rethrow exception
                    throw $_.Exception;
                }
            }

            #UI was not launched synchronously, need to interact until they are done
            GetContinueButtonParams $repair ([ref]$params)
            $answer = Get-DiagInput -ID "IT_AsyncUIRepair" -Parameter $params
            if($answer -eq "Skip")
            {
                $Global:RepairSkipped = $true;
            }
        }

        if(!$Global:RepairSkipped)
        {
            $repair.RepairID | convertto-xml | Update-DiagReport -id CallingRepair -name "Calling Repair" -description "Executing repair function." -verbosity Debug

            $waitHandle =  $Global:ndf.Repair($repair.Rank, $RepairWaitTime);
            if($waitHandle -eq $null)
            {
                throw "Repair call failed"
            }

            #wait for repair to complete
            WaitWithProgress $localizationString.progress_Repairing_NoDetails $waitHandle $Global:ndf

            #add the trace log to the session
            AddTraceFileToSession $Global:ndf $localizationString.TraceFileReportName "Repair"

            $repairResult = $Global:ndf.RepairResult
            if(!($repairResult -eq $S_OK))
            {
                    #skip validation, for us a repair failure implies validation failure
                    $Global:ValidateResult = $repairResult;
                    throw "Repair failed with HRESULT: " + $repairResult
            }

        }
        else
        {
            $repair.RepairID | convertto-xml | Update-DiagReport -id RepairSkipped -name "Repair Skipped" -description "Repair not executed because user skipped it, or it was info only/help topic." -verbosity Debug
        }
    }
    else
    {
        if($Global:HTorIO)
        {
            $waitHandle =  $Global:ndf.Repair($repair.Rank, $RepairWaitTime);
            if($waitHandle)
            {
                #wait on the handle
                WaitWithProgress $localizationString.progress_Repairing_NoDetails $waitHandle $Global:ndf
            }
        }
        $Global:RepairSkipped = $true;
        $repair.RepairID | convertto-xml | Update-DiagReport -id RepairSkipped -name "Repair Skipped" -description "Repair not executed because user skipped it." -verbosity Debug
    }

    #do not generage an exception if the repair was help topic or info only
    if($Global:RepairSkipped -and (!$Global:HTorIO))
    {
        $Global:ndf.SkipRepair($repair.Rank); #marks the repair as skipped
        throw "Repair skipped";
    }
}
else
{
    throw "Could not find matching repair. RootCauseInstanceID:" +  $InstanceID + " RepairID:" + $RepairID
}
