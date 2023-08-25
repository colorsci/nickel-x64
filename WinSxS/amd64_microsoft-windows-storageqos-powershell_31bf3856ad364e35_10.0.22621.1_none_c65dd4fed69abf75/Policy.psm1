Import-LocalizedData -BindingVariable resources -FileName storageqosresources.psd1

Add-Type -TypeDefinition @"
namespace Microsoft.StorageQos {
   public enum PolicyType
   {
      Aggregated = 0,
      Dedicated = 1
   }
}
"@

Add-Type -TypeDefinition @"
namespace Microsoft.StorageQos {
   public enum Status
   {
      Ok = 0,
      InsufficientThroughput,
      UnknownPolicyId,
      LostCommunication
   }
}
"@

# Arbitrary strings can be sucessfully cast to CimInstance!
function ValidatePolicy
{
    param($p)

    if ($p -and -not ([bool]($p.PsObject.Properties.Name -match "CimClass" -and $p.CimClass.CimClassName -eq "MSFT_StorageQoSPolicy")))
    {
        return $false
    }
    return $true
}

function New-StorageQosPolicy
{
    [CmdletBinding(DefaultParameterSetName = "Arguments", ConfirmImpact = "Medium", SupportsShouldProcess = $true)]

    Param(

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = "Object")]
        [CimInstance] $Policy,

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Arguments")]
        [System.Guid] $PolicyId,

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Arguments")]
        [string] $Name,

        [Parameter(Mandatory = $false, Position = 2, ParameterSetName = "Arguments")]
        [uint64] $MaximumIops,

        [Parameter(Mandatory = $false, Position = 3, ParameterSetName = "Arguments")]
        [uint64] $MinimumIops,

        [Parameter(Mandatory = $false, Position = 4, ParameterSetName = "Arguments")]
        [uint64] $MaximumIOBandwidth,

        [Parameter(Mandatory = $false, Position = 5, ParameterSetName = "Arguments")]
        [CimInstance] $ParentPolicy,

        [Parameter(Mandatory = $false, Position = 6, ParameterSetName = "Arguments")]
        [Microsoft.StorageQos.PolicyType] $PolicyType,

        [Switch] $AsJob,

        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32] $ThrottleLimit

    )

    Begin {}

    Process
    {
        $ns = "root\Microsoft\Windows\storage"
        $info = $resources.info
        $p = $null

        if ($pscmdlet.ParameterSetName -eq "Object")
        {
            if (-not (ValidatePolicy($policy)))
            {
                Write-Error "Policy must be a valid CimInstance object of type MSFT_StorageQosPolicy."
                return
            }

            $p = $policy
            $info = $resources.info_plural
        }
        else
        {
            if (-not (ValidatePolicy($parentpolicy)))
            {
                Write-Error "ParentPolicy must be a valid policy object returned by Get-StorageQosPolicy."
                return
            }

            $properties = @{
                "PolicyId" = [string] $policyid;
                "Name" = $name;
                "ThroughputLimit" = $maximumiops;
                "ThroughputReservation" = $minimumiops;
                "BandwidthLimit" = $maximumiobandwidth;
                "ParentPolicy" = [string] $parentpolicy.policyid;
                "PolicyType" = [uint16] $policytype;
            }

            $p = New-CimInstance -ClientOnly -ClassName "MSFT_StorageQoSPolicy" -Namespace $ns -Property $properties -Confirm:$false
        }

        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }

        # Would use a closure here, but jobs are run in their own session state.
        $block = {
            param($session, $ns, $policy, $asjob)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $store = Get-CimInstance -CimSession $session -Namespace $ns -ClassName "MSFT_StorageQoSPolicyStore"

            $r = $store | Invoke-CimMethod -Name "CreatePolicy" -Arguments @{"Policy" = $policy} -Confirm:$false

            $r.Policy
        }

        if ($asjob)
        {
            Start-Job -ScriptBlock $block -ArgumentList @($cimsession, $ns, $p, $true)
        }
        else
        {
            if ($pscmdlet.ShouldProcess($info, $resources.warning, $info))
            {
                &$block $cimsession $ns $p
            }
        }
    }

    End {}
}

function Get-StorageQoSFlow
{
    [CmdletBinding()]

    Param(

        [Parameter(Position = 0, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.Guid] $FlowId,

        [Parameter(Position = 1, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.String] $InitiatorId,

        [Parameter(Position = 2, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.String] $FilePath,

        [Parameter(Position = 3, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.String] $VolumeId,

        [Parameter(Position = 4, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.String] $InitiatorName,

        [Parameter(Position = 5, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.String] $InitiatorNodeName,

        [Parameter(Position = 6, Mandatory = $false, ParameterSetName = "Arguments")]
        [System.String] $StorageNodeName,

        [Parameter(Position = 7, Mandatory = $false, ParameterSetName = "Arguments")]
        [Microsoft.StorageQos.Status] $Status,

        [Parameter(Position = 8, Mandatory = $false, ParameterSetName = "Arguments")]
        [Switch] $IncludeHidden,

        [Parameter(Position = 9, Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Object")]
        [Microsoft.Management.Infrastructure.CimInstance] $Policy,

        [Switch] $AsJob,

        [Microsoft.Management.Infrastructure.CimSession] $CimSession,

        [Int32] $ThrottleLimit

    )

    Begin {}

    Process
    {
        $ns = "root\Microsoft\Windows\storage"

        if (-not $cimsession)
        {
            $cimsession = New-CimSession
        }

        $block = {
            param($session, $ns, $query, $policy, $asjob)

            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            if ($query -ne $null)
            {
                $prefix = @{$true = " WHERE "; $false = ""}

                Get-CimInstance -CimSession $session -Namespace $ns -Query ("select * from MSFT_StorageQoSFlow" + $prefix[$query.Length -gt 0] + $query)
            }
            else
            {
                $policy | Get-CimAssociatedInstance -CimSession $session -Namespace $ns -Association "MSFT_StorageQoSPolicyToFlow" -ResultClassName "MSFT_StorageQoSFlow"
            }
        }

        $query = $null

        if ($pscmdlet.ParameterSetName -eq "Arguments")
        {
            $query = @{$true = "FlowId != '00000000-0000-0000-0000-000000000000'"; $false = ""}[$flowid -eq $null -and -not $includehidden]

            $prefix = @{$true = " AND "; $false = ""}

            $psboundparameters.Keys | ? { $_ -notin @("Status", "AsJob", "CimSession", "ThrottleLimit", "IncludeHidden") } `
                                    | % { $query += $prefix[$query.Length -gt 0] `
                                          + $_ + " LIKE '" + ($psboundparameters[$_] -replace "\\", "\\" -replace "\*", "%") + "'" }

            if ($status -ne $null)
            {
                $query += $prefix[$query.Length -gt 0] + "Status = " + [uint16]$status
            }
        }

        if ($asjob)
        {
            Start-Job -ScriptBlock $block -ArgumentList @($cimsession, $ns, $query, $policy, $true)
        }
        else
        {
                &$block $cimsession $ns $query $policy
        }
    }

    End {}
}

Export-ModuleMember New-StorageQosPolicy
Export-ModuleMember Get-StorageQoSFlow
Export-ModuleMember Microsoft.StorageQos.PolicyType
Export-ModuleMember Microsoft.StorageQos.Status
