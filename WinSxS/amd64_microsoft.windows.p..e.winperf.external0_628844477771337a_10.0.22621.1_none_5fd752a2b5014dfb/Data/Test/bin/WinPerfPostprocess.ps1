<#
.SYNOPSIS
    This script enables post processing of winperf results.
.DESCRIPTION
    This script will process raw winperf result.
.EXAMPLE
    powershell -ep bypass WinPerfPostprocess.ps1 -Postprocess
.PARAMETER Postprocess
    Switch that will take raw results data and create a "PerformanceResults.xml" file.
#>

[CmdletBinding(DefaultParameterSetName="Postprocess")]
param(
    [Parameter(ParameterSetName="Postprocess", Mandatory=$true)]
    [switch]$Postprocess
)

# This function attempts to load and validate winperf objects
# Returns the winperf module custom object
function LoadWinperf() {
    $addedTypes = Add-Type -Path (Join-Path $script:scriptPath WinPerf.Interop.dll) -PassThru
    
    if ($addedTypes -eq $null) {
        WriteLogError "Failed to create interop types for winperf"
        return $null
    }

    # See if we can create the objects
    $tempMessage = $null

    try {
        WriteLogComment "Trying to load winperf SxS"
        $CLSCTX_INPROC_SERVER = 0x1
        $REGCLS_MULTIPLEUSE = 1

        $IUnknownGuid = [Guid]'00000000-0000-0000-C000-000000000046'

        $scriptPathDoubleSlashed = $script:scriptPath.Replace("\", "\\")
    
        $script:native = Add-Type -Name "C$([Guid]::NewGuid().ToString('N'))" -PassThru @"
        [DllImport("ole32.dll")]
        static public extern int CoRegisterClassObject(
                ref Guid rclsid,
                [MarshalAs(UnmanagedType.IUnknown)] object pUnk,
                uint dwClsContext,
                uint flags,
                out uint lpdwRegister);

        [DllImport("ole32.dll")]
        static public extern int CoRevokeClassObject(
                uint dwRegister);
"@

        if ($script:native -eq $null) {
            WriteLogComment "Failed to load ole32.dll entry points"
            throw
        }


        # Load and get an entry point for winperf.dll
        $winperfDllName = "winperf.dll"
        $winperfDll = $null
        $winperfDll = Add-Type -Name "C$([Guid]::NewGuid().ToString('N'))" -PassThru @"
        [DllImport("$($scriptPathDoubleSlashed)\\${winperfDllName}", EntryPoint = "DllGetClassObject")]
        static public extern int WinperfGetClassObject(
                ref Guid rclsid,
                ref Guid riid,
                [MarshalAs(UnmanagedType.IUnknown)]out object ppv);
"@

        if ($winperfDll -eq $null) {
            WriteLogComment "Failed to load ${winperfDllName} entry point"
            throw
        }

        $script:cookies = 'MessageBroker', 'Message' | % {
            $type = [type]"WinPerf.Interop.${_}Class"
            $factory = $null
            $registrationCookie = 0
            $rc = $winperfDll::WinperfGetClassObject([ref]$type.GUID, [ref]$IUnknownGuid, [ref]$factory)
            if ($rc -ne $S_OK) {
                WriteLogComment "Cannot find winperf class factory for $_"
                throw
            }

            $rc = $native::CoRegisterClassObject([ref]$type.GUID, $factory, $CLSCTX_INPROC_SERVER, $REGCLS_MULTIPLEUSE, [ref]$registrationCookie)
            if ($rc -ne $S_OK) {
                WriteLogComment "Cannot register winperf class factory for $_"
                throw
            }

            $registrationCookie
        }

        $tempMessage = New-Object WinPerf.Interop.MessageClass
    } catch {
        # swallow
        WriteLogComment $_.Exception.ToString()
    }

    # Failed to create temp message with SxS COM - try registered COM
    if ($tempMessage -eq $null) {
        WriteLogComment "Failed to create winperf object with SxS COM so trying to load winperf from registry"

        try {
            $tempMessage = New-Object WinPerf.Interop.MessageClass
        } catch {
            # swallow
            WriteLogComment "Unable to use regged winperf"
        }
    }

    if ($tempMessage -eq $null) {
        WriteLogError "Failed to create winperf object with SxS COM as well as registered COM"
        return $null
    }

    # We have either registered COM or SxS objects that can be created - let's actually create the winperf module object we'll use
    WriteLogComment "Setting up winperf configuration"

    if ($Postprocess -or $PostprocessAndUpload) {
        $config = @"
        <configuration>
            <topology>
                <block priority="1000">Logger</block>
                <block priority="90">Profiles</block>
                <block priority="70">CollectEnvironment</block>
                <block priority="60">CollectMeasures</block>
                <block priority="10">UploadMeasures</block>
            </topology>
        </configuration>
"@
    } elseif ($UploadForPostprocess -or $UploadResult) {
        $config = @"
        <configuration>
            <topology>
                <block priority="1000">Logger</block>
                <block priority="90">Profiles</block>
                <block priority="10">UploadMeasures</block>
            </topology>
        </configuration>
"@
    } elseif ($UploadResultFolder) {
        $config = @"
        <configuration>
            <topology>
                <block priority="1000">Logger</block>
                <block priority="10">UploadMeasures</block>
            </topology>
        </configuration>
"@
    }

    $winPerfModule = New-Module -AsCustomObject -ArgumentList $config {
        $broker = New-Object WinPerf.Interop.MessageBrokerClass
        $broker.Initialize($args[0])

        function Send([string]$Pipe, [hashtable]$Properties = @{}) {
            $message = New-Object WinPerf.Interop.MessageClass
            foreach ($property in $Properties.GetEnumerator()) {
                $message.SetProperty($property.Key, $property.Value)
            }
            
            $broker.Send($Pipe, $message)

            return $message
        }
    }
    
    return $winPerfModule
}

function WriteLogComment($output)
{
    if ($script:WexLogging -eq $true)
    {
        [WEX.Logging.Interop.Log]::CommentWithContext($output, "WinPerfPostprocess.ps1")
    }
    else
    {
        Write-Host "WinPerfPostprocess.ps1: $output"
    }
}

function WriteLogError($output)
{
    if ($script:WexLogging -eq $true)
    {
        [WEX.Logging.Interop.Log]::ErrorWithContext($output, "WinPerfPostprocess.ps1")
    }
    else
    {
        Write-Host "Error: WinPerfPostprocess.ps1: $output"
    }
}

try {
    $exitcode = 0
    $S_OK = 0
    $script:native = $null
    $script:cookies = @()
    $script:scriptPath = (Split-Path -Parent $MyInvocation.MyCommand.Path)
    [environment]::CurrentDirectory = $PWD.Path

    # Add script directory to the path
    $env:Path = "$script:scriptPath;" + $env:Path

    if ($Action -eq "postprocess") {
        $Postprocess = $true
    }

    # Hack some parameter defaults for testd in office where these parameters are incorrectly set and difficult to override appropriately
    # When run with WTT job in office, [WTTHostWorkingDir] is set to "<LOCALAPPDATA>\Texus\HostTaskManager\WpConDeviceConnection\<device connection>"
    # When run with TestMD in office, working directory will be in a sub-folder of device connection, so we'll differentiate these two by the extra folder depth
    # For WTT Job, CopyResults task copies files to "<USERPROFILE>\TShell\Results\AutoGeneratedSubmission\<daytime_device>\<32bit>\<32bit>\1
    # For WTT job in lab, these two locations are the same, but in office they are different. Find the approipriate folder for the processing to occur against for wtt job in office.
    # For testmd, we only need to change to the upload command
    if ($script:scriptPath -match '.*Texus\\HostTaskManager\\WpConDeviceConnection\\[^\\]+\\Tools\\Winperf$')
    {
        $testdDevice = (($script:scriptPath -Split("WpConDeviceConnection\\"))[-1] -Split "\\")[0].Trim()

        # Find the most recent results folder for this device
        $directorySearchString = $env:UserProfile + "\Tshell\Results\AutoGeneratedSubmission\*_" + $testdDevice
        $directories = @()
        $directories += get-childitem $directorySearchString -Directory
        $newestDirectory = $null
        $newestDirectoryTime = [DateTime]::MinValue
        foreach ($directory in $directories)
        {
            if ($newestDirectoryTime -lt $directory.CreationTime)
            {
                $newestDirectory = $directory
                $newestDirectoryTime = $directory.CreationTime
            }
        }
        if ($newestDirectoryTime -eq [DateTime]::MinValue)
        {
            throw "Failed to find a results directory to process under $directorySearchString"
        }
        $rawResults = get-childitem $newestDirectory.FullName -filter "RawPerformanceDataMapping.xml" -recurse -file
        if ($rawResults -eq $null)
        {
            throw "No results to process under $newestDirectory"
        }
        $PostProcessDir = $rawResults.DirectoryName

        # Override the default to just Postprocess to actually PostprocessAndUpload since we won't have FGA pick up this run
        $Postprocess = $false
        $PostprocessAndUpload = $true

        WriteLogComment "Running wtt through testd, postprocessing and then uploading"
    } elseif ($script:scriptPath -match '.*Texus\\HostTaskManager\\WpConDeviceConnection\\[^\\]+\\[^\\]+\\Tools\\Winperf$') {
        # Override the default to just Postprocess to actually PostprocessAndUpload since we won't have FGA pick up this run
        $Postprocess = $false
        $PostprocessAndUpload = $true
        
        WriteLogComment "Running testmd through testd, postprocessing and then uploading"
    }

    if (-not [string]::IsNullOrEmpty($PostProcessDir)) {
        Set-Location $PostProcessDir
        [environment]::CurrentDirectory = $PostProcessDir
    }

    try {
        $wexloggerassembly = [Reflection.Assembly]::LoadFrom("$script:scriptPath\Wex.Logger.Interop.dll")
        if (-not [WEX.Logging.Interop.LogController]::IsInitialized())
        {
            [environment]::SetEnvironmentVariable("powershell_CMD", "/enablewttlogging")
            [WEX.Logging.Interop.LogController]::InitializeLogging("WinPerfPostprocess.wtl")
        }
        [WEX.Logging.Interop.Log]::StartGroup("WinPerfPostprocess.ps1")
        $script:WexLogging = $true
        WriteLogComment "Wexlogging to WinPerfPostprocess.wtl"
    } catch {
        # swallow
        WriteLogComment "No wexlogging"
    }
    
    WriteLogComment "Working directory is $PWD"
    WriteLogComment "SKU: $((Get-WmiObject -Class Win32_OperatingSystem).OperatingSystemSKU), Version: $((Get-WmiObject -Class Win32_OperatingSystem).Version)"

    $winPerf = LoadWinperf

    if ($winPerf -eq $null) {
        throw "Failed to load winperf"
    }

    # Create test data message for winperf commands
    $TestData = @{}    
    if ($Postprocess) {
        WriteLogComment "Running winperf action: Postprocess"
        
        $TestData.Add('Process', 'true')
        $TestData.Add('Upload', 'false')
    }
    
    WriteLogComment "Initialize"
    [void]$winPerf.Send('Initialize', $TestData)
    
    WriteLogComment "QueryComplete"
    [void]$winPerf.Send('QueryComplete')

} catch {
    WriteLogError $_.Exception.ToString()

    $exitcode = 1
} finally {
    if ($script:native -ne $null) {
        foreach( $cookie in $script:cookies) {
            $rc = $script:native::CoRevokeClassObject($cookie)
            if ($rc -ne $S_OK) {
                WriteLogComment "Cannot revoke class factory"
            }
        }
    }
    if ($script:WexLogging) {
        if ([WEX.Logging.Interop.LogController]::IsInitialized()) {
            [WEX.Logging.Interop.Log]::EndGroup("WinPerfPostprocess.ps1")
            [WEX.Logging.Interop.LogController]::FinalizeLogging()
        }
    }
}

exit $exitcode
