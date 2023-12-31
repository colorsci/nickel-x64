data _system_translations {
   ConvertFrom-StringData @'
    # fallback text goes here 
 
    BindingExists_title = DHCP: The server should be bound to at least one IP address.
    BindingExists_problem = DHCP server is not bound to an IP address.
    BindingExists_impact = A server that is not bound to an IP address cannot serve IP address leases or any other network configuration to DHCP clients.
    BindingExists_resolution = By using the DHCP MMC snap-in, add bindings to one or more IP addresses.
    BindingExists_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice. 

    BindingExistsV4_title = DHCP: The server should be bound to an IPv4 address
    BindingExistsV4_problem = The DHCP server is not bound to an IPv4 address.
    BindingExistsV4_impact = A server that is not bound to an IPv4 address cannot lease IPv4 addresses to DHCP clients.
    BindingExistsV4_resolution = By using the DHCP MMC snap-in, add bindings to one or more IPv4 addresses.
    BindingExistsV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    BindingExistsV6_title = DHCP: The server should be bound to an IPv6 address.
    BindingExistsV6_problem = The DHCP server is not bound to an IPv6 address.
    BindingExistsV6_impact = A server that is not bound to an IPv6 address cannot lease IPv6 addresses to DHCP clients.
    BindingExistsV6_resolution = By using the DHCP MMC snap-in, add bindings to one or more IPv6 addresses.
    BindingExistsV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    RegistryPermissions_title = DHCP: The server should have Full control permissions to the DHCP registry parameters.
    RegistryPermissions_problem = The DHCP Server service does not have Full control permissions to the DHCP registry parameters.
    RegistryPermissions_impact = The DHCP server might not be able to read its registry configuration and might not start.
    RegistryPermissions_resolution = Assign Full control permissions for the DHCP registry to the DHCP Server service.
    RegistryPermissions_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice. 
    
    DatabasePermissions_title = DHCP: The server should have Full control permissions to the database directory.
    DatabasePermissions_problem = The configured  database directory does not exist or the DHCP server does not have Full control permissions to the database directory {0}.
    DatabasePermissions_impact = The DHCP server cannot work without access to the database directory.
    DatabasePermissions_resolution = Create the database directory path if it does not exist, and then assign the DHCP server Full control permissions.
    DatabasePermissions_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DatabaseBackupPermissions_title = DHCP: The server should have Full control permissions to the backup directory.
    DatabaseBackupPermissions_problem = The configured backup directory does not exist or the DHCP server does not have Full control permissions to the backup directory {0}.
    DatabaseBackupPermissions_impact = The DHCP server cannot make periodic backups of the database without access to the backup directory.
    DatabaseBackupPermissions_resolution = Create the backup directory path if it does not exist and assign the DHCP server Full control permissions.
    DatabaseBackupPermissions_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    AuditlogPermissions_title = DHCP: The server should have Full control permissions to the audit log directory.
    AuditlogPermissions_problem = The configured audit log directory does not exist or the DHCP server does not have Full control permissions to the audit log directory {0}.
    AuditlogPermissions_impact = The DHCP server cannot log server activity without access to the audit log directory.
    AuditlogPermissions_resolution = Create the audit log directory path if it does not exist and then assign the DHCP server Full control permissions.
    AuditlogPermissions_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Database_title = DHCP: The server database should be functional and free of errors.
    Database_problem = The DHCP server failed to open the database and reported error {0}.
    Database_impact = The DHCP service shuts down if its database reports an error while opening.
    Database_resolution = Restore the last successfully backed up copy of the DHCP database from the backup directory.
    Database_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice. 
 
    RogueDetection_title = DHCP: Rogue detection should be enabled.
    RogueDetection_problem = Rogue detection has been disabled on the DHCP server.
    RogueDetection_impact = Disabling rogue detection can cause IP address conflicts.
    RogueDetection_resolution = To enable rogue detection, set registry entry DisableRogueDetection under HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\DHCPServer\\Parameters to a value 0.
    RogueDetection_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ADAuthExists_title = DHCP: The server should be authorized.
    ADAuthExists_problem = This DHCP server is not authorized.
    ADAuthExists_impact = If the DHCP server is not authorized, it cannot lease IP addresses to DHCP clients.
    ADAuthExists_resolution = For a domain member computer, use the DHCP MMC snap-in to authorize this server in Active Directory Domain Services. For a workgroup computer, identify any other DHCP server on the network, and then determine which server is authoritative. Shut down the other server.
    ADAuthExists_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    OpenedPortsV4_title = DHCP: Port 67 (DHCP server port for IPv4) should not be in use by any other process.
    OpenedPortsV4_problem = Port 67 is in use by process id  {0}.
    OpenedPortsV4_impact = If port 67 is in use by another process, the DHCP server cannot communicate with DHCPv4 clients.
    OpenedPortsV4_resolution = Configure process ID {0} to use a port other than 67.
    OpenedPortsV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    OpenedPortsV6_title = DHCP: Port 547 (DHCP server port for IPv6) should not be in use by any other process.
    OpenedPortsV6_problem = Port 547  is in use by process id {0}.
    OpenedPortsV6_impact = If port 547 is in use by another process, the DHCP server cannot communicate with DHCPv6 clients.
    OpenedPortsV6_resolution = Configure process ID {0} to use a port other than 547.
    OpenedPortsV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    RogueDetectionV4_title = DHCP: Port 68 (DHCP Client port for IPv4) should not be in use by any other process  while rogue detection is enabled.
    RogueDetectionV4_problem = Port 68 is in use by  process id {0}.
    RogueDetectionV4_impact = If port 68 is in use by another process, the DHCP server cannot perform rogue DHCP server detection in IPv4.
    RogueDetectionV4_resolution = Configure process ID {0} to use a port other than 68.
    RogueDetectionV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    RogueDetectionV6_title = DHCP: Port 546 (DHCP Client port for IPv6) should not be in use by any other process while rogue detection is enabled.
    RogueDetectionV6_problem = Port 546 is in use by  process id {0}.
    RogueDetectionV6_impact = If port 546 is in use by another process, the DHCP server cannot perform rogue DHCP server detection in IPv6.
    RogueDetectionV6_resolution = Configure process ID {0} to use a port other than 546.
    RogueDetectionV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ScopesV4_title = DHCP: The server should have at least one IPv4 scope.
    ScopesV4_problem = The DHCP server does not have an IPv4 scope configured.
    ScopesV4_impact = The DHCPv4 server cannot lease IP addresses to DHCP clients unless a scope is configured.
    ScopesV4_resolution = Configure an IPv4 scope by using the DHCP MMC snap-in.
    ScopesV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ScopesV6_title = DHCP: The server should have at least one IPv6 scope or server option configured.
    ScopesV6_problem = The DHCP server does not have an IPv6 scope or server option configured.
    ScopesV6_impact = The DHCPv6 server cannot service DHCP client request unless a scope or server option is configured.
    ScopesV6_resolution = Configure an IPv6 scope or a server option using the DHCP MMC snap-in.
    ScopesV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    IpRangeExists_title = DHCP: An IP address range should be defined for all scopes.
    IpRangeExists_problem = The following scopes do not have an IP address range defined: {0}.
    IpRangeExists_impact = A scope is unusable without an IP address range.
    IpRangeExists_resolution = Configure an IP address range for the scope using the DHCP MMC snap-in.
    IpRangeExists_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ScopesDeactivated_title = DHCP: All {0} configured scopes should be active
    ScopesDeactivated_problem = The DHCP server has the following inactive scopes: {1}.
    ScopesDeactivated_impact = If a scope is inactive, the DHCP server cannot lease IP addresses to clients in the scope.
    ScopesDeactivated_resolution = Activate the scopes using the DHCP MMC snap-in.
    ScopesDeactivated_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DAD_title = DHCP: IP Address conflict detection should have a value less than 4.
    DAD_problem = IP address conflict detection  has been set to a value greater than 3.
    DAD_impact = Conflict detection with a value greater than 3 can lead to slow performance of the DHCP server.
    DAD_resolution = Set the IP address conflict detection value to 3 or less using DHCP MMC snap-in.
    DAD_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice. 

    DhcpSecurityGroups_title = DHCP: Security Groups (DHCP Administrators and DHCP Users) required for DHCP administration should be created.
    DhcpSecurityGroups_problem = Security Groups (DHCP Administrator and DHCP Users) do not exist for this DHCP server.
    DhcpSecurityGroups_impact = DHCP administration and monitoring privileges cannot be assigned to other user accounts on the server.
    DhcpSecurityGroups_resolution = Use the add securitygroups command in Netsh to create the DHCP security groups.
    DhcpSecurityGroups_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ServerIPV4Excl_title = DHCP: The server IPv4 address should be excluded from all scopes.
    ServerIPV4Excl_problem = The following address conflicts have been found (Server IP address, Scope): {0}.
    ServerIPV4Excl_impact = The DHCP server might lease its own static IP address to a client computer, leading to an IP address conflict and disruption of DHCP service.
    ServerIPV4Excl_resolution = Use the DHCP MMC snap-in to exclude the DHCP server IPv4 addresses from the scope.
    ServerIPV4Excl_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ServerIPV6Excl_title = DHCP: The server IPv6 address should be excluded from all scopes.
    ServerIPV6Excl_problem = The following address conflicts have been found (Server IP address, Scope): {0}.
    ServerIPV6Excl_impact = The DHCP server might lease its own static IP address to a client computer, leading to an IP address conflict and disruption of DHCP service.
    ServerIPV6Excl_resolution = Use the DHCP MMC snap-in to exclude the DHCP server IPv6 addresses from the scope.
    ServerIPV6Excl_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    AuditLog_title = DHCP: Audit logging should be enabled.
    AuditLog_problem = Audit logging is turned off on the DHCP server.
    AuditLog_impact = The audit log cannot record DHCP server activity.
    AuditLog_resolution = Enable audit logging by using the  DHCP MMC snap-in.
    AuditLog_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsV4DynUpdate_title = DHCP: The server should be configured to register DNS records on behalf of DHCPv4 clients.
    DnsV4DynUpdate_problem = Domain Name System (DNS) registrations of DHCPv4 client computers from the DHCP server have been disabled for the following scopes: {0}.
    DnsV4DynUpdate_impact = The DHCP server cannot register DHCPv4 client names in DNS resulting in the inability to connect to these client computers by using host names unless the client computers are themselves registering DNS records.
    DnsV4DynUpdate_resolution = Configure client computers to register with DNS or use the DHCP MMC snap-in to configure dynamic DNS updates on the DHCP server for DHCPv4.
    DnsV4DynUpdate_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsV6DynUpdate_title = DHCP: The server should be configured to register DNS records on behalf of DHCPv6 clients.
    DnsV6DynUpdate_problem = Domain Name System (DNS) registrations of DHCPv6 client computers from the DHCP server have been disabled for the following scopes: {0}.
    DnsV6DynUpdate_impact = The DHCP server cannot register DHCPv6 client names in DNS resulting in the inability to connect to these client computers by using host names unless the client computers are themselves registering DNS records.
    DnsV6DynUpdate_resolution = Configure client computers to register with DNS or use the DHCP MMC snap-in to configure dynamic DNS updates on the DHCP server for DHCPv6.
    DnsV6DynUpdate_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsCredentials_title = DHCP: Credentials for DNS update should be configured if secure dynamic DNS update is enabled and the domain controller is on the same host as the DHCP server.
    DnsCredentials_problem = Secure dynamic Domain Name System (DNS) update is configured, and a domain cotroller is running on the same host as the DHCP server, but credentials for DNS update are not configured.
    DnsCredentials_impact = DNS registrations can fail if credentials for DNS update are not configured.
    DnsCredentials_resolution = By using the DHCP MMC snap-in, configure credentials for dynamic DNS update.
    DnsCredentials_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    AllowList_title = DHCP: If the allow list is enabled, MAC address filtering should be populated.
    AllowList_problem = The allow list for MAC address filtering is enabled but the list does not contain any MAC addresses.
    AllowList_impact = The DHCP server cannot lease IP addresses.
    AllowList_resolution = Use the DHCP MMC snap-in to enter MAC addresses of DHCP clients in the allow list.
    AllowList_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    ReservationConflict_title =  DHCP: The MAC address filtering configuration should not block IP address reservations.
    ReservationConflict_problem = The following reservations conflict with the configuration of MAC address filters (Reserved IP address, MAC address): {0}.
    ReservationConflict_impact = The DHCP server cannot lease reserved IP addresses to clients with conflicting MAC address filters.
    ReservationConflict_resolution = Use the DHCP MMC snap-in to change the MAC address filters so that reservations are not blocked.
    ReservationConflict_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    IAS_title = DHCP: An NPS (Network Policy Server) should be installed if NAP (Network Access Protection) is enabled.
    IAS_problem = NPS is either not installed or is unreachable.
    IAS_impact = Network Access Protection (NAP) is not enforced by the DHCP server which may result in  non-compliant clients gaining, or compliant clients being denied, access to the network.
    IAS_resolution = Install NPS if it is not already installed, and then ensure that the service is running.
    IAS_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice. 

    DefaultGateway_title = DHCP: The server should be configured to send the default gateway to all clients.
    DefaultGateway_problem = The DHCP server does not have the default gateway option (option 3) set for the following scopes: {0}.
    DefaultGateway_impact = The DHCP server cannot provide default gateway addresses to clients resulting in loss of connectivity for client computers.
    DefaultGateway_resolution = Use the DHCP MMC snap-in to configure the default gateway option at each scope.
    DefaultGateway_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsServerV4_title = DHCP: The DNS server option should be configured for all IPv4 scopes.
    DnsServerV4_problem = The Domain Name System (DNS) server option (option 6) is not configured for the following scopes: {0}.
    DnsServerV4_impact = DHCPv4 clients cannot resolve DNS names.
    DnsServerV4_resolution = Configure DNS server as a scope option or server option by using the DHCP MMC snap-in.
    DnsServerV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsServerV6_title = DHCP: The DNS server option should be configured for all IPv6 scopes.
    DnsServerV6_problem = The Domain Name System (DNS) server option (option 23) is not configured for the following scopes: {0}.
    DnsServerV6_impact = DHCPv6 clients cannot resolve DNS names.
    DnsServerV6_resolution = Configure the DNS server as a scope option or server option by using the DHCP MMC snap-in.
    DnsServerV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsV4ServerValidation_title = DHCP: The IPv4 addresses of the DNS server should be reachable.
    DnsV4ServerValidation_problem = The following DNS server IP address(s) is/are unreachable. The DNS server IP addresess configured as a server option are represented as (DNS IP address, Server/Scope): {0}.
    DnsV4ServerValidation_impact = DHCPv4 clients with an unreachable IP address cannot resolve DNS names.
    DnsV4ServerValidation_resolution = Configure a different DNS server as a scope option or server option by using the DHCP MMC snap-in.
    DnsV4ServerValidation_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsV6ServerValidation_title = DHCP: The IPv6 addresses of the DNS server should be reachable.
    DnsV6ServerValidation_problem = The following DNS server IP address(s) is/are unreachable.  The DNS server IP addresess configured as a server option are represented as (DNS IP address, Server/Scope): {0}.
    DnsV6ServerValidation_impact = DHCPv6 clients with an unreachable IP address will not be able to resolve DNS names.
    DnsV6ServerValidation_resolution = Configure a different DNS server as a scope or server option using the DHCP MMC.
    DnsV6ServerValidation_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsDomainOptionV4_title = DHCP: The DNS domain option should be configured as a scope or server option for DHCPv4.
    DnsDomainOptionV4_problem = The DNS domain option (option 15) is not configured for the following IPv4 scope(s): {0}.
    DnsDomainOptionV4_impact = DHCPv4 clients cannot resolve host names.
    DnsDomainOptionV4_resolution = Configure a DNS domain as a server option or scope option by using the DHCP MMC snap-in.
    DnsDomainOptionV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DnsDomainOptionV6_title = DHCP: The DNS domain option should be configured as a scope or server option for DHCPv6.
    DnsDomainOptionV6_problem = The DNS search list option (option 24) is not configured for the following scope(s): {0}.
    DnsDomainOptionV6_impact = DHCPv6 clients cannot resolve host names.
    DnsDomainOptionV6_resolution = Configure a DNS search list as a server option or scope option by using the DHCP MMC snap-in.
    DnsDomainOptionV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    SecureDnsUpdatesV4_title = DHCP: Secure DNS updates should be configured if name protection is enabled on any IPv4 scope.
    SecureDnsUpdatesV4_problem = Name protection has been enabled on the following IPv4 scopes, but secure Domain Name System (DNS) updates is not enabled: {0}
    SecureDnsUpdatesV4_impact = Name protection requires secure update to work. Without name protection DNS names can be spoofed.
    SecureDnsUpdatesV4_resolution = By using the DNS MMC snap-in, configure an Active Directory-integrated DNS zone for the domain and enable secure (only) dynamic updates.
    SecureDnsUpdatesV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    FwdLookupZonesV4_title = DHCP: A forward lookup zone should be configured for the DNS domain used to register DNS records for IPv4 clients.
    FwdLookupZonesV4_problem = A forward lookup zone has not been configured for the following domains (Domain Name, Server/Scope): {0}
    FwdLookupZonesV4_impact = Domain Name System (DNS) registration of A records for client computers will fail resulting in the inability to connect to these client computers using host names.
    FwdLookupZonesV4_resolution = By using the DNS MMC snap-in, configure a forward lookup zone for these domains or configure the correct domain name on the DHCP server as a scope option or server option.
    FwdLookupZonesV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    SecureDnsUpdatesV6_title = DHCP: Secure DNS updates should be configured if name protection is enabled on any IPv6 scope.
    SecureDnsUpdatesV6_problem = Name protection is enabled on the following IPv6 scopes, but secure Domain Name System (DNS) updates is not enabled: {0}
    SecureDnsUpdatesV6_impact = Name protection requires secure update to work. Without name protection DNS names can be spoofed.
    SecureDnsUpdatesV6_resolution = By using the DNS MMC snap-in, configure an Active Directory-integrated DNS zone for the domain and enable secure (only) dynamic updates.
    SecureDnsUpdatesV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    FwdLookupZonesV6_title = DHCP: A forward lookup zone should be configured for the DNS domain used to register DNS records for IPv6 clients.
    FwdLookupZonesV6_problem = A forward lookup zone has not been configured for the following domains (Domain Name, Server/Scope): {0}
    FwdLookupZonesV6_impact = Domain Name System (DNS) registration of AAAA records for client computers will fail resulting in inability to connect to these client computers using host names.
    FwdLookupZonesV6_resolution = By using the DNS MMC snap-in, configure a forward lookup zone for these domains or configure the correct domain name on the DHCP server as a scope option or server option.
    FwdLookupZonesV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    SecureDnsUpdateProxyV4_title = DHCP: The DNSupdateproxy group must be secured if Name Protection is enabled on any IPV4 scope.
    SecureDnsUpdateProxyV4_problem = Name protection is enabled, but the DNSupdateproxy group is not secured (Domain Name, Server/Scope): {0}.
    SecureDnsUpdateProxyV4_impact = Name protection cannot work without a secured DNSupdateproxy group.
    SecureDnsUpdateProxyV4_resolution = By using dnscmd, set the OpenACLOnProxyUpdates to 0 to secure the DNSupdateproxy group.
    SecureDnsUpdateProxyV4_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    SecureDnsUpdateProxyV6_title = DHCP: The DNSupdateproxy group must be secured if Name Protection is enabled on any IPV6 scope.
    SecureDnsUpdateProxyV6_problem = Name protection is enabled, but the DNSupdateproxy group is not secured (Domain Name, Server/Scope): {0}.
    SecureDnsUpdateProxyV6_impact = Name protection cannot work without a secured DNSupdateproxy group.
    SecureDnsUpdateProxyV6_resolution = By using dnscmd, set the OpenACLOnProxyUpdates to 0 to secure the DNSupdateproxy group.
    SecureDnsUpdateProxyV6_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Error_title = DHCP: An error occured during the DHCP BPA scan.
    Error_problem = The DHCP Best Practices Analyzer (BPA) scan stopped because of the following error: {0} ({1})
    Error_impact = DHCP BPA scan cannot continue to completion until this error is resolved.
    Error_resolution = See the DHCP server  documentation on http://go.microsoft.com/fwlink/?LinkId=108876 to resolve this error.
    Error_compliant = The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    strActive = Active
    strInactive = Inactive
    strServer = Server
'@
}

function Compile-Csharp ([string] $code, [string] $compilerOptions, [Array]$References)
{
    # Get an instance of the CSharp code provider
    $cp = New-Object Microsoft.CSharp.CSharpCodeProvider
    $refs = New-Object Collections.ArrayList
    $refs.AddRange( @("${framework}System.dll",
    "${framework}System.Windows.Forms.dll",
    "${framework}System.Data.dll",
    "${framework}System.Drawing.dll",
    "${framework}System.XML.dll"))
    if ($References.Count -ge 1) 
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
        $codeLines = $code.Split("`n");
        foreach ($ce in $cr.Errors)
        {
            write-host "Error: $($codeLines[$($ce.Line - 1)])"
            $ce | out-default
        }
    Throw "INVALID DATA: Errors encountered while compiling code"
    }
}
#CSharp code goes here
function call-TCPIPQueryPorts()
{
$code = @'

namespace TCPIP
{
    using System;
    using System.Text;
    using System.Runtime.InteropServices;
    using System.Collections.Generic;
    using System.Collections;
    using System.Diagnostics;
    using System.Net;
    using System.ComponentModel;
    using System.Net.Sockets;

    public enum UDP_TABLE_CLASS
    {
        UDP_TABLE_BASIC,
        UDP_TABLE_OWNER_PID,
        UDP_TABLE_OWNER_MODULE
    }
	public partial class NativeConstants
    {
        public const int ERROR_INSUFFICIENT_BUFFER = 122;
	}	
    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MIB_UDPTABLE_OWNER_PID
    {
        // DWORD -> unsigned int
        public uint dwNumEntries;

        //MIB_UDPROW_OWNER_PID 
        public System.IntPtr table;
    }
    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MIB_UDPROW_OWNER_PID
    {
        // DWORD->unsigned int
        public uint dwLocalAddr;

        // DWORD->unsigned int
        public uint dwLocalPort;

        // DWORD->unsigned int
        public uint dwOwningPid;
    }
    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MIB_UDP6TABLE_OWNER_PID
    {
        // DWORD -> unsigned int
        public uint dwNumEntries;

        //MIB_UDP6ROW_OWNER_PID
        public System.IntPtr table;
    }
    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct MIB_UDP6ROW_OWNER_PID
    {
	// UCHAR[]->byte[]
	[System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 16, ArraySubType = System.Runtime.InteropServices.UnmanagedType.I1)]
	public byte[] ucLocalAddr;	

        // DWORD->unsigned int
        public uint dwLocalScopeId;

        // DWORD->unsigned int
        public uint dwLocalPort;

        // DWORD->unsigned int
        public uint dwOwningPid;
    }
       
    [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    public struct HINSTANCE__ 
    {
    
        /// int
        public int unused;
    }


    public partial class NativeMethods
    {
        // Return Type: DWORD->unsigned int
        // pUdpTable: PVOID->void*
        // pdwSize: PDWORD->int*
        // bOrder: BOOL->int
        // ulAf: ULONF->unsigned int
        // TableClass: UDP_TABLE_CLASS->UDP_TABLE_CLASS
        // Reserved: ULONG->unsigned int
        [System.Runtime.InteropServices.DllImportAttribute("iphlpapi.dll", EntryPoint = "GetExtendedUdpTable", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
        public static extern uint GetExtendedUdpTable([System.Runtime.InteropServices.InAttribute()] System.IntPtr pUdpTable, ref uint pdwSize, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)] bool bOrder, uint ulAf, UDP_TABLE_CLASS TableClass, uint Reserved);
    }
    internal class Utilities
    {
        internal static IPAddress GetIPV4Address(UInt32 Address)
        {	
	    byte[] AddressBytes = new byte[sizeof(UInt32)];
            for (int i = 0; i < sizeof(UInt32); i++)
            {
                AddressBytes[sizeof(UInt32) - i - 1] = (byte)
                ((Address >> (sizeof(UInt32) - 1 - i) * 8) & 0xff);
            }
            return new IPAddress(AddressBytes);
        }

        internal static IPAddress GetIPV6Address(byte[] ipv6Bytes)
	{
            IPAddress ipv6Address = new IPAddress(ipv6Bytes);
            return ipv6Address;
	}

	internal static uint GetLocalPort(uint port)
	{
	    uint NewPort = 0;   
            NewPort |= ((port >> 8) & 0x000000ff);
	    NewPort |= ((port << 8) & 0x0000ff00);
	    return NewPort;
	}
    }
    public class UDPRow
    {
        private IPAddress localAddress;
        public IPAddress LocalAddress
        {
            get { return localAddress; }
            set { localAddress = value; }
        }
        
        private uint localPort;
        public uint LocalPort
        {
            get { return localPort; }
            set { localPort = value; }
        }

        private uint pid;
        public uint Pid
        {
            get { return pid; }
            set { pid = value; }
        }
	public UDPRow(MIB_UDPROW_OWNER_PID row)
	{
            this.LocalAddress = Utilities.GetIPV4Address(row.dwLocalAddr);
            this.LocalPort = Utilities.GetLocalPort(row.dwLocalPort);
            this.Pid = row.dwOwningPid;
	}
    }
    public class UDP6Row
    {
        private IPAddress localAddress;
        public IPAddress LocalAddress
        {
            get { return localAddress; }
            set { localAddress = value; }
        }
        
        private uint localPort;
        public uint LocalPort
        {
            get { return localPort; }
            set { localPort = value; }
        }

        private uint pid;
        public uint Pid
        {
            get { return pid; }
            set { pid = value; }
        }
	public UDP6Row(MIB_UDP6ROW_OWNER_PID row)
	{
	    this.localAddress = Utilities.GetIPV6Address(row.ucLocalAddr);
            this.LocalPort = Utilities.GetLocalPort(row.dwLocalPort);
            this.Pid = row.dwOwningPid;
	}
    }

    public class PortInformationWrapper
    {
        internal static UDPRow[] GetUdpTableEntries()
        {
            uint error = 0;
            uint AF_NET = 2; // IPV4
            uint bufferSize = 0;
	    List<UDPRow> rowList = new List<UDPRow>();
         
	    error = NativeMethods.GetExtendedUdpTable(IntPtr.Zero, ref bufferSize, true, AF_NET, UDP_TABLE_CLASS.UDP_TABLE_OWNER_PID, 0);
            if (error != 0  && error != NativeConstants.ERROR_INSUFFICIENT_BUFFER)
            {
                return null;
            }
            IntPtr buffTable = Marshal.AllocHGlobal((int)bufferSize);
            error = NativeMethods.GetExtendedUdpTable(buffTable, ref bufferSize, true, AF_NET, UDP_TABLE_CLASS.UDP_TABLE_OWNER_PID, 0);
            if (error != 0)
            {
                return null;
            }
            MIB_UDPTABLE_OWNER_PID tbl = (MIB_UDPTABLE_OWNER_PID)Marshal.PtrToStructure(buffTable, typeof(MIB_UDPTABLE_OWNER_PID));
        
            IntPtr rowPtr = (IntPtr)(buffTable + Marshal.SizeOf(tbl.dwNumEntries));
         
            for (int i = 0; i < tbl.dwNumEntries; i++)
            {
                MIB_UDPROW_OWNER_PID udpRow = (MIB_UDPROW_OWNER_PID)Marshal.PtrToStructure(rowPtr, typeof(MIB_UDPROW_OWNER_PID));
		rowList.Add(new UDPRow(udpRow));
		Marshal.DestroyStructure(rowPtr, typeof(MIB_UDPROW_OWNER_PID));
                rowPtr = (IntPtr)(rowPtr + Marshal.SizeOf(udpRow));
            }
	    Marshal.DestroyStructure(buffTable, typeof(MIB_UDPTABLE_OWNER_PID)); 
            Marshal.FreeHGlobal(buffTable);
            if (0 == rowList.Count)
	    {
		return null;
	    }
            return rowList.ToArray();
        } 
        internal static UDP6Row[] GetUdpV6TableEntries()
        {
            uint error = 0;
            uint AF_NET6 = 23; // IPV6
            uint bufferSize = 0;
	    List<UDP6Row> rowList = new List<UDP6Row>();
         
	    error = NativeMethods.GetExtendedUdpTable(IntPtr.Zero, ref bufferSize, true, AF_NET6, UDP_TABLE_CLASS.UDP_TABLE_OWNER_PID, 0);
            if (error != 0 && error != NativeConstants.ERROR_INSUFFICIENT_BUFFER)
            {
                return null;
            }
            IntPtr buffTable = Marshal.AllocHGlobal((int)bufferSize);
            error = NativeMethods.GetExtendedUdpTable(buffTable, ref bufferSize, true, AF_NET6, UDP_TABLE_CLASS.UDP_TABLE_OWNER_PID, 0);
            if (error != 0)
            {
                return null;
            }
            MIB_UDP6TABLE_OWNER_PID tbl = (MIB_UDP6TABLE_OWNER_PID)Marshal.PtrToStructure(buffTable, typeof(MIB_UDP6TABLE_OWNER_PID));
         
            IntPtr rowPtr = (IntPtr)(buffTable + Marshal.SizeOf(tbl.dwNumEntries));
            for (int i = 0; i < tbl.dwNumEntries; i++)
            {
                MIB_UDP6ROW_OWNER_PID udpRow = (MIB_UDP6ROW_OWNER_PID)Marshal.PtrToStructure(rowPtr, typeof(MIB_UDP6ROW_OWNER_PID));
		rowList.Add(new UDP6Row(udpRow));
		Marshal.DestroyStructure(rowPtr, typeof(MIB_UDP6ROW_OWNER_PID)); 
                rowPtr = (IntPtr)(rowPtr + Marshal.SizeOf(udpRow));
            }
	    Marshal.DestroyStructure(buffTable, typeof(MIB_UDP6TABLE_OWNER_PID)); 
            Marshal.FreeHGlobal(buffTable);
            if (0 == rowList.Count)
	    {
		return null;
	    }
            return rowList.ToArray();
        } 

    }
    public class PortInformation
    {
	public PortInformation() {}

	public UDPRow[] GetUdpTable()
        {
	    return PortInformationWrapper.GetUdpTableEntries();
	}
	public UDP6Row[] GetUdpV6Table()
        {
	    return PortInformationWrapper.GetUdpV6TableEntries();
	}
    }
}
'@
Compile-Csharp $code "/target:library"
}
function call-DnsValidate()
{
$code = @'
	using System;
	using System.Collections.Generic;
	using System.Text;
	using System.Runtime.InteropServices;
	using System.Net.Sockets;
	using System.Net;

	namespace DnsValidation
	{
	    class NativeConstants
	    {
		public const int DNS_VALSVR_ERROR_NO_AUTH = 0x5;
		public const int DNS_VALSVR_ERROR_REFUSED = 0x6;
		public const int ERROR_SUCCESS = 0x0;

		public const int DNS_VALSRV_FLAG_STANDARD = 1;
			
	        public const Int16 AF_INET = 2;
                public const Int16 AF_INET6 = 23;
                public static readonly int SIZEOF_SOCKADDR_IN6 = Marshal.SizeOf(typeof(SOCKADDR_IN6));
                public static readonly int SIZEOF_SOCKADDR_IN = Marshal.SizeOf(typeof(SOCKADDR_IN));
	    }
  	    
            [StructLayout(LayoutKind.Sequential)]
       	    public unsafe struct SOCKADDR_IN6
            {
   	        public Int16 _family;
       	        public Int16 _port;
           	public Int32 _flowInfo;
           	public fixed byte _addr0[16];
                public Int32 _scopeID;
  	    };

       	    [StructLayout(LayoutKind.Sequential)]
       	    public unsafe struct SOCKADDR_IN
       	    {
            	public Int16 _family;
           	public Int16 _port;
           	public fixed byte _addr[4];
           	public fixed byte sin_zero[8];
            }
	
            [StructLayout(LayoutKind.Explicit)]
       	    public struct Dns_Addr
       	    {
                [FieldOffset(0)]
   	        public SOCKADDR_IN6 SockaddrIn6;
       	        [FieldOffset(0)]
           	public SOCKADDR_IN SockaddrIn;
           	[FieldOffset(32)]
           	public Int32 SockaddrLength;
           	[FieldOffset(36)]
           	public Int32 Delay;
           	[FieldOffset(40)]
           	public Int32 SubStatus;
           	[FieldOffset(44)]
           	public Int32 Status;
           	// Last 16 bytes are dummy and for no use
                [FieldOffset(48)]
   	        public Int32 dummy5;
       	        [FieldOffset(52)]
           	public Int32 dummy6;
                [FieldOffset(56)]
   	        public Int32 dummy7;
       	        [FieldOffset(60)]
           	public Int32 dummy8;
       	    };

	    class NativeMethods
	    {
	       	[DllImport("dnsapi.dll", CharSet = CharSet.Unicode, SetLastError = true, EntryPoint = "DnsValidateServerStatus")]
        	public static extern UInt32 DnsValidateServerStatusV4(ref SOCKADDR_IN DnsServerAddress, string QueryName, out uint status );

	       	[DllImport("dnsapi.dll", CharSet = CharSet.Unicode, SetLastError = true, EntryPoint = "DnsValidateServerStatus")]
        	public static extern UInt32 DnsValidateServerStatusV6(ref SOCKADDR_IN6 DnsServerAddress, string QueryName, out uint status );
	    }

  	    public class DnsWrapper
            {
       	        internal static bool GetValidationStatus(String ipAddressStr, String zone)
        	{
		    unsafe
                    {
                        try
                        {
                            byte[] addressBytes;
                            bool isV4 = false;
			    uint dns_status;
			    uint flag = NativeConstants.DNS_VALSRV_FLAG_STANDARD;
                            IPAddress ipAddress = IPAddress.Parse(ipAddressStr); 
                    	    if (ipAddress.AddressFamily == AddressFamily.InterNetwork)
                    	    {
                        	isV4 = true;
                    	    }
			    Dns_Addr dnsaddr = new Dns_Addr();
                            addressBytes = ipAddress.GetAddressBytes();
                            if (!isV4)
                    	    {
                        	dnsaddr.SockaddrLength = NativeConstants.SIZEOF_SOCKADDR_IN6;
                        	dnsaddr.SockaddrIn6._family = NativeConstants.AF_INET6;
                        	for (int j = 0; j < addressBytes.Length; j++)
                                {
                                    dnsaddr.SockaddrIn6._addr0[j] = addressBytes[j];
                                }
                                // Call the validation API
                                dns_status = NativeMethods.DnsValidateServerStatusV6(ref dnsaddr.SockaddrIn6, zone, out flag);
                            }
                            else
                            {
                                dnsaddr.SockaddrLength = NativeConstants.SIZEOF_SOCKADDR_IN;
                                dnsaddr.SockaddrIn._family = NativeConstants.AF_INET;
                                for (int j = 0; j < addressBytes.Length; j++)
                                {
                                    dnsaddr.SockaddrIn._addr[j] = addressBytes[j];
                                }
				// Call the validation API
                                dns_status = NativeMethods.DnsValidateServerStatusV4(ref dnsaddr.SockaddrIn, zone, out flag);
                            }
                            // The status is returned in addrArray.AddrArray.Status in case of folloing returned value it is considered pass
                            //DNS_VALSVR_ERROR_NO_AUTH = 5)||(ERROR_SUCCESS = 0) ||  (DNS_VALSVR_ERROR_REFUSED = 6))
                            if ((flag != NativeConstants.ERROR_SUCCESS) && (flag != NativeConstants.DNS_VALSVR_ERROR_NO_AUTH) && (flag != NativeConstants.DNS_VALSVR_ERROR_REFUSED))
		    	    {
				return false;
			    }
			    return true;
			}
  		        catch (Exception)
               	        {
                            return false;
                        }
                    }
	        }    
	    }
	    public class DnsValidationStatus
	    {
		public bool GetDnsValidationStatus(String ipAddress, string zone)
		{
		    return DnsWrapper.GetValidationStatus(ipAddress,zone);
		}
	    }
        }
'@
Compile-Csharp $code "/target:library /unsafe"
}
#CSharp code goes here
function call-DhcpQuery()
{
$code = @'
    namespace Dhcp
    {
	using System;
        using System.Text;
        using System.Runtime.InteropServices;
        using System.Collections.Generic;
        using System.Collections;
        using System.Diagnostics;
	using System.Net;
	using System.ComponentModel;
	using System.Net.Sockets;
	using System.Data.OleDb;
	
        public static class DHCPErrors
        {
            #region DHCP Errors
            public enum DHCPError : uint
            {
		ERROR_MORE_DATA = 0x000000EA,
		ERROR_FILE_NOT_FOUND = 0x00000002,
		ERROR_SUCCESS = 0x00000000,
                ERROR_NO_MORE_ITEMS = 0x00000103,			
                ERROR_DHCP_REGISTRY_INIT_FAILED = 0x00004E20,
                ERROR_DHCP_DATABASE_INIT_FAILED = 0x00004E21,
                ERROR_DHCP_RPC_INIT_FAILED = 0x00004E22,
                ERROR_DHCP_NETWORK_INIT_FAILED = 0x00004E23,
                ERROR_DHCP_SUBNET_EXITS = 0x00004E24,
                ERROR_DHCP_SUBNET_NOT_PRESENT = 0x00004E25,
                ERROR_DHCP_PRIMARY_NOT_FOUND = 0x00004E26,
                ERROR_DHCP_ELEMENT_CANT_REMOVE = 0x00004E27,
                ERROR_DHCP_OPTION_EXITS = 0x00004E29,
                ERROR_DHCP_OPTION_NOT_PRESENT = 0x00004E2A,
                ERROR_DHCP_ADDRESS_NOT_AVAILABLE = 0x00004E2B,
                ERROR_DHCP_RANGE_FULL = 0x00004E2C,
                ERROR_DHCP_JET_ERROR = 0x00004E2D,
                ERROR_DHCP_CLIENT_EXISTS = 0x00004E2E,
                ERROR_DHCP_INVALID_DHCP_MESSAGE = 0x00004E2F,
                ERROR_DHCP_INVALID_DHCP_CLIENT = 0x00004E30,
                ERROR_DHCP_SERVICE_PAUSED = 0x00004E31,
                ERROR_DHCP_NOT_RESERVED_CLIENT = 0x00004E32,
                ERROR_DHCP_RESERVED_CLIENT = 0x00004E33,
                ERROR_DHCP_RANGE_TOO_SMALL = 0x00004E34,
                ERROR_DHCP_IPRANGE_EXITS = 0x00004E35,
                ERROR_DHCP_RESERVEDIP_EXITS = 0x00004E36,
                ERROR_DHCP_INVALID_RANGE = 0x00004E37,
                ERROR_DHCP_RANGE_EXTENDED = 0x00004E38,
                ERROR_EXTEND_TOO_SMALL = 0x00004E39,
                ERROR_DHCP_JET_CONV_REQUIRED = 0x00004E3B,
                ERROR_SERVER_INVALID_BOOT_FILE_TABLE = 0x00004E3C,
                ERROR_SERVER_UNKNOWN_BOOT_FILE_NAME = 0x00004E3D,
                ERROR_DHCP_SUPER_SCOPE_NAME_TOO_LONG = 0x00004E3E,
                ERROR_DHCP_IP_ADDRESS_IN_USE = 0x00004E40,
                ERROR_DHCP_LOG_FILE_PATH_TOO_LONG = 0x00004E41,
                ERROR_DHCP_UNSUPPORTED_CLIENT = 0x00004E42,
                ERROR_DHCP_JET97_CONV_REQUIRED = 0x00004E44,
                ERROR_DHCP_ROGUE_INIT_FAILED = 0x00004E45,
                ERROR_DHCP_ROGUE_SAMSHUTDOWN = 0x00004E46,
                ERROR_DHCP_ROGUE_NOT_AUTHORIZED = 0x00004E47,
                ERROR_DHCP_ROGUE_DS_UNREACHABLE = 0x00004E48,
                ERROR_DHCP_ROGUE_DS_CONFLICT = 0x00004E49,
                ERROR_DHCP_ROGUE_NOT_OUR_ENTERPRISE = 0x00004E4A,
                ERROR_DHCP_ROGUE_STANDALONE_IN_DS = 0x00004E4B,
                ERROR_DHCP_CLASS_NOT_FOUND = 0x00004E4C,
                ERROR_DHCP_CLASS_ALREADY_EXISTS = 0x00004E4D,
                ERROR_DHCP_SCOPE_NAME_TOO_LONG = 0x00004E4E,
                ERROR_DHCP_DEFAULT_SCOPE_EXITS = 0x00004E4F,
                ERROR_DHCP_CANT_CHANGE_ATTRIBUTE = 0x00004E50,
                ERROR_DHCP_IPRANGE_CONV_ILLEGAL = 0x00004E51,
                ERROR_DHCP_NETWORK_CHANGED = 0x00004E52,
                ERROR_DHCP_CANNOT_MODIFY_BINDINGS = 0x00004E53,
                ERROR_DHCP_SUBNET_EXISTS = 0x00004E54,
                ERROR_DHCP_MSCOPE_EXISTS = 0x00004E55,
                ERROR_MSCOPE_RANGE_TOO_SMALL = 0x00004E56,
                ERROR_DHCP_EXEMPTION_EXISTS = 0x00004E57,
                ERROR_DHCP_EXEMPTION_NOT_PRESENT = 0x00004E58,
                ERROR_DHCP_INVALID_PARAMETER_OPTION32 = 0x00004E59,
                ERROR_DDS_NO_DS_AVAILABLE = 0x00004E66,
                ERROR_DDS_NO_DHCP_ROOT = 0x00004E67,
                ERROR_DDS_UNEXPECTED_ERROR = 0x00004E68,
                ERROR_DDS_TOO_MANY_ERRORS = 0x00004E69,
                ERROR_DDS_DHCP_SERVER_NOT_FOUND = 0x00004E6A,
                ERROR_DDS_OPTION_ALREADY_EXISTS = 0x00004E6B,
                ERROR_DDS_OPTION_DOES_NOT_EXIST = 0x00004E6C,
                ERROR_DDS_CLASS_EXISTS = 0x00004E6D,
                ERROR_DDS_CLASS_DOES_NOT_EXIST = 0x00004E6E,
                ERROR_DDS_SERVER_ALREADY_EXISTS = 0x00004E6F,
                ERROR_DDS_SERVER_DOES_NOT_EXIST = 0x00004E70,
                ERROR_DDS_SERVER_ADDRESS_MISMATCH = 0x00004E71,
                ERROR_DDS_SUBNET_EXISTS = 0x00004E72,
                ERROR_DDS_SUBNET_HAS_DIFF_SSCOPE = 0x00004E73,
                ERROR_DDS_SUBNET_NOT_PRESENT = 0x00004E74,
                ERROR_DDS_RESERVATION_NOT_PRESENT = 0x00004E75,
                ERROR_DDS_RESERVATION_CONFLICT = 0x00004E76,
                ERROR_DDS_POSSIBLE_RANGE_CONFLICT = 0x00004E77,
                ERROR_DDS_RANGE_DOES_NOT_EXIST = 0x00004E78,
                ERROR_DHCP_DELETE_BUILTIN_CLASS = 0x00004E79,
                ERROR_DHCP_INVALID_SUBNET_PREFIX = 0x00004E7B,
                ERROR_LAST_DHCP_SERVER_ERROR = 0x00004E7C,
            };
            #endregion DHCP Errors
        }

        public enum USER_GROUPS
        {
           ID_DHCP_USER_GROUP  = 211,
           ID_DHCP_ADMIN_GROUP = 213,
        };

        public enum IPv4_OPTIONS
        {
           DHCP_GATEWAY  = 3,
           DHCP_DNSSERVER  = 6,
           DHCP_DNSDOMAINNAME = 15,
           DHCP_DNSFQDN  = 81,
        };
           
        public enum IPv6_OPTIONS
        {
           DHCPV6_DNSSERVER  = 23,
           DHCPV6_DNSDOMAINNAME = 24,
           DHCPV6_DNSFQDN  = 39,
        };

        public enum SOCKET_PORTS
        {
           DHCP_SERVER  = 67,
           DHCP_CLIENT  = 68,
           DHCPV6_SERVER = 547,
           DHCPV6_CLIENT = 546,
           
        };
     

	public class DHCPException : Exception
        {
            #region private members

            /// <summary>
            /// DHCP Error returned by the API.
            /// </summary>
            private DHCPErrors.DHCPError dhcpError;
 
            /// <summary>
            /// Error code.
            /// </summary>
            private UInt32 errorCode;

            /// <summary>
            /// Win32 exception.
            /// </summary>
            private Win32Exception win32Exception;
            #endregion private members

            #region constructors
 
            /// <summary>
            /// Construct from an error code.
            /// </summary>
            /// <param name="errorCode">The 32-bit error code that an API call returned.</param>
            public DHCPException(UInt32 errorCode)
                : base((0 != MapToDHCPError(errorCode)) ? MapToDHCPError(errorCode).ToString()
                : (new Win32Exception((int)errorCode)).Message)
            {
                this.dhcpError = MapToDHCPError(errorCode);
                if (0 == this.dhcpError)
                {
                    this.win32Exception = new Win32Exception((int)errorCode);
                }
                else
                {
                    this.win32Exception = null;
                }

                this.errorCode = errorCode;
            }

            /// <summary>
            /// Construct from a DHCPSAPI Error enum.
            /// </summary>
            /// <param name="error">A DHCPSAPI Error enum.</param>
            public DHCPException(DHCPErrors.DHCPError error)
                : base(error.ToString())
            {
                this.dhcpError = error;
                this.errorCode = (uint)error;
                this.win32Exception = null;
            }
 
            #endregion constructors

            #region public properties
			
	    /// <summary>
            /// Gets the DHCPSAPI error that caused this exception.
            /// All <c>DHCPException</c> may not have a SAPI error associated.
            /// </summary>
            public DHCPErrors.DHCPError DHCPError
            {
                get { return this.dhcpError; }
            }
    
            /// <summary>
            /// Gets the Win32 exception that corresponds to this exception.
            /// </summary>
            public Win32Exception Win32Ex
            {
                get { return this.win32Exception; }
            }

            /// <summary>
            /// Gets the error code that caused this <c>DHCPException.</c>
            /// </summary>
            public UInt32 ErrorCode
            {
                get { return this.errorCode; }
            }

            #endregion public properties

            #region public methods
            /// <summary>
            /// Map a 32-bit error code to a DHCP Error (if possible).
            /// </summary>
            /// <param name="error">A 32-bit error code returned by the SAPI.</param>
            /// <returns>A <c>DHCPSAPI.DHCPError</c> if possible. 0 otherwise.</returns>
            private static DHCPErrors.DHCPError MapToDHCPError(UInt32 error)
            {
                DHCPErrors.DHCPError mappedError = 0;
    
                foreach (DHCPErrors.DHCPError e in Enum.GetValues(typeof(DHCPErrors.DHCPError)))
                {
                    if ((uint)e == error)
                    {
                         mappedError = e;
                    }
                }

                return mappedError;
            }
			#endregion public methods
        }

	public partial class NativeConstants

        {
            /// DNS_FLAG_ENABLED -> 0x01
            public const int DNS_FLAG_ENABLED = 1;

            /// DNS_FLAG_CLEANUP_EXPIRED -> 0x04
	    public const int DNS_FLAG_CLEANUP_EXPIRED = 4;

            /// DNS_FLAG_UPDATE_DHCID -> 0x20
            public const int DNS_FLAG_UPDATE_DHCID = 32;

            /// HWTYPE_ETHERNET_10MB -> 1
            public const int HWTYPE_ETHERNET_10MB = 1;

	    /// DHCP_ATTRIB_TYPE_BOOL -> 0x01
            public const int DHCP_ATTRIB_TYPE_BOOL = 1;

	    public const int DENY_FILTER_LIST = 0;
	
	    public const int ALLOW_FILTER_LIST = 1;

	    public const int QUARANTINE_ON = 1;

	    public const int QUARANTINE_OFF = 0;
		
            public const int DHCP_OPT_ENUM_IGNORE_VENDOR = 1;
			
	    public const int ALLOW_UPDATES_STATUS = 2;
			
   	    public const int DOMAIN_CONTROLLER_STATUS = 2;
	}

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_BIND_ELEMENT
        {
            /// ULONG->unsigned int
            public uint Flags;

	    /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool fBoundToDHCPServer;
 
            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint AdapterPrimaryAddress;
 
            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint AdapterSubnetAddress;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string IfDescription;

            /// ULONG->unsigned int
            public uint IfIdSize;

            /// LPBYTE->BYTE*
            public System.IntPtr IfId;
	}
        
        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_BIND_ELEMENT_ARRAY
        {
            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_BIND_ELEMENT->_DHCP_BIND_ELEMENT*
            public System.IntPtr Elements;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_IPV6_ADDRESS
        {

             /// ULONGLONG->unsigned __int64
             public ulong HighOrderBits;

             /// ULONGLONG->unsigned __int64
             public ulong LowOrderBits;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCPV6_BIND_ELEMENT
        {
  
            /// ULONG->unsigned int
            public uint Flags;

            /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool fBoundToDHCPServer;

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS AdapterPrimaryAddress;

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS AdapterSubnetAddress;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]    
            public string IfDescription;

            /// DWORD->unsigned int
            public uint IpV6IfIndex;

            /// ULONG->unsigned int
            public uint IfIdSize;

            /// LPBYTE->BYTE*
            public System.IntPtr IfId;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCPV6_BIND_ELEMENT_ARRAY
        {

            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCPV6_BIND_ELEMENT->_DHCPV6_BIND_ELEMENT*
            public System.IntPtr Elements;
        }

	[System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
	public struct DHCP_IP_ARRAY
        {

            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_IP_ADDRESS->DWORD*
            public System.IntPtr Elements;
        }

	[System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCPV6_IP_ARRAY
        {

            /// DWORD->unsigned int
            public uint NumElements;
   
            /// LPDHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS*
            public System.IntPtr Elements;
        }

        public enum DHCP_SUBNET_ELEMENT_TYPE
        {

            DhcpIpRanges,
   
            DhcpSecondaryHosts,

            DhcpReservedIps,
  
            DhcpExcludedIpRanges,

            DhcpIpUsedClusters,

            DhcpIpRangesDhcpOnly,

            DhcpIpRangesDhcpBootp,

            DhcpIpRangesBootpOnly,
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_BINARY_DATA
        {

            /// DWORD->unsigned int
            public uint DataLength;

            /// BYTE*
            public System.IntPtr Data;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_BOOTP_IP_RANGE
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint StartAddress;
 
            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint EndAddress;

            /// ULONG->unsigned int
            public uint BootpAllocated;

            /// ULONG->unsigned int
            public uint MaxBootpAllowed;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_HOST_INFO
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint IpAddress;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string NetBiosName;

            /// LPWSTR->WCHAR*
           [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string HostName;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_IP_RESERVATION_V4
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint ReservedIpAddress;

            /// DHCP_CLIENT_UID*
            public System.IntPtr ReservedForClient;

            /// BYTE->unsigned char
            public byte bAllowedClientTypes;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_IP_RANGE
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint StartAddress;

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint EndAddress;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_IP_CLUSTER
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint ClusterAddress;

            /// DWORD->unsigned int
            public uint ClusterMask;
        }
        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SUBNET_ELEMENT_DATA_V5
        {
 
            /// DHCP_SUBNET_ELEMENT_TYPE->_DHCP_SUBNET_ELEMENT_TYPE_V5
            public DHCP_SUBNET_ELEMENT_TYPE ElementType;

            /// _DHCP_SUBNET_ELEMENT_DATA_V5__DHCP_SUBNET_ELEMENT_UNION_V5
            public _DHCP_SUBNET_ELEMENT_DATA_V5__DHCP_SUBNET_ELEMENT_UNION_V5 Union1;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Explicit)]
        public struct _DHCP_SUBNET_ELEMENT_DATA_V5__DHCP_SUBNET_ELEMENT_UNION_V5
        {
  
            /// DHCP_BOOTP_IP_RANGE*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr IpRange;

            /// DHCP_HOST_INFO*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr SecondaryHost;

            /// DHCP_IP_RESERVATION_V4*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr ReservedIp;

            /// DHCP_IP_RANGE*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr ExcludeIpRange;

            /// DHCP_IP_CLUSTER*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr IpUsedCluster;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SUBNET_ELEMENT_INFO_ARRAY_V5
        {

            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_SUBNET_ELEMENT_DATA_V5->_DHCP_SUBNET_ELEMENT_DATA_V5*
            public System.IntPtr Elements;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_IP_RANGE_V6
        {

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS StartAddress;

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS EndAddress;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_IP_RESERVATION_V6
        {

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS ReservedIpAddress;

            /// DHCP_CLIENT_UID*
            public System.IntPtr ReservedForClient;

            /// DWORD->unsigned int
            public uint InterfaceId;
        }

        public enum DHCP_SUBNET_ELEMENT_TYPE_V6
        {

            Dhcpv6IpRanges,

            Dhcpv6ReservedIps,

            Dhcpv6ExcludedIpRanges,
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Explicit)]
        public struct _DHCP_SUBNET_ELEMENT_DATA_V6__DHCP_SUBNET_ELEMENT_UNION_V6
        {

            /// DHCP_IP_RANGE_V6*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr IpRange;
    
            /// DHCP_IP_RESERVATION_V6*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr ReservedIp;

            /// DHCP_IP_RANGE_V6*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr ExcludeIpRange;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SUBNET_ELEMENT_DATA_V6
        {

            /// DHCP_SUBNET_ELEMENT_TYPE_V6->_DHCP_SUBNET_ELEMENT_TYPE_V6
            public DHCP_SUBNET_ELEMENT_TYPE_V6 ElementType;

            /// _DHCP_SUBNET_ELEMENT_DATA_V6__DHCP_SUBNET_ELEMENT_UNION_V6
            public _DHCP_SUBNET_ELEMENT_DATA_V6__DHCP_SUBNET_ELEMENT_UNION_V6 Union1;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SUBNET_ELEMENT_INFO_ARRAY_V6
        {

            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_SUBNET_ELEMENT_DATA_V6->_DHCP_SUBNET_ELEMENT_DATA_V6*
            public System.IntPtr Elements;
        }

	public enum DHCP_SUBNET_STATE
        {

            /// DhcpSubnetEnabled -> 0
            DhcpSubnetEnabled = 0,

            DhcpSubnetDisabled,

            DhcpSubnetEnabledSwitched,
    
            DhcpSubnetDisabledSwitched,
     
            DhcpSubnetInvalidState,
        }
	
        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SUBNET_INFO_VQ
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint SubnetAddress;
 
            /// DHCP_IP_MASK->DWORD->unsigned int
            public uint SubnetMask;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string SubnetName;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string SubnetComment;

            /// DHCP_HOST_INFO->_DHCP_HOST_INFO
            public DHCP_HOST_INFO PrimaryHost;

            /// DHCP_SUBNET_STATE->_DHCP_SUBNET_STATE
            public DHCP_SUBNET_STATE SubnetState;

            /// DWORD->unsigned int
            public uint QuarantineOn;

            /// DWORD->unsigned int
            public uint Reserved1;

            /// DWORD->unsigned int
            public uint Reserved2;

            /// INT64->__int64
            public long Reserved3;

            /// INT64->__int64
            public long Reserved4;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SUBNET_INFO_V6
        {

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS SubnetAddress;

            /// ULONG->unsigned int
            public uint Prefix;

            /// USHORT->unsigned short
            public ushort Preference;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string SubnetName;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string SubnetComment;

            /// DWORD->unsigned int
            public uint State;

            /// DWORD->unsigned int
            public uint ScopeId;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_SERVER_CONFIG_INFO_VQ
        {

            /// DWORD->unsigned int
            public uint APIProtocolSupport;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string DatabaseName;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string DatabasePath;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string BackupPath;

            /// DWORD->unsigned int
            public uint BackupInterval;

            /// DWORD->unsigned int
            public uint DatabaseLoggingFlag;

            /// DWORD->unsigned int
            public uint RestoreFlag;

            /// DWORD->unsigned int
            public uint DatabaseCleanupInterval;

            /// DWORD->unsigned int
            public uint DebugFlag;

            /// DWORD->unsigned int
            public uint dwPingRetries;

            /// DWORD->unsigned int
            public uint cbBootTableString;

            /// WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string wszBootTableString;

            /// BOOL->int
            public int fAuditLog;

            /// BOOL->int
            public int QuarantineOn;

            /// DWORD->unsigned int
            public uint QuarDefFail;

            /// BOOL->int
            public int QuarRuntimeStatus;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_RESERVED_SCOPE
        {

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint ReservedIpAddress;

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            public uint ReservedIpSubnetAddress;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Explicit)]
        public struct ScopeInfo
        {

            /// PVOID->void*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr DefaultScopeInfo;

            /// PVOID->void*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr GlobalScopeInfo;

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public uint SubnetScopeInfo;

            /// DHCP_RESERVED_SCOPE->_DHCP_RESERVED_SCOPE
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public DHCP_RESERVED_SCOPE ReservedScopeInfo;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr MScopeInfo;
        }

        public enum DHCP_OPTION_SCOPE_TYPE
        {

            DhcpDefaultOptions,

            DhcpGlobalOptions,

            DhcpSubnetOptions,

            DhcpReservedOptions,

            DhcpMScopeOptions,
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_OPTION_SCOPE_INFO
        {

            /// DHCP_OPTION_SCOPE_TYPE->_DHCP_OPTION_SCOPE_TYPE
            public DHCP_OPTION_SCOPE_TYPE ScopeType;

            /// _DHCP_OPTION_SCOPE_INFO__DHCP_OPTION_SCOPE_UNION
            public ScopeInfo Union1;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DWORD_DWORD
        {

            /// DWORD->unsigned int
            public uint DWord1;

            /// DWORD->unsigned int
            public uint DWord2;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Explicit)]
        public struct _DHCP_OPTION_DATA_ELEMENT__DHCP_OPTION_ELEMENT_UNION
        {
 
            /// BYTE->unsigned char
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public byte ByteOption;

            /// WORD->unsigned short
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public ushort WordOption;

            /// DWORD->unsigned int
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public uint DWordOption;

            /// DWORD_DWORD->_DWORD_DWORD
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public DWORD_DWORD DWordDWordOption;

            /// DHCP_IP_ADDRESS->DWORD->unsigned int
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public uint IpAddressOption;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr StringDataOption;

            /// DHCP_BINARY_DATA->_DHCP_BINARY_DATA
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public DHCP_BINARY_DATA BinaryDataOption;

            /// DHCP_BINARY_DATA->_DHCP_BINARY_DATA
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public DHCP_BINARY_DATA EncapsulatedDataOption;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr Ipv6AddressDataOption;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_OPTION_DATA_ELEMENT
        {

            /// DHCP_OPTION_DATA_TYPE->_DHCP_OPTION_DATA_TYPE
            public DHCP_OPTION_DATA_TYPE OptionType;
 
            /// _DHCP_OPTION_DATA_ELEMENT__DHCP_OPTION_ELEMENT_UNION
            public _DHCP_OPTION_DATA_ELEMENT__DHCP_OPTION_ELEMENT_UNION Union1;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_OPTION_DATA
        {
 
            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_OPTION_DATA_ELEMENT->_DHCP_OPTION_DATA_ELEMENT*
            public System.IntPtr Elements;
        }


        public enum DHCP_OPTION_DATA_TYPE
        {

            DhcpByteOption,
 
            DhcpWordOption,

            DhcpDWordOption,

            DhcpDWordDWordOption,

            DhcpIpAddressOption,

            DhcpStringDataOption,

            DhcpBinaryDataOption,

            DhcpEncapsulatedDataOption,

            DhcpIpv6AddressOption,
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_OPTION_VALUE
        {

            /// DHCP_OPTION_ID->DWORD->unsigned int
            public uint OptionID;

            /// DHCP_OPTION_DATA->_DHCP_OPTION_DATA
            public DHCP_OPTION_DATA Value;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_OPTION_VALUE_ARRAY
        {

            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_OPTION_VALUES -> DHCP_OPTION_VALUES*
            public System.IntPtr Values;
        }
		
	[System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
	public struct Anomynous_Dhcp_All_Option_Values_Structure
	{
	    /// LPWStr -> WCHAR*
	    [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
	    public string ClassName;
			
	    /// LPWStr -> WCHAR*
	    [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
	    public string VendorName;
			
	    /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool IsVendor;
			
	    /// LPDHCP_OPTION_VALUES_ARRAY -> DHCP_OPTION_VALUES_ARRAY*
	    public System.IntPtr OptionsArray;
	}
		
        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
	public struct DHCP_ALL_OPTION_VALUES
	{
 	    /// DWORD->unsigned int
	    public uint Flags;
			
	    /// DWORD->unsigned int
	    public uint NumElements;
			
	    /// Anonymous Structure
	    public System.IntPtr Array;
	}
		
        public enum DHCP_OPTION_SCOPE_TYPE6
        {

            DhcpDefaultOptions6,
   
            DhcpScopeOptions6,

            DhcpReservedOptions6,

            DhcpGlobalOptions6,
        }

        public enum DHCP_OPTION_TYPE
        {

            DhcpUnaryElementTypeOption,

            DhcpArrayTypeOption,
        }

    	[System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    	public struct DHCP_OPTION
    	{

            /// DHCP_OPTION_ID->DWORD->unsigned int
            public uint OptionID;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string OptionName;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string OptionComment;

            /// DHCP_OPTION_DATA->_DHCP_OPTION_DATA
            public DHCP_OPTION_DATA DefaultValue;

            /// DHCP_OPTION_TYPE->_DHCP_OPTION_TYPE
            public DHCP_OPTION_TYPE OptionType;
    	}

    	[System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
    	public struct DHCP_OPTION_ARRAY
    	{

            /// DWORD->unsigned int
            public uint NumElements;

       	    /// LPDHCP_OPTION->_DHCP_OPTION*
            public System.IntPtr Options;
    	}

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_RESERVED_SCOPE6
        {

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS ReservedIpAddress;

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            public DHCP_IPV6_ADDRESS ReservedIpSubnetAddress;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Explicit)]
        public struct _DHCP_OPTION_SCOPE_INFO6__DHCP_OPTION_SCOPE_UNION6
        {

            /// PVOID->void*
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public System.IntPtr DefaultScopeInfo;

            /// DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public DHCP_IPV6_ADDRESS SubnetScopeInfo;

            /// DHCP_RESERVED_SCOPE6->_DHCP_RESERVED_SCOPE6
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public DHCP_RESERVED_SCOPE6 ReservedScopeInfo;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_OPTION_SCOPE_INFO6
        {

            /// DHCP_OPTION_SCOPE_TYPE6->_DHCP_OPTION_SCOPE_TYPE6
            public DHCP_OPTION_SCOPE_TYPE6 ScopeType;

            /// _DHCP_OPTION_SCOPE_INFO6__DHCP_OPTION_SCOPE_UNION6
            public _DHCP_OPTION_SCOPE_INFO6__DHCP_OPTION_SCOPE_UNION6 Union1;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_FILTER_GLOBAL_INFO
        {

            /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool EnforceAllowList;

            /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool EnforceDenyList;
        }

        public enum DHCP_FILTER_LIST_TYPE
        {

            Deny,
   
            Allow,
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_ADDR_PATTERN
        {

            /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool MatchHWType;

            /// BYTE->unsigned char
            public byte HWType;

            /// BOOL->int
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public bool IsWildcard;

            /// BYTE->unsigned char
            public byte Length;

            /// BYTE[255]
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.ByValArray, SizeConst = 255, ArraySubType = System.Runtime.InteropServices.UnmanagedType.I1)]
            public byte[] Pattern;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_FILTER_RECORD
        {

	    /// DHCP_ADDR_PATTERN->_DHCP_ADDR_PATTERN
            public DHCP_ADDR_PATTERN AddrPatt;

            /// LPWSTR->WCHAR*
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)]
            public string Comment;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_FILTER_ENUM_INFO
        {

            /// DWORD->unsigned int
            public uint NumElements;

            /// LPDHCP_FILTER_RECORD->_DHCP_FILTER_RECORD*
            public System.IntPtr pEnumRecords;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Explicit)]
        public struct Anonymous_b467696c_1f22_4d4c_bf8b_b8aa4ad79e6d
        {

            /// BOOL->int
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.I1)]
            public bool DhcpAttribBool;

            /// ULONG->unsigned int
            [System.Runtime.InteropServices.FieldOffsetAttribute(0)]
            public uint DhcpAttribUlong;
        }

        [System.Runtime.InteropServices.StructLayoutAttribute(System.Runtime.InteropServices.LayoutKind.Sequential)]
        public struct DHCP_ATTRIB
        {
 
            /// DHCP_ATTRIB_ID->ULONG->unsigned int
            public uint DhcpAttribId;

            /// ULONG->unsigned int
            public uint DhcpAttribType;
 
            /// Anonymous_b467696c_1f22_4d4c_bf8b_b8aa4ad79e6d
            public Anonymous_b467696c_1f22_4d4c_bf8b_b8aa4ad79e6d Union1;
        }

        /// <summary>
    	/// Enum of Server Attributes.
	/// </summary>
    	public enum DHCPServerAttribute : uint
    	{
            /// <summary>
            /// Test for ROGUE.
            /// </summary>
            DhcpAttribBoolIsRogue = 0x1,

            /// <summary>
            /// Test for DYNBOOTP Support.
            /// </summary>
            DhcpAttribBoolIsDynBootp = 0x02,

            /// <summary>
            /// Test for DS.
            /// </summary>
            DhcpAttribBoolIsPartOfDsDc = 0x03,

            /// <summary>
            /// Test if server is bindings aware.
            /// </summary>
            DhcpAttributeBoolIsBindingAware = 0x04,

            /// <summary>
            /// Test for Admin Rights.
            /// </summary>
            DhcpAttribBoolIsAdmin = 0x05
        }

        public partial class NativeMethods
        {
            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///Flags: ULONG->unsigned int
            ///BindElementsInfo: LPDHCP_BIND_ELEMENT_ARRAY*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetServerBindingInfo", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpGetServerBindingInfo([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint Flags, ref System.IntPtr BindElementsInfo);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///Flags: ULONG->unsigned int
            ///BindElementsInfo: LPDHCPV6_BIND_ELEMENT_ARRAY*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetServerBindingInfoV6", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpGetServerBindingInfoV6([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint Flags, ref System.IntPtr BindElementsInfo);

	    /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///UnameSize: ULONG->unsigned int
            ///Uname: LPWSTR->WCHAR*
            ///DomainSize: ULONG->unsigned int
            ///Domain: LPWSTR->WCHAR*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpServerQueryDnsRegCredentials")]
            public static extern uint DhcpServerQueryDnsRegCredentials([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint UnameSize, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] System.Text.StringBuilder Uname, uint DomainSize, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] System.Text.StringBuilder Domain);


            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///ResumeHandle: DHCP_RESUME_HANDLE*
            ///PreferredMaximum: DWORD->unsigned int
            ///EnumInfo: LPDHCP_IP_ARRAY*
            ///ElementsRead: DWORD*
            ///ElementsTotal: DWORD*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpEnumSubnets", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpEnumSubnets([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, ref uint ResumeHandle, uint PreferredMaximum, ref System.IntPtr EnumInfo, [System.Runtime.InteropServices.OutAttribute()] out uint ElementsRead, [System.Runtime.InteropServices.OutAttribute()] out uint ElementsTotal);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///ResumeHandle: DHCP_RESUME_HANDLE*
            ///PreferredMaximum: DWORD->unsigned int
            ///EnumInfo: LPDHCPV6_IP_ARRAY*
            ///ElementsRead: DWORD*
            ///ElementsTotal: DWORD*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpEnumSubnetsV6", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpEnumSubnetsV6([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, ref uint ResumeHandle, uint PreferredMaximum, ref System.IntPtr EnumInfo, ref uint ElementsRead, ref uint ElementsTotal);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///SubnetAddresses: DHCP_IP_ADDRESS->DWORD->unsigned int
            ///EnumElementType: DHCP_SUBNET_ELEMENT_TYPE->_DHCP_SUBNET_ELEMENT_TYPE_V5
            ///ResumeHandle: DHCP_RESUME_HANDLE*
            ///PreferredMaximum: DWORD->unsigned int
            ///EnumElementInfo: LPDHCP_SUBNET_ELEMENT_INFO_ARRAY_V5*
            ///ElementsRead: DWORD*
            ///ElementsTotal: DWORD*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpEnumSubnetElementsV5", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpEnumSubnetElementsV5([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint SubnetAddress, DHCP_SUBNET_ELEMENT_TYPE EnumElementType, ref uint ResumeHandle, uint PreferredMaximum, ref System.IntPtr EnumElementInfo, ref uint ElementsRead, ref uint ElementsTotal);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///SubnetAddresses: DHCP_IP_ADDRESS->DWORD->unsigned int
            ///SubnetInfo: LPDHCP_SUBNET_INFO_VQ*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetSubnetInfoVQ", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpGetSubnetInfoVQ([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint SubnetAddress, ref System.IntPtr SubnetInfo);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///Flags: DWORD->unsigned int
            ///OptionID: DHCP_OPTION_ID->DWORD->unsigned int
            ///ClassName: LPWSTR->WCHAR*
            ///VendorName: LPWSTR->WCHAR*
            ///ScopeInfo: LPDHCP_OPTION_SCOPE_INFO->_DHCP_OPTION_SCOPE_INFO*
            ///OptionValue: LPDHCP_OPTION_VALUE*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetOptionValueV5")]
            public static extern uint DhcpGetOptionValueV5([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint Flags, uint OptionID, [System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ClassName, [System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string VendorName, ref DHCP_OPTION_SCOPE_INFO ScopeInfo, ref System.IntPtr OptionValue);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///SubnetAddresses: DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            ///EnumElementType: DHCP_SUBNET_ELEMENT_TYPE_V6->_DHCP_SUBNET_ELEMENT_TYPE_V6
            ///ResumeHandle: DHCP_RESUME_HANDLE*
            ///PreferredMaximum: DWORD->unsigned int
            ///EnumElementInfo: LPDHCP_SUBNET_ELEMENT_INFO_ARRAY_V6*
            ///ElementsRead: DWORD*
            ///ElementsTotal: DWORD*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpEnumSubnetElementsV6", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpEnumSubnetElementsV6([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, DHCP_IPV6_ADDRESS SubnetAddress, DHCP_SUBNET_ELEMENT_TYPE_V6 EnumElementType, ref uint ResumeHandle, uint PreferredMaximum, ref System.IntPtr EnumElementInfo, ref uint ElementsRead, ref uint ElementsTotal);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///SubnetAddresses: DHCP_IPV6_ADDRESS->_DHCP_IPV6_ADDRESS
            ///SubnetInfo: LPDHCP_SUBNET_INFO_V6*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetSubnetInfoV6", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpGetSubnetInfoV6([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, DHCP_IPV6_ADDRESS SubnetAddress, ref System.IntPtr SubnetInfo);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///Flags: DWORD->unsigned int
            ///OptionID: DHCP_OPTION_ID->DWORD->unsigned int
            ///ClassName: LPWSTR->WCHAR*
            ///VendorName: LPWSTR->WCHAR*
            ///ScopeInfo: LPDHCP_OPTION_SCOPE_INFO6->_DHCP_OPTION_SCOPE_INFO6*
            ///OptionValue: LPDHCP_OPTION_VALUE*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetOptionValueV6")]
            public static extern uint DhcpGetOptionValueV6([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint Flags, uint OptionID, [System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ClassName, [System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string VendorName, ref DHCP_OPTION_SCOPE_INFO6 ScopeInfo, ref System.IntPtr OptionValue);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///Flags: DWORD->unsigned int
	    ///ScopeInfo: LPDHCP_OPTION_SCOPE_INFO6->_DHCP_OPTION_SCOPE_INFO6*
	    ///OptionValues: LPDHCP_ALL_OPTION_VALUES*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetAllOptionValuesV6")]
            public static extern uint DhcpGetAllOptionValuesV6([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint Flags, ref DHCP_OPTION_SCOPE_INFO6 ScopeInfo, ref System.IntPtr Values);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///ConfigInfo: LPDHCP_SERVER_CONFIG_INFO_VQ*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpServerGetConfigVQ", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpServerGetConfigVQ([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, ref System.IntPtr ConfigInfo);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: LPWSTR->WCHAR*
            ///Flags: DWORD->unsigned int
            ///AuditLogDir: LPWSTR*
            ///DiskCheckInterval: DWORD*
            ///MaxLogFilesSize: DWORD*
            ///MinSpaceOnDisk: DWORD*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpAuditLogGetParams")]
            public static extern uint DhcpAuditLogGetParams([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, uint Flags, ref System.IntPtr AuditLogDir, ref uint DiskCheckInterval, ref uint MaxLogFilesSize, ref uint MinSpaceOnDisk);

            /// Return Type: void
            ///BufferPointer: PVOID->void*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpRpcFreeMemory", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern void DhcpRpcFreeMemory(System.IntPtr BufferPointer);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///GlobalFilterInfo: DHCP_FILTER_GLOBAL_INFO*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetFilterV4", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpGetFilterV4([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, [System.Runtime.InteropServices.OutAttribute()] out DHCP_FILTER_GLOBAL_INFO GlobalFilterInfo);


            /// Return Type: DWORD->unsigned int
            ///ServerIpAddress: WCHAR*
            ///ResumeHandle: LPDHCP_ADDR_PATTERN->_DHCP_ADDR_PATTERN*
            ///PreferredMaximum: DWORD->unsigned int
            ///ListType: DHCP_FILTER_LIST_TYPE->_DHCP_FILTER_LIST_TYPE
            ///EnumFilterInfo: LPDHCP_FILTER_ENUM_INFO*
            ///ElementsRead: DWORD*
            ///ElementsTotal: DWORD*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpEnumFilterV4", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpEnumFilterV4([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, ref DHCP_ADDR_PATTERN ResumeHandle, uint PreferredMaximum, DHCP_FILTER_LIST_TYPE ListType, ref System.IntPtr EnumFilterInfo, [System.Runtime.InteropServices.OutAttribute()] out uint ElementsRead, [System.Runtime.InteropServices.OutAttribute()] out uint ElementsTotal);

            /// Return Type: DWORD->unsigned int
            ///ServerIpAddr: LPWSTR->WCHAR*
            ///dwReserved: ULONG->unsigned int
            ///DhcpAttribId: DHCP_ATTRIB_ID->ULONG->unsigned int
            ///pDhcpAttrib: LPDHCP_ATTRIB*
            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpServerQueryAttribute")]
            public static extern uint DhcpServerQueryAttribute([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddr, uint dwReserved, uint DhcpAttribId, ref System.IntPtr pDhcpAttrib);

   	    [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetInit")]
            public static extern int JetInit(ref uint jetInstance);

   	    [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetBeginSession")]
            public static extern int JetBeginSession(uint jetInstance, ref uint jetSession, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPTStr)] string userName, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPTStr)] string password);

  	    [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetAttachDatabase")]
	    public static extern int JetAttachDatabase(uint jetSession, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPStr)] string filename, uint grbit);

            [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetOpenDatabase")]
  	    public static extern int JetOpenDatabase(uint jetSession, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPStr)] string filename, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPStr)] string connect, ref uint dbid, uint grbit);

            [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetCloseDatabase")]
  	    public static extern int JetCloseDatabase(uint jetSession, uint dbid, uint grbit);

 	    [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetDetachDatabase")]
	    public static extern int JetDetachDatabase(uint jetSession, [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPStr)] string filename);

	    [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetEndSession")]
	    public static extern int JetEndSession(uint jetSession, uint grbit);

	    [System.Runtime.InteropServices.DllImportAttribute("esent.dll", EntryPoint = "JetTerm")]
	    public static extern int JetTerm(uint jetInstance);

            [System.Runtime.InteropServices.DllImportAttribute("user32.dll", EntryPoint="LoadStringW")]
            public static extern  int LoadStringW([System.Runtime.InteropServices.InAttribute()] System.IntPtr hInstance, uint uID, [System.Runtime.InteropServices.OutAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] System.Text.StringBuilder lpBuffer, int cchBufferMax) ;

            [System.Runtime.InteropServices.DllImportAttribute("kernel32.dll", EntryPoint="LoadLibraryW")]
            public static extern  System.IntPtr LoadLibraryW([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string lpLibFileName) ;

            [System.Runtime.InteropServices.DllImportAttribute("kernel32.dll", EntryPoint="FreeLibrary")]
            [return: System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.Bool)]
            public static extern  bool FreeLibrary([System.Runtime.InteropServices.InAttribute()] System.IntPtr hLibModule) ;

            [System.Runtime.InteropServices.DllImportAttribute("dhcpsapi.dll", EntryPoint = "DhcpGetVersion", CallingConvention = System.Runtime.InteropServices.CallingConvention.StdCall)]
            public static extern uint DhcpGetVersion([System.Runtime.InteropServices.InAttribute()] [System.Runtime.InteropServices.MarshalAsAttribute(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string ServerIpAddress, ref uint MajorVersion, ref uint MinorVersion);


        }

        /// <summary>
        /// Property to set on server.
        /// </summary>
        [Flags]
        public enum DHCPServerProperties : uint
        {
            /// <summary>
            /// For setting API protocol support field.
            /// </summary>
            Set_APIProtocolSupport = 0x0001,

            /// <summary>
            /// For setting database name field.
            /// </summary>
            Set_DatabaseName = 0x0002,

            /// <summary>
            /// For setting database path field.
            /// </summary>
            Set_DatabasePath = 0x0004,
 
            /// <summary>
            /// For setting backup path field.
            /// </summary>
            Set_BackupPath = 0x0008,

            /// <summary>
            /// For setting backup interval field.
            /// </summary>
            Set_BackupInterval = 0x0010,

            /// <summary>
            /// For enabling or disabling database logging flag.
            /// </summary>
            Set_DatabaseLoggingFlag = 0x0020,

            /// <summary>
            /// For enabling or disabling database restore flag. 
            /// </summary>
            Set_RestoreFlag = 0x0040,

            /// <summary>
            /// For setting database cleanup interval field.
            /// </summary>
            Set_DatabaseCleanupInterval = 0x0080,

            /// <summary>
            /// For setting debug flag.
            /// </summary>
            Set_DebugFlag = 0x0100,

            /// <summary>
            /// For setting no. of conlict detection attempt field.
            /// </summary>
            Set_PingRetries = 0x0200,

            /// <summary>
            /// For setting the boot file table string.
            /// </summary>
            Set_BootFileTable = 0x0400,

            /// <summary>
            /// For enabling or disabling the auditlog state.
            /// </summary>
            Set_AuditLogState = 0x0800,

            /// <summary>
            /// For enabling or disabling the quarantine field.
            /// </summary>
            Set_QuarantineON = 0x1000,

            /// <summary>
            /// For setting the quarantine default field.
            /// </summary>
            Set_QuarantineDefFail = 0x2000
        }

	internal class Utilities
        {
            /// <summary>
            /// Convert the <c>IPAddress</c> object passed to a numeric representation suitable
            /// for passing using the DHCPSAPI.
            /// </summary>
            /// <param name="Address">An <c>IPAddress</c> object.</param>
            /// <returns>Returns the numeric 32-bit representation of the IP address
            /// in a byte order suitable for use in the DHCPSAPI.</returns>
            internal static UInt32 IPV4AddressToUInt32(IPAddress Address)
            {
                if (null == Address)
                {
                    throw new ArgumentNullException("Address");
                }

                if (AddressFamily.InterNetwork != Address.AddressFamily)
                {
                    throw new ArgumentException("Address");
                }

                UInt32 IPV4Address = 0;
                byte[] AddressBytes = Address.GetAddressBytes();
                for (int i = 0; i < sizeof(UInt32); i++)
                {
                    IPV4Address |= (UInt32)AddressBytes[i] << ((sizeof(UInt32) - 1 - i) * 8);
                }

                return IPV4Address;
            }

            /// <summary>
            /// Convert an IPv4 address in numeric notation to an equivalent <c>IPAddress</c>
            /// object.
            /// </summary>
            /// <param name="Address">The IPv4 address as returned by DHCPSAPI</param>
            /// <returns>An <c>IPAddress</c> object equivalent to the passed 32-bit integer.
            /// </returns>
            internal static IPAddress UInt32toIPV4Address(UInt32 Address)
            {
                byte[] AddressBytes = new byte[sizeof(UInt32)];
                for (int i = 0; i < sizeof(UInt32); i++)
                {
                    AddressBytes[i] = (byte)
                        ((Address >> (sizeof(UInt32) - 1 - i) * 8) & 0xff);
                }
                return new IPAddress(AddressBytes);
            }
	    internal static DHCP_IPV6_ADDRESS IPV6AddressToDhcpIPV6Address(IPAddress Address)
	    {
                if (null == Address)
                {
                    throw new ArgumentNullException("Address");
                }

                if (AddressFamily.InterNetworkV6 != Address.AddressFamily)
                {
                    throw new ArgumentException("Address");
                }
		DHCP_IPV6_ADDRESS IPV6Address;

                byte []ipv6HigherBytes = new byte [8];    
                byte []ipv6LowerBytes = new byte [8];

		byte[] AddressBytes = Address.GetAddressBytes();
		for (int j = 0; j < 8; j++)
                {
		    ipv6HigherBytes[7 - j] = AddressBytes[j];
                }  
                for (int j = 0; j < 8; j++)
                {
		    ipv6LowerBytes[7 - j] = AddressBytes[8 + j];
                }
		IPV6Address.HighOrderBits = BitConverter.ToUInt64(ipv6HigherBytes,0);
		IPV6Address.LowOrderBits = BitConverter.ToUInt64(ipv6LowerBytes,0);

		return IPV6Address;                
	    } 
	    internal static IPAddress DhcpIPV6AddresstoIPV6Address(DHCP_IPV6_ADDRESS address)
	    {
                byte[] ipv6Bytes = new byte[16];

                byte []ipv6HigherBytes = BitConverter.GetBytes(address.HighOrderBits);
				
                byte []ipv6LowerBytes = BitConverter.GetBytes(address.LowOrderBits);
                for (int j = 0; j < 8; j++)
                {
                    ipv6Bytes[j] = ipv6HigherBytes[7 - j];
                }
                for (int j = 0; j < 8; j++)
                {
                    ipv6Bytes[8 + j] = ipv6LowerBytes[7 - j];
                }
                IPAddress ipv6Address = new IPAddress(ipv6Bytes);
		return ipv6Address;
	    }
	}
	public class DhcpV4Binding
    	{
            private string name;
	    public string Name
            {
                get { return name; }
            }
            private bool boundToServer;
            public bool BoundToServer
            {
                get { return boundToServer; }
                set { boundToServer = value; }
            }
            private System.Net.IPAddress address;
            public IPAddress Address
            {
                get { return address; }
            }
            private IPAddress subnetAddress;
            public IPAddress SubnetAddress
            {
                get { return subnetAddress; }
            }
            private Guid id;
            public Guid Id
            {
                get { return id; }
            }
            public DhcpV4Binding(uint v4Address, uint subnetAddress, bool boundToServer, string name, Guid id)
            {
                this.address = new IPAddress(BitConverter.GetBytes(v4Address));
                this.subnetAddress = new IPAddress(BitConverter.GetBytes(subnetAddress));
                this.name = name;
                this.boundToServer = boundToServer;
                this.id = id;
            }
        }
        public class DhcpV6Binding
        {
            private bool canBeBoundToDhcp;
            private uint ipV6InterfaceIndex;
            public uint IpV6InterfaceIndex
            {
                get { return ipV6InterfaceIndex; }
            }
            private IPAddress address; 
            public IPAddress Address
            {
                get { return this.address; }
            }
            private bool boundToServer;
            public bool BoundToServer
            {
                get { return this.boundToServer; }
                set { this.boundToServer = value; }
            }
            private Guid id;
            public Guid Id
            {
                get { return this.id; }
            }
            private string name;
            public string Name
            {
                get { return this.name; }
            }
            public DhcpV6Binding(IPAddress ipv6Address, bool boundToServer, string name, Guid id, uint ipv6InterfaceIndex)
            {
                this.address = ipv6Address;
                this.boundToServer = boundToServer;
                this.id = id;
                this.name = name;
                this.ipV6InterfaceIndex = ipv6InterfaceIndex;
            }
        }

        public struct DhcpReservationV4
        {
            private IPAddress reservedIp;
            public IPAddress ReservedIp
            {
                get { return reservedIp; }
                set { reservedIp = value; }
            }
            private string clientUid;
            public string ClientUid
            {
                get { return clientUid; }
                set { clientUid = value; }
            }
            internal DhcpReservationV4(uint reservedIP, string clientUID)
            {
                this.reservedIp = Utilities.UInt32toIPV4Address(reservedIP);
                this.clientUid = clientUID;
            }
        }

        public struct DhcpReservationV6
        {
            private IPAddress reservedIp;
            public IPAddress ReservedIp
            {
                get { return reservedIp; }
                set { reservedIp = value; }
            }
            private string clientUid;
            public string ClientUid
            {
                get { return clientUid; }
                set { clientUid = value; }
            }
            internal DhcpReservationV6(DHCP_IPV6_ADDRESS reservedIP, string clientUID)
            {
                this.reservedIp = Utilities.DhcpIPV6AddresstoIPV6Address(reservedIP);
                this.clientUid = clientUID;
            }
        }

	public struct IPRange
        {
            private IPAddress startAddress; 
            public IPAddress StartAddress
            {
                get { return startAddress; }
                set { startAddress = value; }
            }
            private IPAddress endAddress;
            public IPAddress EndAddress
            {
                get { return endAddress; }
                set { endAddress = value; }
            }
            public override string ToString()
            {
                 return String.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}-{1}", this.startAddress, this.endAddress);
            }
            public IPRange(IPAddress startAddress, IPAddress endAddress)
            {
                this.startAddress = startAddress;
                this.endAddress = endAddress;
            }
            public IPRange(uint startAddress, uint endAddress)
            {
                this.startAddress = Utilities.UInt32toIPV4Address(startAddress);
                this.endAddress = Utilities.UInt32toIPV4Address(endAddress);
            }
        }

	public struct IPRangeV6
        {
            private IPAddress startAddress; 
            public IPAddress StartAddress
            {
                get { return startAddress; }
                set { startAddress = value; }
            }
            private IPAddress endAddress;
            public IPAddress EndAddress
            {
                get { return endAddress; }
                set { endAddress = value; }
            }
            public override string ToString()
            {
                 return String.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}-{1}", this.startAddress, this.endAddress);
            }
            public IPRangeV6(IPAddress startAddress, IPAddress endAddress)
            {
                this.startAddress = startAddress;
                this.endAddress = endAddress;
            }
            public IPRangeV6(DHCP_IPV6_ADDRESS startAddress, DHCP_IPV6_ADDRESS endAddress)
            {
                this.startAddress = Utilities.DhcpIPV6AddresstoIPV6Address(startAddress);
                this.endAddress = Utilities.DhcpIPV6AddresstoIPV6Address(endAddress);
            }
        }

        public enum DhcpOptionType
        {
            UnaryElementOption,
            ArrayOption,
        }

        public struct FilterSettings
        {
            private bool allowList;
            public bool AllowList
            {
                get { return allowList; }
                set { allowList = value; }
            }
            private bool denyList;
            public bool DenyList
            {
                get { return denyList; }
                set { denyList = value; }
            }
	    public FilterSettings(bool allow, bool deny)
	    {
		allowList = allow;
		denyList = deny;
	    }
        }

        public class Filter
        {
            private byte hardwareType;
            public byte HardwareType
            {
                get { return hardwareType; }
                set { hardwareType = value; }
            }
            private bool isWildCard;
            public bool IsWildCard
            {
                get { return isWildCard; }
            }
            private string pattern;
            public string Pattern
            {
                get { return pattern; }
                set { pattern = value; }
            }
            private bool action;
            public bool Action
            {
                get { return action; }
                set { action = value; }
            }
            public Filter(bool action, byte hardwareType, string pattern, bool isWildcard)
            {
		this.action = action;
		this.hardwareType = hardwareType;
                this.pattern = pattern;
		this.isWildCard = isWildcard;
            }
        }

        public class OptionValue
        {
            private uint optionId;
            public uint OptionId
            {
                get { return optionId; }
                set { optionId = value; }
            }
            private object[] value;
            public object[] Value
            {
                get { return this.value; }
                set { this.value = value; }
            }
            private DHCP_OPTION_DATA_TYPE optionDataType;
            public DHCP_OPTION_DATA_TYPE OptionDataType
            {
                get { return optionDataType; }
                set { optionDataType = value; }
            }
            public OptionValue(uint id, DHCP_OPTION_DATA_TYPE dataType, params object[] value)
            {
                this.optionId = id;
                this.optionDataType = dataType;
                this.value = value;
            }
        }

        public class ScopeV4
        {
            private string serverName;
            private IPAddress serverIPAddress;

            private string name;        
            public string Name
            {
                get { return this.name; }
                set { this.name = value; }
            }
            private string comment;  
            public string Comment
            {
                get { return this.comment; }
                set { this.comment = value; }
            }

            private IPAddress address;
            public IPAddress Address
            {
                get { return this.address; }
            }

            private IPAddress subnetMask;
            public IPAddress SubnetMask
            {
                get { return subnetMask; }
            }

	    private DHCP_SUBNET_STATE state;
            public DHCP_SUBNET_STATE State
            {
                get { return this.state; }
            }

            private IPRange range;
            public IPRange Range
            {
                get { return this.range; }
            }

            private uint quarantineOn;
            public uint QuarantineOn
            {
                get { return quarantineOn; }
                set { this.quarantineOn = value; }
            }

            public OptionValue GetOptionValue(uint optionId)
            {
		return ScopeWrapper.GetOptionValueV4(this.serverName, optionId, this.address);
            }

            public object[] EnumerateReservations()
            {
                return ScopeWrapper.EnumerateSubnetElements(this.serverName, this.address, DHCP_SUBNET_ELEMENT_TYPE.DhcpReservedIps);
            }

            public object[] EnumerateExclusions()
            {
                return ScopeWrapper.EnumerateSubnetElements(this.serverName, this.address, DHCP_SUBNET_ELEMENT_TYPE.DhcpExcludedIpRanges);
            }

            internal ScopeV4(DhcpServer server, uint subnetAddress, uint subnetMask, string subnetName, string subnetComment, DHCP_SUBNET_STATE subnetState, uint quarantineOn)
            {
                this.serverIPAddress = server.Address;
                this.serverName = server.Name;
                this.name = subnetName;
                this.address = Utilities.UInt32toIPV4Address(subnetAddress);
				
                this.subnetMask = Utilities.UInt32toIPV4Address(subnetMask);
                this.comment = subnetComment;
		this.state = subnetState;
                this.quarantineOn = quarantineOn;
		Object[] scopeiprange = ScopeWrapper.EnumerateSubnetElements(server.Name, this.address, DHCP_SUBNET_ELEMENT_TYPE.DhcpIpRanges);
		if(scopeiprange.Length != 0)
		{
   		    this.range = (IPRange)scopeiprange[0];	
		}
		else
		{
	  	    this.range = new IPRange(0,0);
		}
				
            }
	}

        public class ScopeV6
        {
            private string serverName;
            private IPAddress serverIPAddress;

            private string name;        
            public string Name
            {
                get { return this.name; }
                set { this.name = value; }
            }

            private string comment;  
            public string Comment
            {
                get { return this.comment; }
                set { this.comment = value; }
            }

            private IPAddress address;
            public IPAddress Address
            {
                get { return this.address; }
            }

	    private uint prefix;
            public uint Prefix
            {
                get { return prefix; }
            }

	    private ushort preference;
            public ushort Preference
            {
                get { return preference; }
            }

	    private uint state;
            public uint State
            {
                get { return this.state; }
            }

            public OptionValue GetOptionValue(uint optionId)
            {
		return ScopeWrapper.GetOptionValueV6(this.serverName, optionId, this.address);
            }

            public object[] EnumerateReservations()
            {
                return ScopeWrapper.EnumerateSubnetElementsV6(this.serverName, this.address, DHCP_SUBNET_ELEMENT_TYPE_V6.Dhcpv6ReservedIps);
            }

            public object[] EnumerateExclusions()
            {
                return ScopeWrapper.EnumerateSubnetElementsV6(this.serverName, this.address, DHCP_SUBNET_ELEMENT_TYPE_V6.Dhcpv6ExcludedIpRanges);
            }

            internal ScopeV6(DhcpServer server, DHCP_IPV6_ADDRESS subnetAddress, uint prefix, string subnetName, string subnetComment, uint subnetState, ushort preference)
            {
                this.serverIPAddress = server.Address;
                this.serverName = server.Name;
                this.name = subnetName;
                this.address = Utilities.DhcpIPV6AddresstoIPV6Address(subnetAddress);
                this.comment = subnetComment;
		this.state = subnetState;
                this.prefix = prefix;
                this.preference = preference;
            }
	}

	public class ServerConfiguration
        {

            private string databasePath;
            public string DatabasePath
            {
                get { return databasePath; }
                set { databasePath = value; }
            }

            private string databaseName;
            public string DatabaseName
            {
                get { return databaseName; }
                set { databaseName = value; }
            }

            private string backupPath;
            public string BackupPath
            {
                get { return backupPath; }
                set { backupPath = value; }
            }

            private string auditLogDirectory; 
            public string AuditLogDirectory
            {
                get { return auditLogDirectory; }
                set { auditLogDirectory = value; }
            }

            private bool auditLogState;
            public bool AuditLogState
            {
                get { return auditLogState; }
                set { auditLogState = value; }
            }

            private uint pingRetries;
            public uint PingRetries
            {
                get { return pingRetries; }
                set { pingRetries = value; }
            }

            public object this[DHCPServerProperties index]
            {
                set 
                {
                    switch (index)
                    {

                        case DHCPServerProperties.Set_DatabaseName: this.databaseName = value.ToString();
                            break;
  
                        case DHCPServerProperties.Set_DatabasePath: this.databasePath = value.ToString();
                            break;

			case DHCPServerProperties.Set_BackupPath: this.backupPath = value.ToString();
                            break;

	                case DHCPServerProperties.Set_AuditLogState: this.auditLogState = Convert.ToBoolean(value);
                            break;

                        case DHCPServerProperties.Set_PingRetries: this.pingRetries = Convert.ToUInt32(value);
                            break;

                        default:
                            break;
                    }
                }
                get
                { 
                    switch (index)
                    {

                        case DHCPServerProperties.Set_DatabaseName:
                            return this.databaseName;
 
                        case DHCPServerProperties.Set_DatabasePath:
                            return this.databasePath;

			case DHCPServerProperties.Set_BackupPath:
                            return this.backupPath;

 	                case DHCPServerProperties.Set_AuditLogState: 
                            return this.auditLogState;

                        case DHCPServerProperties.Set_PingRetries:
                            return this.pingRetries;

                        default:
                            return 0;
                    }
                }
            }

            internal ServerConfiguration(string databasename, string databasepath, string backuppath, string auditlogdir, int auditLogState, byte pingRetries)
            {
		this.backupPath = backuppath;
            	this.databasePath = databasepath;
		this.databaseName = databasename;
            	this.auditLogDirectory = auditlogdir;
                this.auditLogState = Convert.ToBoolean(auditLogState);
                this.pingRetries = pingRetries;
            }

        }

	public class JetIds
	{
   	    private uint jetId;
	    public uint JetId 
	    {
  		get { return jetId; }
		set { jetId = value; }
	    }

	    private int jetError;
	    public int JetError 
	    {
		get { return jetError; }
		set { jetError = value; }
	    }

	    public JetIds(uint jetId, int error)
	    {
		this.JetId = jetId;
		this.JetError = error;
	    }
	}

	public class ScopeWrapper
	{
            internal static object[] EnumerateSubnetElements(string serverNameOrIpAddress, IPAddress subnetAddress, DHCP_SUBNET_ELEMENT_TYPE elementType)
            {
                IntPtr enumElementInfo = new IntPtr();
                uint resumeHandle = 0, elementsRead = 0, elementsTotal = 0, error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
                List<object> returnElement = new List<object>();
                do
                {
 		    error = NativeMethods.DhcpEnumSubnetElementsV5(serverNameOrIpAddress, Utilities.IPV4AddressToUInt32(subnetAddress), elementType, ref resumeHandle, UInt32.MaxValue, ref enumElementInfo, ref elementsRead, ref elementsTotal);
                    if ((uint)DHCPErrors.DHCPError.ERROR_NO_MORE_ITEMS == error)
                    {
		        break;
                    }
 
                    if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error && error != (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA)
                    {
			throw new DHCPException(error);
                    }

                    DHCP_SUBNET_ELEMENT_INFO_ARRAY_V5 elementInfoArray = (DHCP_SUBNET_ELEMENT_INFO_ARRAY_V5)Marshal.PtrToStructure(enumElementInfo, typeof(DHCP_SUBNET_ELEMENT_INFO_ARRAY_V5));
                    IntPtr enumElements = elementInfoArray.Elements;
                    for (int i = 0; i < elementInfoArray.NumElements; i++)
                    {
                        DHCP_SUBNET_ELEMENT_DATA_V5 elementData = (DHCP_SUBNET_ELEMENT_DATA_V5)Marshal.PtrToStructure(enumElements, typeof(DHCP_SUBNET_ELEMENT_DATA_V5));
                        if (elementType == elementData.ElementType)
                        {
                            if (elementType == DHCP_SUBNET_ELEMENT_TYPE.DhcpIpRanges)
                            {
                                IntPtr data = elementData.Union1.IpRange;
				DHCP_BOOTP_IP_RANGE ipRange = (DHCP_BOOTP_IP_RANGE)Marshal.PtrToStructure(data, typeof(DHCP_BOOTP_IP_RANGE));
                                IPRange range = new IPRange(ipRange.StartAddress, ipRange.EndAddress);
                                returnElement.Add(range);
				Marshal.DestroyStructure(data, typeof(DHCP_BOOTP_IP_RANGE));
                            }
                            else if (DHCP_SUBNET_ELEMENT_TYPE.DhcpExcludedIpRanges == elementType)
                            {
                                IntPtr data = elementData.Union1.ExcludeIpRange;
                                DHCP_IP_RANGE excludedIPRange = (DHCP_IP_RANGE)Marshal.PtrToStructure(data, typeof(DHCP_IP_RANGE));
                                IPRange range = new IPRange(excludedIPRange.StartAddress, excludedIPRange.EndAddress);
                                returnElement.Add(range);
				Marshal.DestroyStructure(data, typeof(DHCP_IP_RANGE));
                            } 
                            else if (DHCP_SUBNET_ELEMENT_TYPE.DhcpReservedIps == elementType)
                            {
                                IntPtr data = elementData.Union1.ReservedIp;
                                DHCP_IP_RESERVATION_V4 reservedIP = (DHCP_IP_RESERVATION_V4)Marshal.PtrToStructure(data, typeof(DHCP_IP_RESERVATION_V4));
                                DHCP_BINARY_DATA binaryData = (DHCP_BINARY_DATA)Marshal.PtrToStructure(reservedIP.ReservedForClient, typeof(DHCP_BINARY_DATA));
                                byte[] hexBytes = new byte[binaryData.DataLength];
                                for (int j = 0; j < binaryData.DataLength; j++)
                                {
                                    hexBytes[j] = Marshal.ReadByte(binaryData.Data, j);
                                }

                                string clientUID = BitConverter.ToString(hexBytes);
                                DhcpReservationV4 reservation = new DhcpReservationV4(reservedIP.ReservedIpAddress, clientUID);
                                returnElement.Add(reservation);
				Marshal.DestroyStructure(reservedIP.ReservedForClient, typeof(DHCP_BINARY_DATA));
				Marshal.DestroyStructure(data, typeof(DHCP_IP_RESERVATION_V4));
                            }
                        }
			Marshal.DestroyStructure(enumElements , typeof(DHCP_SUBNET_ELEMENT_DATA_V5));
                        enumElements = (IntPtr)(enumElements + Marshal.SizeOf(typeof(DHCP_SUBNET_ELEMENT_DATA_V5)));
                    }
		    Marshal.DestroyStructure(enumElementInfo, typeof(DHCP_SUBNET_ELEMENT_INFO_ARRAY_V5));
		    enumElementInfo = IntPtr.Zero;
                } while (error == (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA);
	
                return returnElement.ToArray();
            }

            internal static OptionValue GetOptionValueV4(string serverNameOrIpAddress, uint optionId, IPAddress subnetAddress)
            {
                OptionValue value = null;
                DHCP_OPTION_SCOPE_INFO scopeInfo = new DHCP_OPTION_SCOPE_INFO();
                
		if(subnetAddress != null)
		{	
  		    scopeInfo.ScopeType = DHCP_OPTION_SCOPE_TYPE.DhcpSubnetOptions;
                    scopeInfo.Union1.SubnetScopeInfo = Utilities.IPV4AddressToUInt32(subnetAddress);
		}
		else
		{
		    scopeInfo.ScopeType = DHCP_OPTION_SCOPE_TYPE.DhcpGlobalOptions;
		}

                IntPtr optionValue = new IntPtr();
            
                uint error = NativeMethods.DhcpGetOptionValueV5(serverNameOrIpAddress, 0, optionId, null, null, ref scopeInfo, ref optionValue);
		if ((uint)DHCPErrors.DHCPError.ERROR_FILE_NOT_FOUND == error)
		{
		    return value;
		}
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
		    throw new DHCPException(error);
                }

                DHCP_OPTION_VALUE optValue = (DHCP_OPTION_VALUE)Marshal.PtrToStructure(optionValue, typeof(DHCP_OPTION_VALUE));
                IntPtr elements = optValue.Value.Elements;
                List<object> optValueElements = new List<object>(Convert.ToInt32(optValue.Value.NumElements));
                DHCP_OPTION_DATA_TYPE optionType;
                for (int i = 0; i < optValue.Value.NumElements; i++)
                {
                    DHCP_OPTION_DATA_ELEMENT optionDataElement = (DHCP_OPTION_DATA_ELEMENT)Marshal.PtrToStructure(elements, typeof(DHCP_OPTION_DATA_ELEMENT));
                    optionType = optionDataElement.OptionType;
                    switch (optionDataElement.OptionType)
                    {
                        case DHCP_OPTION_DATA_TYPE.DhcpBinaryDataOption:
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpByteOption:
                            optValueElements.Add(optionDataElement.Union1.ByteOption);
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpDWordDWordOption:
                            UInt64 data = ((ulong)optionDataElement.Union1.DWordDWordOption.DWord1 << 32) + optionDataElement.Union1.DWordDWordOption.DWord2;
                            optValueElements.Add(data);
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpDWordOption:
                            optValueElements.Add(optionDataElement.Union1.DWordOption);
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpEncapsulatedDataOption:
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpIpAddressOption:
                            optValueElements.Add(Utilities.UInt32toIPV4Address(optionDataElement.Union1.IpAddressOption));
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpIpv6AddressOption:
			    optValueElements.Add(Marshal.PtrToStringAuto(optionDataElement.Union1.Ipv6AddressDataOption));
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpStringDataOption:
                            optValueElements.Add(Marshal.PtrToStringAuto(optionDataElement.Union1.StringDataOption));
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpWordOption:
                            optValueElements.Add(optionDataElement.Union1.WordOption);
                            break;
                    }
		    Marshal.DestroyStructure(elements, typeof(DHCP_OPTION_DATA_ELEMENT));
                    if (i == optValue.Value.NumElements - 1)
                    {
                        value = new OptionValue(optionId, optionType, optValueElements.ToArray());
                    }
                    else
                    {
                        elements = (IntPtr)(elements + Marshal.SizeOf(typeof(DHCP_OPTION_DATA_ELEMENT)));
                    }
                }
            	Marshal.DestroyStructure(optionValue, typeof(DHCP_OPTION_VALUE));
                return value;
            }

            internal static object[] EnumerateSubnetElementsV6(string serverNameOrIpAddress, IPAddress subnetAddress, DHCP_SUBNET_ELEMENT_TYPE_V6 elementType)
            {
                IntPtr enumElementInfo = new IntPtr();
                uint resumeHandle = 0, elementsRead = 0, elementsTotal = 0, error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
                List<object> returnElement = new List<object>();

                do
                {
                    error = NativeMethods.DhcpEnumSubnetElementsV6(serverNameOrIpAddress, Utilities.IPV6AddressToDhcpIPV6Address(subnetAddress), elementType, ref resumeHandle, UInt32.MaxValue, ref enumElementInfo, ref elementsRead, ref elementsTotal);
                    if ((uint)DHCPErrors.DHCPError.ERROR_NO_MORE_ITEMS == error)
                    {
                        break;
                    }
 
                    if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error && error != (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA)
                    {
                        throw new DHCPException(error);
                    }

                    DHCP_SUBNET_ELEMENT_INFO_ARRAY_V6 elementInfoArray = (DHCP_SUBNET_ELEMENT_INFO_ARRAY_V6)Marshal.PtrToStructure(enumElementInfo, typeof(DHCP_SUBNET_ELEMENT_INFO_ARRAY_V6));
                    IntPtr enumElements = elementInfoArray.Elements;
                    for (int i = 0; i < elementInfoArray.NumElements; i++)
                    {
                        DHCP_SUBNET_ELEMENT_DATA_V6 elementData = (DHCP_SUBNET_ELEMENT_DATA_V6)Marshal.PtrToStructure(enumElements, typeof(DHCP_SUBNET_ELEMENT_DATA_V6));
                        if (elementType == elementData.ElementType)
                        {
                            if (elementType == DHCP_SUBNET_ELEMENT_TYPE_V6.Dhcpv6IpRanges)
                            {
                                IntPtr data = elementData.Union1.IpRange;
                                DHCP_IP_RANGE_V6 ipRange = (DHCP_IP_RANGE_V6)Marshal.PtrToStructure(data, typeof(DHCP_IP_RANGE_V6));
                                IPRangeV6 range = new IPRangeV6(ipRange.StartAddress, ipRange.EndAddress);
                                returnElement.Add(range);
				Marshal.DestroyStructure(data , typeof(DHCP_IP_RANGE_V6));
                            }
                            else if (DHCP_SUBNET_ELEMENT_TYPE_V6.Dhcpv6ExcludedIpRanges == elementType)
                            {
                                IntPtr data = elementData.Union1.ExcludeIpRange;
                                DHCP_IP_RANGE_V6 excludedIPRange = (DHCP_IP_RANGE_V6)Marshal.PtrToStructure(data, typeof(DHCP_IP_RANGE_V6));
                                IPRangeV6 range = new IPRangeV6(excludedIPRange.StartAddress, excludedIPRange.EndAddress);
                                returnElement.Add(range);
				Marshal.DestroyStructure(data , typeof(DHCP_IP_RANGE_V6));
                            } 
                            else if (DHCP_SUBNET_ELEMENT_TYPE_V6.Dhcpv6ReservedIps == elementType)
                            {
                                IntPtr data = elementData.Union1.ReservedIp;
                                DHCP_IP_RESERVATION_V6 reservedIP = (DHCP_IP_RESERVATION_V6)Marshal.PtrToStructure(data, typeof(DHCP_IP_RESERVATION_V6));
                                DHCP_BINARY_DATA binaryData = (DHCP_BINARY_DATA)Marshal.PtrToStructure(reservedIP.ReservedForClient, typeof(DHCP_BINARY_DATA));
                                byte[] hexBytes = new byte[binaryData.DataLength];
                                for (int j = 0; j < binaryData.DataLength; j++)
                                {
                                    hexBytes[j] = Marshal.ReadByte(binaryData.Data, j);
                                }

                                string clientUID = BitConverter.ToString(hexBytes);
                                DhcpReservationV6 reservation = new DhcpReservationV6(reservedIP.ReservedIpAddress, clientUID);
                                returnElement.Add(reservation);
				Marshal.DestroyStructure(reservedIP.ReservedForClient , typeof(DHCP_BINARY_DATA));
				Marshal.DestroyStructure(data , typeof(DHCP_IP_RESERVATION_V6));
                            }
                        }
			Marshal.DestroyStructure(enumElements , typeof(DHCP_SUBNET_ELEMENT_DATA_V6));
                        enumElements = (IntPtr)(enumElements + Marshal.SizeOf(typeof(DHCP_SUBNET_ELEMENT_DATA_V6)));
                    }
		    Marshal.DestroyStructure(enumElementInfo, typeof(DHCP_SUBNET_ELEMENT_INFO_ARRAY_V6));
		    enumElementInfo = IntPtr.Zero;
                } while (error == (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA);

                return returnElement.ToArray();
            }

            internal static OptionValue GetOptionValueV6(string serverNameOrIpAddress, uint optionId, IPAddress subnetAddress)
            {
                OptionValue value = null;
                DHCP_OPTION_SCOPE_INFO6 scopeInfo = new DHCP_OPTION_SCOPE_INFO6();

		if(subnetAddress != null)
		{	
		    scopeInfo.ScopeType = DHCP_OPTION_SCOPE_TYPE6.DhcpScopeOptions6;
	            scopeInfo.Union1.SubnetScopeInfo = Utilities.IPV6AddressToDhcpIPV6Address(subnetAddress);
		}
		else
		{
		    scopeInfo.ScopeType = DHCP_OPTION_SCOPE_TYPE6.DhcpGlobalOptions6;
		}
                IntPtr optionValue = new IntPtr();
            
                uint error = NativeMethods.DhcpGetOptionValueV6(serverNameOrIpAddress, 0, optionId, null, null, ref scopeInfo, ref optionValue);
		if ((uint)DHCPErrors.DHCPError.ERROR_FILE_NOT_FOUND == error)
		{
		    return value;
		}
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }

                DHCP_OPTION_VALUE optValue = (DHCP_OPTION_VALUE)Marshal.PtrToStructure(optionValue, typeof(DHCP_OPTION_VALUE));
                IntPtr elements = optValue.Value.Elements;
                List<object> optValueElements = new List<object>(Convert.ToInt32(optValue.Value.NumElements));
                DHCP_OPTION_DATA_TYPE optionType;
                for (int i = 0; i < optValue.Value.NumElements; i++)
                {
                    DHCP_OPTION_DATA_ELEMENT optionDataElement = (DHCP_OPTION_DATA_ELEMENT)Marshal.PtrToStructure(elements, typeof(DHCP_OPTION_DATA_ELEMENT));
                    optionType = optionDataElement.OptionType;
                    switch (optionDataElement.OptionType)
                    {
                        case DHCP_OPTION_DATA_TYPE.DhcpBinaryDataOption:
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpByteOption:
                            optValueElements.Add(optionDataElement.Union1.ByteOption);
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpDWordDWordOption:
                            UInt64 data = ((ulong)optionDataElement.Union1.DWordDWordOption.DWord1 << 32) + optionDataElement.Union1.DWordDWordOption.DWord2;
                            optValueElements.Add(data);
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpDWordOption:
                            optValueElements.Add(optionDataElement.Union1.DWordOption);
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpEncapsulatedDataOption:
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpIpAddressOption:
                            optValueElements.Add(Utilities.UInt32toIPV4Address(optionDataElement.Union1.IpAddressOption));
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpIpv6AddressOption:							
 			    optValueElements.Add(Marshal.PtrToStringAuto(optionDataElement.Union1.Ipv6AddressDataOption));
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpStringDataOption:
                            optValueElements.Add(Marshal.PtrToStringAuto(optionDataElement.Union1.StringDataOption));
                            break;
                        case DHCP_OPTION_DATA_TYPE.DhcpWordOption:
                            optValueElements.Add(optionDataElement.Union1.WordOption);
                            break;
                    }
		    Marshal.DestroyStructure(elements, typeof(DHCP_OPTION_DATA_ELEMENT));
                    if (i == optValue.Value.NumElements - 1)
                    {
                        value = new OptionValue(optionId, optionType, optValueElements.ToArray());
                    }
                    else
                    {
                        elements = (IntPtr)(elements + Marshal.SizeOf(typeof(DHCP_OPTION_DATA_ELEMENT)));
                    }
		
                }
            	Marshal.DestroyStructure(optionValue, typeof(DHCP_OPTION_VALUE));
                return value;
            }

	}
        public class ServerWrapper
        {
            internal static DhcpV4Binding[] GetServerBindingsV4(string serverNameOrIPAddress)
            {
                IntPtr bindingInfo = new IntPtr();
                uint error = NativeMethods.DhcpGetServerBindingInfo(serverNameOrIPAddress, 0, ref bindingInfo);
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
		    throw new DHCPException(error);
				
                }

                DHCP_BIND_ELEMENT_ARRAY bindElementArray = (DHCP_BIND_ELEMENT_ARRAY)Marshal.PtrToStructure(bindingInfo, typeof(DHCP_BIND_ELEMENT_ARRAY));
                IntPtr bindElements = bindElementArray.Elements;
                ArrayList dhcpBindings = new ArrayList(Convert.ToInt32(bindElementArray.NumElements));
                for (int i = 0; i < bindElementArray.NumElements; i++)
                {
                    DHCP_BIND_ELEMENT element = (DHCP_BIND_ELEMENT)Marshal.PtrToStructure(bindElements, typeof(DHCP_BIND_ELEMENT));
                    byte []hexBytes = new byte[element.IfIdSize];
                    for (int j = 0; j < element.IfIdSize; j++)
                    {
                        hexBytes[j] = Marshal.ReadByte(element.IfId, j);
                    }

                    Guid interfaceGuid = new Guid(hexBytes);
                    DhcpV4Binding binding = new DhcpV4Binding(element.AdapterPrimaryAddress, element.AdapterSubnetAddress, element.fBoundToDHCPServer, element.IfDescription, interfaceGuid);
                    dhcpBindings.Add(binding);

		    Marshal.DestroyStructure(bindElements, typeof(DHCP_BIND_ELEMENT));
                    bindElements = (IntPtr)(bindElements + Marshal.SizeOf(typeof(DHCP_BIND_ELEMENT)));
                }
		Marshal.DestroyStructure(bindingInfo, typeof(DHCP_BIND_ELEMENT_ARRAY));
                return (DhcpV4Binding[])dhcpBindings.ToArray(typeof(DhcpV4Binding));
            }

	    internal static DhcpV6Binding[] GetServerBindingsV6(string serverNameOrIPAddress)
            {
                IntPtr bindingInfo = new IntPtr();
                uint error = NativeMethods.DhcpGetServerBindingInfoV6(serverNameOrIPAddress, 0, ref bindingInfo);
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }

                DHCPV6_BIND_ELEMENT_ARRAY bindElementArray = (DHCPV6_BIND_ELEMENT_ARRAY)Marshal.PtrToStructure(bindingInfo, typeof(DHCPV6_BIND_ELEMENT_ARRAY));
                IntPtr bindElements = bindElementArray.Elements;
                ArrayList dhcpBindings = new ArrayList(Convert.ToInt32(bindElementArray.NumElements));
                for (int i = 0; i < bindElementArray.NumElements; i++)
                {
                    DHCPV6_BIND_ELEMENT element = (DHCPV6_BIND_ELEMENT)Marshal.PtrToStructure(bindElements, typeof(DHCPV6_BIND_ELEMENT));
                    string hexString = Marshal.PtrToStringAnsi(element.IfId);
                    byte[] ipv6Bytes = new byte[16];
                    byte []ipv6HigherBytes = BitConverter.GetBytes(element.AdapterPrimaryAddress.HighOrderBits);
                    byte []ipv6LowerBytes = BitConverter.GetBytes(element.AdapterPrimaryAddress.LowOrderBits);

                    for (int j = 0; j < 8; j++)
                    {
                        ipv6Bytes[j] = ipv6HigherBytes[7 - j];
                    }
                    for (int j = 0; j < 8; j++)
                    {
                        ipv6Bytes[8 + j] = ipv6LowerBytes[7 - j];
                    }
                    Guid interfaceGuid = new Guid(hexString);
                    IPAddress ipv6Address = new IPAddress(ipv6Bytes);
                    DhcpV6Binding binding = new DhcpV6Binding(ipv6Address, element.fBoundToDHCPServer, element.IfDescription, interfaceGuid, element.IpV6IfIndex);
                    dhcpBindings.Add(binding);

		    Marshal.DestroyStructure(bindElements, typeof(DHCPV6_BIND_ELEMENT));
                    bindElements = (IntPtr)(bindElements + Marshal.SizeOf(typeof(DHCPV6_BIND_ELEMENT)));
                }
		Marshal.DestroyStructure(bindingInfo, typeof(DHCPV6_BIND_ELEMENT_ARRAY));
                return (DhcpV6Binding[])dhcpBindings.ToArray(typeof(DhcpV6Binding));
            }

            internal static ScopeV4[] EnumV4Subnets(DhcpServer server)
            {
                uint error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
                uint resumeHandle = 0;
                IntPtr enumInfo = new IntPtr();
                uint elementsRead, elementsTotal;
                List<ScopeV4> scopeList = new List<ScopeV4>();

                do
                {
                    error = NativeMethods.DhcpEnumSubnets(server.Name, ref resumeHandle, UInt32.MaxValue, ref enumInfo, out elementsRead, out elementsTotal);
                    if ((uint)DHCPErrors.DHCPError.ERROR_NO_MORE_ITEMS == error)
                    {
                        break;
                    }
                    if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error && error != (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA)
                    {
			throw new DHCPException(error);
                    }

                    DHCP_IP_ARRAY dhcpIPArray = (DHCP_IP_ARRAY)Marshal.PtrToStructure(enumInfo, typeof(DHCP_IP_ARRAY));
                    uint numElements = dhcpIPArray.NumElements;
                    IntPtr ptr = dhcpIPArray.Elements;
                    for (int i = 0; i < numElements; i++)
                    {
                        IntPtr subnetInfo = new IntPtr();
                        UInt32 ipAddress = (UInt32)Marshal.PtrToStructure(ptr, typeof(UInt32));
	                error = NativeMethods.DhcpGetSubnetInfoVQ(server.Name, ipAddress, ref subnetInfo);
	                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                        {
	                    throw new DHCPException(error);
                        }
						
                        DHCP_SUBNET_INFO_VQ dhcpSubnetInfo = (DHCP_SUBNET_INFO_VQ)Marshal.PtrToStructure(subnetInfo, typeof(DHCP_SUBNET_INFO_VQ));
			scopeList.Add(new ScopeV4(server, dhcpSubnetInfo.SubnetAddress, dhcpSubnetInfo.SubnetMask, dhcpSubnetInfo.SubnetName, dhcpSubnetInfo.SubnetComment, dhcpSubnetInfo.SubnetState, dhcpSubnetInfo.QuarantineOn));
						
			Marshal.DestroyStructure(subnetInfo , typeof(DHCP_SUBNET_INFO_VQ));
			Marshal.DestroyStructure(ptr, typeof(UInt32));
                        ptr = (IntPtr)(ptr + Marshal.SizeOf(typeof(UInt32)));
						
                    }
	   	    Marshal.DestroyStructure(enumInfo, typeof(DHCP_IP_ARRAY));	
		    enumInfo = IntPtr.Zero;
                } while (error == (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA);
                return scopeList.ToArray();
            }
 	    internal static uint GetOptionListCountV6(DhcpServer server)
	    {
		uint error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
		uint numOptions = 0;
		DHCP_OPTION_SCOPE_INFO6 scopeInfo = new DHCP_OPTION_SCOPE_INFO6();
		scopeInfo.ScopeType = DHCP_OPTION_SCOPE_TYPE6.DhcpDefaultOptions6;
		IntPtr optionValues = new IntPtr();
		error = NativeMethods.DhcpGetAllOptionValuesV6(server.Name, NativeConstants.DHCP_OPT_ENUM_IGNORE_VENDOR, ref scopeInfo, ref optionValues);
		if ((uint)DHCPErrors.DHCPError.ERROR_FILE_NOT_FOUND == error)
		{
		    return 0;
		}

                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }
		if(optionValues == IntPtr.Zero)
		{
		    return 0;
		}
		DHCP_ALL_OPTION_VALUES Options = (DHCP_ALL_OPTION_VALUES)Marshal.PtrToStructure(optionValues, typeof(DHCP_ALL_OPTION_VALUES));
		if(Options.Array == IntPtr.Zero)
		{
			return 0;	
		}
		Anomynous_Dhcp_All_Option_Values_Structure anonStr = (Anomynous_Dhcp_All_Option_Values_Structure)Marshal.PtrToStructure(Options.Array, typeof(Anomynous_Dhcp_All_Option_Values_Structure));
		if(anonStr.OptionsArray == IntPtr.Zero)
		{
		    return 0;
		}
		DHCP_OPTION_VALUE_ARRAY optionArray = (DHCP_OPTION_VALUE_ARRAY)Marshal.PtrToStructure(anonStr.OptionsArray, typeof(DHCP_OPTION_VALUE_ARRAY));

		numOptions = optionArray.NumElements;
		IntPtr values = optionArray.Values;
		if(values != IntPtr.Zero)
		{		
		    for(int i = 0; i < numOptions; i++)
		    {
                        DHCP_OPTION_VALUE optValue = (DHCP_OPTION_VALUE)Marshal.PtrToStructure(values, typeof(DHCP_OPTION_VALUE));
                        if (i != numOptions-1)
                        {
			    values = (IntPtr)(values + Marshal.SizeOf(typeof(DHCP_OPTION_VALUE)));
                        }
         	        Marshal.DestroyStructure(values, typeof(DHCP_OPTION_VALUE));		    
		    }
		}
		Marshal.DestroyStructure(anonStr.OptionsArray, typeof(DHCP_OPTION_VALUE_ARRAY));
		Marshal.DestroyStructure(Options.Array, typeof(Anomynous_Dhcp_All_Option_Values_Structure));
		Marshal.DestroyStructure(optionValues, typeof(DHCP_ALL_OPTION_VALUES));
		return numOptions;
	    }
            internal static ScopeV6[] EnumV6Subnets(DhcpServer server)
            {
                uint error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
                uint resumeHandle = 0;
                IntPtr enumInfo = new IntPtr();
                uint elementsRead = 0, elementsTotal = 0;
                List<ScopeV6> scopeList = new List<ScopeV6>();
                do
                {
                    error = NativeMethods.DhcpEnumSubnetsV6(server.Name, ref resumeHandle, UInt32.MaxValue, ref enumInfo, ref elementsRead, ref elementsTotal);

                    if ((uint)DHCPErrors.DHCPError.ERROR_NO_MORE_ITEMS == error) 
                    {
                        break;
                    }
       		    if (error != (uint)DHCPErrors.DHCPError.ERROR_SUCCESS && error != (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA)
                    {
                        throw new DHCPException(error);
                    }

                    DHCPV6_IP_ARRAY dhcpIPArray = (DHCPV6_IP_ARRAY)Marshal.PtrToStructure(enumInfo, typeof(DHCPV6_IP_ARRAY));
                    uint numElements = dhcpIPArray.NumElements;
                    IntPtr ptr = dhcpIPArray.Elements;
                    
                    for (int i = 0; i < numElements; i++)
                    {
                        IntPtr subnetInfo = new IntPtr();
                        DHCP_IPV6_ADDRESS ipAddress = (DHCP_IPV6_ADDRESS)Marshal.PtrToStructure(ptr, typeof(DHCP_IPV6_ADDRESS));
                        error = NativeMethods.DhcpGetSubnetInfoV6(server.Name, ipAddress, ref subnetInfo);
                        if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                        {
                            throw new DHCPException(error);
                        }
                        DHCP_SUBNET_INFO_V6 dhcpSubnetInfo = (DHCP_SUBNET_INFO_V6)Marshal.PtrToStructure(subnetInfo, typeof(DHCP_SUBNET_INFO_V6));
                        scopeList.Add(new ScopeV6(server, dhcpSubnetInfo.SubnetAddress, dhcpSubnetInfo.Prefix, dhcpSubnetInfo.SubnetName, dhcpSubnetInfo.SubnetComment, dhcpSubnetInfo.State, dhcpSubnetInfo.Preference));
   
			Marshal.DestroyStructure(ptr, typeof(DHCP_IPV6_ADDRESS));   
                        ptr = (IntPtr)(ptr + Marshal.SizeOf(typeof(DHCP_IPV6_ADDRESS)));
                    }
		    Marshal.DestroyStructure(enumInfo, typeof(DHCPV6_IP_ARRAY));  
		    enumInfo = IntPtr.Zero;
                } while (error == (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA);
                return scopeList.ToArray();
            }

            internal static void QueryDnsCredentials(string serverNameOrIPAddress, out string uname, out string domain)
            {
                StringBuilder userName = new StringBuilder(256);
                StringBuilder domainName = new StringBuilder(256);
                uint error = NativeMethods.DhcpServerQueryDnsRegCredentials(serverNameOrIPAddress, 256, userName, 256, domainName);
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }
  
                uname = userName.ToString();
                domain = domainName.ToString();
	    }
 
            internal static ServerConfiguration GetServerConfiguration(string serverIpAddress)
            {
                uint error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
		IntPtr auditLogDir = new IntPtr();
                IntPtr config = new IntPtr();
		string auditLogDirString;
		uint minDiskSpace = 0;
                uint maxLogFilesSize = 0;
                uint diskCheckInterval = 0;
             
                error = NativeMethods.DhcpAuditLogGetParams(serverIpAddress, 0, ref auditLogDir, ref diskCheckInterval, ref maxLogFilesSize, ref minDiskSpace);
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }

                auditLogDirString = Marshal.PtrToStringUni(auditLogDir);
                NativeMethods.DhcpRpcFreeMemory(auditLogDir);
		
                DHCP_SERVER_CONFIG_INFO_VQ configInfo = new DHCP_SERVER_CONFIG_INFO_VQ();
                error = NativeMethods.DhcpServerGetConfigVQ(serverIpAddress, ref config);
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }

                configInfo = (DHCP_SERVER_CONFIG_INFO_VQ)Marshal.PtrToStructure(config, typeof(DHCP_SERVER_CONFIG_INFO_VQ));
		Marshal.DestroyStructure(config, typeof(DHCP_SERVER_CONFIG_INFO_VQ));  
                return (new ServerConfiguration(configInfo.DatabaseName, configInfo.DatabasePath, configInfo.BackupPath, auditLogDirString, configInfo.fAuditLog, (byte)configInfo.dwPingRetries));
            }

	    internal static FilterSettings GetV4FilterSettings(string serverNameOrIpAddress)
	    {
		DHCP_FILTER_GLOBAL_INFO fltsettings = new DHCP_FILTER_GLOBAL_INFO();
		uint error = NativeMethods.DhcpGetFilterV4(serverNameOrIpAddress, out fltsettings);
		if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
		{
                    throw new DHCPException(error);
		}
		FilterSettings filters = new FilterSettings(fltsettings.EnforceAllowList, fltsettings.EnforceDenyList);
		return filters;		
	    }
            internal static Filter[] EnumV4Filters(string serverNameOrIPAddress, uint listType)
            {
                DHCP_ADDR_PATTERN resumehandle = new DHCP_ADDR_PATTERN();
                DHCP_FILTER_LIST_TYPE list = DHCP_FILTER_LIST_TYPE.Allow;;
                uint elementsRead, elementsTotal, error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
                List<Filter> filterList = new List<Filter>();
                if(0 == listType)
                {
                    list = DHCP_FILTER_LIST_TYPE.Allow;
		    
                }
                else if(1 == listType)
                {
                    list = DHCP_FILTER_LIST_TYPE.Deny; 
                }
                IntPtr enumInfo = new IntPtr();
                do {
                    error = NativeMethods.DhcpEnumFilterV4(serverNameOrIPAddress, ref resumehandle, UInt32.MaxValue, list, ref enumInfo, out elementsRead, out elementsTotal);
                    if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error && error != (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA && error != (uint)DHCPErrors.DHCPError.ERROR_NO_MORE_ITEMS)
                    {
                        throw new DHCPException(error);
                    }
		    DHCP_FILTER_ENUM_INFO filterArray = (DHCP_FILTER_ENUM_INFO)Marshal.PtrToStructure(enumInfo, typeof(DHCP_FILTER_ENUM_INFO));
                    uint numElements = filterArray.NumElements;
                    IntPtr ptr = filterArray.pEnumRecords;

                    for (int i = 0; i < elementsRead; i++)
                    {
                        DHCP_FILTER_RECORD filterRecord = (DHCP_FILTER_RECORD)Marshal.PtrToStructure(ptr, typeof(DHCP_FILTER_RECORD));
			DHCP_ADDR_PATTERN addPattern = filterRecord.AddrPatt;
			if ( NativeConstants.HWTYPE_ETHERNET_10MB == addPattern.HWType )
			{
			    string pattern = BitConverter.ToString(addPattern.Pattern, 0, (int)addPattern.Length);
	                    filterList.Add(new Filter((list == DHCP_FILTER_LIST_TYPE.Allow), addPattern.HWType, pattern, addPattern.IsWildcard));
 			}
			Marshal.DestroyStructure(ptr, typeof(DHCP_FILTER_RECORD));
                        ptr = (IntPtr)(ptr + Marshal.SizeOf(typeof(DHCP_FILTER_RECORD)));
                    }
		    Marshal.DestroyStructure(enumInfo, typeof(DHCP_FILTER_ENUM_INFO));
		    enumInfo = IntPtr.Zero;
                } while (error == (uint)DHCPErrors.DHCPError.ERROR_MORE_DATA);
		if(0 == filterList.Count)
		    return null;
                return filterList.ToArray();
            }
	    
            internal static bool QueryServerAttribute(string serverIpAddress, DHCPServerAttribute dhcpAttribId)
            {
                uint error = (uint)DHCPErrors.DHCPError.ERROR_SUCCESS;
                IntPtr dhcpAttrib = new IntPtr();
                DHCP_ATTRIB dhcpAttribValue = new DHCP_ATTRIB();
                error = NativeMethods.DhcpServerQueryAttribute(serverIpAddress, 0, (uint)dhcpAttribId, ref dhcpAttrib);
                if ((uint)DHCPErrors.DHCPError.ERROR_SUCCESS != error)
                {
                    throw new DHCPException(error);
                }

                dhcpAttribValue = (DHCP_ATTRIB)Marshal.PtrToStructure(dhcpAttrib, typeof(DHCP_ATTRIB));
                NativeMethods.DhcpRpcFreeMemory(dhcpAttrib);
                if (NativeConstants.DHCP_ATTRIB_TYPE_BOOL == dhcpAttribValue.DhcpAttribType)
                {
                    return dhcpAttribValue.Union1.DhcpAttribBool;
                }
		Marshal.DestroyStructure(dhcpAttrib, typeof(DHCP_ATTRIB));
		return false;
            }

        }
	public class JetWrapper
	{
   	    internal static JetIds JetInitStatus()
	    {
		uint _jetInstance = 0;
		int error = NativeMethods.JetInit(ref _jetInstance);
		JetIds jetInstance = new JetIds(_jetInstance, error);
		return jetInstance;
	    }
	    internal static JetIds BeginSession(uint jetInstance)
	    {
		uint _jetSession = 0;
		int error = NativeMethods.JetBeginSession(jetInstance, ref _jetSession, "admin", "");
		JetIds jetSession = new JetIds(_jetSession, error);
		return jetSession;
	    }
	    internal static int AttachDatabase(uint jetSession, string databasePath)
	    {
		return NativeMethods.JetAttachDatabase(jetSession, databasePath, 0);
	    }
  	    internal static JetIds OpenDatabase(uint jetSession, string databasePath)
	    {
		uint _jetDb = 0;
		int error = NativeMethods.JetOpenDatabase(jetSession, databasePath, null, ref _jetDb, 0);
		JetIds jetDb = new JetIds(_jetDb, error);
		return jetDb;
	    }
	    internal static int CloseDatabase(uint jetSession,uint jetDb)
	    {
		return NativeMethods.JetCloseDatabase(jetSession, jetDb, 0);
	    }
	    internal static int DetachDatabase(uint jetSession, string databasePath)
	    {
		return NativeMethods.JetDetachDatabase(jetSession, databasePath);
	    }
	    internal static int EndSession(uint jetSession)
	    {
		return NativeMethods.JetEndSession(jetSession, 0);
	    }
	    internal static int TerminateSession(uint jetInstance)
	    {
		return NativeMethods.JetTerm(jetInstance);
	    }
	}

	public class SecurityGroups
	{
            internal static string GetGroups(uint groupId)
            {
                IntPtr  hModule;
                string library = "dhcpsapi.dll" ;
                StringBuilder groupName = new StringBuilder(256) ;
                int number = 0;
                
               
                hModule = NativeMethods.LoadLibraryW(library) ;   

                if(hModule == null)
                {
                   //unable to load module
                   return null;  
                } 

                number = NativeMethods.LoadStringW(hModule,groupId,groupName,256);
                NativeMethods.FreeLibrary(hModule);

                if(number == 0)
                {
                      /// Return Type: BOOL->int
                  
                  return null;
                }   
            
                return groupName.ToString();
                
            }   
        }


        public class DhcpServer
        {
            private string name;
            public string Name
            {
                get { return name; }
            }
            private System.Net.IPAddress address;
            public System.Net.IPAddress Address
            {
                get { return address; }
            }
            
    	    private DhcpV4Binding[] V4bindings;
	    private DhcpV6Binding[] V6bindings;
	    private ServerConfiguration srvConfig;
	    private ScopeV4[] V4Scopes;
	    private ScopeV6[] V6Scopes;
	    private Filter[] allowList;
	    private Filter[] denyList;

            public DhcpServer(string serverName)
            {
                this.name = serverName;
                this.address = null;
            }
            public DhcpServer(IPAddress serverIPAddress)
            {
                this.name = String.Empty;
                this.address = serverIPAddress;
            }
            public DhcpServer(string serverName, IPAddress serverIPAddress)
            {
                this.name = serverName;
                this.address = serverIPAddress;
            }
	    public void InitializeServer()
 	    {
         	V4bindings = ServerWrapper.GetServerBindingsV4(this.name);
		V6bindings = ServerWrapper.GetServerBindingsV6(this.name);
		srvConfig = ServerWrapper.GetServerConfiguration(this.name);
		V4Scopes = ServerWrapper.EnumV4Subnets(this);
		V6Scopes = ServerWrapper.EnumV6Subnets(this);
		allowList = ServerWrapper.EnumV4Filters(this.name, NativeConstants.DENY_FILTER_LIST);
		denyList = ServerWrapper.EnumV4Filters(this.name, NativeConstants.ALLOW_FILTER_LIST);		
		}	
	    public DhcpV4Binding[] GetV4Bindings()
            {
		return V4bindings;
	    }
	    public DhcpV6Binding[] GetV6Bindings()
	    {
		return V6bindings;
	    }
	    public ServerConfiguration GetServerConfiguration()
	    {
		return srvConfig;
	    }
	    public ScopeV4[] GetV4Scopes()
	    {
		return V4Scopes;
	    }
    	    public ScopeV6[] GetV6Scopes()
	    {
		return V6Scopes;
	    }
	    public object[] EnumerateScopeExclusions(ScopeV4 scope)
	    {
		return scope.EnumerateExclusions();
	    }
    	    public object[] EnumerateScopeReservations(ScopeV4 scope)
	    {
		return scope.EnumerateReservations();
	    }
	    public object[] EnumerateV6ScopeExclusions(ScopeV6 scope)
	    {
		return scope.EnumerateExclusions();
	    }
    	    public object[] EnumerateV6ScopeReservations(ScopeV6 scope)
	    {
		return scope.EnumerateReservations();
	    }
	    public OptionValue GetV4ServerOption(uint optionId)
	    {
		return ScopeWrapper.GetOptionValueV4(this.name, optionId, null);
	    }
	    public OptionValue GetV6ServerOption(uint optionId)
	    {
		return ScopeWrapper.GetOptionValueV6(this.name, optionId, null);
	    }
	    public OptionValue GetOptionV4(ScopeV4 scope, uint optionId)
	    {
		return scope.GetOptionValue(optionId);
	    }
	    public OptionValue GetOptionV6(ScopeV6 scope, uint optionId)
	    {
		return scope.GetOptionValue(optionId);
	    }
	    public uint GetServerOptionsV6Count()
	    {
		return ServerWrapper.GetOptionListCountV6(this);
	    }
	    public bool GetV4BindingStatus()
	    {
		foreach(DhcpV4Binding obj in V4bindings)
		{
		    if (obj.BoundToServer)
		    { 
			return true;
		    }
		}
		return false;
	    }
	    public bool GetV6BindingStatus()
	    {
		foreach(DhcpV6Binding obj in V6bindings)
		{
		    if (obj.BoundToServer)
		    { 
		        return true;
		    }
		}
		return false;
	    }
	    public bool GetAuditLogStatus()
	    {
		return srvConfig.AuditLogState;
	    }
	    public uint GetDetectConflictRetry()
	    {
		return srvConfig.PingRetries;
	    }
	    public string GetAuditLogPath()
	    {
		return srvConfig.AuditLogDirectory;
	    }
	    public string GetDatabasePath()
	    {
		return srvConfig.DatabasePath;
	    }
	    public string GetBackUpPath()
	    {
		return srvConfig.BackupPath;
	    }
	    public FilterSettings GetFilterStatus()
	    {
		return ServerWrapper.GetV4FilterSettings(this.name);
	    }	
	    public Filter[] GetFilters(uint listType)
	    {
		if(0 == listType)
		{
		    return allowList;
		}
		else
		{
		    return denyList;
		}
            }
	    public bool IsAllowListConfigured()
	    {
		if (null == allowList)
		{
		    return false;
		}
		else
		{
		    return true;
		}
	    }
	    public bool IsDenyListConfigured()
	    {
		if (null == denyList)
		{
		    return false;
		}
		else
		{
		    return true;
		}
	    }
	    public bool IsV4ScopeConfigured()
	    {
		if (null == V4Scopes)
		{
		    return false;
		}
		else
		{
		    return true;
		}
	    }
	    public bool IsV6ScopeConfigured()
	    {
		if (null == V6Scopes)
		{
		    return false;
		}
		else
		{
		    return true;
		}
	    }
	    public bool IsNAPEnabled()
	    {
		bool isNapEnabled = false;
		foreach (ScopeV4 scope in V4Scopes)
		{
		    if ( NativeConstants.QUARANTINE_ON == scope.QuarantineOn )
			isNapEnabled = true ;
		}
		return isNapEnabled;
	    }
	    public string QueryDnsCredentials()
            { 
                string uname, domain;
                ServerWrapper.QueryDnsCredentials(this.name, out uname, out domain);
                if (!String.IsNullOrEmpty(uname) && !String.IsNullOrEmpty(domain))
                {
                    return string.Format(System.Globalization.CultureInfo.CurrentCulture, "{0}\\{1}", domain, uname);
                }
                else if (!String.IsNullOrEmpty(uname) && String.IsNullOrEmpty(domain))
                {
                    return uname;
                }
                else
                {
                    return String.Empty;
                }
            }
	    public string[] IsV4DnsDynamicUpdateConfigured()
	    {
		bool DnsUpdateEnabledSrv = false;
     	        bool DnsUpdateEnabled = true;
		uint option = 0;
                List<string> scopeList = new List<string>();

                OptionValue serverOption = GetV4ServerOption((uint)IPv4_OPTIONS.DHCP_DNSFQDN);
		OptionValue scopeOption = null;
		if (serverOption != null)
		{
		    option = (uint)serverOption.Value[0];
	            if ((option & NativeConstants.DNS_FLAG_ENABLED) == NativeConstants.DNS_FLAG_ENABLED )
                    {
		        DnsUpdateEnabledSrv = true;
		    }
                }
		else
		{
		    option = NativeConstants.DNS_FLAG_ENABLED | NativeConstants.DNS_FLAG_CLEANUP_EXPIRED;
		    DnsUpdateEnabledSrv = true;	
		}
		foreach (ScopeV4 scope in V4Scopes)
		{
  	            scopeOption = GetOptionV4(scope, (uint)IPv4_OPTIONS.DHCP_DNSFQDN);
                    if (scopeOption != null)
                    {
			option = (uint)scopeOption.Value[0];
   			if((option & NativeConstants.DNS_FLAG_ENABLED) != NativeConstants.DNS_FLAG_ENABLED)				
			{
                            scopeList.Add(scope.Address.ToString()); 
			    			    
			}
	            }
		    else if( !DnsUpdateEnabledSrv )
		    {
			scopeList.Add(scope.Address.ToString()); 
		    }
		}
	        return scopeList.ToArray();
           }
      
	    public string[] IsV6DnsDynamicUpdateConfigured()
	    {
		bool DnsUpdateEnabledSrv = false;
     	        bool DnsUpdateEnabled = true;
		uint option = 0;
                List<string> scopeList = new List<string>();

                OptionValue serverOption = GetV6ServerOption((uint)IPv6_OPTIONS.DHCPV6_DNSFQDN);
		OptionValue scopeOption = null;
		if (serverOption != null)
		{
		    option = (uint)serverOption.Value[0];
	            if ((option & NativeConstants.DNS_FLAG_ENABLED) == NativeConstants.DNS_FLAG_ENABLED )
                    {
		        DnsUpdateEnabledSrv = true;
		    }
                }
		else
		{
		    option = NativeConstants.DNS_FLAG_ENABLED | NativeConstants.DNS_FLAG_CLEANUP_EXPIRED;
		    DnsUpdateEnabledSrv = true;	
		}
		foreach (ScopeV6 scope in V6Scopes)
		{
		    scopeOption = GetOptionV6(scope, (uint)IPv6_OPTIONS.DHCPV6_DNSFQDN);
                    if (scopeOption != null)
                    {
			option = (uint)scopeOption.Value[0];
   			if((option & NativeConstants.DNS_FLAG_ENABLED) != NativeConstants.DNS_FLAG_ENABLED)				
			{
			    scopeList.Add(scope.Address.ToString()); 
			}
	            }
		    else if( !DnsUpdateEnabledSrv )
		    {
			scopeList.Add(scope.Address.ToString()); 
		    }
		}
	        return scopeList.ToArray();
           }
	   public bool AreDnsCredentialsConfigured()
	   {
  	        string dnsCredentials = QueryDnsCredentials();
   		return (dnsCredentials != String.Empty);       
	   }
           public DhcpReservationV4[] CheckReservationInList()
           {

               bool isAllowList = false;
               bool isDenyList = false;
               int flag ; 
               bool addAddress = true;   
               Filter[] denyFilter = null;
               Filter[] allowFilter = null;
               Object[] scopeReservations = null;
               ScopeV4[] scopes = null;
               string filterMac = null;
               string clientMac = null;
               FilterSettings filterSetting;
               List<DhcpReservationV4> addressMac = new List<DhcpReservationV4>();
 	       DhcpReservationV4 tempRes;
               filterSetting = GetFilterStatus();
               isAllowList = IsAllowListConfigured();
               isDenyList = IsDenyListConfigured();

               if(filterSetting.AllowList==false && filterSetting.DenyList==false)
               {
                   return null; 
               }      

               if(filterSetting.AllowList == true && isAllowList == true)
               {
                   allowFilter = GetFilters(NativeConstants.DENY_FILTER_LIST);

               }

               if(filterSetting.DenyList==true && isDenyList == true)
               {
                   denyFilter = GetFilters(NativeConstants.ALLOW_FILTER_LIST);

               }
             
               scopes = GetV4Scopes();  
              
               foreach(ScopeV4 scope in scopes)
               { 
                   scopeReservations = EnumerateScopeReservations(scope); 
                   if (scopeReservations != null)
                   {  
                       foreach(DhcpReservationV4 reservation in scopeReservations)
                       {
			   tempRes = reservation;
			   tempRes.ClientUid = reservation.ClientUid.Remove(0,15); 
                           clientMac = reservation.ClientUid.Remove(0,15); 
                           if(filterSetting.AllowList==true)
                           {
                               addAddress = true;
                       	       if( isAllowList)
			       {
                            	   foreach( Filter filter in allowFilter)
                            	   {
                               	       if(filter.IsWildCard == true)
                                       {
                                           filterMac = clientMac.Remove(filter.Pattern.Length,17-filter.Pattern.Length);
                                           flag = filterMac.CompareTo(filter.Pattern);
                                       } 
				       else
                                       {
                                           flag = filter.Pattern.CompareTo(clientMac);
                                       }
                                       if(flag == 0)
                                       {
                                           addAddress = false;
                                       } 
                                   }
			       }
                           }
                           else   
                           {
                               addAddress = false;
                           } 
                           if (filterSetting.DenyList == true && isDenyList == true)
                           {
                               foreach( Filter filter in denyFilter)
                               {
                                   if(filter.IsWildCard == true)
                                   {
                                       filterMac = clientMac.Remove(filter.Pattern.Length,17-filter.Pattern.Length);
                                       flag = filterMac.CompareTo(filter.Pattern);
                                   } 
	                           else 
                                   {
                                       flag = filter.Pattern.CompareTo(clientMac);
                                   }
                                   if(flag == 0)
                                   {
                                       addAddress = true; 
                                   }                                                    
                               }                     
                           }
                           if(addAddress == true)
                           {
                               addressMac.Add(tempRes); 
                           } 
                       }
                   }
                }
		if(0 == addressMac.Count)
	        {
		   return null;
                }
                return addressMac.ToArray(); 
            }  

	    public IPAddress[] CheckV4BindingsExcluded(ScopeV4 scope)
	    {
		bool isIncluded = false;
                List<System.Net.IPAddress> includedBindings = new List<System.Net.IPAddress>();
		foreach(DhcpV4Binding binding in V4bindings)
		{
		    if(binding.BoundToServer)
		    {
		    	UInt32 bindingAddress = Utilities.IPV4AddressToUInt32(binding.Address);
			UInt32 StartIp = Utilities.IPV4AddressToUInt32(scope.Range.StartAddress);
			UInt32 EndIp = Utilities.IPV4AddressToUInt32(scope.Range.EndAddress);
			if(StartIp != 0 && EndIp != 0)
			{
  	   		    if (StartIp <= bindingAddress && bindingAddress <= EndIp)
		    	    {
    			    	isIncluded = true;
			    	object[] exclRanges = EnumerateScopeExclusions(scope);
	 		   	foreach(IPRange excl in exclRanges)
			    	{
			            UInt32 StartExcl = Utilities.IPV4AddressToUInt32(excl.StartAddress);
			       	    UInt32 EndExcl = Utilities.IPV4AddressToUInt32(excl.EndAddress);
			            if (StartExcl <= bindingAddress && bindingAddress <= EndExcl)
			            {
				        isIncluded = false;
					break;
			            }
				}
			    }
		        }
		        if (isIncluded)
		        {
			    includedBindings.Add(binding.Address);
			    isIncluded = false;
	       	        }
		    }
		}
		if(0 == includedBindings.Count)
		{
		    return null;
                }
                return includedBindings.ToArray();

	    }
   	    public IPAddress[] CheckV6BindingsExcluded(ScopeV6 scope)
	    {
		bool isIncluded = false;
                List<System.Net.IPAddress> includedBindings = new List<System.Net.IPAddress>();
		foreach(DhcpV6Binding binding in V6bindings)
		{
		    if(binding.BoundToServer)
		    {
			isIncluded = false;
  		        DHCP_IPV6_ADDRESS bindingAddress = Utilities.IPV6AddressToDhcpIPV6Address(binding.Address);
			DHCP_IPV6_ADDRESS scopeAddress = Utilities.IPV6AddressToDhcpIPV6Address(scope.Address);
			if(bindingAddress.HighOrderBits == scopeAddress.HighOrderBits)
			{
			    isIncluded = true;
			    object[] exclRanges = EnumerateV6ScopeExclusions(scope);
	 		    foreach(IPRangeV6 excl in exclRanges)
		    	    {
				DHCP_IPV6_ADDRESS StartExcl = Utilities.IPV6AddressToDhcpIPV6Address(excl.StartAddress);
  				DHCP_IPV6_ADDRESS EndExcl = Utilities.IPV6AddressToDhcpIPV6Address(excl.EndAddress);
	    		        if (StartExcl.LowOrderBits <= bindingAddress.LowOrderBits && bindingAddress.LowOrderBits <= EndExcl.LowOrderBits)
				{
			            isIncluded = false;
				    break;
			        }
                            }
			}
		        if (isIncluded)
		        {
			    includedBindings.Add(binding.Address);
	       	        }
		    }
		}
		if(0 == includedBindings.Count)
		{
		    return null;
		}
                return includedBindings.ToArray();
	    }
    	    public int CheckDatabaseStatus(string databasePath)
	    {
		JetIds jetInstance, jetSession, jetDb;
		int jetError = 0;
		jetInstance = JetWrapper.JetInitStatus();
		if (jetInstance.JetError == 0 )
		{
		    jetSession = JetWrapper.BeginSession(jetInstance.JetId);
		    if(jetSession.JetError == 0)
		    {
			jetError = JetWrapper.AttachDatabase(jetSession.JetId, databasePath);
			if(jetError == 0)
			{
			    jetDb = JetWrapper.OpenDatabase(jetSession.JetId, databasePath);
			    jetError = jetDb.JetError;
			    if(jetDb.JetError == 0 && jetDb.JetId != 0)
			    {
				JetWrapper.CloseDatabase(jetSession.JetId, jetDb.JetId);
			    }	
			    JetWrapper.DetachDatabase(jetSession.JetId, databasePath);
			}
			if(jetSession.JetId != 0)
			{
			    JetWrapper.EndSession(jetSession.JetId);
			}
		    }
		    else
		    {
			jetError = jetSession.JetError;
		    }
		}
		if(jetInstance.JetId != 0)
		{
		    JetWrapper.TerminateSession(jetInstance.JetId);
		}
		return jetError;
            }
	    public bool IsAuthorized()
            {
                bool value = ServerWrapper.QueryServerAttribute(this.name, DHCPServerAttribute.DhcpAttribBoolIsRogue);
		if(value)
		{
		    return false;
		}
		else
		{
		    return true;
		}
            }
            public string GetSecGroups(uint id)
            {
                return SecurityGroups.GetGroups(id);
            } 

            public void InitializeRpc()
            {
                uint  MajorVersion = 0;
                uint  MinorVersion = 0;
                
                uint err = NativeMethods.DhcpGetVersion(this.name, ref MajorVersion, ref MinorVersion);
            } 


	}
    }
'@
Compile-Csharp $code "/target:library"
}
function Create-DocumentElement($ns, $name )
{
    [xml] "<$name xmlns='$ns'/>"
}
#Helper function to set the text of the node
function set-XmlElementInnerText($ElementNode, $ElementValue)
{	  
    # make value canonical to XSD type
    if ($ElementValue -is [bool])
    {
	$standard = $ElementValue.ToString().ToLower() 
        $ElementValue = $standard
    }
    
    #Write the values in the node element
    $ElementNode.Set_innertext($ElementValue)         
}
function setXmlElement($doc, $ParentNode, $tns, $NodeName)
{
    $ChildNode=$doc.CreateElement($NodeName,$tns)
    [void]$ParentNode.AppendChild($ChildNode)
    return $ChildNode
}
function get-ServiceStatus()
{
    $serviceData = Get-Service dhcpserver
    $state = $serviceData.status
    return ($state -as [int])
}
function get-ServerPID()
{
    $serviceData = Get-WmiObject win32_service -filter "name = 'DHCPServer'"
    [int]$dhcppid = [int]$serviceData.ProcessId
    return $dhcppid
}
function get-ServerDomainJoined()
{
    $computerStatus = Get-WmiObject win32_computerSystem
    $isdomainjoined = $computerStatus.PartOfDomain
    return $isdomainjoined
}

function get-DomainName()
{
    $computerStatus = Get-WmiObject win32_computerSystem
 
    if ($computerStatus.PartOfDomain)
    {
	return $computerStatus.domain 
    }  
    return $null
}

function get-RogueDetectionEnabled()
{
    $regOutput = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\DHCPServer\Parameters
    $value = $regOutput.DisableRogueDetection
    if($value -eq $Null)
    {
	return $true;
    }
    else
    {
	return ($value -eq 0)
    }
}
function get-V4OpenedPorts($port, $UdpV4Table, $bindings, $dhcpPid)
{
    $portRows = @()
    foreach($row in $UdpV4Table)
    {
	if($row.LocalPort -eq $port)
        {
  	    if("0.0.0.0" -eq $row.LocalAddress.IPAddressToString)
            {
		if($row.Pid -ne $dhcpPid)
	  	{
		    $portRows = $portRows + @($row)
		}			
            }
	    foreach($binding in $bindings)
            {
		if(($binding.Address -eq $row.LocalAddress) -and ($binding.BoundToServer -eq $true))
		{
		    if($row.Pid -ne $dhcpPid)
		    {
		        $portRows = $portRows + @($row)
		    }
		}
	    }
	}
    }
    return $portRows
}
function get-V6OpenedPorts($port, $UdpV6Table, $bindings, $dhcpPid)
{
    $portRows = @()
    foreach($row in $UdpV6Table)
    {
	if($row.LocalPort -eq $port)
	{
  	    if("::" -eq $row.LocalAddress.IPAddressToString)
            {
		if($row.Pid -ne $dhcpPid)
	  	{
		    $portRows = $portRows + @($row)
		}			
            }
	    foreach($binding in $bindings)
            {
		if(($binding.Address -eq $row.LocalAddress) -and ($binding.BoundToServer -eq $true))
		{
		    if($row.Pid -ne $dhcpPid)
	  	    {
			$portRows = $portRows + @($row)
		    }
		}
	    }
	}
    }
    return $portRows
}
function get-ScopesWithoutIpRange($V4scopes)
{
    $scopeList = @()
    foreach($scope in $V4scopes)
    {
	if($scope.Range.StartAddress -eq 0 -and $scope.Range.EndAddress -eq 0)
	{
	    $scopeList = $scopeList + @($scope.Address.IPAddressToString)
	}
    }
    return $scopeList
}
function get-SecurityGroups()
{
    $usergroup = $DHCPServerInstance.GetSecGroups([Dhcp.USER_GROUPS]::ID_DHCP_USER_GROUP);

    $user = Get-WmiObject Win32_Group | Where-Object {$_.Name -match $usergroup}
    $UserGrpPresent = $user -ne $Null

    $admingroup = $DHCPServerInstance.GetSecGroups([Dhcp.USER_GROUPS]::ID_DHCP_ADMIN_GROUP);
    $admin = Get-WmiObject Win32_Group | Where-Object {$_.Name -match $admingroup}

    $adminGrpPresent = $admin -ne $Null
    
    return ($UserGrpPresent -and $adminGrpPresent)
}
function get-NPSServerStatus()
{
    $isRunning = $false
    $nps = Get-Service | Where-Object {$_.Name -eq "IAS"}
    $isnpsinstalled = ($nps -ne $Null)
    if($isnpsinstalled)
    {
        $isRunning = ($nps.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running)
    }
    return $isRunning	
}
function get-DomainControllerStatus()
{
    $dc = get-wmiobject -class Win32_OperatingSystem
    return ($dc.ProductType -eq [Dhcp.NativeConstants]::DOMAIN_CONTROLLER_STATUS)
}
function get-DNSServerOptionV4($DHCPServerInstance)
{
     $isConfgatServerLevel = $true
     $scopeIp = @()
     $ServerOption = $DHCPServerInstance.GetV4ServerOption([Dhcp.IPv4_OPTIONS]::DHCP_DNSSERVER)
     if ($ServerOption -eq $Null -or $ServerOption.Value[0].IPAddressToString -eq "0.0.0.0")
     {
        $isConfgatServerLevel = $false	
     }
     $V4scopes = $DHCPServerInstance.GetV4Scopes();
     if($V4scopes -eq $Null)
     {
         return $Null; 
     }
     foreach ($scope in $V4scopes)
     {
        $scopeOption = $DHCPServerInstance.GetOptionV4($scope, [Dhcp.IPv4_OPTIONS]::DHCP_DNSSERVER)
	if (($scopeOption -eq $Null -and $isConfgatServerLevel -eq $false) -or ($scopeOption -ne $Null -and $scopeOption.Value[0].IPAddressToString -eq "0.0.0.0"))     
        {
	    $scopeIp = $scopeIp + @($scope.Address.IPAddressToString)
        }
     }	
     return $scopeIp
}
function get-DnsServerListV4($DHCPServerInstance, $V4Scopes)
{
    $dnsTable = @{}
    $dnsTableLevel = @{}
    $dnsserverlist_server = @()
    $serverOption = $DHCPServerInstance.GetV4ServerOption([Dhcp.IPv4_OPTIONS]::DHCP_DNSSERVER)
    if($serverOption -ne $Null -and $serverOption.Value[0].IPAddressToString -ne "0.0.0.0")
    {
	foreach($value in $serverOption.Value)
	{
	    if(-not ($dnsserverlist_server -contains $value.IPAddressToString))
	    {
		$dnsserverlist_server = $dnsserverlist_server + @($value.IPAddressToString)
	    }
	}
    }

    $dnsTable[0] = $dnsserverlist_server
    $dnsTableLevel[0] = $false
    foreach($scope in $V4scopes)
    {
	$dnsserverlist = @()
  	$scopeOption = $DHCPServerInstance.GetOptionV4($scope, [Dhcp.IPv4_OPTIONS]::DHCP_DNSSERVER)
	if ($scopeOption -ne $Null)     
	{
                $dnsTableLevel[$scope.Address] = $true
		if($scopeOption.Value[0].IPAddressToString -ne "0.0.0.0")
		{
	    	foreach($value in $scopeOption.Value)
	    	{
			if(-not ($dnsserverlist -contains $value.IPAddressToString))
			{
		    	$dnsserverlist = $dnsserverlist + @($value.IPAddressToString)
                        
			}
	    	}
		}	
        }
	else
	{
	    $dnsserverlist = $dnsserverlist_server
            $dnsTableLevel[$scope.Address] = $false

	}	
	$dnsTable[$scope.Address] = $dnsserverlist
    }
    return $dnsTable, $dnsTableLevel
}
function get-DNSServerOptionV6($DHCPServerInstance)
{
     $isConfgatServerLevel = $true
     $scopeIp = @()
     $ServerOption = $DHCPServerInstance.GetV6ServerOption([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSSERVER)
     if ($ServerOption -eq $Null -or $ServerOption.Value[0] -eq "")
     {
	$isConfgatServerLevel = $false	
     }

     $V6scopes = $DHCPServerInstance.GetV6Scopes();
     if($V6scopes -eq $Null)
     {
        return $Null; 
     } 
     foreach ($scope in $V6scopes)
     {
	$scopeOption = $DHCPServerInstance.GetOptionV6($scope, [Dhcp.IPv6_OPTIONS]::DHCPV6_DNSSERVER)
	if (($scopeOption -eq $Null -and $isConfgatServerLevel -eq $false) -or ($scopeOption -ne $Null -and $scopeOption.Value[0] -eq ""))     
	{
	    $scopeIp = $scopeIp + @($scope.Address.IPAddressToString)
        }
     }
     return $scopeIp
}
function get-DnsServerListV6($DHCPServerInstance, $V6Scopes)
{
     $dnsTable = @{}
     $dnsTableLevel = @{}

     $dnsserverlist_server = @()
     $serverOption = $DHCPServerInstance.GetV6ServerOption([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSSERVER)
     if($serverOption -ne $Null -and $serverOption.Value[0] -ne "")
     {
	 foreach($value in $serverOption.Value)
	 {
	     if(-not ($dnsserverlist_server -contains $value))
	     {
 	         $dnsserverlist_server = $dnsserverlist_server + @($value)
	     }
	 }
     }

    $dnsTable[0] = $dnsserverlist_server
    $dnsTableLevel[0] = $false


     foreach($scope in $V6scopes)
     {
	 $dnsserverlist = @() 
	 $scopeOption = $DHCPServerInstance.GetOptionV6($scope, [Dhcp.IPv6_OPTIONS]::DHCPV6_DNSSERVER)
	 if ($scopeOption -ne $Null)     
	 {
             $dnsTableLevel[$scope.Address] = $true
    	     if($scopeOption.Value[0] -ne "")
	     {
	         foreach($value in $scopeOption.Value)
	         {
		     if(-not ($dnsserverlist -contains $value))
	   	     {
		         $dnsserverlist = $dnsserverlist + @($value)
		     }
	         }
	     }
	 }
	 else
	 {
	     $dnsserverlist = $dnsserverlist_server
             $dnsTableLevel[$scope.Address] = $false
	 }
	 $dnsTable[$scope.Address] = $dnsserverlist
     }
    return $dnsTable, $dnsTableLevel
}

function get-InvalidDnsServers($DnsValid, $dnsServerList,$dnsDomainTable)	
{
    $preconditionTrue = $false
    $validServerlist = @()
    $invalidServerlist = @()


    $domain = get-DomainName

    foreach($scope in $dnsServerList.Keys)
    {
       $dnsList =  $dnsServerList[$scope]

       if($domain -eq $null)
       {
          if( $dnsDomainTable[$scope] -eq $null)
          {
             $domainName = "."
          } else {
             $domainName = $dnsDomainTable[$scope]
          }        
       } else {
          $domainName = $domain
       }

        if($dnsList.count -ne 0)
	{
	    $preconditionTrue = $true
	    foreach($srv in $dnsList)
	    {
      		if((-not($validServerlist -contains $srv)) -and (-not($invalidServerlist -contains $srv)))
	   	{
  	    	    $isValid = $DnsValid.GetDnsValidationStatus($srv,$domainName);
		    if($isValid)
		    {
		        $validServerlist = $validServerlist + @($srv);
		    }
		    else
		    {
		        $invalidServerlist = $invalidServerlist + @($srv);	
		    }
		}
	    }
	}

    }
   
    $validServerlist, $invalidServerlist, $preconditionTrue 
}	
function get-DNSDomainOptionV4($DHCPServerInstance)
{
     $isConfgatServerLevel = $true
     $scopeIp = @()
     $ServerOption = $DHCPServerInstance.GetV4ServerOption([Dhcp.IPv4_OPTIONS]::DHCP_DNSDOMAINNAME)
     if ($ServerOption -eq $Null -or $ServerOption.Value[0] -eq "")
     {
	 $isConfgatServerLevel = $false
     }	
     $V4scopes = $DHCPServerInstance.GetV4Scopes();
     if($V4scopes -eq $Null)
     {
         return $Null; 
     } 
     foreach ($scope in $V4scopes)
     {
 	 $scopeOption = $DHCPServerInstance.GetOptionV4($scope, [Dhcp.IPv4_OPTIONS]::DHCP_DNSDOMAINNAME)
	 if (($scopeOption -eq $Null -and $isConfgatServerLevel -eq $false) -or ($scopeOption -ne $Null -and $scopeOption.Value[0] -eq ""))     
	 {
	     $scopeIp = $scopeIp + @($scope.Address.IPAddressToString)
         }
     }
     return $scopeIp
}
function get-DnsDomainListV4($DHCPServerInstance, $V4Scopes)
{
     $dnsdomainTable = @{}
     $dnsDomainLevel = @{}

     $serverOption = $DHCPServerInstance.GetV4ServerOption([Dhcp.IPv4_OPTIONS]::DHCP_DNSDOMAINNAME)
     if($serverOption -ne $Null -and $serverOption.Value[0] -ne "")
     {
  	 $dnsdomain_server = $ServerOption.Value

     }

     $dnsdomainTable[0] = $dnsdomain_server 
     $dnsDomainLevel[0] = $false
 	
     foreach($scope in $V4scopes)
     {
	 $scopeOption = $DHCPServerInstance.GetOptionV4($scope, [Dhcp.IPv4_OPTIONS]::DHCP_DNSDOMAINNAME)
	 if ($scopeOption -ne $Null)     
	 {
	     if ($scopeOption.Value[0] -ne "")
	     {	
	         $dnsdomainTable[$scope.Address] = $scopeOption.Value
                 $dnsDomainLevel[$scope.Address] = $true
	     }	
	 }
	 else
	 {
	     $dnsdomainTable[$scope.Address] = $dnsdomain_server
             $dnsDomainLevel[$scope.Address] = $false
	 }

     }

     return $dnsdomainTable, $dnsDomainLevel
}
function get-DNSDomainOptionV6($DHCPServerInstance)
{
     $isConfgatServerLevel = $true
     $scopeIp = @()
     $ServerOption = $DHCPServerInstance.GetV6ServerOption([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSDOMAINNAME)
     if ($ServerOption -eq $Null -or $ServerOption.Value[0] -eq "")
     {
		 $isConfgatServerLevel = $false
     }
     $V6scopes = $DHCPServerInstance.GetV6Scopes();
     if($V6scopes -eq $Null)
     {
         return $Null; 
     } 
     foreach ($scope in $V6scopes)
     {
	 $scopeOption = $DHCPServerInstance.GetOptionV6($scope, [Dhcp.IPv6_OPTIONS]::DHCPV6_DNSDOMAINNAME)
 	 if (($scopeOption -eq $Null -and $isConfgatServerLevel -eq $false) -or ($scopeOption -ne $Null -and $scopeOption.Value[0] -eq ""))     
	 {
	     $scopeIp = $scopeIp + @($scope.Address.IPAddressToString)
         }	
     }
     return $scopeIp
}
function get-DnsDomainListV6($DHCPServerInstance, $V6Scopes)
{
     $dnsdomainTable = @{}
     $dnsDomainLevel = @{}

     $serverOption = $DHCPServerInstance.GetV6ServerOption([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSDOMAINNAME)
     if($serverOption -ne $Null -and $serverOption.Value[0] -ne "")
     {
	 $dnsdomain_server = $serverOption.Value[0]
     }

     $dnsdomainTable[0] = $dnsdomain_server 
     $dnsDomainLevel[0] = $false

     foreach($scope in $V6scopes)
     {
	 $scopeOption = $DHCPServerInstance.GetOptionV6($scope, ([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSDOMAINNAME))
	 if ($scopeOption -ne $Null)     
	 {
	     if($scopeOption.Value[0] -ne "")
	     {
 	         $dnsdomainTable[$scope.Address] = $scopeOption.Value[0]
                 $dnsDomainLevel[$scope.Address] = $true

             }
 	 }
	 else
	 {
	     $dnsdomainTable[$scope.Address] = $dnsdomain_server
             $dnsDomainLevel[$scope.Address] = $false

         }
     }
     return $dnsdomainTable, $dnsDomainLevel

}
function get-DefaultGatewayOption($DHCPServerInstance)
{
     $scopeIp = @()
     $V4scopes = $DHCPServerInstance.GetV4Scopes();
     if($V4scopes -eq $Null)
     {
         return $scopeIp; 
     } 
     foreach ($scope in $V4scopes)
     {
         $scopeOption = $DHCPServerInstance.GetOptionV4($scope, [Dhcp.IPv4_OPTIONS]::DHCP_GATEWAY)
         if ($scopeOption -eq $Null -or ($scopeOption.Value[0].IPAddressToString -eq "0.0.0.0" -and $scopeOption.Value.count -eq 1))     
         {
             $scopeIp = $scopeIp + @($scope.Address.IPAddressToString)
         }
     }	   
     return $scopeIp
}
function get-DnsUpdateProxyGroupSecureStatus($domainName)
{
    $domain = ($domainName -as [string]).split('.')[0]
    $domainInfo = Get-WmiObject Win32_NTDomain -filter "DomainName = '$domain'"
    if($domainInfo -ne $Null)
    {
	$srv = $domainInfo.DomainControllerName.substring(2,$domainInfo.DomainControllerName.length-2)
    }
    try {
        $key = "SYSTEM\CurrentControlSet\services\DNS\Parameters"
        $type = [Microsoft.Win32.RegistryHive]::LocalMachine
        $regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $Srv)
        $regKey = $regKey.OpenSubKey($key)
        $value = $regKey.GetValue("OpenACLOnProxyUpdates")
    }
    catch {
	return $false, $true
    }	
    if($value -eq 0)
    {
	return $true, $false
    }
    else
    {
	return $false, $false
    }
}
function CheckforDuplicate( $dnsdomainhash, $newPair)
{
    foreach ($entry in $dnsdomainhash)
    {
	if ($entry.dns -eq $newPair.dns -and $entry.domain -eq $newPair.domain)
	{
	    return $true, $entry.flag
        }
    }
    return $false, $false
}
function get-ForwardZoneStatus($DhcpServerInstance, $dnsdomainTable, $dnsServerList, $invalidServerlist)
{
    $isAccessDenied = $false
    $dnsdomainhash = @()
    $isPreconditionTrue = $false
    $invalidDomains = @{}

    foreach($scope in $dnsdomainTable.Keys)
    {
	$domainname = $dnsdomainTable[$scope]
        $dnsList = $dnsServerlist[$scope]

	$isConfiguredFwdZone = $false
        $validDnsServer = $false

	# both options should be present - precondition
	if($domainname -ne $Null -and $dnsList.count -ne 0)
	{
	    foreach($srv in $dnsList)
	    {
		if(-not($invalidServerlist -contains $srv))
		{
	 	    $isPreconditionTrue = $true
                    $validDnsServer = $true
	 	    $newPair = @{dns = $srv; domain = $domainname}
		    $alreadyChecked, $flagValue = CheckforDuplicate $dnsdomainhash $newPair
		    if($alreadyChecked -eq $false)
	            { 
			try {
  	                    # this gets all the zones and zone details in a dns server specified by $srv
		            $result = get-wmiobject -namespace "root\MicrosoftDNS" -class "MicrosoftDNS_Zone" -computerName $srv -Filter "ContainerName = '$domainname'"
			}
			catch {
			    $isAccessDenied = $true
		  	    return $invalidDomains, $isPreconditionTrue, $isAccessDenied
			}
			$dnsdomainhash = $dnsdomainhash + @($newPair)
			if($result -ne $Null) 
		    	{ 
			    $isConfiguredFwdZone = $true
			    $newPair.flag = $true
			    break
		   	}
			else
			{
			    $newPair.flag = $false
			}
   	            }
		    else
  		    {
			if($flagValue -eq $true)
			{
			    $isConfiguredFwdZone = $true
			    break
			}
		    }
	 	}
            }
	    if( ($isConfiguredFwdZone -eq $false) -and ($validDnsServer -eq $true))
	    {
	        $invalidDomains[$scope] = $domainname
	    }
        }
    }
    $invalidDomains, $isPreconditionTrue, $isAccessDenied
}
function get-NameProtectionStatus($scope, $isIPv4)
{
    $isNameProtectionEnabled = $false
    if($isIPv4 -eq $true)
    {
	$scopeOption = $DHCPServerInstance.GetOptionV4($scope, [Dhcp.IPv4_OPTIONS]::DHCP_DNSFQDN);
    }
    else
    {
     	$scopeOption = $DHCPServerInstance.GetOptionV6($scope, [Dhcp.IPv6_OPTIONS]::DHCPV6_DNSFQDN);
    }
    if ($scopeOption -ne  $Null)
    {
	$optionValue = $scopeOption.Value[0];
  	if(($optionValue -band [Dhcp.NativeConstants]::DNS_FLAG_UPDATE_DHCID) -eq [Dhcp.NativeConstants]::DNS_FLAG_UPDATE_DHCID)				
	{
	    $isNameProtectionEnabled = $true
	}
    }
    else
    {
	if($isIPv4 -eq $true)
	{
  	    $serverOption = $DHCPServerInstance.GetV4ServerOption([Dhcp.IPv4_OPTIONS]::DHCP_DNSFQDN);
	}
	else
	{
	    $serverOption = $DHCPServerInstance.GetV6ServerOption([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSFQDN);
	}
	if ($serverOption -ne  $Null)
    	{
    	    $optionValue = $serverOption.Value[0];
    	    if(($optionValue -band [Dhcp.NativeConstants]::DNS_FLAG_UPDATE_DHCID) -eq [Dhcp.NativeConstants]::DNS_FLAG_UPDATE_DHCID)				
    	    {
        	$isNameProtectionEnabled = $true
    	    }
	}
    }
    return $isNameProtectionEnabled    
}
function get-SecureZoneStatus($DhcpServerInstance, $Scopes, $dnsdomainTable, $dnsServerList, $invalidServerlist,$invalidDomain, $isIPv4)
{
    $dnsdomainhash = @()
    $isAccessDenied = $false
    $scopeList = @()
    $dhciddisabled = 0
    $SecureDynDnsUpdateConfgSingleScope = $false
    $isPrecondition = $false

    foreach($scope in $Scopes)
    {
	$isNameProtectionEnabled = get-NameProtectionStatus $scope $isIPv4
	if($isNameProtectionEnabled -eq $false)
        {
            $dhciddisabled = $dhciddisabled + 1
	}
	
	$domainname = $dnsdomainTable[$scope.Address]
	$dnsList = $dnsServerlist[$scope.Address]
	$SecureDynamicDnsUpdateConfigured = $false
        $IsFlag = $false 

	# if both options do not exist cannot find the dns update secure status
	if($domainname -ne $Null -and $dnsList.count -ne 0)
	{
	    foreach($srv in $dnsList)
	    {
		if(-not($invalidServerlist -contains $srv) -and -not($domainname -eq $invalidDomain[$scope.Address])  )
		{
		    $newPair = @{dns = $srv; domain = $domainname}
		    $alreadyChecked, $flagValue = CheckforDuplicate $dnsdomainhash $newPair
                    
                    if($isNameProtectionEnabled -eq $true)
                    {
                       $IsFlag = $true  
                       $isPrecondition = $true
                    }
 
		    if($alreadyChecked -eq $false)
	            {  
 
  		        try {
  		            $result = get-wmiobject -namespace "root\MicrosoftDNS" -class "MicrosoftDNS_Zone" -computerName $srv -Filter "ContainerName = '$domainname' and DsIntegrated = 'True' and AllowUpdate = 2"
		        }
		        catch {
			    $isAccessDenied = $true
			    return $scopeList, $dhciddisabled, $SecureDynDnsUpdateConfgSingleScope, $isAccessDenied
		        }
			$dnsdomainhash = $dnsdomainhash + @($newPair)
		        if($result -ne $Null)
		        {
			    $SecureDynamicDnsUpdateConfigured = $true
			    $newPair.flag = $true
			    break
		        }	
			else
			{
			    $SecureDynamicDnsUpdateConfigured = $false
		  	    $newPair.flag = $false
			}
		    }
		    else
  		    {
			if($flagValue -eq $true)
			{
			    $SecureDynamicDnsUpdateConfigured = $true
			}
		    }
		}
	    }
            if(($SecureDynamicDnsUpdateConfigured -eq $false) -and ($isNameProtectionEnabled -eq $true) -and ($IsFlag -eq $true))
	    {
	        if(-not($scopeList -contains $scope.Address.IPAddressToString))
	        {
		    $scopeList = $scopeList + @($scope.Address.IPAddressToString)
	    	}
	    }
	    if($SecureDynamicDnsUpdateConfigured -eq $true)
  	    {
                $SecureDynDnsUpdateConfgSingleScope = $true					
	    }
	}
    }
    return $scopeList, $dhciddisabled, $SecureDynDnsUpdateConfgSingleScope, $isAccessDenied , $isPrecondition
}	
function get-DistinguishedName($domain)
{
    $root = ""
    $dcs = $domain.split('.')
    foreach ($dc in $dcs)
    {
	$root = $root + 'DC=' + $dc + ','
    }
    $root = $root.substring(0,$root.length-1)
    return $root
}
function get-DhcpServerMemberStatus($domain)
{
    $root = get-DistinguishedName ($domain -as [string])
    $isDc = get-DomainControllerStatus
    if($isDc -eq $false)
    {	
    	$localdistinguishedname = 'CN=' + $env:COMPUTERNAME + ',CN=Computers,' + $root   
    }	
    else
    {
	$localdistinguishedname = 'CN=' + $env:COMPUTERNAME + ',OU=Domain Controllers,' + $root   
    }
    try {
	$Group = [ADSI]("LDAP://CN=DnsUpdateProxy, CN=Users,"+ $root)
    	$members = $Group.member
		
	foreach($member in $members)
        {
	    if($member -eq $localdistinguishedname)
    	    {
		return $true, $false
    	    }
        }
    }
    catch {
	return $false, $true
    }
    return $false, $false
    
}
function get-ScopeString($scopeList, $scopeStateTable, $strBpa)
{
    $strScope = [System.String]::Empty
    if($scopeList -ne $Null)
    {
	foreach($scope in $scopeList)
	{
	    if($scopeStateTable[$scope] -eq [Dhcp.DHCP_SUBNET_STATE]::DhcpSubnetEnabled)
	    {
		$strScope = $strScope + $scope + '(' + $strBpa.strActive + ') ' 
	    }
	    else
	    {
		$strScope = $strScope + $scope + '(' + $strBpa.strInactive + ') '
	    }
        }
    }	
    return $strScope 
}
function get-InvalidDnsServerScopeString($dnsServerTable, $invalidServerList, $scopeStateTable, $strBpa, $dnsServerLevel )
{
    $outputString = [System.String]::Empty
    $flag = $false
    foreach($srv in $invalidServerList)
    {
	foreach($scope in $dnsServerTable.Keys) 
	{
	    if($dnsServerTable[$scope] -contains $srv)
	    {
                if ($dnsServerLevel[$scope] -eq $false -and $flag -eq $false)
                {
                    $outputString =  $srv + ' ' + $strBpa.strServer + ', ' + $outputString
                    $flag = $true
                } 
		
                if($dnsServerLevel[$scope] -eq $true)
                {
                   if($scopeStateTable[$scope] -eq [Dhcp.DHCP_SUBNET_STATE]::DhcpSubnetEnabled)
	    	   {
		      $outputString = $outputString + ' ' + $srv  + ' ' + $scope + '(' + $strBpa.strActive + '), ' 
	    	   }
	    	   else
	    	   {
		      $outputString = $outputString + ' ' + $srv + ' ' + $scope + '(' + $strBpa.strInactive + '), '
	    	   }
                }
   	    }
	}
    }
    return $outputString
}
function get-InvalidDomainNameScopeString($invalidDomainList, $scopeStateTable, $strBpa,$domainListLevel)
{
    $outputString = [System.String]::Empty
    $flag = $false

    foreach($scope in $invalidDomainList.Keys)
    {

        if ($domainListLevel[$scope] -eq $false -and $flag -eq $false)
        {
            $outputString =  $invalidDomainList[$scope] + ' ' + $strBpa.strServer + ', ' + $outputString 
            $flag = $true
        }       
	
        if ($domainListLevel[$scope] -eq $true)
        { 
	    if($scopeStateTable[$scope] -eq [Dhcp.DHCP_SUBNET_STATE]::DhcpSubnetEnabled)
            {
	        $outputString = $outputString + ' ' + $invalidDomainList[$scope]  + ' ' + $scope + '(' + $strBpa.strActive + '), '
            }
            else
            {
    	        $outputString = $outputString + ' ' + $invalidDomainList[$scope] + ' ' + $scope + '(' + $strBpa.strInactive + '), '
            }
        }
    }
    return $outputString
}
function get-ScopeHashTable($scopes)
{
    $scopeStatetable = @{}
    foreach($scope in $scopes)
    {
        $scopeStateTable[$scope.Address.IPAddressToString] = $scope.State
    }  
    return $scopeStatetable
}
function get-RegistryPathPermissions($path)
{
    $acls = Get-Acl $path
    foreach($access in $acls.Access)
    {
	if($access.IdentityReference -match "NT SERVICE\\DHCPServer")
	{
	    if(($access.RegistryRights -eq [System.Security.AccessControl.RegistryRights]::FullControl) -and ($access.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow))
   	    {
		return $true
  	    }
	}
    }
    return $false
}
function get-PathPermissions($path)
{
    $acls = Get-Acl $path
    foreach($access in $acls.Access)
    {
	if($access.IdentityReference -match "NT SERVICE\\DHCPServer") 
	{
   	    if(($access.FileSystemRights -eq [System.Security.AccessControl.FileSystemRights]::FullControl) -and ($access.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow))
  	    {
		return $true
	    }
	}
    }
    return $false
}
function create-OpenedPortsNode($doc, $NodeServerConfig, $Protocol, $OpenedPortString, $ports)
{	
    $count = 0
    if($ports -ne $Null)
    {
	foreach ($port in $ports)
	{
	    $count = $count + 1
	}
    }
    $NodeOpenedPorts = $doc.CreateElement($OpenedPortString,$tns)
    [void]$NodeServerConfig.AppendChild($NodeOpenedPorts)

    $NodePortNumber = $doc.CreateElement("Number",$tns)
    [void]$NodeOpenedPorts.AppendChild($NodePortNumber)
    set-XmlElementInnerText -ElementNode $NodePortNumber -ElementValue $count

    $NodeProtocol = $doc.CreateElement("Protocol",$tns)
    [void]$NodeOpenedPorts.AppendChild($NodeProtocol)
    set-XmlElementInnerText -ElementNode $NodeProtocol -ElementValue $Protocol

    if($ports -ne $Null)
    {
	foreach ($port in $ports)
	{
 	    $NodeOpenedPort = $doc.CreateElement("OpenedPort",$tns)
            [void]$NodeOpenedPorts.AppendChild($NodeOpenedPort)
					
	    $NodePort = $doc.CreateElement("Port", $tns)
	    [void]$NodeOpenedPort.AppendChild($NodePort)
  	    set-XmlElementInnerText -ElementNode $NodePort -ElementValue $port.LocalPort

   	    $NodePid = $doc.CreateElement("PID", $tns)
   	    [void]$NodeOpenedPort.AppendChild($NodePid)
	    set-XmlElementInnerText -ElementNode $NodePid -ElementValue $port.Pid

  	    $NodeInterface = $doc.CreateElement("Interface", $tns)
	    [void]$NodeOpenedPort.AppendChild($NodeInterface)
	    set-XmlElementInnerText -ElementNode $NodeInterface -ElementValue $port.LocalAddress
	}
    }
}
function set-DomainOptionInfo($Options,$Protocol,$Id)
{
    $NodeDnsDomainOption = $doc.CreateElement("DnsDomainOption",$tns)
    [void]$NodeServerConfig.AppendChild($NodeDnsDomainOption)

    $NodeDnsDomainOptionProtocol = $doc.CreateElement("Protocol",$tns)
    [void]$NodeDnsDomainOption.AppendChild($NodeDnsDomainOptionProtocol)
    set-XmlElementInnerText -ElementNode $NodeDnsDomainOptionProtocol -ElementValue $Protocol

    if ([System.String]::IsNullOrEmpty($Options) -ne $true)
    {
	$NodeDnsDomainOptionId = $doc.CreateElement("OptionId",$tns)
    	[void]$NodeDnsDomainOption.AppendChild($NodeDnsDomainOptionId)
    	set-XmlElementInnerText -ElementNode $NodeDnsDomainOptionId -ElementValue $Id

	$NodeDnsDomainOptionScopes = $doc.CreateElement("Scopes",$tns)
        [void]$NodeDnsDomainOption.AppendChild($NodeDnsDomainOptionScopes)
        set-XmlElementInnerText -ElementNode $NodeDnsDomainOptionScopes -ElementValue $Options
    } 
}
function set-DnsServerOptionInfo($Options,$Protocol,$Id)
{
    $NodeDnsServerOption = $doc.CreateElement("DnsServerOption",$tns)
    [void]$NodeServerConfig.AppendChild($NodeDnsServerOption)

    $NodeDnsServerOptionProtocol = $doc.CreateElement("Protocol",$tns)
    [void]$NodeDnsServerOption.AppendChild($NodeDnsServerOptionProtocol)
    set-XmlElementInnerText -ElementNode $NodeDnsServerOptionProtocol -ElementValue $Protocol

    if ([System.String]::IsNullOrEmpty($Options) -ne $true)
    {
	$NodeDnsServerOptionId = $doc.CreateElement("OptionId",$tns)
    	[void]$NodeDnsServerOption.AppendChild($NodeDnsServerOptionId)
    	set-XmlElementInnerText -ElementNode $NodeDnsServerOptionId -ElementValue $Id
    
        $NodeDnsServerOptionScopes = $doc.CreateElement("Scopes",$tns)
        [void]$NodeDnsServerOption.AppendChild($NodeDnsServerOptionScopes)
        set-XmlElementInnerText -ElementNode $NodeDnsServerOptionScopes -ElementValue $Options
    }
}
function set-DefaultOptionInfo($Options,$Protocol)
{
    $NodeDefaultGatewayOption = $doc.CreateElement("DefaultGateway",$tns)
    [void]$NodeServerConfig.AppendChild($NodeDefaultGatewayOption)

    $NodeDefaultGatewayOptionProtocol = $doc.CreateElement("Protocol",$tns)
    [void]$NodeDefaultGatewayOption.AppendChild($NodeDefaultGatewayOptionProtocol)

    set-XmlElementInnerText -ElementNode $NodeDefaultGatewayOptionProtocol -ElementValue $Protocol
    if ([System.String]::IsNullOrEmpty($Options) -ne $true)
    {
        $NodeDefaultGatewayOptionScopes = $doc.CreateElement("Scopes",$tns)
        [void]$NodeDefaultGatewayOption.AppendChild($NodeDefaultGatewayOptionScopes)
        set-XmlElementInnerText -ElementNode $NodeDefaultGatewayOptionScopes -ElementValue $Options
    } 
}
function set-ScopesDeactivated($scopes,$protocol)
{
    $scopeList = @()
    $Status = $true
    $NodeScopeDeactivated = $doc.CreateElement("ScopesDeactivated",$tns)
    [void]$NodeServerConfig.AppendChild($NodeScopeDeactivated)
 
    foreach($scope in $scopes)
    {
	if($scope.State -ne [Dhcp.DHCP_SUBNET_STATE]::DhcpSubnetEnabled)
	{
            $scopeList = $scopeList + @($scope.Address.IPAddressToString)
            $Status = $false
        }  
    }  
    $NodeProtocol = $doc.CreateElement("Protocol", $tns)
    [void]$NodeScopeDeactivated.AppendChild($NodeProtocol)    
    set-XmlElementInnerText -ElementNode $NodeProtocol -ElementValue $protocol   

    if($Status -eq $false)
    {
        $NodeScopeList = $doc.CreateElement("Scopes",$tns)
        [void]$NodeScopeDeactivated.AppendChild($NodeScopeList)
        set-XmlElementInnerText -ElementNode $NodeScopeList -ElementValue $scopeList   
    } 
}
function set-PathInformation($PathNodeName, $Path)
{
    $NodePathPermissions = $doc.CreateElement($PathNodeName, $tns)
    [void]$NodeServerConfig.AppendChild($NodePathPermissions)

    $state = Test-Path $Path
    if($state -eq $true)
    {
	$NodePath = $doc.CreateElement("Path", $tns)
        [void]$NodePathPermissions.AppendChild($NodePath)
        set-XmlElementInnerText -ElementNode $NodePath -ElementValue $Path
    }
    $NodeHasPermissions = $doc.CreateElement("HasPermissions", $tns)
    [void]$NodePathPermissions.AppendChild($NodeHasPermissions)
    if($state -eq $false)
    {
	$pathhaspermissions = $false
    }
    else
    {
    	$pathhaspermissions = get-PathPermissions $Path
    }	
    set-XmlElementInnerText -ElementNode $NodeHasPermissions -ElementValue $pathhaspermissions
}


call-TCPIPQueryPorts
$PortsInfo = New-Object TCPIP.PortInformation
$UdpV4Table = $PortsInfo.GetUdpTable();
$UdpV6Table = $PortsInfo.GetUdpV6Table();

call-DhcpQuery
$DHCPServerInstance = New-Object Dhcp.DhcpServer ""

# this fn is called at the beginning to accomodate the scenario when DHCP Server
# is restarted , the first api call fails. This call will call a DHCP api which 
# is not being used, but will take care of the failure.
$rpc = $DHCPServerInstance.InitializeRpc();

call-DnsValidate
$DnsValid = New-Object DnsValidation.DnsValidationStatus

$tns="http://schemas.microsoft.com/bestpractices/models/ServerManager/DHCP/DHCPServer/2008/12"
# create a new XmlDocument
$doc = Create-DocumentElement $tns "DHCPSERVER"

$NodeDhcp = setXmlElement $doc $doc.DocumentElement $tns "DHCP"

$NodeServerStatus = setXmlElement $doc $NodeDhcp $tns "DhcpServerStatus"
$servicestate = get-ServiceStatus
set-XmlElementInnerText -ElementNode $NodeServerStatus -ElementValue $servicestate
$ErrorValue = 0

$dhcpSecGroups = get-SecurityGroups
$isRogueDetectionEnabled = get-RogueDetectionEnabled

$registryPathPermissions = get-RegistryPathPermissions "hklm:\system\currentcontrolset\services\dhcpserver\parameters"

if ($servicestate -eq [System.ServiceProcess.ServiceControllerStatus]::Stopped)
{
    $registryOutput = Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\DHCPServer\Parameters
    $databasePath = $registryOutput.DatabasePath 
    $backuppath = $registryOutput.BackupDatabasePath
    $auditlogpath = $registryOutput.DhcpLogFilePath
    if($auditlogpath -eq $null)
    {
       # the default value is the same as databasepath
       $auditlogpath = $registryOutput.DatabasePath  
    }

    $databasePathFile = $registryOutput.DatabasePath + "\" + $registryOutput.DatabaseName
    $auditLogEnabled = $registryOutput.ActivityLogFlag
    
    if($auditLogEnabled -eq $null)
    {
        $auditLogEnabled = 1
    }

    if($auditLogEnabled -eq 0)
    {
        $auditLogEnabled = $false
    } else {
        $auditLogEnabled = $true
    }


    $dhcpDupAddDetection = $registryOutput.DetectConflictRetries
    if($dhcpDupAddDetection -eq $null)
    {
        $dhcpDupAddDetection = 0
    }

    $NodeDatabaseStatus = setXmlElement $doc $NodeDhcp $tns "DhcpDatabaseStatus"
    $state = $DHCPServerInstance.CheckDatabaseStatus($databasePathFile);
    set-XmlElementInnerText -ElementNode $NodeDatabaseStatus -ElementValue $state

    $NodeRegistryPermissions = setXmlElement $doc $NodeDhcp $tns "DhcpRegistryPathHasPerm"
    set-XmlElementInnerText -ElementNode $NodeRegistryPermissions -ElementValue $registryPathPermissions

    $NodeServerConfig = setXmlElement $doc $NodeDhcp $tns "ServerConfiguration"

    set-PathInformation "DhcpDatabasePath" $databasepath
    set-PathInformation "DhcpDatabaseBackupPath" $backuppath
    set-PathInformation "DhcpAuditlogPath" $auditlogpath

    # Creating XML for AuditLog Enabled/Disabled Status
    $NodeAuditLog = $doc.CreateElement("AuditLog",$tns)
    [void]$NodeServerConfig.AppendChild($NodeAuditLog)
    set-XmlElementInnerText -ElementNode $NodeAuditLog -ElementValue $auditLogEnabled

    # Creating XML for RogueDetection Enabled/Disabled Status
    $NodeRogueDetection = $doc.CreateElement("RogueDetectionEnabled",$tns)
    [void]$NodeServerConfig.AppendChild($NodeRogueDetection)
    set-XmlElementInnerText -ElementNode $NodeRogueDetection -ElementValue $isRogueDetectionEnabled 

    # Creating XML for Duplicate Address detection
    $NodeDupAddDetection = $doc.CreateElement("DuplicateAddressDetection",$tns)
    [void]$NodeServerConfig.AppendChild($NodeDupAddDetection)
    set-XmlElementInnerText -ElementNode $NodeDupAddDetection -ElementValue $dhcpDupAddDetection

    $NodeSecGroups = $doc.CreateElement("DhcpSecurityGroups",$tns)
    [void]$NodeServerConfig.AppendChild($NodeSecGroups)
    set-XmlElementInnerText -ElementNode $NodeSecGroups -ElementValue $dhcpSecGroups


}


if($servicestate -eq [System.ServiceProcess.ServiceControllerStatus]::Running -or $servicestate -eq [System.ServiceProcess.ServiceControllerStatus]::Paused)
{

    $NodeRegistryPermissions = setXmlElement $doc $NodeDhcp $tns "DhcpRegistryPathHasPerm"
    set-XmlElementInnerText -ElementNode $NodeRegistryPermissions -ElementValue $registryPathPermissions

    $NodeServerConfig = setXmlElement $doc $NodeDhcp $tns "ServerConfiguration"
    $NodePID = setXmlElement $doc $NodeServerConfig $tns "DhcpServerPID"
    $dhcppid = get-ServerPID
    set-XmlElementInnerText -ElementNode $NodePID -ElementValue $dhcppid

    try {
    
    $DHCPServerInstance.InitializeServer();
    $isV4Bound = $DHCPServerInstance.GetV4BindingStatus();
    $isV6Bound = $DHCPServerInstance.GetV6BindingStatus();
    $V4bindings = $DHCPServerInstance.GetV4Bindings();
    $V6bindings = $DHCPServerInstance.GetV6Bindings();
    $V4Scopes = $DHCPServerInstance.GetV4Scopes();
    $V4ScopeHashTable = get-ScopeHashTable $V4Scopes
    $V6Scopes = $DHCPServerInstance.GetV6Scopes();
    $V6ScopeHashTable = get-ScopeHashTable $V6Scopes
     
    #Create Binding Node
    $NodeBindings = $doc.CreateElement("Bindings",$tns)
    [void]$NodeServerConfig.AppendChild($NodeBindings)  
    #Create V4 Binding Status Node
    $NodeV4Binding = $doc.CreateElement("V4Binding",$tns)
    [void]$NodeBindings.AppendChild($NodeV4Binding)
    set-XmlElementInnerText -ElementNode $NodeV4Binding -ElementValue $isV4Bound
    #Create V6 Binding Status Node
    $NodeV6Binding = $doc.CreateElement("V6Binding",$tns)
    [void]$NodeBindings.AppendChild($NodeV6Binding)
    set-XmlElementInnerText -ElementNode $NodeV6Binding -ElementValue $isV6Bound
    #Create V4 Scope Existence Node.
    $NodeV4ScopeExists = $doc.CreateElement("V4ScopeExists", $tns)
    [void]$NodeServerConfig.AppendChild($NodeV4ScopeExists)
    $V4ScopesExist = ($V4Scopes.count -ne 0)
    set-XmlElementInnerText -ElementNode $NodeV4ScopeExists -ElementValue $V4ScopesExist
    #Create V6 Scope Existence Node.
    $NodeV6ScopeExists = $doc.CreateElement("V6ScopeExists", $tns)
    [void]$NodeServerConfig.AppendChild($NodeV6ScopeExists)
    $V6ScopesExist = ($V6scopes.count -ne 0)
    set-XmlElementInnerText -ElementNode $NodeV6ScopeExists -ElementValue $V6ScopesExist
    #Create V6 Server Level Option Existence Node.
    $NodeV6OptionExists = $doc.CreateElement("V6OptionExists", $tns)
    [void]$NodeServerConfig.AppendChild($NodeV6OptionExists)
    $numOptions = $DHCPServerInstance.GetServerOptionsV6Count();
    $V6OptionsExist = $numOptions -ne 0
    set-XmlElementInnerText -ElementNode $NodeV6OptionExists -ElementValue $V6OptionsExist
	
    # Check for Database, Databasebackup, Auditlog Path existence and permissions
    $databasepath = $DHCPServerInstance.GetDatabasePath() 
    set-PathInformation "DhcpDatabasePath" $databasepath
    
    $backuppath = $DHCPServerInstance.GetBackUpPath();
    set-PathInformation "DhcpDatabaseBackupPath" $backuppath
	
    $auditlogpath = $DHCPServerInstance.GetAuditlogPath();
    set-PathInformation "DhcpAuditlogPath" $auditlogpath
	

    # Creating XML for AuditLog Enabled/Disabled Status
    $NodeAuditLog = $doc.CreateElement("AuditLog",$tns)
    [void]$NodeServerConfig.AppendChild($NodeAuditLog)
    $isAuditLogEnabled = $DHCPServerInstance.GetAuditLogStatus();
    set-XmlElementInnerText -ElementNode $NodeAuditLog -ElementValue $isAuditLogEnabled

    # Creating XML for Server being Domain Joined
    $NodeDomainJoined = $doc.CreateElement("DhcpDomainJoined",$tns)
    [void]$NodeServerConfig.AppendChild($NodeDomainJoined)
    $dhcpdomainjoined = get-ServerDomainJoined
    set-XmlElementInnerText -ElementNode $NodeDomainJoined -ElementValue $dhcpdomainjoined

    # Creating XML for Server Authorization Status
    $NodeADAuth = $doc.CreateElement("DhcpServerADAuthorization",$tns)
    [void]$NodeServerConfig.AppendChild($NodeADAuth)
    $dhcpADauth = $DHCPServerInstance.IsAuthorized()
    set-XmlElementInnerText -ElementNode $NodeADAuth -ElementValue $dhcpADauth

    # Creating XML for RogueDetection Enabled/Disabled Status
    $NodeRogueDetection = $doc.CreateElement("RogueDetectionEnabled",$tns)
    [void]$NodeServerConfig.AppendChild($NodeRogueDetection)
    set-XmlElementInnerText -ElementNode $NodeRogueDetection -ElementValue $isRogueDetectionEnabled 

    # Creating XML for DHCP Port Checks
    if($isV4Bound -eq $true)
    {
	$ports = get-V4OpenedPorts ([Dhcp.SOCKET_PORTS]::DHCP_CLIENT) $UdpV4Table $V4bindings $dhcppid
    	create-OpenedPortsNode $doc $NodeServerConfig "IPV4" "RogueDetection" $ports
    }
    if($isV6Bound -eq $true)
    {
	$ports = get-V6OpenedPorts ([Dhcp.SOCKET_PORTS]::DHCPV6_CLIENT) $UdpV6Table $V6bindings $dhcppid
    	create-OpenedPortsNode $doc $NodeServerConfig "IPV6" "RogueDetection" $ports
    }
    if($isV4Bound -eq $true)
    {
    	$ports = get-V4OpenedPorts ([Dhcp.SOCKET_PORTS]::DHCP_SERVER) $UdpV4Table $V4bindings $dhcppid
    	create-OpenedPortsNode $doc $NodeServerConfig "IPV4" "OpenedPorts" $ports
    }
    if($isV6Bound -eq $true)
    {
    	$ports = get-V6OpenedPorts ([Dhcp.SOCKET_PORTS]::DHCPV6_SERVER) $UdpV6Table $V6bindings $dhcppid
    	create-OpenedPortsNode $doc $NodeServerConfig "IPV6" "OpenedPorts" $ports
    }	
    # Creating XML for Scope IP Range
    $scopeList = get-ScopesWithoutIpRange $V4Scopes
    if($scopeList -ne $Null)
    {
	$NodeScopeNoIpRange = $doc.CreateElement("ScopesWithoutIpRange",$tns)
    	[void]$NodeServerConfig.AppendChild($NodeScopeNoIpRange)
	$strScope = get-ScopeString $scopeList $V4ScopeHashTable $_system_translations
    	set-XmlElementInnerText -ElementNode $NodeScopeNoIpRange -ElementValue $strScope
    }	
    # Creating XML for Scope Activated/Deactivated State
    if($V4ScopesExist -eq $true)
    {
	set-ScopesDeactivated $V4Scopes "IPv4"
    }	
    if($V6ScopesExist -eq $true)
    {
    	set-ScopesDeactivated $V6Scopes "IPv6"
    }	
    # Creating XML for Server IP Exclusion
    $strServerExclusion = [system.string]::Empty
    foreach ($scope in $V4Scopes)
    {
        $includedBindings = $DHCPServerInstance.CheckV4BindingsExcluded($scope);
        if($includedBindings -ne $NULL)
        {
            foreach ($obj in $includedBindings)
            {
		if($V4ScopeHashTable[$scope.Address.IPAddressToString] -eq [Dhcp.DHCP_SUBNET_STATE]::DhcpSubnetEnabled)
 	        {
	 	    $strServerExclusion = $strServerExclusion + '(' + $obj.IPAddressToString + ',' + $scope.Address.IPAddressToString + '(' + $_system_translations.strActive + ')' + ') ' 
		}
		else
		{
		    $strServerExclusion = $strServerExclusion + '(' + $obj.IPAddressToString + ',' + $scope.Address.IPAddressToString + '(' + $_system_translations.strInActive + ')' + ') '
		}
            }
        }
    }
    if([system.string]::IsNullOrEmpty($strServerExclusion) -ne $true)
    {
    	$NodeV4ServerIPExcl = $doc.CreateElement("ServerIPV4Excl",$tns)
    	[void]$NodeServerConfig.AppendChild($NodeV4ServerIPExcl)
        set-XmlElementInnerText -ElementNode $NodeV4ServerIPExcl -ElementValue $strServerExclusion
    }	
    $strServerExclusion = [system.string]::Empty
    foreach ($scope in $V6Scopes)
    {
        $includedBindings = $DHCPServerInstance.CheckV6BindingsExcluded($scope);
        if($Null -ne $includedBindings)
        {
            foreach ($obj in $includedBindings)
            {
		if($V6ScopeHashTable[$scope.Address.IPAddressToString] -eq [Dhcp.DHCP_SUBNET_STATE]::DhcpSubnetEnabled)
 	        {
		    $strServerExclusion = $strServerExclusion + '(' + $obj.IPAddressToString + ' , ' + $scope.Address.IPAddressToString + '(' + $_system_translations.strActive + ')' + ') ' 
		}
		else
		{
		    $strServerExclusion = $strServerExclusion + '(' + $obj.IPAddressToString + ' , ' + $scope.Address.IPAddressToString + '(' + $_system_translations.strInActive + ')' + ') '
		}
            } 
        }
    }
    if([system.string]::IsNullOrEmpty($strServerExclusion) -ne $true)
    {
    	$NodeV6ServerIPExcl = $doc.CreateElement("ServerIPV6Excl",$tns)
    	[void]$NodeServerConfig.AppendChild($NodeV6ServerIPExcl)
        set-XmlElementInnerText -ElementNode $NodeV6ServerIPExcl -ElementValue $strServerExclusion
    }	
    # Creating XML for DnsCredentials
    if($V4ScopesExist -eq $true)
    {
 
        $scopeList = $DHCPServerInstance.IsV4DnsDynamicUpdateConfigured();
        $strScope = get-ScopeString $scopeList $V4ScopeHashTable $_system_translations
        if(  $strScope -ne [System.String]::Empty)
        {
          $NodeV4DnsDynamicUpdate = $doc.CreateElement("DnsV4DynamicUpdate",$tns)
    	  [void]$NodeServerConfig.AppendChild($NodeV4DnsDynamicUpdate)
          set-XmlElementInnerText -ElementNode $NodeV4DnsDynamicUpdate -ElementValue $strScope
        }
    }	
    if($V6ScopesExist -eq $true)
    {

        $scopeList = $DHCPServerInstance.IsV6DnsDynamicUpdateConfigured();
        $strScope = get-ScopeString $scopeList $V6ScopeHashTable $_system_translations
        if(  $strScope -ne [System.String]::Empty)
        {
           $NodeV6DnsDynamicUpdate = $doc.CreateElement("DnsV6DynamicUpdate",$tns)
    	   [void]$NodeServerConfig.AppendChild($NodeV6DnsDynamicUpdate)
           set-XmlElementInnerText -ElementNode $NodeV6DnsDynamicUpdate -ElementValue $strScope
        }
    }	

    # Creating XML for NAP and NPS Status 
    $NodeIAS = $doc.CreateElement("IAS",$tns)
    [void]$NodeServerConfig.AppendChild($NodeIAS)
    $NodeNapState = $doc.CreateElement("NAPState", $tns)
    [void]$NodeIAS.AppendChild($NodeNapState)
    set-XmlElementInnerText -ElementNode $NodeNapState -ElementValue $DHCPServerInstance.IsNAPEnabled()
    $NodeNPSState = $doc.CreateElement("NPSState", $tns)
    [void]$NodeIAS.AppendChild($NodeNPSState)
    $npsServerState = get-NPSServerStatus
    set-XmlElementInnerText -ElementNode $NodeNPSState -ElementValue $npsServerState

    # Creating XML for AllowFilter and AllowList Status
    $NodeAllowList = $doc.CreateElement("AllowList",$tns)
    [void]$NodeServerConfig.AppendChild($NodeAllowList)
    $filterSettings = $DHCPServerInstance.GetFilterStatus();
    $isallowConfigured = $DHCPServerInstance.IsAllowListConfigured();
    $AllowListStatus = $doc.CreateElement("Status", $tns)
    [void]$NodeAllowList.AppendChild($AllowListStatus)
    set-XmlElementInnerText -ElementNode $AllowListStatus -ElementValue $filterSettings.allowList
    $AllowListConfigured = $doc.CreateElement("List", $tns)
    [void]$NodeAllowList.AppendChild($AllowListConfigured)
    set-XmlElementInnerText -ElementNode $AllowListConfigured -ElementValue $isallowConfigured

    # Creating XML for MAC Filters and Reservations Conflict.
    $reservedMac = $DHCPServerInstance.CheckReservationInList();
    if($reservedMac -ne $NULL)
    { 
        foreach($res in $reservedMac)
        {
            $resString = $resString + '(' + $res.ReservedIp + ' , ' + $res.ClientUid + ') ' 
        }
        $NodeConflictReservations = $doc.CreateElement("ConflictReservations",$tns)
        [void]$NodeServerConfig.AppendChild($NodeConflictReservations)
    
        $NodeConflictReservationsStatus = $doc.CreateElement("Status", $tns)
        [void]$NodeConflictReservations.AppendChild($NodeConflictReservationsStatus)    
        set-XmlElementInnerText -ElementNode $NodeConflictReservationsStatus -ElementValue false

        $NodeConflictReservationsReservations = $doc.CreateElement("Reservations", $tns)
        [void]$NodeConflictReservations.AppendChild($NodeConflictReservationsReservations)    
        set-XmlElementInnerText -ElementNode $NodeConflictReservationsReservations -ElementValue $resString  
    }
    else
    {
        $NodeConflictReservations = $doc.CreateElement("ConflictReservations",$tns)
        [void]$NodeServerConfig.AppendChild($NodeConflictReservations)
    
        $NodeConflictReservationsStatus = $doc.CreateElement("Status", $tns)
        [void]$NodeConflictReservations.AppendChild($NodeConflictReservationsStatus)    
        set-XmlElementInnerText -ElementNode $NodeConflictReservationsStatus -ElementValue true
    } 

    # Creating XML for NAP and NPS Status 
    $NodeDupAddDetection = $doc.CreateElement("DuplicateAddressDetection",$tns)
    [void]$NodeServerConfig.AppendChild($NodeDupAddDetection)
    $dhcpDupAddDetection = $DHCPServerInstance.GetDetectConflictRetry();
    set-XmlElementInnerText -ElementNode $NodeDupAddDetection -ElementValue $dhcpDupAddDetection

    # Creating XML for NAP and NPS Status 
    $NodeSecGroups = $doc.CreateElement("DhcpSecurityGroups",$tns)
    [void]$NodeServerConfig.AppendChild($NodeSecGroups)
    set-XmlElementInnerText -ElementNode $NodeSecGroups -ElementValue $dhcpSecGroups

    # Creating XML for Scope Options

    if($V4ScopesExist -eq $true)
    {
    	$scopeList = get-DNSServerOptionV4 $DHCPServerInstance
	$strScope = get-ScopeString $scopeList $V4ScopeHashTable $_system_translations
    	set-DnsServerOptionInfo $strScope "IPv4" ([Dhcp.IPv4_OPTIONS]::DHCP_DNSSERVER -as [int])
    }
    if($V6ScopesExist -eq $true)
    {
    	$scopeList = get-DnsServerOptionV6 $DHCPServerInstance
    	$strScope = get-ScopeString $scopeList $V6ScopeHashTable $_system_translations
    	set-DNSServerOptionInfo $strScope "IPv6" ([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSSERVER -as [int])
    }
    if($V4ScopesExist -eq $true)
    {
    	$dnsV4ServerList , $dnsV4ServerListLevel = get-DnsServerListV4 $DHCPServerInstance $V4Scopes
	$dnsV4domainTable, $dnsV4domainTableLevel = get-DnsDomainListV4 $DHCPServerInstance $V4Scopes
	$validv4Serverlist, $invalidv4Serverlist, $preconditionTrue = get-InvalidDnsServers $DnsValid $dnsV4ServerList $dnsV4domainTable 
	if($preconditionTrue -eq $true)
	{
            $NodeInValidDnsServer = $doc.CreateElement("InvalidDnsIPV4Servers",$tns)
            [void]$NodeServerConfig.AppendChild($NodeInValidDnsServer)
	    $outputString = get-InvalidDnsServerScopeString $dnsV4ServerList $invalidv4Serverlist $V4ScopeHashTable	$_system_translations $dnsV4ServerListLevel 
	    set-XmlElementInnerText -ElementNode $NodeInValidDnsServer -ElementValue $outputString
	}
    }
    if($V6ScopesExist -eq $true)
    {
	$dnsV6ServerList, $dnsV6ServerListLevel = get-DnsServerListV6 $DHCPServerInstance $V6Scopes
        $dnsV6domainTable, $dnsV6domainTableLevel = get-DnsDomainListV6 $DHCPServerInstance $V6Scopes
	$validv6Serverlist, $invalidv6Serverlist, $preconditionTrue = get-InvalidDnsServers $DnsValid $dnsV6ServerList $dnsV6domainTable
	if($preconditionTrue -eq $true)
	{
	    $NodeInValidDnsServer = $doc.CreateElement("InvalidDnsIPV6Servers",$tns)
            [void]$NodeServerConfig.AppendChild($NodeInValidDnsServer)
	    $outputString = get-InvalidDnsServerScopeString $dnsV6ServerList $invalidv6Serverlist $V6ScopeHashTable	$_system_translations $dnsV6ServerListLevel
    	    set-XmlElementInnerText -ElementNode $NodeInValidDnsServer -ElementValue $outputString    
	}
    }	
    if($V4ScopesExist -eq $true)
    {
	$scopeList = get-DNSDomainOptionV4 $DHCPServerInstance
    	$strScope = get-ScopeString $scopeList $V4ScopeHashTable $_system_translations
    	set-DomainOptionInfo $strScope "IPv4" ([Dhcp.IPv4_OPTIONS]::DHCP_DNSDOMAINNAME -as [int])
    }
    if($V6ScopesExist -eq $true)
    {
	$scopeList = get-DNSDomainOptionV6 $DHCPServerInstance
   	$strScope = get-ScopeString $scopeList $V6ScopeHashTable $_system_translations
    	set-DomainOptionInfo $strScope "IPv6" ([Dhcp.IPv6_OPTIONS]::DHCPV6_DNSDOMAINNAME -as [int])
    }
    if($V4ScopesExist -eq $true)
    {
	$invalidV4Domains, $isPreconditionTrue, $isAccessDenied = get-ForwardZoneStatus $DhcpServerInstance $dnsV4domainTable $dnsV4ServerList $invalidv4Serverlist
	
        if($isPreconditionTrue -eq $true -and $isAccessDenied -ne $true)
        {
	    $NodeFwdZones = $doc.CreateElement("ForwardZonesV4Configured",$tns)
            [void]$NodeServerConfig.AppendChild($NodeFwdZones)
	    $invalidV4DomainString = get-InvalidDomainNameScopeString $invalidV4Domains $V4ScopeHashTable $_system_translations $dnsV4domainTableLevel
            set-XmlElementInnerText -ElementNode $NodeFwdZones -ElementValue $invalidV4DomainString
        }
	
        $V4scopeList, $dhcidV4disabled, $SecureDynamicDnsUpdateV4Configured, $isAccessDenied , $isPrecondition = get-SecureZoneStatus $DhcpServerInstance $V4Scopes $dnsV4domainTable $dnsV4ServerList $invalidv4Serverlist $invalidV4Domains $true 
	if($V4Scopes.count -ne 0 -and $dhcidV4disabled -ne $V4Scopes.count -and $isAccessDenied -ne $true -and $isPrecondition -eq $true)
        {
	    $NodeSecureZones = $doc.CreateElement("SecureDynamicV4Updates",$tns)
            [void]$NodeServerConfig.AppendChild($NodeSecureZones)
    	    $strScope = get-ScopeString $V4scopeList $V4ScopeHashTable $_system_translations
	    set-XmlElementInnerText -ElementNode $NodeSecureZones -ElementValue $strScope
        }
    }
    if($V6ScopesExist -eq $true)
    {
	
	$invalidV6Domains, $isPreconditionTrue, $isAccessDenied = get-ForwardZoneStatus $DhcpServerInstance $dnsV6DomainTable $dnsV6ServerList $invalidv6Serverlist
	
        if($isPreconditionTrue -eq $true -and $isAccessDenied -ne $true)
        {
	    $NodeFwdZones = $doc.CreateElement("ForwardZonesV6Configured",$tns)
            [void]$NodeServerConfig.AppendChild($NodeFwdZones)
	    $invalidV6DomainString = get-InvalidDomainNameScopeString $invalidV6Domains $V6ScopeHashTable $_system_translations $dnsV6domainTableLevel
	    set-XmlElementInnerText -ElementNode $NodeFwdZones -ElementValue $invalidV6DomainString
        }
        
        $V6scopeList, $dhcidV6disabled, $SecureDynamicDnsUpdateV6Configured, $isAccessDenied , $isPrecondition = get-SecureZoneStatus $DhcpServerInstance $V6Scopes $dnsV6domainTable $dnsV6ServerList $invalidv6Serverlist $invalidV6Domains $false
	if($V6Scopes.count -ne 0 -and $dhcidV6disabled -ne $V6Scopes.count -and $isAccessDenied -ne $true -and $isPrecondition -eq $true)
        {
	    $NodeSecureZones = $doc.CreateElement("SecureDynamicV6Updates",$tns)
            [void]$NodeServerConfig.AppendChild($NodeSecureZones)
    	    $strScope = get-ScopeString $V6scopeList $V6ScopeHashTable $_system_translations
	    set-XmlElementInnerText -ElementNode $NodeSecureZones -ElementValue $strScope
        }
    }	
    	 
    if($V4ScopesExist -eq $true)   
    {
	$preconditionMet = $false
	$isAccessDenied = $false
	$isDenied = $false
	$unsecuredomains = @{}
	foreach ($scope in $V4Scopes)	
	{
	    $nameProtectionStatus = get-NameProtectionStatus $scope $true
	    $domainName = $dnsV4domainTable[$scope.Address]
	    # precondition is partially met if domain name is not null and name protection status is true
	    if($domainName -ne '' -and $nameProtectionStatus -eq $true)
	    {
		# check for if DHCP Server is member of update proxy group in Ad for that particular domain name.
	 	$isMember, $isDenied = get-DhcpServerMemberStatus $domainName 	
		
		if($isMember -eq $true)
	        {
		    $preconditionMet = $true
		}
		# we do not have permissions to query AD Domain Group Membership. Do not print the rule
		if($isDenied -eq $true) 
		{
		    break
		}
		$isSecured, $isAccessDenied = get-DnsUpdateProxyGroupSecureStatus $domainName
		#we queried and the domain is not secured
  		if($isAccessDenied -eq $false -and $isSecured -eq $false -and $isMember -eq $true) 
	        {
		    $unsecuredomains[$scope.Address] = $domainName
	        }
		elseif($isAccessDenied -eq $true)
		{
		    break
		}
	        
	    }
	}
	if($preconditionMet -eq $true -and $isAccessDenied -eq $false -and $isDenied -eq $false)	
	{
	    $NodeDnsUpdateProxySecure = $doc.CreateElement("DnsUpdateProxySecuredV4",$tns)
            [void]$NodeServerConfig.AppendChild($NodeDnsUpdateProxySecure)
	    $unsecureV4DomainString = get-InvalidDomainNameScopeString $unsecuredomains $V4ScopeHashTable $_system_translations $dnsV4domainTableLevel
    	    set-XmlElementInnerText -ElementNode $NodeDnsUpdateProxySecure -ElementValue $unsecureV4DomainString
	}

    }
    if($V6ScopesExist -eq $true)   
    {
	$preconditionMet = $false
	$isAccessDenied = $false
	$isDenied = $false
	$unsecuredomains = @{}
	foreach ($scope in $V6Scopes)	
	{
	    $nameProtectionStatus = get-NameProtectionStatus $scope $false
	    $domainName = $dnsV6domainTable[$scope.Address]
	    # precondition is partially met if domain name is not null and name protection status is true
	    if($domainName -ne '' -and $nameProtectionStatus -eq $true)
	    {
		# check for if DHCP Server is member of update proxy group in Ad for that particular domain name.
	 	$isMember, $isDenied = get-DhcpServerMemberStatus $domainName 	
		
		if($isMember -eq $true)
	        {
		    $preconditionMet = $true
		}
		# we do not have permissions to query AD Domain Group Membership. Do not print the rule
		if($isDenied -eq $true) 
		{
		    break
		}
		$isSecured, $isAccessDenied = get-DnsUpdateProxyGroupSecureStatus $domainName
		#we queried and the domain is not secured
  		if($isAccessDenied -eq $false -and $isSecured -eq $false -and $isMember -eq $true) 
	        {
		    $unsecuredomains[$scope.Address] = $domainName
	        }
		elseif($isAccessDenied -eq $true)
		{
		    break
	        }
	    }
	}
	if($preconditionMet -eq $true -and $isAccessDenied -eq $false -and $isDenied -eq $false)	
	{
	    $NodeDnsUpdateProxySecure = $doc.CreateElement("DnsUpdateProxySecuredV6",$tns)
            [void]$NodeServerConfig.AppendChild($NodeDnsUpdateProxySecure)
	    $unsecureV6DomainString = get-InvalidDomainNameScopeString $unsecuredomains $V6ScopeHashTable $_system_translations $dnsV6domainTableLevel
    	    set-XmlElementInnerText -ElementNode $NodeDnsUpdateProxySecure -ElementValue $unsecureV6DomainString
	}
    }
    if(($SecureDynamicDnsUpdateV4Configured -eq $true) -or ($SecureDynamicDnsUpdateV6Configured -eq $true))
    {
	$isDomainController = get-DomainControllerStatus
	if($isDomainController -eq $true)
	{
	    $isDnscredentialsConfigured = $DHCPServerInstance.AreDnsCredentialsConfigured()
            $NodeDnsCredentials = $doc.CreateElement("DnsCredentials",$tns)
            [void]$NodeServerConfig.AppendChild($NodeDnsCredentials)
            set-XmlElementInnerText -ElementNode $NodeDnsCredentials -ElementValue $isDnscredentialsConfigured
	}
    }
    $scopeList = get-DefaultGatewayOption $DHCPServerInstance
    $strScope = get-ScopeString $scopeList $V4ScopeHashTable $_system_translations
    set-DefaultOptionInfo $strScope "IPv4"
	
    } # try block ends
    
    catch {
	$ErrorValue = $_.Exception.InnerException.ErrorCode 
	$ErrorText = $_.Exception.InnerException
    } 
}	
$NodeDhcpError = $doc.CreateElement("DhcpError",$tns)
[void]$NodeDhcp.AppendChild($NodeDhcpError)
set-XmlElementInnerText -ElementNode $NodeDhcpError -ElementValue $ErrorValue

if($ErrorValue -ne 0)
{
    $NodeDhcpErrorText = $doc.CreateElement("DhcpErrorText",$tns)
    [void]$NodeDhcp.AppendChild($NodeDhcpErrorText)
    set-XmlElementInnerText -ElementNode $NodeDhcpErrorText -ElementValue $ErrorText.Message
}

$doc