# Localized	05/07/2022 03:34 AM (GMT)	303:7.0.30723 	DHCPServer.psd1
# Only add new (name,value) pairs to the end of this table
# Do not remove, insert or re-arrange entries
   ConvertFrom-StringData @'
       ###PSLOC start localizing
       #
       # helpID = VersionTooLow
       #

BindingExists_title=DHCP: The server should be bound to at least one IP address.
BindingExists_problem=DHCP server is not bound to an IP address.
BindingExists_impact=A server that is not bound to an IP address cannot serve IP address leases or any other network configuration to DHCP clients.
BindingExists_resolution=By using the DHCP MMC snap-in, add bindings to one or more IP addresses.
BindingExists_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

BindingExistsV4_title=DHCP: The server should be bound to an IPv4 address
BindingExistsV4_problem=The DHCP server is not bound to an IPv4 address.
BindingExistsV4_impact=A server that is not bound to an IPv4 address cannot lease IPv4 addresses to DHCP clients.
BindingExistsV4_resolution=By using the DHCP MMC snap-in, add bindings to one or more IPv4 addresses.
BindingExistsV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

BindingExistsV6_title=DHCP: The server should be bound to an IPv6 address.
BindingExistsV6_problem=The DHCP server is not bound to an IPv6 address.
BindingExistsV6_impact=A server that is not bound to an IPv6 address cannot lease IPv6 addresses to DHCP clients.
BindingExistsV6_resolution=By using the DHCP MMC snap-in, add bindings to one or more IPv6 addresses.
BindingExistsV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

RegistryPermissions_title=DHCP: The server should have Full control permissions to the DHCP registry parameters.
RegistryPermissions_problem=The DHCP Server service does not have Full control permissions to the DHCP registry parameters.
RegistryPermissions_impact=The DHCP server might not be able to read its registry configuration and might not start.
RegistryPermissions_resolution=Assign Full control permissions for the DHCP registry to the DHCP Server service.
RegistryPermissions_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
DatabasePermissions_title=DHCP: The server should have Full control permissions to the database directory.
DatabasePermissions_problem=The configured  database directory does not exist or the DHCP server does not have Full control permissions to the database directory {0}.
DatabasePermissions_impact=The DHCP server cannot work without access to the database directory.
DatabasePermissions_resolution=Create the database directory path if it does not exist, and then assign the DHCP server Full control permissions.
DatabasePermissions_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DatabaseBackupPermissions_title=DHCP: The server should have Full control permissions to the backup directory.
DatabaseBackupPermissions_problem=The configured backup directory does not exist or the DHCP server does not have Full control permissions to the backup directory {0}.
DatabaseBackupPermissions_impact=The DHCP server cannot make periodic backups of the database without access to the backup directory.
DatabaseBackupPermissions_resolution=Create the backup directory path if it does not exist and assign the DHCP server Full control permissions.
DatabaseBackupPermissions_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

AuditlogPermissions_title=DHCP: The server should have Full control permissions to the audit log directory.
AuditlogPermissions_problem=The configured audit log directory does not exist or the DHCP server does not have Full control permissions to the audit log directory {0}.
AuditlogPermissions_impact=The DHCP server cannot log server activity without access to the audit log directory.
AuditlogPermissions_resolution=Create the audit log directory path if it does not exist and then assign the DHCP server Full control permissions.
AuditlogPermissions_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

Database_title=DHCP: The server database should be functional and free of errors.
Database_problem=The DHCP server failed to open the database and reported error {0}.
Database_impact=The DHCP service shuts down if its database reports an error while opening.
Database_resolution=Restore the last successfully backed up copy of the DHCP database from the backup directory.
Database_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.
 
RogueDetection_title=DHCP: Rogue detection should be enabled.
RogueDetection_problem=Rogue detection has been disabled on the DHCP server.
RogueDetection_impact=Disabling rogue detection can cause IP address conflicts.
RogueDetection_resolution=To enable rogue detection, set registry entry DisableRogueDetection under HKEY_LOCAL_MACHINE\\System\\CurrentControlSet\\Services\\DHCPServer\\Parameters to a value 0.
RogueDetection_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ADAuthExists_title=DHCP: The server should be authorized.
ADAuthExists_problem=This DHCP server is not authorized.
ADAuthExists_impact=If the DHCP server is not authorized, it cannot lease IP addresses to DHCP clients.
ADAuthExists_resolution=For a domain member computer, use the DHCP MMC snap-in to authorize this server in Active Directory Domain Services. For a workgroup computer, identify any other DHCP server on the network, and then determine which server is authoritative. Shut down the other server.
ADAuthExists_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

OpenedPortsV4_title=DHCP: Port 67 (DHCP server port for IPv4) should not be in use by any other process.
OpenedPortsV4_problem=Port 67 is in use by process id  {0}.
OpenedPortsV4_impact=If port 67 is in use by another process, the DHCP server cannot communicate with DHCPv4 clients.
OpenedPortsV4_resolution=Configure process ID {0} to use a port other than 67.
OpenedPortsV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

OpenedPortsV6_title=DHCP: Port 547 (DHCP server port for IPv6) should not be in use by any other process.
OpenedPortsV6_problem=Port 547  is in use by process id {0}.
OpenedPortsV6_impact=If port 547 is in use by another process, the DHCP server cannot communicate with DHCPv6 clients.
OpenedPortsV6_resolution=Configure process ID {0} to use a port other than 547.
OpenedPortsV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

RogueDetectionV4_title=DHCP: Port 68 (DHCP Client port for IPv4) should not be in use by any other process  while rogue detection is enabled.
RogueDetectionV4_problem=Port 68 is in use by  process id {0}.
RogueDetectionV4_impact=If port 68 is in use by another process, the DHCP server cannot perform rogue DHCP server detection in IPv4.
RogueDetectionV4_resolution=Configure process ID {0} to use a port other than 68.
RogueDetectionV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

RogueDetectionV6_title=DHCP: Port 546 (DHCP Client port for IPv6) should not be in use by any other process while rogue detection is enabled.
RogueDetectionV6_problem=Port 546 is in use by  process id {0}.
RogueDetectionV6_impact=If port 546 is in use by another process, the DHCP server cannot perform rogue DHCP server detection in IPv6.
RogueDetectionV6_resolution=Configure process ID {0} to use a port other than 546.
RogueDetectionV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ScopesV4_title=DHCP: The server should have at least one IPv4 scope.
ScopesV4_problem=The DHCP server does not have an IPv4 scope configured.
ScopesV4_impact=The DHCPv4 server cannot lease IP addresses to DHCP clients unless a scope is configured.
ScopesV4_resolution=Configure an IPv4 scope by using the DHCP MMC snap-in.
ScopesV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ScopesV6_title=DHCP: The server should have at least one IPv6 scope or server option configured.
ScopesV6_problem=The DHCP server does not have an IPv6 scope or server option configured.
ScopesV6_impact=The DHCPv6 server cannot service DHCP client request unless a scope or server option is configured.
ScopesV6_resolution=Configure an IPv6 scope or a server option using the DHCP MMC snap-in.
ScopesV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

IpRangeExists_title=DHCP: An IP address range should be defined for all scopes.
IpRangeExists_problem=The following scopes do not have an IP address range defined: {0}.
IpRangeExists_impact=A scope is unusable without an IP address range.
IpRangeExists_resolution=Configure an IP address range for the scope using the DHCP MMC snap-in.
IpRangeExists_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ScopesDeactivated_title=DHCP: All {0} configured scopes should be active
ScopesDeactivated_problem=The DHCP server has the following inactive scopes: {1}.
ScopesDeactivated_impact=If a scope is inactive, the DHCP server cannot lease IP addresses to clients in the scope.
ScopesDeactivated_resolution=Activate the scopes using the DHCP MMC snap-in.
ScopesDeactivated_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DAD_title=DHCP: IP Address conflict detection should have a value less than 4.
DAD_problem=IP address conflict detection  has been set to a value greater than 3.
DAD_impact=Conflict detection with a value greater than 3 can lead to slow performance of the DHCP server.
DAD_resolution=Set the IP address conflict detection value to 3 or less using DHCP MMC snap-in.
DAD_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DhcpSecurityGroups_title=DHCP: Security Groups (DHCP Administrators and DHCP Users) required for DHCP administration should be created.
DhcpSecurityGroups_problem=Security Groups (DHCP Administrator and DHCP Users) do not exist for this DHCP server.
DhcpSecurityGroups_impact=DHCP administration and monitoring privileges cannot be assigned to other user accounts on the server.
DhcpSecurityGroups_resolution=Use the add securitygroups command in Netsh to create the DHCP security groups.
DhcpSecurityGroups_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ServerIPV4Excl_title=DHCP: The server IPv4 address should be excluded from all scopes.
ServerIPV4Excl_problem=The following address conflicts have been found (Server IP address, Scope): {0}.
ServerIPV4Excl_impact=The DHCP server might lease its own static IP address to a client computer, leading to an IP address conflict and disruption of DHCP service.
ServerIPV4Excl_resolution=Use the DHCP MMC snap-in to exclude the DHCP server IPv4 addresses from the scope.
ServerIPV4Excl_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ServerIPV6Excl_title=DHCP: The server IPv6 address should be excluded from all scopes.
ServerIPV6Excl_problem=The following address conflicts have been found (Server IP address, Scope): {0}.
ServerIPV6Excl_impact=The DHCP server might lease its own static IP address to a client computer, leading to an IP address conflict and disruption of DHCP service.
ServerIPV6Excl_resolution=Use the DHCP MMC snap-in to exclude the DHCP server IPv6 addresses from the scope.
ServerIPV6Excl_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

AuditLog_title=DHCP: Audit logging should be enabled.
AuditLog_problem=Audit logging is turned off on the DHCP server.
AuditLog_impact=The audit log cannot record DHCP server activity.
AuditLog_resolution=Enable audit logging by using the  DHCP MMC snap-in.
AuditLog_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsV4DynUpdate_title=DHCP: The server should be configured to register DNS records on behalf of DHCPv4 clients.
DnsV4DynUpdate_problem=Domain Name System (DNS) registrations of DHCPv4 client computers from the DHCP server have been disabled for the following scopes: {0}.
DnsV4DynUpdate_impact=The DHCP server cannot register DHCPv4 client names in DNS resulting in the inability to connect to these client computers by using host names unless the client computers are themselves registering DNS records.
DnsV4DynUpdate_resolution=Configure client computers to register with DNS or use the DHCP MMC snap-in to configure dynamic DNS updates on the DHCP server for DHCPv4.
DnsV4DynUpdate_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsV6DynUpdate_title=DHCP: The server should be configured to register DNS records on behalf of DHCPv6 clients.
DnsV6DynUpdate_problem=Domain Name System (DNS) registrations of DHCPv6 client computers from the DHCP server have been disabled for the following scopes: {0}.
DnsV6DynUpdate_impact=The DHCP server cannot register DHCPv6 client names in DNS resulting in the inability to connect to these client computers by using host names unless the client computers are themselves registering DNS records.
DnsV6DynUpdate_resolution=Configure client computers to register with DNS or use the DHCP MMC snap-in to configure dynamic DNS updates on the DHCP server for DHCPv6.
DnsV6DynUpdate_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsCredentials_title=DHCP: Credentials for DNS update should be configured if secure dynamic DNS update is enabled and the domain controller is on the same host as the DHCP server.
DnsCredentials_problem=Secure dynamic Domain Name System (DNS) update is configured, and a domain cotroller is running on the same host as the DHCP server, but credentials for DNS update are not configured.
DnsCredentials_impact=DNS registrations can fail if credentials for DNS update are not configured.
DnsCredentials_resolution=By using the DHCP MMC snap-in, configure credentials for dynamic DNS update.
DnsCredentials_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

AllowList_title=DHCP: If the allow list is enabled, MAC address filtering should be populated.
AllowList_problem=The allow list for MAC address filtering is enabled but the list does not contain any MAC addresses.
AllowList_impact=The DHCP server cannot lease IP addresses.
AllowList_resolution=Use the DHCP MMC snap-in to enter MAC addresses of DHCP clients in the allow list.
AllowList_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

ReservationConflict_title=DHCP: The MAC address filtering configuration should not block IP address reservations.
ReservationConflict_problem=The following reservations conflict with the configuration of MAC address filters (Reserved IP address, MAC address): {0}.
ReservationConflict_impact=The DHCP server cannot lease reserved IP addresses to clients with conflicting MAC address filters.
ReservationConflict_resolution=Use the DHCP MMC snap-in to change the MAC address filters so that reservations are not blocked.
ReservationConflict_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

IAS_title=DHCP: An NPS (Network Policy Server) should be installed if NAP (Network Access Protection) is enabled.
IAS_problem=NPS is either not installed or is unreachable.
IAS_impact=Network Access Protection (NAP) is not enforced by the DHCP server which may result in  non-compliant clients gaining, or compliant clients being denied, access to the network.
IAS_resolution=Install NPS if it is not already installed, and then ensure that the service is running.
IAS_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DefaultGateway_title=DHCP: The server should be configured to send the default gateway to all clients.
DefaultGateway_problem=The DHCP server does not have the default gateway option (option 3) set for the following scopes: {0}.
DefaultGateway_impact=The DHCP server cannot provide default gateway addresses to clients resulting in loss of connectivity for client computers.
DefaultGateway_resolution=Use the DHCP MMC snap-in to configure the default gateway option at each scope.
DefaultGateway_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsServerV4_title=DHCP: The DNS server option should be configured for all IPv4 scopes.
DnsServerV4_problem=The Domain Name System (DNS) server option (option 6) is not configured for the following scopes: {0}.
DnsServerV4_impact=DHCPv4 clients cannot resolve DNS names.
DnsServerV4_resolution=Configure DNS server as a scope option or server option by using the DHCP MMC snap-in.
DnsServerV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsServerV6_title=DHCP: The DNS server option should be configured for all IPv6 scopes.
DnsServerV6_problem=The Domain Name System (DNS) server option (option 23) is not configured for the following scopes: {0}.
DnsServerV6_impact=DHCPv6 clients cannot resolve DNS names.
DnsServerV6_resolution=Configure the DNS server as a scope option or server option by using the DHCP MMC snap-in.
DnsServerV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsV4ServerValidation_title=DHCP: The IPv4 addresses of the DNS server should be reachable.
DnsV4ServerValidation_problem=The following DNS server IP address(s) is/are unreachable. The DNS server IP addresess configured as a server option are represented as (DNS IP address, Server/Scope): {0}.
DnsV4ServerValidation_impact=DHCPv4 clients with an unreachable IP address cannot resolve DNS names.
DnsV4ServerValidation_resolution=Configure a different DNS server as a scope option or server option by using the DHCP MMC snap-in.
DnsV4ServerValidation_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsV6ServerValidation_title=DHCP: The IPv6 addresses of the DNS server should be reachable.
DnsV6ServerValidation_problem=The following DNS server IP address(s) is/are unreachable.  The DNS server IP addresess configured as a server option are represented as (DNS IP address, Server/Scope): {0}.
DnsV6ServerValidation_impact=DHCPv6 clients with an unreachable IP address will not be able to resolve DNS names.
DnsV6ServerValidation_resolution=Configure a different DNS server as a scope or server option using the DHCP MMC.
DnsV6ServerValidation_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsDomainOptionV4_title=DHCP: The DNS domain option should be configured as a scope or server option for DHCPv4.
DnsDomainOptionV4_problem=The DNS domain option (option 15) is not configured for the following IPv4 scope(s): {0}.
DnsDomainOptionV4_impact=DHCPv4 clients cannot resolve host names.
DnsDomainOptionV4_resolution=Configure a DNS domain as a server option or scope option by using the DHCP MMC snap-in.
DnsDomainOptionV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

DnsDomainOptionV6_title=DHCP: The DNS domain option should be configured as a scope or server option for DHCPv6.
DnsDomainOptionV6_problem=The DNS search list option (option 24) is not configured for the following scope(s): {0}.
DnsDomainOptionV6_impact=DHCPv6 clients cannot resolve host names.
DnsDomainOptionV6_resolution=Configure a DNS search list as a server option or scope option by using the DHCP MMC snap-in.
DnsDomainOptionV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

SecureDnsUpdatesV4_title=DHCP: Secure DNS updates should be configured if name protection is enabled on any IPv4 scope.
SecureDnsUpdatesV4_problem=Name protection has been enabled on the following IPv4 scopes, but secure Domain Name System (DNS) updates is not enabled: {0}
SecureDnsUpdatesV4_impact=Name protection requires secure update to work. Without name protection DNS names can be spoofed.
SecureDnsUpdatesV4_resolution=By using the DNS MMC snap-in, configure an Active Directory-integrated DNS zone for the domain and enable secure (only) dynamic updates.
SecureDnsUpdatesV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

FwdLookupZonesV4_title=DHCP: A forward lookup zone should be configured for the DNS domain used to register DNS records for IPv4 clients.
FwdLookupZonesV4_problem=A forward lookup zone has not been configured for the following domains (Domain Name, Server/Scope): {0}
FwdLookupZonesV4_impact=Domain Name System (DNS) registration of A records for client computers will fail resulting in the inability to connect to these client computers using host names.
FwdLookupZonesV4_resolution=By using the DNS MMC snap-in, configure a forward lookup zone for these domains or configure the correct domain name on the DHCP server as a scope option or server option.
FwdLookupZonesV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

SecureDnsUpdatesV6_title=DHCP: Secure DNS updates should be configured if name protection is enabled on any IPv6 scope.
SecureDnsUpdatesV6_problem=Name protection is enabled on the following IPv6 scopes, but secure Domain Name System (DNS) updates is not enabled: {0}
SecureDnsUpdatesV6_impact=Name protection requires secure update to work. Without name protection DNS names can be spoofed.
SecureDnsUpdatesV6_resolution=By using the DNS MMC snap-in, configure an Active Directory-integrated DNS zone for the domain and enable secure (only) dynamic updates.
SecureDnsUpdatesV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

FwdLookupZonesV6_title=DHCP: A forward lookup zone should be configured for the DNS domain used to register DNS records for IPv6 clients.
FwdLookupZonesV6_problem=A forward lookup zone has not been configured for the following domains (Domain Name, Server/Scope): {0}
FwdLookupZonesV6_impact=Domain Name System (DNS) registration of AAAA records for client computers will fail resulting in inability to connect to these client computers using host names.
FwdLookupZonesV6_resolution=By using the DNS MMC snap-in, configure a forward lookup zone for these domains or configure the correct domain name on the DHCP server as a scope option or server option.
FwdLookupZonesV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

SecureDnsUpdateProxyV4_title=DHCP: The DNSupdateproxy group must be secured if Name Protection is enabled on any IPV4 scope.
SecureDnsUpdateProxyV4_problem=Name protection is enabled, but the DNSupdateproxy group is not secured (Domain Name, Server/Scope): {0}.
SecureDnsUpdateProxyV4_impact=Name protection cannot work without a secured DNSupdateproxy group.
SecureDnsUpdateProxyV4_resolution=By using dnscmd, set the OpenACLOnProxyUpdates to 0 to secure the DNSupdateproxy group.
SecureDnsUpdateProxyV4_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

SecureDnsUpdateProxyV6_title=DHCP: The DNSupdateproxy group must be secured if Name Protection is enabled on any IPV6 scope.
SecureDnsUpdateProxyV6_problem=Name protection is enabled, but the DNSupdateproxy group is not secured (Domain Name, Server/Scope): {0}.
SecureDnsUpdateProxyV6_impact=Name protection cannot work without a secured DNSupdateproxy group.
SecureDnsUpdateProxyV6_resolution=By using dnscmd, set the OpenACLOnProxyUpdates to 0 to secure the DNSupdateproxy group.
SecureDnsUpdateProxyV6_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

Error_title=DHCP: An error occured during the DHCP BPA scan.
Error_problem=The DHCP Best Practices Analyzer (BPA) scan stopped because of the following error: {0} ({1})
Error_impact=DHCP BPA scan cannot continue to completion until this error is resolved.
Error_resolution=See the DHCP server  documentation on http://go.microsoft.com/fwlink/?LinkId=108876 to resolve this error.
Error_compliant=The DHCP Best Practices Analyzer scan has determined that you are in compliance with this best practice.

strActive=Active
strInactive=Inactive
strServer=Server
'@
