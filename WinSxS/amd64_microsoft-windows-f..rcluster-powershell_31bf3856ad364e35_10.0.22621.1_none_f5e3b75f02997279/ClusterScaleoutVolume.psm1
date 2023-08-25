function ValidateVolume
{
    param($p)

    if ($p -and -not ([bool]($p.PsObject.Properties.Name -match "CimClass" -and $p.CimClass.CimClassName -eq "MSCluster_ScaleoutVolume")))
    {
        return $false
    }
    return $true
}

function Get-ErrorMessage($status)
{
    $ex = New-Object System.ComponentModel.Win32Exception($status)
    return $ex.Message
}


function DisplayOrError($result)
{
    if ($null -eq $result.ReturnValue)
    {
        $result
    }
    else 
    {
        Get-ErrorMessage([int32] $result.ReturnValue)
    }
}


function Set-ClusterScaleoutVolumeZoneTargetPath {

    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a target zone')]
        [System.String] $ZoneTarget

    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
        $PSBoundParameters.Confirm = $true
    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        try
        {
            if (ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Set-ClusterScaleoutVolumeZoneTargetPath"))
            {
                $r = $volume | Invoke-CimMethod -Name "SetSVZoneTargetPath" -Arguments @{"ZoneId" = $ZoneId; "targetPath" = $ZoneTarget;} -ErrorAction Stop 
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $r
    }

}

function Set-ClusterScaleoutZoneGroupId{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a new group ID')]
        [System.String] $GroupId
    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
    }
    Process
    {
        
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }

        try
        {
            if ( ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Set-ClusterScaleoutZoneGroupId"))
            {
                $result = $volume | Invoke-CimMethod -Name "UpdateGroupIdForSVDataZone" -Arguments @{"ZoneId" = $ZoneId; "ZoneGroupId" = $GroupId;} -ErrorAction Stop
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result

    }
    
}



function Add-ClusterScaleoutZone {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact = 'High')]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, HelpMessage='Supply a valid data zone GUID')]
        [System.String] $ZoneId,

        [parameter(Mandatory=$false, HelpMessage='Supply a group ID')]
        [System.String] $GroupId = "00000000-0000-0000-0000-000000000000",

        [parameter(Mandatory=$true, HelpMessage="The size of the zone to be added in bytes")]
        [System.Int64] $ZoneSize,

        [parameter(Mandatory=$false, HelpMessage='Supply a zone target path')]
        [System.String] $TargetPath = ""
    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
        $PSBoundParameters.Confirm = $true
    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        
        try
        {
            if ( ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Add-ClusterScaleoutZone"))
            {
                $result = $volume | Invoke-CimMethod -Name "AddDataZoneToSV" -Arguments @{"ZoneId" = $ZoneId; "ZoneGroupId" = $GroupId; "sizeInBytes" = $ZoneSize; "ZoneTargetPath" = $TargetPath} -ErrorAction Stop
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result        
    }

    End {}
    
}

function Suspend-ClusterScaleoutZone {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId

    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        
        try
        {
            if (ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Suspend-ClusterScaleoutZone"))
            {
                $result = $volume | Invoke-CimMethod -Name "SuspendSVDataZone" -Arguments @{"ZoneId" = $ZoneId} -ErrorAction Stop
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result

    }
}

function Resume-ClusterScaleoutZone {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId

    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        try
        {
            if (ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Resume-ClusterScaleoutZone"))
            {
                $result = $volume | Invoke-CimMethod -Name "ResumeSVDataZone" -Arguments @{"zoneId" = $ZoneId} -ErrorAction Stop
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result
    }
}

function Disable-ClusterScaleoutZone {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId
    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
        $PSBoundParameters.Confirm = $true
    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        try
        {
            if ( ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Disable-ClusterScaleoutZone"))
            {
                $result = $volume | Invoke-CimMethod -Name "RetireSVDataZone" -Arguments @{"zoneId" = $ZoneId} -ErrorAction Stop
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result
    }
}


function Remove-ClusterScaleoutZone {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId,

        [parameter(Mandatory=$false, ValueFromPipeline=$false, HelpMessage='Force removal')]
        [System.Boolean] $Force = $false

    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
        $PSBoundParameters.Confirm = $true
    }
    Process
    {
       if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        try
        {
            if ( ValidateVolume($volume) -And $psCmdlet.ShouldProcess($VolumeName, "Remove-ClusterScaleoutZone"))
            {
                $result = $volume | Invoke-CimMethod -Name "RemoveSVDataZone" -Arguments @{"ZoneId" = $ZoneId; "force" = $Force} -ErrorAction Stop
            }
            else 
            {
                Write-Host "ScaleoutVolume not found or invalid input object"
            }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result
    }
}

function Get-ClusterScaleoutZone {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume Object', ParameterSetName="WithVolObj")]
        [System.Object] $Vol,

        [parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelineByPropertyName=$false, HelpMessage='Supply a valid existing data zone GUID')]
        [System.String] $ZoneId

    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
    }
    Process
    {
        if($PSCmdlet.ParameterSetName -eq "WithVolObj")
        {
            $volume = $Vol
        }
        else
        {
            $volume = Get-ClusterScaleoutVolume -VolumeName $VolumeName 
        }
        
        if ( ValidateVolume($volume) )
        {
            try
            {
                if ($psCmdlet.ShouldProcess($VolumeName, "Get-ClusterScaleoutZone"))
                {
                    $result = $volume | Invoke-CimMethod -Name "GetZoneInformation" -Arguments @{"ZoneId" = $ZoneId;} -ErrorAction Stop
                }
            }
            catch
            {
                $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
                $psCmdlet.WriteError($errorObject)
            }
        }
        else 
        {
            Write-Host "ScaleoutVolume not found or invalid input object"
        }
        return $result
    }
}

function Get-ClusterScaleoutVolume {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory=$false, ValueFromPipeline=$false, HelpMessage='Supply a valid Scaleout Volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName

    )
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
    }
    Process
    {
        try
        {
            if ($psCmdlet.ShouldProcess($VolumeName, "Get-ClusterScaleoutVolume"))
            {
                if( $PSBoundParameters.ContainsKey('VolumeName') )
                {
                    $result = (Invoke-CimMethod -Name "GetSVInformation" -Arguments @{"VolumeName" = $VolumeName;} -Namespace root/mscluster -ClassName MSCluster_ScaleoutVolume -ErrorAction Stop).RetrievedScaleoutVolume
                    
                }
                else
                {
                    $result = @()
                    $vols = Invoke-CimMethod -Name "GetAllSV" -Namespace root/mscluster -ClassName MSCluster_ScaleoutVolume -ErrorAction Stop
                    foreach ( $v in $vols )
                    {
                        $result += $v.ItemValue
                    }
                }
            }
            return $result
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
       
    }
}

function New-ClusterScaleoutVolume {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory=$True, ValueFromPipeline=$false, HelpMessage='Supply a valid volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName,

        [parameter(Mandatory=$false, HelpMessage='Supply a group ID')]
        [System.String] $GroupId = "00000000-0000-0000-0000-000000000000",

        [parameter(Mandatory=$false, HelpMessage='Supply a group ID')]
        [System.String] $FriendlyName

    ) 
    Begin 
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
    }
    Process
    {
        try
        {
            if ($psCmdlet.ShouldProcess($VolumeName, "New-ClusterScaleoutVolume"))
            {
            	$result = (Invoke-CimMethod -Name "NewScaleoutVolume" -Arguments @{"VolumeName" = $VolumeName; "ZoneGroupId" = $GroupId; "FriendlyName" = $FriendlyName } -Namespace root/mscluster -ClassName MSCluster_ScaleoutVolume -ErrorAction Stop).CreatedScaleoutVolume
		    }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }

	    return $result
    }
}

function Remove-ClusterScaleoutVolume {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage='Supply a valid volume GUID', ParameterSetName="WithVolId")]
        [System.String] $VolumeName
    ) 
    Begin
    {
        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }
        $PSBoundParameters.Confirm = $true
    }
    Process
    {
        try
        {
            if ($psCmdlet.ShouldProcess($VolumeName, "Remove-ClusterScaleoutVolume"))
            {
                $result = Invoke-CimMethod -Name "DeleteSV" -Arguments @{"VolumeName" = $VolumeName; } -Namespace root/mscluster -ClassName MSCluster_ScaleoutVolume -ErrorAction Stop
		    }
        }
        catch
        {
            $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)
            $psCmdlet.WriteError($errorObject)
        }
        return $result
    }
}

Export-ModuleMember Set-ClusterScaleoutVolumeZoneTargetPath
Export-ModuleMember Set-ClusterScaleoutZoneGroupId
Export-ModuleMember Add-ClusterScaleoutZone
Export-ModuleMember Suspend-ClusterScaleoutZone
Export-ModuleMember Resume-ClusterScaleoutZone
Export-ModuleMember Disable-ClusterScaleoutZone
Export-ModuleMember Remove-ClusterScaleoutZone
Export-ModuleMember Get-ClusterScaleoutZone
Export-ModuleMember Get-ClusterScaleoutVolume
Export-ModuleMember Remove-ClusterScaleoutVolume
Export-ModuleMember New-ClusterScaleoutVolume
