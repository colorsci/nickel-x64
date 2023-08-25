#
# Copyright (c) Microsoft Corporation.  All rights reserved.
#
# Version: 1.0.0.0
# Revision 2015.05.26
#

# --------------------------------------------------------------------------------------------------------------------------
# CONSTANTS
# --------------------------------------------------------------------------------------------------------------------------
$TIMESTAMP_FORMAT = "yyyy/MM/dd HH:mm:ss.fffffff"

$WORKDIR = "$env:TEMP\WindowsUpdateLog"

# TraceRpt.exe fails with "data area passed in too small" error which is really just insufficient buffer error. It happens
# when the total size of ETLs we're passing in is too huge. We're going to batch it every 10 ETLs to workaround the issue.
$MAX_ETL_PER_BATCH = 10

# Column headers in CSV produced by tracerpt.exe
$CSV_HEADER= "EventName, Type, Event ID, Version, Channel, Level, Opcode, Task, Keyword, PID, TID, ProcessorNumber, InstanceID, ParentInstanceID, ActivityID, RelatedActivityID,  ClockTime, KernelTime, UserTime, UserData, Function, LogMessage, Ignore1, Ignore2, IgnoreGuid1, SourceLine, IgnoreTime, Ignore3, Category, LogLevel, TimeStamp, IgnoreGuid2"

# --------------------------------------------------------------------------------------------------------------------------
# FUNCTIONS
# --------------------------------------------------------------------------------------------------------------------------

#
# Given a path to single ETL file or a directory containing multiple ETL files, return a list containing the fullpaths of the ETLs.
#
function GetListOfETLs
{
    Param(
        [string[]] $Paths = $(throw "'Paths' parameter is required.")
    )

    Write-Verbose "Gathering ETL files ..."

    $etlList = New-Object Collections.Generic.List[string]

    foreach ($path in $Paths)
    {
        # If user passes in a directory as $ETLPath, grabs all the ETLs in that folder.
        if (Test-Path $path -PathType Container)
        {
            $etls = Get-ChildItem $path -Filter WindowsUpdate*.etl

            if ($etls.Length -eq 0)
            {
                throw "File not found: No Windows Update ETL file under $path"
            }

            foreach ($etl in $etls)
            {
                $etlList.Add($etl.FullName.Trim())
            }
        }
        else
        {
            if (!(Test-Path $path))
            {
                throw "File not found: $path"
            }

            $etlList.Add($path.Trim())
        }
    }

    if ($etlList.Count -gt 1)
    {
        Write-Verbose "Sorting ETLs numerically ..."    

        # Pad the last decimal before .etl in WindowsUpdate.20150609.225042.704.1.etl so ETLs can be sorted numerically.    
        $etlList = $etlList | Sort-Object { [regex]::Replace($_, '\d+(?=.etl)', { $args[0].Value.PadLeft(10) }) }
    }

    Write-Verbose "Found $($etlList.Count) ETLs."

    return $etlList
}

#
# The ScriptBlock for decoding ETL files to XML or CSV files and then converting those XML or CSV files To Log files.
#
$ScriptBlock_DecodeETL =
{
    param(
        [Collections.Generic.List[string]] $ETLList = $(throw "'ETLList' parameter is required."),
        [int] $StartIndex = $(throw "'StartIndex' parameter is required."),
        [int] $Length = $(throw "'Length' parameter is required."),
        [string] $OutPath = $(throw "'OutPath' parameter is required."),
        [string] $LogPath = $(throw "'LogPath' parameter is required."),
        [string] $DebugPath = $(throw "'DebugPath' parameter is required."),
        [ValidateSet('XML', 'CSV')] $Type = $(throw "'Type' parameter is required.")
    )

    # Access variables defined in the outer scope while running this script block via Start-Job
    $VerbosePreference = $using:VerbosePreference

    $TIMESTAMP_FORMAT = $using:TIMESTAMP_FORMAT
    $CSV_HEADER= $using:CSV_HEADER

    #
    # Given a list of ETLs, decode them into XML or CSV file using TraceRpt.exe
    #
    function DecodeETL
    {
        Param(
            [Collections.Generic.List[string]] $ETLList = $(throw "'ETLList' parameter is required."),
            [string] $OutPath = $(throw "'OutPath' parameter is required."),
            [ValidateSet('XML', 'CSV')] $Type = $(throw "'Type' parameter is required.")
        )

        Write-Verbose "Decoding $($ETLList.Count) ETLs to $OutPath using $Type processing ..."

        if (Test-Path $OutPath)
        {
            Remove-Item $OutPath -Force -ErrorAction Stop
        }

        #
        # Build tracerpt arguments.
        #
        $arguments = New-Object Collections.Generic.List[string]

        # ETL files
        $arguments.AddRange($ETLList)

        # output format
        $arguments.Add("-of")
        $arguments.Add($Type)

        # output file
        $arguments.Add("-o")
        $arguments.Add($OutPath)

        # no prompt
        $arguments.Add("-y")

        #
        # Decode ETLs to XML
        #
        $start = Get-Date

        & "tracerpt.exe" $arguments

        Write-Verbose "Done. Elapsed: $((Get-Date).Subtract($start).TotalMilliseconds) ms."

        if ($LastExitCode -ne 0)
        {
            throw "Failed to decode ETLs. TraceRpt.exe returned error= $LastExitCode"
        }

        if (!(Test-Path $OutPath))
        {
            throw "Failed to decode ETLs. TraceRpt.exe failed to produce $OutPath"
        }
    }

    #
    # Given an XML file produced by tracerpt.exe, convert it to user friendly text log.
    #
    function ConvertXmlToLog
    {
        Param(
            [string] $XmlPath = $(throw "'XmlPath' parameter is required."),
            [string] $LogPath = $(throw "'LogPath' parameter is required.")
        )

        Write-Verbose "Converting $XmlPath to $LogPath ..."

        if (Test-Path $LogPath)
        {
            Remove-Item $LogPath -Force -ErrorAction Stop
        }

        [xml] $xml = Get-Content $XmlPath

        $writer = New-Object IO.StreamWriter $LogPath
        $start = Get-Date

        try
        {
            $nodeNum = 0

            $xml.Events.Event | ForEach-Object {

                $row = $_

                try
                {
                    $systemNode = $_.System
                    $providerNode = $systemNode.Provider
                    $providerName = $systemNode.Provider.Name

                    if ($providerNode -ne $null -And $providerName -eq "WUTraceLogging")
                    {
                        $eventDataNode = $_.EventData
                        $executionNode = $systemNode.Execution
                        [DateTime] $datetime = $systemNode.TimeCreated.SystemTime
                        
                        $keywordNode = $_.RenderingInfo
                        

                        # Log columns:
                        # Time ProcessID ThreadID Component Message
                        $writer.WriteLine("$($datetime.ToString($TIMESTAMP_FORMAT)) $($executionNode.ProcessID.ToString().PadRight(5)) $($executionNode.ThreadID.ToString().PadRight(5)) $($keywordNode.Task.ToString().PadRight(15)) $($eventDataNode.Data.'#text')")
                    }
                }
                catch
                {
                    # Log exception, eat it, and process the rest of the log.
                    Write-Warning "Unable to process node $nodeNum."

                    "Failed to process line:$nodeNum of $XmlPath`n$row`n$_`n---" | Out-File $DebugPath -Encoding UTF8 -Append
                }

                $nodeNum++
            } # foreach
        }
        finally
        {
            $writer.Close()
        }

        Write-Verbose "Done. Elapsed: $((Get-Date).Subtract($start).TotalMilliseconds) ms."
    }

    #
    # Given a CSV file produced by tracerpt.exe, convert it to user friendly text log.
    #
    function ConvertCsvToLog
    {
        Param(
            $CsvPath = $(throw "'CsvPath' parameter is required."),
            $LogPath = $(throw "'LogPath' parameter is required.")
        )

        Write-Verbose "Converting $CsvPath to $LogPath ..."

        if (Test-Path $LogPath)
        {
            Remove-Item $LogPath -Force -ErrorAction Stop
        }

        $csvText = Get-Content $CsvPath
        $csvText[0] = $CSV_HEADER

        $csv = ConvertFrom-Csv $csvText

        $writer = New-Object IO.StreamWriter $LogPath
        $start = Get-Date

        try
        {
            $lineNum = 0

            $csv | ForEach-Object {

                $row = $_

                try
                {
                    if ($_.EventName -ne "EventTrace" -And !($_.EventName.StartsWith("{")))
                    {
                        [DateTime] $datetime = [DateTime]::FromFileTimeUTC($_.ClockTime).ToLocalTime()

                        # convert hex string to decimals
                        $processId = $_.PID -as [int]
                        $threadId = $_.TID -as [int]

                        # Log columns:
                        # Time ProcessID ThreadID Component Message
                        $writer.WriteLine("$($datetime.ToString($TIMESTAMP_FORMAT)) $($processId.ToString().PadRight(5)) $($threadId.ToString().PadRight(5)) $($_.EventName.PadRight(15)) $($_.UserData)")
                    }
                }
                catch
                {
                    # Log exception, eat it, and process the rest of the log.
                    Write-Warning "Unable to process line $lineNum."

                    "Unable to process line:$lineNum of $CsvPath`n$row`n$_`n---" | Out-File $DebugPath -Encoding UTF8 -Append
                }

                $lineNum++
            } # foreach
        }
        finally
        {
            $writer.Close()
        }

        Write-Verbose "Done. Elapsed: $((Get-Date).Subtract($start).TotalMilliseconds) ms."
    }

    #
    # Call function DecodeETL here.
    #
    DecodeETL -ETLList $ETLList.GetRange($StartIndex, $Length) -OutPath $OutPath -Type $Type

    #
    # Call function ConvertXmlToLog or ConvertCsvToLog here.
    #
    if ($Type -eq 'XML')
    {
        ConvertXmlToLog -XmlPath $OutPath -LogPath $LogPath
    }
    else
    {
        ConvertCsvToLog -CsvPath $OutPath -LogPath $LogPath
    }
}

function FlushWindowsUpdateETLs
{
    Write-Verbose "Flushing Windows Update ETLs ..."

    Stop-Service usosvc -ErrorAction Stop
    Stop-Service wuauserv -ErrorAction Stop

    Write-Verbose "Done."
}

#
# Print the DecodeETL results.
# The result from the script "tracerpt.exe" may has some unuseful messages. Please see BUG 33709951 for more details
# Remove all unnecessary empty lines and keep the latest progress value (100%)
#
function PrintDecodeETLResults
{
    Param(
        [string] $result = $(throw "'result' parameter is required.")
    )

    $array = $result.Split(
        [Environment]::NewLine,
        [StringSplitOptions]::RemoveEmptyEntries
    )

    foreach ($str in $array)
    {
        # Find the line in the output showing something like 0.00%0.50%0.90%...
        if ($str.StartsWith('0.00%'))
        {
            # Only print the last percentage value, e.g. "100%"
            $percentages = $str.Split(
                '%',
                [StringSplitOptions]::RemoveEmptyEntries
            )

            "`n$($percentages[-1])%`n"
        }
        else
        {
            # Just print the whole line
            $str
        }
    }
}

#
# Given an ETL path, convert the ETL file(s) into text log.
#
function ConvertETLsToLog
{
    Param(
        [string[]] $ETLPaths = $(throw "'etlPaths' parameter is required."),
        [string] $LogPath = $(throw "'LogPath' parameter is required."),
        [ValidateSet('XML', 'CSV')] $Type = $(throw "'type' parameter is required.")
    )

    if ($ETLPaths.Count -gt 1)
    {
        $progressDisplayStr = "`nMerging and converting $($ETLPaths.Count) ETLs into $LogPath ..."
    }
    elseif ($ETLPaths.Count -eq 1)
    {
        $progressDisplayStr = "`nConverting $($ETLPaths[0]) into $LogPath ..."
    }
    else
    {
        throw "No Windows Update ETL file found."
    }

    "`nGetting the list of all ETL files..."

    $start = Get-Date

    [Collections.Generic.List[string]] $etlList = GetListOfETLs -path $ETLPaths
    # Create Working Directory
    New-Item -Path $WORKDIR -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

    # Make the file name be unique, so when multiple WindowsUpdateLog.psm1 run in parallel,
    # these temp files won't stomp on each other.
    $guid = New-Guid
    $tempFilePath = "$WORKDIR\wuetl.$Type.tmp.$guid"
    $tempLogPath = "$WORKDIR\wuetl.log.tmp.$guid"
    $NEW_DEBUG_LOG_PATH = "$WORKDIR\debug.$guid.log"

    Remove-Item "$tempFilePath.*" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$tempLogPath.*" -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item $NEW_DEBUG_LOG_PATH -Force -ErrorAction SilentlyContinue | Out-Null

    $processed = 0;
    $tempFileCount = 0

    # Pad tempFileCount so files can be sorted numerically.
    $NumFormat = "{0:00000}"

    $decodeETLJobs = @()

    while ($processed -lt $etlList.Count)
    {
        $remaining = $etlList.Count - $processed

        $numberedTempFile = "$tempFilePath.$NumFormat" -f $tempFileCount
        $numberedLogFile = "$tempLogPath.$NumFormat" -f $tempFileCount

        if ($remaining -ge $MAX_ETL_PER_BATCH)
        {
            # Parameters for executing $ScriptBlock_DecodeETL
            [Object[]] $scriptBlockParams = @(
                $etlList, #ETLList
                $processed, #StartIndex
                $MAX_ETL_PER_BATCH, #Length
                $numberedTempFile, #OutPath
                $numberedLogFile, #LogPath
                $NEW_DEBUG_LOG_PATH, #DebugPath
                $Type #Type
            )
    
            $decodeETLJobs += Start-Job -Name "WULog_${tempFileCount}" -ScriptBlock $ScriptBlock_DecodeETL -ArgumentList $scriptBlockParams
            
            $processed += $MAX_ETL_PER_BATCH
        }
        else
        {
            # Parameters for executing $ScriptBlock_DecodeETL
            [Object[]] $scriptBlockParams = @(
                $etlList, #ETLList
                $processed, #StartIndex
                $remaining, #Length
                $numberedTempFile, #OutPath
                $numberedLogFile, #LogPath
                $NEW_DEBUG_LOG_PATH, #DebugPath
                $Type #Type
            )
        
            $decodeETLJobs += Start-Job -Name "WULog_${tempFileCount}" -ScriptBlock $ScriptBlock_DecodeETL -ArgumentList $scriptBlockParams

            $processed += $remaining
        }       

        $tempFileCount++
    }

    Write-Verbose "Background Job Information:"
    if ($VerbosePreference -ne "SilentlyContinue")
    {
        Get-Job
    }

    "`nPlease wait for all of conversions to complete...`n"

    # Display the progress bar and wait for all jobs in $decodeETLJobs to complete
    $total = @($decodeETLJobs | Where State -eq Running).Count
    do
    {
        $completed = @($decodeETLJobs | Where State -eq Completed).Count

        $per = $completed / $total * 100
        Write-Progress -Activity $progressDisplayStr -Status "$completed/$total Complete:" -PercentComplete $per
        Start-Sleep -Milliseconds 1000
    } Until (($decodeETLJobs | Where State -eq Running).Count -eq 0)

    # When all background jobs completed, display 100% in the progress bar for 1 sec,
    # and then close the progress bar
    Write-Progress -Activity $progressDisplayStr -Status "$total/$total Complete:" -PercentComplete 100
    Start-Sleep -Milliseconds 1000
    Write-Progress -Activity $progressDisplayStr -Status "$total/$total Complete:" -Completed

    $failed = $false;

    # Go through jobs in $decodeETLJobs to check their States. Print the result of each job on demand.
    # Remove all jobs at the end.
    foreach ($job in $decodeETLJobs)
    {
        "`n================ Results from $($job.Name) ================`n"

        $result = Receive-Job $job
        if ($job.State -eq 'Failed')
        {
            Write-Warning $result
            $failed = $true
        }
        else
        {
            $output = out-string -InputObject $($job.ChildJobs.output)
            PrintDecodeETLResults -result $output
        }

        "`n==================================================`n"

        Remove-Job $job
    }

    if ($failed)
    {
        throw "Failed to Complete Get-WindowsUpdateLog Cmdlet!";
    }

    if ($tempFileCount -gt 1)
    {
        $actualFileCount = (Get-ChildItem "$tempLogPath.*" | Measure-Object).Count

        Write-Verbose "Merging all $actualFileCount temporary logs into one ..."

        # If the actual file count is not equal to the expected, print warning.
        if ($actualFileCount -ne $tempFileCount)
        {
            Write-Warning "Expected has $tempFileCount temporary logs, but actually has $actualFileCount. So this will affect the WindowsUpdate.log file."
        }
        Get-Content "$tempLogPath.*" | Out-File $LogPath -Encoding UTF8
    }
    else
    {
        $src = "$tempLogPath.$NumFormat" -f 0
        Copy-Item -Path $src -Destination $LogPath -ErrorAction Stop
    }

    # Removing $tempLogPath.* and $tempFilePath.*
    Remove-Item "$tempLogPath.*" -ErrorAction SilentlyContinue | Out-Null
    Remove-Item "$tempFilePath.*" -ErrorAction SilentlyContinue | Out-Null

    Write-Verbose "Total elapsed: $((Get-Date).Subtract($start).TotalMilliseconds) ms."

    "`nWindowsUpdate.log written to $LogPath`n"
}

#.ExternalHelp WindowsUpdateLog.psm1-help.xml
function Get-WindowsUpdateLog
{
    [CmdLetBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High')]
    Param(
        [parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [Alias('PsPath')]
        [string[]] $ETLPath = @("$env:windir\logs\WindowsUpdate"),

        [parameter(
            Position = 1)]
        [string] $LogPath = "$([Environment]::GetFolderPath("Desktop"))\WindowsUpdate.log",

        [ValidateSet('CSV', 'XML')]
        [string] $ProcessingType = 'XML',

        [switch] $ForceFlush
    )

    begin
    {
        $etls = New-Object Collections.ArrayList
    }

    process
    {
        #
        # Handles pipeline input. For e.g. get-childitem C:\temp | get-windowsupdatelog
        #
        if ($_ -ne $null)
        {
            if ($_.PsPath -eq $null -or !(Test-Path $_.PsPath))
            {
                throw "ETL file cannot be found or is invalid: $_"
            }
            
            $etls.Add($_.FullName) | Out-Null
        }
        #
        # Handles regular input. For e.g. get-windowsupdate.log C:\temp\WindowsUpdate1.etl, C:\temp\WindowsUpdate2.etl
        #
        else
        {
            foreach ($p in $ETLPath)
            {
                if (!(Test-Path $p))
                {
                    throw "File not found: $p"
                }
                $etls.Add($p) | Out-Null
            }
        }
    }

    end
    {
        if ($ForceFlush)
        {
            if ($PSCmdlet.ShouldProcess("$env:COMPUTERNAME", "Stopping Update Orchestrator and Windows Update services"))
            {
                FlushWindowsUpdateETLs
            }
            else
            {
                return
            }
        }

        # The rest of the function doesn't support -WhatIf, so just bail out if -WhatIf is specified
        if ($WhatIfPreference)
        {
            return
        }

        #
        # Make sure we have permission to write log file to requested path.
        #
        $logDir = Split-Path -Parent $LogPath

        if (!(Test-Path $logDir))
        {
            New-Item -Path $logDir -ErrorAction Stop
        }

        try
        {
            "Checking write access" | Out-File -FilePath $LogPath -Encoding ascii
        }
        catch [UnauthorizedAccessException]
        {
            throw "No permission to write to $LogPath"
        }

        #
        # Do work now.
        #

        ConvertETLsToLog -ETLPaths $etls -LogPath $LogPath -Type $ProcessingType
    }
}

Export-ModuleMember -Function Get-WindowsUpdateLog
