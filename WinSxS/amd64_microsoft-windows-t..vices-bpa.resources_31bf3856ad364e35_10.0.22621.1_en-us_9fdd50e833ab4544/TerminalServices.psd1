# Localized	05/07/2022 03:26 AM (GMT)	303:7.0.30723 	TerminalServices_model.psd1
# 
# Only add new (name,value) pairs to the end of this table
# Do not remove, insert or re-arrange entries
#

ConvertFrom-StringData @'
       
    ###PSLOC start localizing

    #
    # ActivationStatusCheck
    #
ActivationStatusCheck_Title=The license server must be activated before you can install RDS CALs onto the license server
ActivationStatusCheck_Problem_UnRegistered=The Remote Desktop license server is not activated, so you cannot install Remote Desktop Services client access licenses (RDS CALs) onto the license server.
ActivationStatusCheck_Problem_StatusUnknown=The Remote Desktop license server Activation Status could not be determined.
ActivationStatusCheck_Impact=Each user or computing device that connects to a remote desktop server must have a valid RDS CAL issued by a license server. If an activated license server with RDS CALs installed is not available, the remote desktop server may stop accepting connections.
ActivationStatusCheck_Resolution_UnRegistered=Use the RD Licensing Manager tool to activate the license server and then to install RDS CALs onto the license server.
ActivationStatusCheck_Resolution_StatusUnknown=Check if the Remote Desktop Licensing Service is running.
ActivationStatusCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
       
    #
    # NumberCAPPoliciesCheck - Rule 3
    #
NumberCAPPoliciesCheck_Title=The RD Gateway server must have at least one RD CAP enabled
NumberCAPPoliciesCheck_Problem=The Remote Desktop Gateway (RD Gateway) server does not have a Remote Desktop connection authorization policy (RD CAP) enabled.
NumberCAPPoliciesCheck_Impact=If the RD Gateway server does not have an RD CAP enabled, users cannot connect to internal network resources (computers) through the RD Gateway server.
NumberCAPPoliciesCheck_Resolution=Use the RD Gateway Manager tool to enable an RD CAP to specify which users can use the RD Gateway server to connect to internal network resources (computers).
NumberCAPPoliciesCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # NumberRAPPoliciesCheck - Rule 4
    #
NumberRAPPoliciesCheck_Title=The RD Gateway server must have at least one RD RAP enabled
NumberRAPPoliciesCheck_Problem=The Remote Desktop Gateway (RD Gateway) server does not have a Remote Desktop resource authorization policy (RD RAP) enabled.
NumberRAPPoliciesCheck_Impact=If the RD Gateway server does not have an RD RAP enabled, users cannot connect to internal network resources (computers) through the RD Gateway server.
NumberRAPPoliciesCheck_Resolution=Use the RD Gateway Manager tool to enable an RD RAP to specify the internal network resources (computers) that users can connect to through the RD Gateway server.
NumberRAPPoliciesCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #	
    # SSLCertConfiguredCheck - Rule 5
    #
SSLCertConfiguredCheck_Title=The RD Gateway server must be configured to use a valid SSL certificate
SSLCertConfiguredCheck_Problem=The Remote Desktop Gateway (RD Gateway) server does not have a valid Secure Sockets Layer (SSL) certificate.
SSLCertConfiguredCheck_Impact=If the RD Gateway server is configured to use an SSL certificate that is not valid, users cannot connect to internal network resources (computers) through the RD Gateway server.
SSLCertConfiguredCheck_Resolution=Use the RD Gateway Manager tool to select a valid SSL certificate for the RD Gateway server to use.
SSLCertConfiguredCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # SSLCertIsSelfSignedCheck- Rule 6
    #
SSLCertIsSelfSignedCheck_Title=RD Gateway must be configured to use an SSL certificate signed by a trusted certification authority
SSLCertIsSelfSignedCheck_Problem=The Remote Desktop Gateway (RD Gateway) server is configured to use a self-signed certificate. By default, a self-signed certificate is not trusted by client computers.
SSLCertIsSelfSignedCheck_Impact=If the RD Gateway server is configured to use a Secure Sockets Layer (SSL) certificate that is not signed by a trusted certification authority, users might be unable to connect to internal network resources (computers) through the RD Gateway server.
SSLCertIsSelfSignedCheck_Resolution=Use the RD Gateway Manager tool to configure the RD Gateway server to use an SSL certificate that is signed by a trusted certification authority. Using a self-signed certificate is not recommended.
SSLCertIsSelfSignedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # NPSServerReachableCheck - Rule 7
    #
NPSServerReachableCheck_Title=The RD Gateway server must be able to contact the server running NPS
NPSServerReachableCheck_Problem=The Remote Desktop Gateway (RD Gateway) server is unable to contact the server running Network Policy Server (NPS) that contains the central Remote Desktop connection authorization policy (RD CAP) store.
NPSServerReachableCheck_Impact=If the RD Gateway server is unable to contact the server running NPS that contains the central RD CAP store, users cannot connect to internal network resources (computers) through the RD Gateway server.
NPSServerReachableCheck_Resolution=Ensure that the server running NPS is started and that there is network connectivity between the RD Gateway server and the server running NPS.
NPSServerReachableCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # LoadBalancedServerErrorneousCheck - Rule 8
    #
LoadBalancedServerErrorneousCheck_Title=Members of an RD Gateway server farm should be available on the network and configured identically
LoadBalancedServerErrorneousCheck_Problem=At least one Remote Desktop Gateway (RD Gateway) server in the RD Gateway server farm is not available on the network or is not running the same version of the operating system as the other members of the RD Gateway server farm.
LoadBalancedServerErrorneousCheck_Impact=If some of the members of an RD Gateway server farm are not available on the network or are not running the same version of the operating system, users might experience different functionality depending on the RD Gateway server through which they connect.
LoadBalancedServerErrorneousCheck_Resolution=Ensure that all the RD Gateway servers in the RD Gateway server farm are available on the network, are running the same version of the operating system, and are configured identically.
LoadBalancedServerErrorneousCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # ConnectionsExhaustedCheck - Rule 9
    #
ConnectionsExhaustedCheck_Title=The RD Gateway server should be configured to allow  an adequate number of simultaneous connections
ConnectionsExhaustedCheck_Problem=The Remote Desktop Gateway (RD Gateway) server has reached the limit on the maximum number of simultaneous connections allowed.
ConnectionsExhaustedCheck_Impact=If the RD Gateway server is configured to limit the number of simultaneous connections allowed, users making new connections will be unable to connect to internal network resources (computers) through the RD Gateway server when the limit is exceeded.
ConnectionsExhaustedCheck_Resolution=Monitor the performance of the RD Gateway server to determine the maximum number of connections that the RD Gateway server can support. If necessary, use the RD Gateway Manager tool to reconfigure the maximum number of simultaneous connections allowed.
ConnectionsExhaustedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # ActiveDirectoryServerRechableCheck - Rule 10
    #
ActiveDirectoryServerRechableCheck_Title=The RD Gateway server must be able to contact Active Directory Domain Services
ActiveDirectoryServerRechableCheck_Problem=An authorization policy on the Remote Desktop Gateway (RD Gateway) server is configured to use an Active Directory security group, but the RD Gateway server is unable to contact Active Directory Domain Services (AD DS).
ActiveDirectoryServerRechableCheck_Impact=If the RD Gateway server is unable to contact AD DS, users cannot be authenticated and the users will be unable to connect to internal network resources (computers) through the RD Gateway server.
ActiveDirectoryServerRechableCheck_Resolution=Ensure that the RD Gateway server is a member of an Active Directory domain and that there is network connectivity between the RD Gateway server and AD DS.
ActiveDirectoryServerReachableCheckWarning_Title=Remote Desktop Services can’t connect to Active Directory.
ActiveDirectoryServerReachableCheckWarning_Problem=An authorization policy on the Remote Desktop Gateway (RD Gateway) server is set to use an Active Directory security group, but the Remote Desktop Services Best Practices Analyzer can’t get a list of domain controllers in the current domain.
ActiveDirectoryServerReachableCheckWarning_Impact=If the Remote Desktop Services Best Practices Analyzer can’t get the list of domain controllers, it can’t verify connectivity to Active Directory.
ActiveDirectoryServerReachableCheckWarning_Resolution=Log on with a domain user account, and then run the Best Practices Analyzer to get a list of domain controllers and to verify connectivity to Active Directory.
ActiveDirectoryServerRechableCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # WebSiteRunningCheck - Rule 11
    #
WebSiteRunningCheck_Title=The Web site that the RD Gateway server is configured to use must be started on the Web (IIS) server
WebSiteRunningCheck_Problem=The Web site that the Remote Desktop Gateway (RD Gateway) server is configured to use is not started on the Web (IIS) server.
WebSiteRunningCheck_Impact=If the Web site that the RD Gateway server is configured to use is not started on the Web (IIS) server, users cannot connect to internal network resources (computers) through the RD Gateway server.
WebSiteRunningCheck_Resolution=Use the Internet Information Services (IIS) Manager tool to ensure that the Web site that the RD Gateway server is configured to use is started.
WebSiteRunningCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # CAPPolicyIsNonCompliantCheck - Rule 12
    #
CAPPolicyIsNonCompliantCheck_Title=The RD CAP(s) stored on the server running NPS must be configured correctly to support RD Gateway
CAPPolicyIsNonCompliantCheck_Problem=The Remote Desktop connection authorization policy (with Name[s] {0}) stored on the server running Network Policy Server (NPS) is/are not configured correctly to support connections through the Remote Desktop Gateway (RD Gateway) server.
CAPPolicyIsNonCompliantCheck_Impact=If the RD CAP stored on the server running NPS is not configured correctly, users will be unable to connect to internal network resources (computers) through the RD Gateway server.
CAPPolicyIsNonCompliantCheck_Resolution=Use the Network Policy Server tool to ensure that the RD CAP stored on the server running NPS is configured correctly to support connections through the RD Gateway server.
CAPPolicyIsNonCompliantCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # NONewConnectinsAllowedCheck - Rule 13
    #
NONewConnectinsAllowedCheck_Title=The RD Gateway server should be configured to allow new connections
NONewConnectinsAllowedCheck_Problem=The Remote Desktop Gateway (RD Gateway) server is configured to disable new connections.
NONewConnectinsAllowedCheck_Impact=If the RD Gateway server is configured to disable new connections, no new user connections will be allowed through the RD Gateway server.
NONewConnectinsAllowedCheck_Resolution=Use the RD Gateway Manager tool to configure the RD Gateway server to accept new connections.
NONewConnectinsAllowedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # ConenctOnlytoWin7ClientCheck - Rule 14
    #
ConenctOnlytoWin7ClientCheck_Title=The RD Gateway server should be configured to allow connections from all supported clients
ConenctOnlytoWin7ClientCheck_Problem=The Remote Desktop Gateway (RD Gateway) server is configured to accept only connections from clients using the latest version of the Remote Desktop Connection (RDC) software.
ConenctOnlytoWin7ClientCheck_Impact=If a client computer is not running the latest version of RDC, the user will be unable to connect to internal network resources (computers) through the RD Gateway server.
ConenctOnlytoWin7ClientCheck_Resolution=Use the RD Gateway Manager tool to configure the RD Gateway server to accept connections from all supported versions of RDC.
ConenctOnlytoWin7ClientCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RDGatewaySvcStartedCheck - Rule 15
    #
RDGatewaySvcStartedCheck_Title=The Remote Desktop Gateway service must be running on the RD Gateway server
RDGatewaySvcStartedCheck_Problem=The Remote Desktop Gateway service is not running on the Remote Desktop Gateway (RD Gateway) server.
RDGatewaySvcStartedCheck_Impact=If the Remote Desktop Gateway service is not running on the RD Gateway server, users cannot connect to internal network resources (computers) through the RD Gateway server.
RDGatewaySvcStartedCheck_Resolution=Use the Services tool to start the Remote Desktop Gateway service on the RD Gateway server.
RDGatewaySvcStartedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RDPGrpMemberCountCheck
    #
RDPGrpMemberCountCheck_Title=The Remote Desktop Users group on the RD Session Host server must contain domain users or groups
RDPGrpMemberCountCheck_Problem=The Remote Desktop Users group on the Remote Desktop Session Host server does not contain any domain users or groups.
RDPGrpMemberCountCheck_Impact=If the Remote Desktop Users group on the RD Session Host server does not contain domain users or groups, users will not be able to connect to the RD Session Host server.
RDPGrpMemberCountCheck_Resolution=Use the Remote tab in the System Properties dialog box to add domain users or groups to the Remote Desktop Users group on the RD Session Host server.
RDPGrpMemberCountCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RemoteDesktopDisabledCheck
    #
RemoteDesktopDisabledCheck_Title=The RD Session Host server should be configured to allow remote desktop connections
RemoteDesktopDisabledCheck_Problem=Remote desktop connections to the Remote Desktop Session Host server are disabled.
RemoteDesktopDisabledCheck_Impact=If remote desktop connections are disabled, users will not be able to connect to the RD Session Host server.
RemoteDesktopDisabledCheck_Resolution=Use the Remote tab in the System Properties dialog box to enable remote desktop connections on the RD Session Host server.
RemoteDesktopDisabledCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    #
    # MaxInstanceCountCheck
    #
MaxInstanceCountCheck_Title=The RD Session Host server should be configured to allow an adequate number of simultaneous connections
MaxInstanceCountCheck_Problem=The maximum number of simultaneous connections is configured for less than 5 users.
MaxInstanceCountCheck_Impact=If the maximum number of simultaneous connections is less than the required number of users, some users may not be able to log on to the Remote Desktop Session Host server.
MaxInstanceCountCheck_Resolution=Increase the maximum number of simultaneous connections by configuring the "Limit number of connections" Group Policy setting.
MaxInstanceCountCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
   
    #
    # AlternateSrvSpecifiedCheck
    #
AlternateSrvSpecifiedCheck_Title=The alternative server name must be specified for Remote Desktop Connection 6.1 and earlier
AlternateSrvSpecifiedCheck_Problem=The alternative server name is not specified.
AlternateSrvSpecifiedCheck_Impact=The alternative server name must be specified if you are using Remote Desktop Connection (RDC) 6.1 and earlier. If it is not specified, RDC 6.1 and earlier clients will not be able to connect.
AlternateSrvSpecifiedCheck_Resolution=The alternative server name is specified by using Remote Desktop Connection Manager on the Remote Desktop Connection Broker server.
AlternateSrvSpecifiedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RedirectorAltServerHaveSameIPCheck
    #
RedirectorAltServerHaveSameIPCheck_Title=The alternative server name must resolve to the IP address of the redirection server
RedirectorAltServerHaveSameIPCheck_Problem=The alternative server name does not have a valid DNS entry, or the DNS entry does not resolve to the same IP address as the Remote Desktop Session Host server running in redirection mode.
RedirectorAltServerHaveSameIPCheck_Impact=The alternative server name must resolve to the IP address of the Remote Desktop Session Host server running in redirection mode. If it does not, RDC 6.1 and earlier clients will not be able to connect.
RedirectorAltServerHaveSameIPCheck_Resolution=The alternative server name is specified by using Remote Desktop Connection Manager on the Remote Desktop Connection Broker server.
RedirectorAltServerHaveSameIPCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # FireWallExceptionEnabledCheck
    #
FireWallExceptionEnabledCheck_Title=The current Windows Firewall profile must be configured to allow remote desktop connections
FireWallExceptionEnabledCheck_Problem=The current Windows Firewall profile is not configured to allow remote desktop connections.
FireWallExceptionEnabledCheck_Impact=Users are not able to connect to the server by using Remote Desktop Connection.
FireWallExceptionEnabledCheck_Resolution=Enable remote desktop connections by using the Windows Firewall console.
FireWallExceptionEnabledCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # CALAvailableCheck
    #
CALAvailableCheck_Title=The Remote Desktop license server must have enough RDS CALs installed to allow users and devices to connect
CALAvailableCheck_Problem=There are not enough Remote Desktop Services client access licenses (RDS CALs) installed to allow users and devices to connect to the Remote Desktop Session Host server.
CALAvailableCheck_Impact=Some users or devices may not be able to connect to the Remote Desktop Session Host server.
CALAvailableCheck_Resolution=Install more Remote Desktop Services client access licenses by using Remote Desktop Licensing Manager.
CALAvailableCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #	
    # SSLCertNameIsFQDNCheck
    #
SSLCertNameIsFQDNCheck_Title=The RD Gateway server SSL certificate must be configured with a valid certificate subject name
SSLCertNameIsFQDNCheck_Problem=The Remote Desktop Gateway (RD Gateway) server Secure Sockets Layer (SSL) certificate may not have a valid certificate subject name.
SSLCertNameIsFQDNCheck_Impact=If the RD Gateway server is configured to use an SSL certificate with a certificate subject name that is not valid, users cannot connect to internal network resources (computers) through the RD Gateway server.
SSLCertNameIsFQDNCheck_Resolution=Use the RD Gateway Manager tool to select a valid SSL certificate for the RD Gateway server to use.
SSLCertNameIsFQDNCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #	
    # RDSHCollectionCheck
    #
RDSHCollectionCheck_Title=All the RDSH Servers in a collection must be homogenous
RDSHCollectionCheck_Problem=Some RDSH Servers in a collection may not be homogenous. Please take a look at the below report. {0}
RDSHCollectionCheck_Impact=If the RDSH servers in a collection are not homogenous then undesired side effects can happen
RDSHCollectionCheck_Resolution=Use the RDMS console to maintain homogeneity across all settings in RDSH servers of a collection.
RDSHCollectionCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

RDSHCollectionCheck_Collection=Collection:
RDSHCollectionCheck_HeterogeneousServers=Non-homogeneous servers:
RDSHCollectionCheck_MoreInformation=See below for more information:
RDSHCollectionCheck_ExpectedPropertyValues=Collection expected property values:
RDSHCollectionCheck_Server=Server:

    #
    # RDSH Collection Properties
    #
RDSHCollectionCheck_PropertyUserGroup=Property: User Group:

RDSHCollectionCheck_PropertyConnections_DisconnectedSessionLimit=Property: Connections: Disconnection Session Limit:
RDSHCollectionCheck_PropertyConnections_ActiveSessionLimit=Property: Connections: Active Session Limit:
RDSHCollectionCheck_PropertyConnections_IdleSessionLimit=Property: Connections: Idle Session Limit:
RDSHCollectionCheck_PropertyConnections_BrokenConnectionAction=Property: Connections: Broken Connection Action:
RDSHCollectionCheck_PropertyConnections_EnableAutomaticReconnection=Property: Connections: Enable Automatic Reconnection:
RDSHCollectionCheck_PropertyConnections_DeleteTempFoldersOnExit=Property: Connections: Delete Temp Folders On Exit:
RDSHCollectionCheck_PropertyConnections_UseTempFoldersPerSession=Property: Connections: Use Temp Folders Per Session:
 

RDSHCollectionCheck_PropertySecurity_SecurityLayer=Property: Security: Security Layer:
RDSHCollectionCheck_PropertySecurity_EncryptionLevel=Property: Security: Encryption Level:
RDSHCollectionCheck_PropertySecurity_AuthenticateUsingNLA=Property: Security: Authenticate Using NLA:

RDSHCollectionCheck_PropertyClientSettings_DeviceRedirectionOptions=Property: Client Settings: Device Redirection Options:
RDSHCollectionCheck_PropertyClientSettings_RedirectClientPrinter=Property: Client Settings: Redirect Client Printer:
RDSHCollectionCheck_PropertyClientSettings_SetClientPrinterAsDefault=Property: Client Settings: Set Client Printer As Default:
RDSHCollectionCheck_PropertyClientSettings_UserRDEasyPrintDriver=Property: Client Settings: Use RD Easy Print Driver:
RDSHCollectionCheck_PropertyClientSettings_MaxMonitors=Property: Client Settings: Max Monitors:
 
RDSHCollectionCheck_PropertyUVHDSettings_IsUserVHDEnabled=Property: UVHD Settings: Is User VHD Enabled:
RDSHCollectionCheck_PropertyUVHDSettings_UserVHDShare=Property: UVHD Settings: User VHD Share:
RDSHCollectionCheck_PropertyUVHDSettings_UserPolicyXML=Property: UVHD Settings: User Policy XML:
RDSHCollectionCheck_PropertyUVHDSettings_DiskSizeInMB=Property: UVHD Settings: Disk Size In MB:
RDSHCollectionCheck_PropertyUVHDSettings_DiskType=Property: UVHD Settings: Disk Type:

RDSHSvcStartedCheck_Title=The Remote Desktop Session Host service must be running on the RD Session Host server.
RDSHSvcStartedCheck_Problem=The Remote Desktop Session Host service is not running on the Remote Desktop Session Host (RD Session Host) server.
RDSHSvcStartedCheck_Impact=If the Remote Desktop Session Host service is not running on the RD Session Host server, users will not be able to connect to the RD Session Host server remotely.
RDSHSvcStartedCheck_Resolution=Use the Services tool to start the Remote Desktop Session Host service on the RD Session Host server.
RDSHSvcStartedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

RDVHSvcStartedCheck_Title=The Remote Desktop Virtualization Host service must be running on the RD Virtualization Host server.
RDVHSvcStartedCheck_Problem=The Remote Desktop Virtualization Host service is not running on the Remote Desktop Virtualization Host (RD Virtualization Host) server.
RDVHSvcStartedCheck_Impact=If the Remote Desktop Virtualization Host service is not running on the RD Virtualization Host server, users will not be able to connect to virtual desktops.
RDVHSvcStartedCheck_Resolution=Use the Services tool to start the Remote Desktop Virtualization Host service on the RD Virtualization Host server.
RDVHSvcStartedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.


RDCBSvcStartedCheck_Title=The Remote Desktop Connection Broker service must be running on the RD Connection Broker server.
RDCBSvcStartedCheck_Problem=The Remote Desktop Connection Broker service is not running on the Remote Desktop Connection Broker (RD Connection Broker) server.
RDCBSvcStartedCheck_Impact=If the Remote Desktop Connection Broker service is not running on the RD Connection Broker server, users will not be able to connect to sessions or virtual desktops.
RDCBSvcStartedCheck_Resolution=Use the Services tool to start the Remote Desktop Connection Broker service on the RD Connection Broker server.
RDCBSvcStartedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

RDWASvcStartedCheck_Title=The IIS service must be running on the RD Web Access server.
RDWASvcStartedCheck_Problem=The Internet Information Services (IIS) service is not running on the Remote Desktop Web Access (RD Web Access) server.
RDWASvcStartedCheck_Impact=If the IIS service is not running on the RD Web Access server, users will not be able to see published applications.
RDWASvcStartedCheck_Resolution=Use the Services tool to start the IIS service on the RD Web Access server.
RDWASvcStartedCheck_Compliant=The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.


'@
