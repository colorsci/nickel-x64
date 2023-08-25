#-----------------------------------------------------------------------
# The user running this script needs to have administrator privileges
#-----------------------------------------------------------------------

param($TargetType,$IpamUgName,$IpamUgSid,$Log)

function LogToFile ([string] $msg)
{
    Add-Content $logFile -Encoding Unicode -value $msg
}

function pscmdexec ([string[]] $msg)
{   
    $cmd = $msg[0]
    $desc = $msg[1]
    DebugPrint $desc
    $firstStep = [string][DateTime]::Now + " Step: " + $desc
    $secondStep = "`t" + "Executing: "
    $output = "`t" + "Output: "
    $secondStep += $cmd
    LogToFile $firstStep
    LogToFile $secondStep
    
    trap 
    { 
        $output += $_
        LogToFile $output
        LogToFile "IPAM Provisioning step failed"
        ErrorPrint $_
        ErrorPrint "IPAM provisoining step failed."
        break
    }

    $dummy = Invoke-Expression $cmd
    $output += "Success"
    LogToFile $output
    
    return $dummy
}

function cmdexec ([string[]] $msg, [bool]$breakOnError = $TRUE, [int]$swallowErrorCode = 0)
{   
    $cmd = $msg[0]
    $desc = $msg[1]
    DebugPrint $desc
    $firstStep = [string][DateTime]::Now + " Step: " + $desc
    $secondStep = "`t" + "Executing: "
    $output = "`t" + "Output: "
    $secondStep += $cmd
    LogToFile $firstStep
    LogToFile $secondStep
   
    $ret = Invoke-Expression $cmd
    if(($LastExitCode -gt 0) -and ($LastExitCode -ne $swallowErrorCode))
    {
        $output += $ret;
        LogToFile $output
        if ($breakOnError -eq $TRUE)
        {
            LogToFile "IPAM provisoining step failed."
            ErrorPrint $ret;
            ErrorPrint "IPAM provisoining step failed."
            throw "$ret"
        }
    }
    else
    {
        if(($LastExitCode -ne 0) -and ($LastExitCode -eq $swallowErrorCode))
        {
            LogToFile "`tError returned but ignored, errorcode: $LastExitCode"
            ErrorPrint "Error returned but ignored, errorcode: $LastExitCode"
        }
        $output += "Success"
        LogToFile $output
    }
    
    return $ret
}

function DebugPrint ([string] $str)
{
    $host.UI.WriteLine("yellow", "black", "$str")
}

function ErrorPrint ([string] $str)
{
    $host.UI.WriteLine("red", "black", "$str")
}

function initLogFile([string] $log)
{
    $dummy = New-Item -path $log -type "file" -Force -ErrorAction silentlycontinue
    if(-not $?)
    {
        ErrorPrint "Couldn't open the log file $log"
        ErrorPrint "Usage: .\ipamprovisioning.ps1 -TargetType <DHCP|DNS> -IpamUgName <string> -IpamUgSid <string> [-log <logfilepath>]"
    }
}

function GetAce($IdentityName, $IdentityDomain, $Sid, $AccessMask)
{
    #Create Trustee
    $trustee = ([WMIClass] "\\.\root\cimv2:Win32_Trustee").CreateInstance()
    $trustee.Domain = $IdentityDomain
    $trustee.Name = $IdentityName
    $trustee.SIDString = $Sid
    
    #Create Ace
    $ace = ([WMIClass] "\\.\root\cimv2:Win32_ACE").CreateInstance()
    $ace.AccessMask = $AccessMask
    $ace.AceFlags = 0
    $ace.AceType = 0
    $ace.Trustee = $trustee
    
    return $ace
}

function AddReadPermissionToAuditShare([string]$ipamUgName)
{
    trap
    {
        LogToFile  "`tAddReadPermissionToAuditShare failed, $_"
        DebugPrint "AddReadPermissionToAuditShare failed, $_"
        break
    }
    
    $arr = $IpamUgName.Split("@")
    $identityName = $arr[0]
    $identityDomain = $arr[1]
    $readPermission = 1179817 #Read permission mask
 
    DebugPrint "AddReadPermissionToAuditShare: Name: $identityName Domain: $identityDomain"
    $auditSecuritySettings = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -filter "Name='dhcpaudit'";
    if ($null -eq $auditSecuritySettings) {
        throw "Failed to retreive dhcpaudit from Win32_LogicalShareSecuritySetting"        
    }
    
    $auditSD = $auditSecuritySettings.GetSecurityDescriptor().Descriptor;    
    foreach ($acl in $auditSD.DACL)
    {
        if ($acl.Trustee.Name -eq $IdentityName) {
            LogToFile  "`t$identityName permission already present in the dhcpaudit share"
            DebugPrint "$identityName permission already present in the dhcpaudit share"            
            # ACL for given Identity already present - return            
            return
        }
    }
    
    $ace = GetAce $identityName $identityDomain $IpamUgSid $readPermission

    #Add ACE to Dacl
    $auditSD.DACL += [System.Management.ManagementBaseObject]$ace
    
    $audit = Get-WmiObject -Class win32_share -filter "Name='dhcpaudit'"
    $ret = $audit.SetShareInfo($auditSecuritySettings.MaximumAllowed, $auditSecuritySettings.Description, $auditSD)    
    if ($ret.ReturnValue -ne 0) {        
        throw "SetShareInfo failed with $($ret.ReturnValue)"
    }
    else {
        LogToFile  "`t$identityName permission added successfully to the dhcpaudit share"
        DebugPrint "$identityName permission added successfully to the dhcpaudit share"
    }
}

# This is the C# Code compiler routine
function Compile-Csharp ([string] $code, [Array]$References)
{
    # Get an instance of the CSharp code provider
    $cp = New-Object Microsoft.CSharp.CSharpCodeProvider
    $refs = New-Object Collections.ArrayList
    $refs.AddRange( @("System.dll", "System.Windows.Forms.dll", "System.Data.dll", "System.Drawing.dll", "System.XML.dll"))
    if ($References.Count -ge 1) 
    {
        $refs.AddRange($References)
    }
    # Build up a compiler params object...
    $cpar = New-Object System.CodeDom.Compiler.CompilerParameters
    $cpar.GenerateInMemory = $true
    $cpar.GenerateExecutable = $false
    $cpar.OutputAssembly = "custom"
    $cpar.ReferencedAssemblies.AddRange($refs)
    $cr = $cp.CompileAssemblyFromSource($cpar, $code)
    if ( $cr.Errors.Count)
    {
        $codeLines = $code.Split("`n");
        foreach ($ce in $cr.Errors)
        {
            LogToFile "Error: $($codeLines[$($ce.Line - 1)])"
            LogToFile $ce
        }
        Throw "INVALID DATA: Errors encountered while compiling code"
    }
}

# C-Sharp Code for PInvoke to FormatMessage API to retreive the 'DHCP Users' localized string
$code = @'
using System;
using System.Runtime.InteropServices;

namespace PInvokeLibrary
{
    public class PInvoke
    {

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, ExactSpelling = true, EntryPoint = "LoadLibraryExW")] 
        public static extern IntPtr LoadLibraryEx(string lpFileName, IntPtr hFile, uint dwFlags);

        [DllImport("kernel32.dll", ExactSpelling = true)] 
        public static extern int FreeLibrary(IntPtr hModule);

        [DllImport("Kernel32.dll", SetLastError=true)]
        static extern uint FormatMessage( uint dwFlags, IntPtr lpSource, uint dwMessageId, uint dwLanguageId, System.Text.StringBuilder message, int nSize, IntPtr pArguments);

        public static string FormatMessage(string dllName, uint messageId)
        {
            System.Text.StringBuilder sb = new System.Text.StringBuilder(1024);
            uint flag = 0x00000800 | 0x00000200 | 0x000000FF; //FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_MAX_WIDTH_MASK
    
            IntPtr hMod = LoadLibraryEx(dllName, IntPtr.Zero, 3);  //3 ==> LOAD_LIBRARY_AS_DATAFILE
            if (hMod != IntPtr.Zero)
            {
                uint res = FormatMessage(flag, hMod, messageId, 0, sb, sb.Capacity, IntPtr.Zero);
                //Console.WriteLine("LoadLibr returned: {0} - FormatMessage returned: {1}", hMod, res);
                //Console.WriteLine("String inside RUN is: {0}  capacity: {1}", sb.ToString(), sb.Capacity);
                FreeLibrary(hMod);              
            }
            return sb.ToString();
        }
    }
}
'@


function ConfigureDhcpNetworkShare([string]$ipamUgName)
{
    trap
    {  
       LogToFile "`tConfigureDhcpNetworkShare FAILED!!" 
       ErrorPrint "ConfigureDhcpNetworkShare FAILED!!"
       break
    }

    # Read the DHCP log file path from the registry entry
    $dhcpServerParams = pscmdexec("get-itemproperty HKLM:\System\CurrentControlSet\Services\DHCPServer\Parameters","Fetching the DHCP params from registry")

    # Get the log file folder
    [string] $dhcpLogFilePath = $dhcpServerParams.DhcpLogFilePath;
    
    # Validate that a proper file path is returned
    if(($dhcpLogFilePath -ine $null) -and  ($dhcpLogFilePath -ine ""))
    {
       LogToFile "`tDHCP Log file path: $dhcpLogFilePath"

       # Create the network share
       cmdexec("net share dhcpaudit=`"$dhcpLogFilePath`" /grant:`"$ipamUgName,read`"","Creating the network share") -swallowErrorCode 2
       AddReadPermissionToAuditShare $ipamUgName       
    }
    else
    {
       LogToFile "`tInvalid DHCP log folder detected from DHCP registry settings" 
       DebugPrint "Invalid DHCP log folder detected from DHCP registry settings" 
    }
}

# Get the localized 'Dhcp Administrators' string
function GetDhcpAdministratorsLocalizedString()
{    
    trap
    {
        $output = "GetDhcpAdministratorsLocalizedString failed: $_"
        LogToFile $output
        ErrorPrint $output        
        break
    }
    
    compile-CSharp $code
    $dllName = $env:windir + "\system32\dhcpssvc.dll"
    $msgId = 1128 #DHCP MsgId for 'DHCP Administrators' string
    $dhcpAdministratorsString = [PInvokeLibrary.PInvoke]::FormatMessage($dllName, $msgId)
    if (("" -eq $dhcpAdministratorsString) -or ($null -eq $dhcpAdministratorsString)) {
        throw "Failed to retreive message Id $msgId from $dllName"
    }
    return $dhcpAdministratorsString
}

function AddIpamUgToDHCPAdministrators([string] $ipamUgName)
{
    trap
    {
       LogToFile "`tAddIpamUgToDHCPAdministrators FAILED!!" 
       ErrorPrint "AddIpamUgToDHCPAdministrators FAILED!!"
       break
    }

    # Fetching DhcpAdministrators localized string
    DebugPrint "Fetching DhcpAdministrators localized string"
    [string] $dhcpAdministratorsGroupName = GetDhcpAdministratorsLocalizedString
    DebugPrint "DHCP Administrators localized string: $dhcpAdministratorsGroupName"
    
    # Add IPAMUG to the group name
    cmdexec("Net localgroup `"$dhcpAdministratorsGroupName`" /add $ipamUgName","Add IPAMUG to the DHCP Administrators group name: $dhcpAdministratorsGroupName") -swallowErrorCode 2
}



function AddIpamUgToDnsAdmins([string] $ipamUgName)
{
    trap
    {
       LogToFile "`tAddIpamUgToDnsAdmins FAILED!!" 
       ErrorPrint "AddIpamUgToDnsAdmins FAILED!!"
       break
    }

    $currSystem = Get-WmiObject Win32_ComputerSystem

	# DomainRole parameter in Win32_ComputerSystem tells you whether the current system is DC or not
	# Value of 4 and 5 are primary and replica DC
    if ((4 -eq $currSystem.DomainRole) -or (5 -eq $currSystem.DomainRole))
    {
       # Fetching DnsAdmins string if the machine is a Domain Controller as DnsAdmins group name is not localized
       DebugPrint "Fetching DnsAdmins string"
       [string] $DnsAdminsGroupName = "DnsAdmins"
       DebugPrint "DnsAdmins localized string: $DnsAdminsGroupName"
    
       # Add IPAMUG to the group name
       cmdexec("Net localgroup `"$DnsAdminsGroupName`" /add $ipamUgName","Add IPAMUG to the DnsAdmins group name: $DnsAdminsGroupName") -swallowErrorCode 2
    }
    else
    {
       # Fetching Administrators localized string from well known SID on non-DC servers
       DebugPrint "Fetching Administrators localized string"
       $administratorsGroupSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
       [string] $administratorsGroupName = $administratorsGroupSid.Translate([System.Security.Principal.NTAccount]).Value
	   # Net Localgroup command doesn't work if group name is BUILTIN\Administrators so removing the BUILTIN\ tag
       $administratorsGroupName = $administratorsGroupName.Substring($administratorsGroupName.IndexOf("\") + 1)
       DebugPrint "Administrators localized string: $administratorsGroupName"
    
       # Add IPAMUG to the group name
       cmdexec("Net localgroup `"$administratorsGroupName`" /add $ipamUgName","Add IPAMUG to the Administrators group name: $administratorsGroupName") -swallowErrorCode 2
    }
}

function GetUpdatedSddl([string]$existingSddl, [string]$newAce)
{
    $daclIndex = $existingSddl.IndexOf("D:", 0)
    $firstAceIndex = $existingSddl.IndexOf("(", $daclIndex)
    return $existingSddl.Insert($firstAceIndex, $newAce)
}
        
function AddSidToServiceDacl([string[]] $msg)
{
    trap
    {
       LogToFile "`tAddSidToServiceDacl $servicename FAILED!!" 
       ErrorPrint "AddSidToServiceDacl $servicename FAILED!!"
       break
    }

    # Get the existing service SDDL
    $ipamUgSid = $msg[0]
    $servicename = $msg[1]
    
    [string] $serviceSddl = cmdexec("sc.exe sdshow $servicename","Fetching SDDL for $servicename")    
    LogToFile "`tExisting Service SDDL: $serviceSddl"

    #Check if IPAMUG Sid is already a member of the DHCPServer SDDL
    if(!($serviceSddl | select-string $ipamUgSid))
    {      
        # Create the ACE with required privileges for IPAMUG
        [string] $ipamUgAce = "(A;;CCLCSWLOCRRC;;;" + $ipamUgSid + ")"
        
        # Get the updated SDDL with new ACE for IPAMUG
        $newServiceSddl = GetUpdatedSddl $serviceSddl $ipamUgAce
        LogToFile "`t New Service SDDL: $newServiceSddl"
        
        # Set the new service SDDL
        cmdexec("sc.exe sdset $servicename `"$newServiceSddl`"","Setting new SDDL for $servicename.")            
    }
    else
    {
       LogToFile "`tIPAMUG is already a member of the Service ACL" 
       DebugPrint "IPAMUG is already a member of the Service ACL" 
    }
}

function ConfigureDnsEventLog([string] $ipamUgSid)
{
    trap
    {
       LogToFile "`tConfigureDnsEventLog FAILED!!" 
       ErrorPrint "ConfigureDnsEventLog FAILED!!"
       break
    }   

    # Get the existing DNS event log settings
    $dnsEventLog = pscmdexec("get-itemproperty `"HKLM:\System\CurrentControlSet\Services\EventLog\DNS Server`"","Getting Event Log registry for DNS")
  
    [string] $CustomSD = $dnsEventLog.CustomSD;
    
    LogToFile "`tExisting DNS Event Log CustomSD: $CustomSD"
    
    #Check if IPAMUG Sid is already a member of the CustomSD registry
    if(!($CustomSD | select-string $ipamUgSid))
    {
        # Create the string with required privileges for IPAMUG
        $ipamsddl = "(A;;0x1;;;" + $ipamUgSid + ")";
        
        # Get the updated SDDL with new ACE for IPAMUG
        $newCustomSD = GetUpdatedSddl $CustomSD $ipamsddl
        LogToFile "`tNew DNS Event Log CustomSD: $newCustomSD"
        
        # Set the registry value
        pscmdexec("set-itemproperty `"HKLM:\System\CurrentControlSet\Services\EventLog\DNS Server`" -Name CustomSD -Value `"$newCustomSD`"","Setting Event Log registry for DNS")
    }
    else
    {
       LogToFile "`tIPAMUG is already a member of the DNS CustomSD" 
       DebugPrint "IPAMUG is already a member of the DNS CustomSD" 
    }

}

function AddEventLogReaderMembership([string] $IpamUgName)
{
    $addToEventLogReaderFailed = $false

    trap
    {
        LogToFile "`tAddToEventLogReaders FAILED!!" 
        ErrorPrint "AddToEventLogReaders FAILED!!"
        continue
    }

    try
    {
        #Add IPAMUG to Event Log Readers group

        $eventLogSid = New-Object System.Security.Principal.SecurityIdentifier ("S-1-5-32-573")
        $eventLogGroup = $eventLogSid.Translate( [System.Security.Principal.NTAccount])
    
        LogToFile "`tEvent Log Reader Group name: $eventLogGroup.Value"

        #The returned value of name would be like "BUILTIN\Event Log Readers". Splitting the name for usage
        $eventLogGroupName = $eventLogGroup.Value.Split('\\')[1]

        LogToFile "`tEvent Log Reader Group Name for object: $eventLogGroupName"

        $eventLogGroupObject = [ADSI]"WinNT://./$eventLogGroupName,group"

        LogToFile "`tEvent Log Reader object: $eventLogGroupObject"

        $eventLogGroupObject.psbase.Invoke("Add",([ADSI]"WinNT://$IpamUgName").Path)

        LogToFile "`t$IpamUgName added to Event Log Readers"
    }
    catch
    {
        LogToFile "`tException while adding event log reader membership: $_"
        throw
    }
}

#--------------------------------------------------------------------------------------------------------------------------------------------
#                                                                   Starting the script
#--------------------------------------------------------------------------------------------------------------------------------------------

$ErrorActionPreference = "stop"

# Check TargetType
if($TargetType)
{
    if(($TargetType -ine "DHCP") -and ($TargetType -ine "DNS") -and ($TargetType -ine "DC_NPS"))
    {
        ErrorPrint "Invalid TargetType specified."
        ErrorPrint "Usage: .\ipamprovisioning.ps1 -TargetType <DHCP|DNS> -IpamUgName <string> -IpamUgSid <string> [-log <logfilepath>]"
        exit
    }
}
else
{
    ErrorPrint "TargetType not specified";
    ErrorPrint "Usage: .\ipamprovisioning.ps1 -TargetType <DHCP|DNS|DC_NPS> -IpamUgName <string> -IpamUgSid <string> [-log <logfilepath>]"
    exit
}

if(($IpamUgSid -ieq $null) -or ($IpamUgSid -ieq ""))
{
    ErrorPrint "IpamUgSid not specified";
    ErrorPrint "Usage: .\ipamprovisioning.ps1 -TargetType <DHCP|DNS|DC_NPS> -IpamUgName <string> -IpamUgSid <string> [-log <logfilepath>]"
    exit
}

if(($IpamUgName -ieq $null) -or ($IpamUgName -ieq ""))
{
    ErrorPrint "IpamUgName not specified";
    ErrorPrint "Usage: .\ipamprovisioning.ps1 -TargetType <DHCP|DNS|DC_NPS> -IpamUgName <string> -IpamUgSid <string> [-log <logfilepath>]"
    exit
}

#--------------------------------------------------------------------------------------------------------------------------------------------
#                                                                Starting command execution
#--------------------------------------------------------------------------------------------------------------------------------------------

# Initialize the log file
if($log)
{
    [string] $logFile = $log
}
elseif($TargetType -ieq "DNS")
{
    [string] $windir= $env:windir
    [string] $logFile = $windir + "\temp\ipamdnslog.txt"
}
elseif($TargetType -ieq "DHCP")
{
        [string] $windir= $env:windir
        [string] $logFile = $windir + "\temp\ipamdhcplog.txt"
}
elseif($TargetType -ieq "DC_NPS")
{
        [string] $windir= $env:windir
        [string] $logFile = $windir + "\temp\ipamdcnpslog.txt"
}
    
trap
{
    continue
}

initLogFile $logfile

$time = [string][datetime]::Now
LogToFile "DateTime: $time"

AddEventLogReaderMembership($IpamUgName)

if($TargetType -ieq "DHCP")
{
    ConfigureDhcpNetworkShare($IpamUgName)
    AddIpamUgToDHCPAdministrators($IpamUgName)
    [string] $service="dhcpserver"
    AddSidToServiceDacl($IpamUgSid, $service)
}
elseif($TargetType -ieq "DNS")
{
    ConfigureDnsEventLog($IpamUgSid)
    AddIpamUgToDnsAdmins($IpamUgName)
    [string] $service="dns"    
    AddSidToServiceDacl($IpamUgSid, $service)
}

exit
