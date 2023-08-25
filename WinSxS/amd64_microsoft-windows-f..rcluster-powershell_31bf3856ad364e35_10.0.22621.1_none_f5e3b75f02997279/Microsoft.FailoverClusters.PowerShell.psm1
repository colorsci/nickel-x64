Set-Alias Add-VMToCluster -Value Add-ClusterVirtualMachineRole
Export-ModuleMember -Alias Add-VMToCluster 

Set-Alias Remove-VMFromCluster -Value Remove-ClusterGroup
Export-ModuleMember -Alias Remove-VMFromCluster

Add-Type -TypeDefinition @"
    public enum MSCluster_GroupSet_StartupSettingType
    {
       Delay = 1,
       Online = 2
    }
"@

Add-Type -TypeDefinition @"
    public enum MSCluster_FaultDomain_FaultDomainType
    {
       Unknown = 0,
       Site = 1000,
       Rack = 2000,
       Chassis = 3000,
       Node = 4000,
       StorageNode = 5000
    }
"@

Add-Type -TypeDefinition @"
    public enum MSCluster_AffinityRule_RuleType
    {
       SameFaultDomain = 1,
       SameNode = 2,
       DifferentFaultDomain = 3,
       DifferentNode = 4 
    }
"@

function Get-ClusterDiagnosticInfo
{  
    [CmdletBinding()]  
  
    Param(  
  
    [parameter(ParameterSetName="Write", Position=0, Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $WriteToPath = $($env:userprofile + "\HealthTest\"),

    [parameter(ParameterSetName="Write", Position=1, Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $Cluster = ".",

    [parameter(ParameterSetName="Write", Position=2, Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $ZipPrefix = $($env:userprofile + "\HealthTest"),

    [parameter(ParameterSetName="Write", Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [int] $HoursOfEvents = 24,

    [parameter(ParameterSetName="Write", Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch] $IncludeEvents = $true,

 #   [parameter(ParameterSetName="Write", Position=1, Mandatory=$false)]
    #[ValidateNotNullOrEmpty()]
    #[string] $WriteToPath = $($env:userprofile + "\HealthTest\"),

    [parameter(ParameterSetName="Read", Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $ReadFromPath = ""
  
    )  
  
    Begin {}  
  
    Process  
    {  
      
$ClusterName = $Cluster
$isDebug = $PSBoundParameters['Debug']

#
# Set strict mode to check typos on variable and property names
#

Set-StrictMode -Version Latest

#
# Shows error, cancels script
#

Function ShowError { 
Param ([string] $Message)
    $Message = $Message + " - cmdlet was cancelled"
    Write-Error $Message -ErrorAction Stop
}

#
# Shows warning, script continues
#

Function ShowWarning { 
    Param ([string] $Message) 
    Write-Warning $Message 
}
 

#
# Veriyfing basic prerequisites on script node.
#

$OS = Get-WmiObject Win32_OperatingSystem
[int]$buildnum = $OS.BuildNumber
If ($buildnum -lt 9600) { 
    ShowError("Wrong OS Version - Need at least Windows Server 2012 R2 or Windows 8.1. You are running '" + $OS.Name + "'") 
}
 
If (-not (Get-Command -Module FailoverClusters)) { 
    ShowError("Cluster PowerShell not available. Download the Windows Server 2012 R2 RSAT.") 
}


#
# Veriyfing path
#

If ($ReadFromPath -ne "") {
    $Path = $ReadFromPath
    $Read = $true
} else {
    $Path = $WriteToPath
    $Read = $false
}

$PathOK = Test-Path $Path -ErrorAction SilentlyContinue
If ($Read -and -not $PathOK) { ShowError ("Path not found: $Path") }
If (-not $Read) {
    rm -ErrorAction SilentlyContinue -Recurse $Path | Out-Null
    md -ErrorAction SilentlyContinue $Path | Out-Null
} 
$PathObject = Get-Item $Path
If ($PathObject -eq $null) { ShowError ("Invalid Path: $Path") }
$Path = $PathObject.FullName

If ($Path.ToUpper().EndsWith(".ZIP")) {
    [Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
    $ExtractToPath = $Path.Substring(0, $Path.Length - 4)

    Try { [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $ExtractToPath) }
    Catch { ShowError("Can't extract results as Zip file from '$Path' to '$ExtractToPath'") }

    $Path = $ExtractToPath
}

If (-not $Path.EndsWith("\")) { $Path = $Path + "\" }

If ($Read) { 
    "Reading from path : $Path"
} else { 
    "Writing to path : $Path"
}

#
# Script Version
#

$ScriptVersion = 0.1
"Script Version : " + $ScriptVersion
If ($Read) {
    Try { $SavedVersion = Import-Clixml ($Path + "GetVersion.XML") }
    Catch { $SavedVersion = 1.1 }

    If ($SavedVersion -ne $ScriptVersion) 
    {ShowError("Files are from script version $SavedVersion, but the script is version $ScriptVersion")};
} else {
    $ScriptVersion | Export-Clixml ($Path + "GetVersion.XML")
}
  

If ($Read) {
    $Parameters = Import-Clixml ($Path + "GetParameters.XML")
    $clusterName = $Parameters.clusterName    
    $TodayDate =  $Parameters.TodayDate

} else {
    $Parameters = "" | Select TodayDate, clusterName
    $TodayDate = Get-Date
    $Parameters.TodayDate = $TodayDate
    $Parameters.clusterName = $clusterName
    $Parameters | Export-Clixml ($Path + "GetParameters.XML")
}


Function MakeObject($properties)
{
      Foreach ($map in $input) {
	$toPrint = @{}
	foreach($property in $properties)
	{
		$toPrint[$property ] = $map[$property]
	}
	New-Object PSObject -Property $toPrint
      }
}

Function Print($properties)
{
	$input | MakeObject $properties | ft $properties -AutoSize
}

#
# Count number of elements in an array, including checks for $null or single object
#

Function NCount { 
    Param ([object] $Item) 
    If ($Item -eq $Null) {
        $Result = 0
    } else {
        If ($Item.GetType().BaseType.Name -eq "Array") {
            $Result = ($Item).Count
        } Else { 
            $Result = 1
        }
    }
    Return $Result
}


function survey
{
	param(
		[Parameter(Mandatory=$True,
		ValueFromPipeline=$True)]
		$values
	)
	BEGIN 
    { 
        $count = 0
    }
	PROCESS 
    {
        foreach($value in $values)
        {
            $count += 1
        }
    }
	END 
    {
        $count 
    }
}


Function GenerateEventLogs()
{
    #
    # Phase 6
    #

    "<<< Phase 6 - Recent Error events >>>`n"
    $ClusterNodes = $nodes

    If ((-not $Read) -and (-not $IncludeEvents)) {
       "Events were excluded by a parameter`n"
    }

    If ((-not $Read) -and $IncludeEvents) {

        "Starting Export of Cluster Logs..." 

        # Cluster log collection will take some time. 
        # Using Start-Job to run them in the background, while we collect events and other diagnostic information

        $ClusterLogJob = Start-Job -ArgumentList $ClusterName,$Path { 
            param($c,$p) Get-ClusterLog -Cluster $c -Destination $p 
        }

        "Exporting Event Logs..." 

        $AllErrors = @();

        $Hours = $HoursOfEvents 
        $GeneratedLogs = @()
        $currentNode = $env:computername
        foreach( $Node in $($ClusterNodes | ? State -like "Up")) {
            $Node = $Node.name

            # Calculate number of milliseconds and prepare the WEvtUtil parameter to filter based on date/time
            $MSecs = $Hours * 60 * 60 * 1000
            $QParameter = "*[System[(Level=2) and TimeCreated[timediff(@SystemTime) <= "+$MSecs+"]]]"

            $tmpPath = Invoke-Command -ComputerName $node { [System.IO.Path]::GetTempPath() }
            $RPath = "\\"+$node+"\"+$tmpPath.Substring(0,1)+"$\"+$tmpPath.Substring(3,$tmpPath.Length-3)

            $LogPatterns = 'Storage','SMB','Failover','VHDMP','Hyper-V' | % { "Microsoft-Windows-$_*" }
            $LogPatterns += 'System','Application'

            $Logs = Get-WinEvent -ListLog $LogPatterns -ComputerName $Node | ? LogName -NotLike "*Diag*" 
            $Logs | % {

                $FileSuffix = $Node+"_Event_"+$_.LogName.Replace("/","-")+".EVTX"
                $NodeFile = $tmpPath+$FileSuffix
                $smbFile = $RPath+$FileSuffix

                # Export filtered log file using the WEvtUtil command-line tool
                # This includes filtering the events to errors (Level=2) that happened in recent hours.
                WEvtUtil.exe epl $_.LogName $NodeFile /r:$Node /q:$QParameter

                $GeneratedLogs += , $smbFile
            }
        }
        $Logs = $GeneratedLogs

        "Copying Event Logs...."

        $Logs |% {
            # Copy event log files and remove them from the source
            Copy-Item $_ $Path -Force -ErrorAction SilentlyContinue
            Remove-Item $_ -Force -ErrorAction SilentlyContinue
        }

        "Processing Event Logs..." 

        $Files = Dir ($Path+"\*.EVTX") | Sort Name

        If ($Files) {

            $Total1 = $Files.Count
            $E = "" | Select MachineName, LogName, EventID, Count
            $ErrorFound = $false
            $Count1 = 0

            $Files | % {
                Write-Progress -Activity "Processing Event Logs - Reading in" -PercentComplete ($Count1 / $Total1 * 100)
                $Count1++

                $ErrorEvents = Get-WinEvent -Path $_ -ErrorAction SilentlyContinue | 
                Sort MachineName, LogName, Id | Group MachineName, LogName, Id 

                If ($ErrorEvents) {
                     $ErrorEvents | % { $AllErrors += $_ }
                     $ErrorFound = $true 
                }
            } 

            Write-Progress -Activity "Processing Event Logs - Reading in" -Completed
        }


        #
        # Find the node name prefix, so we can trim the node name if possible
        #

        $NodeCount = $ClusterNodes.Count
        $NodeSame =$ClusterNodes[0].Name.length -1
        If ($NodeCount -gt 1) { 
    
            # Find the length of the shortest node name
            $NodeShort = $ClusterNodes[0].Name.Length
            1..($NodeCount-1) | % {
                If ($NodeShort -gt $ClusterNodes[$_].Name.Length) {
                    $NodeShort = $ClusterNodes[$_].Name.Length
                }
            }

            # Find the first character that's different in a node name (end of prefix)
            $Current = 0
            $Done = $false
            While (-not $Done) {

                1..($NodeCount-1) | % {
                    If ($ClusterNodes[0].Name[$Current] -ne $ClusterNodes[$_].Name[$Current]) {
                        $Done = $true
                    }
                }
                $Current++
                If ($Current -eq $NodeShort) {
                    $Done = $true
                }
            }
            # The last character was the end of the prefix
            $NodeSame = $Current-1
        } 


        #
        # Trim the node name by removing the node name prefix
        #
        Function TrimNode {
            Param ([String] $Node) 
            $Result = $Node.Split(".")[0].Trim().TrimEnd()
            If ($NodeSame -gt 0) { $Result = $Result.Substring($NodeSame, $Result.Length-$NodeSame) }
            Return $Result
        }

        # 
        # Trim the log name by removing some common log name prefixes
        #
        Function TrimLogName {
            Param ([String] $LogName) 
            $Result = $LogName.Split(",")[1].Trim().TrimEnd()
            $Result = $Result.Replace("Microsoft-Windows-","")
            $Result = $Result.Replace("Hyper-V-Shared-VHDX","Shared-VHDX")
            $Result = $Result.Replace("Hyper-V-High-Availability","Hyper-V-HA")
            $Result = $Result.Replace("FailoverClustering","Clustering")
            Return $Result
        }

        #
        # Convert the grouped table into a table with the fields we need
        #
        $Errors = $AllErrors | Select @{Expression={TrimLogName($_.Name)};Label="LogName"},
        @{Expression={[int] $_.Name.Split(",")[2].Trim().TrimEnd()};Label="EventId"},
        @{Expression={TrimNode($_.Name)};Label="Node"}, Count, 
        @{Expression={$_.Group[0].Message};Label="Message"} | 
        Sort LogName, EventId, Node

        #
        # Prepare to summarize events by LogName/EventId
        #

        If ($Errors) {

            $Last = $Errors.Count -1
            $LogName = ""
            $EventID = 0

            $ErrorSummary = 0 .. $Last | % {

                #
                # Top of row, initialize the totals
                #

                If (($LogName -ne $Errors[$_].LogName) -or ($EventId -ne $Errors[$_].EventId)) {
                    Write-Progress -Activity "Processing Event Logs - Summary" -PercentComplete ($_ / ($Last+1) * 100)
                    $LogName = $Errors[$_].LogName
                    $EventId = $Errors[$_].EventId
                    $Message = $Errors[$_].Message

                    # Zero out the node hash table
                    $NodeData = @{}
                    $ClusterNodes | % { 
                        $Node = TrimNode($_.Name)
                        $NodeData.Add( $Node, 0) 
                    }
                }

                # Add the error count to the node hash table
                $Node = $Errors[$_].Node
                $NodeData[$Node] += $Errors[$_].Count

                #
                # Is it the end of row?
                #
                If ($_ -eq $Last) { 
                    $EndofRow = $true 
                } else { 
                    If (($LogName -ne $Errors[$_+1].LogName) -or ($EventId -ne $Errors[$_+1].EventId)) { 
                        $EndofRow = $true 
                    } else { 
                        $EndofRow = $false 
                    }
                }

                # 
                # End of row, generate the row with the totals per Logname, EventId
                #
                If ($EndofRow) {
                    $ErrorRow = "" | Select LogName, EventId
                    $ErrorRow.LogName = $LogName
                    $ErrorRow.EventId = "<" + $EventId + ">"
                    $TotalErrors = 0
                    $ClusterNodes | Sort Name | % { 
                        $Node = TrimNode($_.Name)
                        $NNode = "N"+$Node
                        $ErrorRow | Add-Member -NotePropertyName $NNode -NotePropertyValue $NodeData[$Node]
                        $TotalErrors += $NodeData[$Node]
                    }
                    $ErrorRow | Add-Member -NotePropertyName "Total" -NotePropertyValue $TotalErrors
                    $ErrorRow | Add-Member -NotePropertyName "Message" -NotePropertyValue $Message
                    $ErrorRow
                }
            }
        } else {
            $ErrorSummary = @()
        }

        $ErrorSummary | Export-Clixml ($Path + "GetAllErrors.XML")
        Write-Progress -Activity "Processing Event Logs - Summary" -Completed

        "Gathering System Info and Minidump files ..." 

        $Count1 = 0
        $Total1 = NCount($ClusterNodes | ? State -like "Up")
    
        If ($Total1 -gt 0) {
    
            $ClusterNodes | ? State -like "Up" | % {

                $Progress = ( $Count1 / $Total1 ) * 100
                Write-Progress -Activity "Gathering System Info and Minidump files" -PercentComplete $Progress
                
                $Node = $_.Name

                # Gather SYSTEMINFO.EXE output for a given node

                $LocalFile = $Path+$Node+"_SystemInfo.TXT"
                SystemInfo.exe /S $Node >$LocalFile

                # Gather Network Adapter information for a given node

                $LocalFile = $Path+"GetNetAdapter_"+$Node+".TXT"
                Try { Get-NetAdapter -CimSession $Node >$LocalFile }
                Catch { ShowWarning("Unable to get a list of network adapters for node $Node") }

                # Gather SMB Network information for a given node

                $LocalFile = $Path+"GetSmbServerNetworkInterface_"+$Node+".TXT"
                Try { Get-SmbServerNetworkInterface -CimSession $Node >$LocalFile } 
                Catch { ShowWarning("Unable to get a list of SMB network interfaces for node $Node") }

                # Enumerate minidump files for a given node

                Try { $NodePath = Invoke-Command -ComputerName $Node { Get-Content Env:\SystemRoot }
                      $RPath = "\\"+$Node+"\"+$NodePath.Substring(0,1)+"$\"+$NodePath.Substring(3,$NodePath.Length-3)+"\Minidump\*.dmp"
                      $DmpFiles = Dir $RPath -Recurse -ErrorAction SilentlyContinue } 
                Catch { $DmpFiles = ""; ShowWarning("Unable to get minidump files for node $Node") }

                # Copy minidump files from the node

                $DmpFiles | % {
                    $LocalFile = $Path + $Node + "_" + $_.Name 
                    Try { Copy-Item $_.FullName $LocalFile } 
                    Catch { ShowWarning("Could not copy minidump file $_.FullName") }
                }        

                $Count1++
            }
        }

        Write-Progress -Activity "Gathering System Info and Minidump files" -Completed

        "Receiving Cluster Logs..."
        $ClusterLogJob | Wait-Job | Receive-Job
        $ClusterLogJob | Remove-Job
    
        "All Logs Received`n"
    }

    If ($Read) { 
        Try { $ErrorSummary = Import-Clixml ($Path + "GetAllErrors.XML") }
        Catch { $ErrorSummary = @() }
    }

    If ($Read -or $IncludeEvents) {
        If (-not $ErrorSummary) {
            "No errors found`n" 
        } Else { 

            #
            # Output the final error summary
            #
            "Summary of Error Events (in the last $HoursOfEvents hours) by LogName and EventId"
            $ErrorSummary | Sort Total -Descending | Select * -ExcludeProperty Group, Values | FT  -AutoSize
        }
    }









    [System.GC]::Collect()

    If (-not $read) {

        "<<< Phase 7 - Compacting files for transport >>>`n"

        $ZipSuffix = '-{0}{1:00}{2:00}-{3:00}{4:00}' -f $TodayDate.Year,$TodayDate.Month,$TodayDate.Day,$TodayDate.Hour,$TodayDate.Minute
        $ZipSuffix = "-" + $Cluster.Name + $ZipSuffix
        $ZipPath = $ZipPrefix+$ZipSuffix+".ZIP"

        Try {
            "Creating zip file with objects, logs and events."

            [Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
            $ZipLevel = [System.IO.Compression.CompressionLevel]::Optimal
            [System.IO.Compression.ZipFile]::CreateFromDirectory($Path, $ZipPath, $ZipLevel, $false)

            "Cleaning up temporary directory $Path"
            rm -ErrorAction SilentlyContinue -Recurse $Path
            "Zip File Name : $ZipPath `n" 
        } Catch {
            ShowError("Error creating the ZIP file!`nContent remains available at $Path") 
        }
    }

}


"Date of capture : " + $TodayDate


#
# Phase 1
#

"`n<<< Phase 1 - Cluster Overview >>>`n"



































#if we do not have permissions for every node in the cluster we will
# only do local cluster nodes
$canWeDoWinRM = $false




"`nGetting Info for cluster $clusterName"

If ($Read) { 
$cluster = Import-Clixml ($Path + "GetCluster.XML")
$nodes = Import-Clixml ($Path + "GetClusterNode.XML")
$groups = Import-Clixml ($Path + "GetClusterGroup.XML")
$resources = Import-Clixml ($Path + "GetClusterResource.XML")

$vm_groups = $groups | ?{$_.grouptype -eq "virtualmachine"}

$vms = Import-Clixml ($Path + "GetClusterVm.XML")






} else { 
if($isDebug)
{
    "writting"
}
[Microsoft.FailoverClusters.PowerShell.Cluster]$cluster = get-cluster $clusterName
$nodes = @($cluster | get-clusternode)
#we are going to determine if we can only do local vm nodes



$groups = $cluster | get-clustergroup
$resources = $cluster | get-clusterresource
$vm_groups = $groups | ?{$_.grouptype -eq "virtualmachine"}

"`nGot Groups Resources"

$availableDisk = $cluster | Get-ClusterAvailableDisk
$checkpoint = $cluster | get-ClusterCheckPoint
$network = $cluster | Get-ClusterNetwork
$networkInterface = $cluster | Get-ClusterNetworkInterface
$quorum = $cluster | Get-ClusterQuorum
$resourceType = $cluster | Get-ClusterResourceType
$clusterSharedVolume = $cluster | Get-ClusterSharedVolume
$depenencies = $resources | %{$_ | Get-ClusterResourceDependency}


"`nGot remainder cluster objects & exporting groups resources"

$cluster | Export-Clixml ($Path + "GetCluster.XML") -depth 50
$nodes | Export-Clixml ($Path + "GetClusterNode.XML") -depth 50
$groups | Export-Clixml ($Path + "GetClusterGroup.XML") -depth 50
$resources | Export-Clixml ($Path + "GetClusterResource.XML") -depth 50


"`nExporting remaining objects"
$availableDisk | Export-Clixml ($Path + "GetClusterAvailableDisk.XML") -depth 50
$checkpoint | Export-Clixml ($Path + "GetClusterCheckPoint.XML") -depth 50
$network | Export-Clixml ($Path + "GetClusterNetwork.XML") -depth 50
$networkInterface | Export-Clixml ($Path + "GetClusterNetworkInterface.XML") -depth 50
$quorum | Export-Clixml ($Path + "GetClusterQuorum.XML") -depth 50
$resourceType | ?{$_.displayname -ne "(Resource Type Unavailable)"} | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterResourceTypeParameter.XML") -depth 50
$clusterSharedVolume | Export-Clixml ($Path + "GetClusterSharedVolume.XML") -depth 50
$depenencies | Export-Clixml ($Path + "ClusterResourceDependency}.XML") -depth 50

"`nGetting cluster properties"

$cluster | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterParameter.XML") -depth 50
$nodes | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterNodeParameter.XML") -depth 50
$groups | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterGroupParameter.XML") -depth 50
$resources | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterResourceParameter.XML") -depth 50
$network | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterNetworkParameter.XML") -depth 50
$networkInterface | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterNetworkInterfaceParameter.XML") -depth 50
$resourceType | ?{$_.displayname -ne "(Resource Type Unavailable)"} | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterResourceTypeParameter.XML") -depth 50
$clusterSharedVolume | Get-ClusterParameter | Export-Clixml ($Path + "GetClusterSharedVolumeParameter.XML") -depth 50


#determine if I should halt everything if no node for winrm works
$upNodes = @($nodes | ?{$_.state.ToString() -eq "Up"})
$upNodeNames = @($upNodes | %{$_.name})
$winRmNodes = @()
$winRmNodeNames = @()
foreach($node in $upNodes)
{
    $reply= Invoke-Command -ComputerName $node.name {dir \} -ErrorVariable errorVar -ErrorAction SilentlyContinue
    if($reply){$winrmNodes += , $node; $winRmNodeNames += , $node.name}
}
if($winRmNodes.length -eq 0)
{
    write-error "Cannot use winrm to connect to remote nodes. Fix WinRM"
    return 
}

if($winRmNodes.length -ne $upNodeNames.length)
{
    write-warning "Cannot use winrm to connect to all up Nodes"
    foreach($node in $upNodeNames)
    {
        if($node -notin $winRmNodeNames)
        {
            write-warning "Cannot use winrm to connect to node $node"
        }        
    }
    write-warning "Only gathering a subset of logs, run command on every node to get all data"
    $clusterNodes = $winRmNodes
    $nodes = $winRmNodes

    GenerateEventLogs
    return 0
}




"`nGetting VMs"

$vms = $vm_groups | get-vm
"`nExporting vms"

#50 seems to be too big for vms
$vms | Export-Clixml ($Path + "GetClusterVm.XML") -depth 3

if($isDebug)
{
    $path
}

}


$vm_state_counts = @{}
foreach($vm in $vms)
{
    $vmState = $vm.state.tostring()
    $vm_state_counts[$vmState] = $vm_state_counts[$vmState] + 1
}

$vm_state_count_list = @()
foreach($state in $vm_state_counts.keys)
{
    $vm_state_count_list += @{state = $state; count = $vm_state_counts[$state]}
}

"The states and counts of vms are "
$vm_state_count_list | print -properties  ("state","count")



"The database read write mode is $($cluster.databasereadwritemode)"

"The Cluster has $($nodes.count) nodes"

$not_up = $nodes | ?{$_.state.ToString() -ne "Up"}
"Number of nodes that are up $($nodes.count - ($not_up | survey))/$($nodes.count)"

if(($not_up | survey) -ne 0)
{
"Nodes that are not up"
$not_up | ft Name, id, state -AutoSize
}

$notOnlineResources = @()
foreach($resource in $resources)
{
    if($resource.persistentstate -eq 1)
    {
        if($resource.state.ToString() -ne "Online")
        {
            $notOnlineResources += $resource
        }
    }
}

if(($notOnlineResources | survey) -ne 0)
{
"Resources that should be online but aren't"
$notOnlineResources | ft Name, state -AutoSize
}

$notOnlineSharedVolumes = @()
foreach($sharedVolume in $clusterSharedVolume)
{
    if($sharedVolume.state.ToString() -ne "Online")
    {
        $notOnlineSharedVolumes += $sharedVolume
    }
}

if(($notOnlineSharedVolumes | survey) -ne 0)
{
"SharedVolumes that should be online but aren't"
$notOnlineSharedVolumes | ft Name, state -AutoSize
}



"The cluster contains $($vms | survey) vms"

function Round($number, $precision = 0)
{
    [math]::Round($number,$precision)
}

function FormatGBs($number)
{
    $gbs = $number/1gb
    #"{0:N2}" -f $gbs
    Round $gbs 2
}

# is smb share
# return volume object
function GetSmbShareRoot($path)
{
	$parentPath = $path
	do
	{
		$path = $parentPath
		$parentPath = Split-Path -Path $path -Parent
	}
	while($parentPath -ne "")
	$path
}

#should look something like \\431217D9C3SCFS.cfdev.nttest.microsoft.com\MayhewContent
function GetVolumeOfSmbRootPath($rootPath)
{
	$parts = $rootPath -split '\\'
	$computerName = $parts[$parts.count - 2]
	$shareName = $parts[$parts.count - 1]
#write stuff
	$volumeId = (get-smbshare -cimsession $computername $shareName).volume
	get-volume -cimsession $computerName -Uniqueid $volumeId
}

function GetVolumeOfSmbPath($path)
{
	$rootPath = GetSmbShareRoot $path
	GetVolumeOfSmbRootPath $rootPath
}

function TryToGetWorkingPath($currentPath,$remoteNameToTry = $ClusterName)
{
	if(Test-Path $currentPath -ErrorAction SilentlyContinue)
	{
		return $currentPath
	}
	else
	{
		#if this path looks like a local path, it could be due to CSV, lets smbify it
                if($currentPath.length -gt 0 -and $currentPath[1] -eq ':')
		{
			$testPath = "\\"+$remoteNameToTry+"\"+$currentPath.Substring(0,1)+"$\"+$currentPath.Substring(3,$currentPath.Length-3)
                        if(Test-Path $testPath -ErrorAction SilentlyContinue)
			{
				$currentPath = $testPath
			}
		}		
	}
	return $currentPath	
}

function GetHardDriveSize($hd)
{
        $hd = TryToGetWorkingPath $hd.path
        try
        {
		(dir ($hd)).length
	}
	catch
	{
		0
	}
}
function CanGetHardDriveSize($hd, $remoteNameToTry = $ClusterName)
{
        $hd = TryToGetWorkingPath $hd.path $remoteNameToTry
        try
        {
		$a = (dir ($hd)).length
        return $true
	}
	catch
	{
		return $false
	}
}

function GetSnapShotSize($vm)
{
	$size = 0
	$snapshots = $vm | get-vmsnapshot
	foreach($snapshot in $snapshots)
	{
		$size += $snapshot.SizeOfSystemFiles
		$hds = $snapshot.harddrives
		foreach($hd in $hds)
		{
			$size += GetHardDriveSize $hd
		}
	}
	$size
}

"`nExamining each vm"

#compute all volumes and see what free space they have
$volume_infos = @()
$volume_share_roots = @{}

#get info for each vm
$vm_infos = @();


If ($Read) { 
$volume_infos = Import-Clixml ($Path + "GetVolumeInfos.XML")
$volume_share_roots = Import-Clixml ($Path + "GetVolumeShareRoots.XML")
$vm_infos = Import-Clixml ($Path + "GetVmInfos.XML")
$inAccessibleHdClusterVms = Import-Clixml ($Path + "inAccessibleHdClusterVms.XML")






} else { 
$inAccessibleHdClusterVms = @{}
foreach($vm in $vms)
{

if($isDebug)
{
$vm.name
}
#$vm = $vms[0]
    write-progress "Examining each VM" -Status "VM $($vm_infos | survey) of $($vms | survey)" -PercentComplete (100.0 * ($vm_infos| survey)/ ($vms| survey))
	$vm_info = @{'vm' = $vm; 'vhds' = $vm.Harddrives;}
	$vm_info.snapShotSize = GetSnapShotSize $vm 
    $vm_info.snapshot_size_GBs = FormatGBs $vm_info.snapShotSize
	$vm_info.cluster_group = $vm | get-clustergroup -cluster $clusterName
	$vm_info.host = $vm_info.cluster_group.OwnerNode.name
	$total_size = $vm.SizeOfSystemFiles
	$total_size += $vm_info.snapShotSize
	$vm_info.paths = @($vm.SmartPagingFilePath, $vm.Path, $vm.ConfigurationLocation, $vm.SnapshotFileLocation)
    #$vhd_free_space = 0
    $vm_info.CanGetHardDriveSize = $true
	foreach($hd in $vm_info.vhds)
	{
		$vm_info.paths += $hd.path
        
        #calculate size
        $canGetHdSize = CanGetHardDriveSize $hd
        if(-not $canGetHdSize)
        {
            $inAccessibleHdClusterVms[$vm.Name] = $vm
            $vm_info.CanGetHardDriveSize = $false
        }
		$hd_size = GetHardDriveSize $hd
		$total_size += $hd_size

        #calculate size based on vhd
        #$vhd = get-vhd $hd.path -computername $vm_info.host
        #$total_size += $vhd.size
        #$vhd_free_space += ($vhd.size - $vhd.fileSize )
	}
    #$vm_info.vhd_free_space = $vhd_free_space
	$vm_info.total_size = $total_size
    $vm_info.total_size_GBs = FormatGBs $vm_info.total_size
	$vm_info.cpu = $vm.CPUusage
	$vm_info.memory = $vm.MemoryAssigned
    $vm_info.memory_GBs = FormatGBs $vm_info.memory
    try{
    $vm_info.uptime_days = $vm.uptime.TotalDays
    }
    catch{ $vm_info.uptime_days = 0}

	$vm_info.uptime_days = Round $vm_info.uptime_days 2

	#want to know those that are -ne "Operating normally"
	$vm_info.status = $vm.status
	$vm_info.state = $vm.state
	$vm_info.name = $vm.name

    #compute volume_info
    foreach($data_path in $vm_info.paths)
    {
        try{
        #sometimes the path is garbage
        if(-not $data_path)
        {
            continue
        }
        $volume_info = @{}
        $root = GetSmbShareRoot $data_path
        if($volume_share_roots.ContainsKey($root))
        {
            continue
        }
        $volume = GetVolumeOfSmbPath $data_path
        $volume_share_roots[$root] = $volume #we are using the map as a set

        $volume_info.volume = $volume
        $volume_info.free_space = $volume.SizeRemaining
        $volume_info.free_space_GBs = FormatGBs $volume_info.free_space
        $volume_info.size = $volume.size
        $volume_info.size_GBs = FormatGBs $volume_info.size
        $volume_info.percent_free_space = 100.0 * $volume_info.free_space  / $volume_info.size
        $volume_info.percent_free_space = Round $volume_info.percent_free_space 2
        $volume_info.share = $root
        $volume_info.path = $volume.path

        $volume_infos += $volume_info      
        }catch{}  
    }


	$vm_infos+=$vm_info

}


$volume_infos | Export-Clixml ($Path + "GetVolumeInfos.XML") -depth 50
$volume_share_roots | Export-Clixml ($Path + "GetVolumeShareRoots.XML") -depth 50
$vm_infos | Export-Clixml ($Path + "GetVmInfos.XML") -depth 50
$inAccessibleHdClusterVms| Export-Clixml ($Path + "inAccessibleHdClusterVms.XML") -depth 50

}


write-progress "Examining each VM" -Completed
#$vm_infos
#$vmh = $vm_infos | select -first 1
#$vmh.host


function average($numbers)
{
    $count = 0
    $sum = 0
    foreach($item in $numbers)
    {
        $count += 1
        $sum += $item
    }
    if($count -eq 0)
    {
        return 0
    }
    return $sum/$count
}

function AllSameSize
{
	param(
		[Parameter(Mandatory=$True,
		ValueFromPipeline=$True)]
		[int[]]$values
	)
	BEGIN 
    { 
        $allSame=$true
        $firstValueCaptured = $false
    }
	PROCESS 
    {
        foreach($value in $values)
        {
            if(-not $firstValueCaptured)
            {
                $firstValueCaptured = $true
                $firstValue = $value
            }
            else
            {
                $allSame = ($allSame -and ($firstValue -eq $value))
            }
        }
    }
	END 
    {
        $allSame 
    }
}



$countToDisplay = 5;

"Worst $countToDisplay in memory utilization"
$vm_infos | sort @{expression={$_.memory}; Ascending=$false} | select -first $countToDisplay | Print -properties "name","host","memory_GBs"

"Worst $countToDisplay in cpu utilization"
$vm_infos | sort @{expression={$_.cpu}; Ascending=$false} | select -first $countToDisplay | Print -properties "name","host","cpu"

"Worst $countToDisplay in uptime, that are not 0"
$vm_infos | ?{$_.uptime_days -ne 0}| sort @{expression={$_.uptime_days}; Ascending=$true} | select -first $countToDisplay | Print -properties "name","host","uptime_days"

"Worst $countToDisplay in snapshot size"
$vm_infos | sort @{expression={$_.snapshotsize}; Ascending=$false} | select -first $countToDisplay | Print -properties "name","host","snapshot_size_GBs"

"Worst $countToDisplay in total size"
$vm_infos | sort @{expression={$_.total_size}; Ascending=$false} | select -first $countToDisplay | Print -properties "name","host","total_size_GBs"





$node_infos = @()
$unclustered_vms = @()
$duplicate_vms = @{}
$inAccessibleHdNonClusterVms = @{}

If ($Read) { 
$node_infos = Import-Clixml ($Path + "GetNodeInfos.XML")
$unclustered_vms = Import-Clixml ($Path + "GetUnclusteredVms.XML")
$duplicate_vms = Import-Clixml ($Path + "GetDuplicateVms.XML")
$inAccessibleHdNonClusterVms = Import-Clixml ($Path + "inAccessibleHdNonClusterVms.XML")

} else { 

foreach($node in $nodes)
{
    write-progress "Examining each node" -Status "node $($node_infos| survey) of $($nodes| survey))" -PercentComplete (100.0 * ($node_infos| survey)/ ($nodes| survey))
    $name = $node.name
    $node_info = @{}
    if($node.state.ToString() -ne "Up")
    {
        continue
    }

    $vms_on_this_node = get-vm -computername $name
    foreach($vm in $vms_on_this_node)
    {
        if($duplicate_vms.ContainsKey($vm.id))
        {
            $duplicate_vms[$vm.id] += $vm
        }
        else
        {
            $duplicate_vms[$vm.id] = @($vm)
        }

        if(-not $vm.IsClustered)
        {
            $unclustered_vms += $vm
            try
            {
                foreach($hd in $vm.Harddrives)
	            {        
                    #calculate size
                    $canGetHdSize = CanGetHardDriveSize $hd $node.name
                    if(-not $canGetHdSize)
                    {
                        $inAccessibleHdNonClusterVms[$vm.Name] = $true
                    }
	            }
            }
            catch
            {
            }
        }
    }

    $node_info.name = $name
    $node_info.node = $node
    $node_info.state = $node.state

    #compute the average cpu utilization
    $node_info.cpu = average $(gwmi -ComputerName $name win32_processor | %{$_.LoadPercentage})
    $computer = gwmi -ComputerName $name win32_computersystem
    $os = gwmi -ComputerName $name win32_operatingsystem
    $node_info.total_memory = $computer.TotalPhysicalMemory
    $node_info.free_memory = $os.FreePhysicalMemory
    $node_info.percent_free_memory = 100.0 * $node_info.free_memory *1024 / $node_info.total_memory
    $node_info.percent_free_memory = Round $node_info.percent_free_memory 2

    $node_infos+= $node_info
}

$node_infos | Export-Clixml ($Path + "GetNodeInfos.XML") -depth 50
$unclustered_vms | Export-Clixml ($Path + "GetUnclusteredVms.XML") -depth 50
$duplicate_vms | Export-Clixml ($Path + "GetDuplicateVms.XML") -depth 50
$inAccessibleHdNonClusterVms | Export-Clixml ($Path + "inAccessibleHdNonClusterVms.XML") -depth 50


}

write-progress "Examining each node" -Completed



function printVms($vms, $tag = "clustered")
{
    $stateToName = @{}
    foreach($vm in $vms)
    {
	    $stateToName[$vm.state]+= @($vm.name)
    }
    "There are $($vms | survey) $tag Vms"
    foreach($state in $stateToName.Keys)
    {
	    "$($stateToName[$state] | survey) `t  $state"
    }

    $statesToIgnore = @("Running", "Off", "Saved", "Paused")
    $printedHeader = $false
    foreach($state in $stateToName.Keys)
    {
	    if($state -notin $statesToIgnore)
	    {
            if(-not $printedHeader)
            {
                $printedHeader = $true
                ""
                "$tag Vms that are not in $($statesToIgnore -join ", ") state"
            }
		    "The following Vms are in the state $state `n$($stateToName[$state] -join "`n")"		
	    }
    }
    ""
}
function printVmsWithStorageProblems($vms, $tag = "clustered")
{
    if($($vms | survey) -eq 0)
    {
        "Found no $tag vms that have inaccessible storage"
        return
    }
    "Found $tag vms that have inaccessible storage, this could be due to double hop issues if running this command in a remote powershell session"
    foreach($vm in $vms)
    {
        $vm
    }
}

printVms $vm_infos
printVmsWithStorageProblems $inAccessibleHdClusterVms.Values 

""

printVms $unclustered_vms "unclustered"
printVmsWithStorageProblems $inAccessibleHdNonClusterVms.Values "unclustered"


if(($unclustered_vms| survey) -ne 0)
{
    "There are $($unclustered_vms| survey) unclustered vms"
    $unclustered_vms | ft name, computername
}

$list_duplicate_vms = @()
foreach($vm_id in $duplicate_vms.Keys)
{
    if(($duplicate_vms[$vm_id]| survey) -ne 1)
    {
        foreach($vm in $duplicate_vms[$vm_id])
        {
            $list_duplicate_vms += $vm
        }
    }
}


if(($list_duplicate_vms| survey) -ne 0)
{
    "Printing duplicate vms"
    $list_duplicate_vms | ft name, computername
}

"Worst $countToDisplay in memory utilization"
$node_infos | sort @{expression={$_.percent_free_memory}; Ascending=$true} | select -first $countToDisplay | Print -properties "name","percent_free_memory"

"Worst $countToDisplay in cpu utilization"
$node_infos | sort @{expression={$_.cpu}; Ascending=$false} | select -first $countToDisplay | Print -properties "name","cpu" 


#should do a check to see which OS drives are close to max utilization



"Worst $countToDisplay in disk free space"
$volume_infos | sort @{expression={$_.percent_free_space}; Ascending=$true} | select -first $countToDisplay | Print -properties "share","percent_free_space","free_space_GBs", "size_GBs"



"`n looking at Network adapters for nodes without an RDMA nic`n"


$networksPerNode = @()

If ($Read) { 
$networksPerNode = Import-Clixml ($Path + "networksPerNode.XML")

} else { 
foreach($node in $nodes)
{
    if($node.state.ToString() -ne "up")
    {
        continue
    }

    $name = $node.name
    $thisNode = @{'name'=$name}
    $cim = New-CimSession -ComputerName $name
    
    $thisNode.adapter = @()
    foreach( $adapter in $(Get-NetAdapter -cimsession $cim))
    {        
        $thisNode.adapter += $adapter
    }

    
    $thisNode.rdmaAdapter = @()
    foreach( $rdmaAdapter in $(Get-NetAdapterRdma -cimsession $cim))
    {        
        $thisNode.rdmaAdapter += $rdmaAdapter
    }

    $thisNode.clusterNetworkInterface = @()
    foreach( $clusterNetworkInterface in $(get-clusternetworkinterface -cluster $cluster -node $name))
    {        
        $thisNode.clusterNetworkInterface += $clusterNetworkInterface
    }

    $networksPerNode += $thisNode
}
$networksPerNode | Export-Clixml ($Path + "networksPerNode.XML") -depth 50
}

$nodesWithZeroRdmaNics = $networksPerNode | ?{($_.rdmaAdapter| survey) -eq 0}
if($nodesWithZeroRdmaNics)
{
    "The following Nodes do not have RDMA networks"
    $nodesWithZeroRdmaNics | %{$_.name}
}

if(-not ($networksPerNode | %{$_.rdmaAdapter| survey} | AllSameSize))
{
    "Not every node contains the same number of RDMA networks"
    $networksPerNode | %{@{name = $_.name; rdmaNicCount=($_.rdmaAdapter| survey)}} | Print -properties "name","rdmaNicCount" 
}

$notUpInterfaces = $networksPerNode | %{$_.clusterNetworkInterface | ?{$_.state.ToString() -ne "Up"}}
if($notUpInterfaces)
{
    "There exist cluster interfaces that are not up"
    $notUpInterfaces | ft
}

if(-not ($networksPerNode | %{$_.clusterNetworkInterface| survey} | AllSameSize))
{
    "Not all nodes contain the same number of network interfaces"
    $networksPerNode | %{ @{name = $_.name; ClusterInterfaceCount = ($_.clusterNetworkInterface| survey)}  } | Print -properties "name","ClusterInterfaceCount" 
}


GenerateEventLogs






    }  
  
    End {}  
}  
Export-ModuleMember Get-ClusterDiagnosticInfo


Set-Alias Enable-ClusterS2D -Value Enable-ClusterStorageSpacesDirect
Export-ModuleMember -Alias Enable-ClusterS2D

Set-Alias Disable-ClusterS2D -Value Disable-ClusterStorageSpacesDirect
Export-ModuleMember -Alias Disable-ClusterS2D

Set-Alias Get-ClusterS2D -Value Get-ClusterStorageSpacesDirect
Export-ModuleMember -Alias Get-ClusterS2D

Set-Alias Repair-ClusterS2D -Value Repair-ClusterStorageSpacesDirect
Export-ModuleMember -Alias Repair-ClusterS2D

Set-Alias Set-ClusterS2D -Value Set-ClusterStorageSpacesDirect
Export-ModuleMember -Alias Set-ClusterS2D

# Export-ModuleMember -Alias Set-ClusterS2DDisk

function Set-ClusterStorageSpacesDirectDisk
{
            
    [CmdletBinding( DefaultParameterSetName = "ByPhysicalDiskGuid", SupportsShouldProcess = $true, ConfirmImpact="high")]
    Param
    (
        #### -------------------- Parameter sets -------------------------------------####

        [System.String[]]
        [Parameter(
            ParameterSetName  = 'ByPhysicalDiskGuid',
            ValueFromPipeline = $false,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $PhysicalDiskGuid,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        [PSTypeName("Microsoft.Management.Infrastructure.CimInstance#ROOT/Microsoft/Windows/Storage/MSFT_PhysicalDisk")]
        [Parameter(
            ParameterSetName  = 'ByPhysicalDisk',
            ValueFromPipeline = $true,
            Mandatory         = $true)]
        [ValidateNotNullOrEmpty()]
        $PhysicalDisk,

        #### ------------------------- Common method parameters ----------------------####

        [System.Boolean]
        [Parameter(
            ParameterSetName = 'ByPhysicalDiskGuid',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByPhysicalDisk',
            Mandatory        = $false)]
        $CanBeClaimed = $true,

        [Switch]
        [Parameter(
            ParameterSetName = 'ByPhysicalDiskGuid',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByPhysicalDisk',
            Mandatory        = $false)]
        $Reset = $false,

        [S2DDiskUsage]
        [Parameter(
            ParameterSetName = 'ByPhysicalDiskGuid',
            Mandatory        = $false)]
        [Parameter(
            ParameterSetName = 'ByPhysicalDisk',
            Mandatory        = $false)]
        $CacheUsage,

        #### -------------------- Powershell parameters ------------------------------####

        [Microsoft.Management.Infrastructure.CimSession]
        $CimSession,

        # Provided for compatibility with CDXML cmdlets, not actually used.
        [Int32]
        $ThrottleLimit,

        [Switch]
        $AsJob
    )

    Begin
    {
        [flagsattribute()]
        Enum S2DDiskUsage
        {
            NonHybrid = 0
            Capacity  = 1
            Cache     = 2
            Auto      = 3
        }

        $SourceCaller = "Microsoft.PowerShell"
        $PSBoundParameters.Confirm = $true  
    }

    Process
    {
        if (-not $CimSession)
        {
            $CimSession = New-CimSession
        }

        if (-not $AsJob)
        {
            Write-Progress -Activity "Set-ClusterStorageSpacesDirectDisk" -PercentComplete 0 -CurrentOperation "Gathering objects" -Status "0/2"
        }

        ## Populate arguments list

        $Arguments = @{}
 
        switch ($psCmdlet.ParameterSetName)
        {
            "ByPhysicalDisk" 
            { 
                [string[]]$ids = @()
                foreach ($disk in $PhysicalDisk) 
                {
                    $ids += $disk.ObjectId -Replace '.*:{' -Replace '}"'
                }
                $Arguments.Add("PhysicalDiskIds", $ids); 
                break; 
            }
            "ByPhysicalDiskGuid" 
            { 
                $Arguments.Add("PhysicalDiskIds", $PhysicalDiskGuid); 
                break; 
            }               
        }

        if ($PSBoundParameters.ContainsKey("CanBeClaimed"))
        {
            $Arguments.Add("CanBeClaimed", $CanBeClaimed)
        }
        if ($PSBoundParameters.ContainsKey("Reset"))
        {
            $Arguments.Add("Reset", $Reset.ToBool())
        }
        if ($PSBoundParameters.ContainsKey("CacheUsage"))
        {
            $Arguments.Add("CacheUsage", [System.UInt32]$CacheUsage)
        }                     

        ## Define Method block        
        $methodblock = {

            param($session, $asjob, $Arguments)

            # Start-Job serializes/deserializes the CimSession,
            # which means it shows up here as having type Deserialized.CimSession.
            # Must recreate or cast the object in order to pass it to Get-CimInstance.
            if ($asjob)
            {
                $session = $session | New-CimSession
            }

            $errorObject = $null

            if (-not $asjob)
            {
                Write-Progress -Activity "Set-ClusterStorageSpacesDirectDisk" -PercentComplete 30 -CurrentOperation "Executing method" -Status "1/2"
            }

            try
            {
                $progressPreference = "silentlyContinue"

                if ($psCmdlet.ShouldProcess("Set-ClusterStorageSpacesDirectDisk", $Arguments.PhysicalDiskIds))
                {
                    $output = Invoke-CimMethod -CimSession $session -Namespace "ROOT/MSCluster" -ClassName "MSCluster_StorageSpacesDirect" -MethodName SetStorageSpacesDirectDisk -Arguments $Arguments -ErrorAction Stop
                }
                
                $progressPreference = "Continue"
            }
            catch
            {
                $progressPreference = "Continue"

                $errorObject = New-Object System.Management.Automation.ErrorRecord @($_.Exception, $_.FullyQualifiedErrorId, $_.CategoryInfo.Category, $_.TargetObject)

                $psCmdlet.WriteError($errorObject)
            }

            if (-not $asjob)
            {
                Write-Progress -Activity "Set-ClusterStorageSpacesDirectDisk" -Completed -Status "2/2"
            }
        }

        if ($asjob)
        {
            Start-Job -Name SetClusterStorageSpacesDirectDisk -ScriptBlock $methodblock -ArgumentList @($CimSession, $true, $Arguments )
        }
        else
        {
            &$methodblock $CimSession $false $Arguments 
        }
    }
}

Set-Alias Set-ClusterS2DDisk -Value Set-ClusterStorageSpacesDirectDisk
Export-ModuleMember -Function Set-ClusterStorageSpacesDirectDisk -Alias Set-ClusterS2DDisk