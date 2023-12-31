write-debug "Microsoft DNS Server BPA Version 1.0.0.0"

#
# -----------------------------
# TRANSLATIONS DEFINITION
# -----------------------------
#

data _system_translations {
    
# Only add new (name,value) pairs to the end of this table
# Do not remove, insert or re-arrange entries
ConvertFrom-StringData @'
       ###PSLOC start localizing
       #
       # helpID = VersionTooLow
       #
    IPAddressExists_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121988
    IPAddressExists_title = DNS: IP addresses must be configured on {0}
    IPAddressExists_problem = There are no IP addresses associated with {0}.
    IPAddressExists_impact = Without an IP address, the computer cannot communicate with other computers on the network or the Internet.
    IPAddressExists_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure a valid IP address on the adapter.
    IPAddressExists_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    IPv4DHCPConfiguration_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121986
    IPv4DHCPConfiguration_title = DNS: {0} should have static IPv4 settings
    IPv4DHCPConfiguration_problem = {0} has dynamically assigned Internet Protocol version 4 (IPv4) addresses.
    IPv4DHCPConfiguration_impact = Dynamic IP addresses can change, preventing clients from locating server resources.
    IPv4DHCPConfiguration_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure a static IP address on the interface.
    IPv4DHCPConfiguration_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    IPAutoConfiguration_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121982
    IPAutoConfiguration_title = DNS: The IP address {0} on {1} must be accessible to clients
    IPAutoConfiguration_problem = {1} has an autonet IP address.
    IPAutoConfiguration_impact = Without a valid IP address, the computer will not communicate with other network computers.
    IPAutoConfiguration_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure valid IP addresses on the adapter.
    IPAutoConfiguration_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    NoDNSServerConfigured_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121981
    NoDNSServerConfigured_title = DNS: {0} must have configured DNS servers
    NoDNSServerConfigured_problem = {0} does not have any DNS servers configured.
    NoDNSServerConfigured_impact = If DNS servers are not configured, the computer cannot resolve names or connect to network resources. Critical operations related to Active Directory Domain Services (AD DS) might also fail.
    NoDNSServerConfigured_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure at least two DNS servers per interface.
    NoDNSServerConfigured_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DNSServerConfigured_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121980
    DNSServerConfigured_title = DNS: {0} should be configured to use both a preferred and an alternate DNS server
    DNSServerConfigured_problem = {0} has only the preferred DNS server configured.
    DNSServerConfigured_impact = The use of a single DNS server per interface does not allow for redundancy and failover. If the configured DNS server becomes unavailable, the computer cannot resolve names and will not connect to other resources.
    DNSServerConfigured_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure at least two DNS servers per interface.
    DNSServerConfigured_compliant =  The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DNSLoopback_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121979
    DNSLoopback_title = DNS: DNS servers on {0} should include their own IP addresses on their interface lists of DNS servers
    DNSLoopback_problem = {0} on the target computer that is a DNS server does not have its own IP addresses in the list of DNS servers.
    DNSLoopback_impact = The inclusion of its own IP address in the list of DNS servers improves performance and increases availability of DNS servers.
    DNSLoopback_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to add the loopback IP address to the list of DNS servers on all active interfaces. The loopback IP address should not be the first server in the list.
    DNSLoopback_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DNSAutoConfig_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121977
    DNSAutoConfig_title = DNS: The DNS server {0} on {1} must be accessible to clients.
    DNSAutoConfig_problem = {1} is configured with an autonet IP address as a DNS server.
    DNSAutoConfig_impact = A DNS server that belongs to an IP address range that is not valid can prevent this computer from resolving names and connecting to network resources.
    DNSAutoConfig_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to remove all invalid or unresponsive DNS servers.
    DNSAutoConfig_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNSSuffix_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121973
    Resolve_Status_DNSSuffix_title = DNS: The DNS server {0} on {1} must resolve names in the primary DNS domain zone
    Resolve_Status_DNSSuffix_problem = The DNS server {0} on {1} did not successfully resolve the name for the start of authority (SOA) record of the zone hosting the computer's primary DNS domain name.
    Resolve_Status_DNSSuffix_impact = Active Directory Domain Services (AD DS) operations that depend on locating domain controllers will fail.
    Resolve_Status_DNSSuffix_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to remove or replace all invalid or unresponsive DNS servers.
    Resolve_Status_DNSSuffix_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNSForest_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121974
    Resolve_Status_DNSForest_title = DNS: The DNS server {0} on {1} must resolve names in the forest root domain name zone
    Resolve_Status_DNSForest_problem = The DNS server {0} on {1} did not successfully resolve the name for the start of authority (SOA) record of the zone hosting the computer's forest root domain name.
    Resolve_Status_DNSForest_impact = Active Directory Domain Services (AD DS) operations that depend on locating domain controllers will fail.
    Resolve_Status_DNSForest_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to remove all invalid or unresponsive DNS servers.
    Resolve_Status_DNSForest_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNS_LDAP_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121972
    Resolve_Status_DNS_LDAP_title = DNS: The DNS server {0} on {1} must resolve LDAP resource records for the domain controller
    Resolve_Status_DNS_LDAP_problem = The DNS server {0} on {1} did not successfully resolve the name {2}.
    Resolve_Status_DNS_LDAP_impact = Active Directory Domain Services (AD DS) operations that depend on locating domain controllers will fail.
    Resolve_Status_DNS_LDAP_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure DNS servers that can resolve the name {2}.
    Resolve_Status_DNS_LDAP_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNS_PDC_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121971
    Resolve_Status_DNS_PDC_title = DNS: The DNS server {0} on the {1} must resolve PDC resource records for the domain controller
    Resolve_Status_DNS_PDC_problem = The DNS server {0} on {1} did not successfully resolve the name {2}.
    Resolve_Status_DNS_PDC_impact = Active Directory Domain Services (AD DS) operations that depend on locating a Primary Domain Controller will fail.
    Resolve_Status_DNS_PDC_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure DNS servers that can resolve the name {2}.
    Resolve_Status_DNS_PDC_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNS_GC_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121970
    Resolve_Status_DNS_GC_title = DNS: The DNS server {0} on {1} must resolve Global Catalog resource records for the domain controller
    Resolve_Status_DNS_GC_problem = The DNS server {0} on {1} did not successfully resolve the name {2}.
    Resolve_Status_DNS_GC_impact = Active Directory Domain Services (AD DS) operations that depend on locating a Global Catalog will fail.
    Resolve_Status_DNS_GC_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure DNS servers that can resolve the name {2}.
    Resolve_Status_DNS_GC_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNS_KDC_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121967
    Resolve_Status_DNS_KDC_title = DNS: The DNS server {0} on {1} must resolve Kerberos resource records for the domain controller
    Resolve_Status_DNS_KDC_problem = The DNS server {0} on {1} did not successfully resolve the name {2}.
    Resolve_Status_DNS_KDC_impact = Active Directory Domain Services (AD DS) operations that depend on locating a Kerberos Key Distribution Center(KDC) will fail.
    Resolve_Status_DNS_KDC_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure DNS servers that can resolve the name {2}.
    Resolve_Status_DNS_KDC_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    Resolve_Status_DNS_HOST_A_helpTopic = http://go.microsoft.com/fwlink/?LinkId=130024
    Resolve_Status_DNS_HOST_A_title = DNS: The DNS server {0} on {1} must resolve the name of this computer
    Resolve_Status_DNS_HOST_A_problem = The DNS server {0} on {1} did not successfully resolve the name of the address (A) record for this computer.
    Resolve_Status_DNS_HOST_A_impact = Other domain controllers might not be able to resolve this computer's name. The computer might not be able to connect to network resources.
    Resolve_Status_DNS_HOST_A_resolution = Click Start, click Network, click Network and Sharing Center, and then click Change adapter settings to configure DNS servers that are able to resolve names for your enterprise.
    Resolve_Status_DNS_HOST_A_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    BindingOrder_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121966
    BindingOrder_title = DNS: Valid network interfaces should precede invalid interfaces in the binding order.
    BindingOrder_problem = A disabled or invalid adapter precedes a valid adapter in the network interface binding order list.
    BindingOrder_impact = The binding order determines when network interfaces will be used to make network connections by the computer. A disabled adapter high in the binding order can degrade performance.
    BindingOrder_resolution = Click Start, click Network, click Network and Sharing Center, click Change adapter settings, and then press the Alt key, click Advanced, and click Advanced Settings to move all disabled and invalid interfaces to the bottom of the binding order list.
    BindingOrder_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #  Resources added for MBCAv2 start below

    Generic_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    DNSLoopbackFirst_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188760
    DNSLoopbackFirst_impact = If the loopback IP address is the first entry in the list of DNS servers, Active Directory might be unable to find its replication partners.
    DNSLoopbackFirst_problem = The network adapter {0} does not list the local server as a DNS server; or it is configured as the first DNS server on this adapter.
    DNSLoopbackFirst_resolution = Configure adapter settings to add the loopback IP address to the list of DNS servers on all active interfaces, but not as the first server in the list.
    DNSLoopbackFirst_title = DNS: DNS servers on {0} should include the loopback address, but not as the first entry.

    NoIPAddressesExist_helpTopic = http://go.microsoft.com/fwlink/?LinkId=121988
    NoIPAddressesExist_impact = The DNS server will fail to resolve any DNS queries.
    NoIPAddressesExist_problem = No network adapters are installed and enabled with either the IPv4 or IPv6 protocol.
    NoIPAddressesExist_resolution = Install and enable a network adapter and add either the IPv4 or IPv6 protocol.
    NoIPAddressesExist_title = DNS: The DNS server must have an IP address.

    Param_Blocklist_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188763
    Param_Blocklist_impact = Users might register DNS names that have special significance. By default, the Global Query Block List contains the strings "wpad" and "isatap".
    Param_Blocklist_problem = The DNS Global Query block list is enabled but empty. The default strings ("wpad" and "isatap") have been removed.
    Param_Blocklist_resolution = Disable the Global Query Block List, or add the strings "wpad" and "isatap" to the list if you do not have these services deployed in your environment.
    Param_Blocklist_title = DNS: If the Global Query Block List is enabled, then it should not be empty.

    Param_CacheLockingOff_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188764
    Param_CacheLockingOff_impact = A low cache locking value increases the chance of a successful cache poisoning attack. Network traffic might be directed to a malicious site.
    Param_CacheLockingOff_problem = The cache locking value {0}% is less than 90%. By default, the cache locking value is 100%.
    Param_CacheLockingOff_resolution = Configure the cache locking value to be 90% or greater.
    Param_CacheLockingOff_title = DNS: Cache locking should be configured to 90% or greater.

    Param_ForwardingTimeout_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188767
    Param_ForwardingTimeout_impact = The timeout value {0} is not within the recommended range of 2 to 10 seconds. DNS resolutions failures can occur if the value is too small. A timeout value of more than 10 seconds can cause DNS resolution delays.
    Param_ForwardingTimeout_problem = The forwarding timeout value is less than 2 seconds or greater than 10 seconds.
    Param_ForwardingTimeout_resolution = Configure the forwarding timeout value to a value between 2 seconds and 10 seconds.
    Param_ForwardingTimeout_title = DNS: The forwarding timeout value should be 2 to 10 seconds.

    Param_Hosts_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188769
    Param_Hosts_impact = Errors in the Hosts file on a DNS server can cause problems with name resolution on your network.
    Param_Hosts_problem = The Hosts file {0} on the DNS server is not empty.
    Param_Hosts_resolution = Review the entries in your Hosts file, which is located at {1}.
    Param_Hosts_title = DNS: The Hosts file {0} on the DNS server should be empty.

    Param_RegistrationEnabled_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188771
    Param_RegistrationEnabled_impact = IP addresses on the interface will not be automatically registered in DNS.
    Param_RegistrationEnabled_problem = The interface {0} is not configured to register its addresses in DNS.
    Param_RegistrationEnabled_resolution = Configure the interface {0} to register the connection's addresses in DNS.
    Param_RegistrationEnabled_title = DNS: Interface {0} on the DNS server should be configured to register its IP addresses in DNS.

    Param_RootHints_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188773
    Param_RootHints_impact = The DNS server will fail to resolve DNS queries for DNS zones for which it is not authoritative.
    Param_RootHints_problem = If recursion is enabled then either root hints or forwarders must be configured.
    Param_RootHints_resolution = Configure root hints or enable forwarding and configure forwarding servers.
    Param_RootHints_title = DNS: The DNS server must have root hints or forwarders configured.

    Param_ScavengingServer_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188774
    Param_ScavengingServer_title = DNS: The scavenging interval should be within the recommended range.
    Param_ScavengingServer_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice. The scavenging interval {0} is within the recommended range.

    Param_ScavengingServer_AgingDisabled_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188775
    Param_ScavengingServer_AgingDisabled_impact = The size of the DNS database can become excessive if scavenging is not enabled.
    Param_ScavengingServer_AgingDisabled_problem = Scavenging is disabled on the DNS server.
    Param_ScavengingServer_AgingDisabled_resolution = Enable scavenging on the DNS Server.
    Param_ScavengingServer_AgingDisabled_title = DNS: The DNS server should have scavenging enabled.

    Param_ScavengingServer_IntervalRange_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188776
    Param_ScavengingServer_IntervalRange_impact = An incorrect value will lead to scavenging being run less or more often than desired.
    Param_ScavengingServer_IntervalRange_problem = The server scavenging interval has been set to a non-recommended value of {0}.
    Param_ScavengingServer_IntervalRange_resolution = Set the server scavenging interval to a value between 6 hours and 28 days.
    Param_ScavengingServer_IntervalRange_title = DNS: The scavenging interval {0} should be set to a recommended value.

    Param_ScavengingZone_AgingDisabled_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188778
    Param_ScavengingZone_AgingDisabled_title = DNS: Zone {0} record aging is disabled, so scavenging will not occur.
    Param_ScavengingZone_AgingDisabled_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice. Scavenging parameters were not evaluated because record aging is disabled. Enable aging for the zone {0} if scavenging is desired.

    Param_ScavengingZone_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188777
    Param_ScavengingZone_title = DNS: Zone {0} should have scavenging enabled with recommended parameters.
    Param_ScavengingZone_compliant = The DNS Best Practices Analyzer scan has determined that you are in compliance with this best practice. Zone {0} has scavenging enabled with recommended parameters.

    Param_ScavengingZone_NoScavengeServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188780
    Param_ScavengingZone_NoScavengeServers_impact = DNS records in the zone {0} will not be scavenged.
    Param_ScavengingZone_NoScavengeServers_problem = Scavenging is enabled but there are no scavenging servers specified for the zone {0}.
    Param_ScavengingZone_NoScavengeServers_resolution = Configure the list of DNS scavenging servers for the zone.
    Param_ScavengingZone_NoScavengeServers_title = DNS: Zone {0} scavenging server list should not be empty.

    Param_ScavengingZone_RefreshNonDefault_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188781
    Param_ScavengingZone_RefreshNonDefault_impact = The DNS server will scavenge resource records too frequently or not frequently enough.
    Param_ScavengingZone_RefreshNonDefault_problem = The refresh and no-refresh scavenging intervals for the zone {0} are not set to the default values.
    Param_ScavengingZone_RefreshNonDefault_resolution = Configure the refresh and no-refresh intervals for the zone {0} to the default values.
    Param_ScavengingZone_RefreshNonDefault_title = DNS: Zone {0} scavenging parameters should be set to default values.

    Param_SocketPoolOff_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188782
    Param_SocketPoolOff_impact = The DNS server is more vulnerable to DNS spoofing attacks.
    Param_SocketPoolOff_problem = The value of {0} in the Windows Registry is configured to a value of {1}.
    Param_SocketPoolOff_resolution = Enable the socket pool and configure a recommended value for MaxUserPort.
    Param_SocketPoolOff_title = DNS: The socket pool should be enabled with recommended settings.

    Param_TimeoutOffset_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188783
    Param_TimeoutOffset_impact = The DNS server will fail to respond to queries for external zones if forwarding servers are not available.
    Param_TimeoutOffset_problem = The forwarding timeout {0} is greater than or equal to the recursion timeout {1}.
    Param_TimeoutOffset_resolution = Configure the recursion timeout to be greater than the forwarding timeout.
    Param_TimeoutOffset_title = DNS: The recursion timeout must be greater than the forwarding timeout.

    Resolve_Forwarders_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188784
    Resolve_Forwarders_impact = Unresponsive forwarders can cause delays and failures in DNS resolution.
    Resolve_Forwarders_problem = The forwarder {0} is not responding to DNS queries.
    Resolve_Forwarders_resolution = Remove the unresponsive forwarder {0} from the list of forwarders.
    Resolve_Forwarders_title = DNS: Forwarding server {0} should respond to DNS queries.

    Resolve_Forwarders_AllFail_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188785
    Resolve_Forwarders_AllFail_impact = DNS queries for external zones might fail.
    Resolve_Forwarders_AllFail_problem = All DNS servers configured in the list of forwarders are unresponsive.
    Resolve_Forwarders_AllFail_resolution = Configure valid DNS servers in the list of forwarders.
    Resolve_Forwarders_AllFail_title = DNS: At least one DNS server on the list of forwarders must respond to DNS queries.

    Resolve_Forwarders_Autoconfig_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188786
    Resolve_Forwarders_Autoconfig_impact = DNS queries for external zones might fail.
    Resolve_Forwarders_Autoconfig_problem = A link-local IP address {0} is configured as a forwarding server.
    Resolve_Forwarders_Autoconfig_resolution = Remove the link-local forwarder IP address {0} from the list of forwarders.
    Resolve_Forwarders_Autoconfig_title = DNS: The list of forwarding servers must not contain the link-local IP address {0}.

    Resolve_Forwarders_Loopback_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188787
    Resolve_Forwarders_Loopback_impact = DNS queries for external zones might fail.
    Resolve_Forwarders_Loopback_problem = A loopback IP address {0} is configured as a forwarding server.
    Resolve_Forwarders_Loopback_resolution = Remove the loopback forwarder IP address {0} from the list of forwarders.
    Resolve_Forwarders_Loopback_title = DNS: The list of forwarding servers must not contain the loopback address {0}.

    Resolve_Forwarders_OnlyOne_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188788
    Resolve_Forwarders_OnlyOne_impact = The forwarder {0} is a single point of failure.
    Resolve_Forwarders_OnlyOne_problem = There is only one forwarder configured on the DNS server.
    Resolve_Forwarders_OnlyOne_resolution = Configure additional forwarders on the DNS server.
    Resolve_Forwarders_OnlyOne_title = DNS: More than one forwarding server should be configured.

    Resolve_Mismatch_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188789
    Resolve_Mismatch_impact = DNS queries might fail or be delayed.
    Resolve_Mismatch_problem = The DNS servers {0} and {1} do not respond identically to queries for the forest root domain.
    Resolve_Mismatch_resolution = Configure DNS servers on the network interface so that either both respond or neither responds to queries for the forest root domain.
    Resolve_Mismatch_title = DNS: DNS servers assigned to the network adapter should respond consistently.

    Resolve_Peers_AllMasterServersFail_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188790
    Resolve_Peers_AllMasterServersFail_impact = The secondary zone {0} will not be updated.
    Resolve_Peers_AllMasterServersFail_problem = None of the master servers configured for zone {0} are responding.
    Resolve_Peers_AllMasterServersFail_resolution = Validate the list of master servers for the zone {0}.
    Resolve_Peers_AllMasterServersFail_title = DNS: Zone {0} master servers must respond to queries for the zone.

    Resolve_Peers_AllSecondaryServersFail_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188791
    Resolve_Peers_AllSecondaryServersFail_impact = Secondary servers will fail DNS queries for the zone {0}.
    Resolve_Peers_AllSecondaryServersFail_problem = None of the secondary servers configured for zone {0} are responding.
    Resolve_Peers_AllSecondaryServersFail_resolution = Validate secondary servers for zone {0}.
    Resolve_Peers_AllSecondaryServersFail_title = DNS: Zone {0} secondary servers must respond to queries for the zone.

    Resolve_Peers_MasterServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188792
    Resolve_Peers_MasterServers_impact = The secondary zone {0} will not be transferred from the master DNS server {1}.
    Resolve_Peers_MasterServers_problem = The secondary zone {0} does not exist on the master server {1}.
    Resolve_Peers_MasterServers_resolution = Add the zone {0} to the master server {1} or remove {1} from the list of master servers.
    Resolve_Peers_MasterServers_title = DNS: Zone {0} master server {1} must respond to queries for the zone.

    Resolve_Peers_MissingMasterServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188793
    Resolve_Peers_MissingMasterServers_impact = The zone will not be updated on secondary DNS servers.
    Resolve_Peers_MissingMasterServers_problem = There are no master servers configured for the zone {0}.
    Resolve_Peers_MissingMasterServers_resolution = Update the master servers list for the zone {0}.
    Resolve_Peers_MissingMasterServers_title = DNS: Zone {0} master server list must not be empty.

    Resolve_Peers_MissingNotifyServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188794
    Resolve_Peers_MissingNotifyServers_impact = Secondary servers for the zone {0} will not be notified of changes to zone records.
    Resolve_Peers_MissingNotifyServers_problem = The list of servers receiving zone update notifications for the zone {0} is empty.
    Resolve_Peers_MissingNotifyServers_resolution = Add secondary servers to the zone update notification list for the zone {0}.
    Resolve_Peers_MissingNotifyServers_title = DNS: Zone {0} update notification list must not be empty.

    Resolve_Peers_MissingSecondaryServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188795
    Resolve_Peers_MissingSecondaryServers_impact = Zone transfers will be denied from this DNS server.
    Resolve_Peers_MissingSecondaryServers_problem = Zone transfers are allowed for the primary zone {0} but no secondary servers are configured.
    Resolve_Peers_MissingSecondaryServers_resolution = Add secondary servers to the list of hosts that are allowed to receive zone transfers for the zone {0}.
    Resolve_Peers_MissingSecondaryServers_title = DNS: Zone {0} secondary servers list should not be empty.

    Resolve_Peers_NotifyServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188798
    Resolve_Peers_NotifyServers_impact = Zone update notifications for zone {0} will be ignored by the secondary server {1} since it does not host the zone.
    Resolve_Peers_NotifyServers_problem = The secondary server {1} is configured to receive zone update notifications for the zone {0}, but it does not host the zone.
    Resolve_Peers_NotifyServers_resolution = Remove the secondary server {1} from the list of secondary servers to be notified for updates to zone {0}.
    Resolve_Peers_NotifyServers_title = DNS: Zone {0} should be present on the secondary server {1} configured to receive zone update notifications.

    Resolve_Peers_ScavengeServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188799
    Resolve_Peers_ScavengeServers_impact = The server {1} cannot scavenge records in the zone {0}.
    Resolve_Peers_ScavengeServers_problem = The DNS server {1} is listed as a scavenging server for zone {0}, but does not host this zone.
    Resolve_Peers_ScavengeServers_resolution = Remove the server {1} from the list of scavenging servers for the zone {0}.
    Resolve_Peers_ScavengeServers_title = DNS: Zone {0} scavenging servers should host the zone.

    Resolve_Peers_SecondaryServers_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188802
    Resolve_Peers_SecondaryServers_impact = DNS queries for the zone {0} might fail.
    Resolve_Peers_SecondaryServers_problem = The secondary DNS server {1} does not respond to queries for the zone {0}.
    Resolve_Peers_SecondaryServers_resolution = Verify that the server {1} is a secondary DNS server that hosts the zone {0}.
    Resolve_Peers_SecondaryServers_title = DNS: Zone {0} secondary server {1} should respond to queries for the zone.

    Resolve_RootHints_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188803
    Resolve_RootHints_impact = The DNS server might be unable to resolve external host names.
    Resolve_RootHints_problem = The root hint server {0} is not responding.
    Resolve_RootHints_resolution = Validate network connectivity to root hint servers. Remove {0} from the list if it is unresponsive.
    Resolve_RootHints_title = DNS: Root hint server {0} must respond to NS queries for the root zone.

    Resolve_RootHints_AllFail_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188805
    Resolve_RootHints_AllFail_impact = The DNS server might be unable to resolve external host names.
    Resolve_RootHints_AllFail_problem = All root hints failed an NS query for the root zone.
    Resolve_RootHints_AllFail_resolution = Configure the list of root hints with name servers that are responding.
    Resolve_RootHints_AllFail_title = DNS: At least one name server in the list of root hints must respond to queries for the root zone.

    Resolve_RootHints_Autoconfig_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188807
    Resolve_RootHints_Autoconfig_impact = The DNS server might be unable to resolve external host names.
    Resolve_RootHints_Autoconfig_problem = A link-local address is configured in the list of root hints.
    Resolve_RootHints_Autoconfig_resolution = Remove the link-local address from the list of root hints.
    Resolve_RootHints_Autoconfig_title = DNS: The list of root hints must not contain the link-local IP address {0}.

    Resolve_RootHints_Loopback_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188808
    Resolve_RootHints_Loopback_impact = The DNS server might be unable to resolve external host names.
    Resolve_RootHints_Loopback_problem = The IP address of this DNS server or the loopback address is configured in the list of root hints.
    Resolve_RootHints_Loopback_resolution = Remove the loopback or host IP address from the list of root hints.
    Resolve_RootHints_Loopback_title = DNS: The list of root hints must not contain the host IP address or loopback address {0}.

    Resolve_RootHints_OnlyOne_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188809
    Resolve_RootHints_OnlyOne_impact = Loss of the single root hint server {0} will prevent the DNS server from being able to resolve external host names.
    Resolve_RootHints_OnlyOne_problem = The root hint {0} that has been configured for the DNS server is a single point of failure.
    Resolve_RootHints_OnlyOne_resolution = Add additional root hints to the list of root hint servers.
    Resolve_RootHints_OnlyOne_title = DNS: The list of root hints should contain more than one entry.

    Resolve_Status_DNS_HOST_AAAA_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188810
    Resolve_Status_DNS_HOST_AAAA_impact = The DNS server might be unavailable on the network.
    Resolve_Status_DNS_HOST_AAAA_problem = The DNS server {0} on {1} did not successfully resolve the DNS name of this computer.
    Resolve_Status_DNS_HOST_AAAA_resolution = Configure DNS servers on the network adapter that can resolve names in the host domain.
    Resolve_Status_DNS_HOST_AAAA_title = DNS: The DNS server {0} configured on the adapter {1} should resolve the name of this computer.

    Zone_Status_AD_helpTopic = http://go.microsoft.com/fwlink/?LinkId=188812
    Zone_Status_AD_title = DNS: Zone {0} is Active Directory integrated and should be present and configured as primary.

    Zone_Status_AD_NotPresent_helpTopic = http://go.microsoft.com/fwlink/?LinkId=189238
    Zone_Status_AD_NotPresent_impact = DNS queries for the Active Directory integrated zone {0} might fail.
    Zone_Status_AD_NotPresent_problem = The Active Directory integrated DNS zone {0} was not found.
    Zone_Status_AD_NotPresent_resolution = Restore the Active Directory integrated DNS zone {0}.
    Zone_Status_AD_NotPresent_title = DNS: Zone {0} is an Active Directory integrated DNS Zone and must be available.

    Zone_Status_AD_NotPrimary_helpTopic = http://go.microsoft.com/fwlink/?LinkId=189239
    Zone_Status_AD_NotPrimary_impact = DNS queries for the Active Directory integrated zone {0} might fail.
    Zone_Status_AD_NotPrimary_problem = The zone {0} is Active Directory integrated but the zone type is not configured as primary.
    Zone_Status_AD_NotPrimary_resolution = Configure the zone type for the zone {0} as a primary.
    Zone_Status_AD_NotPrimary_title = DNS: Zone {0} is an Active Directory integrated DNS zone and must be configured as primary.

    Zone_Status_AD_NotRunning_helpTopic = http://go.microsoft.com/fwlink/?LinkId=189240
    Zone_Status_AD_NotRunning_impact = The DNS server will not respond to queries for the zone {0}.
    Zone_Status_AD_NotRunning_problem = The Active Directory integrated zone {0} is unavailable because it is not running.
    Zone_Status_AD_NotRunning_resolution = Start the Active Directory integrated zone {0}.
    Zone_Status_AD_NotRunning_title = DNS: Zone {0} is an Active Directory integrated DNS zone and must be running.

    Zone_Status_XFR_helpTopic = http://go.microsoft.com/fwlink/?LinkId=189298
    Zone_Status_XFR_impact = Contents of the zone {0} on this DNS server are out of date.
    Zone_Status_XFR_problem = The results of the last zone transfer were {1} for the zone {0}.
    Zone_Status_XFR_resolution = Verify that zone transfers are allowed to this DNS server.
    Zone_Status_XFR_title = DNS: Zone {0} transfers from the primary to the secondary DNS server must be successful.

'@
    
}

#
# ---------------------
# XSD SCHEMA DEFINITION
# ---------------------
#




#
# -----------------------------
# SCHEMATRON RULES DEFINITION
# -----------------------------
#




#This function will call DNSQuery API with the pExtra parameter containing the Server IP to be queried
function Compile-Csharp ([string] $code)
{
    # Get an instance of the CSharp code provider
    $cp = New-Object Microsoft.CSharp.CSharpCodeProvider
    $refs = New-Object Collections.ArrayList
    $refs.AddRange( @("System.dll",
    #"${PsHome}\System.Management.Automation.dll",
    #"${PsHome}\Microsoft.PowerShell.ConsoleHost.dll",
    "System.Windows.Forms.dll",
    "System.Data.dll",
    "System.Drawing.dll",
    "System.XML.dll"))

    # Build up a compiler params object...
    $cpar = New-Object System.CodeDom.Compiler.CompilerParameters
    $cpar.GenerateInMemory = $true
    $cpar.GenerateExecutable = $false
    $cpar.IncludeDebugInformation = $false
    $cpar.CompilerOptions = "/target:library"
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


#
# -----------------------------
# CSHARP CODE SECTION
# 1) DNSQUERY
# 2) GETADAPTERADDRESSES
# -----------------------------
#

function call-CompileCSharpUtilities()
{
    $code =
@'
    

namespace DnsQueryUtils
{
    using System;
    using System.Collections;
    using System.ComponentModel;
    using System.Runtime.InteropServices;
    using System.Net;
    using System.Net.Sockets;

    [StructLayout(LayoutKind.Sequential)]
    public struct DNS_ADDR
    {
        const int DnsValSrvFlagStandard = 1;
        public Int16 addressFamily;
        public UInt16 port;

        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 28)]
        public byte[] addressBytes;
        public UInt32 sockaddrLength;
        public UInt32 delay;
        public UInt32 subStatus;
        public UInt32 status;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
        public byte[] dnsAddrUserBytes;
    }

    [StructLayout(LayoutKind.Explicit, CharSet = CharSet.Unicode, Size = 144)]
    public struct PDNS_ADDR_ARRAY
    {
        [FieldOffset(0)]
        public UInt32 MaxCount;
        [FieldOffset(4)]
        public UInt32 AddrCount;
        [FieldOffset(8)]
        public UInt32 Tag;
        [FieldOffset(12)]
        public Int16 Family;
        [FieldOffset(14)]
        public Int16 WordReserved;
        [FieldOffset(16)]
        public UInt32 Flags;
        [FieldOffset(20)]
        public UInt32 MatchFlag;
        [FieldOffset(24)]
        public UInt32 Reserved1;
        [FieldOffset(28)]
        public UInt32 Reserved2;
        [FieldOffset(32)]
        public DNS_ADDR dnsAddress;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DNSExtraInfo
    {
        public UInt32 Version;
        public UInt32 Size;
        public IntPtr pNext;
        public UInt32 Id;
        public UInt32 Reserved;
        public IntPtr pServerList;
    }

    public class DNSQueryInvoker
    {
        public DNSQueryInvoker()
        {
        }

        [DllImport("dnsapi", EntryPoint = "DnsQuery_W", CharSet = CharSet.Unicode, SetLastError = true, ExactSpelling = true)]
        private static extern int DnsQuery([MarshalAs(UnmanagedType.VBByRefStr)] ref string pszName, QueryTypes wType, QueryOptions options, [In, Out, MarshalAs(UnmanagedType.Struct)]ref DNSExtraInfo pExtra, ref IntPtr ppQueryResults, int pReserved);

        [DllImport("dnsapi", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern void DnsRecordListFree(IntPtr pRecordList, int FreeType);
        public static int GetDNSRecords(string dnsqtype, string domain, string Address)
        {
            //
            // Get the type of the record
            //

            DNSQueryInvoker.QueryTypes qtype = QueryTypes.DnsTypePTR;
            switch (dnsqtype)
            {
                case "A":
                    qtype = QueryTypes.DnsTypeA;
                    break;
                case "SOA":
                    qtype = QueryTypes.DnsTypeSOA;
                    break;
                case "MX":
                    qtype = QueryTypes.DnsTypeMX;
                    break;
                case "NS":
                    qtype = QueryTypes.DnsTypeNS;
                    break;
                case "AAAA":
                    qtype = QueryTypes.DnsTypeAAAA;
                    break;
                case "SRV":
                    qtype = QueryTypes.DnsTypeSRV;
                    break;
                case "PTR":
                    qtype = QueryTypes.DnsTypePTR;
                    break;
                default:
                    throw new NotSupportedException("This QType is not implemented.");
            }

            //
            // initialize pExtra. Some information is not completely documented.
            //

            DNSExtraInfo pExtra = new DNSExtraInfo();
            pExtra.Version = DnsExtraInfoVersion;
            pExtra.Size = (UInt32)System.Runtime.InteropServices.Marshal.SizeOf(pExtra);
            pExtra.pNext = IntPtr.Zero;
            pExtra.Reserved = 0;
            pExtra.Id = DnsExtraInfoIdServerList;

            //
            // initialize array
            //

            PDNS_ADDR_ARRAY ptr = new PDNS_ADDR_ARRAY();
            ptr.MaxCount = 1;
            ptr.AddrCount = 1;
            ptr.Reserved1 = 0;
            ptr.Reserved2 = 0;
            ptr.WordReserved = 0;
            ptr.Tag = DnsImbeddedExtraInfoTag;

            //
            // initialize the dnsaddr
            //

            IPAddress ipaddress = IPAddress.Parse(Address);
            ptr.dnsAddress = new DNS_ADDR();
            ptr.dnsAddress.addressBytes = new byte[IPAddressBufferBytes];
            ptr.dnsAddress.dnsAddrUserBytes = new byte[DnsAddrUserBytesLength];
            byte[] addressBytes;
            int addressOffset;

            if (ipaddress.AddressFamily.Equals(AddressFamily.InterNetwork))
            {
                ptr.dnsAddress.sockaddrLength = SockAddrV4Length;
                ptr.dnsAddress.addressFamily = (Int16)AddressFamily.InterNetwork;
                addressBytes = ipaddress.GetAddressBytes();
                addressOffset = 0;
            }
            else
            {
                ptr.dnsAddress.sockaddrLength = SockAddrV6Length;
                ptr.dnsAddress.addressFamily = (Int16)AddressFamily.InterNetworkV6;
                addressBytes = ipaddress.GetAddressBytes();
                addressOffset = 4;
            }

            //
            // Copy the address bytes to the structure for marshalling
            //

            Array.Copy(
                addressBytes,
                0,
                ptr.dnsAddress.addressBytes,
                addressOffset,
                addressBytes.Length);

            pExtra.pServerList = Marshal.AllocHGlobal(Marshal.SizeOf(ptr));

            //
            // Copy the struct to unmanaged memory.
            //

            Marshal.StructureToPtr(ptr, pExtra.pServerList, false);
            IntPtr ptr1 = IntPtr.Zero;
            IntPtr ptr2 = IntPtr.Zero;

            if (Environment.OSVersion.Platform != PlatformID.Win32NT)
            {
                throw new NotSupportedException("DNSQuery is not supported on this system");
            }

            try
            {
                int num = DNSQueryInvoker.DnsQuery(ref domain, qtype, QueryOptions.DnsQueryByPassCache, ref pExtra, ref ptr1, 0);

                DNSQueryInvoker.DnsRecordListFree(ptr2, 0);

                return num;
            }

            catch (Exception ex)
            {
                return (int)(ErrorReturnCode.DnsErrorCodeException);
            }

        }

        //
        // Return Codes
        //

        public enum ErrorReturnCode
        {
            DnsErrorCodeException = -1,
            DnsErrorCodeNoError = 0,
            DnsErrorCodeFormatError = 9001,
            DnsErrorCodeServerFailure = 9002,
            DnsErrorCodeNameError = 9003,
            DnsErrorCodeNodeImplemented = 9004,
            DnsErrorCodeRefused = 9005,
            DnsErrorCodeBadTime = 9018,
            DnsErrorCodeTimeOut = 1460
        }

        //
        // Query Options
        //

        private enum QueryOptions
        {
            DnsQueryAccepteTruncatedREsponse = 1 ,
            DnsQueryByPassCache = 8,
            DnsQueryDontResetTTLValues = 0x100000,
            DnsQueryNoHostsFile = 0x40,
            DnsQueryNoLocalName = 0x20,
            DnsQueryNoNetBT = 0x80,
            DnsQueryNoRecursion = 4,
            DnsQueryNoWireQuery = 0x10,
            DnsQueryReserved = -16777216,
            DnsQueryReturnMEssage = 0x200,
            DnsQueryStandard = 0,
            DnsQueryTreatAsFQDN = 0x1000,
            DnsQueryUseTCPOnly = 2,
            DnsQueryWireOnly = 0x100
        }

        //
        // Query Types
        //

        private enum QueryTypes
        {
            DnsTypeA = 1,
            DnsTypeNS = 2,
            DnsTypeCNAME = 5,
            DnsTypeSOA = 6,
            DnsTypePTR = 12,
            DnsTypeMX = 15,
            DnsTypeTEXT = 16,
            DnsTypeAAAA = 28,
            DnsTypeSRV = 33
        }
        const int DNS_VALSVR_FLAG_STANDARD = 1;

        //
        // The number of bytes in the IP address byte array for DNS_ADDR.
        //

        const int IPAddressBufferBytes = 28;

        //
        // The number of bytes in a v6 address: sizeof(SOCKADDR_IN6).
        //

        const int SockAddrV6Length = 28;

        //
        // The number of bytes in a v4 address: sizeof(SOCKADDR_IN).
        //

        const int SockAddrV4Length = 16;

        //
        // The number of bytes in the DnsAddrUserBytes byte array.
        //

        const int DnsAddrUserBytesLength = 16;

        //
        // The pExtra.Version to be passed to DNSQuery is set with this variable
        //

        const UInt32 DnsExtraInfoVersion = 0x80000001;

        //
        // The ID Information to be set in pExtra parameter so that DNSQuery accepts a server list
        //

        const UInt32 DnsExtraInfoIdServerList = 10;

        //
        // test extra info "imbedded" in v4 array input. This is probalyused to mnaintain some compatibility
        //

        const UInt32 DnsImbeddedExtraInfoTag = 0xfedc1234;
    }
}

'@
    Compile-Csharp $code
}

#CSharp code goes here
function call-GetAdapterAddresses()
{
    $code =
@'
    
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.Runtime.InteropServices;
    using System.Net;
    using System.Diagnostics;
    using System.ComponentModel;
    using Microsoft.Win32;
    using System.Net.Sockets;

    namespace AdapterUtils
    {
        //
        // All Information related to the IPAddresses
        //

        public class IPAddressInfo
        {
            public string IPAddress;
            public string AddressFamily;
            public string InterfaceZoneId;
            public string LinkLocalAddress;
            public string MulticastAddress;
            public string SiteLocalAddress;
            public string ScopeId;
        }

        //
        // All Information related to the DNS Server
        //

        public class DNSServerInfo
        {
            public string DNSAddress;
            public string DNSAddressFamily;
            public string InterfaceZoneId;
            public string LinkLocalAddress;
            public string MulticastAddress;
            public string SiteLocalAddress;
            public string ScopeId;
        }

        //
        // Structure to store the information returned by GetAdapterAddresses
        // This fill be used in powershell
        //

        public class InterfaceInformation
        {
            public string AdapterName;
            public string Description;
            public string AdapterFriendlyName;
            public string MACAddress;
            public string InterfaceType;
            public string InterfaceIndex;
            public string IPv6InterfaceAddress;
            public string OperationalAddress;
            public string DNSSuffix;
            public Boolean DHCPEnabled;
            public Boolean IPv4Enabled;
            public Boolean IPv6Enabled;
            public List<IPAddressInfo> IPAddressList;
            public List<DNSServerInfo> DNSServerList;
        }

        //
        // Structure used to store IPV4 addresses.
        //

        [StructLayout(LayoutKind.Sequential)]
        public struct SOCKADDR
        {
            //
            //Address Family
            //

            public Int32 sa_family;

            //
            //up to 4 bytes of direct address
            //

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
            public byte[] sa_data;
        };

        //
        // Structure used to store IPV6 addresses.
        // Make it to 16 bytes to get rid of any zone ids if present after the address.
        //

        [StructLayout(LayoutKind.Sequential)]
        public struct SOCKADDRIPV6
        {
            //
            //address family
            //

            public Int64 sa_family;

            //
            //up to 16 bytes of direct address
            //

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
            public byte[] sa_data;
        };

        //
        // SOCKET_ADDRESS
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct SOCKET_ADDRESS
        {
            public IntPtr lpSockAddr;
            public Int32 iSockaddrLength;
        }

        //
        // IP_ADAPTER_UNICAST_ADDRESS
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct IP_ADAPTER_UNICAST_ADDRESS
        {
            public UInt32 Length;
            public UInt32 Flags;
            public IntPtr Next;
            public SOCKET_ADDRESS Address;
            public IP_PREFIX_ORIGIN PrefixOrigin;
            public IP_SUFFIX_ORIGIN SuffixOrigin;
            public IP_DAD_STATE DadState;
            public UInt32 ValidLifetime;
            public UInt32 PreferredLifetime;
            public UInt32 LeaseLifetime;
            public Byte OnLinkPrefixLength;
        }

        //
        // IP_ADAPTER_ANYCAST_ADDRESS -
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct IP_ADAPTER_ANYCAST_ADDRESS
        {
            //UInt64 Alignment; // reserved
            public UInt32 Length;
            public UInt32 Flags;

            public IntPtr Next;
            public SOCKET_ADDRESS Address;
        }

        //
        // IP_ADAPTER_MULTICAST_ADDRESS
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct IP_ADAPTER_MULTICAST_ADDRESS
        {
            //
            // UInt64 Alignment; // reserved
            //
            public UInt32 Length;
            public UInt32 Flags;
            public IntPtr Next;
            public SOCKET_ADDRESS Address;
        }

        //
        // IP_ADAPTER_DNS_SERVER_ADDRESS
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public struct IP_ADAPTER_DNS_SERVER_ADDRESS
        {
            //
            // UInt64 Alignment; // reserved
            //

            public UInt32 Length;
            public UInt32 Flags;
            public IntPtr Next;
            public SOCKET_ADDRESS Address;
        }

        //
        // IP_ADDRESS_STRING
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public class IP_ADDRESS_STRING
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 16)]
            public string address;
        };

        //
        // IP_MASK_STRING - a clone of IP_ADDRESS_STRING used for retrieving subnet masks.
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public class IP_MASK_STRING
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 16)]
            public string address;
        };

        //
        // IP_ADDR_STRING
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
        public class IP_ADDR_STRING
        {
            public IntPtr Next;
            public IP_ADDRESS_STRING IpAddress;
            public IP_MASK_STRING IpMask;
            public UInt32 Context;
        }

        //
        // IP_ADAPTER_ADDRESSES
        //

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
        public class IP_ADAPTER_ADDRESSES
        {
            public UInt32 Length;
            public UInt32 IfIndex;
            public IntPtr Next;

            public IntPtr AdapterName;
            public IntPtr FirstUnicastAddress;
            public IntPtr FirstAnycastAddress;
            public IntPtr FirstMulticastAddress;
            public IntPtr FirstDnsServerAddress;

            public IntPtr DnsSuffix;
            public IntPtr Description;

            public IntPtr FriendlyName;

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 8)]
            public Byte[] PhysicalAddress;

            public UInt32 PhysicalAddressLength;
            public UInt32 flags;
            public UInt32 Mtu;
            public UInt32 IfType;

            public Int32 OperStatus;

            public UInt32 Ipv6IfIndex;

            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 16)]
            public UInt32[] ZoneIndices;

            public IntPtr FirstPrefix;
        }

        //
        // Display network adapter information.
        //

        public class AdapterInfo
        {
            //
            // Calls the C API GetAdapterAddressesInfo
            //

            public static List<InterfaceInformation> GetAdapterAddressInfo()
            {
                List<IP_ADAPTER_ADDRESSES> adaptersAddressesCollection;
                IpHlpNetworkAdapterUtil adapterUtils = new IpHlpNetworkAdapterUtil();

                adapterUtils.GetAdaptersAddresses(AddressFamily.Unspecified, GAA_FLAGS.GaaFlagDefault, out adaptersAddressesCollection);

                List<InterfaceInformation> InterfaceList = new List<InterfaceInformation>();

                foreach (IP_ADAPTER_ADDRESSES adapterAddressesBuffer in adaptersAddressesCollection)
                {
                    //
                    // Skip the LoopBack and Tunnel Adapters
                    //

                    IF_TYPE iftype = (IF_TYPE)adapterAddressesBuffer.IfType;
                    if (iftype == IF_TYPE.IfTypeSoftwareLoopback || iftype == IF_TYPE.IfTypeTunnel)
                        continue;

                    //
                    // Check if the interface is not unplugged.
                    //

                    OPERSTATUS operationstatus = (OPERSTATUS)adapterAddressesBuffer.OperStatus;
                    if (operationstatus != OPERSTATUS.IfOperStatusUp)
                        continue;

                    string adapterName = Marshal.PtrToStringAnsi(adapterAddressesBuffer.AdapterName);
                    string FriendlyName = Marshal.PtrToStringAuto(adapterAddressesBuffer.FriendlyName);
                    string description = Marshal.PtrToStringAuto(adapterAddressesBuffer.Description);
                    string dnssuffix = Marshal.PtrToStringAuto(adapterAddressesBuffer.DnsSuffix);

                    string tmpString = string.Empty;

                    for (int i = 0; i < 6; i++)
                    {
                        tmpString += string.Format("{0:X2}", adapterAddressesBuffer.PhysicalAddress[i]);

                        if (i < 5)
                        {
                            tmpString += ":";
                        }
                    }
                    InterfaceInformation Interface = new InterfaceInformation();
                    Interface.AdapterFriendlyName = FriendlyName.ToString();
                    Interface.Description = description.ToString();
                    Interface.AdapterName = adapterName;
                    Interface.MACAddress = tmpString;
                    Interface.InterfaceType = iftype.ToString();
                    Interface.InterfaceIndex = adapterAddressesBuffer.IfIndex.ToString();
                    Interface.IPv6InterfaceAddress = adapterAddressesBuffer.Ipv6IfIndex.ToString();
                    Interface.OperationalAddress = operationstatus.ToString();
                    Interface.DNSSuffix = dnssuffix.ToString();

                    //
                    // Check if DHCP is enabled
                    //

                    UInt32 flag = adapterAddressesBuffer.flags;

                    if((adapterAddressesBuffer.flags & (UInt32)flags.IPAdapterDHCPEnabled) > 0)
                        Interface.DHCPEnabled = true;
                    else
                        Interface.DHCPEnabled = false;

                    //
                    //check if IPv4 is enabled
                    //

                    if((adapterAddressesBuffer.flags & (UInt32)flags.IPAdapterIPv4Enabled) > 0)
                        Interface.IPv4Enabled = true;
                    else
                        Interface.IPv4Enabled = false;

                    //
                    //check if IPv6 is enabled
                    //

                    if((adapterAddressesBuffer.flags & (UInt32)flags.IPAdapterIPv6Enabled) > 0)
                        Interface.IPv6Enabled = true;
                    else
                        Interface.IPv6Enabled = false;


                    //
                    // UNICAST IP ADDRESS INFORMATION
                    //

                    List<IPAddressInfo> IPAddressList = new List<IPAddressInfo>();
                    IP_ADAPTER_UNICAST_ADDRESS ipadapterunicastaddr;
                    IntPtr next = adapterAddressesBuffer.FirstUnicastAddress;

                     while(next != (IntPtr)0)
                    {
                        IPAddressInfo IpAddress = new IPAddressInfo();
                        ipadapterunicastaddr = (IP_ADAPTER_UNICAST_ADDRESS)Marshal.PtrToStructure(next, typeof(IP_ADAPTER_UNICAST_ADDRESS));
                        SOCKET_ADDRESS sock_addr;
                        sock_addr = (SOCKET_ADDRESS)ipadapterunicastaddr.Address;
                        next = ipadapterunicastaddr.Next;

                        //
                        // A sockaddr struct
                        //

                        SOCKADDR sockaddr;
                        SOCKADDRIPV6 sockaddripv6;
                        IPAddress ipaddr = null;

                        //
                        // Marshal memory pointer into a struct
                        //

                        sockaddr = (SOCKADDR)Marshal.PtrToStructure(sock_addr.lpSockAddr, typeof(SOCKADDR));

                        //
                        //Check if the address family is IPV4
                        //

                        if (sockaddr.sa_family == (Int32)System.Net.Sockets.AddressFamily.InterNetwork)
                        {
                            ipaddr = new IPAddress(sockaddr.sa_data);
                        }
                        else if (sockaddr.sa_family == (Int32)System.Net.Sockets.AddressFamily.InterNetworkV6)
                        {
                            //
                            // Marshal memory pointer into a struct
                            //

                            sockaddripv6 = (SOCKADDRIPV6)Marshal.PtrToStructure(sock_addr.lpSockAddr, typeof(SOCKADDRIPV6));
                            ipaddr = new IPAddress(sockaddripv6.sa_data);
                        }

                        if (ipaddr == null)
                             throw new MemberAccessException("Could not parse the interface's IP Address.");

                        //
                        // If the address is empty then, the interface is under transition so skip this address
                        // as this address is blank
                        //

                        string strIPAddr = ipaddr.ToString();
                        if (String.IsNullOrEmpty(strIPAddr) == true)
                            continue;

                        IpAddress.IPAddress = strIPAddr;
                        IpAddress.AddressFamily = ipaddr.AddressFamily.ToString();
                        IpAddress.InterfaceZoneId = adapterAddressesBuffer.ZoneIndices[(uint)SCOPE_LEVEL.ScopeLevelInterface].ToString();
                        IpAddress.LinkLocalAddress = ipaddr.IsIPv6LinkLocal.ToString();
                        IpAddress.MulticastAddress = ipaddr.IsIPv6Multicast.ToString();
                        IpAddress.SiteLocalAddress = ipaddr.IsIPv6SiteLocal.ToString();
                        IPAddressList.Add(IpAddress);
                    }

                    //
                    // DNS SERVER INFORMATION
                    //

                    List<DNSServerInfo> DNSServerList = new List<DNSServerInfo>();
                    IP_ADAPTER_DNS_SERVER_ADDRESS dnsaddr = new IP_ADAPTER_DNS_SERVER_ADDRESS();
                    IntPtr nextdns = adapterAddressesBuffer.FirstDnsServerAddress;

                    while (nextdns != (IntPtr)0)
                    {
                        DNSServerInfo DNSServer = new DNSServerInfo();
                        dnsaddr = (IP_ADAPTER_DNS_SERVER_ADDRESS)Marshal.PtrToStructure(nextdns, typeof(IP_ADAPTER_DNS_SERVER_ADDRESS));
                        SOCKET_ADDRESS sock_addr;
                        sock_addr = (SOCKET_ADDRESS)dnsaddr.Address;
                        nextdns = dnsaddr.Next;

                        //
                        // A sockaddr struct
                        //

                        SOCKADDR sockaddr;
                        SOCKADDRIPV6 sockaddripv6;
                        IPAddress ipaddr = null;

                        //
                        // Marshal memory pointer into a struct
                        //

                        sockaddr = (SOCKADDR)Marshal.PtrToStructure(sock_addr.lpSockAddr, typeof(SOCKADDR));

                        //
                        // Check if the address family is IPV4
                        //

                        if (sockaddr.sa_family == (Int32)System.Net.Sockets.AddressFamily.InterNetwork)
                        {
                            ipaddr = new IPAddress(sockaddr.sa_data);
                        }
                        else if (sockaddr.sa_family == (Int32)System.Net.Sockets.AddressFamily.InterNetworkV6)
                        {
                            //
                            // Marshal memory pointer into a struct
                            //

                            sockaddripv6 = (SOCKADDRIPV6)Marshal.PtrToStructure(sock_addr.lpSockAddr, typeof(SOCKADDRIPV6));
                            ipaddr = new IPAddress(sockaddripv6.sa_data);
                        }

                        if (ipaddr == null)
                             throw new MemberAccessException("Could not parse the interface's IP Address.");

                        DNSServer.DNSAddress = ipaddr.ToString();
                        DNSServer.DNSAddressFamily = ipaddr.AddressFamily.ToString();
                        DNSServer.InterfaceZoneId = adapterAddressesBuffer.ZoneIndices[(uint)SCOPE_LEVEL.ScopeLevelInterface].ToString();
                        DNSServer.LinkLocalAddress = ipaddr.IsIPv6LinkLocal.ToString();
                        DNSServer.MulticastAddress = ipaddr.IsIPv6Multicast.ToString();
                        DNSServer.SiteLocalAddress = ipaddr.IsIPv6SiteLocal.ToString();

                        //
                        //skip default DNS Servers having either of the following site local addresses
                        //fec0:0:0:ffff::1,fec0:0:0:ffff::2,fec0:0:0:ffff::3
                        //

                        if (ipaddr.IsIPv6SiteLocal)
                        {
                            Byte[] bytes = ipaddr.GetAddressBytes();
                            int len = bytes.Length -1;
                            if (bytes[len] >= 1 && bytes[len] <= 3)
                                continue;
                        }

                        DNSServerList.Add(DNSServer);
                    }
                    Interface.IPAddressList = IPAddressList;
                    Interface.DNSServerList = DNSServerList;
                    InterfaceList.Add(Interface);
                }
                return InterfaceList;
            }
        }
        public class IpHlpNetworkAdapterUtil
        {
            //
            // The GetAdaptersAddresses function retrieves the addresses associated with the adapters on the local computer.
            // If the function succeeds, the return value is ERROR_SUCCESS.
            // If the function fails, the return value is one of the following error codes.
            //     ERROR_ADDRESS_NOT_ASSOCIATED
            //     ERROR_BUFFER_OVERFLOW
            //     ERROR_INVALID_PARAMETER
            //     ERROR_NOT_ENOUGH_MEMORY
            //     ERROR_NO_DATA
            //     Other
            //

            [DllImport("Iphlpapi.dll", CharSet = CharSet.Auto)]
            private static extern uint GetAdaptersAddresses(uint Family,
                                                            uint flags,
                                                            IntPtr Reserved,
                                                            IntPtr PAdaptersAddresses,
                                                            ref uint pOutBufLen);

            //
            // A wrapper for GetAdaptersAddresses.
            //

            public void GetAdaptersAddresses(System.Net.Sockets.AddressFamily addressFamily, GAA_FLAGS gaaFlags, out List<IP_ADAPTER_ADDRESSES> adaptersAddressesCollection)
            {
                //
                // The GetAdaptersAddresses function is available only in Windows XP and beyond and hence the version check!
                //

                OperatingSystem os = Environment.OSVersion;
                Version ver = os.Version;
                bool isSupported = false;

                if ((os.Platform == PlatformID.Win32NT) && ((ver.Major == 5 && ver.Minor >= 1) || (ver.Major >= 6)))
                {
                    isSupported = true;
                }
                else
                {
                    throw new NotSupportedException("GetAdaptersAddresses is supported only in Microsoft Windows XP and beyond.");
                }

                adaptersAddressesCollection = new List<IP_ADAPTER_ADDRESSES>();
                UInt32 size = (UInt32)Marshal.SizeOf(typeof(IP_ADAPTER_ADDRESSES));
                IntPtr pAdaptersAddressesBuffer = Marshal.AllocHGlobal((Int32)size);

                uint result = GetAdaptersAddresses((UInt32)addressFamily, (UInt32)gaaFlags, (IntPtr)0, pAdaptersAddressesBuffer, ref size);

                if (result == IpHlpConstants.ErrorBufferFlow)
                {
                    Marshal.FreeHGlobal(pAdaptersAddressesBuffer);
                    pAdaptersAddressesBuffer = Marshal.AllocHGlobal((Int32)size);
                    result = GetAdaptersAddresses((UInt32)addressFamily, (UInt32)gaaFlags, (IntPtr)0, pAdaptersAddressesBuffer, ref size);
                }

                if (result != IpHlpConstants.ErrorSuccess)
                {
                    throw new Win32Exception((Int32)result, "GetAdaptersInfo did not return ERROR_SUCCESS.");
                }

                //
                // Add results only for the success cases...
                //

                if ((result == IpHlpConstants.ErrorSuccess) && (pAdaptersAddressesBuffer != IntPtr.Zero))
                {
                    IntPtr pTempAdaptersAddressesBuffer = pAdaptersAddressesBuffer;

                    do
                    {
                        IP_ADAPTER_ADDRESSES adaptersAddressesBuffer = new IP_ADAPTER_ADDRESSES();
                        adaptersAddressesBuffer = (IP_ADAPTER_ADDRESSES)Marshal.PtrToStructure((IntPtr)pTempAdaptersAddressesBuffer, typeof(IP_ADAPTER_ADDRESSES));
                        adaptersAddressesCollection.Add(adaptersAddressesBuffer);

                        pTempAdaptersAddressesBuffer = (IntPtr)adaptersAddressesBuffer.Next;
                    }
                    while (pTempAdaptersAddressesBuffer != IntPtr.Zero);
                }
            }
        }

        public class IpHlpConstants
        {
            public const Int32 MaxAdapterName = 128;
            public const Int32 MaxAdapterNameLength = 256;
            public const Int32 MaxAdapterDescriptionLength = 128;
            public const Int32 MaxAdapterAddressLength = 8;
            public const UInt32 ErrorBufferFlow = (UInt32)111;
            public const Int32 ErrorSuccess = 0;
        }

        //
        // IF_TYPE
        // IpIfCons.h defines all these types in the platform SDK
        //

        public enum IF_TYPE
        {
            IfTypeOther = 1,
            IfTypeEthernet = 6,
            IfTypeIS088023CSMACD = 7,
            IfTypeISO88025Tokenring = 9,
            IfTypePPP = 23,
            IfTypeSoftwareLoopback = 24,
            IfTypeATM = 37,
            IfTypeIEEE80211 = 71,
            IfTypeTunnel = 131,
            IfTypeIEEE1394 = 144,
        }

        //
        // The operational status for the interface as defined in RFC 2863.
        // This member can be one of the values from the IF_OPER_STATUS enumeration type defined in the Iftypes.h header file. On Windows Vista and later, the header files were reorganized and this enumeration id defined in the Ifdef.h header file.
        //

        public enum OPERSTATUS
        {
            //
            // The interface is up and able to pass packets.
            //

            IfOperStatusUp = 1,

            //
            // The interface is down and not in a condition to pass packets.
            //

            IfOperStatusDown = 2,

            //
            // The interface is in testing mode.
            //

            IfOperStatusTesting = 3,

            //
            // The operational status of the interface is unkwown.
            //

            IfOperStatusUnknown = 4,

            //
            // The interface is not actually in a condition to pass packets (it is not up), but is in a pending state, waiting for some external event.
            //

            IfOperStatusDormant = 5,

            //
            // A refinement on the IfOperStatusDown state which indicates that the relevant interface
            //

            IfOperStatusNotPresent = 6,

            //
            //This new state indicates that this interface runs on top of one or more other interfaces and that this interface is down specifically because one or more of these lower-layer interfaces are down.
            //

            IfOperStatusLowerLayerDown = 7
        }

        //
        // The SCOPE_LEVEL enumeration is used with the IP_ADAPTER_ADDRESSES structure to identify scope levels for IPv6 addresses.
        //

        public enum SCOPE_LEVEL
        {
            ScopeLevelInterface = 1,
            ScopeLevelLink = 2,
            ScopeLevelSubnet = 3,
            ScopeLevelAdmin = 4,
            ScopeLevelSite = 5,
            ScopeLevelOrganization = 8,
            ScopeLevelGlobal = 14
        }

        //
        // IP_PREFIX_ORIGIN
        //

        public enum IP_PREFIX_ORIGIN
        {
            IpPrefixOriginOther = 0,
            IpPrefixOriginManual,
            IpPrefixOriginWellKnown,
            IpPrefixOriginDhcp,
            IpPrefixOriginRouterAdvertisement
        }


        //
        // IP_SUFFIX_ORIGIN
        //

        public enum IP_SUFFIX_ORIGIN
        {
            IpSuffixOriginOther = 0,
            IpSuffixOriginManual,
            IpSuffixOriginWellKnown,
            IpSuffixOriginDhcp,
            IpSuffixOriginLinkLayerAddress,
            IpSuffixOriginRandom
        }

        //
        // IP_DAD_STATE
        //

        public enum IP_DAD_STATE
        {
            IpDadStateInvalid = 0,
            IpDadStateTentative,
            IpDadStateDuplicate,
            IpDadStateDeprecated,
            IpDadStatePreferred
        }

        //
        // Flags used as argument to GetAdaptersAddresses().
        // "SKIP" flags are added when the default is to include the information.
        // "INCLUDE" flags are added when the default is to skip the information.
        // All the values are obtained directly from IpTypes.h file in the platform SDK.
        //
        [Flags]
        public enum GAA_FLAGS
        {
            GaaFlagDefault = 0x0000,
            GaaFlagSkipUnicast = 0x0001,
            GaaFlagSkipAnycast = 0x0002,
            GaaFlagSkipMultiCast = 0x0004,
            GaaFlagSkipDNSServer = 0x0008,
            GaaFlagIncludePrefix = 0x0010,
            GaaFlagSkipFriendlyName = 0x0020,
            GaaFlagIncludeWinsInfo = 0x0040,
            GaaFlagIncludeGateways = 0x0080,
            GaaFlagIncludeAllInterfaces = 0x0100,
            GaaFlagIncludeAllCompartments = 0x0200,
            GaaFlagIncludeTunnelBindingOrder = 0x0400
        }

        //
        // Flags which are returned by IP_ADAPTER_ADDRESSES
        //

        public enum flags
        {
            //
            // Dynamic DNS is enabled on this adapter.
            //

            IPAdapterDDNSEnabled = 0x0001,

            //
            // Register the DNS suffix for this adapter.
            //

            IPAdapterRegisterAdapterSuffix = 0x0002,

            //
            // The Dynamic Host Configuration Protocol (DHCP) is enabled on this adapter.
            //

            IPAdapterDHCPEnabled = 0x0004,

            //
            // The adapter is a receive-only adapter
            //

            IPAdapterReceiveOnly = 0x0008,

            //
            // The adapter is not a multicast recipient.
            //

            IPAdapterNoMulticast = 0x0010,

            //
            // The adapter contains other IPv6-specific stateful configuration information.
            //

            IPAdapterIPv6OtherStatefulConfig = 0x0020,

            //
            // The adapter contains other IPv6-specific stateful configuration information.
            //
            IPAdapterNetBiosOverTCPIPEnabled = 0x0040,

            //
            // The adapter is enabled for NetBIOS over TCP/IP.
            // This flag is only supported on Windows Vista and later when the application has been compiled for a target platform with an NTDDI version equal or greater than NTDDI_LONGHORN. This flag is defined in the IP_ADAPTER_ADDRESSES_LH structure as the NetbiosOverTcpipEnabled bitfield.
            // The adapter is enabled for IPv4.
            //

            IPAdapterIPv4Enabled = 0x0080,

            //
            // Note  This flag is only supported on Windows Vista and later when the application has been compiled for a target platform with an NTDDI version equal or greater than NTDDI_LONGHORN. This flag is defined in the IP_ADAPTER_ADDRESSES_LH structure as the Ipv4Enabled bitfield.
            // The adapter is enabled for IPv6.
            //

            IPAdapterIPv6Enabled = 0x0100,

            //
            // Note  This flag is only supported on Windows Vista and later when the application has been compiled for a target platform with an NTDDI version equal or greater than NTDDI_LONGHORN. This flag is defined in the IP_ADAPTER_ADDRESSES_LH structure as the Ipv6Enabled bitfield.
            //

            Ipv6ManagedAddressConfigurationSupported = 0x0200
        }
    }

'@
    Compile-Csharp $code
}


#
# -----------------------------
# PowerShell Helper Functions
# -----------------------------
#

$XML_NAMESPACE='http://schemas.microsoft.com/bestpractices/models/ServerManager/DNSServer/DNSServerComposite/2010/01'

# This is the correspondence between zone types and the registry type
$ZONE_TYPE =   @{
                    'Cache'           = 0;
                    'Primary'         = 1;
                    'Secondary'       = 2;
                    'Stub'            = 3;
                    'Forwarder'       = 4;
                    'SecondaryCache' =  5;
                };

#  Registry values for zone notification levels (NotifyLevel key)
$ZONE_NOTIFY = @{
                    'Off'   =   0;
                    'NS'    =   1;
                    'List'  =   2;
                };

#  Registry values for zone transfers (SecureSecondaries key)
$ZONE_XFR = @{
                'Unsecure'  =   0;
                'NS'        =   1;
                'List'      =   2;
                'Off'       =   3;
            };

#  This parameter contains a sensitive term, so it will appear only once
$FORWARDING_ENABLED_PARAMETER_NAME = 'IsSlave';

# helper function to create document
function Create-DocumentElement($ns, $name )
{
    [xml] "<$name xmlns='$ns'/>"
}

#Helper function to set the text of the node
function Set-XmlElementInnerText($ElementNode, $ElementValue)
{
    #  make value canonical to XSD type
    if ($ElementValue -is [bool])
    {
        $standard = $(if ($ElementValue) {'true'} else {'false'} )
        $ElementValue = $standard
    }

    #  Write the values in the node element
    $ElementNode.Set_innertext($ElementValue)
}

function Create-XMLElement {
<#
.Synopsis
   Create-XMLElement
   Create an XML document element in $doc and set the inner text
.Parameter ElementName
    The name of the element to be created
.Parameter Value
    The value to set as the inner text
.Example
 $Node_AutoConfig = Create-XMLElement 'tns:AutoConfig' $Elem_AutoConfig
   Creates a new node at Node_AutoConfig and uses the element name 'tns:AutoConfig' and sets the XML Inner text to
   $Elem_AutoConfig
.Notes
    Return value:
       Returns the new document node [System.Xml.XmlElement]
#>
[CmdletBinding()]
PARAM( [String] $ElementName, [Object] $Value )
    $Node = $doc.CreateElement( $ElementName, $XML_NAMESPACE );
    Set-XmlElementInnerText -ElementNode $Node -ElementValue $Value;

    return $Node;
}

function Create-XMLSubtreeForObject {
<#
.Synopsis
   Create-XMLSubtreeForObject
   Recursively outputs an XML subtree for the given Object. The Object's fields are enumerated and the XML elements
   are named using reflection. List objects are understood and an XML subtree is created for each element.
.Parameter Object
   An object with properties to be written.
.Parameter Name (Optional)
   The name for the XML element. If not provided, this will be defaulted using the last class name of the object's
   type (e.g. 'AdapterUtils.InterfaceInformation' will default to 'tns:InterfaceInformation')
.Example
   $childXMLNode = Create-XMLSubtreeForObject -Object $fieldValue -Name $fieldName;
   Generates an XML node for the object $fieldValue, using the name $fieldName;
.Outputs
   Returns the new document node [System.Xml.XmlElement]
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [Object] $Object,
    [AllowNull()]
    [String] $Name = $NULL
    )

    $parentXmlNode = $null;

    #  This trap is required because the PowerShell ETS functions aren't working properly on the domain information
    #  Problems include returning a non-existent 'Children' property
    trap
    {
        Write-Debug "Create-XMLSubtreeForObject: Writing: $Name, Object: <$($Object.GetType().ToString())>, Trapped error $_";
        return $parentXmlNode;
    }

    if ( $Name -eq $null -or $Name.Length -eq 0 )
    {
        #  Write-Debug 'Create-XMLSubtreeForObject: Generating a name';
        #  Determine the name for node based on the name of the type for the given object
        $objectTypeStringArray = $Object.GetType().ToString().Split('.');
        $Name = 'tns:' + $ObjectTypeStringArray[ $ObjectTypeStringArray.Length - 1 ];
    }

    #  Write-Debug "Create-XMLSubtreeForObject: Writing: $Name, Object: <$($Object.GetType().ToString())>";

    #  For other types, either immediately create an element or recurse the object's fields

    switch -wildcard ( $Object.GetType().ToString() ) {
        'System.String'     { return Create-XMLElement $Name $Object }
        'System.Boolean'    { return Create-XMLElement $Name $Object }
        'System.Int*'       { return Create-XMLElement $Name $Object }
        'System.UInt*'      { return Create-XMLElement $Name $Object }
        'System.DateTime'   { return Create-XMLElement $Name $Object.ToString(); }
        '*Hashtable*'
            {
                #  Write-Debug $( 'Create-XMLSubtreeForObject: Processing as hashtable: ' + $Object.GetType().ToString() );

                #  This is to get the rule evaluations to have the RuleName as the node's name
                #  This allows a rule-specific document context (XPATH) to be created in the schematron
                if ( $Name -eq 'tns:EvaluationElement' -and $Object['RuleName'] -ne $NULL )
                {
                    $Name = 'tns:' + $Object['RuleName'];
                    $Object.Remove('RuleName');
                    #  Write-Debug "Create-XMLSubtreeForObject: Overriding EvaluationElement to $Name";
                }

                $parentXmlNode = $doc.CreateElement( $Name , $XML_NAMESPACE );

                #  Elements in the schema are alphabetically ordered, so we need to sort before output.
                foreach ( $key in $Object.Keys | Sort )
                {
                    $keyName = 'tns:' + $key;
                    if ( $Object[$key]-ne $NULL )
                    {
                        $childXMLNode = Create-XMLSubtreeForObject -Object $Object[$key] -Name $keyName;
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                    else
                    {
                        $childXMLNode = Create-XMLElement $keyName 'NULL';
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                }

                 return $parentXmlNode;
            }
        '*System.Collections.Generic.List*'
            {
                #  Write-Debug "Create-XMLSubtreeForObject: List found $Name";
                $parentXmlNode = $doc.CreateElement( $Name , $XML_NAMESPACE );
                $fields = $Object.GetType().GetFields();
                foreach ( $element in $Object )
                {
                    if ( $element -ne $NULL )
                    {
                        $childXMLNode = Create-XMLSubtreeForObject -Object $element;
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                }
                return $parentXmlNode;
            }
        "*``[``]"      
            {
                #  Write-Debug $( 'Create-XMLSubtreeForObject: Processing as object array: ' + $Object.GetType().ToString() );
                $parentXmlNode = $doc.CreateElement( $Name , $XML_NAMESPACE );
                foreach ( $bucket in $Object )
                {
                    $bucketName = $Name + 'Element';
                    if ( $bucket -ne $NULL )
                    {
                        $childXMLNode = Create-XMLSubtreeForObject -Object $bucket -Name $bucketName;
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                    else
                    {
                        $childXMLNode = Create-XMLElement $bucketName 'NULL';
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                }

                return $parentXmlNode;
            }
        default
            {
                #  Write-Debug $( 'Create-XMLSubtreeForObject: Defaulting on ' + $Object.GetType().ToString() );
                $parentXmlNode = $doc.CreateElement( $Name , $XML_NAMESPACE );
                $fields = $Object | get-member -MemberType Property
                foreach ( $field in $fields )
                {
                    $fieldName = 'tns:' + $field.Name;
                    $fieldValue = $Object.($field.Name);
                    if ( $fieldValue -ne $NULL )
                    {
                        $childXMLNode = Create-XMLSubtreeForObject -Object $fieldValue -Name $fieldName;
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                    else
                    {
                        $childXMLNode = Create-XMLElement $fieldName 'NULL';
                        [void]$parentXmlNode.AppendChild($childXMLNode);
                    }
                }

                return $parentXmlNode;
            }
    }
}

function Check-AutoConfig {
<#
.Synopsis
    Checks whether the given IP address is from the autoconfiguration IPv4 block (169.254.*) or if it has the
    link-local address attribute set ( IPv6 address in the ( fe80::/10 ) subnet ).
.Parameter IPAddress
    The IP address to check. Must be a System.Net.IPAddress object (which can be retrieved from Check-AddressValidity)
.Parameter IgnoreIPv6
    If missing or set to $FALSE, if IPAddress is a link-local address, the function will return $TRUE. If set to $TRUE
    an IPv6 link-local address will return $FALSE.
.Outputs
    For an IPv4 address:
        $TRUE if the address is automatically configured or a link-local address
        $FALSE if not
    For an IPv6 address:
        $FALSE if IgnoreIPv6 is set to $TRUE, or IPAddress is not automatically configured or link-local
        $TRUE if IgnoreIPv6 is set to $FALSE or is omitted, and IPAddress is automatically configured or link-local
.Notes
    The link-local address attribute applies only to IPv6 addresses. It will always be false on an IPv4 address.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [System.Net.IPAddress] $IPAddress,
    [parameter(Mandatory=$FALSE)]
    [Boolean] $IgnoreIPv6 = $FALSE
)

    #  Check for an autoconfiguration address
    if ( $IPAddress.IPAddressToString -like '169.254.*' )
    {
            return $TRUE;
    }

    if ( $IgnoreIPv6 -eq $TRUE )
    {
        #  Ignore IPv6 link-local addresses
        return $FALSE;
    }
    else
    {
        #  Return IPv6 link-locality
        return $IPAddress.IsIPv6LinkLocal;
    }
}

function Check-InterfaceHasAddressFamily {
<#
.Synopsis
   Determines if the adapter has an IP addresses from the given family. IP addresses that are marked as link-local or
   multicast are not considered. Site-local addresses are considered.
.Parameter Interface
   Interface object to be checked.
.Parameter Family
   String containing the family (e.g. 'InterNetwork' or 'InterNetworkV6')
.Outputs
    $TRUE   There exists an assigned IP address that has
.Example
   $result = Resolve-Query -RecordType 'AAAA' -IPAddress '4.2.2.1' -Query 'www.microsoft.com';
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [Hashtable]
    $Interface,
    [parameter(Mandatory=$TRUE)]
    [ValidatePattern('InterNetwork(|V6)')]  #  Allows 'InterNetwork' followed by nothing or 'V6'
    [String]
    $Family
    )

    foreach ( $IPAddress in $Interface.IPAddressList )
    {
        if ( $IPAddress.LinkLocalAddress -eq $TRUE -or $IPAddress.MulticastAddress -eq $TRUE )
        {
            #  Skip link-local or multicast address
            continue;
        }

        if ( $IPAddress.AddressFamily -eq $Family )
        {
            #  The interface has requested family
            return $TRUE;
        }
    }

    #  The interface doesn't have the requested family
    return $FALSE;
}

function Resolve-Query {
<#
.Synopsis
   This function will call DNSQuery API with the pExtra parameter containing the Server IP to be queried. It also will
   cache ERROR_TIMEOUT(1460) and immediately return the same error if that address is queried again.
.Parameter RecordType
   String record type (e.g. 'SRV', 'A', 'AAAA',...)
.Parameter IPAddress
   String containing IP address (e.g. '192.168.5.2', 'fe80::1234:abcd')
.Parameter Query
   String IPAddress (e.g. '192.168.5.2', 'fe80::1234:abcd')
.Outputs
   0        ERROR_SUCCESS
   9501     DNS_INFO_NO_RECORDS
   9003     DNS_ERROR_RCODE_NAME_ERROR
   Other    Use winerror.exe to interpret
.Example
   $result = Resolve-Query -RecordType 'AAAA' -IPAddress '4.2.2.1' -Query 'www.microsoft.com';
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String]
    $RecordType = 'A',
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String]
    $IPAddress,
    [parameter(Mandatory=$TRUE)]
    [AllowEmptyString()]
    [String]
    $Query
    )

    trap
    {
        Write-Debug "Resolve-Query: $($error[0])";
        continue;
    }

    #  Check if the global variable has already been declared without throwing an exception when strict mode is on
    if ( $(get-variable RESOLVE_QUERY__TIMED_OUT_IP_ADDRESSES -ValueOnly -erroraction 'SilentlyContinue') -eq $NULL )
    {
        Set-Variable RESOLVE_QUERY__TIMED_OUT_IP_ADDRESSES @{} -Scope Global;
    }

    if ( $RESOLVE_QUERY__TIMED_OUT_IP_ADDRESSES[$IPAddress] -gt 0 )
    {
        Write-Debug "Resolve-Query: Returning cached error ERROR_TIMEOUT(1460) for $IPAddress";
        return 1460;
    }

    $valid = -1;
    $valid = [DnsQueryUtils.DNSQueryInvoker]::GetDNSRecords($RecordType, $Query, $IPAddress);

    #  If the error was ERROR_TIMEOUT
    if ( $valid -eq 1460 )
    {
        $RESOLVE_QUERY__TIMED_OUT_IP_ADDRESSES[$IPAddress]++;
        Write-Debug "Resolve-Query: $IPAddress has timed out; caching timeout."
    }

    return $valid;
}

function Get-NSRecordsForZone {
<#
.Synopsis
   Given a zone name, this function will use the DNSCMD /enumrecords command to retrieve the IP addresses in the
   additional data for the NS records of the zone (in short, the IP addresses of the nameservers for that zone).
.Parameter ZoneName
   String containing zone name (e.g. 'contoso.com'). This zone MUST be hosted on this server.
.Outputs
   $NULL on error
   Otherwise, a string array of IP addresses [String[]]
.Example
   $NSIPAddresses = Get-NSRecordsForZone -ZoneName 'www.microsoft.com'
.Example
   #  This is DNSCMD-specific
   $RootHints = Get-NSRecordsForZone -ZoneName '/RootHints'
.Notes
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ZoneName
    )

    $DNSCmd = $(get-childitem -path env:SystemRoot).Value + "\system32\dnscmd.exe";
    $errVar = $NULL;
    $returnArray = $NULL;

    #  Get the output of dnscmd /enumrecords for the zone, and check that were no errors
    $CMDLine = "$DNSCmd /EnumRecords $ZoneName '@' /Type NS /Additional";

    $dnscmdOutput = exec -cmd $CMDLine -errVarRef ([ref]$errVar);
    if ( $errVar )
    {
        Write-Debug "Get-NSRecordsForZone: DNSCmd.exe returned error: $errVar";
        Write-Debug "Get-NSRecordsForZone: Output: $dnscmdOutput";
    }
    else
    {
        #  Scan the output and retrieve the IP addresses. Note that this is not affected by localization.
        foreach ( $line in $dnscmdOutput )
        {
            #  This regular expression matches lines listing A/AAAA records and saves the IP addresses and record
            #  type
            #  Write-Debug "Get-NSRecordsForZone: Line: $line";
            if ( $line -match "^.*\s+(?<RecordType>A|AAAA)\s*(?<IPAddress>[0-9a-fA-F:.]+)\s*$" )
            {
                $returnArray += @( $matches['IPAddress'] );
            }
        }
    }

    return $returnArray;
}

function Get-NSRecords {
<#
.Synopsis
   This function will call nslookup to get
.Parameter RecordType
   String record type (e.g. 'SRV', 'A', 'AAAA',...)
.Parameter IPAddress
   String containing IP address (e.g. '192.168.5.2', 'fe80::1234:abcd')
.Parameter Query
   String IPAddress (e.g. '192.168.5.2', 'fe80::1234:abcd')
.Outputs
   0        ERROR_SUCCESS
   9501     DNS_INFO_NO_RECORDS
   9003     DNS_ERROR_RCODE_NAME_ERROR
   Other    Use winerror.exe to interpret
.Example
   $result = Resolve-Query -RecordType 'AAAA' -IPAddress '4.2.2.1' -Query 'www.microsoft.com';
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String]
    $RecordType = 'A',
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String]
    $IPAddress,
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Query
    )

    trap
    {
        Write-Debug "Resolve-Query: $($error[0])";
        continue;
    }

    $valid = -1;
    $valid = [DnsQueryUtils.DNSQueryInvoker]::GetDNSRecords($RecordType, $Query, $IPAddress);

    return $valid;
}

function Check-AddressValidity {
<#
.Synopsis
    Checks whether the given IP address is valid (i.e. properly parsable)
.Parameter IPAddressString
    The IP address to check, as a string
.Parameter IPAddress
    (Optional) A reference (can be null) that will be populated with a System.Net.Ipaddress object if parsing succeeds.
.Outputs
    $TRUE if the address is parsable
    $FALSE if not
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String] $IPAddressString,
    [AllowNull()]
    [ref] $IPAddress
)

    #  Create a system.net.ipaddress object to be passed as a reference
    $IPAddress = [system.net.ipaddress] '169.254.0.0';

    #  Try parsing the IP address
    return [System.Net.Ipaddress]::TryParse( [string]$IPAddressString, [ref] $IPAddress );
}

function Check-Loopback {
<#
.Synopsis
    Checks whether the given IP address is loopback or refers to one of the local interfaces
.Parameter IPAddress
    The IP address to check. Must be a System.Net.IPAddress object (which can be retrieved from Check-AddressValidity)
.Outputs
    $TRUE if the address is loopback or a local interface
    $FALSE if not
.Notes
    The global variable $Configuration['ServerConfiguration']['InterfaceAddresses'] needs to be defined before using
    this function. If in strict mode, an exception may be thrown.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [System.Net.IPAddress] $IPAddress
)

    #  Check for a loopback, screening out addresses starting with 255, since IsLoopback improperly returns $TRUE for these
    if ( [System.Net.Ipaddress]::IsLoopback($IPAddress) -and -not ( $IPAddress.IPAddressToString -like "255.*.*.*" ) )
    {
            #  Write-Debug "Check-Loopback: [System.Net.Ipaddress]::IsLoopback($IPAddress) returns TRUE";
            return $TRUE;
    }

    #  Check for the interface addresses

    #  Get the list of interface addresses from a global variable
    $InterfaceAddresses = $Configuration['ServerConfiguration']['InterfaceAddresses'];

    foreach ( $Address in $InterfaceAddresses )
    {
        if ( $Address.IPAddress -eq $IPAddress )
        {
            #  Write-Debug "Check-Loopback: $Address.IPAddress -eq $IPAddress";
            return $TRUE;
        }
    }

    return $FALSE;
}

function Get-IsDomainController {
<#
.Synopsis
   Get-IsDomainController
   Check if the current host is a domain controller.
.Parameter HostName
    (Optional) The hostname of the machine to query for status as a domain controller
.Example
    $x = Get-IsDomainController
    Determines if the local machine is a domain controller and stores the boolean result in variable x
.Example
    $x = Get-IsDomainController 'dc-hostname.domain.com'
    Determines if 'dc-hostname.domain.com' is a domain controller and stores the boolean result in variable x
.Notes
    This implementation will store the result of the first localhost invocation
    in the global variable $LOCALHOST_IS_DOMAIN_CONTROLLER; This allows this
    function to skip the costly call to Get-WMIObject on subsequent calls.

    Return values:

    $true if the machine is a domain controller
    $FALSE if the machine is not domain controller
    [Exception] if get-wmiobject throws
#>
[CmdletBinding()]
PARAM( [String] $HostName = 'localhost' )
    $VER_NT_DOMAIN_CONTROLLER = 2;

    #  This avoids the slow get-wmiobject call for localhost
    #  Devnote: consider making the global into an key/value array to cover all hosts
    #  Check if the global variable has already been declared without throwing an exception when strict mode is on
    if ( $Hostname -eq 'localhost' -and
        $( get-variable LOCALHOST_IS_DOMAIN_CONTROLLER -ValueOnly -erroraction 'SilentlyContinue' ) -ne $NULL )
    {
        return $LOCALHOST_IS_DOMAIN_CONTROLLER;
    }

    #  Retrieve operating system information from HostName
    #  Devnote: may want to catch exceptions here and try a TCP connection to the LDAP port as an approximation of being a DC
    $operatingSystem = get-wmiobject -ComputerName $HostName -class Win32_OperatingSystem | select-object -property ProductType;

    if ( $operatingSystem.ProductType -eq $VER_NT_DOMAIN_CONTROLLER )
    {
        set-variable -Name isDomainController -Value $TRUE;
    }
    else
    {
        set-variable -Name isDomainController -Value $FALSE;
    }

    # Save the result as a global variable if the query was for 'localhost'
    if ( $Hostname -eq 'localhost' )
    {
        set-variable -Name LOCALHOST_IS_DOMAIN_CONTROLLER -Scope 'global' -Value $isDomainController;
    }

    return $isDomainController;
}

function Get-ADConfiguration {
<#
.Synopsis
   Get Active Server Directory Information
.Notes
   This function does not return a hash like most other Get-*Configuration functions. Also, if the machine is not
   domain-joined, the call will block for several seconds before returning $NULL;
.Outputs
   A System.DirectoryServices.ActiveDirectory.Domain object for the current domain, or $NULL if the machine is not
   domain joined or there was an error.
#>
[CmdletBinding()]
PARAM( )

    #  This is a call that should work on any machine to get domain information
    #  In the first version of the BPA this was a call to GetCurrentDomain, which was not guaranteed to match the
    #  computer's domain information, just the domain info for the credentials running this script

    try
    {
        $DomainInfo = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain();
    }
    #  The most likely error here is [System.DirectoryServices.ActiveDirectory]::ActiveDirectoryObjectNotFoundException
    #  but PowerShell seems to convert that to an internal ErrorRecord
    catch
    {
        Write-Debug "Get-ADConfiguration: This machine is not domain-joined or the AD object couldn't be contacted.";
        return $NULL;
    }

    return $DomainInfo;
}

function New-RuleEvaluationHash {
<#
.Synopsis
   Generates a new RuleEvaluationHash object. This object represents the result of a single BPA test.
.Parameter RuleName
   This is the name of the rule tested. It must match the rule name in the schema, Schematron, and UI resources.
.Parameter Compliant
   $TRUE if the system is compliant with the rule. $FALSE otherwise.
.Parameter Field0
   The string information that will replace '{0}' in the UI resources for this rule.
.Parameter Field1
   The string information that will replace '{1}' in the UI resources for this rule.
.Parameter Field2
   The string information that will replace '{2}' in the UI resources for this rule.
.Outputs
    Always returns a hashtable.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String] $RuleName,
    [boolean] $Compliant = $FALSE,
    [Object] $Field0 = $NULL,
    [Object] $Field1 = $NULL,
    [Object] $Field2 = $NULL
)
    return @{
               'RuleName'  = $RuleName;    #  The name of the rule; this matches the UI messages name, if any
               'Compliant' = $Compliant;   #  $TRUE = Test passed; $FALSE = Test failed
               'Field0'    = $Field0;      #  Strings used to fill-in-the-blanks of UI messages;
               'Field1'    = $Field1;      #  Shouldn't use array, since these need to be addressed by the schematron
               'Field2'    = $Field2;
           };
}

function Get-RuleEvaluation-BindingOrder {
<#
.Synopsis
    Checks that less-valid interfaces are not first in the binding order. Interfaces are weighted based on whether they
    have autoconfigured IP addresses, have no IP addresses, and whether they have non-autoconfigured DNS servers.
.Parameter InputConfiguration
    Results from Get-InterfaceConfiguration
.Outputs
    BindingOrder(Compliant=$FALSE) if there is a mis-ordered interface.
    BindingOrder(Compliant=$TRUE) otherwise.

    Field0 = Interface internal name (GUID).
.Notes
    There is also a IPv6 version of the binding order, which is not being checked.

    Interfaces are classified according to:

        Invalid DNS Server IPs: TRUE, if there are no DNS servers configured for the interface, or if any of
        them have an 'Invalid' address family, or if the 'DNSAutoConfig' test returns FALSE. FALSE otherwise.

        Invalid Adapter IPs: TRUE, if the adapter has no assigned IP addresses, or any of the IP addresses
        fails the 'IPAutoConfiguration' test. FALSE otherwise.

    Weighting is as follows:

        Base weight is zero.

        If the interface does not have invalid DNS server IPs, increase the weight by 1.

        If the interface does not have invalid Adapter IPs, increase the weight by 2.

    The interfaces are expected to be in order by descending weight. Interfaces that are software loopback
    addresses or tunnels (interfaces that are ignored by Get-InterfaceConfiguration) are allowed to appear
    anywhere in the binding order.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $IPBindingOrder = $InputConfiguration['Bind'];
    $Interfaces = $InputConfiguration['Interfaces'];
    $InterfaceBindingOrderHash = @{};
    $InvalidAdapterIP = $FALSE;
    $InvalidDNSIP = $FALSE;

    #  Check for less than two interfaces and immediately return. There's only one possibly ordering for 1 or 0
    #  interfaces.
    if ( $Interfaces.Count -lt 2 )
    {
        Write-Debug 'BindingOrder: This machine is compliant, since there are less than two interfaces.';
        $ReturnHash.Value['Compliant'] = $TRUE;
        return $TRUE;
    }

    #  Note: code below is not safe if there is only one interface

    Foreach ( $Interface in $Interfaces)
    {
        $TestInputHash = @{ 'Interface' = $Interface };

        #  Ensure that having no DNS servers is also considered invalid
        $InvalidDNSIP = $TRUE;
        #  Recursively call DNSAutoConfig to learn of invalid DNS servers
        foreach ( $DNSIPAddress in $Interface.DNSServerList )
        {
            if ( $DNSIPAddress.DNSAddressFamily -like 'Invalid' )
            {
                $InvalidDNSIP = $TRUE;
            }
            else
            {
                $TestInputHash['IPAddress'] = $DNSIPAddress;
                $InvalidDNSIP = -not ( Get-RuleEvaluation 'DNSAutoConfig' $TestInputHash );
            }

            if ( $InvalidDNSIP -eq $TRUE )
            {
                break;
            }
        }

        #  Ensure that an interface with no IP addresses is treated like an interface with an invalid IP address
        $InvalidAdapterIP = $TRUE;

        #  Recursively call IPAutoConfiguration for each IP address on this adapter
        foreach ( $IPAddress in $Interface.IPAddressList )
        {
            $TestInputHash['IPAddress'] = $IPAddress;
            $InvalidAdapterIP = -not ( Get-RuleEvaluation 'IPAutoConfiguration' $TestInputHash );
            if ( $InvalidAdapterIP -eq $TRUE )
            {
                break;
            }
        }

        #  Store the weights associated with the Interfaces in the array on the basis of the validity of the DNS
        #  Servers. If the interface has valid IP addresses as well as valid DNS servers, then its weight will be
        #  2+1=3.
        if ( $InvalidAdapterIP -eq $FALSE )
        {
            $InterfaceBindingOrderHash[$Interface.AdapterName] = 2;
        }
        else
        {
            $InterfaceBindingOrderHash[$Interface.AdapterName] = 0;
        }

        if ( $InvalidDNSIP -eq $FALSE )
        {
            $InterfaceBindingOrderHash[$Interface.AdapterName] += 1;
        }
    }

    $FilteredInterfaceBindingOrderHash = @{};

    #  The CSharp code to get our interface information purposefully ignores certain invalid interfaces.
    #  Nonetheless, they need to be included in the $InterfaceBindingOrderHash with weight 0.
    #  It is also possible to have fewer binding entries than we have valid interfaces. That means that
    #  the InterfaceBindingOrderHash needs to be filtered to include only interfaces in the binding order.
    Foreach ( $Bind in $IPBindingOrder )
    {
        #  Strip '/device/' (8 chars) off the front of each subkey
        #  Ex: "\Device\{11AF600D-D459-4E1E-9F3E-B52BCB36A161}" -> "{11AF600D-D459-4E1E-9F3E-B52BCB36A161}"
        $AdapterName = $Bind.SubString( 8, $Bind.Length - 8 );

        #  It is normal to have unknown interfaces in the binding order. Ignore them, since many times they are ranked
        #  higher than the interface(s) we are interested in.
        if ( $InterfaceBindingOrderHash[$AdapterName] -eq $NULL )
        {
            continue;
        }
        else
        {
            $FilteredInterfaceBindingOrderHash[$AdapterName] = $InterfaceBindingOrderHash[$AdapterName];
        }

        write-debug "BindingOrder: $AdapterName = $($FilteredInterfaceBindingOrderHash[$AdapterName])";
    }

    $InterfaceBindingOrderHash = $FilteredInterfaceBindingOrderHash;
    $ImproperInterface = $NULL;
    $PreferredInterfaceOrder = $InterfaceBindingOrderHash.GetEnumerator() | sort -Property Value -Descending;
    $i = 0;
    Foreach ( $Bind in $IPBindingOrder )
    {
        $AdapterName = $Bind.SubString( 8, $Bind.Length - 8 );
        write-debug "BindingOrder: $($i): Evaluating order for $AdapterName";
        #  If the highest is zero, we are at the bottom of the barrel and we don't need to continue
        if ( $i -ge $PreferredInterfaceOrder.Count -or $PreferredInterfaceOrder[$i].Value -eq 0 )
        {
            write-debug "BindingOrder: $($i): Breaking because $i > (No. Ordering entries) $($PreferredInterfaceOrder.Count)";
            write-debug "BindingOrder: $($i):       or because the value PreferredInterfaceOrder[$i].Value is now zero";
            break;
        }

        if ( $InterfaceBindingOrderHash[$AdapterName] -ne $NULL )
        {
            write-debug "BindingOrder: $($i): InterfaceBindingOrderHash[$AdapterName] = $($InterfaceBindingOrderHash[$AdapterName])";
            write-debug "BindingOrder: $($i): PreferredInterfaceOrder[$i].Value = $($PreferredInterfaceOrder[$i].Value)";
            if ( $InterfaceBindingOrderHash[$AdapterName] -ne $PreferredInterfaceOrder[$i].Value )
            {
                Write-Debug $( "BindingOrder: $($PreferredInterfaceOrder[$i].Key) is non-compliant." );
                $ImproperInterface = $AdapterName;
                break;
            }
            ++$i;
        }

        write-debug "BindingOrder: Done Evaluating order for $AdapterName";
    }
    if ( $ImproperInterface -ne $NULL )
    {
        $ReturnHash.Value['Field0'] = $ImproperInterface ;
    }
    else
    {
        Write-Debug $( 'BindingOrder: This machine is compliant.' );
        $ReturnBool = $TRUE;
        $ReturnHash.Value['Compliant'] = $TRUE;
    }
    return $ReturnBool;
}

function Get-RuleEvaluation-DNSAutoConfig  {
<#
.Synopsis
    Checks that the DNS server of the IPv4 interface or interfaces provided are not autoconfigured
.Parameter InputConfiguration
    Hash with keys 'Interface' and 'IPAddress'
.Outputs
    DNSAutoConfig(Compliant=$FALSE) if the given DNS server is a 169.254.* IPv4 address
    DNSAutoConfig(Compliant=$TRUE) otherwise

    Field0 = DNS server IP address
    Field1 = Interface friendly name
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $TRUE;
    $AdapterFriendlyName = $InputConfiguration['Interface'].AdapterFriendlyName;
    $IPAddress = $InputConfiguration['IPAddress'];
    $DNSServerIPIsAutoconfig = $NULL;

    #  Check for automatically-configured address only on IPv4 addresses
    $DNSServerIPIsAutoconfig = check-AutoConfig -IPAddress $IPAddress.DNSAddress -IgnoreIPv6 $TRUE;

    if ( $DNSServerIPIsAutoconfig -eq $TRUE )
    {
        $ReturnBool = $FALSE;
        $ReturnHash.Value['Field0'] = $IPAddress.DNSAddress;
        $ReturnHash.Value['Field1'] = $AdapterFriendlyName;
    }
    else
    {
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $IPAddress.DNSAddress;
        $ReturnHash.Value['Field1'] = $AdapterFriendlyName;
    }
    return $ReturnBool;
}

function Get-RuleEvaluation-DNSLoopback  {
<#
.Synopsis
    Checks that the DNS servers on an interface contain the loopback address, but that it isn't the first address.
.Parameter InputConfiguration
    An Interface object.
.Outputs
    DNSLoopback(Compliant=$FALSE) if there are no loopback addresses in the DNS servers list
    DNSLoopbackFirst(Compliant=$FALSE) if a loopback address is first in the DNS servers list
    DNSLoopback(Compliant=$TRUE) if there is a loopback address and it is not the first entry.

    Field0 = Interface friendly name.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $TRUE;

    $AdapterFriendlyName = $InputConfiguration.AdapterFriendlyName;
    $DNSServerListHasLoopback = $FALSE;
    $LoopbackIsFirst = $FALSE;
    $FirstTimeThrough = $TRUE;

    #  Check for the presence and position of the first (if any) loopback address on this adapter. DNS
    #  server addresses that are not in the 'InterNetwork' or 'InterNetworkV6' families are ignored.

    #  Check IPv6 Addresses first, since the DNS client prefers IPv6 addresses over IPv4, but we
    #  may not receive these addresses first in the configuration.
    Foreach ( $IPAddress in $InputConfiguration.DNSServerList )
    {
        if ( $IPAddress.DNSAddressFamily -like 'InterNetworkV6' )
        {
            if ( $( check-Loopback -IPAddress $IPAddress.DNSAddress ) -eq $TRUE )
            {
                $DNSServerListHasLoopback = $TRUE;
                if ( $FirstTimeThrough -eq $TRUE )
                {
                    $LoopbackIsFirst = $TRUE;
                }
                break;
            }
            $FirstTimeThrough = $FALSE;
        }
    }

    #  Now check IPv4 addresses
    Foreach ( $IPAddress in $InputConfiguration.DNSServerList )
    {
        if ( $IPAddress.DNSAddressFamily -like 'InterNetwork' )
        {
            if ( $( check-Loopback -IPAddress $IPAddress.DNSAddress ) -eq $TRUE )
            {
                $DNSServerListHasLoopback = $TRUE;
                if ( $FirstTimeThrough -eq $TRUE )
                {
                    $LoopbackIsFirst = $TRUE;
                }
                break;
            }
            $FirstTimeThrough = $FALSE;
        }
    }
    #  For the non-compliant case, we only output either DNSLoopback or DNSLoopbackFirst
    #  For the compliant case, we output DNSLoopback only.
    if ( $LoopbackIsFirst -eq $TRUE )
    {
        Write-Debug $( "DNSLoopback: $($InputConfiguration.AdapterFriendlyName)'s DNS server address list has" +
            ' loopback first'
        );
        $ReturnBool = $FALSE;
        $ReturnHash.Value['RuleName'] = 'DNSLoopbackFirst';
        $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
    }
    elseif ( $DNSServerListHasLoopback -eq $FALSE )
    {
        Write-Debug $( "DNSLoopback: $($InputConfiguration.AdapterFriendlyName)'s DNS server address list is " +
            'missing a loopback address'
        );
        $ReturnBool = $FALSE;
        $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
    }
    else
    {
        Write-Debug $( "DNSLoopback: $($InputConfiguration.AdapterFriendlyName)'s DNS server address list is " +
            'compliant with loopback recommendations'
        );
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
    }
    return $ReturnBool;
}

function Get-RuleEvaluation-DNSServerConfigured  {
<#
.Synopsis
    Checks that there are at least two DNS servers configured on the interface.
.Parameter InputConfiguration
    An Interface object.
.Outputs
    NoDNSServerConfigured(Compliant=$FALSE) if the interface has no DNS servers configured.
    DNSServerConfigured(Compliant=$FALSE) if the interface has only one DNS server configured.
    DNSServerConfigured(Compliant=$TRUE) if the interface has two or more DNS servers configured.

    Field0 = Interface friendly name.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)
    $ReturnBool = $TRUE;

    $DNSServerListHasLoopback = $FALSE;
    $CountDNSServers = 0;
    #  Count DNS server IPs; Count more than one loopback address as just one address.
    Foreach ( $IPAddress in $InputConfiguration.DNSServerList )
    {
        if ( $( check-Loopback -IPAddress $IPAddress.DNSAddress ) -eq $TRUE )
        {
            $DNSServerListHasLoopback = $TRUE;
        }
        else
        {
            ++$CountDNSServers;
        }
    }

    if ( $DNSServerListHasLoopback -eq $TRUE )
    {
        ++$CountDNSServers;
    }

    if ( $CountDNSServers -eq 0 )
    {
        Write-Debug $(
            "DNSServerConfigured: $($InputConfiguration.AdapterFriendlyName) has no DNS servers configured"
        );
        $ReturnBool = $FALSE;
        $ReturnHash.Value['RuleName'] = 'NoDNSServerConfigured';
        $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
    }
    elseif ( $CountDNSServers -eq 1 )
    {
        Write-Debug $( "DNSServerConfigured: $($InputConfiguration.AdapterFriendlyName)'s DNS server address " +
            'list has one address'
        );
        $ReturnBool = $FALSE;
        $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
    }
    else
    {
        Write-Debug $( "DNSServerConfigured: $($InputConfiguration.AdapterFriendlyName) has two or more DNS " +
            'servers'
        );
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
    }
    return $ReturnBool;
}

function Get-RuleEvaluation-NoIPAddressesExist  {
<#
.Synopsis
    Checks that the machine has at least one interface with an assigned IP address.
.Parameter InputConfiguration
    An Interfaces object.
.Outputs
    NoIPAddressesExist(Compliant=$FALSE) if there are no interfaces with an assigned IP address
    NoIPAddressesExist(Compliant=$TRUE) otherwise.

#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)
    $ReturnBool = $FALSE;

    if ( $InputConfiguration -ne $NULL )
    {
        $ReturnBool = $TRUE;
        $ReturnHash.Value['Compliant'] = $TRUE;
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-IPAutoConfiguration  {
<#
.Synopsis
    Checks that the given IP address is not autoconfigured
.Parameter InputConfiguration
    Hash with keys 'Interface' and 'IPAddress'
.Outputs
    IPAutoConfiguration(Compliant=$FALSE) if the given IP address is an IPv4 autoconfigured address (169.254.*)
    IPAutoConfiguration(Compliant=$TRUE) otherwise

    Field0 = Interface's IP address.
    Field1 = Interface friendly name.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)
    $ReturnBool = $TRUE;
    $AdapterFriendlyName = $InputConfiguration['Interface'].AdapterFriendlyName;
    $IPAddress = $InputConfiguration['IPAddress'];
    $AdapterIPIsAutoconfig = $NULL;

    #  Check for IPv4 autoconfiguration (ignore IPv6 link-local addresses)
    $AdapterIPIsAutoconfig = check-AutoConfig -IPAddress $IPAddress.IPAddress -IgnoreIPv6 $TRUE;

    if ( $AdapterIPIsAutoconfig -eq $TRUE )
    {
        Write-Debug "IPAutoConfiguration: Non-Compliant: $($IPAddress.IPAddress) of $AdapterFriendlyName";
        $ReturnBool = $FALSE;
        $ReturnHash.Value['Field0'] = $IPAddress.IPAddress;
        $ReturnHash.Value['Field1'] = $AdapterFriendlyName;
    }
    else
    {
        Write-Debug "IPAutoConfiguration:     Compliant: $($IPAddress.IPAddress) of $AdapterFriendlyName";
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $IPAddress.IPAddress;
        $ReturnHash.Value['Field1'] = $AdapterFriendlyName;
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-IPv4DHCPConfiguration  {
<#
.Synopsis
    Checks that given interface is not configured using DHCP
.Parameter InputConfiguration
    An Interface object.
.Outputs
    IPv4DHCPConfiguration(Compliant=$FALSE) if the given interface is autoconfigured (DHCPEnabled == $TRUE)
        and the interface has IPv4 enabled (IPv4Enabled == $TRUE)
    IPv4DHCPConfiguration(Compliant=$TRUE) if the given interface is not autoconfigured
       (DHCPEnabled != $TRUE) and the interface has IPv4 enabled (IPv4Enabled == $TRUE)
    NULL-result when IPv4 is not enabled for this interface

    Field0 = Interface friendly name.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    #  DHCPEnabled only applies to the IPv4 stack.
    if ( $InputConfiguration.IPv4Enabled -eq $TRUE )
    {
        if ( $InputConfiguration.DHCPEnabled -eq $TRUE )
        {
            Write-debug "IPv4DHCPConfiguration: Non-Complaint: $($InputConfiguration.AdapterFriendlyName) is dynamically configured for IPv4";
            $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
        }
        else
        {
            Write-debug "IPv4DHCPConfiguration:     Complaint: $($InputConfiguration.AdapterFriendlyName) is statically configured for IPv4";
            $ReturnBool = $TRUE;
            $ReturnHash.Value['Compliant'] = $TRUE;
            $ReturnHash.Value['Field0'] = $InputConfiguration.AdapterFriendlyName;
        }
    }
    else
    {
        #  Emit neither a compliant nor a non-compliant message
        Write-debug "IPv4DHCPConfiguration: NULL-Result: IPv4 not enabled for $($InputConfiguration.AdapterFriendlyName)";
        $ReturnHash.Value = $NULL;
    }
    return $ReturnBool;
}

function Get-RuleEvaluation-Param_Blocklist  {
<#
.Synopsis
    Checks that the blocklist is not empty if the global query blocklist is enabled
    non-commented)
.Parameter InputConfiguration
    ServerConfiguration object
.Notes:
    Source:     Rule 10f 'Block list is empty and enabled'
.Outputs
    Param_Blocklist(Compliant=$FALSE) if the blocklist is empty and enabled
    Param_Blocklist(Compliant=$TRUE) otherwise.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $Parameters = $InputConfiguration['Parameters'];

    if ( $Parameters['EnableGlobalQueryBlockList'] -eq $NULL -or $Parameters['EnableGlobalQueryBlockList'] -eq 1 )
    {
        if ( $Parameters['GlobalQueryBlockList'] -eq $NULL -or
            $Parameters['GlobalQueryBlockList'] -isnot [System.Array] -or
            $Parameters['GlobalQueryBlockList'].Count -lt 1 )
        {
            Write-Debug 'Param_Blocklist: Non-compliant';
            $ReturnBool = $FALSE;
        }
        else
        {
            Write-Debug 'Param_Blocklist: Blocklist is enabled;     Compliant ';
            $ReturnBool = $TRUE;
            $ReturnHash.Value['Compliant'] = $TRUE;
        }
    }
    else
    {
        Write-Debug 'Param_Blocklist: Blocklist is disabled;     Compliant ';
        $ReturnBool = $TRUE;
        $ReturnHash.Value['Compliant'] = $TRUE;
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Param_CacheLockingOff  {
<#
.Synopsis
    Checks that Cachelocking fix hasn't been partially or totally disabled. Threshold for warning is at 90% (default
    CacheLockingPercent is 100%).
.Parameter InputConfiguration
    ServerConfiguration object
.Notes
    Source:     Rule 10h 'CacheLocking is off or set to 0'
    Reference:  http://technet.microsoft.com/en-us/library/ee683892(WS.10).aspx
.Outputs
    Param_CacheLockingOff(Compliant=$FALSE) if the CacheLockingPercent parameter is less than 90 (%)
    Param_CacheLockingOff(Compliant=$TRUE) otherwise

    Field0 = Value of CacheLockingPercent
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $Default_CacheLockingPercent = 100;

    $Registry_CacheLockingPercent = $InputConfiguration['Parameters']['CacheLockingPercent'];
    #  Cache locking can be reduced a little bit, but shouldn't be reduced by much because it is opening
    #  a nice big window for a cache-poisoning attack
    if ( $Registry_CacheLockingPercent -ne $NULL -and
         $Registry_CacheLockingPercent -lt $( ( $Default_CacheLockingPercent / 10 ) * 9 ) )
    {
        # Non-Compliant
        Write-Debug "Param_CacheLockingOff: CacheLockingPercent is non-compliant: $Registry_CacheLockingPercent";
        $ReturnHash.Value['Field0'] = $Registry_CacheLockingPercent;
        return $ReturnBool;
    }
    elseif ( $Registry_CacheLockingPercent -ne $NULL )
    {
        $Effective_CacheLockingPercent = $Registry_CacheLockingPercent;
    }
    else
    {
        $Effective_CacheLockingPercent = $Default_CacheLockingPercent;
    }

    write-debug "Param_CacheLockingOff: Effective_CacheLockingPercent=$Effective_CacheLockingPercent";
    Write-Debug 'Param_CacheLockingOff: Fully Compliant';

    $ReturnHash.Value['Compliant'] = $TRUE;
    $ReturnHash.Value['Field0'] = $Effective_CacheLockingPercent;
    return $ReturnBool;
}

function Get-RuleEvaluation-Param_ForwardingTimeout  {
<#
.Synopsis
    Checks that forwarding timeout hasn't been set to unreasonable values ( < 2 or > 10 )
.Parameter InputConfiguration
    ServerConfiguration object
.Notes:
    Source:     Rule 9f 'Forwarder timeout'
    Reference:  http://technet.microsoft.com/en-us/library/cc940784.aspx
    Discussion:
        The forwarding server needs to be given a reasonable amount of time to answer the query. Most forwarding
        servers will have root hints enabled and may have to query on the internet for the answer. Therefore we
        warn on a timeout of 1. On the other hand, no internet DNS server should take more than a few seconds
        to return, and if the local server has root hints enabled, it will need some time for the internet
        query. Microsoft DNS clients have a default timeout of 15 seconds, hence the upper bound of 10 seconds.
.Outputs
    Param_ForwardingTimeout(Compliant=$FALSE) if the forwarding timeout is set to < 2 or > 10 seconds.
    Param_ForwardingTimeout(Compliant=$TRUE) otherwise.

    Field0 = Effective forwarding timeout
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    #  Note that the reference claims the default is 0x5; I have confirmed that for 2008 R2, the default is 3 seconds.
    $Default_ForwardingTimeout = 3;

    $Registry_ForwardingTimeout = $InputConfiguration['Parameters']['ForwardingTimeout'];

    if ( $Registry_ForwardingTimeout -ne $NULL -and
         ( $Registry_ForwardingTimeout -lt 2 -or
           $Registry_ForwardingTimeout -gt 10 ) )
    {
        # Non-Compliant
        Write-Debug "Param_ForwardingTimeout: ForwardingTimeout is non-compliant: $Registry_ForwardingTimeout";
        $ReturnHash.Value['Field0'] = $Registry_ForwardingTimeout;
        return $ReturnBool;
    }
    elseif ( $Registry_ForwardingTimeout -ne $NULL )
    {
        $Effective_ForwardingTimeout = $Registry_ForwardingTimeout;
    }
    else
    {
        $Effective_ForwardingTimeout = $Default_ForwardingTimeout;
    }

    write-debug "Param_ForwardingTimeout: Effective_ForwardingTimeout=$Effective_ForwardingTimeout";
    Write-Debug 'Param_ForwardingTimeout: Fully Compliant';

    $ReturnHash.Value['Compliant'] = $TRUE;
    $ReturnHash.Value['Field0'] = $Effective_ForwardingTimeout;
    return $ReturnBool;
}

function Get-RuleEvaluation-Param_Hosts  {
<#
.Synopsis
    Checks that hosts file(s) are effectively empty (i.e. they contain no lines that are non-blank or
    non-commented)
.Parameter InputConfiguration
    HostsFileConfiguration object
.Notes:
    Source:     Rule 10b 'HOSTS file has entries'
.Outputs
    Param_Hosts(Compliant=$FALSE, all three fields) if the HostsFileConfiguration indicates non-empty,
        repeated for each non-compliant file.
    Param_Hosts(Compliant=$TRUE, no fields) otherwise, without repeats.

    Field0 = Short File name, e.g. "hosts.ics"
    Field1 = Full path, e.g. "c:\windows\system32\drivers\etc\hosts.ics"
    Field2 = First match (not full line) of problem content, e.g. "10.4.3.2    CORP-DC-1"

#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $TRUE;

    $HostsFileConfiguration = $InputConfiguration;

    foreach ( $file in $HostsFileConfiguration )
    {
        if ( $file['Empty'] -eq $FALSE )
        {
            Write-Debug "Param_Hosts: Non-compliant for file $($file['File'])";

            #  First time through, convert single hash to array of hashes
            if ( $ReturnBool )
            {
                $ReturnHash.Value = @();
            }

            $fileHash = New-RuleEvaluationHash -RuleName "Param_Hosts" -Compliant $FALSE;
            $fileHash['Field0'] = $file['File'];
            $fileHash['Field1'] = $file['FullPath'];
            $fileHash['Field2'] = $file['Contents'][0];

            $ReturnHash.Value += $fileHash;
            $ReturnBool = $FALSE;
        }
    }

    if ( $ReturnBool )
    {
        Write-Debug 'Param_Hosts: Fully Compliant';
        $ReturnHash.Value['Compliant'] = $TRUE;
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Param_TimeoutOffset  {
<#
.Synopsis
    Checks that recursion timeout is greater than or equal to the forwarding timeout, if recursion is enabled.
.Parameter InputConfiguration
    ServerConfiguration object
.Notes:
    Source:     Rule 10d 'Recursion and Forwarding timeouts should be offset'
    Reference:  http://technet.microsoft.com/en-us/library/cc951583.aspx
.Outputs
    Param_TimeoutOffset(Compliant=$FALSE) if the recursion timeout is less than or equal to the forwarding
        timeout
    Param_TimeoutOffset(Compliant=$TRUE) otherwise.

    Field0 = Effective forwarding timeout
    Field1 = Effective recursion timeout

    Nothing is returned if either recursion or forwarding are impossible due to missing
    root-hints/forwarders or disabling parameters set in the registry
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    #  This test only applies if both root hints and forwarders are configured
    if ( $InputConfiguration['RecursionPossible'] -eq $FALSE -or $InputConfiguration['ForwardingPossible'] -eq $FALSE )
    {
        Write-Debug 'Param_TimeoutOffset: Skipping this test since either recursion or forwarding is impossible';
        $ReturnHash.Value = $NULL;
        return $TRUE;
    }

    #  Defaults confirmed for 2008 R2
    $Default_ForwardingTimeout = 3;
    $Default_RecursionTimeout  = 8;

    $Registry_ForwardingTimeout = $InputConfiguration['Parameters']['ForwardingTimeout'];
    $Registry_RecursionTimeout  = $InputConfiguration['Parameters']['RecursionTimeout'];

    if ( $Registry_ForwardingTimeout -ne $NULL )
    {
        $Effective_ForwardingTimeout = $Registry_ForwardingTimeout;
    }
    else
    {
        $Effective_ForwardingTimeout = $Default_ForwardingTimeout;
    }

    if ( $Registry_RecursionTimeout -ne $NULL )
    {
        $Effective_RecursionTimeout = $Registry_RecursionTimeout;
    }
    else
    {
        $Effective_RecursionTimeout = $Default_RecursionTimeout;
    }

    write-debug "Param_TimeoutOffset: Effective_ForwardingTimeout = $Effective_ForwardingTimeout";
    Write-Debug "Param_TimeoutOffset: Effective_RecursionTimeout  = $Effective_RecursionTimeout";

    $ReturnHash.Value['Field0'] = $Effective_ForwardingTimeout;
    $ReturnHash.Value['Field1'] = $Effective_RecursionTimeout;

    if ( $Effective_RecursionTimeout -le $Effective_ForwardingTimeout )
    {
        Write-Debug 'Param_TimeoutOffset: Non-Compliant';
        return $TRUE;
    }
    else
    {
        Write-Debug 'Param_TimeoutOffset:     Compliant';
        $ReturnHash.Value['Compliant'] = $TRUE;
        return $TRUE;
    }
}

function Get-RuleEvaluation-Param_RootHints  {
<#
.Synopsis
    If forwarding is disabled or unavailable, but recursion is enabled, checks that recursion is possible
.Parameter InputConfiguration
    ServerConfiguration object
.Notes:
    Source:     Rule 9b "'Use Root Hints' not selected"
.Outputs
    Param_RootHints(Compliant=$FALSE) if NoRecursion and ForwardingEnabled are false/unset, and root hints are
        not configured
    Param_RootHints(Compliant=$TRUE)  if NoRecursion and ForwardingEnabled are false/unset, and root hints are
        configured
    Param_RootHints(Compliant=$FALSE) if NoRecursion is false/unset, ForwardingEnabled is true, and forwarders are
        not configured
    Param_RootHints(Compliant=$TRUE)  if NoRecursion is false/unset, ForwardingEnabled is true, and forwarders are
        configured

    Nothing if NoRecursion is true
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool   = $FALSE;
    $NoRecursion  = $InputConfiguration['Parameters']['NoRecursion'];

    if ( $NoRecursion -eq 1 )
    {
        Write-Debug 'Param_RootHints: All recursion/forwarding is disabled; skipping this rule.';
        return $TRUE;
    }

    $ForwardingEnabled      = $InputConfiguration['Parameters'][$FORWARDING_ENABLED_PARAMETER_NAME];
    $NumRootHints = 0;
    $NumForwarders = 0;

    if ( $InputConfiguration['RootHints'] -ne $NULL )
    {
        $NumRootHints = $InputConfiguration['RootHints'].Count;
    }

    if ( $InputConfiguration['Parameters']['Forwarders'] -ne $NULL )
    {
        $NumForwarders = $InputConfiguration['Parameters']['Forwarders'].Count;
    }

    if ( $ForwardingEnabled -eq 1 )
    {
        $ReturnBool = $( $NumForwarders -gt 0 );
        $ReturnHash.Value['Compliant'] = $ReturnBool;
        Write-Debug "Param_RootHints: ForwardingEnabled = TRUE; Compliance = Forwarders Configured = $ReturnBool";
    }
    else
    {
        $ReturnBool = $( $NumRootHints -gt 0 );
        $ReturnHash.Value['Compliant'] = $ReturnBool;
        Write-Debug "Param_RootHints: ForwardingEnabled = FALSE; Compliance = Root Hints Configured = $ReturnBool";
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Param_RegistrationEnabled  {
<#
.Synopsis
    Checks that the given interface has the RegistrationEnabled flag set to 1.
.Parameter InputConfiguration
    An Interface object
.Notes:
    Source:     Rule 3g
.Outputs
    Param_RegistrationEnabled(Compliant=$FALSE) if the RegistrationEnabled is not 1
    Param_RegistrationEnabled(Compliant=$TRUE) otherwise.

    Field0 = Interface friendly name
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $Interface = $InputConfiguration;
    $AdapterFriendlyName = $Interface['AdapterFriendlyName'];

    if ( $Interface['RegistrationEnabled'] -ne 1 )
    {
        Write-Debug "Param_RegistrationEnabled: Non-compliant: $AdapterFriendlyName";
        $ReturnHash.Value['Field0'] = $AdapterFriendlyName;
        $ReturnBool = $FALSE;
    }
    else
    {
        Write-Debug "Param_RegistrationEnabled:     Compliant: $AdapterFriendlyName";
        $ReturnBool = $TRUE;
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $AdapterFriendlyName;
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Param_ScavengingServer  {
<#
.Synopsis
    Verifies that the server scavenging parameters have scavenging enabled and the interval within
    an acceptable range.
.Parameter InputConfiguration
    ServerConfiguration object
.Notes
    Source:     Rules 7c1, 7c2
.Outputs
    Param_ScavengingServer_AgingDisabled(Compliant=$FALSE, Field0 = scavenging interval ) if the Scavenge
        interval is zero or null, indicating that scavenging is disabled.
    Param_ScavengingServer_IntervalRange(Compliant=$FALSE, Field0 = scavenging interval ) if the
        Scavenge interval is non-zero/non-null but the value is greater than 28 days or less than 6 hours.
    Param_ScavengingServer(Compliant=$TRUE) otherwise.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $Parameters = $InputConfiguration['Parameters'];
    $Maximum_ScavengingInterval = 24 * 28;  #  hours
    $Minimum_ScavengingInterval = 6;        #  hours

    #  If ScavengingInterval is not set or 0, then scavenging is disabled for the server.
    if ( $Parameters['ScavengingInterval'] -ne $NULL -and $Parameters['ScavengingInterval'] -ne 0 )
    {
        #  Check if the scavenging interval is out of range
        if ( ( $Parameters['ScavengingInterval'] -gt $Maximum_ScavengingInterval ) -or
             ( $Parameters['ScavengingInterval'] -lt $Minimum_ScavengingInterval ) )
        {
            $ReturnBool = $FALSE;
            $ReturnHash.Value['RuleName'] = 'Param_ScavengingServer_IntervalRange';
            $ReturnHash.Value['Compliant'] = $FALSE;
            $ReturnHash.Value['Field0'] = $Parameters['ScavengingInterval'];
            return $ReturnBool;
        }

        $ReturnHash.Value['RuleName'] = 'Param_ScavengingServer';
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $Parameters['ScavengingInterval'];
        return $ReturnBool;
    }
    else
    {
        #  Scavenging is disabled for this server, which is not recommended
        $ReturnBool = $FALSE;
        $ReturnHash.Value['RuleName'] = 'Param_ScavengingServer_AgingDisabled';
        $ReturnHash.Value['Compliant'] = $FALSE;
        return $ReturnBool;
    }
}

function Get-RuleEvaluation-Param_ScavengingZone  {
<#
.Synopsis
    Checks for the given zone that scavenging, if enabled, has recommended parameters.
.Parameter InputConfiguration
    ZoneConfigurationElement object
.Notes
    Source:     Rules 7b2, 7d2
    Reference:  http://technet.microsoft.com/en-us/library/cc960935.aspx
.Outputs
    Param_ScavengingZone_AgingDisabled(Compliant=$TRUE) if the aging parameter for the zone is 0 or not set.
    Param_ScavengingZone_NoScavengeServers(Compliant=$FALSE) if the 'ScavengeServers' key exists but is
        blank.
    Param_ScavengingZone_RefreshNonDefault(Compliant=$FALSE) if the no-refresh or refresh intervals are set
        and not at the default value of 168 hours (7 days)
    Param_ScavengingZone(Compliant=$TRUE) otherwise

    Field0 = Zone name
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $Zone = $InputConfiguration;
    $ZoneName = $Zone['Name'];
    $Default_RefreshInterval    = 24 * 7;   #  hours

    if ( $Zone['Aging'] -eq 1 )
    {
        #  Check if the list of ScavengeServers is blank
        if ( $Zone['ScavengeServers'] -ne $NULL -and $Zone['ScavengeServers'] -match "^\s*$" )
        {
            $ReturnBool = $FALSE;
            $ReturnHash.Value['RuleName'] = 'Param_ScavengingZone_NoScavengeServers';
            $ReturnHash.Value['Compliant'] = $FALSE;
            $ReturnHash.Value['Field0'] = $ZoneName;
            return $ReturnBool;
        }

        #  Check if the no-refresh+refresh intervals are non-default
        if ( ( $Zone['NoRefreshInterval'] -ne $NULL -and $Zone['NoRefreshInterval'] -ne $Default_RefreshInterval ) -or
             ( $Zone['RefreshInterval']   -ne $NULL -and $Zone['RefreshInterval']   -ne $Default_RefreshInterval ) )
        {
            $ReturnBool = $FALSE;
            $ReturnHash.Value['RuleName'] = 'Param_ScavengingZone_RefreshNonDefault';
            $ReturnHash.Value['Compliant'] = $FALSE;
            $ReturnHash.Value['Field0'] = $ZoneName;
            return $ReturnBool;
        }

        #  One of two compliant outcomes; aging is enabled and the parameters look good.
        $ReturnBool = $TRUE;
        $ReturnHash.Value['RuleName'] = 'Param_ScavengingZone';
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $ZoneName;
        return $ReturnBool;
    }
    else
    {
        #  One of two compliant outcomes; aging is disabled, hence the other checks are irrelevant.
        $ReturnBool = $TRUE;
        $ReturnHash.Value['RuleName'] = 'Param_ScavengingZone_AgingDisabled';
        $ReturnHash.Value['Compliant'] = $TRUE;
        $ReturnHash.Value['Field0'] = $ZoneName;
        return $ReturnBool;
    }
}

function Get-RuleEvaluation-Param_SocketPoolOff  {
<#
.Synopsis
        Checks that SocketPool fix hasn't been disabled or weakened below half of the default value and that the pool of
        available sockets (controlled by MaxUserPort) isn't too small (the DNS server would use more than half of them).
        The default value for the socket pool is 2500 ports.
.Parameter InputConfiguration
    ServerConfiguration object
.Notes
    Source:     Rule 10g 'SocketPool is set to OFF'
    Reference:  http://support.microsoft.com/kb/956188
.Outputs
    Param_SocketPoolOff(Compliant=$FALSE, Field0='SocketPoolSize') if SocketPoolSize < ( $Default / 2 )
    Param_SocketPoolOff(Compliant=$FALSE, Field0='MaxUserPort') if:
        MaxUserPort < ( 1024 + ( $Effective_SocketPoolSize * 2 ) )
    Param_SocketPoolOff(Compliant=$TRUE, Field0='SocketPoolSize') in all other cases

    Field1 = Effective socket pool size, if Field0='SocketPoolSize'; otherwise, value of MaxUserPort
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $Default_SocketPoolSize = 2500;

    $Registry_SocketPoolSize = $InputConfiguration['Parameters']['SocketPoolSize'];
    $Registry_MaxUserPort    = $InputConfiguration['Parameters']['MaxUserPort'];
    if ( $Registry_SocketPoolSize -ne $NULL -and
         $Registry_SocketPoolSize -lt $( $Default_SocketPoolSize / 2 ) )
    {
        # Non-Compliant
        Write-Debug "Param_SocketPoolOff: SocketPoolSize is non-compliant: $Registry_SocketPoolSize";
        $ReturnHash.Value['Field0'] = 'SocketPoolSize';
        $ReturnHash.Value['Field1'] = $Registry_SocketPoolSize;
        return $ReturnBool;
    }
    elseif ( $Registry_SocketPoolSize -ne $NULL )
    {
        $Effective_SocketPoolSize = $Registry_SocketPoolSize;
    }
    else
    {
        $Effective_SocketPoolSize = $Default_SocketPoolSize;
    }

    write-debug "Param_SocketPoolOff: Effective_SocketPoolSize=$Effective_SocketPoolSize";

    #  Check that the MaxUserPort setting, if enabled, is not overly constrained. That is, the size of the
    #  available socket pool is less than twice the size of the effective socket pool
    if ( $Registry_MaxUserPort -ne $NULL -and
         $Registry_MaxUserPort -lt $( 1024 + ( $Effective_SocketPoolSize * 2 ) ) )
    {
        # Non-Compliant
        Write-Debug 'Param_SocketPoolOff: Non-compliant MaxUserPort';
        $ReturnHash.Value['Field0'] = 'MaxUserPort';
        $ReturnHash.Value['Field1'] = $Registry_MaxUserPort;
        return $ReturnBool;
    }
    elseif ( $Registry_MaxUserPort -ne $NULL )
    {
        Write-Debug "Param_SocketPoolOff: MaxUserPort=$($Registry_MaxUserPort)";
    }
    Write-Debug 'Param_SocketPoolOff: Fully Compliant';

    $ReturnHash.Value['Compliant'] = $TRUE;
    $ReturnHash.Value['Field0'] = 'SocketPoolSize';
    $ReturnHash.Value['Field1'] = $Effective_SocketPoolSize;
    return $ReturnBool;
}

function Get-RuleEvaluation-Resolve_Forwarders  {
<#
.Synopsis
    Checks that forwarding servers, and root hints, if listed, respond to an 'NS' query for the root servers.
.Parameter InputConfiguration
    A server configuration object
.Notes
    Rule: 9e 'Configured machine is not a DNS server'
.Outputs
    Resolve_Forwarders(Compliant=$FALSE, Field0 = Forwarder IP) for each forwarder IP that does not respond.
    Resolve_Forwarders(Compliant=$TRUE, Field0 = Forwarder IP) for each forwarder IP that does respond.
    Resolve_Forwarders_AllFail(Compliant=$FALSE) if all forwarder IPs do not respond.
    Resolve_Forwarders_OnlyOne(Compliant=$FALSE) if there is only one forwarder IP.
    Resolve_Forwarders_Loopback(Compliant=$FALSE, Field0 = Forwarder IP) for each forwarder IP that is
        either a loopback address or is a local interface address.
    Resolve_Forwarders_Autoconfig(Compliant=$FALSE, Field0 = Forwarder IP) for each forwarder IP that is
        an autoconfigured or link-local address, and is not a local interface address.

    No Resolve_Forwarders evaluations arereturned if there are no forwarders configured.

    Resolve_RootHints(Compliant=$FALSE, Field0 = RootHint IP) for each Root hint that does not respond.
    Resolve_RootHints(Compliant=$TRUE, Field0 = RootHint IP) for each Root hint that does respond.
    Resolve_RootHints_AllFail(Compliant=$FALSE) if all Root hint do not respond.
    Resolve_RootHints_OnlyOne(Compliant=$FALSE, Field0 = RootHint IP) if there is only one Root hint.
    Resolve_RootHints_Loopback(Compliant=$FALSE, Field0 = RootHint IP) for each root hint that is
        either a loopback address or is a local interface address.
    Resolve_RootHints_Autoconfig(Compliant=$FALSE, Field0 = RootHint IP) for each Root hint that is
        an autoconfigured or link-local address, and is not a local interface address.

    No Resolve_RootHints evaluations arereturned if there are no RootHints configured.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $TRUE;

    #  We may return several results
    $ReturnHash.Value = @();

    $TestSetHash = @{
        'Forwarders' = $InputConfiguration['Parameters']['Forwarders'];
        'RootHints' = $InputConfiguration['RootHints'];
    };

    foreach ( $TestSet in $TestSetHash.Keys )
    {
        if ( $TestSetHash[$TestSet] -eq $NULL )
        {
            Write-Debug "Resolve_$($TestSet): No $TestSet configured; skipping tests.";
            continue;
        }

        if ( $TestSetHash[$TestSet].Count -eq 1 )
        {
            Write-Debug "Resolve_$($TestSet): Only one IP configured for $TestSet.";
            $tempHash = New-RuleEvaluationHash "Resolve_$($TestSet)_OnlyOne" -Compliant $FALSE -Field0 "$($TestSetHash[$TestSet])";
            $ReturnHash.Value += $tempHash;
        }

        #  These store a count of the address types tested/passing. This allows us to tell if all of the addresses failed.
        $NumTests = 0;
        $NumPassingTests = 0;

        #  Query all the peers.
        foreach ( $DNSServer in $TestSetHash[$TestSet] )
        {
            #  Check for loopback or autoconfigured/link-local addresses and issue evaluations.
            if ( $( Check-Loopback $DNSServer ) -eq $TRUE )
            {
                Write-Debug "Resolve_$($TestSet)_Loopback:     Non-compliant: $DNSServer";
                $tempHash = New-RuleEvaluationHash "Resolve_$($TestSet)_Loopback" -Compliant $FALSE -Field0 $DNSServer;
                $ReturnHash.Value += $tempHash;
                $ReturnBool = $FALSE;
            }
            elseif ( $( Check-AutoConfig $DNSServer ) -eq $TRUE )
            {
                Write-Debug "Resolve_$($TestSet)_Autoconfig:     Non-compliant: $DNSServer";
                $tempHash = New-RuleEvaluationHash "Resolve_$($TestSet)_Autoconfig" -Compliant $FALSE -Field0 $DNSServer;
                $ReturnHash.Value += $tempHash;
                $ReturnBool = $FALSE;
            }

            #  Check if the DNSServer can resolve the root hints
            $NumTests++;
            $result = Resolve-Query -RecordType 'NS' -IPAddress $DNSServer -Query '.';

            #  If the query succeeded
            if ( $result -eq 0 )
            {
                Write-Debug "Resolve_$($TestSet):     Compliant: $DNSServer";
                $tempHash = New-RuleEvaluationHash "Resolve_$TestSet" -Compliant $TRUE -Field0 $DNSServer;
                $ReturnHash.Value += $tempHash;
                $NumPassingTests++;
            }
            #  The query failed
            else
            {
                Write-Debug "Resolve_$($TestSet): Non-Compliant: $DNSServer (Code $result)";
                $tempHash = New-RuleEvaluationHash "Resolve_$TestSet" -Field0 $DNSServer;
                $ReturnHash.Value += $tempHash;
                $ReturnBool = $FALSE;
            }
        }

        #  Check if all the IPs are down. Issue an error if so.
        if ( $NumPassingTests -eq 0 -and
             $NumTests        -gt 0 )
        {
            Write-Debug "Resolve_$($TestSet)_AllFail: Non-Compliant";
            $tempHash = New-RuleEvaluationHash "Resolve_$($TestSet)_AllFail";
            $ReturnHash.Value += $tempHash;
        }
    }
    return $ReturnBool;
}

function Get-RuleEvaluation-Resolve_Peers  {
<#
.Synopsis
    Checks that references to peer servers in lists of Master, Secondary and Notify servers in the zone
    configuration point to DNS servers that host the given zone.

    This rule collects all the master/secondary and notify servers, and issues a query for the zone for each
    unique server IP. If an IP address appears on more than one list, only one error will be issued (order
    of preference: MasterServers, SecondaryServers, NotifyServers, ScavengeServers). The Missing variants are
    triggered when the server is configured to read from a list (e.g. transfer only to servers on this list,
    notify servers on list...) but the list is empty or non-existent.
.Parameter InputConfiguration
    A single zone configuration object
.Notes
    Subrules: Resolve_Peers_MasterServers                Resolve_Peers_NotifyServers
              Resolve_Peers_MissingMasterServers         Resolve_Peers_ScavengeServers
              Resolve_Peers_MissingNotifyServers         Resolve_Peers_SecondaryServers
              Resolve_Peers_MissingSecondaryServers
.Outputs

    Resolve_Peers_MissingMasterServers(Compliant=$FALSE) if the zone is non-DS-integrated secondary, stub or
        forwarder and the MasterServers list is missing or empty.

    Resolve_Peers_MissingSecondaryServers(Compliant=$FALSE) if the zone is Primary and the zone transfer
        policy is set to 'list'(2) and the SecondaryServers list is missing or empty.

    Resolve_Peers_MissingNotifyServers(Compliant=$FALSE) if the zone is Primary and the zone notification
        policy is set to 'list'(2) and the zone transfer policy is not 'off'(3) and the NotifyServers list
        is missing or empty.

    Resolve_Peers_MasterServers(Compliant=$FALSE, Field1 = IP address) for each master server IP that fails
        the DNS query.

    Resolve_Peers_MasterServers(Compliant=$TRUE, Field1 = IP address) for each master server IP that passes
        the DNS query.

    Resolve_Peers_SecondaryServers(Compliant=$FALSE, Field1 = IP address) for each secondary server IP that
        fails the DNS query.

    Resolve_Peers_SecondaryServers(Compliant=$TRUE, Field1 = IP address) for each secondary server IP that
        passes the DNS query.

    Resolve_Peers_NotifyServers(Compliant=$FALSE, Field1 = IP address) for each secondary server IP that was
        not in the master or secondary list that fails the DNS query.

    Resolve_Peers_NotifyServers(Compliant=$TRUE, Field1 = IP address) for each secondary server IP that was
        not in the master or secondary list that passes the DNS query.

    Resolve_Peers_ScavengeServers(Compliant=$FALSE, Field1 = IP address) for each secondary server IP that
        was not in the master, secondary, or scavengers list that fails the DNS query.

    Resolve_Peers_ScavengeServers(Compliant=$TRUE, Field1 = IP address) for each secondary server IP that
        was not in the master, secondary, or scavengers list that passes the DNS query.

    Field0 = Zone name
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $ZoneName = $InputConfiguration['Name'];
    $ZoneType = $InputConfiguration['Type'];
    $ZoneNotifyLevel = $InputConfiguration['NotifyLevel'];
    $ZoneTransferLevel = $InputConfiguration['SecureSecondaries'];

    Write-Debug "Resolve_Peers: Checking $ZoneName";
    # This is a hash of IPaddress->AddressSource.
    # Obviously some addresses may come from more than one source, and so the hash for a certain address may be
    # written several times. The order in which the sources is checked is set up so that the most important
    # sources are at the bottom of the list, so that if there is a problem contacting that address, the user
    # will receive only one error about it, and only the gravest error.
    $PeersToQuery = @{};

    #  We may return several results
    $ReturnHash.Value = @();
    #  Check for a scavenge servers list if scavenging (aging) is enabled
    if ( $InputConfiguration['Aging'] -eq 1 -and $InputConfiguration['ScavengeServers'] -ne $NULL )
    {
        foreach ( $Address in $InputConfiguration['ScavengeServers'].Split(',') )
        {
            #  The regular expression serves to remove any whitespace on the address, so that it will match addresses
            #  from other sources
            if ( $Address -ne $NULL -and $Address -match "^\s*(?<addr>\S.*?)\s*$" )
            {
                Write-Debug "Resolve_Peers_ScavengeServers: Adding $($matches['addr'])"
                $PeersToQuery[$matches['addr']] = 'ScavengeServers';
            }
        }
    }

    #  Check if there should be a NotifyServers list
    #  Note: other zone types besides Primary can have NotifyLevel set to list, but they don't need the list
    if ( $ZoneType -eq $ZONE_TYPE['Primary'] -and $ZoneTransferLevel -ne $ZONE_XFR['Off'] )
    {
        if ( $ZoneNotifyLevel -eq $ZONE_NOTIFY['List'] )
        {
            #  If the NotifyServers list is missing
            if ( $InputConfiguration['NotifyServers'] -eq $NULL -or $InputConfiguration['NotifyServers'].Length -eq 0 )
            {
                Write-Debug "Resolve_Peers_MissingNotifyServers: $ZoneName is non-compliant";
                $ReturnHash.Value += New-RuleEvaluationHash -RuleName 'Resolve_Peers_MissingNotifyServers' -Field0 $ZoneName;
            }
            else    #  Add servers from the notify list to the peer query list
            {
                foreach ( $Address in $InputConfiguration['NotifyServers'] )
                {
                    if ( $Address -ne $NULL )
                    {
                        $PeersToQuery[$Address] = 'NotifyServers';
                    }
                }
            }
        }
        #  Add the nameserver addresses for this zone if notifications are sent to them.
        elseif ( $ZoneNotifyLevel -eq $ZONE_NOTIFY['NS'] )
        {
            foreach ( $Address in $InputConfiguration['NameServerAddresses'] )
            {
                if ( $Address -ne $NULL )
                {
                    $PeersToQuery[$Address] = 'NotifyServers';
                }
            }
        }
    }

    #  Check if there should be a SecondaryServers list
    #  Note: other zone types besides Primary can have SecureSecondaries set to list, but they don't need the list
    if ( $ZoneType -eq $ZONE_TYPE['Primary'] )
    {
        if ( $ZoneTransferLevel -eq $ZONE_XFR['List'] )
        {
            #  If the SecondaryServers list is missing
            if ( $InputConfiguration['SecondaryServers']  -eq $NULL -or
                 $InputConfiguration['SecondaryServers'].Length -eq 0 )
            {
                Write-Debug "Resolve_Peers_MissingSecondaryServers: $ZoneName is non-compliant";
                $ReturnHash.Value += New-RuleEvaluationHash -RuleName 'Resolve_Peers_MissingSecondaryServers' -Field0 $ZoneName;
            }
            else    #  Add servers from the Secondary list to the peer query list
            {
                foreach ( $Address in $InputConfiguration['SecondaryServers'] )
                {
                    if ( $Address -ne $NULL )
                    {
                        $PeersToQuery[$Address] = 'SecondaryServers';
                    }
                }
            }
        }
        #  Add the nameserver addresses for this zone if transfers are allowed to them.
        elseif ( $ZoneTransferLevel -eq $ZONE_XFR['NS'] )
        {
            foreach ( $Address in $InputConfiguration['NameServerAddresses'] )
            {
                if ( $Address -ne $NULL )
                {
                    $PeersToQuery[$Address] = 'SecondaryServers';
                }
            }
        }
    }

    #  Check if there should be a MasterServers list
    if ( $ZoneType -eq $ZONE_TYPE['Secondary'] -or
           $ZoneType -eq $ZONE_TYPE['Stub'] -or
           $ZoneType -eq $ZONE_TYPE['Forwarder'] )
    {
        #  If the MasterServers list is missing (applies only to non-AD-integrated zones)
        if ( (  $InputConfiguration['MasterServers'] -eq $NULL -or
                $InputConfiguration['MasterServers'].Length -eq 0 ) -and
                $InputConfiguration['DSIntegrated'] -ne 1 )
        {
            Write-Debug "Resolve_Peers_MissingMasterServers: $ZoneName is non-compliant";
            $ReturnHash.Value += New-RuleEvaluationHash -RuleName 'Resolve_Peers_MissingMasterServers' -Field0 $ZoneName;
        }
        #  Add servers from the master servers list to the peer query list
        elseif ( $InputConfiguration['MasterServers'] -ne $NULL )
        {
            foreach ( $Address in $InputConfiguration['MasterServers'] )
            {
                if ( $Address -ne $NULL )
                {
                    $PeersToQuery[$Address] = 'MasterServers';
                }
            }
        }

        #  If there is a LocalMasterServers list, we should add that too
        #  Note: I wasn't able to get this registry key to show up on a DC running Server 2008R2
        #  This key should not be present unless the zone is DSIntegrated
        if ( $InputConfiguration['LocalMasterServers'] -ne $NULL )
        {
            foreach ( $Address in $InputConfiguration['LocalMasterServers'] )
            {
                if ( $Address -ne $NULL )
                {
                    $PeersToQuery[$Address] = 'MasterServers';
                }
            }
        }
    }

    #  These store a count of the address types tested (e.g. 'MasterServers' -> 3). This allows us to tell if
    #  all of the addresses of a certain type have failed
    $NumTestsOfAddressType = @{ 'MasterServers' = 0; 'SecondaryServers' = 0; };
    $NumPassingTestsOfAddressType = @{ 'MasterServers' = 0; 'SecondaryServers' = 0; };

    #  Query all the peers. Note that there is no possibility of duplicate queries because the list is in a
    #  hash
    foreach ( $Peer in $PeersToQuery.Keys )
    {
        $NumTestsOfAddressType[$PeersToQuery[$Peer]]++;
        #  Test whether the query resolves, and store the results
        $result = Resolve-Query -RecordType 'SOA' -IPAddress $Peer -Query $ZoneName;

        #  If the query succeeded
        if ( $result -eq 0 )
        {
            Write-Debug "Resolve_Peers_$($PeersToQuery[$Peer]):     Compliant: $Peer";
            $tempHash = New-RuleEvaluationHash "Resolve_Peers_$($PeersToQuery[$Peer])" -Compliant $TRUE -Field0 $ZoneName -Field1 $Peer;
            $ReturnHash.Value += $tempHash;
            $NumPassingTestsOfAddressType[$PeersToQuery[$Peer]]++;
        }
        #  The query failed
        else
        {
            Write-Debug "Resolve_Peers_$($PeersToQuery[$Peer]): Non-Compliant: $Peer (Code $result)";
            $tempHash = New-RuleEvaluationHash "Resolve_Peers_$($PeersToQuery[$Peer])" -Field0 $ZoneName -Field1 $Peer;
            $ReturnHash.Value += $tempHash;
        }
    }

    #  Check if all masters or all secondaries are down and issue errors. Note that a zone should not have
    #  both masters and secondaries
    foreach ( $Type in @( 'MasterServers', 'SecondaryServers' ) )
    {
        #  There were some addresses of $Type tested, but none of them passed
        if ( $NumPassingTestsOfAddressType[$Type] -eq 0 -and
             $NumTestsOfAddressType[$Type]        -gt 0 )
        {
            Write-Debug "Resolve_Peers_All$($Type)Fail: Non-Compliant: $ZoneName";
            $tempHash = New-RuleEvaluationHash "Resolve_Peers_All$($Type)Fail" -Field0 $ZoneName;
            $ReturnHash.Value += $tempHash;
        }
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Resolve_Status  {
<#
.Synopsis
    DC-Only: Checks that the DC records (the local machine's records) can be properly queried
.Parameter InputConfiguration
    Hash of ['ServerConfiguration']->ServerConfiguration object, ['IPAddress']->DNS Server Address,
    ['Interface']->Interface Object
.Outputs
    Resolve_Status_DNSSuffix(Compliant=$TRUE) if the SOA query for '<DomainDNSZone>' succeeded.

    Resolve_Status_DNSSuffix(Compliant=$FALSE) otherwise.

    Resolve_Status_DNSForest(Compliant=$TRUE) if the SOA query for '<ForestDNSZone>' succeeded.

    Resolve_Status_DNSForest(Compliant=$FALSE) otherwise.

    Resolve_Status_DNS_LDAP(Compliant=$TRUE) if the SRV query for '_ldap._tcp.<DomainDNSZone>' succeeded.

    Resolve_Status_DNS_LDAP(Compliant=$FALSE) otherwise.

    Resolve_Status_DNS_PDC(Compliant=$TRUE) if the SRV query for '_ldap._tcp.pdc._msdcs.<DomainDNSZone>'
        succeeded.

    Resolve_Status_DNS_PDC(Compliant=$FALSE) otherwise.

    Resolve_Status_DNS_GC(Compliant=$TRUE) if the SRV query for '_ldap._tcp.gc._msdcs.<ForestDNSZone>' succeeded.

    Resolve_Status_DNS_GC(Compliant=$FALSE) otherwise.

    Resolve_Status_DNS_KDC(Compliant=$TRUE) if the SRV query for '_kerberos._tcp.<DomainDNSZone>' succeeded.

    Resolve_Status_DNS_KDC(Compliant=$FALSE) otherwise.

    Resolve_Status_DNS_HOST_A(Compliant=$TRUE) if the A query for '<Hostname>' succeeded, and the local
        machine has an interface bound to an IPv4 address.

    Resolve_Status_DNS_HOST_A(Compliant=$FALSE) if the A query for '<Hostname>' failed, and the local machine
        has an interface bound to an IPv4 address.

    Resolve_Status_DNS_HOST_AAAA(Compliant=$TRUE) if the AAAA query for '<Hostname>' succeeded, and the local
        machine has an interface bound to an IPv6 address.

    Resolve_Status_DNS_HOST_AAAA(Compliant=$FALSE) if the AAAA query for '<Hostname>' failed, and the local
        machine has an interface bound to an IPv6 address.

    Field0 = IP address.
    Field1 = Interface friendly name.
#>
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    $Domain               = $InputConfiguration['ServerConfiguration']['DomainInfo']['DomainName'];
    $Forest               = $InputConfiguration['ServerConfiguration']['DomainInfo']['ForestName'];
    $MachineName          = $InputConfiguration['ServerConfiguration']['Hostname'];
    $DNSIPAddress         = $InputConfiguration['IPAddress'].DNSAddress;
    $Interface            = $InputConfiguration['Interface'];
    $AdapterFriendlyName  = $Interface.AdapterFriendlyName;
    $CompliantDebugString = "";

    #  We will be returning one result per query in the $QueriesArrayOfHashes
    $ReturnHash.Value = @();
    $QueriesArrayOfHashes =
        @(
            @{  RecordType = 'SOA';     QueryString = $Domain;                             QueryName = 'DNSSuffix';     },
            @{  RecordType = 'SOA';     QueryString = $Forest;                             QueryName = 'DNSForest';     },
            @{  RecordType = 'SRV';     QueryString = '_ldap._tcp.' + $Domain;             QueryName = 'DNS_LDAP';      },
            @{  RecordType = 'SRV';     QueryString = '_ldap._tcp.pdc._msdcs.' + $Domain;  QueryName = 'DNS_PDC';       },
            @{  RecordType = 'SRV';     QueryString = '_ldap._tcp.gc._msdcs.' + $Forest;   QueryName = 'DNS_GC';        },
            @{  RecordType = 'SRV';     QueryString = '_kerberos._tcp.' + $Domain;         QueryName = 'DNS_KDC';       },
            @{  RecordType = 'A';       QueryString = $MachineName;                        QueryName = 'DNS_HOST_A';    },
            @{  RecordType = 'AAAA';    QueryString = $MachineName;                        QueryName = 'DNS_HOST_AAAA'; }
        );

    foreach ( $qry in $QueriesArrayOfHashes )
    {

        #  This is primarily meant to skip DNS_HOST_AAAA in environments lacking IPv6, but it could also skip
        #  DNS_HOST_A in environments lacking IPv4
        if ( $qry['QueryName'] -eq 'DNS_HOST_A' -and
            ( -not $( Check-InterfaceHasAddressFamily -Family 'InterNetwork'   -Interface $Interface ) ) )
        {
            continue;
        }
        elseif ( $qry['QueryName'] -eq 'DNS_HOST_AAAA' -and
            ( -not $( Check-InterfaceHasAddressFamily -Family 'InterNetworkV6' -Interface $Interface ) ) )
        {
            continue;
        }

        #  Test whether the query resolves, and store the results
        $result = Resolve-Query -RecordType $qry['RecordType'] -IPAddress $DNSIPAddress -Query $qry['QueryString'];
        $qry['IPAddress'] = $DNSIPAddress;
        $qry['Result'] = $result;

        #  If the query succeeded
        if ( $result -eq 0 )
        {
            $CompliantDebugString += "$($qry['QueryName']) ";
            $tempHash = New-RuleEvaluationHash "Resolve_Status_$($qry['QueryName'])" -Compliant $TRUE -Field0 $DNSIPAddress -Field1 $AdapterFriendlyName -Field2 $qry['QueryString'];
            $ReturnHash.Value += $tempHash;
        }
        #  The query failed
        else
        {
            Write-Debug "Resolve_Status: $DNSIPAddress Non-Compliant: $($qry['QueryName'])";
            $tempHash = New-RuleEvaluationHash "Resolve_Status_$($qry['QueryName'])" -Field0 $DNSIPAddress -Field1 $AdapterFriendlyName -Field2 $qry['QueryString'];
            $ReturnHash.Value += $tempHash;

            #  Write the full query and its results to debug
            $debugString = "Resolve_Status: Query:`n`t"; 
            foreach ( $qryKey in $qry.Keys )
            {
                $debugString += $qryKey + ': ' + $qry[$qryKey] + "`n`t"; 
            }
            Write-Debug $debugString;
        }
    }

    if ( $CompliantDebugString.Length -gt 0 )
    {
        Write-Debug "Resolve_Status: $DNSIPAddress     Compliant: $CompliantDebugString";
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Resolve_Mismatch  {
<#
.Synopsis
    DNS-Only: Checks that the forest domain is either present on all the DNS servers, or present
    on none of the DNS servers
.Parameter InputConfiguration
    Full Configuration object
.Outputs
    Resolve_Mismatch(Compliant=$TRUE) if the SOA queries for '<ForestDNSZone>' are consistent.
    Resolve_Mismatch(Compliant=$FALSE, Field0 = DNS Server 1, Field1 = DNS Server 2) otherwise.

    No evaluation is emitted if the machine is apparently not domain-joined.
#>
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    if ( $InputConfiguration['ServerConfiguration']['DomainInfo'] -eq $NULL )
    {
        Write-Debug 'Resolve_Mismatch: Skipping this test, since this machine is not domain-joined';
        $ReturnHash.Value = $NULL;
        return $TRUE;
    }

    write-debug 'Resolve_Mismatch: Performing DNS Resolution Tests';
    $Forest              = $InputConfiguration['ServerConfiguration']['DomainInfo']['ForestName'];
    $Interfaces          = $InputConfiguration['InterfaceConfiguration']['Interfaces'];

    write-debug "Resolve_Mismatch: Forest: $Forest";

    $DNSServersHash = @{};

    #  Collect the DNS servers from all of the interfaces, suppressing duplicates
    foreach ( $Interface in $Interfaces )
    {
        foreach ( $DNSServer in $Interface.DNSServerList )
        {
            ++$DNSServersHash[$DNSServer.DNSAddress];
        }
    }

    $PreviousResult = $NULL;
    $PreviousServer = $NULL;

    foreach ( $DNSServer in $DNSServersHash.Keys )
    {
        #  Test whether the query resolves
        $result = Resolve-Query -RecordType 'SOA' -IPAddress $DNSServer -Query "$Forest";
        Write-Debug "Resolve_Mismatch: $DNSServer --> $result";

        #  Skip timeouts; they receive the benefit of the doubt.
        if ( $result -eq 1460 )
        {
            Write-Debug 'Resolve_Mismatch: Ignoring timed-out server';
            continue;
        }

        if ( $PreviousResult -ne $result )
        {
            #  If we haven't stored a previous result yet, store one
            if ( $PreviousResult -eq $NULL )
            {
                $PreviousResult = $result;
                $PreviousServer = $DNSServer;
            }
            else
            {
                Write-Debug 'Resolve_Mismatch: Non-Compliant';
                $ReturnHash.Value['Field0'] = $DNSServer;
                $ReturnHash.Value['Field1'] = $PreviousServer;
                return $FALSE;
            }
        }
    }

    write-debug 'Resolve_Mismatch:     Compliant';
    $ReturnHash.Value['Compliant'] = $TRUE;
    return $TRUE;
}

function Get-RuleEvaluation-Zone_Status_AD  {
<#
.Synopsis
    DC-Only: Checks that AD zones (_msdcs.<ForestDNSZone>, <DomainDNSZone>) are running and in good order.
.Parameter InputConfiguration
    The Configuration object (Output of Get-Configuration)
.Outputs
    Zone_Status_AD_NotPresent(Compliant=$FALSE) if the zone is not present
    Zone_Status_AD_NotRunning(Compliant=$FALSE) if the zone is present, but is shutdown or paused
    Zone_Status_AD_NotPrimary(Compliant=$FALSE) if the zone is present, but is not primary
    Zone_Status_AD(Compliant=$TRUE) if the zone is present, primary, and running

    Field0 = zone name
#>
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $ReturnBool = $FALSE;

    write-debug 'Zone_Status_AD: Performing DNS Resolution Tests';
    $Domain              = $InputConfiguration['ServerConfiguration']['DomainInfo']['DomainName'];
    $Forest              = $InputConfiguration['ServerConfiguration']['DomainInfo']['ForestName'];
    $MachineName         = $InputConfiguration['ServerConfiguration']['Hostname'];
    $ZonesArray          = $InputConfiguration['ZonesConfiguration'];
    Write-Debug "Zone_Status_AD: Domain: $Domain Forest: $Forest";
    Write-Debug "Zone_Status_AD: MachineName: $MachineName";

    #  We will be return multiple results;
    $ReturnHash.Value = @();

    #  Array of zone names to check for each test; Using an ArrayList so that items can be deleted
    $ZoneTestNamesArray = New-Object System.Collections.ArrayList;
    $ZoneTestNamesArray.Add( "_msdcs.$Forest" );
    $ZoneTestNamesArray.Add( "$Domain" );

    #  Array of zone information; This will contain just the info for any test zones found;
    $ZonesToTestArray = @();

    #  Check for the zones being present
    #  Devnote: This is an O(n) search of the zone configuration array. For servers with thousands of zones, this might
    #  be slow. The $ZonesToTestArray is built so that there is no more searching and so that no indices have to be
    #  remembered.
    foreach ( $Zone in $ZonesArray )
    {
        foreach ( $ZoneTestName in $ZoneTestNamesArray.ToArray() )
        {
            if ( $Zone['Name'] -eq $ZoneTestName )
            {
                #  Remove the ZoneTestName from the list, since it has been found.
                $ZoneTestNamesArray.Remove( $ZoneTestName );

                #  Add the zone to the array of zones to test
                $ZonesToTestArray += @( $Zone );
            }
        }

        #  Exit early if all the ZoneTestNames have been found
        if ( $ZoneTestNamesArray.Count -eq 0 )
        {
            break;
        }
    }

    #  Any names left in the $ZoneTestNamesArray were not found, and hence are not present on the server
    foreach ( $ZoneTestName in $ZoneTestNamesArray )
    {
        Write-Debug "Zone_Status_AD: Non-Compliant: $ZoneTestName doesn't exist.";
        $tempHash = New-RuleEvaluationHash 'Zone_Status_AD_NotPresent' -Field0 $ZoneTestName;
        $ReturnHash.Value += $tempHash;
    }

    #  Check the zone type and status information
    foreach ( $Zone in $ZonesToTestArray )
    {
        $AllPassed = $TRUE;

        if ( $Zone['Shutdown'] -eq 1 -or $Zone['Paused'] -eq 1 )
        {
            Write-Debug "Zone_Status_AD: Non-Compliant: $($Zone['Name']) is shutdown/paused";
            $tempHash = New-RuleEvaluationHash 'Zone_Status_AD_NotRunning' -Field0 $Zone['Name'];
            $ReturnHash.Value += $tempHash;
            $AllPassed = $FALSE;
        }

        if ( $Zone['Type'] -ne $ZONE_TYPE['Primary'] )
        {
            Write-Debug "Zone_Status_AD: Non-Compliant: $($Zone['Name']) is not type primary";
            $tempHash = New-RuleEvaluationHash 'Zone_Status_AD_NotPrimary' -Field0 $Zone['Name'];
            $ReturnHash.Value += $tempHash;
            $AllPassed = $FALSE;
        }

        if ( $AllPassed -eq $TRUE )
        {
            Write-Debug "Zone_Status_AD:     Compliant: $($Zone['Name']) is present, running, and of primary type";
            $tempHash = New-RuleEvaluationHash 'Zone_Status_AD' -Compliant $TRUE -Field0 $Zone['Name'];
            $ReturnHash.Value += $tempHash;
            $AllPassed = $FALSE;
        }
    }

    return $ReturnBool;
}

function Get-RuleEvaluation-Zone_Status_XFR  {
<#
.Synopsis
    Checks that stub or secondary zones have successfully transferred from their masters.
.Parameter InputConfiguration
    A single zone configuration
.Notes
    If there was an error reading the LastTransferResult, its value will be NULL, which will result in no output.
.Outputs

    Zone_Status_XFR(Compliant=$FALSE) if the LastTransferResult is not NULL, 0 or -1 (XFR in progress).

    Zone_Status_XFR(Compliant=$TRUE) if the LastTransferResult is 0 or -1

    Nothing if the LastTransferResult is NULL.

    Field0 = zone name
    Field1 = Last transfer result
#>
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [ref] $ReturnHash
)

    $Zone = $InputConfiguration;
    $ReturnHash.Value['Field0'] = $Zone['Name'];
    $ReturnHash.Value['Field1'] = $Zone['LastTransferResult'];

    if ( $Zone['LastTransferResult'] -eq $NULL )
    {
        Write-Debug "Zone_Status_XFR: $($Zone['Name']): No transfer result found; Skipping this test.";
        $ReturnHash.Value = $NULL;
        return $TRUE;
    }
    elseif ( $Zone['LastTransferResult'] -eq -1 -or $Zone['LastTransferResult'] -eq 0 )
    {
        Write-Debug "Zone_Status_XFR: $($Zone['Name']): Transfer result ($($Zone['LastTransferResult'])) is     compliant";
        $ReturnHash.Value['Compliant'] = $TRUE;
        return $TRUE;
    }
    else
    {
        Write-Debug "Zone_Status_XFR: $($Zone['Name']): Transfer result ($($Zone['LastTransferResult'])) is non-compliant";
        return $FALSE;
    }
}

function Get-RuleEvaluation {
<#
.Synopsis
    Calls a more specific rule evaluation function and gives results. This function will selectively-invoke a rule
    only if the scenario for the rule (ex: DC-Only) matches the present scenario.
.Parameter RuleName
    The name of the rule to be invoked. Must match exactly.
.Parameter $InputConfiguration
    Configuration information required for the rule. The type of this input depends on which rule is being invoked.
.Parameter $Evaluation
    (Optional) Reference that will be returned with the evaluation object. If the object passed already contains one or
    more evaluations, the new evaluations will be appended.
.Notes
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [String] $RuleName,
    [parameter(Mandatory=$TRUE)]
    $InputConfiguration,
    [parameter(Mandatory=$FALSE)]
    [AllowNull()]
    [Ref]$Evaluation
    )

    $ReturnHash = New-RuleEvaluationHash -RuleName $RuleName

    #  This debug statement and the matching one below are too chatty. Disabled unless needed.
    #  Write-Debug "Get-RuleEvaluation: +$RuleName Evaluation -ne NULL = $($Evaluation -ne $NULL); ReturnHash -ne NULL = $($ReturnHash -ne $NULL) )";
    $ReturnBool = $FALSE;   #  This is $TRUE if the specified test completely passed; $FALSE in all other cases.

    $DC_ONLY = 2;   #  Rule applies only if the machine is a DC
    $DNS_ONLY = 1;  #  Rule applies only if the machine is not a DC
    $BOTH = $NULL;  #  Rule applies in both cases

    $RuleExemptionsHash = @{
            'DNSLoopback'         = $DC_ONLY;
            'DNSServerConfigured' = $DC_ONLY;
            'Resolve_Mismatch'    = $DNS_ONLY;
            'Resolve_Status'      = $DC_ONLY;
            'Zone_Status_AD'      = $DC_ONLY;
    }

    $DCStatus = Get-IsDomainController;

    #  Check if the rule applies to this scenario and skip if it does not
    if ( $( get-variable TEST_IGNORE_DC_CHECKS -ErrorAction 'SilentlyContinue' ) -eq $NULL )
    {
        if ( $DCStatus -and $RuleExemptionsHash[$RuleName] -eq $DNS_ONLY )
        {
            Write-Debug "Get-RuleEvaluation: Skipping $RuleName because this rule does not apply to DCs."
            return $TRUE;
        }
        elseif( $DCStatus -eq $FALSE -and $RuleExemptionsHash[$RuleName] -eq $DC_ONLY )
        {
            Write-Debug "Get-RuleEvaluation: Skipping $RuleName because this rule applies only to DCs."
            return $TRUE;
        }
    }

    $ReturnBool = Invoke-Expression "Get-RuleEvaluation-$RuleName -InputConfiguration `$InputConfiguration -ReturnHash ([ref]`$ReturnHash)";  

    # Write-Debug "Get-RuleEvaluation: -$RuleName Evaluation -ne NULL = $($Evaluation -ne $NULL); ReturnHash -ne NULL = $($ReturnHash -ne $NULL) )";
    if ( $Evaluation -ne $NULL -and $ReturnHash -ne $NULL )
    {
        #  ReturnHash may be an array if multiple results are returned from a particular rule. Process each one.
        foreach( $hash in $ReturnHash )
        {
            #  MBCA has a bug that causes certain characters to crash the engine. This is because the text of a field is
            #  passed to String.Format, and any characters that can be interpreted as a format string can cause an error.
            #  Convert the input to a string and replace '{' and '}' with alternatives.

            foreach ( $field in @( 'Field0', 'Field1', 'Field2' ) )
            {
                if ( $hash[$field] -ne $NULL )
                {
                    $hash[$field] = $hash[$field].ToString().replace('{','(').replace('}',')');
                }
            }
        }

        $Evaluation.Value += $ReturnHash;
    }

    return $ReturnBool;
}

function Get-Configuration {
<#
.Synopsis
    Calls all of the other Get-*Configuration functions.
.Outputs
    A hashtable
#>
[CmdletBinding()]
PARAM( )

    $resultsHash = @{};

    write-debug 'Getting InterfaceConfiguration';
    $resultsHash['InterfaceConfiguration'] = Get-InterfaceConfiguration;

    write-debug 'Getting ServerConfiguration';
    $resultsHash['ServerConfiguration'] = Get-ServerConfiguration $resultsHash['InterfaceConfiguration'];

    write-debug 'Getting HostsFileConfiguration';
    $resultsHash['HostsFileConfiguration'] = Get-HostsFileConfiguration;

    write-debug 'Getting ZonesConfiguration';
    $resultsHash['ZonesConfiguration'] = Get-ZonesConfiguration;

    return $resultsHash;
}

function Get-HostsFileConfiguration {
<#
.Synopsis
   Gets the status of the hosts files (hosts, hosts.ics and lmhosts); determines if they have potentially
   active lines
.Notes
    Return values:
       Returns an array of hashes hash with keys 'Empty', 'File', and 'FullPath', and possibly a key
       'Contents' containing non-commented text from the files.

       If key 'Empty' is $TRUE, then there are no potentially active lines in the host file given by
       'File'.
#>
[CmdletBinding()]
PARAM( )

    $returnArray = @();

    #  minio\dns\dnsapi\hostfile.c specifies that the hosts file registry key is ignored
    #  minio\netbt\sys\nt\registry.c does not ignore the
    #  HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\DataBasePath key, but we will ignore this detail.
    $hostsFiles = @(
        $( $(get-childitem -path env:SystemRoot).Value + "\system32\drivers\etc\hosts" ),
        $( $(get-childitem -path env:SystemRoot).Value + "\system32\drivers\etc\hosts.ics" )
        $( $(get-childitem -path env:SystemRoot).Value + "\system32\drivers\etc\lmhosts" )
    );

    foreach ( $file in $hostsFiles )
    {
        #  Get just the filename; relies on the greedy property of the * regex operator
        $shortFile = $file -replace ".*\\","";

        $fileHash = @{ 'Empty' = $TRUE; 'File' = $shortFile; 'FullPath' = $file };

        foreach ( $line in $( Get-Content -Path $file -ErrorAction:SilentlyContinue ) )
        {
            #  Check for uncommented, non-blank lines, but allow the standard ::1 and 127.0.0.1 localhost
            #  entries
            if ( $line -notmatch "^\s*(?<content>::1\s*localhost)(\s*#.*)?$" -and
                 $line -notmatch "^\s*(?<content>127\.0\.0\.1\s*localhost)(\s*#.*)?$" -and
                 $line -match "^\s*(?<content>[^# \t]+[^#]*?)(\s*#.*)?$" )
            {
                if ( $fileHash['Contents'] -eq $NULL )
                {
                    $fileHash['Contents'] = @();
                }

                $fileHash['Empty'] = $FALSE;
                $fileHash['Contents'] += $matches['content'];
                Write-Debug $( 'Found content in ' + $file + ': <' + $matches['content'] + '>' );
            }
            #  Check for a #include statement, which is not caught above, since # is the comment operator
            elseif ( $line -match "^\s*(?<content>#include\s*[^#]*?)(\s*#.*)?$" )
            {
                if ( $fileHash['Contents'] -eq $NULL )
                {
                    $fileHash['Contents'] = @();
                }

                $fileHash['Empty'] = $FALSE;
                $fileHash['Contents'] += $matches['content'];
                Write-Debug $( 'Found content in ' + $file + ': <' + $matches['content'] + '>' );
            }
        }

        $returnArray += $fileHash;
    }

    return $returnArray;
}

function Get-InterfaceConfiguration {
<#
.Synopsis
   Gets all the network interface configuration relevant to the BPA from the registry.
.Notes
    Return values:
       If the internal calls succeed, a hash is returned;
#>
[CmdletBinding()]
PARAM(  )

    $BindingOrderKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage\Bind";

    $resultsHash = @{};

    #  Get binding order from registry
    $keyResult = Get-RegistryKey $BindingOrderKey;
    if ( $keyResult -ne $NULL )
    {
        $resultsHash += $keyResult;
    }
    else
    {
        Write-Debug "Get-InterfaceConfiguration: Couldn't retrieve binding order from registry!";
    }

    #  Call CSharp code to get the network adapter information
    call-GetAdapterAddresses;

    $resultsHash['Interfaces'] = @();

    $InterfaceObjects = [AdapterUtils.AdapterInfo]::GetAdapterAddressInfo();

    #  This gets a list of strings, one for each property of the InterfaceInformation object
    $InterfaceProperties = [AdapterUtils.InterfaceInformation].GetMembers() |
        where { $_.MemberType -eq 'Field' } | foreach { $_.Name; }

    #  Convert the .Net object into a hashtable, so that it is extensible
    foreach ( $Interface in $InterfaceObjects )
    {
        $tempHash = @{};

        foreach ( $Property in $InterfaceProperties )
        {
            $tempHash[$Property] = $Interface.$Property;
        }

        $resultsHash['Interfaces'] += $tempHash;
    }

    foreach ( $Interface in $resultsHash['Interfaces'] )
    {
        $RegistrationEnabledKey = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($Interface.AdapterName)\RegistrationEnabled";

        $keyResult = Get-RegistryKey $RegistrationEnabledKey;

        if ( $keyResult -ne $null )
        {
            $Interface['RegistrationEnabled'] = $keyResult['RegistrationEnabled'];
        }
        else
        {
            Write-Debug "Get-InterfaceConfiguration: Couldn't retrieve $RegistrationEnabledKey!";
            $Interface['RegistrationEnabled'] = $NULL;
        }
    }

    return $resultsHash;
}

function Get-ServerConfiguration {
<#
.Synopsis
   Gets all the DNS Server configuration information relevant to the BPA from the registry and other sources. This is
   just the server parameters/configuration, not including zone information. The InterfaceConfiguration is required
   so that the complete list of server interfaces can be gathered.
.Parameter InterfaceConfiguration
    The InterfaceConfiguration hashtable.
.Notes
    Return values:
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [hashtable] $InterfaceConfiguration

 )

    $ServerParametersKey = "HKLM:\SYSTEM\CurrentControlSet\services\DNS\Parameters\*";
    $ServerCommentKey = "HKLM:\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters\srvcomment";
    $MaxUserPortKey = "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\MaxUserPort";

    $resultsHash = @{ 'Parameters' = @{}; };

    #  Get server parameters from registry
    $keyResult = Get-RegistryKey $ServerParametersKey;
    if ( $keyResult -ne $NULL )
    {
        foreach ( $Key in $keyResult.Keys )
        {
            #  We allow any key that is alpha-numeric, so as to avoid non-alphanumeric keys that might cause an XML
            #  exception when introduced as an element name. All present DNS Server keys are like this.
            if ( $keyResult[$Key] -ne $NULL -and $Key -match "^[a-zA-Z0-9]+$")
            {
                $resultsHash['Parameters'][$Key] = $keyResult[$Key];
            }
        }
    }
    else
    {
        Write-Debug "Get-ServerConfiguration:Couldn't retrieve server parameters from registry!";
    }

    #  Get the list of root hints
    $resultsHash['RootHints'] = Get-NSRecordsForZone '/RootHints';

    #  Determine if this server is configured for forwarding and/or recursion
    #  Devnote: this doesn't take into account the effects of timeouts or whether the roothints/forwarders are
    #  responding
    $ForwardingEnabled = $FALSE;  #  Based on the default values
    $NoRecursion = $FALSE;

    if ( $resultsHash['Parameters'][$FORWARDING_ENABLED_PARAMETER_NAME] -ne $NULL )
    {
        if ( $resultsHash['Parameters'][$FORWARDING_ENABLED_PARAMETER_NAME] -ne 0 )
        {
            $ForwardingEnabled = $TRUE;
        }
    }

    if ( $resultsHash['Parameters']['NoRecursion'] -ne $NULL )
    {
        if ( $resultsHash['Parameters']['NoRecursion'] -ne 0 )
        {
            $NoRecursion = $TRUE;
        }
    }

    if ( $resultsHash['Parameters']['Forwarders'] -ne $NULL -and
        $resultsHash['Parameters']['Forwarders'].Count -gt 0 )
    {
        $ForwardersConfigured = $TRUE;
    }
    else
    {
        $ForwardersConfigured = $FALSE;
    }

    if ( $resultsHash['RootHints'] -ne $NULL -and
        $resultsHash['RootHints'].Count -gt 0 )
    {
        $RootHintsConfigured = $TRUE;
    }
    else
    {
        $RootHintsConfigured = $FALSE;
    }

    if ( $NoRecursion -eq $TRUE )
    {
        $resultsHash['ForwardingPossible'] = $FALSE;
        $resultsHash['RecursionPossible'] = $FALSE;
    }
    else
    {
        if ( $ForwardingEnabled -eq $TRUE )
        {
            $resultsHash['RecursionPossible'] = $FALSE;
            $resultsHash['ForwardingPossible'] = $ForwardersConfigured;
        }
        else
        {
            $resultsHash['RecursionPossible'] = $RootHintsConfigured;
            $resultsHash['ForwardingPossible'] = $ForwardersConfigured;
        }
    }

    #  Get MaxUserPort from registry
    $keyResult = Get-RegistryKey $MaxUserPortKey;
    if ( $keyResult -ne $NULL )
    {
        $resultsHash['Parameters']['MaxUserPort'] = $keyResult['MaxUserPort'];
    }

    #  Retrieve service state
    $keyResult = Get-WmiObject -query "select * from win32_service where name='DNS'";
    $resultsHash['Service'] = @{};

    #  Assign only the allowed keys. This removes some WMI-specific keys.
    foreach ( $Key in $( $keyResult | get-member -MemberType Property ) )
    {
        #  Here we only allow alphabetical keys, since this covers all the ones we want.
        if ( $keyResult[$Key] -ne $NULL -and $Key -match "^[a-zA-Z]+$" )
        {
            $resultsHash['Service'][$Key] = $keyResult[$Key];
        }
    }

    #  This is to get the machine's hostname, but it could also retrieve the make/model and total RAM if needed
    $ComputerSystem = get-wmiobject Win32_ComputerSystem;
    if ( $ComputerSystem -ne $NULL )
    {
        $resultsHash['Hostname'] =  $ComputerSystem.DNSHostName + '.' +  $ComputerSystem.Domain;
    }

    #  Store whether this machine is a domain controller
    $resultsHash['IsDomainController'] = Get-IsDomainController;

    #  collecting information about Active Server Directory
    $DirectoryInfo = Get-ADConfiguration;
    if ( $DirectoryInfo -ne $NULL )
    {
        #  Manually extracting the information here, since the domain information object is very ill-behaved in
        #  Get-XMLSubtreeForObject (there are lots of circular references leading to infinite loops, and also
        #  there are properties reported by the Powershell ETS functions that don't actually exist )
        $resultsHash['DomainInfo'] = @{};
        $resultsHash['DomainInfo']['ForestMode'] = $DirectoryInfo.Forest.ForestMode;
        $resultsHash['DomainInfo']['DomainMode'] = $DirectoryInfo.DomainMode;
        $resultsHash['DomainInfo']['ForestName'] = $DirectoryInfo.Forest.Name;
        $resultsHash['DomainInfo']['DomainName'] = $DirectoryInfo.Name;
    }
    else
    {
        $resultsHash['DomainInfo'] = $NULL;
    }

    #  Get a list of all the interface IP addresses. These may or may not be listen addresses for the DNS server (by
    #  default, all IPs are listened on, but this can be overridden by registry key)
    $IPAddressAntiduplicationHash = @{};
    $IPAddressArray = @();

    foreach ( $Interface in $InterfaceConfiguration['Interfaces'] )
    {
        foreach ( $IPAddress in $Interface.IPAddressList)
        {
            $IPAddressAntiduplicationHash[ $IPAddress.IPAddress ]++;
            if ( $IPAddressAntiduplicationHash[ $IPAddress.IPAddress ] -eq 1 )
            {
                $IPAddressArray += $IPAddress;
            }
        }
    }

    #  Store the list of Interface IP addresses as an array
    $resultsHash['InterfaceAddresses'] = $IPAddressArray;

    return $resultsHash;
}

function Get-ZonesConfiguration {
<#
.Synopsis
    Returns the configuration for the zones on the local machine. Uses the registry and the output of DNSCMD
    to determine the results
#>
[CmdletBinding()]
PARAM(  )

    $DNSCmd = $(get-childitem -path env:SystemRoot).Value + "\system32\dnscmd.exe";
    $ZonesKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones";
    $AllowedKeysArray = @( 'Aging', 'AllowNSRecordsAutoCreation', 'AllowUpdate', 'DatabaseFile', 'DirectoryPartition',
        'DsIntegrated', 'ForwarderSlave', 'ForwarderTimeout', 'LocalMasterServers', 'LogUpdates', 'MasterServers',
        'NoRefreshInterval', 'NotifyLevel', 'NotifyServers', 'RefreshInterval', 'ScavengeServers', 'SecondaryServers',
        'SecureSecondaries', 'Type'
        );

    #  We will return the zones as individual hashes in an array, since we can't key based on the zone name.
    #  If we keyed by the zone name, then that zone name would be part of an XML tag in the configuration XML
    #  and that would mean that the schema would have to be generated on the fly.
    $ReturnHashArray = @();

    #  Get server parameters from registry
    $Zones = Get-ChildItem $ZonesKey;

    if ( $Zones -ne $null )
    {
        #  Perform additional processing for certain zones
        foreach( $Zone in $Zones )
        {
            $errVar = $NULL;

            #  Note: $Zone.PSChildName is just the last name in the key (e.g. 'contoso.com' )
            #        $Zone.Name is the full key (e.g. "$ZonesKey\contoso.com" )
            $ReturnHash = @{ 'Name' = $Zone.PSChildName; };

            Write-Debug "Get-ZonesConfiguration: Getting configuration for $($Zone.PSChildName)";

            #  Load a predefined list of zone keys into the hash:
            foreach ( $Key in $AllowedKeysArray )
            {
                #  $KeyValueHash = Get-RegistryKey "$ZonesKey\$($Zone.PSChildName)\$Key";
                $KeyValueHash = get-itemproperty -path "$ZonesKey\\$($Zone.PSCHildName)" -name "$Key" -ErrorAction:SilentlyContinue;

                if ( $KeyValueHash -ne $null )
                {
                    $ReturnHash[$Key] = $KeyValueHash.$Key;
                }
                else
                {
                    $ReturnHash[$Key] = $NULL;
                }
            }

            #  Get the output of dnscmd /zoneinfo for the zone, and check that were no errors
            #  dnscmd is localized, so this has to be done very carefully. We have to do this because there is no other
            #  source for the last transfer result, unless we want to parse the event log
            $dnscmdOutput = exec -cmd "$DNSCmd /ZoneInfo $($Zone.PSChildName)" -errVarRef ([ref]$errVar);
            if ( $errVar )
            {
                Write-Debug "Get-ZonesConfiguration: $DNSCmd /ZoneInfo $($Zone.PSChildName) returned error: $errVar";
                Write-Debug "Get-ZonesConfiguration: Output: $dnscmdOutput";
            }
            else
            {
                #  This hash gives the location of the information in the output. Lines are only counted if they have an
                #  equal sign eventually followed by a number. The first such line is index 1. The last line can be
                #  referred to as -1.
                #  Devnote: the negative indexes here are both for stub/secondary only, and that is the property used
                #  to exclude these patterns from other zone types.
                #  Example:
                #  [1/-24]:  ptr                   = 00000000002CA990
                #  [2/-23]:  zone name             = zone3.com
                #  [3/-22]:  zone type             = 2
                #  [4/-21]:  shutdown              = 0
                #  [5/-20]:  paused                = 0
                #  [6/-19]:  update                = 0
                #  [7/-18]:  DS integrated         = 0
                #  [8/-17]:  read only zone        = 0
                #  [9/-16]:  data file             = zone3.com.dns
                #  [10/-15]:  using WINS            = 0
                #  [11/-14]:  using Nbstat          = 0
                #  [12/-13]:  aging                 = 0
                #  [13/-12]:    refresh interval    = 0
                #  [14/-11]:    no refresh          = 0
                #  [15/-10]:    scavenge available  = 0
                #  [16/-9]:  Ptr          = 00000000002BDF40
                #  [17/-8]:  MaxCount     = 1
                #  [18/-7]:  AddrCount    = 1
                #  [19/-6]:   Master[0] => af=2, salen=16, [sub=0, flag=00000000] p=13568, addr=157.55.24.200
                #  [20/-5]:  secure secs           = 0
                #  [21/-4]:  last successful xfr         = not since restart (0)
                #  [22/-3]:  last successful SOA check   = Thu Dec 31 15:20:44 2009 (1262301644)
                #  [23/-2]:  last transfer attempt       = not since restart (0)
                #  [24/-1]:  last transfer result        = 0

                $resultLocationHash =    @{
                                            'Type' = 3;                     # Valid for all zone types
                                            'Shutdown' = 4;                 # Valid for all zone types
                                            'Paused' = 5;                   # Valid for all zone types
                                            'LastTransferResult' = -1;      # Valid for stub/secondary only
                                            'LastTransferAttempt' = -2;     # Valid for stub/secondary only
                                            'LastSuccessfulSOACheck' = -3;  # Valid for stub/secondary only
                                            'LastSuccessfulXFR' = -4;       # Valid for stub/secondary only
                                         };

                #  This pattern says:   1) the line must contain an equal sign
                #                       2) if the line contains a group of digits, the group of digits nearest the end
                #                          of the line is called the 'LastDigitGroup'
                $linePattern = "^.*=.*?(?<LastDigitGroup>-?\d+)?\D*$"

                #  This creates an array of lines matching the pattern. The $Matches variable is not set in this context
                #  (the array context).
                $patternMatchedLines = $dnscmdOutput -match $linePattern;

                #  If $patternMatchedLines matched no lines or only one line, it will not be an array. In this case
                #  something has gone wrong
                if ( $patternMatchedLines -isnot [System.Array] )
                {
                    Write-Debug 'Get-ZonesConfiguration: Output of DNSCMD did not match pattern properly. Skipping..';
                    continue;
                }

                ## For debug purposes, this will display the captured lines with both positive and negative indices
                0..$($patternMatchedLines.Count-1) | foreach {
                     Write-Debug "[$($_+1)/-$($patternMatchedLines.Count - $_)]: $($patternMatchedLines[$_])"; }

                foreach ( $patternKey in $resultLocationHash.Keys )
                {
                    $index = $resultLocationHash[$patternKey];

                    #  Convert the location hash index into the array index
                    if ( $index -gt 0 ) #  Positive indexes are line numbers starting from 1 (not 0)
                    {
                        $index--;   #  The absolute index is just rooted at zero instead of one
                    }
                    else    #  Negative indexes count backwards from the last line, starting at -1
                    {
                        #  The last line is -1, which results in Count - 1 in absolute terms
                        $index = $patternMatchedLines.Count + $index;

                        #  All the negative indexes (so far) are only valid for secondary/stub zones. Skip this if the
                        #  zone is not the right type.
                        if ( $ReturnHash['Type'] -ne $ZONE_TYPE['Secondary'] -and
                             $ReturnHash['Type'] -ne $ZONE_TYPE['Stub'] )
                        {
                            continue;
                        }
                    }

                    #  Verify that the absolute index is in bounds
                    if ( $index -lt 0 -or $index -gt $( $patternMatchedLines.Count - 1 ) )
                    {
                        Write-Debug "Get-ZonesConfiguration: Index $index out of range 0..$($patternMatchedLines.Count-1)";
                        break;
                    }

                    #  Match the specific line again, so that we get the $Matches variable set
                    $Value = $patternMatchedLines[$index] -match $linePattern;
                    $Value = $Matches['LastDigitGroup'];

                    #  This is a safeguard; if we already have the value from the registry, check that it matches
                    if ( $ReturnHash[$patternKey] -ne $NULL -and $ReturnHash[$patternKey] -ne $Value )
                    {
                        Write-Debug "Get-ZonesConfiguration: Pre-existing data ($($ReturnHash[$patternKey])) contradicted by dnscmd output ($Value)";
                        break;
                    }

                    #  Capture the result
                    $ReturnHash[$patternKey] = $Value;
                }
            }

            #  Retrieves whatever NS glue/additional known to the local server
            $ReturnHash['NameServerAddresses'] = Get-NSRecordsForZone -ZoneName $Zone.PSChildName;

            $ReturnHashArray += $ReturnHash;
        }
    }
    else
    {
        Write-Debug "Get-ZonesConfiguration: Couldn't retrieve zone parameters from registry!";
    }

    return $ReturnHashArray;
}

function Get-RegistryKey {
<#
.Synopsis
   Get-RegistryKey
   Gets the value of a particular registry key, or values for keys specified with a wildcard.
.Parameter Key
    A string containing the registry key to query. Use the same format/paths as the native Powershell registry
    provider. Wildcards are partially supported. Either the last label of the path or the key name (but not both) may
    be '*'.
.Example
   Get-RegistryKey "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\CurrentBuildNumber"
       Retrieves the current build number from the registry
.Example
   Get-RegistryKey "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DNS Server\Zones\*\DatabaseFile"
       Retrieves the names of the database files for all zones. The zone name is the key of the hash.
.Example
   Get-RegistryKey "HKLM:\SYSTEM\CurrentControlSet\services\DNS\Parameters\*"
       Retrieves the DNS server's server-parameters
.Notes
    Return values:
       $NULL: Indicates that the path or key does not exist
       Object: The value of the key
       Hashtable: A hashtable with wildcard instance as the hash-key and key value as hash-value. This is only returned
           if there was a wildcard in the path.
#>
[CmdletBinding()]
PARAM(  [parameter(Mandatory=$TRUE,ValueFromPipeline=$true)] [String] $Key )

    try
    {
        if ( $Key -match "^(?<path>[A-Z]{4}:.*)\\(?<keyname>[^\\]+)$" )
        {
            $path = $matches['path'];
            $keyname = $matches['keyname'];
            $returnHash = @{};

            # Check for a terminal wildcard;
            if ( $keyname -eq '*' )
            {
                $item = get-itemproperty -path $path -ErrorAction:SilentlyContinue;
            }
            else
            {
                $item = get-itemproperty -path $path -name $keyname -ErrorAction:SilentlyContinue
            }

            if ( $item -eq $null )
            {
                return $NULL;
            }

            #  If we get an array (due to wildcard), or the original search spec'd a wildcard but
            #  returned only one result, process and return as a hash
            foreach ( $subitem in $item )
            {
                foreach ( $property in $( $subitem | Get-Member -MemberType NoteProperty ) )
                {
                    #  Screen out the PowerShell default properties to get only the registry keys
                    if ( $property.Name -match "^PS(ChildName|Drive|ParentPath|Path|Provider)$" )
                    {
                        continue;
                    }
                    else
                    {
                        #  If a hash doesn't already exist for the key, create it
                        if ( $returnHash[ $subitem.PSChildName ] -eq $NULL )
                        {
                            $returnHash[ $subitem.PSChildName ] = @{ $property.Name = $subitem.$($property.Name); };
                        }

                        #  Use the existing hash
                        else
                        {
                            $returnHash[ $subitem.PSChildName ][$property.Name] = $subitem.$($property.Name);
                        }
                    }
                }

            }

            if ( $returnHash.Count -eq 0 )
            {
                return $NULL
            }
            #  If we are not doing a path wildcard, strip the pathname layer from the hash
            elseif ( -not $path.Contains('*') )
            {
                return $returnHash[ $item.PSChildName ];
            }
            else
            {
                return $returnHash;
            }
        }
        else
        {
            return $NULL;
        }
    }
    #  Catch exceptions thrown when a key or path does not exist.
    catch [System.Management.Automation.RuntimeException]
    {
        Write-Debug "Get-RegistryKey($key) encountered exception: $_";
        return $NULL;
    }
}

function Get-Evaluation {
<#
.Synopsis
    Returns the complete evaluation for this sytem. This function calls all the Get-RuleEvaluation rules.
.Parameter Configuration
    This is the Configuration hashtable provided by Get-Configuration.
.Outputs
    Returns an array of RuleEvaluationHashes.
#>
[CmdletBinding()]
PARAM(
    [parameter(Mandatory=$TRUE)]
    [ValidateNotNullOrEmpty()]
    [Hashtable] $Configuration
)

    $returnArray         = @();
    $Evaluation          = @();
    $Interfaces          = $Configuration['InterfaceConfiguration']['Interfaces'];
    $ServerConfiguration = $Configuration['ServerConfiguration'];

    #  Tests on the entire configuration
    $result = Get-RuleEvaluation 'Resolve_Mismatch' $Configuration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Zone_Status_AD' $Configuration ([ref]$Evaluation);

    #  Hosts File(s) tests
    $result = Get-RuleEvaluation 'Param_Hosts' $Configuration['HostsFileConfiguration'] ([ref]$Evaluation);

    #  Server Parameters Tests
    $result = Get-RuleEvaluation 'Param_Blocklist' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Param_CacheLockingOff' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Param_ForwardingTimeout' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Param_RootHints' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Param_ScavengingServer' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Param_SocketPoolOff' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Param_TimeoutOffset' $ServerConfiguration ([ref]$Evaluation);
    $result = Get-RuleEvaluation 'Resolve_Forwarders' $ServerConfiguration ([ref]$Evaluation);

    #  InterfaceConfiguration Tests
    $result = Get-RuleEvaluation 'BindingOrder' $Configuration['InterfaceConfiguration'] ([ref]$Evaluation);

    #  Execute interface tests only if NoIPAddressesExist passes. This handles the case where Interfaces is $NULL.
    #  Interfaces will be $NULL when all of the interfaces on the system have no assigned IP addresses.
    if ( Get-RuleEvaluation 'NoIPAddressesExist' $Interfaces ([ref]$Evaluation) )
    {
        foreach ( $Interface in $Interfaces )
        {
            #  Interface Tests

            $result = Get-RuleEvaluation 'DNSServerConfigured' $Interface ([ref]$Evaluation);
            $result = Get-RuleEvaluation 'IPv4DHCPConfiguration' $Interface ([ref]$Evaluation);
            $result = Get-RuleEvaluation 'Param_RegistrationEnabled' $Interface ([ref]$Evaluation);

            #  Many of the tests require the AdapterFriendlyName and/or ServerConfiguration in addition to the IP address
            #  to test
            $IPAddressTestInputHash = @{ 'Interface' = $Interface; };
            $IPAddressTestInputHash['ServerConfiguration'] = $ServerConfiguration;

            #  Don't run the DNSLoopback or other DNS server address tests if there are no addresses
            #  This surpresses a spurious DNSLoopback non-compliance message when there are no DNS servers anyway
            if ( $Interface.DNSServerList.Count -ne 0 )
            {
                $result = Get-RuleEvaluation 'DNSLoopback' $Interface ([ref]$Evaluation);

                Foreach ( $IPAddress in $Interface.DNSServerList )
                {
                    #  DNS Server tests
                    $IPAddressTestInputHash['IPAddress'] = $IPAddress;

                    $result = Get-RuleEvaluation 'Resolve_Status' $IPAddressTestInputHash ([ref]$Evaluation);
                    $result = Get-RuleEvaluation 'DNSAutoConfig' $IPAddressTestInputHash ([ref]$Evaluation);
                }
            }

            if ( $Interface.IPAddressList -ne $NULL )
            {
                Foreach ( $IPAddress in $Interface.IPAddressList )
                {
                    #  Adapter IP tests
                    $IPAddressTestInputHash['IPAddress'] = $IPAddress;

                    write-debug "AFN: $($IPAddressTestInputHash['Interface'].AdapterFriendlyName)";
                    $result = Get-RuleEvaluation 'IPAutoConfiguration' $IPAddressTestInputHash ([ref]$Evaluation);
                }
            }

        }
    }

    # Zone Tests
    if ( $Configuration['ZonesConfiguration'] -ne $NULL )
    {
        foreach ( $Zone in $Configuration['ZonesConfiguration'] )
        {
            $result = Get-RuleEvaluation 'Resolve_Peers' $Zone ([ref]$Evaluation);
            $result = Get-RuleEvaluation 'Param_ScavengingZone' $Zone ([ref]$Evaluation);
            $result = Get-RuleEvaluation 'Zone_Status_XFR' $Zone ([ref]$Evaluation);
        }
    }
    #  Return the evaluations, sorted by the RuleName. The sequence of rules in the schema is in alphabetical order
    #  by the RuleName, so this ensures that the output will pass XML validation.
    return $Evaluation | sort -Property @{ Expression={$_['RuleName']}; } ;
}

#################################################################################################
# Execute a command and capture errors
# Original implementation: DirectoryServices_model.ps1
#################################################################################################
function Exec($cmd, [ref] $errVarRef) {
    $cmdErr = $NULL
    $trapErr = $NULL
    $trapRef = [ref] $trapErr

    $result = Invoke-Expression -command $cmd -ErrorVariable cmdErr

    if (!($trapErr)) {
        if ($cmdErr) {
            $trapErr = $cmdErr[0]
        }
        elseif ( $LASTEXITCODE ) {
            $trapErr = $LASTEXITCODE;
        }
    }

    $errVarRef.Value = $trapErr
    $result

    trap {
        $trapRef.Value = $_
        continue
    }
}

function CleanAndExit()
{
    Write-Debug $error[0]
    Write-Debug $error[0].Exception
    Write-Debug $error[0].InvocationInfo.PositionMessage
    Write-Debug 'Exiting';
    exit(1);
}


#All the errors will be trapped here and the boolean flag will be set
$error.clear()
trap
{
    CleanAndExit
}

#
# ------------------------
# SCRIPT MAIN BODY - START
# ------------------------
#

#  Compile the C# code for the DNS resolver and network adapter utilities
call-CompileCSharpUtilities;

Write-Debug "Baseline: Getting configuration"
$Configuration = Get-Configuration;

Write-Debug "Baseline: Generating evaluation"
$Evaluation = Get-Evaluation $Configuration;


# Create the XML Configuration Document
Write-Debug "Baseline: Creating XML document"

$doc = Create-DocumentElement $XML_NAMESPACE "DNS-BPA-Report"

$Node_Configuration = Create-XMLSubtreeForObject -Object $Configuration -Name "tns:Configuration";
$Node_Evaluation = Create-XMLSubtreeForObject -Object $Evaluation -Name "tns:Evaluation";

[void]$doc.DocumentElement.AppendChild($Node_Configuration);
[void]$doc.DocumentElement.AppendChild($Node_Evaluation);

$doc
