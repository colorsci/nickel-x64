# Copyright © 2008, Microsoft Corporation. All rights reserved.


function SyncInvoke([string]$executable = $(throw "No executable is specified"), [string]$arguments, [bool]$isHidden = $false)
{
    [int]$timeOut = 60000
    [System.Diagnostics.ProcessStartInfo]$startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $executable
    $startInfo.Arguments = $arguments
    $startInfo.UseShellExecute = $true
    if($isHidden)
    {
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
    }
    else
    {
        $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
    }

    [bool]$result = $false
    [System.Diagnostics.Process]$process = $null
    try
    {
        $process = [System.Diagnostics.Process]::Start($startInfo)
        $result = $process.waitforexit($timeOut)
    }
    finally
    {
        if(-not $process.HasExited)
        {
            $process.Kill()
        }
    }

    return $result
}
