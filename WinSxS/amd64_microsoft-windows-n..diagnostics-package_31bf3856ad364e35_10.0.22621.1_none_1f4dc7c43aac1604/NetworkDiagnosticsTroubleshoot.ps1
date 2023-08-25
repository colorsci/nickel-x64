# Copyright © 2008, Microsoft Corporation. All rights reserved.

#include utility functions and localization data
. .\UtilityFunctions.ps1
Import-LocalizedData -BindingVariable localizationString -FileName LocalizationData

#set the environment constants
.\UtilitySetConstants

Write-DiagProgress -activity $localizationString.progress_Diagnosing_Initializing


#reset the global NDF object
$Global:ndf = $null
$Global:previousNdf = $null

#initialize script level variables (script scope used to avoid odd powershell scope handling)
$script:ExpectingException = $false
$script:incidentID = $null
$Global:incidentData = $null #need to access this during verification as well
$script:skipRerun = $false
$script:attachTraceFile = $false
$script:isRerun = $false

#first check whether we're either elevated or a re-run scenario
&{
    $prevIncidentID = 0
    $prevFlags = 0

    $script:ExpectingException = $true
    #marked as no-ui. throws exception if not available
    $SBSData = Get-DiagInput -ID "SecurityBoundarySafe"
    $script:ExpectingException = $false

    if($SBSData[0].Length -gt 0)
    {
        #Security boundary safe data is now always passed in to our script on rerun or elevation
        #We use the "flags" field to determine whether it's a rerun or elevation  -- if the flag doesn't match the current privilege, we elevated
        "SBS Data Retrieved: " + $SBSData  | convertto-xml | Update-DiagReport -id SecurityBoundarySafe -name "Security Boundary Safe" -verbosity Debug

        $script:isRerun = $true
        $admin = IsAdmin
        SplitSBSData $SBSData[0] ([ref]$prevIncidentID) ([ref]$prevFlags)
        if([System.Int32]($prevFlags) -eq [System.Int32]($admin))
        {
            "Previous run's privilege level flag (" + $prevFlags + ") matches our current level (IsAdmin:" + $admin +"). Determining whether it's appropriate to re-run." | convertto-xml | Update-DiagReport -id ReuseSession -name "Reusing previous session" -verbosity Debug

            #same privilege level as last run, so this is a rerun rather than elevation
            #should not use previous incident, but should determine whether rerun is necessary

            #open the previous incident
            $Global:ndf = GetExistingNDFInstance $prevIncidentID
            if($Global:ndf)
            {
                #recover the input attributes so we don't re-prompt
                $prevHelperClass = $Global:ndf.EntryPoint
                $prevHelperAttributes = $Global:ndf.HelperAttributes
                $Global:incidentData = @{"HelperClassName" = $prevHelperClass; "HelperAttributes" =$prevHelperAttributes}

                #check whether re-diagnosis occurred during verification, if so open use the follow up session
                $ndfRerun = $null
                $followupIncidentID = $Global:ndf.FollowUpSession
                if($followupIncidentID)
                {
                    #if follow up incident is available, we should always reuse and return this data as the diagnostics result of this rerun
                    $ndfRerun = GetExistingNDFInstance $followupIncidentID
                    if($ndfRerun)
                    {
                        $Global:previousNdf = $Global:ndf #keep a handle to the previous NDF
                        $Global:ndf = $ndfRerun;

                    }
                    else
                    {
                        throw "Could not open re-run incident."
                    }
                }
                else
                {
                    #don't have a rerun available so lets make sure it's appropriate to rerun
                    #Only necessary when the last action was a failed validation
                    $sessionStatus = $Global:ndf.SessionStatus
                    if(!($sessionStatus -eq $NDF_STOP_STATUS_FAILEDVALIDATE))
                    {
                        #rerun not necessary
                        if($sessionStatus -eq $NDF_STOP_STATUS_SUCCESSVALIDATE)
                        {
                            "Skipping rerun, previous session succeeded in resolving the problem." | convertto-xml | Update-DiagReport -id SkipRerun -name "Skip Rerun" -verbosity Debug
                            $script:skipRerun = $true
                        }
                        else
                        {
                            "Skipping rerun, previous session status (" + $sessionStatus + ") was not a verification failure. Will return same diagnosis as last session." | convertto-xml | Update-DiagReport -id SkipRerun -name "Skip Rerun" -verbosity Debug
                            $script:incidentID = $prevIncidentID
                        }
                        return;
                    }
                    else
                    {
                        "Previous session ended in a validation failure (" + $sessionStatus + ") was a verification failure, rerun will proceed." | convertto-xml | Update-DiagReport -id ValidRerun -name "Rerun is Valid" -verbosity Debug
                        $Global:ndf = $null
                    }
                }
            }
        }
        else
        {
            "Previous run's privilege level flag (" + $prevFlags + ") differs to our current level (IsAdmin:" + $admin +"). Reusing previous session (" + $prevIncidentID + ")" | convertto-xml | Update-DiagReport -id ReuseSession -name "Reusing previous session" -verbosity Debug

            #different privilege level, reuse previous session
            $script:incidentID = $prevIncidentID

            #open the previous incident
            $Global:ndf = GetExistingNDFInstance $prevIncidentID
            #recover the input attributes so we don't re-prompt
            $prevHelperClass = $Global:ndf.EntryPoint
            $prevHelperAttributes = $Global:ndf.HelperAttributes
            $Global:incidentData = @{"HelperClassName" = $prevHelperClass; "HelperAttributes" =$prevHelperAttributes}
        }
    }
}
trap [Exception]
{
    if($script:ExpectingException)
    {
        $script:ExpectingException = $false
        continue;
    }
    else
    {
        #rethrow exception
        throw $_.Exception;
    }
}

if($script:skipRerun)
{
    return;
}   
########################

$script:IT_EntryPoint = "DefaultConnectivity"
if($Global:ndf -eq $null)
{
    "New Diagnostics Session." | convertto-xml | Update-DiagReport -id ReopenSessionCheck -name "Re-open Session Check" -verbosity Debug

    #get entry point
    &{
        $script:ExpectingException = $true
        $script:IT_EntryPoint = Get-DiagInput -ID "IT_EntryPoint"
        $script:ExpectingException = $false
        if($script:IT_EntryPoint[0].Length -eq 0)
        {
            "No entry point specified. Using default connectivity diagnose experience" | convertto-xml | Update-DiagReport -id EntryPoint -name "Entry Point" -description "Selected entry point." -verbosity Debug
            $script:IT_EntryPoint = "DefaultConnectivity"
        }
        else
        {
            $script:IT_EntryPoint | convertto-xml | Update-DiagReport -id EntryPoint -name "Entry Point" -description "Selected entry point." -verbosity Debug
        }
    }
    trap [Exception]
    {
        if($script:ExpectingException)
        {
            "No entry point specified. Using default connectivity diagnose experience" | convertto-xml | Update-DiagReport -id EntryPoint -name "Entry Point" -description "Selected entry point." -verbosity Debug
            $script:ExpectingException = $false
            continue;
        }
        else
        {
            #rethrow exception
            throw $_.Exception;
        }
    }
}

$diagResult = $S_OK
if($Global:ndf -eq $null)
{
    if($Global:incidentData -eq $null)
    {
        #Entry Point functions return a hash with "HelperClassName" and "HelperAttributes" values, or $null on failure
        if($script:IT_EntryPoint -eq "InContext")
        {
            $Global:incidentData = InContextEntry
        }
        elseif($script:IT_EntryPoint -eq "HTTP")
        {
            $Global:incidentData = WebEntry
        }
        elseif($script:IT_EntryPoint -eq "SMB")
        {
            $Global:incidentData = FileSharingEntry
        }
        elseif($script:IT_EntryPoint -eq "NetworkAdapter")
        {
            $Global:incidentData = NetworkAdapterEntry
			
			# If the user did not select a specific adapter we revert to default connectivity diagnostics
			$adapterGuid = (([xml] $Global:incidentData["HelperAttributes"]).HelperAttributes.HelperAttribute | where {$_.Name -eq "guid"}).Value
			$regDefaultDiagnosisOption = (get-itemproperty -path hklm:\SYSTEM\CurrentControlSet\Control\NetDiagFx\Config  -name TroubleshooterAdapterEntryDefaultDiagnostics -ErrorAction SilentlyContinue -ErrorVariable regError).TroubleshooterAdapterEntryDefaultDiagnostics
			if($adapterGuid -eq "{00000000-0000-0000-0000-000000000000}" -and !$regError -and $regDefaultDiagnosisOption)
			{
				$script:IT_EntryPoint = "DefaultConnectivity"
				$Global:incidentData = GetWebNDFIncidentData $DefaultDiagURL $true
			}
        }
        elseif($script:IT_EntryPoint -eq "Winsock")
        {
            $Global:incidentData = WinsockEntry
        }
        elseif($script:IT_EntryPoint -eq "Grouping")
        {
            $Global:incidentData = GroupingEntry
        }
        elseif($script:IT_EntryPoint -eq "Inbound")
        {
            $Global:incidentData = InboundEntry
        }
        elseif($script:IT_EntryPoint -eq "DirectAccess")
        {
            $Global:incidentData = DirectAccessEntry
            if(!$Global:incidentData)
            {
                #not provisioned, root cause outside of NDF
                Update-DiagRootCause -ID "{E42E5B5A-16E0-43f1-AB32-C94C608D269D}" -Detected $true
                return;
            }
        }
        elseif($script:IT_EntryPoint -eq "DefaultConnectivity")
        {
            #DefaultConnectivity experience initially diagnoses default URL
            $Global:incidentData = GetWebNDFIncidentData $DefaultDiagURL $true
        }
        else
        {
            throw "Unexpected entry point specified"
        }
    }
	
    if($Global:incidentData -eq $null)
    {
        throw "Entry Point function failure"
    }

    while($true)
    {
        $regEnableSnapshotTelemetry = (get-itemproperty -path hklm:\SYSTEM\CurrentControlSet\Control\NetDiagFx\Config  -name TroubleshooterSnapshotTelemetry -ErrorAction SilentlyContinue -ErrorVariable regError).TroubleshooterSnapshotTelemetry
        if(!$script:isRerun -and !$regError -and $regEnableSnapshotTelemetry)
        {
            #if it's the first run, we invoke the NetworkSnapshot to telemeter data on the network state
            $adapterGuid = (([xml] $Global:incidentData["HelperAttributes"]).HelperAttributes.HelperAttribute | where {$_.Name -eq "guid"}).Value
            
            if($adapterGuid -eq $null)
            {
                $networkSnapshotCommand = "netsh trace diagnose Scenario=NetworkSnapshot Mode=NetTroubleshooter"
            }
            else
            {
                # Snapshot a specific adapter if user entered though the NetworkAdapter entry point
                $networkSnapshotCommand = "netsh trace diagnose Scenario=NetworkSnapshot Mode=NetTroubleshooter AdapterGuid=`"$adapterGuid`""
            }
            
            Invoke-Expression -Command:$networkSnapshotCommand
        }
        
        #will diagnose, should attach trace file
        $script:attachTraceFile = $true

        $Global:incidentData["HelperClassName"] | convertto-xml | Update-DiagReport -id CreateIncidentHelperClass -name "Create Incident Helper Class" -description "CreateIncident Helper Class Value." -verbosity Debug
        $Global:incidentData["HelperAttributes"] | convertto-xml | Update-DiagReport -id CreateIncidentHelperAttributes -name "Create Incident Helper Attributes" -description "CreateIncident Helper Attributes Value." -verbosity Debug


        $Global:ndf = new-object -comObject ndfapi.NetworkDiagnostics.1 -strict
        $Global:ndf.CreateIncident($Global:incidentData["HelperClassName"], $Global:incidentData["HelperAttributes"])

        $waitHandle =  $Global:ndf.Diagnose($DiagnoseWaitTime, 0)
        if($waitHandle -eq $null)
        {
            throw "Diagnose call failed"
        }

        WaitWithProgress $localizationString.progress_Diagnosing_NoDetails $waitHandle $Global:ndf

        #check diagnose result
        $diagResult = $Global:ndf.DiagnoseResult

        if(($script:IT_EntryPoint -eq "DefaultConnectivity") -and (!$script:isRerun))
        {
            #for the DefaultConnectivity entry point, if no issues are found then we ask a few follow up questions and potentially re-diagnose
            if(($diagResult -eq $S_OK) -and ($Global:ndf.RootCauses.Count -eq 0))
            {
                #no issues were found, see if there's anything else to diagnose

                #first add tracelog from session to report
                AddTraceFileToSession $Global:ndf $localizationString.TraceFileReportName "Diagnose"
                #add network config information to report
                AddNetworkInfoToSession;

                #do not attach file if we break out of loop rather than re-diagnose
                $script:attachTraceFile = $false

                #query the user for new entry point
                $Global:incidentData = DefaultConnectivityFollowUpEntry
                if($Global:incidentData -eq $null)
                {
                    #nothing else to diagnose
                    break;
                }
                else
                {
                    $script:IT_EntryPoint = "DefaultConnectivityOther"
                }
            }
            else
            {
                #issues found, break out of loop
                break;
            }
        }
        else
        {
            #for anything other than the DefaultConnectivity entry point we only diagnose once during a run
            break;
        }
    }
}



if($diagResult -eq $S_OK)
{
    $Global:rootCauseEnum = $Global:ndf.RootCauses
    if($Global:rootCauseEnum -ne $null)
    {
        #enumerate through root causes
        $rootCauseCount = $Global:rootCauseEnum.Count

        $rootCauseCount  | convertto-xml | Update-DiagReport -id RootCausecount -name "Root Cause Count" -description "The following number of root causes were found." -verbosity Debug

        #collect catch-all information for use later
        $Global:catchAlls = @{}; #will contain the RC's with catch all repairs, indexed by HC it applies to
        $catchAllsIndex = @{}; #will hold the index of the catch-all in the root cause list
        $Global:catchAllsAltRC = @{}; #will contain the alternate RC ID for the catch all, if available, indexed by root cause
        GetCatchAllInformation ($Global:rootCauseEnum) ([ref]$Global:catchAlls)  ([ref]$catchAllsIndex)  ([ref]$Global:catchAllsAltRC);

        $Global:rootCauseEnum.Reset()
        for($i=0; $i -lt $rootCauseCount; $i++)
        {
            $rootCause=$Global:rootCauseEnum.Next;

            "ID:" + $rootCause.RootCauseID + " Description:" + $rootCause.Description | convertto-xml | Update-DiagReport -id RootCauseFound -name "Root Cause Found" -description "A Root Cause was found." -verbosity Debug

            $rcFlags=$rootCause.Flags;
            if($rcFlags -band $RCF_ISTHIRDPARTY)
            {
                $rootCause.RootCauseID + " is a third party root cause. Filters and catch-alls do not apply." | convertto-xml | Update-DiagReport -id ThirdPartyRootCause -name "Third Party Root Cause" -verbosity Debug
            }
            else
            {
                #check if RC is filtered
                $catchAllRC = $null;
                $filterMode = 0;
                $filterValue = GetRootCauseFilterValue ($rootCause) ([ref]$filterMode);
                if($filterValue -eq $FV_FILTERED)
                {
                    #always drop filtered root causes
                    $rootCause.RootCauseID + " skipped because it is filtered." | convertto-xml | Update-DiagReport -id RootCauseSkipped -name "Root Cause Skipped" -verbosity Debug
                    continue;
                }
                elseif($filterValue -eq $FV_MISSING)
                {
                    #if the root cause is not in the inclusion list and not filtered, get the catch all data
                    $className = $rootCause.ClassName;
                    if($className)
                    {
                        $catchAllRC = $Global:catchAlls[$className];
                    }

                    if(!$catchAllRC)
                    {
                        #no catch all found, should we ignore the RC?
                        if($filterMode -eq $FM_CATCHALL)
                        {
                            #we're only in catch all mode, and this RC did not have a catch all to replace it. We allow the RC through.
                        }
                        else
                        {
                            $rootCause.RootCauseID + " skipped because it is not in the inclusion list." | convertto-xml | Update-DiagReport -id RootCauseSkipped -name "Root Cause Skipped" -verbosity Debug
                            continue;
                        }
                    }
                }

                #a all catch-all RC should only be surfaced as a catch-all for another root cause
                #So if this RC is not filtered, or a catch-all is in use and is the same as the current root cause,
                #skip if it's all catch-alls
                if(($filterValue -eq $FV_NOTFILTERED) -or ($catchAllRC -and ($catchAllRC.RootCauseID -eq $rootCause.RootCauseID)))
                {
                    $nonCatchAllPresent = $false;
                    $repairEnum = $rootCause.Repairs;
                    $repairCount = $repairEnum.Count;
                    if($repairCount -gt 0)
                    {
                        $repairEnum.Reset();
                        for($curRep=0; $curRep -lt $repairCount; $curRep++)
                        {
                            $repair = $repairEnum.Next;
                            if(!($repair.Flags -band $RF_RESERVED_CA))
                            {
                                $nonCatchAllPresent = $true;
                                break;
                            }
                        }

                        if(!$nonCatchAllPresent)
                        {
                            $rootCause.RootCauseID + " skipped because it only contained catch-alls" | convertto-xml | Update-DiagReport -id RootCauseSkipped -name "Root Cause Skipped" -verbosity Debug
                            continue;
                        }
                    }
                }
            }

            $rootCauseIndex = $i;
            if($catchAllRC)
            {
                #from now on we use the catch-all RC
                $rootCause = $catchAllRC;
                $rootCauseIndex = $catchAllsIndex[$catchAllRC];
            }

            $instanceID = GetInstanceIDRC ($rootCause) ($Global:catchAlls) ($Global:catchAllsAltRC)

            $repairEnum = $rootCause.Repairs
            $repairCount = $repairEnum.Count
            if($repairCount -eq 0)
            {
                $rootCause.RootCauseID | convertto-xml | Update-DiagReport -id RootCauseWithoutRepairs -name "Root Cause Without Repairs" -description "Skipped root cause without repairs." -verbosity Debug
                continue;
            }

            &{

                if($Global:previousNdf)
                {
                    #before we add the root cause, lets make sure we shouldn't be skipping it
                    $skipReason = $Global:previousNdf.ShouldSkipRootCause($rootCause);
                    if($skipReason -ne $NDF_SKIPREASON_NONE)
                    {
                        $skipText = GetSkipReasonText($skipReason)
                        $rootCause.RootCauseID + " skipped due to reason: " + $skipText  | convertto-xml | Update-DiagReport -id RootCauseSkipped -name "Root Cause Skipped" -verbosity Debug
                        continue;
                    }
                }

                #try to add root cause. an exception will be thrown
                #if it is not manifested

                $rcToAttach = $rootCause.RootCauseID;
                if($catchAllRC)
                {
                    #get the catch-all root cause ID if available
                    if($Global:catchAllsAltRC[$catchAllRC])
                    {
                        $rcToAttach = $Global:catchAllsAltRC[$catchAllRC];
                        "Attaching catch-all Root Cause instead. ID:" + $rcToAttach | convertto-xml | Update-DiagReport -id CatchAllRootCause -name "Catch-all Root Cause used." -verbosity Debug
                    }
                }

                #collect the replacement parameters
                $params = @{"InstanceID" = $instanceID};

                #Get extra replacement parameters from repair
                $descEx = $rootCause.DescriptionEx
                if(!($descEx -eq $null))
                {
                    $params += GetParameters $descEx $params
                }

                #also need parameters for every repair
                $repairEnum.Reset()
                for($curRep=0; $curRep -lt $repairCount; $curRep++)
                {
                    $repair = $repairEnum.Next
                    $descEx = $repair.DescriptionEx
                    if(!($descEx -eq $null))
                    {
                         $params += GetParameters $descEx $params
                    }
                }

                #add security boundary safe data
                $data = GetSBSData $Global:ndf.IncidentID
                $params.Add("SBSData",$data)

                #keywords for escalation
                $keywords = GetKeywords($rootCause.DescriptionEx);
                if($keywords.Length -gt 0)
                {
                    $params.Add("Keywords", $keywords);
                }

                $script:ExpectingException = $true;
               

                Update-DiagRootCause -InstanceId $instanceID -ID $rcToAttach -Detected $true -Parameter $params
                $script:ExpectingException = $false;

                #log the parameters
                $evtDesc =  "Root Cause " + $rcToAttach
                $params |  convertto-xml | Update-DiagReport -id RootCauseParameters -name "Root Cause Parameters" -description $evtDesc -verbosity Debug
            }
            trap [Exception] {
                if($script:ExpectingException)
                {
                    $script:ExpectingException = $false
                    #add unmanifested root cause
                    $params = @{"InstanceID" = $instanceID};
                    $uRC = GetUnmanifestedRootCause $rootCause ([ref]$params) ($catchAllRC)
                    #pop-msg "URC " + $uRC
                    if(!($uRC -eq $null))
                    {
                        Update-DiagRootCause -InstanceId $instanceID -ID $uRC -Detected $true -Parameter $params

                        #log the parameters
                        $evtDesc =  "Root Cause " + $rootCause.RootCauseID + " (" + $uRC + ")"
                        $params |  convertto-xml | Update-DiagReport -id RootCauseParameters -name "Root Cause Parameters" -description $evtDesc -verbosity Debug
                    }
                    continue
                }
                else
                {
                    #rethrow exception
                    throw $_.Exception;
                }
            }
        }
    }
}
elseif(!($diagResult -eq $S_FALSE))
{
    AddTraceFileToSession $Global:ndf $localizationString.TraceFileReportName "Diagnose"

    #may have failed due to service state or boot mode

    #first verify that DPS is running and that we aren't in safe mode.
    Write-DiagProgress -activity $localizationString.progress_Diagnosing_SafeMode
    $safeMode = IsSafeMode
    if($safeMode)
    {
        Update-DiagRootCause -ID "{6880DE42-9ED5-454a-8490-BA407BEABC22}" -Detected $true
        return;
    }

    #check if DPS is started
    Write-DiagProgress -activity $localizationString.progress_Diagnosing_DPS
    $dpsStarted = IsDPSStarted
    if(!$dpsStarted)
    {
        $dpsDisabled = IsDPSDisabled
        if($dpsDisabled)
        {
            Update-DiagRootCause -ID "{A693C86C-3907-4467-8A92-F360C3482C01}" -Detected $true
        }
        else
        {
            Update-DiagRootCause -ID "{F4148D83-8526-48e2-B21A-01894ECCE98C}" -Detected $true
        }
        return;
    }

    throw "Diagnosis failed with HRESULT" + $diagResult
}

#finished with troubleshooting

#if we re-opened an existing incident, there's no need to retrieve the trace file
#since nothing new was done other than re-reading the diagnostics results
if($script:attachTraceFile)
{
    #add tracelog to report
    AddTraceFileToSession $Global:ndf $localizationString.TraceFileReportName "Diagnose"
    #add network config information to report
    AddNetworkInfoToSession;
}

#clear validation result in case we are re-running
$Global:ValidateResult = $null

