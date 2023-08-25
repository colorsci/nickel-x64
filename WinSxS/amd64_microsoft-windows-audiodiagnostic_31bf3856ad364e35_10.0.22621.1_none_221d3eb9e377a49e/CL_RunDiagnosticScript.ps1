# Copyright © 2008, Microsoft Corporation. All rights reserved.


function RunDiagnosticScript([ScriptBlock]$script = $(throw "No script is specified"))
{
    if($script -eq $null)
    {
        throw "No script found"
    }

    $result = &$script

    if($result -is [bool])
    {
        return [bool]$result
    }
    else
    {
        return $false
    }
}
