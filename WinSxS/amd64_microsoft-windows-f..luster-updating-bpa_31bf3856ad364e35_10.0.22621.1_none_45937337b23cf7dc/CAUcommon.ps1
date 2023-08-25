#---------------------------------------#
# CauCommon.ps1                         #
# Library for CAU BPA                   #
# Copyright (c) Microsoft Corporation.  #
#---------------------------------------#


#
# Function Description:
#
#  This function will add the Server Manager module so that Roles
#  can be queried
#
# Arguments:
#
#  None
#
# Return Value:
#
#  None
#
function Setup
{
    Import-Module ServerManager
    import-module failoverclusters
    import-module clusterawareupdating
}

#
# Function Description:
#
#  This function will remove the Server Manager module after the Roles
#  have been queried
#
# Arguments:
#
#  None
#
# Return Value:
#
#  None
#
function TearDown
{
    Remove-Module ServerManager
    Remove-Module clusterawareupdating
    Remove-Module failoverclusters
}

#
# Function Description:
#  Creates the Document element for the Xml Document
#
# Arguments:
#  $ns - Namespace Name
#  $name - Name of the document element
#
# Return Value:
#  returns the created document element
#
function Create-DocumentElement( $ns, $name )
{
    [xml] "<$name xmlns='$ns'></$name>"
}

#
# Function Description:
#
#  This function will check to see if the specified feature is installed
#
# Arguments:
#
#  $featureName - Id of the Role 
#
# Return Value:
#
#  $true - If Role is Installed
#  $false - If Role is not Installed
#
function Check-FeatureInstallStatus ( $featureName )
{
    $featureInstalled = $false
    
    #
    # Use the Server Manager CmdLet to obtain detail about Feature
    #
    $Feature = Get-WindowsFeature $featureName
    if ( $Feature -ne $null ) 
    {
        $featureInstalled = $Feature.Installed
    }

    $featureInstalled
}

#
# Function Description:
#  Get Remote HKLM registry key
#
# Arguments:
#  $path - HKLM Path to the remote registry
#  $value - HKLM value that is expected
#
# Return Value:
#  $true - if HKLM registry exists
#  $false - if it is not in cluster
#*************************************************************************************************************
# TODO: For some reason this retruns an object even if key is not present we should somehow return $null then
function Get-RemoteHKLM($computerName,$path,$value)
{
    $result=$null
    try
    {
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computerName)
        $regKey= $reg.OpenSubKey($path)
        $result=$regkey.GetValue($value)
    }
    catch
    {
        $result=$null
    }
    $result
}

#
# Function Description:
#  Check whether the a machine is in cluster
#
# Arguments:
#  $clusterName - Name of the cluster
#  $computerName - Name of the computer
# Return Value:
#  $true - if it is in cluster
#  $false - if it is not in cluster
#
function Get-ServerInClusterStatus($clusterName,$computerName)
{
    $result = $false
    $nodes = get-clusternode -Cluster $clusterName
    foreach($node in $nodes)
    {
        if($node.Name -eq $computername)
        {
            $result = $true
             break
        }
    }
    $result
}

#
# Function Description:
#
#  check the status of specifed service
#  have been queried
#
# Arguments:
#
#  $computer - computer name
#  $serviceName - service name
#
# Return Value:
#
#  $true - if the service is running
#  $false - otherwise
#
function Check-ServiceStatus($computerName, $serviceName)
{
    $service = get-service -computername $computerName -name $serviceName
    if($service -ne $null -and ($service.Status -eq [System.ServiceProcess.ServiceControllerStatus]"Running"))
    {
        $true
    }
    else
    {
        $false
    }
}

#
# Function Description:
#  Create XmlElement and append it into the specified parent
#
# Arguments:
#  $doc - XmlDocument manipulated
#  $parent - parent node
#  $ns - namespace used for the element
#  $elementName - element name
#  $elementValue - element value
#
# Return Value:
#   none
#
function Append-XmlElement($doc, $parent, $ns, $elementName, $elementValue)
{
    $element = $doc.CreateElement($elementName, $ns)
    $element.set_InnerText($elementValue)
    [void]$parent.AppendChild($element)
}

#
# Function Description:
#  formalize the text of the boolean value
#
# Arguments:
#  $value - boolean value
#
# Return Value:
#  "true" - if $value -eq $true
#  "false" - if $value -eq $false
#
function Formalize-BoolValue($value)
{
    $valueString=([bool]$value).ToString()
    $valueString.ToLowerInvariant()
}

#
# Function Description:
#  Is host name resolvable
#
# Arguments:
#  $ComputerName - Name of Computer
#  
#
# Return Value:
#  $true - if name is resolvable
#  $false -if name is not resolvable
function IsHostNameResolvable([string] $ComputerName, [bool] $IPV6only, [bool] $IPV4only  )
{
    $HostName= $ComputerName
    $result=$false
    $HostIP = @(([net.dns]::GetHostEntry($HostName)).AddressList | foreach { 
                if ($IPV6only) 
                {
                    if ($_.AddressFamily -eq "InterNetworkV6") 
                    {
                        $_.IPAddressToString
                    }
                }
                if ($IPV4only)
                {
                    if ($_.AddressFamily -eq "InterNetwork") 
                    {
                        $_.IPAddressToString
                    }
                }
                if (!($IPV6only -or $IPV4only))
                {
                    $_.IPAddressToString
                }
            })

   if($HostIP -ne $null)
   {
        $result=$true
   }
   return $result
}

#
# Function Description:
#  Compile Csharp code
#
# Arguments:
#  $code - C# code
#  $Reference - reference assembley
#
# Return Value:
#  none
#
function Compile-Csharp ([string] $code, [string] $compilerOptions,[Array]$References)
{
    # Get an instance of the CSharp code provider
    $cp = New-Object Microsoft.CSharp.CSharpCodeProvider
    $refs = New-Object Collections.ArrayList
    $refs.AddRange( @("System.dll",
                    "System.Core.dll",
                    "System.Windows.Forms.dll",
                    "System.Runtime.Serialization.dll",
                    "System.Data.dll",
                    "System.XML.dll"))
    if ($References -and ($References.Count -ge 1))
    {
        $refs.AddRange($References)
    }

    # Build up a compiler params object...
    $cpar = New-Object System.CodeDom.Compiler.CompilerParameters
    $cpar.GenerateInMemory = $true
    $cpar.GenerateExecutable = $true
    $cpar.IncludeDebugInformation = $false
    $cpar.CompilerOptions = $compilerOptions
    $cpar.ReferencedAssemblies.AddRange($refs)
    $cr = $cp.CompileAssemblyFromSource($cpar, $code)

    if ( $cr.Errors.Count)
    {
        $errStr = "INVALID DATA: Errors encountered while compiling code \n"
        foreach ($ce in $cr.Errors)
        {
            $errStr+=$ce.ToString()+"\n"
        }
        Throw $errStr
    }
}

#
# Function Description:
#
# This function Initializes the named pipe for CAU and exposes WriteCauProgress and ClosCAUPipe functions
#
# Arguments:
#
#  None
#
# Return Value:
#
#  None
#
function call-GenCauPipeServer
{
    $code = @'
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Globalization;
    using System.IO;
    using System.IO.Pipes;
    using System.Runtime.Serialization;
    using System.Security.AccessControl;
    using System.Security.Principal;
    using System.Text;
    using System.Xml;

    namespace Microsoft.ClusterAwareUpdating
    {
        public enum RuleSeverity
        {
            Info = 0,
            Error,
            Warning,
        }

        public enum RuleState
        {
            Started = 0,
            Succeeded,
            Failed,
        }

        /// <summary>
        ///    Represents the progress reported by CAU BPA
        /// </summary>
        /// <remarks>
        ///    The object wraps the information about BPA rules and the current progress
        ///    percentage
        /// </remarks>
        [DataContract]
        public sealed class CauBpaProgress
        {
            [DataMember( IsRequired = true )]
            public int RuleId { get; private set; }

            [DataMember( IsRequired = true )]
            public string Title { get; private set; }

            [DataMember( IsRequired = true )]
            public RuleState State { get; private set; }

            [DataMember( IsRequired = true )]
            public RuleSeverity Severity { get; private set; }

            [DataMember(IsRequired = true)]
            public IList<string> FailedMachines { get; private set; }

            [DataMember( IsRequired = true )]
            public int PercentComplete { get; private set; }

            public CauBpaProgress( int ruleId,
                                   string title,
                                   RuleState state,
                                   RuleSeverity severity,
                                   IList<string> failedMachines,
                                   int percentComplete
                                 )
            {
                if( ruleId <= 0 )
                    throw new ArgumentException( "Invalid rule identifier.", "ruleId" );

                if( String.IsNullOrEmpty( title ) )
                    throw new ArgumentException( "Rule title cannot be empty.", "title" );

                if( null == failedMachines )
                    failedMachines = new List<string>();

                if( percentComplete < 0 || percentComplete > 100 )
                    throw new ArgumentException( "Invalid precent completion.", "percentComplete" );

                RuleId                   = ruleId;
                Title                    = title;
                State                    = state;
                Severity                 = severity ;
                FailedMachines           = new List<string>(failedMachines).AsReadOnly();
                PercentComplete          = percentComplete;
            } // end constructor
        }

        public class CAUPipeServer
        {
            NamedPipeServerStream pipeServer;
            UTF8Encoding encoding = new UTF8Encoding();

            public CAUPipeServer(string progressPipeName)
            {
                // Grant members of the built-in Administrators user group full control of the named pipe
                // used for progress; the client needs to set the ReadMode to PipeTransitionMode.Message.
                PipeAccessRule progressPipeAccessRule = new PipeAccessRule(
                    new SecurityIdentifier(WellKnownSidType.BuiltinAdministratorsSid, null),
                    PipeAccessRights.FullControl,
                    AccessControlType.Allow);
                PipeSecurity progressPipeSecurity = new PipeSecurity();
                progressPipeSecurity.AddAccessRule(progressPipeAccessRule);

                pipeServer = new NamedPipeServerStream(progressPipeName, PipeDirection.InOut, 1, PipeTransmissionMode.Message, PipeOptions.Asynchronous, 0, 0, progressPipeSecurity);
                AsyncCallback callBack = new AsyncCallback(asynctestmethod);
                pipeServer.BeginWaitForConnection(callBack, Tuple.Create(pipeServer));
            }

            public bool WriteRuleStart(int ruleId , string title, int percentcompleted)
            {
                CauBpaProgress cauBpaProgress = new CauBpaProgress( ruleId, title, RuleState.Started, RuleSeverity.Info, new List<string>(), percentcompleted);
                return WriteCauProgress(cauBpaProgress);
            }

            public bool WriteRuleResult(int ruleId , string title, bool result, int sev, string[] failedMachines, int percentcompleted)
            {
                RuleSeverity severity = RuleSeverity.Info;
                RuleState state = RuleState.Succeeded;
                if (!result)
                {
                    state = RuleState.Failed;
                    if (Enum.IsDefined(typeof(RuleSeverity), sev))
                    {
                        severity = (RuleSeverity)sev;
                    }
                    else
                    {
                        throw new ArgumentException("Invalid RuleSeverity.", "severity");
                    }
                }

                IList<string> failedMachinesList= new List<string>();
                foreach( string machine in failedMachines )
                {
                   failedMachinesList.Add(machine);
                }

                CauBpaProgress cauBpaProgress = new CauBpaProgress(ruleId, title, state, severity, failedMachinesList, percentcompleted);
                return WriteCauProgress(cauBpaProgress);
            }

            public bool WriteCauProgress(CauBpaProgress progress)
            {
                DataContractSerializer dcs =new DataContractSerializer(typeof(CauBpaProgress));
                using (StringWriter stringWriter = new StringWriter(CultureInfo.InvariantCulture))
                {
                   using (XmlWriter xmlWriter = new XmlTextWriter(stringWriter))
                   {
                       dcs.WriteObject(xmlWriter, progress);
                       string message=stringWriter.GetStringBuilder().ToString();
                       return WriteCauProgress(message);
                    }
                 }
            }

            public bool WriteCauProgress(string message)
            {
               if (pipeServer.IsConnected)
               {
                   Byte[] bytes = encoding.GetBytes(message);
                   pipeServer.Write(bytes, 0, bytes.Length);
                   return true;
               }
               else
               {
                   return false;
               }
            }

            public void CloseCAUPipe()
            {
                if (pipeServer.IsConnected)
                {
                   pipeServer.Close();
                }
            }

            public void asynctestmethod(IAsyncResult result)
            {
                Tuple<NamedPipeServerStream> state = (Tuple<NamedPipeServerStream>)result.AsyncState;
                NamedPipeServerStream pipeServer = state.Item1;
                if (result.AsyncWaitHandle.WaitOne())
                {
                    pipeServer.EndWaitForConnection(result);
                }
            }
        }//class
    }//namespace

'@
  Compile-Csharp $code "/target:library"
}

function PercentCompleted ($ruleid,$totalrules)
{
    $percent=$ruleid/$totalrules*100
    $percent
}

function Write-RuleStart($CAUPipeServer, $id, $title, $percentcompleted)
{
    if($CAUPipeServer -ne $null)
    {
        $messageSent=$CAUPipeServer.WriteRuleStart([int]$id, [string]$title, [int]$percentcompleted)
    }
}

function Write-RuleResult($CAUPipeServer, $id, $title, $result, $sev, $failedMachines, $percentcompleted)
{
    if($CAUPipeServer -ne $null)
    {
        $messageSent=$CAUPipeServer.WriteRuleResult([int]$id, [string]$title, [bool]$result, [int]$sev, [string[]] $failedMachines, [int]$percentcompleted)
    }
}

#
# Function Description:
#  test if the file is present on remote computer
#
# Arguments:
#  $computerName - name of remote machine
#  $fileName - name of the file whose contents need to be fetched on remote machine
#
# Return Value:
#  $fileContent if file exists
#  
function GetRemoteFileContent([string]$computerName,[string]$fileName)
{
    $session= New-PSSession -ComputerName $computerName
    if ($session -eq $null)
    {
        return $false;
    }
    
    $fileResults = Invoke-Command -Session $session -ScriptBlock { 
        # Finding a nonexisting folder name
        do 
        { 
            $tempFolder = [System.Environment]::ExpandEnvironmentVariables("%windir%\Temp\" + [System.IO.Path]::GetRandomFileName());
        }while(Test-Path -Path $tempFolder)

        $folderInfo = mkdir $tempFolder;
        try
        {
            $outFile = $tempFolder + "\foundScript.ps1";
            $copyScript = $tempFolder + "\copyScript.bat";
            
            #creating batch file to copy file content
            "copy `"" + $args[0] + "`" `"" + $outFile + "`"" | Out-File $copyScript -Encoding ascii
            
            #connecting to task scheduler and running batch file
            $taskScheduler = New-Object -com("Schedule.Service")
            $taskScheduler.connect();

            $copyTask = $taskScheduler.NewTask(0);
            $copyTask.Settings.Hidden = $false
            $copyTaskAction = $copyTask.Actions.Create( 0 ); # 0 - Excutes a command-line operation
            $copyTaskAction.Path = $copyScript;
            
            $registeredTask = $taskScheduler.GetFolder("\").RegisterTask($null, $copyTask.XmlText, 2, "SYSTEM", $null, 5, $null)
            try
            {
                $runningTask = $registeredTask.Run($null)
                
                #waiting on task to complete
        	    while($registeredTask.State -ne 3) # Waiting until task goes back to the Ready State ( 3 )
                {
                    Start-Sleep -Milliseconds 100
                }

                #Writing if the file exists to return stream
                $fileExists = Test-Path -Path $outFile
                $fileExists
            	if ($fileExists)
            	{
                    #if file exists, we will write it content to the stream as well
                    get-content $outFile -Encoding String
            	}
            }
            finally
            {
                #remove the scheduled task
            	$taskScheduler.GetFolder("\").DeleteTask($registeredTask.Name, 0);
            }
        }
        finally
        {
            #remove our temporary folder too
        	remove-item $tempFolder -Force -Recurse
        }

    } -ArgumentList $fileName

    Remove-PSSession $session
    $fileResults
}


#
# Function Description:
#  Test if the user is admin on remote computer
#
# Arguments:
#  $computerName - name of remote machine
#  
#
# Return Value:
#  $true if user is Admin
#  $false if user is not an Admin

function isAdminonremote ($computerName)
{
    $session= New-PSSession -ComputerName $computerName
    if ($session -eq $null)
    {
        return $false;
    }

    $isAdmin=Invoke-Command -Session $session -ScriptBlock { $user=[System.Security.Principal.WindowsIdentity]::GetCurrent(); $identity = $user;$principal = new-object System.Security.Principal.WindowsPrincipal($identity);$admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator;$principal.IsInRole($admin) }    
    # make sure we remove the session, otherwise it will linger around
    Remove-PSSession $session
    $isAdmin
}


#
# Function Description:
#  Test if the PS remoting is enabled
#
# Arguments:
#  $computerName - name of remote machine
#  
#
# Return Value:
#  $true if PS remoting is enabled
#  $false otherwise

function isPSRemotingEnabled ($computerName)
{
    # There is no reliable way to detect if PS remoting is enabled.
    # If creating a new PS session fails, we claim PS remoting is not enabled

    $isPSEnabled=$false
    $session= New-PSSession -ComputerName $computerName
    if ($session -ne $null)
    {
        $isPSEnabled=$true;
        Remove-PSSession $session
    }
    return $isPSEnabled;
}


#
# FUNCTION DESCRIPTION:
#   Get WinHttp proxy for a machine
#
# PARAMETERS:
#   $computer
#
# RETURN VALUES:
#   Proxy server else return null
#
#http://blogs.msdn.com/b/timid/archive/2011/06/20/getting-web-proxy-settings.aspx
function Get-WinHttpProxy
{
    param ( [string[]]$computer = '.' );

    try
    {
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer);
        $subKey= "SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Connections" -replace '\\', '\\';
        $regKey= $reg.OpenSubKey($subkey);

        $proxyServer = $exclusionList = $null;

        if ($regKey)
        {
            $data = $regKey.GetValue('WinHttpSettings');
            if (!$data -or $data.Count -le 16)
            {
                $proxyServer
            }
            else
            {
                $data1 = $data[16 .. ($data.Count-1)];
                $firstNull = [array]::IndexOf($data1, [byte]0);
 
                if ($firstNull -le 1)
                {
                    $proxyServer
                }
                else
                {
                    $proxyServer = [string]::Join("",($data1[0 .. ($firstNull-2)]|%{[char][int]$_}));

                    if ($data1.Count -lt ($firstNull+3))
                    {
                    }
                    else
                    {
                        $exclusionList = [string]::Join("",($data1[($firstNull+3) .. ($data1.Count-1)]| %{[char][int]$_}));
                    }
                }
            }
        }
    }
    catch
    {
        $proxyServer = $null;
    }
    $proxyServer
}

#
# Function Description:
#  Check whether the cluster is in downlevel cluster
#
# Arguments:
#  $clusterName - Name of the cluster
# Return Value:
#  $true - if it is a downlevel cluster
#  $false - if it is a Win8 or greater cluster
#
function isDownlevelCluster($clusterName)
{
    if(($clusterName -ne $null) -AND ($clusterName.Trim().Length -ne 0))
    {        
        $nodes= get-clusternode -Cluster $clusterName | Select-Object -Property MajorVersion,MinorVersion
    }
    else
    {
        $nodes = get-clusternode | Select-Object -Property MajorVersion,MinorVersion
    }

    $result = $false
    foreach($node in $nodes)
    {
        if(($node.MajorVersion -lt 6) -OR ($node.MajorVersion -eq 6 -AND $node.MinorVersion -le 1))
        {
            $result = $true
            break
        }
    }
    $result
}
