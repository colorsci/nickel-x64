function Get-NetworkControllerReplica()
{
    param(
      [string]$ServiceTypeName,
      [switch]$AllReplicas
    )
    
    # Set Fabric.Code path if it is not already set.
    if (!$env:Path.Contains("$env:ProgramFiles\Microsoft Service Fabric\bin\Fabric\Fabric.Code"))
    {
        $env:Path=$env:Path+";"+"$env:ProgramFiles\Microsoft Service Fabric\bin\Fabric\Fabric.Code;"
    }

    if (!(Get-Module -ListAvailable -Name ServiceFabric))
    {
        Import-Module "$env:ProgramFiles\Microsoft Service Fabric\bin\ServiceFabric\ServiceFabric";
    }

    $a = Connect-ServiceFabricCluster -WarningAction "SilentlyContinue"
    Write-Output ""

    if([String]::IsNullOrEmpty($ServiceTypeName))
    {
        $services = Get-ServiceFabricApplication fabric:/NetworkController | Get-ServiceFabricService
    }
    else
    {
        $servicename = "fabric:/NetworkController/" + $ServiceTypeName
        $services = Get-ServiceFabricService "fabric:/NetworkController" -ServiceName $servicename
    }

    foreach ($service in $services) 
    {
        "Replicas for service:" + $service.ServiceTypeName
        $replicas = Get-ServiceFabricPartition $service.ServiceName | Get-ServiceFabricReplica 
        if ($AllReplicas -eq $false) { $replicas = $replicas | where {$_.ReplicaRole -eq "Primary"} } 
        $replicas | Select-Object ReplicaRole,NodeName,ReplicaStatus | fl 
    }
}

Export-ModuleMember -Function Get-NetworkControllerReplica