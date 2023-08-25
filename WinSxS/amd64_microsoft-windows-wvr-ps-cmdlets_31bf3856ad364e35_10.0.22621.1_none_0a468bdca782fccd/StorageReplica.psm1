
Import-LocalizedData -BindingVariable SRStringTable -FileName "StorageReplicaStrings.psd1"

function Get-SRClusterResource
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $ComputerName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $GroupId
    )

    $Result = $null

    $StorageReplicaResources = Get-WmiObject -ComputerName $ComputerName -Namespace ROOT\MSCluster -Class MSCluster_Resource -Filter "Type='Storage Replica'"

    foreach ($resource in $StorageReplicaResources)
    {
        if ($resource.PrivateProperties.ReplicationGroupId -eq $GroupId)
        {
            $Result = $resource

            break
        }
    }

    Write-Output $Result
}

function Get-SRNewGroupCommand
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [Object] $Group
    )

    $Name              = $Group.Name
    $OwnerName         = $Group.ComputerName
    $Description       = $Group.Description
    $IsWriteConsistent = $Group.IsWriteConsistency
    $IsEncrypted       = $Group.IsEncrypted
    $IsCompression     = $Group.IsCompression
    $LogVolume         = $Group.LogVolume
    $LogSizeInBytes    = $Group.LogSizeInBytes
    $DataVolumes       = $Group.Replicas[0].DataVolume

    for ($index=1; $index -lt $Group.Replicas.Count; $index++)
    {
        $DataVolumes = $DataVolumes + ',' + $Group.Replicas[$index].DataVolume
    }

    if ($Group.IsCluster -eq $true)
    {
        $GroupId = '{' + $Group.Id + '}'

        $Resource = Get-SRClusterResource -ComputerName $Group.ComputerName -GroupId $GroupId

        if ($Resource -eq $null)
        {
            throw $SRStringTable.ResourceNotFound + " $Name"
        }

        $OwnerName = $Resource.OwnerNode
    }

    $NewGroupCommand = [String]::Format("New-SRGroup -Computer {0} -Name {1} -VolumeName {2} -LogVolumeName {3} -LogSizeInBytes {4}", $OwnerName, $Name, $DataVolumes, $LogVolume, $LogSizeInBytes)

    if ([String]::IsNullOrWhiteSpace($Description) -eq $false)
    {
        $NewGroupCommand = [String]::Format("{0} -Description '{1}'", $NewGroupCommand, $Description)
    }

    if ($IsWriteConsistent -eq $true)
    {
        $NewGroupCommand += " -EnableConsistencyGroups"
    }

    if ($IsEncrypted -eq $true)
    {
        $NewGroupCommand += " -EnableEncryption"
    }

    if ($IsCompressed -eq $true)
    {
        $NewGroupCommand += " -EnableCompression"
    }

    Write-Output $NewGroupCommand
}

function Export-SRConfiguration
{
    [CmdletBinding(SupportsShouldProcess=$false)]
    param
    (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("CN")]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $ComputerName,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("P")]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $Path,

        [Parameter(Mandatory=$false, Position=2)]
        [Alias("S")]
        [Switch] $Seeded,

        [Parameter(Mandatory=$false, Position=99)]
        [Alias("AC")]
        [Switch] $AllowClobber
    )

    if ((Test-Path -Path $Path -IsValid) -eq $false)
    {
        throw (New-Object -TypeName System.ArgumentException -ArgumentList "Path")
    }

    if ((Test-Path -Path $Path -PathType Container) -eq $true)
    {
        throw (New-Object -TypeName System.IO.IOException -ArgumentList $SRStringTable.PathIsDirectory)
    }


    $Partnerships         = $null
    $ExportedPartnerships = 0
    $Groups               = @{}
    $ExportedGroups       = 0


    Write-Progress -Activity $SRStringTable.ActivityExportConfig -Status $SRStringTable.DiscoverPartnerships


    if ([String]::IsNullOrEmpty($ComputerName) -eq $false)
    {
        $Partnerships = Get-SRPartnership -ComputerName $ComputerName -Name * | Select-Object -Unique

        foreach ($group in (Get-SRGroup -ComputerName $ComputerName))
        {
            $Groups += @{ $group.Name = $group }
        }
    }
    else
    {
        $Partnerships = Get-SRPartnership

        foreach ($group in (Get-SRGroup))
        {
            $Groups += @{ $group.Name = $group }
        }
    }


    if ($Partnerships -ne $null -or $Groups.Count -gt 0)
    {
        if ((Test-Path -Path $Path) -eq $true)
        {
            if ($AllowClobber -eq $false)
            {
                $FileExistsError = [String]::Format($SRStringTable.FileExists, $Path)
                throw (New-Object -TypeName System.IO.IOException -ArgumentList $FileExistsError)
            }

            Clear-Content -Path $Path -Force
        }
    }


    #
    # Export groups which are part of an active
    # replication partnership.
    #
    if ($Partnerships -ne $null)
    {
        foreach ($partnership in $Partnerships)
        {
            $partnershipToString = [String]::Format(" {0} : {1} -> {2} : {3}", $partnership.SourceComputerName, $partnership.SourceRGName, $partnership.DestinationComputerName, $partnership.DestinationRGName)

            Write-Progress -Activity $SRStringTable.ActivityExportConfig -Status ($SRStringTable.ProcessingPartnership + $partnershipToString)

            $SourceComputerName      = $partnership.SourceComputerName
            $SourceGroupName         = $partnership.SourceRGName
            $DestinationComputerName = $partnership.DestinationComputerName
            $DestinationGroupName    = $partnership.DestinationRGName

            $SourceRG = Get-SRGroup -ComputerName $partnership.SourceComputerName -Name $SourceGroupName
            if ($SourceRG -eq $null)
            {
                throw $SRStringTable.GroupNotFound + " $SourceGroupName"
            }

            $DestinationRG = Get-SRGroup -ComputerName $partnership.DestinationComputerName -Name $DestinationGroupName
            if ($DestinationRG -eq $null)
            {
                throw $SRStringTable.GroupNotFound + " $DestinationGroupName"
            }

            $ReplicationMode = $DestinationRG.ReplicationMode

            $NewSourceGroupCommand      = Get-SRNewGroupCommand -Group $SourceRG
            $NewDestinationGroupCommand = Get-SRNewGroupCommand -Group $DestinationRG

            $NewPartnershipCommand = [String]::Format("New-SRPartnership -SourceComputerName {0} -SourceRGName {1} -DestinationComputerName {2} -DestinationRGName {3} -ReplicationMode {4}", $SourceComputerName, $SourceGroupName, $DestinationComputerName, $DestinationGroupName, $ReplicationMode)

            if ($DestinationRG.AsyncRPO -ne $null)
            {
                $NewPartnershipCommand += [String]::Format(" -AsyncRPO {0}", $DestinationRG.AsyncRPO)
            }

            if ($Seeded -eq $true)
            {
                $NewPartnershipCommand += " -Seeded"
            }

            $NewPartnershipCommand += " -PreventReplication"


            Add-Content -Path $Path -Value $NewSourceGroupCommand
            Add-Content -Path $Path -Value $NewDestinationGroupCommand
            Add-Content -Path $Path -Value $NewPartnershipCommand
            Add-Content -Path $Path -Value ([String]::Empty)

            $ExportedGroups += 2
            $ExportedPartnerships += 1

            if ($Groups.ContainsKey($SourceGroupName))
            {
                $Groups.Remove($SourceGroupName)
            }

            if ($Groups.ContainsKey($DestinationGroupName))
            {
                $Groups.Remove($DestinationGroupName)
            }
        }

        Add-Content -Path $Path -Value ([String]::Format("Write-Host {0}", $SRStringTable.ExecuteSyncGroup))
    }


    #
    # Export groups on the specified computer even
    # if they are not part of a replication partnership.
    #
    if ($Groups.Count -gt 0)
    {
        Add-Content -Path $Path -Value ([String]::Empty)
        Add-Content -Path $Path -Value "#"
        Add-Content -Path $Path -Value ("# " + $SRStringTable.GroupsNotInPartnership)
        Add-Content -Path $Path -Value "#"

        foreach ($groupName in $Groups.Keys)
        {
            Write-Progress -Activity $SRStringTable.ActivityExportConfig -Status ($SRStringTable.ProcessingGroup + " $groupName")

            $Group = $Groups[$groupName]

            $NewGroupCommand = Get-SRNewGroupCommand -Group $Group

            Add-Content -Path $Path -Value $NewGroupCommand
            Add-Content -Path $Path -Value ([String]::Empty)

            $ExportedGroups += 1
        }
    }


    Write-Progress -Activity $SRStringTable.ActivityExportConfig -Completed


    if ($ExportedPartnerships -gt 0)
    {
        Write-Host -Object ([String]::Format($SRStringTable.PartnershipsExported, $ExportedPartnerships))
    }
    else
    {
        Write-Host -Object $SRStringTable.NoPartnershipsFound
    }
   
    if ($ExportedGroups -gt 0)
    {
        Write-Host -Object ([String]::Format($SRStringTable.GroupsExported, $ExportedGroups))
    }
    else
    {
        Write-Host -Object $SRStringTable.NoGroupsFound
    }
}
