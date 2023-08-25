data strings
{
# culture="en-US"
ConvertFrom-StringData @'
    UnexpectedError = An unexpected error occurred
    PathValidError = {0} is not a valid path
    FileDoesNotExistError = File {0} does not exist
    FileLoadError = Could not load {0}
    CouldNotCreateFSK = Specialization Data File creation failed
    FSKFileExtensionError = File extension must be .fsk
    PDKFileExtensionError = File extension must be .pdk
    FabricDataTypeError = SpecializationDataPairs must contain entries of type [string]
    VirtualMachineDoesNotExist = Virtual machine '{0}' could not be found
    ProvisioningJobNotFound = Could not find a matching provisioning job. The provisioning job may have been removed after completion.
    CimTypeError = Provided CimInstance must have an extended type of Msps_ProvisioningJob
    CimTypeErrorPDK = Provided file was not a valid Shielding Data File
'@
}

# import localized strings
Import-LocalizedData strings -FileName ShieldedVmCmdlets.strings.psd1 -ErrorAction SilentlyContinue
$ErrorActionPreference = "Stop"
$ExceptionsToTrap = @(
    [Microsoft.PowerShell.Commands.WriteErrorException],
    [Microsoft.HyperV.PowerShell.VirtualizationException],
    [Microsoft.Management.Infrastructure.CimException])

function New-ShieldedVMSpecializationDataFile {
    <#
        .NOTES
            Copyright (C) Microsoft Corporation. All rights reserved.

        .SYNOPSIS
            Creates a Specialization Data File to be used in provisioning a Shielded Virtual Machine
        
        .DESCRIPTION
            The Specialization Data File represents a set of key-value pairs used to specialize
            an unattend.xml when used to provision a Shielded Virtual Machine

        .PARAMETER ShieldedVMSpecializationDataFilePath
            The location to place the created VMSpecializationDataFile (.fsk)

        .PARAMETER SpecializationDataPairs
            A table of key-value pairs of type [string]

        .EXAMPLE
            New-ShieldedVMSpecializationDataFile -ShieldedVMSpecializationDataFilePath C:\Users\Robert\myfile.fsk -SpecializationDataPairs @{"@computername@"="pc-001"; "@timezone@"="GMT Standard Time"}

        .EXAMPLE
            New-ShieldedVMSpecializationDataFile C:\Users\Robert\myfile.fsk @{"@computername@"="pc-001"; "@timezone@"="GMT Standard Time"}
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$ShieldedVMSpecializationDataFilePath,

        [Parameter(Mandatory=$true,
            Position=1)]
        [ValidateNotNullOrEmpty()]
        [HashTable]$SpecializationDataPairs
    )

    process {
        trap {
            if ($_.Exception.GetType() -in $ExceptionsToTrap) {
                Write-Error $_.Exception
            } else {
                Write-Error -Message $strings.CouldNotCreateFSK -Exception $_.Exception
            }
        }

        # 

        # Verify types inside the hashtable
        foreach ($pair in $SpecializationDataPairs.GetEnumerator()) {
            if ($pair.Value -eq $null -or -Not ($pair.Key.GetType() -eq [string] -and $pair.Value.GetType() -eq [string])) {
                Write-Error $strings.FabricDataTypeError
            }
        }

        # Check path validity
        if (-Not (Test-Path $ShieldedVMSpecializationDataFilePath -IsValid) ) {
            Write-Error ($strings.PathValidError -f $ShieldedVMSpecializationDataFilePath)
        }

        # Check path extension
        if ([string]::IsNullOrEmpty([System.IO.Path]::GetExtension($ShieldedVMSpecializationDataFilePath))) {
            $ShieldedVMSpecializationDataFilePath += '.fsk'
        } elseif (-Not ([System.IO.Path]::GetExtension($ShieldedVMSpecializationDataFilePath) -eq '.fsk')) {
            Write-Error $strings.FSKFileExtensionError
        }

        # Resolve to absolute path for CIM
        if (-Not [System.IO.Path]::IsPathRooted($ShieldedVMSpecializationDataFilePath)) {
            $ShieldedVMSpecializationDataFilePath = [System.IO.Path]::GetFullPath((Join-Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path $ShieldedVMSpecializationDataFilePath))
        }

        # Create pairs
        $fskData = @()
        foreach ($pair in $SpecializationDataPairs.GetEnumerator()) {
            $cimVal = New-CimInstance -NameSpace root/msps -ClassName Msps_FabricData -Property @{Key=$pair.Key; Value=$pair.Value} -ClientOnly
            $fskData += $cimVal
        }

        # Aggregate pairs
        $fsk = New-CimInstance -Namespace root/msps -ClassName Msps_FSK -Property @{FabricDataPairs=[CimInstance[]]$fskData} -ClientOnly

        # Create FSK
        Invoke-CimMethod -ClassName Msps_ProvisioningFileProcessor -Namespace root/msps -MethodName SerializeToFile `
            -Arguments @{ProvisioningFile=$fsk; FilePath=$ShieldedVMSpecializationDataFilePath} | Out-Null
    }
}

function Test-ShieldingDataApplicability {
    <#
        .NOTES
            Copyright (C) Microsoft Corporation. All rights reserved.

        .SYNOPSIS
            This cmdlet verifies a Shielding Data File can be applied to a given Volume Signature Catalog
        
        .DESCRIPTION
            This cmdlet verifies a Shielding Data File can be applied to a given Volume Signature Catalog

        .PARAMETER ShieldingDataFilePath
            The location of a Shielding Data File (.pdk)

        .PARAMETER VolumeSignatureCatalogPath
            The location of a Volume Signature Catalog file (.vsc)

        .EXAMPLE
            Test-ShieldingDataApplicability -ShieldingDataFilePath C:\Users\Robert\bob.pdk -VolumeSignatureCatalogPath @{"@computername@"="pc-001"; "@productkey@"="1337haxx0r"}

        .EXAMPLE
            Test-ShieldingDataApplicability C:\Users\Robert\myfile.fsk @{"@computername@"="pc-001"; "@productkey@"="1337haxx0r"}
    #>
    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true,
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$ShieldingDataFilePath,

        [Parameter(Mandatory=$true,
            Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$VolumeSignatureCatalogPath
    )

    process {
        trap {
            if ($_.Exception.GetType() -in $ExceptionsToTrap) {
                Write-Error $_.Exception
            } else {
                Write-Error -Message $strings.UnexpectedError -Exception $_.Exception
            }
        }

        # Check file existence
        if (-Not (Test-Path $ShieldingDataFilePath) ) {
            Write-Error ($strings.FileDoesNotExistError -f $ShieldingDataFilePath)
        }

        if (-Not (Test-Path $VolumeSignatureCatalogPath) ) {
            Write-Error ($strings.FileDoesNotExistError -f $VolumeSignatureCatalogPath)
        }

        # Be kind towards missing/incorrect extensions
        # Underlying layer ignores them anyways 

        # Resolve to absolute paths
        if (-Not [System.IO.Path]::IsPathRooted($VolumeSignatureCatalogPath)) {
            $VolumeSignatureCatalogPath = [System.IO.Path]::GetFullPath((Join-Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path $VolumeSignatureCatalogPath))
        }

        if (-Not [System.IO.Path]::IsPathRooted($ShieldingDataFilePath)) {
            $ShieldingDataFilePath = [System.IO.Path]::GetFullPath((Join-Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path $ShieldingDataFilePath))
        }

        # Load the files 
        try {
            $vsc = Invoke-CimMethod -ClassName Msps_ProvisioningFileProcessor -Namespace root/msps -MethodName PopulateFromFile -Arguments @{FilePath=$VolumeSignatureCatalogPath}
            if (-Not $vsc.ProvisioningFile) {throw}
        } catch {
            Write-Error ($strings.FileLoadError -f $VolumeSignatureCatalogPath)
        }

        try {
            $pdk = Invoke-CimMethod -ClassName Msps_ProvisioningFileProcessor -Namespace root/msps -MethodName PopulateFromFile -Arguments @{FilePath=$ShieldingDataFilePath}
            if (-Not $pdk.ProvisioningFile) {throw}
        } catch {
            Write-Error ($strings.FileLoadError -f $ShieldingDataFilePath)
        }

        # Check validity
        $result = Invoke-CimMethod -ClassName Msps_ProvisioningFileProcessor -Namespace root/msps -MethodName PdkVscApplicabilityCheck `
            -Arguments @{Vsc=$vsc.ProvisioningFile;Pdk=$pdk.ProvisioningFile}
        return $result.Applicable
    }
}

function Initialize-ShieldedVM {
    <#
        .NOTES
            Copyright (C) Microsoft Corporation. All rights reserved.

        .SYNOPSIS
            This cmdlet provisions a Shielded Virtual Machine

        .DESCRIPTION
            This cmdlet initializes a Shielded Virtual Machine. The virtual
            machine disk must have been prepared using the Template Disk Wizard, 
            and the Shielding Data File must be valid when applied to the template. 
            The virtual machine must contain a vTPM and be in a stopped state. 

        .PARAMETER ShieldingDataFilePath
            The location of a Shielding Data File (.pdk)

        .PARAMETER ShieldedVMSpecializationDataFilePath
            The location of a Specialization Data File (.fsk) used to specialize the Shielded VM

        .PARAMETER VM
            The virtual machine to be provisioned
            
        .PARAMETER VMName
            The name of the virtual machine to be provisioned

        .EXAMPLE
            Initialize-ShieldedVM -ShieldingDataFilePath c:\users\robert\myfile.pdk -ShieldedVMSpecializationDataFilePath c:\users\robert\fabric.fsk -VirtualMachine $vm

        .EXAMPLE
            Initialize-ShieldedVM .\myfile.pdk c:\users\robert\fabric.fsk -VMName 'MyVM'
    #>
    [CmdletBinding()]
    [OutputType([CimInstance])]
    param(
        [Parameter(Mandatory=$true,
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$ShieldingDataFilePath,

        [Parameter(Mandatory=$false,
            Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$ShieldedVMSpecializationDataFilePath,

        [Parameter(Mandatory=$true,
            Position=2,
            ParameterSetName='ByVM')]
        [ValidateNotNull()]
        [Microsoft.HyperV.PowerShell.VirtualMachine, Microsoft.HyperV.PowerShell.Objects, Version=10.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]$VM,
        
        [Parameter(Mandatory=$true,
            Position=2,
            ParameterSetName='ByName')]
        [ValidateNotNullOrEmpty()]
        [string]$VMName
    )

    # TODO: change GUID to UUID so it can work in space

    Process {
        trap {
            if ($_.Exception.GetType() -in $ExceptionsToTrap) {
                Write-Error $_.Exception
            } else {
                Write-Error -Message $strings.UnexpectedError -Exception $_.Exception
            }
        }
        
        # Get VM object if name was provided
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $VM = Get-VM -Name $VMName
            if (-Not $VM) {
                Write-Error ($strings.VirtualMachineDoesNotExist -f $VMName)
            }
        }

        # Validate files exist
        if (-Not (Test-Path $ShieldingDataFilePath) ) {
            Write-Error ($strings.FileDoesNotExistError -f $ShieldingDataFilePath)
        }

        if ($ShieldedVMSpecializationDataFilePath -And (-Not (Test-Path $ShieldedVMSpecializationDataFilePath)) ) {
            Write-Error ($strings.FileDoesNotExistError -f $ShieldedVMSpecializationDataFilePath)
        }

        # Resolve to absolute path

        if (-Not [System.IO.Path]::IsPathRooted($ShieldingDataFilePath)) {
            $ShieldingDataFilePath = [System.IO.Path]::GetFullPath((Join-Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path $ShieldingDataFilePath))
        }

        if ($ShieldedVMSpecializationDataFilePath -And (-Not [System.IO.Path]::IsPathRooted($ShieldedVMSpecializationDataFilePath))) {
            $ShieldedVMSpecializationDataFilePath = [System.IO.Path]::GetFullPath((Join-Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path $ShieldedVMSpecializationDataFilePath))
        }
        
        # Build CIM arguments
        $Arguments = @{PDKPath=$ShieldingDataFilePath;MachineID=$VM.VMId.Guid}
        
        if($ShieldedVMSpecializationDataFilePath) {
            $Arguments += @{FSKPath=$ShieldedVMSpecializationDataFilePath}
        }
        

        # Start the provisioning service
        $provisioningJob = Invoke-CimMethod -ClassName Msps_ProvisioningService -Namespace root/msps -MethodName ProvisionMachine `
            -Arguments $Arguments

        Start-VM -VM $VM
        return $provisioningJob
    }
}

function Get-ShieldedVMProvisioningStatus {
    <#
        .NOTES
            Copyright (C) Microsoft Corporation. All rights reserved.

        .SYNOPSIS
            This cmdlet queries the provisioning status of a shielded VM

        .DESCRIPTION
            This cmdlet

        .PARAMETER VMName
            The name of the virtual machine being provisioned

        .PARAMETER VM
            The virtual machine being provisioned

        .PARAMETER ProvisioningJob
            A CimInstance returned from either Initialize-ShieldedVM or a prior call to Get-ShieldedVMProvisioningStatus

        .EXAMPLE
            Get-ShieldedVMProvisioningStatus -VMName SuperSecure

        .EXAMPLE
            Get-ShieldedVMProvisioningStatus -VM $myShieldedVM

        .EXAMPLE
            Get-ShieldedVMProvisioningStatus -ProvisioningJob $provJob

    #>
    [CmdletBinding(
        DefaultParameterSetName='ByName'
    )]
    [OutputType([CimInstance])]
    param(
        [Parameter(Mandatory=$true,
            Position=0,
            ParameterSetName='ByName')]
        [ValidateNotNullOrEmpty()]
        [string]$VMName,

        [Parameter(Mandatory=$true,
            Position=0,
            ParameterSetName='ByVM')]
        [ValidateNotNull()]
        [Microsoft.HyperV.PowerShell.VirtualMachine, Microsoft.HyperV.PowerShell.Objects, Version=10.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]$VM,

        [Parameter(Mandatory=$true,
            ParameterSetName='ByInstance')]
        [ValidateNotNull()]
        [CimInstance]$ProvisioningJob
    )

    Process {
        trap {
            if ($_.Exception.GetType() -in $ExceptionsToTrap) {
                Write-Error $_.Exception
            } else {
                Write-Error -Message $strings.UnexpectedError -Exception $_.Exception
            }
        }

        $guids = @()

        # Get VM Guid(s)
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            $VMtemp = Get-VM -Name $VMName
            if (-Not $VMtemp) {
                Write-Error ($strings.VirtualMachineDoesNotExist -f $VMName)
            }

            $guids = $VMtemp.Id.Guid
        } elseif ($PSCmdlet.ParameterSetName -eq 'ByVM') {
            $guids = $VM.Id.Guid
        } else {
            # Ensure the CimInstance is of correct type
            if (-Not $ProvisioningJob.CimClass.CimClassName -eq 'Msps_ProvisioningJob') {
                Write-Error $strings.CimTypeError
            }

            $guids = $ProvisioningJob.InstanceID
        }

        # Get all provisioning jobs that match guids
        $localJobs = Get-CimInstance -ClassName Msps_ProvisioningJob -NameSpace root/msps | Where-Object { $guids -contains $_.InstanceID }

        if (-Not $localJobs) {
            Write-Error $strings.ProvisioningJobNotFound
        }

        # May return several provisioning jobs
        return $localJobs
    }
}

function Get-KeyProtectorFromShieldingDataFile {
    <#
        .NOTES
            Copyright (C) Microsoft Corporation. All rights reserved.

        .SYNOPSIS
            This cmdlet extracts the Key Protector from a Shielding Data File.

        .DESCRIPTION
            This cmdlet extracts the Key Protector from a Shielding Data File.

        .PARAMETER ShieldingDataFilePath
            The location of a Shielding Data File (.pdk)

        .EXAMPLE
            Get-KeyProtectorFromShieldingDataFile -ShieldingDataFilePath '.\ShieldingData.pdk'

    #>
    [CmdletBinding()]
    [OutputType([byte[]])]
    param(
        [Parameter(Mandatory=$true,
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$ShieldingDataFilePath
    )

    Process {
        trap {
            if ($_.Exception.GetType() -in $ExceptionsToTrap) {
                Write-Error $_.Exception
            } else {
                Write-Error -Message $strings.UnexpectedError -Exception $_.Exception
            }
        }
        
        # Check path validity
        if (-Not (Test-Path $ShieldingDataFilePath -IsValid) ) {
            Write-Error ($strings.PathValidError -f $ShieldingDataFilePath)
        }

        # Check path extension
        if ([string]::IsNullOrEmpty([System.IO.Path]::GetExtension($ShieldingDataFilePath))) {
            $ShieldingDataFilePath += '.pdk'
        } elseif (-Not ([System.IO.Path]::GetExtension($ShieldingDataFilePath) -eq '.pdk')) {
            Write-Error $strings.PDKFileExtensionError
        }

        # Resolve to absolute path for CIM
        if (-Not [System.IO.Path]::IsPathRooted($ShieldingDataFilePath)) {
            $ShieldingDataFilePath = [System.IO.Path]::GetFullPath((Join-Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation.Path $ShieldingDataFilePath))
        }

        # Get the PDK and extract the KP
        $pdk = Invoke-CimMethod -ClassName Msps_ProvisioningFileProcessor -Namespace root\msps -MethodName PopulateFromFile -Arguments @{ FilePath = $ShieldingDataFilePath }
        $provisioningFile = $pdk.ProvisioningFile
        
        # Ensure the correct type of file was parsed
        if ($provisioningFile.CimClass.CimClassName -ne 'Msps_PDK') {
            Write-Error ($strings.CimTypeErrorPDK)
        }
                
        return $provisioningFile.KeyProtector
    }
}
