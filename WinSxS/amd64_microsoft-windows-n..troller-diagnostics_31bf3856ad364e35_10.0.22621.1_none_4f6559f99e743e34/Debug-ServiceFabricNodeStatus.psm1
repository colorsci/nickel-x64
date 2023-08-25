function Debug-ServiceFabricNodeStatus
{
    param(
            [string][parameter(Mandatory=$true, HelpMessage="Name of the NC Micro Service e.g. SlbManagerService OR ApiService.")] $ServiceTypeName
    )

    # This Script Monitors Fabric Node Status
    # Tracks transitions (displays running diff) in replica roles, health states etc.
    # Useful as an on screen debug diagnostic.

    $TargetNcServiceName= "fabric:/NetworkController/$ServiceTypeName"
    $WaitIntervalSec = [int] 1
    $Script:PreviousReplicas = $null

    while ($true)
    {
        $res = Connect-ServiceFabricCluster -WarningAction SilentlyContinue
        $NcServiceFabricPartion = Get-ServiceFabricPartition -ServiceName $TargetNcServiceName

        $NcServiceFabricReplicas = Get-ServiceFabricReplica -PartitionId $NcServiceFabricPartion.PartitionId
    
        Display-DiffReplicaStatus $NcServiceFabricReplicas

        $Script:PreviousReplicas = $NcServiceFabricReplicas

        Start-Sleep -s $WaitIntervalSec
    }
}

function Stringify-NodeProperties ($node, [System.Collections.Generic.HashSet[String]] $set)
{
    $prefix = $(($node).NodeName)

    $ignore = $set.Add("                      $prefix    START          ")
    $ignore = $set.Add("$prefix | ReplicaId                 : $(($node).ReplicaId)")
    $ignore = $set.Add("$prefix | ReplicaAddress            : $(($node).ReplicaAddress)")
    $ignore = $set.Add("$prefix | ReplicaRole               : $(($node).ReplicaRole)")
    $ignore = $set.Add("$prefix | NodeName                  : $(($node).NodeName)")
    $ignore = $set.Add("$prefix | ReplicaStatus             : $(($node).ReplicaStatus)")
    $ignore = $set.Add("$prefix | LastInBuildDuration       : $(($node).LastInBuildDuration)")
    $ignore = $set.Add("$prefix | HealthState               : $(($node).HealthState)")
    $ignore = $set.Add("                      $prefix    END          ")
}

function Display-DiffReplicaStatus ($newReplicas)
{
    $prevReplicas = $Script:PreviousReplicas
    $prevSet = new-object "System.Collections.Generic.HashSet[String]"
    $currSet = new-object "System.Collections.Generic.HashSet[String]"

    foreach ($node in $prevReplicas)
    {
        Stringify-NodeProperties $node $prevSet
    }

    foreach ($node in $newReplicas)
    {
        Stringify-NodeProperties $node $currSet
    }

    if ($currSet.SetEquals($prevSet))
    {
        return
    }

    $lastUpdateTime = $(Get-Date)
    Write-Host -ForegroundColor Cyan "----- $lastUpdateTime ----"
    Write-Host -ForegroundColor Cyan "----- Complete Current State ----"
    foreach ($prop in $currSet)
    {
        Write-Host $prop
    }

    Write-Host -ForegroundColor Cyan "----- Printing DIFF State for above Replic Set Update ----"

    $diffSet = new-object "System.Collections.Generic.HashSet[String]" $currSet
    $diffSet.SymmetricExceptWith($prevSet)

    foreach ($prop in $diffSet)
    {
        if ($currSet.Contains($prop))
        {
            Write-Host -ForegroundColor Yellow $prop
        }
        else
        {
            Write-Host -ForegroundColor Red $prop
        }

    }

    Write-Host -ForegroundColor Cyan "----- END ----"
    Write-Host -ForegroundColor Yellow "Polling for Change, Press CNTRL + c to exit ... Last Update: $lastUpdateTime"
}

Export-ModuleMember -Function Debug-ServiceFabricNodeStatus

