<#
// <copyright file="SMDeploymentHelpers.psm1" company="Microsoft">
//     Copyright (c) Microsoft Corporation.  All rights reserved.
// </copyright>
//
// <summary>
// Helper script cmdlets intended only for internal use by Server Manager
// via Deployment Scenario workflow Add-_InternalWindowsRole
// in its internal module SererManagerShell
// </summary>
//
// <remarks>
// The primary implementation of these M3P workflows is in
// Add-_InternalWindowsRole.xaml.  These helper functions are invoked via
// InvokeCommandActivity and InlineScriptActivity instances in those workflows.
// </remarks>
 #>

<#
WFGetCimGuid and the WFTrace primitives are called directly by InlineScriptActivity instances
in the M3P workflows.


Best Practices:

Parameters: Scripts run via InlineScriptActivity do not have
access to workflow variables, so these must be passed as explicit
function parameters. Use the $using:WFVariableName syntax in the
activity declaration to pass the value.

Tracing: Because debugging support for M3P workflows is so limited,
it is critical to include generous tracing support in M3P workflows and
their support scripts.  If possible, trace the entry and exit for key functions,
and trace the values of key inputs, outputs, and internal variables.

Errors: Workflows and their script helpers should report errors directly
to the error output stream.

New-WinEvent: Note that the payload must be provided with types consistent
with the defined payload in the instrumentation manifest. Otherwise the event
will be generated but the payload will be defined as an error.
In particular, bools must be specified as ints.
We use SilentlyContinue with New-WinEvent to ensure that tracing problems
do not affect the workflow.
#>

# Workflow helper functions

# Creates a dynamic instance of CimInstance#MSFT_ServerManagerRequestGuid
# and writes it to the output stream. Also writes the raw GUID
# so that the workflow can use it for tracing purposes.
function WFGetCimGuid
{
    $guid = [Guid]::NewGuid()
    $guidBytes = $guid.ToByteArray()
    $guidHigh = [BitConverter]::ToUInt64($guidBytes, 0)
    $guidLow = [BitConverter]::ToUInt64($guidBytes, 8)
    
    $cimInstance = New-CimInstance -ClassName MSFT_ServerManagerRequestGuid -Namespace root/Microsoft/Windows/ServerManager -ClientOnly -Property @{ LowHalf = [UInt64]$guidLow ; HighHalf = [UInt64]$guidHigh}

    $cimInstance

    # Also write the raw GUID
    $guid
}

function GetTargetComputer(
    [array][parameter(Position = 0)]$TargetComputers # can't be mandatory, could be empty
    )
{
    $targetComputer = ""
    if ($TargetComputers)
    {
        if ($TargetComputers.Count -ge 1)
        {
            if ($TargetComputers[0])
            {
                $targetComputer = $TargetComputers[0]
            }
        }
    }
    $targetComputer
}

function SafeString(
    [parameter(Position = 0)]$obj
    )
{
    if (-not ($obj -is [string]))
    {
        $obj = ""
    }
    $obj
}

function SafeInt(
    [parameter(Position = 0)]$obj
    )
{
    if (-not (($obj -is [int]) -or ($obj -is [uint32]) -or ($obj -is [byte])))
    {
        $obj = -1
    }
    [int]$obj
}

function SafeBoolToInt(
    [parameter(Position = 0)]$obj
    )
{
    if (-not ($obj -is [bool]))
    {
        $obj = $false
    }
    [int]$obj
}

function WFTraceAddWorkflowEnter(
    [array]$TargetComputers, # can't be mandatory, could be empty
    $ServerComponentDescriptors,
    [bool]$Remove,
    [string]$PathToVhdFile,
    [bool]$PermitReboot,
    [string]$Source,
    [bool]$DeleteComponents
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers
    $serverComponentNames = $ServerComponentDescriptors | % {$_.CimSystemProperties.ClassName}
    $nameString = SafeString ($serverComponentNames -join " ")
    $removeParam = SafeBoolToInt $Remove
    $vhdpath = SafeString $PathToVhdFile
    $permitRebootParam = SafeBoolToInt $PermitReboot
    $sourcepath = SafeString $Source
    $deleteComponentsParam = SafeBoolToInt $DeleteComponents

    # Note that New-WinEvent requires boolean payload to be passed as ints
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4000 -Payload @($targetComputer,$nameString,$removeParam,$vhdpath,$permitRebootParam,$sourcepath,$deleteComponentsParam) -ErrorAction SilentlyContinue
}

function WFTraceAddWorkflowExit(
    [array]$TargetComputers, # can't be mandatory, could be empty
    $AlterationState
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers
    $requestState = -1
    $restartRequired = 0
    $errorMessage = ""
    $errorId = ""
    $errorCategory = 0
    $warnings = ""

    if ($null -ne $AlterationState)
    {
        # Need to cast these so that New-WinEvent will work
        $requestState = SafeInt $AlterationState.RequestState
        $restartRequired = SafeBoolToInt $AlterationState.RestartRequired

        $error = $AlterationState.Error
        if ($null -ne $error)
        {
            $errorMessage = SafeString $error.ErrorMessage
            $errorId = SafeString $error.ErrorId
            $errorCategory = SafeInt $error.ErrorCategory
        }
        $warnings = SafeString ($AlterationState.Warnings -join "; ")
    }

    $id = 4001
    if (1 -ne $requestState) # 1 means Success
    {
        $id = 4002
    }

    # Note that New-WinEvent requires boolean payload to be passed as int
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id $id -Payload @($targetComputer,$requestState,$restartRequired,$errorMessage,$errorId,$errorCategory,$warnings) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowInstallLaunchStarted(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [System.Guid]$RequestGuid
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    # Note that New-WinEvent requires boolean payload to be passed as ints
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4010 -Payload @($targetComputer,$RequestGuid) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowInstallLaunchEnded(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [System.Guid]$RequestGuid,
    $AlterationState
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers
    $requestState = -1
    $restartRequired = 0
    $progressTicks = -1
    $totalTicks = -1
    $errorMessage = ""
    $errorId = ""
    $errorCategory = 0
    $warnings = ""

    if ($null -ne $AlterationState)
    {
        # Need to cast these so that New-WinEvent will work
        $requestState = SafeInt $AlterationState.RequestState
        $restartRequired = SafeBoolToInt $AlterationState.RestartRequired
        $progressTicks = SafeInt $AlterationState.ProgressTicks
        $totalTicks = SafeInt $AlterationState.TotalTicks

        $error = $AlterationState.Error
        if ($null -ne $error)
        {
            $errorMessage = SafeString $error.ErrorMessage
            $errorId = SafeString $error.ErrorId
            $errorCategory = SafeInt $error.ErrorCategory
        }
        $warnings = SafeString ($AlterationState.Warnings -join "; ")
    }

    # Note that New-WinEvent requires boolean payload to be passed as int
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4011 -Payload @($targetComputer,$RequestGuid,$requestState,$restartRequired,$progressTicks,$totalTicks,$errorMessage,$errorId,$errorCategory,$warnings) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowPollStarted(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [System.Guid]$RequestGuid
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    # Note that New-WinEvent requires boolean payload to be passed as ints
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4012 -Payload @($targetComputer,$RequestGuid) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowPollEnded(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [System.Guid]$RequestGuid,
    $AlterationState
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers
    $requestState = -1
    $restartRequired = 0
    $progressTicks = -1
    $totalTicks = -1
    $errorMessage = ""
    $errorId = ""
    $errorCategory = 0
    $warnings = ""

    if ($null -ne $AlterationState)
    {
        # Need to cast these so that New-WinEvent will work
        $requestState = SafeInt $AlterationState.RequestState
        $restartRequired = SafeBoolToInt $AlterationState.RestartRequired
        $progressTicks = SafeInt $AlterationState.ProgressTicks
        $totalTicks = SafeInt $AlterationState.TotalTicks

        $error = $AlterationState.Error
        if ($null -ne $error)
        {
            $errorMessage = SafeString $error.ErrorMessage
            $errorId = SafeString $error.ErrorId
            $errorCategory = SafeInt $error.ErrorCategory
        }
        $warnings = SafeString ($AlterationState.Warnings -join "; ")
    }

    # Note that New-WinEvent requires boolean payload to be passed as int
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4013 -Payload @($targetComputer,$RequestGuid,$requestState,$restartRequired,$progressTicks,$totalTicks,$errorMessage,$errorId,$errorCategory,$warnings) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowRestartCheckStarted(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [DateTime]$InitialLastBootTime
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    # Note that New-WinEvent requires boolean payload to be passed as ints
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4020 -Payload @($targetComputer,$InitialLastBootTime.ToFileTime()) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowRestartCheckEnded(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [DateTime]$InitialLastBootTime,
    [DateTime]$CurrentLastBootTime,
    [bool]$AlreadyRebooted
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    # Note that New-WinEvent requires boolean payload to be passed as ints
    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4021 -Payload @($targetComputer,$InitialLastBootTime.ToFileTime(),$CurrentLastBootTime.ToFileTime(),[int]$AlreadyRebooted) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowRestartStarted(
    [array]$TargetComputers # can't be mandatory, could be empty
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4022 -Payload @($targetComputer) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowRestartEnded(
    [array]$TargetComputers # can't be mandatory, could be empty
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4023 -Payload @($targetComputer) -ErrorAction SilentlyContinue
}

function WFTraceAddWindowsRoleWorkflowRestartTimeout(
    [array]$TargetComputers # can't be mandatory, could be empty
    )
{
    $targetComputer = GetTargetComputer -TargetComputers $TargetComputers

    New-WinEvent -Provider Microsoft-Windows-ServerManager-MultiMachine -Id 4024 -Payload @($targetComputer) -ErrorAction SilentlyContinue
}


# Returns 0 if the target computer is unreachable
# Returns 1 if LastBootUpTime has not changed
# Returns 2 if LastBootUpTime has changed
# If target machine is unreachable, this is $false
# Used internally by WFRestartComputer, not called directly from workflow
function Test-LastBootUpTimeChanged(
    [array]$TargetComputers,
    [DateTime]$InitialLastBootTime,
    [PSCredential]$Credential
    )
{
    trap { continue; } # Get-CimInstance can fail when target machine is rebooting
    WFTraceAddWindowsRoleWorkflowRestartCheckStarted -TargetComputers $TargetComputers -InitialLastBootTime $InitialLastBootTime

    if ($TargetComputers.Count -gt 0)
    {
        # It is expected that the computer might still be rebooting
        if (ActiveCredential $Credential)
        {
            # Need to create an explicit session in order to pass a credential
            $session = New-CimSession -ComputerName $TargetComputers[0] -Credential $Credential -ErrorAction SilentlyContinue
            if ($session)
            {
                try
                {
                    $instance = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session -ErrorAction SilentlyContinue
                }
                finally
                {
                    Remove-CimSession $session
                }
            }
        }
        else
        {
            $instance = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $TargetComputers[0] -ErrorAction SilentlyContinue
        }
    }
    else
    {
        $instance = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    }

    $alreadyRebooted = 0
    if ($null -ne $instance)
    {
        $current = $instance.LastBootUpTime
        if ($null -ne $current)
        {
            if ($InitialLastBootTime -eq $current)
            {
                $alreadyRebooted = 1
            }
            else
            {
                $alreadyRebooted = 2
            }
        }
        WFTraceAddWindowsRoleWorkflowRestartCheckEnded -TargetComputers $TargetComputers -InitialLastBootTime $InitialLastBootTime -CurrentLastBootTime $current -AlreadyRebooted ($alreadyRebooted -eq 2)
    }

    $alreadyRebooted
}

# Restart the target computer unless it can be shown to have already restarted.
# We need this to run as a single InlineScriptActivity so that M3P will not
# persist between retrieving the current LastBootUpTime and restarting;
# allowing this could potentially cause an infinite loop.
function WFRestartComputer(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [DateTime][Parameter(Mandatory=$true)]$StartTime,
    [DateTime][Parameter(Mandatory=$true)]$InitialLastBootTime,
    [PSCredential]$Credential
    )
{
    # We need to double-check that LastBootUpTime has not changed,
    # since this could be a workflow resume after local computer reboot.
    # Restart-Computer -Wait against the local computer does not have
    # the full LastBootUpTime logic, so we still need this in
    # the workflow.
    $rebooted = $false
    Write-Progress -Activity "Reboot target computer" -PercentComplete 80 -SourceId 1
    while ($true)
    {
        $alreadyRebooted = Test-LastBootUpTimeChanged -TargetComputers $TargetComputers -InitialLastBootTime $InitialLastBootTime -Credential $Credential
        switch ($alreadyRebooted)
        {
            0   { # Target not reachable
                    break
                }
            1   { # Target not yet rebooted
                    break
                }
            2   { # reboot was successful
                    return
                }
            default # Should not happen
                {
                    return
                }
        }

        # Terminate the workflow if reboot is still not complete
        # and the reboot sequence has been running for over an hour
        if (-not (CheckStartTimeWithinOneHour -StartTime $StartTime))
        {
            WFTraceAddWindowsRoleWorkflowRestartTimeout -TargetComputers $TargetComputers
            return
        }

        if ((1 -eq $alreadyRebooted) -and (-not $rebooted))
        {
            $rebooted = $true
            WFTraceAddWindowsRoleWorkflowRestartStarted $TargetComputers
            if ($TargetComputers.Count -gt 0)
            {
                if (ActiveCredential $Credential)
                {
                    Restart-Computer -Force -Protocol WSMan -ComputerName $TargetComputers[0] -Credential $Credential
                }
                else
                {
                    Restart-Computer -Force -Protocol WSMan -ComputerName $TargetComputers[0]
                }
            }
            else
            {
                # Local reboot is over DCOM in case WSMAN is down/disabled
                Restart-Computer -Force
            }
            WFTraceAddWindowsRoleWorkflowRestartEnded $TargetComputers
        }

        Start-Sleep -Seconds 15
    }
}

<#
This method is used by the "Final GetAlterationRequestState" loop
at the end of the ServerManagerShell\Add-WindowsRole.xaml workflow.
It returns true if timeout occurs, false otherwise.
#>
function WFCheckTimeout(
    [array]$TargetComputers, # can't be mandatory, could be empty
    [Parameter(Mandatory=$true)]$StartTime
    )
{
    if (CheckStartTimeWithinOneHour -StartTime $StartTime)
    {
        return $false
    }

    WFTraceAddWindowsRoleWorkflowRestartTimeout -TargetComputers $TargetComputers
    return $true
}

function ActiveCredential(
    [PSCredential]$Credential
    )
{
    if ($Credential)
    {
        if (-not [System.String]::IsNullOrEmpty($Credential.UserName))
        {
            return $true
        }
    }
    return $false
}

function CheckStartTimeWithinOneHour(
    [Parameter(Mandatory=$true)]$StartTime
    )
{
    # //!! FUTURE We should use (Get-Date).ToUniversalTime() to avoid rare issues associated with Daylight Savings Time.
    #             This would have to be applied here and also when StartTime is read.
    # //!! FUTURE Should probably present an error or warning message in this scenario
    $currentTime = Get-Date
    $elapsed = $currentTime - $StartTime[0]
    $withinOneHour = ($elapsed.TotalSeconds -lt (60*60))

    $withinOneHour
}
