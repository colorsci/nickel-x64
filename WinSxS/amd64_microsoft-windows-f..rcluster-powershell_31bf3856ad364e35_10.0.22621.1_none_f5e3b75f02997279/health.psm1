Import-LocalizedData -BindingVariable strings -FileName healthstrings.psd1

function Enable-HealthService
{
    [CmdletBinding(ConfirmImpact = "Medium", SupportsShouldProcess = $true)]

    Param(
        [Microsoft.Management.Infrastructure.CimSession] $CimSession = (New-CimSession)
    )

    Begin {}

    Process
    {
        $ns = "root\MSCluster"

        $cluster = Get-CimInstance -CimSession $cimsession -Namespace $ns -ClassName "MSCluster_Cluster"

        if ($cluster -and $pscmdlet.ShouldProcess(($strings.target -f $cluster.Name), $strings.action))
        {
            $r = Get-CimInstance -CimSession $cimsession -Namespace $ns -ClassName "MSCluster_ClusterService" | Invoke-CimMethod -Name "EnableHealth" -Confirm:$false

            if ($r.ReturnValue -ne 0)
            {
                Write-Error (New-Object -TypeName System.ComponentModel.Win32Exception -ArgumentList @([int]$r.ReturnValue))
            }
        }
    }

    End {}
}

Export-ModuleMember Enable-HealthService