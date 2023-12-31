#
# -----------------------------
# TRANSLATIONS DEFINITION
# -----------------------------
#
data _system_translations {
   ConvertFrom-StringData @'
    # fallback text goes here (optional)
    ###PSLOC start localizing

    #
    # ActivationStatusCheck
    #
    ActivationStatusCheck_Title                        =   The license server must be activated before you can install RDS CALs onto the license server        
    ActivationStatusCheck_Problem_UnRegistered         =   The Remote Desktop license server is not activated, so you cannot install Remote Desktop Services client access licenses (RDS CALs) onto the license server.
    ActivationStatusCheck_Problem_StatusUnknown        =   The Remote Desktop license server Activation Status could not be determined.
    ActivationStatusCheck_Impact                       =   Each user or computing device that connects to a remote desktop server must have a valid RDS CAL issued by a license server. If an activated license server with RDS CALs installed is not available, the remote desktop server may stop accepting connections.
    ActivationStatusCheck_Resolution_UnRegistered      =   Use the RD Licensing Manager tool to activate the license server and then to install RDS CALs onto the license server.
    ActivationStatusCheck_Resolution_StatusUnknown     =   Check if the Remote Desktop Licensing Service is running.
    ActivationStatusCheck_Compliant                    =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
       
    #
    # NumberCAPPoliciesCheck - Rule 3
    #
    NumberCAPPoliciesCheck_Title                       =   The RD Gateway server must have at least one RD CAP enabled
    NumberCAPPoliciesCheck_Problem                     =   The Remote Desktop Gateway (RD Gateway) server does not have a Remote Desktop connection authorization policy (RD CAP) enabled.     
    NumberCAPPoliciesCheck_Impact                      =   If the RD Gateway server does not have an RD CAP enabled, users cannot connect to internal network resources (computers) through the RD Gateway server.
    NumberCAPPoliciesCheck_Resolution                  =   Use the RD Gateway Manager tool to enable an RD CAP to specify which users can use the RD Gateway server to connect to internal network resources (computers).
    NumberCAPPoliciesCheck_Compliant                   =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # NumberRAPPoliciesCheck - Rule 4
    #
    NumberRAPPoliciesCheck_Title                       =   The RD Gateway server must have at least one RD RAP enabled
    NumberRAPPoliciesCheck_Problem                     =   The Remote Desktop Gateway (RD Gateway) server does not have a Remote Desktop resource authorization policy (RD RAP) enabled.
    NumberRAPPoliciesCheck_Impact                      =   If the RD Gateway server does not have an RD RAP enabled, users cannot connect to internal network resources (computers) through the RD Gateway server.
    NumberRAPPoliciesCheck_Resolution                  =   Use the RD Gateway Manager tool to enable an RD RAP to specify the internal network resources (computers) that users can connect to through the RD Gateway server. 
    NumberRAPPoliciesCheck_Compliant                   =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # SSLCertConfiguredCheck - Rule 5
    #
    SSLCertConfiguredCheck_Title                       =   The RD Gateway server must be configured to use a valid SSL certificate
    SSLCertConfiguredCheck_Problem                     =   The Remote Desktop Gateway (RD Gateway) server does not have a valid Secure Sockets Layer (SSL) certificate.
    SSLCertConfiguredCheck_Impact                      =   If the RD Gateway server is configured to use an SSL certificate that is not valid, users cannot connect to internal network resources (computers) through the RD Gateway server. 
    SSLCertConfiguredCheck_Resolution                  =   Use the RD Gateway Manager tool to select a valid SSL certificate for the RD Gateway server to use.
    SSLCertConfiguredCheck_Compliant                   =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # SSLCertIsSelfSignedCheck- Rule 6
    #
    SSLCertIsSelfSignedCheck_Title                     =   RD Gateway must be configured to use an SSL certificate signed by a trusted certification authority 
    SSLCertIsSelfSignedCheck_Problem                   =   The Remote Desktop Gateway (RD Gateway) server is configured to use a self-signed certificate. By default, a self-signed certificate is not trusted by client computers.
    SSLCertIsSelfSignedCheck_Impact                    =   If the RD Gateway server is configured to use a Secure Sockets Layer (SSL) certificate that is not signed by a trusted certification authority, users might be unable to connect to internal network resources (computers) through the RD Gateway server.
    SSLCertIsSelfSignedCheck_Resolution                =   Use the RD Gateway Manager tool to configure the RD Gateway server to use an SSL certificate that is signed by a trusted certification authority. Using a self-signed certificate is not recommended.
    SSLCertIsSelfSignedCheck_Compliant                 =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # NPSServerReachableCheck - Rule 7
    #
    NPSServerReachableCheck_Title                      =   The RD Gateway server must be able to contact the server running NPS  
    NPSServerReachableCheck_Problem                    =   The Remote Desktop Gateway (RD Gateway) server is unable to contact the server running Network Policy Server (NPS) that contains the central Remote Desktop connection authorization policy (RD CAP) store.
    NPSServerReachableCheck_Impact                     =   If the RD Gateway server is unable to contact the server running NPS that contains the central RD CAP store, users cannot connect to internal network resources (computers) through the RD Gateway server.
    NPSServerReachableCheck_Resolution                 =   Ensure that the server running NPS is started and that there is network connectivity between the RD Gateway server and the server running NPS.
    NPSServerReachableCheck_Compliant                  =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # LoadBalancedServerErrorneousCheck - Rule 8
    #
    LoadBalancedServerErrorneousCheck_Title            =   Members of an RD Gateway server farm should be available on the network and configured identically
    LoadBalancedServerErrorneousCheck_Problem          =   At least one Remote Desktop Gateway (RD Gateway) server in the RD Gateway server farm is not available on the network or is not running the same version of the operating system as the other members of the RD Gateway server farm.
    LoadBalancedServerErrorneousCheck_Impact           =   If some of the members of an RD Gateway server farm are not available on the network or are not running the same version of the operating system, users might experience different functionality depending on the RD Gateway server through which they connect.
    LoadBalancedServerErrorneousCheck_Resolution       =   Ensure that all the RD Gateway servers in the RD Gateway server farm are available on the network, are running the same version of the operating system, and are configured identically.
    LoadBalancedServerErrorneousCheck_Compliant        =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # ConnectionsExhaustedCheck - Rule 9
    #
    ConnectionsExhaustedCheck_Title                    =   The RD Gateway server should be configured to allow  an adequate number of simultaneous connections
    ConnectionsExhaustedCheck_Problem                  =   The Remote Desktop Gateway (RD Gateway) server has reached the limit on the maximum number of simultaneous connections allowed.
    ConnectionsExhaustedCheck_Impact                   =   If the RD Gateway server is configured to limit the number of simultaneous connections allowed, users making new connections will be unable to connect to internal network resources (computers) through the RD Gateway server when the limit is exceeded. 
    ConnectionsExhaustedCheck_Resolution               =   Monitor the performance of the RD Gateway server to determine the maximum number of connections that the RD Gateway server can support. If necessary, use the RD Gateway Manager tool to reconfigure the maximum number of simultaneous connections allowed. 
    ConnectionsExhaustedCheck_Compliant                =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # ActiveDirectoryServerRechableCheck - Rule 10
    #
    ActiveDirectoryServerRechableCheck_Title           =   The RD Gateway server must be able to contact Active Directory Domain Services
    ActiveDirectoryServerRechableCheck_Problem         =   An authorization policy on the Remote Desktop Gateway (RD Gateway) server is configured to use an Active Directory security group, but the RD Gateway server is unable to contact Active Directory Domain Services (AD DS).
    ActiveDirectoryServerRechableCheck_Impact          =   If the RD Gateway server is unable to contact AD DS, users cannot be authenticated and the users will be unable to connect to internal network resources (computers) through the RD Gateway server.
    ActiveDirectoryServerRechableCheck_Resolution      =   Ensure that the RD Gateway server is a member of an Active Directory domain and that there is network connectivity between the RD Gateway server and AD DS.
    ActiveDirectoryServerReachableCheckWarning_Title   =   Remote Desktop Services can’t connect to Active Directory.
    ActiveDirectoryServerReachableCheckWarning_Problem =   An authorization policy on the Remote Desktop Gateway (RD Gateway) server is set to use an Active Directory security group, but the Remote Desktop Services Best Practices Analyzer can’t get a list of domain controllers in the current domain.
    ActiveDirectoryServerReachableCheckWarning_Impact  =   If the Remote Desktop Services Best Practices Analyzer can’t get the list of domain controllers, it can’t verify connectivity to Active Directory.
    ActiveDirectoryServerReachableCheckWarning_Resolution = Log on with a domain user account, and then run the Best Practices Analyzer to get a list of domain controllers and to verify connectivity to Active Directory.
    ActiveDirectoryServerRechableCheck_Compliant       =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # WebSiteRunningCheck - Rule 11
    #
    WebSiteRunningCheck_Title                          =   The Web site that the RD Gateway server is configured to use must be started on the Web (IIS) server
    WebSiteRunningCheck_Problem                        =   The Web site that the Remote Desktop Gateway (RD Gateway) server is configured to use is not started on the Web (IIS) server.
    WebSiteRunningCheck_Impact                         =   If the Web site that the RD Gateway server is configured to use is not started on the Web (IIS) server, users cannot connect to internal network resources (computers) through the RD Gateway server.
    WebSiteRunningCheck_Resolution                     =   Use the Internet Information Services (IIS) Manager tool to ensure that the Web site that the RD Gateway server is configured to use is started.
    WebSiteRunningCheck_Compliant                      =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # CAPPolicyIsNonCompliantCheck - Rule 12
    #
    CAPPolicyIsNonCompliantCheck_Title                 =   The RD CAP(s) stored on the server running NPS must be configured correctly to support RD Gateway
    CAPPolicyIsNonCompliantCheck_Problem               =   The Remote Desktop connection authorization policy (with Name[s] {0}) stored on the server running Network Policy Server (NPS) is/are not configured correctly to support connections through the Remote Desktop Gateway (RD Gateway) server.
    CAPPolicyIsNonCompliantCheck_Impact                =   If the RD CAP stored on the server running NPS is not configured correctly, users will be unable to connect to internal network resources (computers) through the RD Gateway server.
    CAPPolicyIsNonCompliantCheck_Resolution            =   Use the Network Policy Server tool to ensure that the RD CAP stored on the server running NPS is configured correctly to support connections through the RD Gateway server.
    CAPPolicyIsNonCompliantCheck_Compliant             =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # NONewConnectinsAllowedCheck - Rule 13
    #
    NONewConnectinsAllowedCheck_Title                  =   The RD Gateway server should be configured to allow new connections
    NONewConnectinsAllowedCheck_Problem                =   The Remote Desktop Gateway (RD Gateway) server is configured to disable new connections.
    NONewConnectinsAllowedCheck_Impact                 =   If the RD Gateway server is configured to disable new connections, no new user connections will be allowed through the RD Gateway server.
    NONewConnectinsAllowedCheck_Resolution             =   Use the RD Gateway Manager tool to configure the RD Gateway server to accept new connections.
    NONewConnectinsAllowedCheck_Compliant              =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # ConenctOnlytoWin7ClientCheck - Rule 14
    #
    ConenctOnlytoWin7ClientCheck_Title                 =   The RD Gateway server should be configured to allow connections from all supported clients
    ConenctOnlytoWin7ClientCheck_Problem               =   The Remote Desktop Gateway (RD Gateway) server is configured to accept only connections from clients using the latest version of the Remote Desktop Connection (RDC) software.
    ConenctOnlytoWin7ClientCheck_Impact                =   If a client computer is not running the latest version of RDC, the user will be unable to connect to internal network resources (computers) through the RD Gateway server.
    ConenctOnlytoWin7ClientCheck_Resolution            =   Use the RD Gateway Manager tool to configure the RD Gateway server to accept connections from all supported versions of RDC.
    ConenctOnlytoWin7ClientCheck_Compliant             =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RDGatewaySvcStartedCheck - Rule 15
    #
    RDGatewaySvcStartedCheck_Title                     =   The Remote Desktop Gateway service must be running on the RD Gateway server
    RDGatewaySvcStartedCheck_Problem                   =   The Remote Desktop Gateway service is not running on the Remote Desktop Gateway (RD Gateway) server. 
    RDGatewaySvcStartedCheck_Impact                    =   If the Remote Desktop Gateway service is not running on the RD Gateway server, users cannot connect to internal network resources (computers) through the RD Gateway server.
    RDGatewaySvcStartedCheck_Resolution                =   Use the Services tool to start the Remote Desktop Gateway service on the RD Gateway server.
    RDGatewaySvcStartedCheck_Compliant                 =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RDPGrpMemberCountCheck
    #
    RDPGrpMemberCountCheck_Title                       =   The Remote Desktop Users group on the RD Session Host server must contain domain users or groups
    RDPGrpMemberCountCheck_Problem                     =   The Remote Desktop Users group on the Remote Desktop Session Host server does not contain any domain users or groups.
    RDPGrpMemberCountCheck_Impact                      =   If the Remote Desktop Users group on the RD Session Host server does not contain domain users or groups, users will not be able to connect to the RD Session Host server.
    RDPGrpMemberCountCheck_Resolution                  =   Use the Remote tab in the System Properties dialog box to add domain users or groups to the Remote Desktop Users group on the RD Session Host server.
    RDPGrpMemberCountCheck_Compliant                   =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    

    #
    # RemoteDesktopDisabledCheck
    #
    RemoteDesktopDisabledCheck_Title                   =   The RD Session Host server should be configured to allow remote desktop connections 
    RemoteDesktopDisabledCheck_Problem                 =   Remote desktop connections to the Remote Desktop Session Host server are disabled.
    RemoteDesktopDisabledCheck_Impact                  =   If remote desktop connections are disabled, users will not be able to connect to the RD Session Host server.
    RemoteDesktopDisabledCheck_Resolution              =   Use the Remote tab in the System Properties dialog box to enable remote desktop connections on the RD Session Host server.
    RemoteDesktopDisabledCheck_Compliant               =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
    #
    # MaxInstanceCountCheck
    #
    MaxInstanceCountCheck_Title                        =   The RD Session Host server should be configured to allow an adequate number of simultaneous connections
    MaxInstanceCountCheck_Problem                      =   The maximum number of simultaneous connections is configured for less than 5 users.
    MaxInstanceCountCheck_Impact                       =   If the maximum number of simultaneous connections is less than the required number of users, some users may not be able to log on to the Remote Desktop Session Host server.
    MaxInstanceCountCheck_Resolution                   =   Increase the maximum number of simultaneous connections by configuring the "Limit number of connections" Group Policy setting.
    MaxInstanceCountCheck_Compliant                    =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.
   
    #
    # AlternateSrvSpecifiedCheck
    #
    AlternateSrvSpecifiedCheck_Title                   =   The alternative server name must be specified for Remote Desktop Connection 6.1 and earlier
    AlternateSrvSpecifiedCheck_Problem                 =   The alternative server name is not specified.
    AlternateSrvSpecifiedCheck_Impact                  =   The alternative server name must be specified if you are using Remote Desktop Connection (RDC) 6.1 and earlier. If it is not specified, RDC 6.1 and earlier clients will not be able to connect.
    AlternateSrvSpecifiedCheck_Resolution              =   The alternative server name is specified by using Remote Desktop Connection Manager on the Remote Desktop Connection Broker server.
    AlternateSrvSpecifiedCheck_Compliant               =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RedirectorAltServerHaveSameIPCheck
    #
    RedirectorAltServerHaveSameIPCheck_Title           =   The alternative server name must resolve to the IP address of the redirection server
    RedirectorAltServerHaveSameIPCheck_Problem         =   The alternative server name does not have a valid DNS entry, or the DNS entry does not resolve to the same IP address as the Remote Desktop Session Host server running in redirection mode.
    RedirectorAltServerHaveSameIPCheck_Impact          =   The alternative server name must resolve to the IP address of the Remote Desktop Session Host server running in redirection mode. If it does not, RDC 6.1 and earlier clients will not be able to connect.
    RedirectorAltServerHaveSameIPCheck_Resolution      =   The alternative server name is specified by using Remote Desktop Connection Manager on the Remote Desktop Connection Broker server.
    RedirectorAltServerHaveSameIPCheck_Compliant       =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # FireWallExceptionEnabledCheck
    #
    FireWallExceptionEnabledCheck_Title                =   The current Windows Firewall profile must be configured to allow remote desktop connections
    FireWallExceptionEnabledCheck_Problem              =   The current Windows Firewall profile is not configured to allow remote desktop connections.
    FireWallExceptionEnabledCheck_Impact               =   Users are not able to connect to the server by using Remote Desktop Connection.
    FireWallExceptionEnabledCheck_Resolution           =   Enable remote desktop connections by using the Windows Firewall console.
    FireWallExceptionEnabledCheck_Compliant            =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # CALAvailableCheck
    #
    CALAvailableCheck_Title                            =   The Remote Desktop license server must have enough RDS CALs installed to allow users and devices to connect
    CALAvailableCheck_Problem                          =   There are not enough Remote Desktop Services client access licenses (RDS CALs) installed to allow users and devices to connect to the Remote Desktop Session Host server.
    CALAvailableCheck_Impact                           =   Some users or devices may not be able to connect to the Remote Desktop Session Host server.
    CALAvailableCheck_Resolution                       =   Install more Remote Desktop Services client access licenses by using Remote Desktop Licensing Manager.
    CALAvailableCheck_Compliant                        =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #	
    # SSLCertNameIsFQDN
    #
    SSLCertNameIsFQDNCheck_Title                       =   The RD Gateway server SSL certificate must be configured with a valid certificate subject name
    SSLCertNameIsFQDNCheck_Problem                     =   The Remote Desktop Gateway (RD Gateway) server Secure Sockets Layer (SSL) certificate may not have a valid certificate subject name.
    SSLCertNameIsFQDNCheck_Impact                      =   If the RD Gateway server is configured to use an SSL certificate with a certificate subject name that is not valid, users cannot connect to internal network resources (computers) through the RD Gateway server. 
    SSLCertNameIsFQDNCheck_Resolution                  =   Use the RD Gateway Manager tool to select a valid SSL certificate for the RD Gateway server to use.
    SSLCertNameIsFQDNCheck_Compliant                   =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
    # RDSHCollectionCheck
    #
    RDSHCollectionCheck_Title                          =   All the RDSH Servers in a collection must be homogenous.
    RDSHCollectionCheck_Problem                        =   Some RDSH Servers in a collection may not be homogenous. Please take a look at the below report. {0}
    RDSHCollectionCheck_Impact                         =   If the RDSH servers in a collection are not homogenous then undesired side effects can happen.
    RDSHCollectionCheck_Resolution                     =   Use the RDMS console to maintain homogeneity across all settings in RDSH servers of a collection.
    RDSHCollectionCheck_Compliant                      =   The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    RDSHCollectionCheck_Collection                     =   Collection: 
    RDSHCollectionCheck_HeterogeneousServers           =   Non-homogeneous servers: 
    RDSHCollectionCheck_MoreInformation                =   See below for more information: 
    RDSHCollectionCheck_ExpectedPropertyValues         =   Collection expected property values: 
    RDSHCollectionCheck_Server=Server: 

    #
    # RDSH Collection Properties
    #
    RDSHCollectionCheck_PropertyUserGroup                               = Property: User Group:

    RDSHCollectionCheck_PropertyConnections_DisconnectedSessionLimit    = Property: Connections: Disconnection Session Limit: 
    RDSHCollectionCheck_PropertyConnections_ActiveSessionLimit          = Property: Connections: Active Session Limit: 
    RDSHCollectionCheck_PropertyConnections_IdleSessionLimit            = Property: Connections: Idle Session Limit: 
    RDSHCollectionCheck_PropertyConnections_BrokenConnectionAction      = Property: Connections: Broken Connection Action: 
    RDSHCollectionCheck_PropertyConnections_EnableAutomaticReconnection = Property: Connections: Enable Automatic Reconnection: 
    RDSHCollectionCheck_PropertyConnections_DeleteTempFoldersOnExit     = Property: Connections: Delete Temp Folders On Exit: 
    RDSHCollectionCheck_PropertyConnections_UseTempFoldersPerSession    = Property: Connections: Use Temp Folders Per Session: 
 

    RDSHCollectionCheck_PropertySecurity_SecurityLayer                  = Property: Security: Security Layer: 
    RDSHCollectionCheck_PropertySecurity_EncryptionLevel                = Property: Security: Encryption Level: 
    RDSHCollectionCheck_PropertySecurity_AuthenticateUsingNLA           = Property: Security: Authenticate Using NLA:

    RDSHCollectionCheck_PropertyClientSettings_DeviceRedirectionOptions = Property: Client Settings: Device Redirection Options:
    RDSHCollectionCheck_PropertyClientSettings_RedirectClientPrinter    = Property: Client Settings: Redirect Client Printer:
    RDSHCollectionCheck_PropertyClientSettings_SetClientPrinterAsDefault= Property: Client Settings: Set Client Printer As Default:
    RDSHCollectionCheck_PropertyClientSettings_UserRDEasyPrintDriver    = Property: Client Settings: Use RD Easy Print Driver:
    RDSHCollectionCheck_PropertyClientSettings_MaxMonitors              = Property: Client Settings: Max Monitors:
 
    RDSHCollectionCheck_PropertyUVHDSettings_IsUserVHDEnabled           = Property: UVHD Settings: Is User VHD Enabled:
    RDSHCollectionCheck_PropertyUVHDSettings_UserVHDShare               = Property: UVHD Settings: User VHD Share:
    RDSHCollectionCheck_PropertyUVHDSettings_UserPolicyXML              = Property: UVHD Settings: User Policy XML:
    RDSHCollectionCheck_PropertyUVHDSettings_DiskSizeInMB               = Property: UVHD Settings: Disk Size In MB:
    RDSHCollectionCheck_PropertyUVHDSettings_DiskType                   = Property: UVHD Settings: Disk Type:
    
    RDSHSvcStartedCheck_Title                                           = The Remote Desktop Session Host service must be running on the RD Session Host server.
    RDSHSvcStartedCheck_Problem                                         = The Remote Desktop Session Host service is not running on the Remote Desktop Session Host (RD Session Host) server.
    RDSHSvcStartedCheck_Impact                                          = If the Remote Desktop Session Host service is not running on the RD Session Host server, users will not be able to connect to the RD Session Host server remotely.
    RDSHSvcStartedCheck_Resolution                                      = Use the Services tool to start the Remote Desktop Session Host service on the RD Session Host server.
    RDSHSvcStartedCheck_Compliant                                       = The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    RDVHSvcStartedCheck_Title                                           = The Remote Desktop Virtualization Host service must be running on the RD Virtualization Host server.
    RDVHSvcStartedCheck_Problem                                         = The Remote Desktop Virtualization Host service is not running on the Remote Desktop Virtualization Host (RD Virtualization Host) server.
    RDVHSvcStartedCheck_Impact                                          = If the Remote Desktop Virtualization Host service is not running on the RD Virtualization Host server, users will not be able to connect to virtual desktops.
    RDVHSvcStartedCheck_Resolution                                      = Use the Services tool to start the Remote Desktop Virtualization Host service on the RD Virtualization Host server.
    RDVHSvcStartedCheck_Compliant                                       = The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.


    RDCBSvcStartedCheck_Title                                           = The Remote Desktop Connection Broker service must be running on the RD Connection Broker server.
    RDCBSvcStartedCheck_Problem                                         = The Remote Desktop Connection Broker service is not running on the Remote Desktop Connection Broker (RD Connection Broker) server.
    RDCBSvcStartedCheck_Impact                                          = If the Remote Desktop Connection Broker service is not running on the RD Connection Broker server, users will not be able to connect to sessions or virtual desktops.
    RDCBSvcStartedCheck_Resolution                                      = Use the Services tool to start the Remote Desktop Connection Broker service on the RD Connection Broker server.
    RDCBSvcStartedCheck_Compliant                                       = The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    RDWASvcStartedCheck_Title                                           = The IIS service must be running on the RD Web Access server.
    RDWASvcStartedCheck_Problem                                         = The Internet Information Services (IIS) service is not running on the Remote Desktop Web Access (RD Web Access) server.
    RDWASvcStartedCheck_Impact                                          = If the IIS service is not running on the RD Web Access server, users will not be able to see published applications.
    RDWASvcStartedCheck_Resolution                                      = Use the Services tool to start the IIS service on the RD Web Access server.
    RDWASvcStartedCheck_Compliant                                       = The Remote Desktop Services Best Practices Analyzer scan has determined that you are in compliance with this best practice.

'@
}
Import-LocalizedData -BindingVariable _system_translations -filename TerminalServices.psd1

#
# ----------------------
# CUSTOM DATA STRUCTURES
# ----------------------
#
Add-Type -TypeDefinition @"

public struct ConnectionsType
{
    public int    DisconnectedSessionLimit;
    public int    ActiveSessionLimit;
    public int    IdleSessionLimit;
    public int    BrokenConnectionAction;
    public int    EnableAutomaticReconnection;
    public int    DeleteTempFoldersOnExit;
    public int    UseTempFoldersPerSession;

}

public struct SecurityType
{
    public int    SecurityLayer;
    public int    EncryptionLevel;
    public int    AuthenticateUsingNLA;
}

public struct ClientSettingsType
{
    public int    DeviceRedirectionOptions;
    public int    RedirectClientPrinter;
    public int    SetClientPrinterAsDefault;
    public int    UseRDEasyPrintDriver;
    public int    MaxMonitors;
}

public struct UVHDSettingsType
{
    public int    IsUVHDEnabled;
    public string UVHDShare;
    public string UserPolicyXML;
    public int    DiskSizeInMB;
    public int    DiskType;
}

public struct RDSHCollectionPropertiesType
{
    public string[]           UserGroups;
    public ConnectionsType    Connections;
    public SecurityType       Security;
    public ClientSettingsType ClientSettings;
    public UVHDSettingsType   UVHDSettings;
}
"@

$NewLine = [Environment]::NewLine


#
# ------------------
# FUNCTIONS - START
# ------------------
#

#
# An implimentation of try..catch..finally
#
function Try
{
    param
    (
        [ScriptBlock]$Command = $(throw "The parameter -Command is required."),
        [ScriptBlock]$Catch   = { throw $_ },
        [ScriptBlock]$Finally = {}
    )
    
    & {
        $local:ErrorActionPreference = "SilentlyContinue"
        
        trap
        {
            trap
            {
                & {
                    trap { throw $_ }
                    &$Finally
                }
                
                throw $_
            }
            
            $_ | & { &$Catch }
        }
        
        &$Command
    }

    & {
        trap { throw $_ }
        &$Finally
    }
}

#
# Function Description:
#
#  Convert true false value to number
#
function BoolToNum ( $BoolVal )
{
    $NumVal = 0

    if ( $BoolVal -eq $true )
    {
        $NumVal = 1
    }

    $NumVal
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
    [xml] "<$name xmlns='$ns'/>"
}

#
# Function Description:
#
#  Adds the specified element in the element hierarchy specified
#  as variable number of arguments
#
# Arguments:
#
#  $docElem - The Document Element for the XML Document
#  $tns - Namespace
#  $elemData - The data value of the element to be added
#  Variable Args - Specifies the hierarchy of elements
#
# Return Value:
#
#  None
#
function AddElementToDocument ( $docElem, $tns, $elemData )
{
    $numLevels = $args.length
    $parent = $docElem.DocumentElement
    
    #
    # Iterate over the elements hierarchy specified. For each level
    # if it doesnt exist, create it.
    # 
    for ( $i=0; $i -lt $numLevels; $i++ )
    {
        #
        # current element in hierarchy
        # 
        $currName = $args[$i]

        if ( $parent.$currName -eq $null )
        {
            #
            # Create a new element since it doesnt exist and add it to the parent
            # to maintain relationship
            #
            $currElem = $docElem.CreateElement( $currName, $tns )
            [void] $parent.AppendChild( $currElem )
        }
        
        #
        # Iterate to the next element in hierarchy
        #
        $parent = $parent[$currName]
    }
    
    #
    # This element is the one that needs to be set the data
    #
    $currElem.InnerText = $elemData
}

#
# Function Description:
#
#  Appends the specified element to the target
#

function Append-Elements( $doc, $target, $ns, $name, $objs )
{
    foreach ($obj in $objs) {
        $parent = $doc.CreateElement( $name, $ns )
        $propnames = $obj | gm -type NoteProperty | foreach {$_.name}
        foreach ($propname in $propnames) {
            if ($propname) {
                  $child = $doc.CreateElement( $propname, $ns )
                  $child.set_InnerText( $obj.$propname )
                  [void] $parent.AppendChild( $child )
            }
        }
        [void] $target.AppendChild( $parent )

    }
}

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
function RoleQueryInitialize
{
    Import-Module ServerManager
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
function RoleQueryShutdown
{
    Remove-Module ServerManager
}

#
# Function Description:
#
#  This function will check to see if the specified role is installed
#
# Arguments:
#
#  $roleId - Id of the Role 
#
# Return Value:
#
#  $true - If Role is Installed
#  $false - If Role is not Installed
#
function IsRoleInstalled ( $roleId )
{
    $roleInstalled = $false
    
    #
    # Use the Server Manager CmdLet to obtain detail about Role
    #
    $Role = Get-WindowsFeature -Name $roleId
    if ( $Role -ne $null ) 
    {
        $roleInstalled = $Role.Installed
    }

    $roleInstalled
}


#
# Function Description:
#
#  This function will check to see if the specified service is running
#
# Arguments:
#
#  $Service - Service which needs to be queried
#
# Return Value:
#
#  $true - If service is running
#  $false - If service is not running
#

function IsServiceRunning($Service)
{
    $Svc = $null
    $SvcRunning = $false

    $Svc = get-Service $Service
    
    if ( $Svc -ne $null )
    {
        $status = $Svc.Status

        if ( $status -eq "Running" )
        {
            $SvcRunning = $true
        }

    }
    
    $SvcRunning

}

#
# Function Description:
#
#  This function will count the number of users in the specified group
#
# Arguments:
#
#  $groupName - Name of the User Group
#
# Return Value:
#
#  Count of the number of members in the specified group
#
function CountUsersInGroup ( $groupName )
{
    $countUsers = 0
    
    #
    # Set the Domain to the Local computer name obtained using $env:COMPUTERNAME
    #
    $domain = $env:COMPUTERNAME
    
    #
    # Set up the WMI Query Filter
    #
    $queryFilter = "GroupComponent=`"Win32_Group.Domain='$domain',Name='$groupName'`""
    
    #
    # Make the WMI call to get list of users
    #
    [Object[]] $users = Get-WmiObject Win32_GroupUser -filter $queryFilter
    
    #
    # if $users is $null then the number of users is 0
    #
    if ( $users -eq $null ) 
    {
        $countUsers = 0
    } 
    else
    {
        $countUsers = $users.Count
    }
    
    #
    # Return count of users
    #
    $countUsers
}

#
# Function Description:
#
#  This function will count the number of instances of the specified WMI class
#  in the specified WMI namespace
#
# Arguments:
#
#  $wmiClassName - Name of the WMI Class
#  $wmiNamespace - Name of the WMI Namespace
#
# Return Value:
#
#  Count of instances of WMI class
#
function CountOfWMIClassInstance ( $wmiClassName, $wmiNamespace )
{
    $countInstances = 0
    

    Try {    
        #
        # Make the WMI call to get instances of WMI class
        #
        [Object[]] $instances = Get-WmiObject $wmiClassName -namespace $wmiNamespace
    } Catch { 
       #Nothing
    }
    
    #
    # if $instances is $null then the number of instances is 0
    #
    if ( $instances -eq $null )
    {
        $countInstances = 0
    }
    else
    {
        $countInstances = $instances.Count
    }
    
    #
    # Return count of instances
    #
    $countInstances        
}


#
# Function Description:
#
#  This function will count the number of instances of the specified WMI class with Enabled = $true
#  in the specified WMI namespace
#
# Arguments:
#
#  $wmiClassName - Name of the WMI Class
#  $wmiNamespace - Name of the WMI Namespace
#
# Return Value:
#
#  Count of instances of WMI class
#
function CountOfEnabledWMIClassInstance ( $wmiClassName, $wmiNamespace )
{
    $countInstances = 0
    
    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [Object[]] $instances = Get-WmiObject $wmiClassName -namespace $wmiNamespace | where-object {$_.Enabled -eq $true}
    } Catch { 
       #Nothing
    }
    
    #
    # if $instances is $null then the number of instances is 0
    #
    if ( $instances -eq $null )
    {
        $countInstances = 0
    }
    else
    {
        $countInstances = $instances.Count
    }
    
    #
    # Return count of instances
    #
    $countInstances        
}

#
# Function Description:
#
#  This function gets the OS Version of the computer $compName in x.y format
#

function GetOSVersionComp (  $compName )
{
    $ver = $null

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        $instanceOSClass = Get-WmiObject "Win32_OperatingSystem" -namespace "root\cimv2" -computername $compName -ErrorAction silentlycontinue  
    } Catch { 
       #Nothing
    }

    $str = $null

   if ( $instanceOSClass -ne $null )
   {
       $ret = $null
       $ret = $instanceOSClass.Version

       if ( $ret -ne $null )
       {
           $val = $ret.Split('.')
           if ( $val.count -ge 2)
           {
               $str = $val[0] + "." + $val[1]
           }
           else
           {
               $str = $ret
           }
       }
   }
 
   $str    
}

#
# Function Description:
#
#  This function will checkif TS Gateway is using Central CAP store
#

function IsCentralCAPEnabled ()
{
    $usesCentralCAPStore = $false
    
    #
    # Make the WMI call to get instances of WMI class
    #
    [Object] $ServerSettingsInstance = Get-WmiObject "Win32_TSGatewayServerSettings" -namespace "root\CIMV2\TerminalServices"
    
    #
    # if $ServerSettingsInstance is $null then the number of instances is 0
    #
    if ( $ServerSettingsInstance -eq $null )
    {
        $usesCentralCAPStore = $false
    }
    else
    {
        $usesCentralCAPStore = $ServerSettingsInstance.CentralCAPEnabled
    }
    
    #
    # Return count of instances
    #
    $usesCentralCAPStore        
}

#
# Function Description:
#
#  This function will check if TS Gateway allows unlimited conenctions
#

function UnlimitedconnectionsSettingTSG ()
{
    $unlimitedconnectionsAllowed = $false
    
    #
    # Make the WMI call to get instances of WMI class
    #
    [Object] $ServerSettingsInstance = Get-WmiObject "Win32_TSGatewayServerSettings" -namespace "root\CIMV2\TerminalServices"
    
    #
    # if $ServerSettingsInstance is $null then the number of instances is 0
    #
    if ( $ServerSettingsInstance -eq $null )
    {
        $unlimitedconnectionsAllowed = $false
    }
    else
    {
        $unlimitedconnectionsAllowed = $ServerSettingsInstance.UnlimitedConnections
    }
    
    #
    # Return count of instances
    #
    $unlimitedconnectionsAllowed        
}

#
# Function Description:
#
#  This function returns the maximum connections allowed by the TSG
#

function NumberConnectionsAllowedByTSG ()
{
    $maxConnectionsAllowed = 0
    
    #
    # Make the WMI call to get instances of WMI class
    #
    [Object] $ServerSettingsInstance = Get-WmiObject "Win32_TSGatewayServerSettings" -namespace "root\CIMV2\TerminalServices"
    
    #
    # if $ServerSettingsInstance is $null then the number of instances is 0
    #
    if ( $ServerSettingsInstance -eq $null )
    {
        $maxConnectionsAllowed = 0
    }
    else
    {
        $maxConnectionsAllowed = $ServerSettingsInstance.MaxConnections
    }
    
    #
    # Return count of instances
    #
    $maxConnectionsAllowed        
}

#
# Function Description:
#
#  This function checks if maximum number of connections has  been
#  exhausted to the TSG
#

function TSGConnectionsExhausted ( $MaxConnectionsAllowed )
{
    $connectionsExhausted = $false

    $numberConnections = CountOfWMIClassInstance "Win32_TSGatewayConnection" "root\CIMV2\TerminalServices"

    if ( $numberConnections -ge $MaxConnectionsAllowed )
    {
        $connectionsExhausted = $true
    }
    else
    {
        $connectionsExhausted = $false
    }
    
    $connectionsExhausted
}

#
# Function Description:
#
#  Returns true if a computer is rechable (can ping to it)
#

function IsComputerReachable ( $computerName )
{
    $pingcount = 0

    $computerRechable = $false
    
    #
    # Make the ping call
    #
    $pingCount =  (ping "$computerName"  | select-string "time[=|<]" ).count

    if ( $pingCount -ge 1 )
    {
        $computerRechable = $true
    }
    
    $computerRechable        
}

#
# Function Description:
#
#  Returns the value of $valueName from registry $keyPath
#
function GetValueFromRegistry ( $keyPath, $valueName )
{

    $value = $null

    $rpcRegKeyPath = "$keyPath"

    $regKeys = Get-ItemProperty $rpcRegKeyPath | get-member -membertype noteproperty | select-object name,Definition

    foreach ( $key in $regKeys)
    {
        if ( $key.name -eq $valueName )
        {
            $regKey = $key
            break
        }
    }

    if ($regKey -ne $null )
    {
        $webSiteDef = $regKey.Definition
        if ( $webSiteDef -ne $null )
        {
            $strings = $webSiteDef.split("=")
            if ($strings.Length -eq 2)
            {
                $value = $strings[1]
            }
        }
    }

    $value
}


#
# Function Description:
#
#  Returns true if the site  $site has the application $app in it
#  false otherwise
#
function IsSiteRuning ( $webSiteName )
{
    $siteRuning = $false

    $winDir = $env:windir

    $op = [System.Reflection.Assembly]::LoadFile("$winDir\System32\inetsrv\Microsoft.Web.Administration.dll")

    $mgr = new-object Microsoft.Web.Administration.ServerManager

    if ( $mgr -ne $null )
    {
        $webSite = GetWebSite -sites:$mgr.Sites -siteName:$webSiteName

        if ( $webSite -ne $null )
        {
            $state = $webSite.state

            if ( $state -eq "Started")
            {
                $siteRuning = $true
            }
        }
    }

    $siteRuning
}

#
# Function Description:
#
#  Returns the corresponding site object from the list of given sites and site name
#
function GetWebSite ( $sites, $siteName )
{
    $site = $null

    foreach ( $tmpSite in $sites )
    {
        if ( $tmpSite.Name -eq $siteName )
        {
            $site = $tmpSite
            break
        }
    }

    $site
}

#
# Function Description:
#
#  Returns true if the site  $site has the application $app in it
#  false otherwise
#
function IsApplicationInSiteConfigured ( $command, $site, $app )
{
    $appConfigd = $false

    $op = & $command List config "$site" -section:"system.applicationHost/sites"

    if ( $op -ne $null )
    {
        $str = "application path=""/$app"""

        $res = $op -clike "*$str*"

        if ( ( $res -eq $null ) -or ( $res.Length -le 0) )
        {
            $appConfigd = $false
        }
        else
        {
            $appConfigd = $true 
        }        
    }

    $appConfigd
}


#
# Function Description:
#
#  Returns 1 if value of reg key "HKLM:\SOFTWARE\Microsoft\Terminal Server Gateway\Authorization plug-ins"
#  is not native, 0 if native and 2 if nothing is configured in this key 
#
function IsAuthorizationPlugginNonNative ()
{
    $retVal = 2

    $keyName = "(default)"

    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Terminal Server Gateway\Authorization plug-ins"
 
    $keyVal =  Get-ItemProperty $RegKeyPath -name $keyName

    if ( $keyVal -ne $null )
    {
        $val = $keyVal.$keyName

        $KeyValLen = $val.Length

        if ( $KeyValLen -ge 1)
        {
            $valLower = $val.ToLower()

            if ( $valLower -eq "native")
            {
                $retVal = 0
            }
            else
            {
                $retVal = 1
            }
        }
    }

    $retVal
}

#
# Function Description:
#
#  Checks if any of the NPs servers configured are rechable
#

function GetNPSServers ( )
{
    $serverNames = @()

    [Object[]] $instances = Get-WmiObject "Win32_TSGatewayRADIUSServer" -namespace "root\CIMV2\TerminalServices"

    if ( $instances.count -eq 0 )
    {
        $rechableServerName = $null
    }
    else
    {
        $serverRechable = $false

        Foreach ( $i in $instances )
        {
            $serverNames += @($i.Name)
        }
    }

    $serverNames
}


#
# Function Description:
#
#  Returnes the SSL certificate (if configured) fot the website $webSiteName
#
function GetCertForWebsite ( $webSiteName )
{
    $winDir = $env:windir

    $certForWebPage = $null

    $op = [System.Reflection.Assembly]::LoadFile("$winDir\System32\inetsrv\Microsoft.Web.Administration.dll")

    $mgr = new-object Microsoft.Web.Administration.ServerManager

    if ( $mgr -ne $null )
    {
        $webSite = GetWebSite -sites:$mgr.Sites -sitename:$webSiteName

        if ( $webSite -ne $null)
        {
            $certHash = $null

            foreach ($binding in $webSite.Bindings)
            {
                if (($binding.EndPoint -ne $null) -and ($binding.EndPoint.Port -eq 443))
                {
                    if ($binding.UseDsMapper -eq $true)
                    {
                        $certHash = $binding.CertificateHash;
                        $certStore = $binding.CertificateStoreName 
                    }
                    break;
                }
            }

            if ( $certHash -ne $null )
            {
                $certList = Get-item -path cert:LocalMachine\$certStore\*
                $numCerts = $certList.Length

                $len = $certHash.count
             
                foreach ( $cert in $certList)
                {
                    $certHashcurr = $cert.GetCertHash()

                    $lenCurr = $certHashcurr.count

                    if ( $len -eq $lenCurr)
                    {
                        $match = $true

                        $limit = $len - 1

                        for ( $i=0; $i -le $limit; $i+=1)
                        {
                            $num1 = $certHashcurr[$i]
                            $num2 = $certHash[$i]
                            if ( $num1 -ne $num2)
                            {
                                $match = $false
                                break
                            }
                        }
 
                        if ( $match -eq $true )
                        {
                            $certForWebPage = $cert
                            break
                        } 
                    }
                }
            }
        }
    }

    $certForWebPage
}

#
# Function Description:
#
#  Returnes 1 if subject matches FQDN, 2 if it matches netbios name 0 otherwise
#
function FindDomainFromIPConfig()
{
    $ipconfiginfo = $null

    $ipconfiginfo = ipconfig /all

    $domInf = $null

    $domNm = $null

    if ($ipconfiginfo -ne $null)
    {
        $domInf = $ipconfiginfo  | select-string "Primary Dns Suffix"

        $domInfStr = $domInf.ToString()

        $vals = $null
   
        if ( $domInfStr -ne $null )
        {
            $vals = $domInfStr.split(':')

            if ( $vals.Count -ge 2 )
            {
                $domNm = $vals[1]
               $domNm = $domNm.trim()
            }
        }
    }

    $domNm    
}

#
# Function Description:
#
#  This is a helper function for function GetSubjAltNames
#  This takes in a string (can be multi-line) and returns the DNS names (as an array) in it 
#  (strings starting with "DNS Name=")
#
function ScanStringForNames ( $stringToScan )
{
    $list = @()
    
    $strLookinFor = "DNS Name="
    $endStr = "`r`n"

    $strlenInpStr = $stringToScan.Length
 
    $loopEnd = $false

    $postostartLookin = 0
 
    while ( $postostartLookin -lt $strlenInpStr )
    {
        $posBegin = -1
        $endPos = -1

        $subStr = $null

        $posBegin = $stringToScan.IndexOf( $strLookinFor, $postostartLookin )

        if ( $posBegin -gt -1)
        {
            $endPos = $stringToScan.IndexOf( $endStr, $posBegin )

            $startTrimPos = $posBegin + $strLookinFor.Length
             
            if ( $endPos -gt $posBegin )
            {
                $lenToCut = $endPos - $startTrimPos
                $subStr = $stringToScan.SubString( $startTrimPos, $lenToCut )

            }
            else
            {
                $subStr = $stringToScan.SubString( $startTrimPos )
            }
            
            $subStrLen = $subStr.Length

            $postostartLookin = $posBegin + $subStrLen

            $list += @($subStr)
        }
        else
        {
            $postostartLookin = $strlenInpStr
        }
    }

    $list
}

#
# Function Description:
#
# This is a helper function for function GetIPADDRList
# Recieves the certificate as a string and scans for the section containing SAN's
# the section starts with the heading "Subject Alternative Name(2.5.29.17)"
# The function returns all the DNS names found in the cert as an array
#
function GetSubjAltNames ( $cert )
{
    $extns = $cert.Extensions
    
    $list = @()

    foreach ($extn in $extns)
    {
        if ( $extn -eq $null)
        {
            break
        }

        $str = $extn.Format($true)
        if ( $str -clike "DNS Name=*")
        {
            $nameList = ScanStringForNames ($str)

            foreach ($name in $nameList)
            {
                $list += @($name)
            }
        }
    }

    $list
}

#
# Function GetIPADDRList
#
# Returns the IP Addresses as a list for the provided machine
#
function GetIPADDRList ( $machineName )
{
    $ipAddLst = @()

    if ( ( $machineName -ne $null ) -and ( $machineName.Length -gt 0 ) )
    {

        $colItems = GWMI -cl "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $machineName -filter "IpEnabled = TRUE"

        foreach ( $objItem in $colItems )
        {
            $ipAddListItem = $objItem.IPAddress

            foreach ( $item in $ipAddListItem )
            {
                $ipAddLst += @($item)
            }
        }
    }

    $ipAddLst
}


#
# Function GetIPADDRFfromDNS
#
# Returns the IP Addresses as a list for the provided name from nslookup query
#
function GetIPADDRFfromDNS ( $name )
{
    $addrLst = @()

    if ( ( $name -ne $null) -and ( $name.Length -gt 0 ) )
    {
        $errStr = $null

        $op = ""

        $opList = & nslookup $name 2> $errStr

        foreach ( $item in $opList )
        {
           $op += $item + "`r`n"
        }

        $strToMatch = "*$name`r`nAddress*"

        $strAddress1 = "Address:"
        $strAddress2 = "Addresses:"

        $res = $false
        $res = $op -like $strToMatch


        if ( $res -eq $true )
        {
            $posOfName = -1
            $posOfAddress = -1

            $posOfName = $op.IndexOf($name)

            if ( $posOfName -ge 0 )
            {
                $posToLookFrom = $posOfName + $name.Length
                $posOfAddress = $op.IndexOf($strAddress1, $posToLookFrom)
                $lenOfAddrStr = $strAddress1.Length

                if ( $posOfAddress -le $posToLookFrom )
                {
                    $posOfAddress = $op.IndexOf($strAddress2, $posToLookFrom)
                    $lenOfAddrStr = $strAddress2.Length
                }

                if ( $posOfAddress -gt $posToLookFrom )
                {
                    $subStr = $null

                    $posToCutFrom = $posOfAddress + $lenOfAddrStr

                    $subStr = $op.SubString($posToCutFrom)

                    $splitStrs = $subStr.Split("`r`n")

                    foreach ($str in $splitStrs)
                    {
                        $strTmp = $null
                        $strTmp = $str.Trim()
                
                        if ( ($strTmp -ne $null) -and ( $strTmp.Length -gt 0 ) )
                        {
                            $addrLst += @($strTmp)
                        }
                    }
                }
            }
        }
    }
    $addrLst
}


#
# Funciton IsCommonItemInLists
# Returns true if there is at least one comon item in the two lists
#
function IsCommonItemInLists ( $list1, $list2 )
{
    $found = $false

    if ( ( ( $list1 -ne $null ) -and ( $list2 -ne $null ) ) -and ( ( $list1.Count -gt 0 ) -and ( $list2.count -gt 0 ) ) )
          
    {
        foreach ( $item in $list1 )
        {
            foreach ( $itemInner in $list2 )
            {
                if ( $item -eq $itemInner )
                {
                    $found = $true
                    break
                }
            }

            if ( $found -eq $true )
            {
                break
            }
        }
    }

    $found
}

#
# Function Description:
#
#  Returns 1 if subject(or SAN) matches FQDN, 2 if it matches netbios name ,
#  1 if there is a common ip address in the list of IP's for the certificate subject
#  and the machine and 0 otherwise
#
function CheckIfCertSubjectMatchesCurrentMachineName ( $certToCheck )
{
    $match = 0
    $domains = get-wmiobject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property DNSDomain

    $machineNetBios = $env:ComputerName
        
    $lookinFor = "CN="

    $strVal = $certToCheck.Subject

    $vals = $strVal.Split(",")

    $certSubj = $null

    foreach ( $val in $vals)
    {
        $val1 = $val.TrimStart(" ")
    
        $boolVal = $val1.StartsWith($lookinFor)
        if ( $boolVal -eq $true)
        {
            $certSubj = $val1.TrimStart($lookinFor)
            break
       }
    }

    $domNotFound = $true

    $ipAddressesForLocalMacine = $null

    $ipListForCertSubject = $null

    $ipAddressesForLocalMacine = GetIPADDRList ( $machineNetBios )

    foreach ( $domain in $domains )
    {
        $domainStr = $domain.DNSDomain

        if ( $domainStr -ne $null )
        {
            $domNotFound = $false

            $FQDN = "$machineNetBios.$domainStr"

            if ( $certSubj -eq $FQDN ) 
            {
                $match = 1
                break
            }
        }
    }

    if ( $domNotFound -eq $true )
    {
        $domName = $null

        $domName = FindDomainFromIPConfig

        $FQDN = "$machineNetBios.$domName"

        if ( $certSubj -eq $FQDN ) 
        {
            $match = 1
        }
    }
    
    if ( $match -eq 0 )
    {
        if ( $machineNetBios -eq $certSubj )
        {
            $match = 2
        }
        else
        {
            $ipListForCertSubject = $null
            $ipListForCertSubject = GetIPADDRFfromDNS ( $certSubj )

            $found = $false

            $found = IsCommonItemInLists -list1:($ipAddressesForLocalMacine) -list2:($ipListForCertSubject)

            if ( $found -eq $true )
            {
                $match = 1
            }
        }
    }

    if ( ( $match -eq 0 ) -or ( $match -eq 2 ) )
    {
        $certSANNameArr = GetSubjAltNames $certToCheck

        if ( $certSANNameArr -ne $null)
        {
            foreach ( $certSANName in $certSANNameArr )  
            {   
                $domNotFound = $true

                foreach ( $domain in $domains )
                {
                    $domainStr = $domain.DNSDomain
    
                    if ( $domainStr -ne $null )
                    {
                        $domNotFound = $false

                        $FQDN = "$machineNetBios.$domainStr"

                        if ( $certSANName -eq $FQDN ) 
                        {
                            $match = 1
                            break
                        }
                    }
                }

                if ( $domNotFound -eq $true )
                {
                    $domName = $null

                    $domName = FindDomainFromIPConfig

                    $FQDN = "$machineNetBios.$domName"

                    if ( $certSANName -eq $FQDN ) 
                    {
                        $match = 1
                    }
                }

                if ( $match -eq 1 )
                {
                    break
                }

                if ( $match -eq 0 )
                {
                   if ( $machineNetBios -eq $certSANName )
                   {
                       $match = 2
                   }
                   else
                   {
                       $ipListForCertSubject = $null
                       $ipListForCertSubject = GetIPADDRFfromDNS ( $certSANName )

                       $found = $false

                       $found = IsCommonItemInLists -list1:($ipAddressesForLocalMacine) -list2:($ipListForCertSubject)

                       if ( $found -eq $true )
                       {
                           $match = 1
                           break
                       }
                   }
               }
           }
       }
    }

    $match
}


#
# Function Description:
#
#  Returnes 1 if cert is Self Signed Cert 0 otherwise
#
function CheckIfCertIsSelfSigned ( $certToCheck )
{
    $match = 0
    $domains = get-wmiobject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property DNSDomain

    $machineNetBios = $env:ComputerName
        
    $certSubj = ($certToCheck.Issuer.Split("="))[1]

    foreach ( $domain in $domains )
    {
        $domainStr = $domain.DNSDomain

        $FQDN = "$machineNetBios.$domainStr"

        if ( $certSubj -eq $FQDN ) 
        {
            $match = 1
            break
        }
    }

    if ( $match -eq 0 )
    {
        $domName = $null

        $domName = FindDomainFromIPConfig

        $FQDN = "$machineNetBios.$domName"

        if ( $certSubj -eq $FQDN ) 
        {
            $match = 1
        }
    }
    
    if ( $match -eq 0 )
    {
        if ( $machineNetBios -eq $certSubj )
        {
            $match = 1
        }
    }

    $match
}

#
# Function Description:
# Returns if value in HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\TerminalServerGateway\Config\Core\OnlyConsentCapableClients
# is 1, returns 0 otherwise
#
function IsConenctOnlyToWin7clientsSet ( )
{
    $keyName = "OnlyConsentCapableClients"
    $RegKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\TerminalServerGateway\Config\Core"

    $retVal = $false

    $keyVal =  Get-ItemProperty $RegKeyPath -name $keyName

    if ( $keyVal -ne $null )
    {
        $val = $keyVal.$keyName

        if ( $val -eq 1)
        {
            $retVal = $true
        }
    }

    $retVal
}

#
# Function Description:
#
#  Returnes the SID's found in $text
#  $text is an excrpt from the NPS configuration dump file (in XML format)
#
function GetGroupNames ( $text )
{
    $ret = $null

    $Index = $text.IndexOf('"')
    $lastIndex = $text.LastIndexOf('"')
    $length = $lastIndex - $Index - 1

    $actualIndex = $index + 1

    if ( $length -ge 1 )
    {
        $SubStr = $text.SubString($actualIndex , $length)
    }

    if ( ( $SubStr -ne $null ) -and ( $SubStr.Length -ne 0 ) )
    {
        $ret = $SubStr.Split(";")
    }

    $ret
}

#
# Function Description:
#
#  Returnes the name for the SID
#
function ConvertSIDToName  ( $SID )
{
    $ret = $null
    $name = $null
    
    $sidObj = new-object System.Security.Principal.SecurityIdentifier ( $SID)
 
    if ( $sidObj -ne $null )
    {
        $name = $sidObj.Translate( [System.Security.Principal.NTAccount])
        if ( $name -ne $null )
        {
            $ret = $name.ToString()
        }
    }

    $ret
}

#
# Function Description:
#
#  Returnes the name of the health policy in $text
#  $text is an excrpt from the NPS configuration dump file (in XML format)
#
function GetHealthPolicyName ( $text )
{
    $ret = $null

    $Index = $text.IndexOf('"')
    $lastIndex = $text.LastIndexOf('"')
    $length = $lastIndex - $Index - 1

    $actualIndex = $index + 1

    if ( $length -ge 1 )
    {
        $SubStr = $text.SubString($actualIndex , $length)
    }

    if ( ( $SubStr -ne $null ) -and ( $SubStr.Length -ne 0 ) )
    {
        $ret = $SubStr
    }

    $ret    
}

#
# Function Description:
#
#  Returnes true if the NAS_PORT_TYPE in $text
#  is "^5$" (i.e. Virtual(VPN)), false otherwise
#
function NASPortTypeVPN ( $text )
{
    $ret = $false

    $Index = $text.IndexOf('"')
    $lastIndex = $text.LastIndexOf('"')
    $length = $lastIndex - $Index - 1
    $actualIndex = $index + 1

    if ( $length -ge 1 )
    {
        $SubStr = $text.SubString($actualIndex , $length)
    }

    $NASPortValStrs = $SubStr.Split('=')

    $count = $NASPortValStrs.Count   

    if ( $count -eq 2 )
    {
        $strVal = $NASPortValStrs[1]

        if ( ( $strVal -ne $null ) -and ( $strVal -eq "^5$" ) )
        {
            $ret = $true
        }
    }

    $ret
}

#
# Function Description:
#
#  Returnes 0, 1, 2 or 3 depending on the auth method found in $text
#  0 means no auth method was found. i = PW, 2 = SC, 3 = PW and SC
#  $text is an excrpt from the NPS configuration dump file (in XML format)
#
function GetAuthMethod ( $text )
{
    $ret = 0

    $Index1 = $text.LastIndexOf('(')
    $Index2 = $text.IndexOf(')')

    $length = $Index2 - $Index1 - 1

    $actualIndex = $Index1 + 1

    if ( $length -ge 1 )
    {
        $SubStr = $text.SubString($actualIndex , $length)
    }

    $strs = $null

    if ( ( $SubStr -ne $null ) -and ( $SubStr.Length -ne 0 ) )
    {
        $strs = $SubStr.Split("|")
    }

    foreach ( $str in $strs)
    {
        if ( $str -eq "PW" )
        {
            $ret += 1
        }

        if ( $str -eq "SC" )
        {
            $ret += 2
        }
    }

    $ret    
}

function IsRemoteDesktopDisabled()
{
    $reg = Get-WMIObject -List -Namespace root\default -class StdRegProv -ErrorAction SilentlyContinue
    $result = $reg.getDwordvalue(2147483650,"software\policies\microsoft\windows nt\terminal services","fDenyTSConnections")
    if(($result.ReturnValue -eq 0) -and ($result.uValue -eq 1)) {
		  return 1
    }
    
    $result = $reg.getDwordvalue(2147483650,"system\currentcontrolset\control\terminal server","fDenyTSConnections")
    if(($result.ReturnValue -eq 0) -and ($result.uValue -eq 1)) {
		  return 1
    }
    return 0
}

function GetTsMaxInstanceCount()
{
    $MaxInstanceCount = 0
    Import-Module RemoteDesktopServices
    $TotalConnections = Get-Item "RDS:\RDSConfiguration\Connections\*\ConnectionStatus" | ?{$_.CurrentValue -eq 1} | %{Get-Item "$($_.parentpath)\MaximumConnections"} | Measure-Object -Sum -Property CurrentValue
    if($TotalConnections -ne $NULL) {
        $MaxInstanceCount = $TotalConnections.Sum
    }
    
    # the following code is needed to handle a bug in the BPA frame work
    if($MaxInstanceCount -gt 1024) {
        $MaxInstanceCount = 1024
    }
    return $MaxInstanceCount
}


function IsAltServerSpecified()
{
    $WrkSpace = Get-WmiObject -Namespace root\cimv2\terminalservices -Class win32_workspace
    $Redirector = $WrkSpace.Redirector
    $AltSrv = $WrkSpace.RedirectorAlternateAddress
    
    # no redirector hence complaint
    if(($Redirector -eq $NULL) -or ($Redirector -eq "")) {
        return 1
    }
    
    # alternate server not specified though redirector is specified
    if(($AltSrv -eq $NULL) -or ($AltSrv -eq "")) {
        return 0
    }
    
    return 1
}

#
# Gets IP addresses of a machine(both IPv4 and IPv6)
#
function GetMachineIP($MachineName)
{
    $MachineIP = @()
    try {
        $MachineIPAddr = [System.Net.Dns]::GetHostAddresses($MachineName)
        $IPv4 = @($MachineIPAddr|?{$_.AddressFamily -eq "InterNetwork" } | %{$_.IPAddressToString})
        if($IPv4.Count -gt 0) {
            $MachineIP = $MachineIP + $IPv4
        }
        $IPv6 = @($MachineIPAddr|?{$_.AddressFamily -eq "InterNetworkV6" } | %{$_.IPAddressToString})
        if($IPv6.Count -gt 0) {
            $MachineIP = $MachineIP + $IPv6
        }
    }catch{
    }
    return $MachineIP
}

function IsIPAdress([System.String]$Address)
{
    $RetValue = $TRUE
    try {
        [System.Net.IPAddress]::Parse($Address)
    }catch {
        $RetValue = $FALSE
    }
    return $RetValue
}

function IsFQDN([System.String]$Name)
{
    $Components = $Name.Split(".")
    if($Components.Count -gt 1) {
        return $TRUE
    }
    return $FALSE
}

function AreNamesSame([System.String]$Name1, [System.String]$Name2)
{
    $RetValue = $FALSE
    $Name1 = $Name1.ToLower()
    $Name2 = $Name2.ToLower()
    if((IsFQDN $Name1) -and (IsFQDN $Name2)) {
        $RetValue = $Name1.Equals($Name2)
    }else {
        $RetValue = $Name1.Split(".")[0].Equals($Name2.Split(".")[0])
    }
    return $RetValue
}

function CheckRedirectorAltServerSameIP()
{
    $WrkSpace = Get-WmiObject -Namespace root\cimv2\terminalservices -Class win32_workspace
    $Redirector = $WrkSpace.Redirector
    $AltSrv = $WrkSpace.RedirectorAlternateAddress
    
    # alternate server not specified, so complaint
    if(($AltSrv -eq $NULL) -or ($AltSrv -eq "")) {
        return 1
    }
    
    # only alternative server is specified, so not complaint
    if(($Redirector -eq $NULL) -or ($Redirector -eq "")) {
        return 0
    }
    
    # check if alternate server name and redirector name are the same
    if(!(IsIPAdress $AltSrv) -and !(IsIPAdress $Redirector)) {
        if(AreNamesSame $AltSrv $Redirector) { 
            return 0
        }
    }
    
    # redirector is IP pass the rule. Avoid false -ve
    if((IsIPAdress $Redirector)) {
        return 1
    }
    
    $AltSrvIP = @(GetMachineIP $AltSrv)
    if($AltSrvIP.Count -eq 0) {
        return 0
    }
    
    
    $RedirectorIP = @(GetMachineIP $Redirector)
    if($RedirectorIP.Count -eq 0) {
        return 0
    }
    
    
    if([System.Array]::IndexOf($RedirectorIP, $AltSrvIP[0]) -ne -1) {
        return 1
    }
    
    return 0
}

#
# check if firewall exception is enabled for remote desktop
#
function IsFireWallExEnabledForRD()
{
    $FwPolicy2 = New-Object -ComObject HNetCfg.FwPolicy2
    $Enabled = $FwPolicy2.IsRuleGroupCurrentlyEnabled("@FirewallAPI.dll,-28752")
    if($Enabled) {
        return 1
    }
    return 0
}

function IsCALTypeAvailable([System.String]$CalType, [System.Collections.Hashtable]$AvailableCALTab)
{
    if($AvailableCALTab.ContainsKey($CalType)) {
        if($AvailableCALTab[$CalType] -gt 0) {
            return $TRUE
        }
    }
    
    return $FALSE
}

function IsHigherVersionCALAvailable([System.String]$CalType, [System.Collections.Hashtable]$AvailableCALTab, [System.Collections.Hashtable]$HigherVersionCALTab)
{
    
    #
    # this condition does not throw false warnings for the future cal versions
    # 
    if(!($HigherVersionCALTab.ContainsKey($CalType))) {
        return $TRUE
    }
    
    $HigherVersionCalTypes = $HigherVersionCALTab[$CalType]
    foreach($HigherVersionCal in $HigherVersionCalTypes) {
        if(IsCALTypeAvailable $HigherVersionCal $AvailableCALTab) {
            return $TRUE
        }
    }
    return $FALSE
}

function IsLSPreventUpgradeGPEnabled()
{
    $LSServer = New-Object System.Management.ManagementClass("Win32_TSLicenseServer")
    if($LSServer) {
        $Status = $LSServer.IsLSPreventUpgradeGPEnabled()
        if($Status.ReturnValue -eq 0) {
            return $Status.Enabled
        }
    }
    return $FALSE
}

#
# Compute the available Non-PU CALs (i.e., PD or Internet type) for each product version (for which CAL has been installed) and
# report if any of the product versions has zero available Non-PU CALs
# Return Values:
#   0 - there is atleast one product version (for which CAL has been installed) for which Non-PU CALs available count is zero
#   1 - all product versions (for which CAL has been installed) have atleast one Non-PU CAL available
#   2 - there are no Non-PU CAL packs
#
function IsNonPUCALAvailable([System.Array]$CALPacks)
{
    
    $AvailableCALTab = @{}
    foreach($CALPack in $CALPacks) {     
        # enumerate available CALs for all product types other than PU
        if($CALPack.ProductType -ne 1) {
            [String]$Key =  [String]$CALPack.ProductVersionID + "_" + $CALPack.ProductType
            if($AvailableCALTab.ContainsKey($Key)) {
               $AvailableCALTab[$Key] += $CALPack.AvailableLicenses
            }else{
               $AvailableCALTab.Add($Key, $CALPack.AvailableLicenses)
            }
        }
    }
    
    # No Non-PU CAL packs
    if($AvailableCALTab.Count -eq 0) {
        return 2
    }
    
    $NoAvailableCALProdVers = $AvailableCALTab.GetEnumerator() | ?{$_.Value -le 0}
    if($NoAvailableCALProdVers) {
        if((IsLSPreventUpgradeGPEnabled)) {
            return 0
        }
        
        # define a hashtable that contains the higher version CAL information
        # for example, the higher version cals for win2k PD("0_0") are win2k3("1_0") and win2k8("2_0")
        $HigherVersionCALTab = @{}
        
        # Add higher version cals
        # the following encoding is used for representing win2k, win2k3 and win2k8 PD cal types
        # A code of the form "ProductVersionID_ProductType" represents a CAL of particualr product version
        # and of a particular product type. for example, "0_0" represents win2k PD cal and 
        # "2_0" represents win2k8 PD cal
        
        $HigherVersionCALTab.Add("0_0", @("1_0", "2_0"))
        $HigherVersionCALTab.Add("0_2", @())
        $HigherVersionCALTab.Add("1_0", @("2_0"))
        $HigherVersionCALTab.Add("2_0", @())
        
        foreach($ProdVerCALType in $NoAvailableCALProdVers) {
            if(!(IsHigherVersionCALAvailable $ProdVerCALType.Name $AvailableCALTab $HigherVersionCALTab)) {
                return 0
            }
        }
    }
    return 1
}

function IsPUCALAvailable()
{
    
    import-module RemoteDesktopServices
    $res = 1
    $repObj = New-Item "RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports" -Scope AllTrustedDom
    if($repObj -eq $NULL) {
        $repObj = New-Item "RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports" -Scope Dom
    }
    if($repObj -eq $NULL) {
        return $res
    }
    $rep = $repObj | %{$_.Name}
    $caltypes = Get-ChildItem "RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports\$rep" | ?{($_.name -ne "Version") -and ($_.name -ne "Scope")} | %{$_.name}
    foreach($ctype in $caltypes) {
        $InsCount = (Get-Item "RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports\$rep\$ctype\InstalledCount").CurrentValue
        $IssCount = (Get-Item "RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports\$rep\$ctype\IssuedCount").CurrentValue
        if(($InsCount -eq 0) -and ($IssCount -eq 0)) {
            continue
        }
        if($IssCount -ge $InsCount) {
            $res = 0
            break
        }
    }
    if($rep) {
        Remove-Item "RDS:\LicenseServer\IssuedLicenses\PerUserLicenseReports\$rep" -Recurse
    }
    return $res
}

function IsCALAvailable()
{
    $CALPacks = Get-WMIObject -NameSpace root\cimv2 -Class Win32_TsLicenseKeyPack
    
    # No packs installed
    if(($CALPacks -eq $NULL)) {
        return 0
    }
    
    $InstalledPermCALPacks = @()
    foreach($CALPack in $CALPacks) {
        # exclude temp cals and win2k default cals
        if(($CALPack.KeyPackType -eq 4) -or (($CALPack.ProductVersionID -eq 0) -and ($CALPack.KeyPackType -eq 6))) {
             continue
        }
        $InstalledPermCALPacks += $CALPack
    }
    
    if($InstalledPermCALPacks.Count -eq 0) {
        return 0
    }
    
    if((IsNonPUCALAvailable $InstalledPermCALPacks) -eq 0) {
        return 0
    }
    return (IsPUCALAvailable)
}

function AreDomainUsrsInRemoteDesktopUsersGrp([System.String]$GroupName)
{
     $DomainUsrs = net localgroup $GroupName|?{$_ -match "\\"}
     if($DomainUsrs) {
        return 1
     }
     return 0
}

#
# Retrieves the collection user groups properties for a specified collection
# 
# Returns collection properties
#
function GetRDSHCollectionPropertiesUserGroups ($RDSHCollection, [REF]$RDSHCollectionReport)
{
    $UserGroups = @()
    $RDSHCollectionTempReport = ""
    
    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        $RetVal = Invoke-WmiMethod -Name "GetStringProperty" -InputObject $RDSHCollection -ArgumentList "SecurityDescriptor" 
    } Catch { 
       #Nothing
    }

    if ($RetVal.ReturnValue -eq 0)
    {
        #
        # Convert from SID to User Group
        #
        $parts = $RetVal.Value.Split("()")
        foreach ($part in $parts)
        {
            $index = $part.LastIndexOf(';')
            if ($index -le 0)
            {
                continue
            }
            $UserGroups += @(ConvertSIDToName $part.SubString($index+1))
        }
        $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUserGroup + " " + $UserGroups + $NewLine
    }

    $RDSHCollectionReport.Value = $RDSHCollectionTempReport 
    return $UserGroups
}

#
# Retrieves the collection connection properties for a specified collection
# 
# Returns collection properties
#
function GetRDSHCollectionPropertiesConnections ($RDSHCollection, [REF]$RDSHCollectionReport)
{
    $Connections = New-Object ConnectionsType
    $RDSHCollectionTempReport = ""

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "DisconnectedSessionLimit" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Connections.DisconnectedSessionLimit = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_DisconnectedSessionLimit + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "ActiveSessionLimit" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Connections.ActiveSessionLimit = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_ActiveSessionLimit + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "IdleSessionLimit" 
    } Catch { 
        #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Connections.IdleSessionLimit = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_IdleSessionLimit + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "BrokenConnectionAction" 
    } Catch { 
        #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
        $Connections.BrokenConnectionAction = $RetVal.Value
        $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_BrokenConnectionAction + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "EnableAutomaticReconnection" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Connections.EnableAutomaticReconnection = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_EnableAutomaticReconnection + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "DeleteTempFoldersOnExit" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Connections.DeleteTempFoldersOnExit = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_DeleteTempFoldersOnExit + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "UseTempFoldersPerSession" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Connections.UseTempFoldersPerSession = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_UseTempFoldersPerSession + " " + $RetVal.Value + $NewLine
    }

    $RDSHCollectionReport.Value = $RDSHCollectionTempReport
    return $Connections
}

#
# Retrieves the collection security properties for a specified collection
# 
# Returns collection properties
#
function GetRDSHCollectionPropertiesSecurity ($RDSHCollection, [REF]$RDSHCollectionReport)
{
    $Security = New-Object SecurityType
    $RDSHCollectionTempReport = ""

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "SecurityLayer" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Security.SecurityLayer = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertySecurity_SecurityLayer + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "EncryptionLevel" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Security.EncryptionLevel = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertySecurity_EncryptionLevel + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "AuthenticateUsingNLA" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $Security.AuthenticateUsingNLA = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertySecurity_AuthenticateUsingNLA + " " + $RetVal.Value + $NewLine
    }

    $RDSHCollectionReport.Value = $RDSHCollectionTempReport 
    return $Security
}

#
# Retrieves the collection client settings properties for a specified collection
# 
# Returns collection properties
#
function GetRDSHCollectionPropertiesClientSettings ($RDSHCollection, [REF]$RDSHCollectionReport)
{
    $ClientSettings = New-Object ClientSettingsType
    $RDSHCollectionTempReport = ""

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "DeviceRedirectionOptions" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $ClientSettings.DeviceRedirectionOptions = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_DeviceRedirectionOptions + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "RedirectClientPrinter" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $ClientSettings.RedirectClientPrinter = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_RedirectClientPrinter + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "SetClientPrinterAsDefault" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $ClientSettings.SetClientPrinterAsDefault = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_SetClientPrinterAsDefault + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "UseRDEasyPrintDriver" 
    } Catch { 
       #Nothing
    }
        if ($RetVal.ReturnValue -eq 0)
    {
       $ClientSettings.UseRDEasyPrintDriver = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_UserRDEasyPrintDriver + " " + $RetVal.Value + $NewLine
    }

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "MaxMonitors" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $ClientSettings.MaxMonitors = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_MaxMonitors + " " + $RetVal.Value + $NewLine
    }

    $RDSHCollectionReport.Value = $RDSHCollectionTempReport 
    return $ClientSettings
}

#
# Retrieves the collection UVHD properties for a specified collection
# 
# Returns collection properties
#
function GetRDSHCollectionPropertiesUVHDSettings ($RDSHCollection, [REF]$RDSHCollectionReport)
{
    $UVHDSettings = New-Object UVHDSettingsType
    $RDSHCollectionTempReport = ""

    Try {
        #
        # Make the WMI call to get the desired property
        #
        $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "IsUserVHDEnabled" 
    } Catch { 
       #Nothing
    }
    if ($RetVal.ReturnValue -eq 0)
    {
       $UVHDSettings.IsUVHDEnabled = $RetVal.Value
       $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUVHDSettings_IsUserVHDEnabled + " " + $RetVal.Value + $NewLine
    }

    if ($UVHDSettings -ne $NULL -and $UVHDSettings.IsUVHDEnabled -eq 1)
    {
        Try {
            #
            # Make the WMI call to get the desired property
            #
            $RetVal = Invoke-WmiMethod -Name "GetStringProperty" -InputObject $RDSHCollection -ArgumentList "UserVHDShare" 
        } Catch { 
            #Nothing
        }
        if ($RetVal.ReturnValue -eq 0)
        {
           $UVHDSettings.UserVHDShare = $RetVal.Value
           $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUVHDSettings_UserVHDShare + " " + $RetVal.Value + $NewLine
        }

        Try {
            #
            # Make the WMI call to get the desired property
            #
            $RetVal = Invoke-WmiMethod -Name "GetStringProperty" -InputObject $RDSHCollection -ArgumentList "UserPolicyXML" 
        } Catch { 
            #Nothing
        }
        if ($RetVal.ReturnValue -eq 0)
            {
                $UVHDSettings.UserPolicyXML = $RetVal.Value
                $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUVHDSettings_UserPolicyXML + " " + $RetVal.Value + $NewLine
            }

        Try {
            #
            # Make the WMI call to get the desired property
            #
            $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "DiskSizeInMB" 
        } Catch { 
            #Nothing
        }
        if ($RetVal.ReturnValue -eq 0)
        {
           $UVHDSettings.DiskSizeInMB = $RetVal.Value
           $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUVHDSettings_DiskSizeInMB + " " + $RetVal.Value + $NewLine
        }

        Try {
            #
            # Make the WMI call to get the desired property
            #
            $RetVal = Invoke-WmiMethod -Name "GetInt32Property" -InputObject $RDSHCollection -ArgumentList "DiskType" 
        } Catch { 
            #Nothing
        }
        if ($RetVal.ReturnValue -eq 0)
        {
           $UVHDSettings.DiskType = $RetVal.Value
           $RDSHCollectionTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUVHDSettings_DiskType + " " + $RetVal.Value + $NewLine
        }
    }

    $RDSHCollectionReport.Value = $RDSHCollectionTempReport 
    return $UVHDSettings
}

#
# Retrieves the collection properties for a specified collection
# 
# Returns collection properties
#
function GetRDSHCollectionProperties ($RDSHCollection, [REF]$RDSHCollectionReport)
{
    $RDSHCollectionProperties = New-Object RDSHCollectionPropertiesType

    $RDSHCollectionTempReport = $_system_translations.RDSHCollectionCheck_ExpectedPropertyValues + $NewLine 
    $RDSHCollectionTempReport2 = ""

    $RDSHCollectionProperties.UserGroups = GetRDSHCollectionPropertiesUserGroups $RDSHCollection ([REF]$RDSHCollectionTempReport2)
    $RDSHCollectionTempReport += $RDSHCollectionTempReport2

    $RDSHCollectionProperties.Connections = GetRDSHCollectionPropertiesConnections $RDSHCollection ([REF]$RDSHCollectionTempReport2)
    $RDSHCollectionTempReport += $RDSHCollectionTempReport2

    $RDSHCollectionProperties.Security = GetRDSHCollectionPropertiesSecurity $RDSHCollection ([REF]$RDSHCollectionTempReport2)
    $RDSHCollectionTempReport += $RDSHCollectionTempReport2

    $RDSHCollectionProperties.ClientSettings = GetRDSHCollectionPropertiesClientSettings $RDSHCollection ([REF]$RDSHCollectionTempReport2)
    $RDSHCollectionTempReport += $RDSHCollectionTempReport2

    $RDSHCollectionProperties.UVHDSettings = GetRDSHCollectionPropertiesUVHDSettings $RDSHCollection ([REF]$RDSHCollectionTempReport2)
    $RDSHCollectionTempReport += $RDSHCollectionTempReport2
    
    $RDSHCollectionReport.Value = $RDSHCollectionTempReport
    return $RDSHCollectionProperties
}

#
# Check whether a specified RDSH server has identical user groups settings compared to the collection settings. 
# This function also dumps the settings which are different.
# 
# Returns 0 if there is some differences
# Returns 1 if the settings are same
#
function CheckRDSHServerPropertiesUserGroups($RDSHServerName, $UserGroups, [REF]$RDSHCollectionServerReport)
{
    $ArePropertiesSame = $TRUE
    $RDSHCollectionServerTempReport = ""
    $TempUserGroups = @()

    $RemoteDesktopUsersGroupSID = "S-1-5-32-555"
    $GroupName = (ConvertSIDToName $RemoteDesktopUsersGroupSID).Split("\")[1]

    $Domain = $env:COMPUTERNAME
    $QueryFilter = "GroupComponent=`"Win32_Group.Domain='$Domain',Name='$GroupName'`""
    
    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [Object[]] $Users = Get-WmiObject Win32_GroupUser -filter $QueryFilter
    } Catch { 
        #Nothing
    }
    foreach ($User in $Users)
    {
        if ($User -eq $NULL)
        {
            continue
        }
        $StartIndex = $User.PartComponent.IndexOf("=")
        $EndIndex = $User.PartComponent.IndexOf(",")
        if ($StartIndex -ge 0 -and $EndIndex-$StartIndex-3 -ge 0)
        {
            $TempUserGroup = $User.PartComponent.Substring($StartIndex+2, $EndIndex-$StartIndex-3)
        }

        $StartIndex = $User.PartComponent.LastIndexOf("=")
        $EndIndex = $User.PartComponent.LastIndexOf("`"")
        if ($StartIndex -ge 0 -and $EndIndex-$StartIndex-2 -ge 0)
        {
            $TempUserGroup += "\" + $User.PartComponent.Substring($StartIndex+2, $EndIndex-$StartIndex-2)
        }
        $TempUserGroups += @($TempUserGroup)
    }
    if ($TempUserGroups -ne $UserGroups)
    {
        $ArePropertiesSame = $FALSE
        $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyUserGroup + " " + $TempUserGroup + $NewLine
    }
    
    $RDSHCollectionServerReport.Value = $RDSHCollectionServerTempReport
    return $ArePropertiesSame
}

#
# Check whether a specified RDSH server has identical connection settings compared to the collection settings. 
# This function also dumps the settings which are different.
# 
# Returns 0 if there is some differences
# Returns 1 if the settings are same
#
function CheckRDSHServerPropertiesConnections($RDSHServerName, [ConnectionsType]$Connections, [REF]$RDSHCollectionServerReport)
{
    $ArePropertiesSame = $TRUE
    $RDSHCollectionServerTempReport = ""

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [object] $RDSHServerTSSessionSetting = Get-WmiObject Win32_TSSessionSetting -Namespace "root\cimv2\TerminalServices" -ComputerName $RDSHServerName -Authentication PacketPrivacy
    } Catch { 
        #Nothing
    }
    if ($RDSHServerTSSessionSetting -ne $NULL)
    {
        if ($RDSHServerTSSessionSetting.DisconnectedSessionLimit -ne $Connections.DisconnectedSessionLimit)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_DisconnectedSessionLimit + " " + $RDSHServerTSSessionSetting.DisconnectedSessionLimit + $NewLine
        }

        if ($RDSHServerTSSessionSetting.ActiveSessionLimit -ne $Connections.ActiveSessionLimit)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_ActiveSessionLimit + " " + $RDSHServerTSSessionSetting.ActiveSessionLimit + $NewLine
        }

        if ($RDSHServerTSSessionSetting.IdleSessionLimit -ne $Connections.IdleSessionLimit)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_IdleSessionLimit + " " + $RDSHServerTSSessionSetting.IdleSessionLimit + $NewLine
        }

        if ($Connections.BrokenConnectionAction -eq 0 -and $RDSHServerTSSessionSetting.BrokenConnectionPolicy -ne 1)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_BrokenConnectionAction + " " + $RDSHServerTSSessionSetting.BrokenConnectionPolicy + $RDSHServerTSSessionSetting.BrokenConnectionAction + $NewLine
        }
        elseif ($Connections.BrokenConnectionAction -eq 2 -and $RDSHServerTSSessionSetting.BrokenConnectionPolicy -ne 0 -and $RDSHServerTSSessionSetting.BrokenConnectionPolicy -ne 1)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_BrokenConnectionAction + " " + $RDSHServerTSSessionSetting.BrokenConnectionPolicy + $RDSHServerTSSessionSetting.BrokenConnectionAction + $NewLine
        }
        elseif ($RDSHServerTSSessionSetting.BrokenConnectionPolicy -ne 0 -and $RDSHServerTSSessionSetting.BrokenConnectionPolicy -ne 0)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_BrokenConnectionAction + " " + $RDSHServerTSSessionSetting.BrokenConnectionPolicy + $RDSHServerTSSessionSetting.BrokenConnectionAction + $NewLine
        }

        # Automatic reconnection policy is handled by GP. Hence the check is excluded here.

#        if ($RDSHServerTSSessionSetting.ReconnectionPolicy -ne $Connections.EnableAutomaticReconnection)
#        {
#            $ArePropertiesSame = $FALSE
#            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_EnableAutomaticReconnection + " " + $RDSHServerTSSessionSetting.ReconnectionPolicy + $NewLine
#        }
    }

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [object] $RDSHServerTerminalServiceSetting = Get-WmiObject Win32_TerminalServiceSetting -Namespace "root\cimv2\TerminalServices" -ComputerName $RDSHServerName -Authentication PacketPrivacy
    } Catch { 
        #Nothing
    }

    if ($RDSHServerTerminalServiceSetting -ne $NULL)
    {
        if ($RDSHServerTerminalServiceSetting.DeleteTempFolders -ne $Connections.DeleteTempFoldersOnExit)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_DeleteTempFoldersOnExit + " " + $RDSHServerTerminalServiceSetting.DeleteTempFolders + $NewLine
        }

        if ($RDSHServerTerminalServiceSetting.UseTempFolders -ne $Connections.UseTempFoldersPerSession)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyConnections_UseTempFoldersPerSession + " " + $RDSHServerTerminalServiceSetting.UseTempFolders + $NewLine
        }
    }

    $RDSHCollectionServerReport.Value = $RDSHCollectionServerTempReport
    return $ArePropertiesSame
}

#
# Check whether a specified RDSH server has identical security settings compared to the collection settings. 
# This function also dumps the settings which are different.
# 
# Returns 0 if there is some differences
# Returns 1 if the settings are same
#
function CheckRDSHServerPropertiesSecurity($RDSHServerName, [SecurityType]$Security, [REF]$RDSHCollectionServerReport)
{
    $ArePropertiesSame = $TRUE
    $RDSHCollectionServerTempReport = ""

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [object] $RDSHServerTSGeneralSetting = Get-WmiObject Win32_TSGeneralSetting -Namespace "root\cimv2\TerminalServices" -ComputerName $RDSHServerName -Authentication PacketPrivacy
    } Catch { 
        #Nothing
    }
    if ($RDSHServerTSGeneralSetting -ne $NULL)
    {
        if ($RDSHServerTSGeneralSetting.SecurityLayer -ne $Security.SecurityLayer)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertySecurity_SecurityLayer + " " + $RDSHServerTSGeneralSetting.SecurityLayer + $NewLine
        }

        if ($RDSHServerTSGeneralSetting.MinEncryptionLevel -ne $Security.EncryptionLevel)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertySecurity_EncryptionLevel + " " + $RDSHServerTSGeneralSetting.MinEncryptionLevel + $NewLine
        }

        if ($RDSHServerTSGeneralSetting.UserAuthenticationRequired -ne $Security.AuthenticateUsingNLA)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertySecurity_AuthenticateUsingNLA + " " + $RDSHServerTSGeneralSetting.UserAuthenticationRequired + $NewLine
        }
    }

    $RDSHCollectionServerReport.Value = $RDSHCollectionServerTempReport
    return $ArePropertiesSame
}

#
# Check whether a specified RDSH server has identical client settings compared to the collection settings. 
# This function also dumps the settings which are different.
# 
# Returns 0 if there is some differences
# Returns 1 if the settings are same
#
function CheckRDSHServerPropertiesClientSettings($RDSHServerName, [ClientSettingsType]$ClientSettings, [REF]$RDSHCollectionServerReport)
{
    $ArePropertiesSame = $TRUE
    $RDSHCollectionServerTempReport = ""

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [object] $RDSHServerTSDeploymentSetting = Get-WmiObject Win32_TSDeploymentSettings -Namespace "root\cimv2\TerminalServices" -ComputerName $RDSHServerName -Authentication PacketPrivacy
    } Catch { 
        #Nothing
    }
    if ($RDSHServerTSDeploymentSetting -ne $NULL)
    {
         # TODO: Device redirection options are not matching. Disabling this check now.

#        if ($RDSHServerTSDeploymentSetting.RedirectionOptions -ne $ClientSettings.DeviceRedirectionOptions)
#        {
#            $ArePropertiesSame = $FALSE
#            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_DeviceRedirectionOptions + " " + $RDSHServerTSDeploymentSetting.RedirectionOptions + $NewLine
#        }
    }

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [object] $RDSHServerTSClientSetting = Get-WmiObject Win32_TSClientSetting -Namespace "root\cimv2\TerminalServices" -ComputerName $RDSHServerName -Authentication PacketPrivacy
    } Catch { 
        #Nothing
    }
    if ($RDSHServerTSClientSetting -ne $NULL)
    {
        # Printer settings are controlled by GP and hence excluded in this check. Check for UserRDEasyPrintDriver is missing.

#        if ($RDSHServerTSClientSetting.WindowsPrinterMapping -ne $ClientSettings.RedirectClientPrinter)
#        {
#            $ArePropertiesSame = $FALSE
#            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_RedirectClientPrinter + " " + $RDSHServerTSClientSetting.ConnectPrinterAtLogon + $NewLine
#        }

#        if ($RDSHServerTSClientSetting.DefaultToClientPrinter -ne $ClientSettings.SetClientPrinterAsDefault)
#        {
#            $ArePropertiesSame = $FALSE
#            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_SetClientPrinterAsDefault + " " + $RDSHServerTSClientSetting.DefaultToClientPrinter + $NewLine
#        }

        if ($RDSHServerTSClientSetting.MaxMonitors -ne $ClientSettings.MaxMonitors)
        {
            $ArePropertiesSame = $FALSE
            $RDSHCollectionServerTempReport += "    " + $_system_translations.RDSHCollectionCheck_PropertyClientSettings_MaxMonitors + " " + $RDSHServerTSClientSetting.MaxMonitors + $NewLine
        }
    }

    $RDSHCollectionServerReport.Value = $RDSHCollectionServerTempReport
    return $ArePropertiesSame
}

#
# Check whether a specified RDSH server has identical UVHD settings compared to the collection settings. 
# This function also dumps the settings which are different.
# 
# Returns 0 if there is some differences
# Returns 1 if the settings are same
#
function CheckRDSHServerPropertiesUVHDSettings($RDSHServerName, [UVHDSettingsType]$UVHDSettings, [REF]$RDSHCollectionServerReport)
{
    # TODO
    $RDSHCollectionServerReport.Value = ""
    return $TRUE
}

#
# Check whether a specified RDSH server has identical settings compared to the collection settings. 
# This function also dumps the settings which are different.
# 
# Returns 0 if there is some differences
# Returns 1 if the settings are same
#
function CheckRDSHServerProperties([RDSHCollectionPropertiesType]$RDSHCollectionProperties, $RDSHServerName, [REF]$RDSHCollectionServerReport)
{
    $ArePropertiesSame = $TRUE

    $RDSHCollectionServerTempReport = $_system_translations.RDSHCollectionCheck_Server + " " + $RDSHServerInstance.Name + $NewLine 
    $RDSHCollectionServerTempReport2 = ""

    $RetVal = CheckRDSHServerPropertiesUserGroups $RDSHServerName $RDSHCollectionProperties.UserGroups ([REF]$RDSHCollectionServerTempReport2)
    $RDSHCollectionServerTempReport += $RDSHCollectionServerTempReport2
    if ($RetVal -ne $TRUE)
    {
        $ArePropertiesSame = $FALSE
    }

    $RetVal = CheckRDSHServerPropertiesConnections $RDSHServerName $RDSHCollectionProperties.Connections ([REF]$RDSHCollectionServerTempReport2)
    $RDSHCollectionServerTempReport += $RDSHCollectionServerTempReport2
    if ($RetVal -ne $TRUE)
    {
        $ArePropertiesSame = $FALSE
    }

    $RetVal = CheckRDSHServerPropertiesSecurity $RDSHServerName $RDSHCollectionProperties.Security ([REF]$RDSHCollectionServerTempReport2)
    $RDSHCollectionServerTempReport += $RDSHCollectionServerTempReport2
    if ($RetVal -ne $TRUE)
    {
        $ArePropertiesSame = $FALSE
    }

    $RetVal = CheckRDSHServerPropertiesClientSettings $RDSHServerName $RDSHCollectionProperties.ClientSettings ([REF]$RDSHCollectionServerTempReport2)
    $RDSHCollectionServerTempReport += $RDSHCollectionServerTempReport2
    if ($RetVal -ne $TRUE)
    {
        $ArePropertiesSame = $FALSE
    }

    $RetVal = CheckRDSHServerPropertiesUVHDSettings $RDSHServerName $RDSHCollectionProperties.UVHDSettings ([REF]$RDSHCollectionServerTempReport2)
    $RDSHCollectionServerTempReport += $RDSHCollectionServerTempReport2
    if ($RetVal -ne $TRUE)
    {
        $ArePropertiesSame = $FALSE
    }

    $RDSHCollectionServerReport.Value = $RDSHCollectionServerTempReport + $NewLine
    return $ArePropertiesSame
}

#
# Check whether all the RDSH servers in a given collection have identical settings. 
# 
# Returns 0 if there is some differences
# Returns 1 if the collections are homogeneous
#
function CheckRDSHCollection()
{
    $ArePropertiesSame = 1

    Try {
        #
        # Make the WMI call to get instances of WMI class
        #
        [Object[]] $RDSHCollections = Get-WmiObject Win32_RDSHCollection -namespace "root\cimv2\rdms" 
        [Object[]] $RDSHServers = Get-WmiObject Win32_RDSHServer -namespace "root\cimv2\rdms" 
    } Catch { 
       #Nothing
    }

    if ($RDSHCollections -eq $NULL -or $RDSHservers -eq $NULL)
    {
        #
        # Base WMI objects failed. Trigger failure with no data.
        #
        return 0
    }
 
    $RDSHCollectionsReport  = @()

    foreach ($RDSHCollectionInstance in $RDSHCollections)
    {   
        $RDSHCollectionReport = $NewLine + $NewLine + $_system_translations.RDSHCollectionCheck_Collection + " " + $RDSHCollectionInstance.Name + $NewLine 
        $RDSHCollectionReport += $_system_translations.RDSHCollectionCheck_HeterogeneousServers
        $RDSHCollectionReportExpectedPropertyValues = ""
        $RDSHCollectionProperties = GetRDSHCollectionProperties $RDSHCollectionInstance ([REF]$RDSHCollectionReportExpectedPropertyValues)

        $RDSHCollectionServersReport = ""

        foreach ($RDSHServerInstance in $RDSHServers)
        {
            if ($RDSHCollectionInstance.Name -eq $RDSHServerInstance.CollectionAlias)
            {
                $RDSHCollectionServerReport = ""
                $RetVal = CheckRDSHServerProperties $RDSHCollectionProperties $RDSHServerInstance.Name ([REF]$RDSHCollectionServerReport)
                if ($RetVal -ne $TRUE)
                {
                    $ArePropertiesSame = 0
                    $RDSHCollectionReport += $RDSHServerInstance.Name + " "
                    $RDSHCollectionServersReport += $RDSHCollectionServerReport

                }
            }
        }
        $RDSHCollectionReport += $NewLine + $_system_translations.RDSHCollectionCheck_MoreInformation + $NewLine + $NewLine + $RDSHCollectionReportExpectedPropertyValues + $NewLine + $RDSHCollectionServersReport + $NewLine
        $RDSHCollectionsReport += @($RDSHCollectionReport)
    }
    AddElementToDocument $doc $tns $RDSHCollectionsReport "RDMS" "RDSHCollection" "RDSHCollectionReport"
    return $ArePropertiesSame
}    

#
# ------------------
# FUNCTIONS - END
# ------------------
#

#
# ------------------------
# SCRIPT MAIN BODY - START
# ------------------------
#

#
# Initialize to perform querying Role information
#
RoleQueryInitialize

$TSGatewayInstalled = IsRoleInstalled "RDS-Gateway"
$TSLicensingInstalled = IsRoleInstalled "RDS-Licensing"
$TSTerminalServerInstalled = IsRoleInstalled "RDS-RD-Server"
$IISInatalled = IsRoleInstalled "Web-Server"
$RDConnectionBrokerInstalled = IsRoleInstalled "RDS-Connection-Broker"
$RDVHInstalled = IsRoleInstalled "RDS-Virtualization"
$RDWebAccessInstalled = IsRoleInstalled "RDS-Web-Access"

#
# Role Information obtained.
#
RoleQueryShutdown

# 
# Set the Target Namespace to be used by XML
#
$tns="http://schemas.microsoft.com/bestpractices/models/ServerManager/TerminalServices/TerminalServicesComposite/2008/04"

#
# Create a new XmlDocument
#
$doc = Create-DocumentElement $tns "TerminalServicesComposite"

$NumVal = 0
$NumVal = BoolToNum $TSGatewayInstalled

#
# Adding this value to the XML Document
# 
AddElementToDocument $doc $tns $NumVal "TSGateway" "TSGatewayInstalled"

#
# If TS-Gateway is installed, we need to get count of CAPs and RAPs
#
if ( $TSGatewayInstalled -eq $true )
{
    $NumVal = 0
    $NumVal = BoolToNum $IISInatalled

    $nonNativeAuthnPluginUsed = 2

    $nonNativeAuthnPluginUsed = IsAuthorizationPlugginNonNative  

#
#  If Authorization plugin in non native, no need of verifying CAP/RAP and NPS settings
#

    if ( $nonNativeAuthnPluginUsed -eq 0 )
    {
        $rechableNPSServer = $null
        #
        # Is Central CAP store Enabled
        #
        $centralCAPEnabled = IsCentralCAPEnabled 

        if ( $centralCAPEnabled -eq $true )
        {
            $NPSServers = GetNPSServers 
     
            $NAPServerRechable = $false

            $SomeNPSServersUnrechable = $false

            if ( $NPSServers.Count -ne 0 )
            {
                $UnrechableNPSServers = $null

                foreach ( $server in $NPSServers )
                {
                    $serverRechable = $false

                    $serverRechable = IsComputerReachable $server

                    if ( $serverRechable -eq $true )
                    {
                        if ( $NAPServerRechable -eq $false)
                        {
                            $rechableNPSServer = $server
                            $NAPServerRechable = $true
                        }
                    }
                    else
                    {
                        $UnrechableNPSServers += $server + " "
                    }
                } 

                $NumVal = 0
                $NumVal = BoolToNum $NAPServerRechable

                AddElementToDocument $doc $tns $NumVal "TSGateway" "CAPSetup" "NPSServerReachable"
            }
        }

        $NumberCAPSconfigured = 0

        $NumberCapsActive = 0  

        $NumberCAPSNonCompliant = 0

        $NamesNonCompliantCAPS = $null

        $tempDir = $env:temp
 
        $file = "$tempDir\NPS_Settings_1.xml"

        $op = $null
        $res = $null

        if ( $centralCAPEnabled -eq $true )
        {
            if ( $rechableNPSServer -ne $null )
            {
                $op = &netsh -r "$rechableNPSServer" nps export filename = "$file" exportPSK = YES
            }
        }
        else
        {
            $op = &netsh nps export filename = "$file" exportPSK = YES
        }

        $opStr = "The NPS server configuration is successfully exported."

        if ( $op -ne $null )
        {
            $res = $op -clike "*$opStr*"
        }

        $delFile = $false

        if ( $res -ne $null )
        {
            $delFile = $true
        } 

        $fileData = $null

        if ( $delFile -eq $true )
        {
            $fileData = get-content -Path "$file"
        }

        if ( $fileData -ne $null )
        {
            $XMLData = [xml] $fileData

            $root = $XMLData.Root

            $networkPolicies = $XMLData.Root.Children.Microsoft_Internet_Authentication_Service.Children.NetworkPolicy.Children

            $policyNodes = $networkPolicies.ChildNodes

            $num = $policyNodes.count

            $gatewayPolicies = @()

            foreach ( $policy in $policyNodes )
            {
                $selectPolicy = $false

                $propertiesNode = $policy.Properties
                $properties = $propertiesNode.ChildNodes
        
                $obj = "" | select-object "name", "text"

                foreach ( $property in $properties )
                {
                    $obj.name = $property.name
                    $obj.text = $property.InnerText

                    if ( ( $obj.name -eq "Policy_SourceTag") -and ( $obj.text -eq 1 ) )
                    {
                        $selectPolicy = $true
                    }
                }

                if ( $selectPolicy -eq $true )
                {
                    $name = $policy.Name
                    $str = "TSG Marker Policy"
                    $str1 = "RDG Marker Policy"
                    $res = $name -clike "*$str*"
                    $res1 = $name -clike "*$str1*"

                    if ( ( $res -eq $false) -and ( $res1 -eq $false ) )
                    {
                        $gatewayPolicies += @($policy)
                        $NumberCAPSconfigured += 1
                    }
                }
            }

           $num = $gatewayPolicies.count

            $CAPPoliciesToAddToXML = @()

            foreach ( $policy in $gatewayPolicies)
            {
                $PolicyObject = "" | Select-object A1CAPPolicyName, A2PolicyAllowConenction, A3AllowClientWithoutAuthNego, A4NASPortTypeVPN, A5NumberUserGroups, A6AuthenticationSet, A7NumberHealthPolicies, A8PolicyCompliant
                $name = $policy.Name

                $groupNames = @()
                $healthPoliciesUsed = @() 
                $authMethod  = 0
                $policyEnabled = $false
                $nasPortTypeisVirtualVPN = $false
                $policyIsAllowAccess = $false
                $AllowCleintWithoutAuthNego = $false


                $propertiesNode = $policy.Properties

                $properties = $propertiesNode.ChildNodes     

                foreach ( $property in $properties )
                {
                    $propName = $property.Name
                    $text = $property.InnerText

                    if ( $propName -eq "Policy_Enabled" )
                    {
                        if ( $text -eq 1 )
                        {
                            $policyEnabled = $true
                            $NumberCapsActive += 1
                        }
                    } 

                    $str = "USERNTGROUPS"
                    $res = $text  -clike "*$str*"
                    $groups = $null

                    if ( $res -ne $false )
                    {
                        $groups = GetGroupNames $text

                        if ( $groups -ne $null )
                        {
                            foreach ( $group in $groups)
                            {
                                $grpName = ConvertSIDToName $group

                                if ( $grpName -ne $null)
                                {
                                    $groupNames += @($grpName)
                                }
                                else
                                {
                                    $groupNames += @($group)
                                }
                            }
                        }
                    }

                    $str = "NAS-Port-Type="
                    $res = $text  -clike "*$str*"
                    if ( $res -ne $false )
                    {
                        $nasPortTypeisVirtualVPN = NASPortTypeVPN $text
                    }

                    $str = "UserAuthType:"
                    $res = $text  -clike "*$str*"
                    if ( $res -ne $false )
                    {
                        $authMethod = GetAuthMethod $text
                    }

                    $str = "SHV("""
                    $res = $text  -clike "*$str*"
                    if ( $res -ne $false )
                    {
                        $hpName = $null
                        $hpName = GetHealthPolicyName $text

                        if ( $hpName -ne $null )
                        {
                            $healthPoliciesUsed += @($hpName)
                        }
                    }
                }


                $AuthStr = "None"

                $node = $XMLData.Root.Children.Microsoft_Internet_Authentication_Service.Children.RadiusProfiles.Children

                $policyNodes2 = $node.ChildNodes

                $nodeToCheck = $null

                foreach ( $policyNode2 in $policyNodes2)
                {
                    $namePolNode = $policyNode2.Name
                    if ( $namePolNode -eq $name )
                    {
                        $nodeToCheck = $policyNode2
                        break
                    }
                }

                $propNode = $nodeToCheck.Properties

                $props = $propNode.ChildNodes

                $authNegoAlreadySeen = $false
                $savedMachHalthChkOnly = $false

                foreach ( $prop in $props )
                {
                    $propName = $prop.Name

                    if ( $propName -eq "msNPAllowDialin")
                    {
                        $propText = $prop.InnerText

                        if ( $propText -eq 1 )
                        {
                            $policyIsAllowAccess = $true
                        }
                    }

                    if ( $propName -eq "msSavedMachineHealthCheckOnly")
                    {
                        $savedMachHalthChkOnly = $true
                        if ( $AllowCleintWithoutAuthNego -eq $true )
                        {
                            $AllowCleintWithoutAuthNego = $false
                        }
                    }

                    if ( $propName -eq "msNPAuthenticationType2")
                    {

                        if ( ( $authNegoAlreadySeen -eq $false ) -and (  $savedMachHalthChkOnly -eq $false ) )
                        {
                            $propText = $prop.InnerText

                            if ( $propText -eq 7 )
                            {
                                $AllowCleintWithoutAuthNego = $true
                            }

                            $authNegoAlreadySeen = $true
                        }
                        else
                        {
                            if ( $AllowCleintWithoutAuthNego -eq $true )
                            {
                                $AllowCleintWithoutAuthNego = $false
                            }
                        }

                    }
        
                }

                $PolicyObject.A1CAPPolicyName = $policy.Name

                $NumVal = 0
                $NumVal = BoolToNum $policyIsAllowAccess

                $PolicyObject.A2PolicyAllowConenction = $NumVal

                $NumVal = 0
                $NumVal = BoolToNum $AllowCleintWithoutAuthNego

                $PolicyObject.A3AllowClientWithoutAuthNego = $NumVal

                $NumVal = 0
                $NumVal = BoolToNum $nasPortTypeisVirtualVPN

                $PolicyObject.A4NASPortTypeVPN = $NumVal

                $grpCount = $groupNames.Count

                $PolicyObject.A5NumberUserGroups = $grpCount

                $PolicyObject.A6AuthenticationSet = $authMethod

                $hlthPolCnt = $healthPoliciesUsed.Count

                $PolicyObject.A7NumberHealthPolicies = $hlthPolCnt

                $CAPPolicyIsCompliant = $false

                if ( ( $policyIsAllowAccess -eq $true) -and ( $AllowCleintWithoutAuthNego -eq $true ) -and ( $nasPortTypeisVirtualVPN -eq $true) -and ( $grpCount -ge 1) -and ( $authMethod -ne 0 ) )
                {
                    $CAPPolicyIsCompliant = $true
                }  

                $NumVal = 0
                $NumVal = BoolToNum $CAPPolicyIsCompliant

                $PolicyObject.A8PolicyCompliant = $NumVal

                if ( $CAPPolicyIsCompliant -eq $false )
                {
                    $NumberCAPSNonCompliant += 1
                    $NamesNonCompliantCAPS += """" + $policy.Name + """ "
                }

                $CAPPoliciesToAddToXML += @($PolicyObject)
            }

        }

        $CAPPoliciesActiveState = 0

        if ( $NumberCapsActive -ge 1 )
        {
            $CAPPoliciesActiveState = 1
        }

        $someCapPoliciesNonCompliant = 0

        if ( $NumberCAPSNonCompliant -gt 0 )
        {
            $someCapPoliciesNonCompliant = 1
        }            

        if ( $centralCAPEnabled -eq $false )
       {
            AddElementToDocument $doc $tns $CAPPoliciesActiveState "TSGateway" "CAPSetup" "NumberCAPPoliciesActive"

            if ( $NumberCAPSconfigured -ge 1)
            {
                AddElementToDocument $doc $tns $someCapPoliciesNonCompliant "TSGateway" "CAPSetup" "SomeCAPPoliciesNonCompliant"
            }

            if ( $NumberCAPSNonCompliant -gt 0 )
            {
                AddElementToDocument $doc $tns $NamesNonCompliantCAPS "TSGateway" "CAPSetup" "NamesCAPPoliciesNonCompliant"
            }
        }
        else
        {
            if ( $NAPServerRechable -eq $true)
            {
                AddElementToDocument $doc $tns $CAPPoliciesActiveState "TSGateway" "CAPSetup" "NumberCAPPoliciesActive"

                if ( $NumberCAPSconfigured -ge 1)
                {
                    AddElementToDocument $doc $tns $someCapPoliciesNonCompliant "TSGateway" "CAPSetup" "SomeCAPPoliciesNonCompliant"
                }

                if ( $NumberCAPSNonCompliant -gt 0 )
                {
                    AddElementToDocument $doc $tns $NamesNonCompliantCAPS "TSGateway" "CAPSetup" "NamesCAPPoliciesNonCompliant"
                }
            }
        }
     
        if ( $NumberCAPSconfigured -ge 1)
        {
            $rootElement = $doc.DocumentElement
            $tsgRootElement = $rootElement.childNodes | where { $_.name -eq "TSGateway"}
            $CAPSetupNode = $tsgRootElement.childNodes | where { $_.name -eq "CAPSetup"}
            Append-Elements $doc $CAPSetupNode $tns "CAPPolicy" $CAPPoliciesToAddToXML
        }

        if ( $delFile -eq $true )
        {
            del $file
        }

        #
        # Count of RAPs
        #
        $countTSGatewayRAPs = CountOfWMIClassInstance "Win32_TSGatewayResourceAuthorizationPolicy" "root\CIMV2\TerminalServices"

        $countActiveTSGatewayRAPs = 0    
        if ( $countTSGatewayRAPs -ge 1 )
        {
            #
            # Count of Active RAPs
            #
            $countActiveTSGatewayRAPs = CountOfEnabledWMIClassInstance "Win32_TSGatewayResourceAuthorizationPolicy" "root\CIMV2\TerminalServices"
        }

        #
        # Adding thie value to the XML Document
        # 
        AddElementToDocument $doc $tns $countActiveTSGatewayRAPs "TSGateway" "RAPSetup" "NumberRAPPoliciesActive"
    }
##### CAP/RAP and NPS checking stuff ends here
    
    #
    # Check for unlimited connections allowed setting on TSG
    #
    $maxConnectionsAllowed = 0

    $connectionsExhausted = $true  

    $unlimitedConectionsAllowed = UnlimitedconnectionsSettingTSG 

    if ( $unlimitedConectionsAllowed -eq $false)
    {
        $maxConnectionsAllowed = NumberConnectionsAllowedByTSG

        if ( $maxConnectionsAllowed -ne 0 )
        {
            $connectionsExhausted = TSGConnectionsExhausted $maxConnectionsAllowed 
        }

    }
    else
    {
        $maxConnectionsAllowed = 1

        $connectionsExhausted = $false        
    }

    AddElementToDocument $doc $tns $maxConnectionsAllowed "TSGateway" "MaxConnectionsAllowed"

    $NumVal = 0
    $NumVal = BoolToNum $connectionsExhausted

    AddElementToDocument $doc $tns $NumVal "TSGateway" "ConnectionsExhausted"

    #
    # Check if server is load balanced
    #

    [Object] $LoadBalancingServerInstance = Get-WmiObject "Win32_TSGatewayLoadBalancer" -namespace "root\CIMV2\TerminalServices"

    if ( $LoadBalancingServerInstance -eq $null )
    {
        $loadBalancedServers = $null
    }
    else
    {
        $loadBalancedServers = $LoadBalancingServerInstance.Servers
    }   

    $gatewayFarmConfigured = 0
    
    if ( ( $loadBalancedServers -eq $null ) -or ( $loadBalancedServers.Length -eq 0 ) )
    {
        $gatewayFarmConfigured = 0
    }
    else
    {
        $gatewayFarmConfigured = 1
    }

    AddElementToDocument $doc $tns $gatewayFarmConfigured "TSGateway" "GatewayFarmConfigured"

    $webSitename = $null

    $RPCRegKeyPAth = "HKLM:\SOFTWARE\Microsoft\Rpc\RpcProxy"

    $webSitename = $webSitename = GetValueFromRegistry "$RPCRegKeyPAth" "Website" 

    if ( ( $webSitename -eq $null ) -or ( $webSitename.Length -le 0 ) )
    {
        $webSitename = "Default Web Site"
    }    

    AddElementToDocument $doc $tns $webSitename "TSGateway" "IISConfiguration" "WebSiteName"

    $winPath = $env:windir

    $appCmd = "$winPath\system32\inetsrv\AppCmd.exe"
        
    $op = & $appCmd List site "$webSitename"

    $siteConfigured = $false

    if ( ($op -ne $null ) -or ( $op.Length -ge 1 ) )
    {
        $siteConfigured = $true
    }
           
    $NumVal = 0
    $NumVal = BoolToNum $siteConfigured

    AddElementToDocument $doc $tns $NumVal "TSGateway" "IISConfiguration" "WebSiteConfigured"

    if ( $siteConfigured -eq $true )
    {
        $siteRuning = IsSiteRuning ( $webSitename )
        $NumVal = 0
        $NumVal = BoolToNum $siteRuning
        AddElementToDocument $doc $tns $NumVal "TSGateway" "IISConfiguration" "WebSiteRunning"

        $certForSite = $null

        $certConfigured = 0

        $certCompliant = 0

        $certNameIsFQDN = 0

        $certForSite = GetCertForWebsite "$webSitename"

        if ( $certForSite -ne $null )
        {
            $certConfigured = 1

            $certCompliant = 1
        }            

        AddElementToDocument $doc $tns $certConfigured "TSGateway" "CertConfiguration" "CertConfigured"

        if ( $certConfigured -eq 1 )
        {
            $subjCert = $certForSite.Subject

            if ( $subjCert -ne $null )
            {
                $CompNameInSubj = ($subjCert.Split("="))[1]
                AddElementToDocument $doc $tns $CompNameInSubj "TSGateway" "CertConfiguration" "CertSubject"
            }

            $startDate = $certForSite.NotBefore
 
            $endDate = $certForSite.NotAfter

            $dateNow = get-date

            $comp1 = -1

            $comp2 = -1

            if ( $startDate -ne $null )
            {
                $comp1 = $dateNow.CompareTo($startDate)
            }
            else
            {
                $certCompliant = 0
            }

            if ( $endDate -ne $null )
            {
                $comp2 = $endDate.CompareTo($dateNow)
            }
            else
            {
                $certCompliant = 0
            }

            $certActive = $false;
            $certExpired = $true

            if ( $comp1 -ge 0)
            {
                $certActive = $true
            }
            else
            {
                $certCompliant = 0
            }

            if ( $comp2 -ge 1)
            {
                $certExpired = $false
            }
            else
            {
                $certCompliant = 0
            }
            
            $NumVal = 0
            $NumVal = BoolToNum $certActive                   

            AddElementToDocument $doc $tns $NumVal "TSGateway" "CertConfiguration" "CertActive"
 
            if ( $NumVal -ne 0)
            {
                $NumVal = 0
                $NumVal = BoolToNum $certExpired                   

                AddElementToDocument $doc $tns $NumVal "TSGateway" "CertConfiguration" "CertExpired"
 
                if ( $certExpired -eq $false)
                {
                    $NumVal = 1
                }
            }

            if ( $NumVal -ne 0)
            {
                $match = 0
                $match = CheckIfCertSubjectMatchesCurrentMachineName $certForSite

                if ( $match -eq 2 )
                {
                    $certCompliant = 0
                }
                
                if ( $match -eq 1 )
                {
                    $certNameIsFQDN = 1
                }

                AddElementToDocument $doc $tns $match "TSGateway" "CertConfiguration" "CertSubjectMatchesCompName"

                AddElementToDocument $doc $tns $certNameIsFQDN "TSGateway" "CertConfiguration" "CertNameIsFQDN"

                $NumVal = $match
            }



            $certIsSelfSigned = CheckIfCertIsSelfSigned $certForSite

            if ( $certIsSelfSigned -eq 0)
            {
                $certIsCACert = 1
            }
            else
            {
                $certIsCACert = 0
            }

            AddElementToDocument $doc $tns $certIsCACert "TSGateway" "CertConfiguration" "CertIsCACert"
        }

    AddElementToDocument $doc $tns $certCompliant "TSGateway" "CertConfiguration" "CertSettingsCompliant"

    }

    $conenctOnlyToWin7Clients = $false

    $conenctOnlyToWin7Clients = IsConenctOnlyToWin7clientsSet 

    $NumVal = 0
    $NumVal = BoolToNum $conenctOnlyToWin7Clients                   

    AddElementToDocument $doc $tns $NumVal "TSGateway" "ConenctOnlytoWin7Client"

    #
    # Find out if the AD for this machine is reachable (in case this machine is attached to a domain)
    #

    [Object] $ComputerSystemInstance = Get-WmiObject "Win32_ComputerSystem" -namespace "root\CIMV2"

    if ($ComputerSystemInstance.PartOfDomain -eq $true)
    {
        $dom = $null
        $dcReachable = $false

        Try 
        {
            $dom = [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain()
        } Catch {
            #Nothing
        }

        if ( $dom -eq $null )
        {
            Try 
            {
                $dom = [System.DirectoryServices.ActiveDirectory.Domain]::getcomputerdomain()
            } catch [System.Security.Authentication.AuthenticationException] {
                # If computer is part of domain and got authentication exception, user needs to login as domain user
                $NumVal = 2
            } catch {
                # For any other exception, such as NIC disabled etc, give error
                $NumVal = 0
            }
        }


        if ( $dom -ne $null )
        {
            $dcInstances = $null

            $domName = $dom.Name
 
            $dcInstances = $dom.FindAllDomainControllers()

            if ($dcInstances -ne $null)
            {
                $numItm = $dcInstances.Count

                for ($i=0;$i -lt $numItm; $i += 1)
                {

                    $dcName = $dcInstances.Item($i)

                    $reachable = $false

                    $reachable = IsComputerReachable ( $dcName )

                    if ( $reachable -eq $true )
                    {
                        $dcReachable = $true
                        break
                    }
                }

            }

            $NumVal = 0
            $NumVal = BoolToNum $dcReachable   
            AddElementToDocument $doc $tns $NumVal "TSGateway" "ADForDomainReachable"
        }
        else
        {
            AddElementToDocument $doc $tns $NumVal "TSGateway" "ADForDomainReachable"
        }
    }

    #
    # Find out if the TS Gateway service is runing or not
    #  
    $gwSvc = $null

    $gwSvc = get-Service tsgateway

    if ( $gwSvc -ne $null )
    {
        $gwSvcRunning = $false

        $status = $gwSvc.Status

        if ( $status -eq "Running" )
        {
            $gwSvcRunning = $true
        }

        $NumVal = 0
        $NumVal = BoolToNum $gwSvcRunning   
        AddElementToDocument $doc $tns $NumVal "TSGateway" "RDGatewaySvcStarted"
    }

    if ( $gatewayFarmConfigured -eq 1 )
    {   
        $OSVersionThisComp = $null
        $OSVersionThisComp = GetOSVersionComp "."

        $serverList = $loadBalancedServers.split(";")

        $co = @()

        foreach ($server in $serverList)
        {
            $serverReachable = $false

            $serverReachableOrOSSameNum  = 0

            $serverReachable = IsComputerReachable $server

            if ( $serverReachable -eq $true )
            {
                $RemoteCompOSVer = $null

                Try {
                    $RemoteCompOSVer = GetOSVersionComp "$server"
                } Catch { 
                   #Nothing
                }

                if ( ( $RemoteCompOSVer -ne $null ) -and ( $OSVersionThisComp -ne $null ) )
                {
                    if ( $RemoteCompOSVer -eq $OSVersionThisComp )
                    {
                        $serverReachableOrOSSameNum = 1
                    }
                }
            }

            $value = "" | Select-Object ServerName,serverReachableOrOSSameNum  

            $value.ServerName = $server
            $value.serverReachableOrOSSameNum  = $serverReachableOrOSSameNum 

            $co += $value
        }      

        $totalNumServers = $co.count

        $noServerWithError = 1

        foreach ( $element in $co )
        {
            $valTocheck = $element.serverReachableOrOSSameNum 
            if ( $valTocheck -eq 0 )
            {
                $noServerWithError = 0
                break
            }

        }


        AddElementToDocument $doc $tns $noServerWithError "TSGateway" "LoadBalancedServerComposite" "LoadBalancedServersErrorFree"
        
    }
  
}

#
# If TS-Licensing is installed, we need to get activation status of Licensing Server
#
if ( $TSLicensingInstalled -eq $true )
{

    #
    # Create WMI .NET object (as we need to call a method on it)
    #
    $LicenseServerObj = [WMICLASS] "root\cimv2:Win32_TSLicenseServer"
    
    #
    # Obtain ActivationStatus from the object
    #
    $licenseServerActivationStatus = $LicenseServerObj.GetActivationStatus().ActivationStatus

    #
    # Adding thie value to the XML Document
    # 
    AddElementToDocument $doc $tns $licenseServerActivationStatus "TSLicensing" "ActivationStatus"
    
    $CALAvailable = IsCALAvailable
    AddElementToDocument $doc $tns $CALAvailable "TSLicensing" "CALAvailable"

}

#
# If TS-TerminalServer is installed, we need to get number of users in Remote Desktop Users Group
#
if ( $TSTerminalServerInstalled -eq $true )
{
    $SvcRunning = IsServiceRunning termservice
    $NumSvcRunning = 0
    $NumSvcRunning = BoolToNum $SvcRunning
    AddElementToDocument $doc $tns $NumSvcRunning "TSTerminalServer" "RDSServiceRunning"

}


#   check connection broker rules
#
if ($RDConnectionBrokerInstalled -eq $true )
{
    $SvcRunning = IsServiceRunning tssdis
    $NumSvcRunning = 0
    $NumSvcRunning = BoolToNum $SvcRunning
    AddElementToDocument $doc $tns $NumSvcRunning "RDConnectionBroker" "RDCBServiceRunning"

}

#   check RDWA rules
#
if ($RDWebAccessInstalled -eq $true )
{
    $SvcRunning = IsServiceRunning w3svc
    $NumSvcRunning = 0
    $NumSvcRunning = BoolToNum $SvcRunning
    AddElementToDocument $doc $tns $NumSvcRunning "RDWebAccess" "RDWebAccessServiceRunning"

}


#   check  RDVH rules
#
if ($RDVHInstalled -eq $true )
{
    $SvcRunning = IsServiceRunning vmhostagent
    $NumSvcRunning = 0
    $NumSvcRunning = BoolToNum $SvcRunning
    AddElementToDocument $doc $tns $NumSvcRunning "RDVH" "RDVHServiceRunning"

}

#
# The following rule is not associated with any role since it is expected to run to machines 
# without RS roles installed. 
# TODO: CheckCollection should take a parameter which is the RDMS Server name. It should be supplied to the
# gwmi call on the rdms name space. 
#

#$RDSHCollectionCheck = CheckRDSHCollection
#AddElementToDocument $doc $tns $RDSHCollectionCheck "RDMS" "RDSHCollection" "RDSHCollectionStatus"    

#
# send the document to the output stream
#
$doc

#
# ------------------------
# SCRIPT MAIN BODY - END
# ------------------------
#
# SIG # Begin signature block
# MIIkKAYJKoZIhvcNAQcCoIIkGTCCJBUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU35CeNpVHu0E6AhSPrj639xc/
# 1tuggh7hMIIEEjCCAvqgAwIBAgIPAMEAizw8iBHRPvZj7N9AMA0GCSqGSIb3DQEB
# BAUAMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQgQ29y
# cC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWlj
# cm9zb2Z0IFJvb3QgQXV0aG9yaXR5MB4XDTk3MDExMDA3MDAwMFoXDTIwMTIzMTA3
# MDAwMFowcDErMCkGA1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBD
# b3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhN
# aWNyb3NvZnQgUm9vdCBBdXRob3JpdHkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCpAr3BcOY78k4bKJ+XeF4w6qKpjSVf+P6VTKO3/p2iID58UaKboo9g
# MmvRQmR57qx2yVTa8uuchhyPn4Rms8VremIj1h083g8BkuiWxL8tZpqaaCaZ0Dos
# vwy1WCbBRucKPjiWLKkoOajsSYNC44QPu5psVWGsgnyhYC13TOmZtGQ7mlAcMQgk
# FJ+p55ErGOY9mGMUYFgFZZ8dN1KH96fvlALGG9O/VUWziYC/OuxUlE6u/ad6bXRO
# rxjMlgkoIQBXkGBpN7tLEgc8Vv9b+6RmCgim0oFWV++2O14WgXcE2va+roCV/rDN
# f9anGnJcPMq88AijIjCzBoXJsyB3E4XfAgMBAAGjgagwgaUwgaIGA1UdAQSBmjCB
# l4AQW9Bw72lyniNRfhSyTY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykg
# MTk5NyBNaWNyb3NvZnQgQ29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCLPDyI
# EdE+9mPs30AwDQYJKoZIhvcNAQEEBQADggEBAJXoC8CN85cYNe24ASTYdxHzXGAy
# n54Lyz4FkYiPyTrmIfLwV5MstaBHyGLv/NfMOztaqTZUaf4kbT/JzKreBXzdMY09
# nxBwarv+Ek8YacD80EPjEVogT+pie6+qGcgrNyUtvmWhEoolD2Oj91Qc+SHJ1hXz
# UqxuQzIH/YIX+OVnbA1R9r3xUse958Qw/CAxCYgdlSkaTdUdAqXxgOADtFv0sd3I
# V+5lScdSVLa0AygS/5DW8AiPfriXxas3LOR65Kh343agANBqP8HSNorgQRKoNWob
# ats14dQcBOSoRQTIWjM4bk0cDWK3CqKM09VUP0bNHFWmcNsSOoeTdZ+n0qAwggQS
# MIIC+qADAgECAg8AwQCLPDyIEdE+9mPs30AwDQYJKoZIhvcNAQEEBQAwcDErMCkG
# A1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jvc29mdCBDb3JwLjEeMBwGA1UE
# CxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgUm9v
# dCBBdXRob3JpdHkwHhcNOTcwMTEwMDcwMDAwWhcNMjAxMjMxMDcwMDAwWjBwMSsw
# KQYDVQQLEyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYD
# VQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBS
# b290IEF1dGhvcml0eTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkC
# vcFw5jvyThson5d4XjDqoqmNJV/4/pVMo7f+naIgPnxRopuij2Aya9FCZHnurHbJ
# VNry65yGHI+fhGazxWt6YiPWHTzeDwGS6JbEvy1mmppoJpnQOiy/DLVYJsFG5wo+
# OJYsqSg5qOxJg0LjhA+7mmxVYayCfKFgLXdM6Zm0ZDuaUBwxCCQUn6nnkSsY5j2Y
# YxRgWAVlnx03Uof3p++UAsYb079VRbOJgL867FSUTq79p3ptdE6vGMyWCSghAFeQ
# YGk3u0sSBzxW/1v7pGYKCKbSgVZX77Y7XhaBdwTa9r6ugJX+sM1/1qcaclw8yrzw
# CKMiMLMGhcmzIHcThd8CAwEAAaOBqDCBpTCBogYDVR0BBIGaMIGXgBBb0HDvaXKe
# I1F+FLJNjv/LoXIwcDErMCkGA1UECxMiQ29weXJpZ2h0IChjKSAxOTk3IE1pY3Jv
# c29mdCBDb3JwLjEeMBwGA1UECxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEwHwYD
# VQQDExhNaWNyb3NvZnQgUm9vdCBBdXRob3JpdHmCDwDBAIs8PIgR0T72Y+zfQDAN
# BgkqhkiG9w0BAQQFAAOCAQEAlegLwI3zlxg17bgBJNh3EfNcYDKfngvLPgWRiI/J
# OuYh8vBXkyy1oEfIYu/818w7O1qpNlRp/iRtP8nMqt4FfN0xjT2fEHBqu/4STxhp
# wPzQQ+MRWiBP6mJ7r6oZyCs3JS2+ZaESiiUPY6P3VBz5IcnWFfNSrG5DMgf9ghf4
# 5WdsDVH2vfFSx73nxDD8IDEJiB2VKRpN1R0CpfGA4AO0W/Sx3chX7mVJx1JUtrQD
# KBL/kNbwCI9+uJfFqzcs5HrkqHfjdqAA0Go/wdI2iuBBEqg1ahtq2zXh1BwE5KhF
# BMhaMzhuTRwNYrcKoozT1VQ/Rs0cVaZw2xI6h5N1n6fSoDCCBGAwggNMoAMCAQIC
# Ci6rEdxQ/1ydy8AwCQYFKw4DAh0FADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNzA4
# MjIyMjMxMDJaFw0xMjA4MjUwNzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25pbmcg
# UENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt3l91l2zRTmoNKwx
# 2vklNUl3wPsfnsdFce/RRujUjMNrTFJi9JkCw03YSWwvJD5lv84jtwtIt3913UW9
# qo8OUMUlK/Kg5w0jH9FBJPpimc8ZRaWTSh+ZzbMvIsNKLXxv2RUeO4w5EDndvSn0
# ZjstATL//idIprVsAYec+7qyY3+C+VyggYSFjrDyuJSjzzimUIUXJ4dO3TD2AD30
# xvk9gb6G7Ww5py409rQurwp9YpF4ZpyYcw2Gr/LE8yC5TxKNY8ss2TJFGe67SpY7
# UFMYzmZReaqth8hWPp+CUIhuBbE1wXskvVJmPZlOzCt+M26ERwbRntBKhgJuhgCk
# wIffUwIDAQABo4H6MIH3MBMGA1UdJQQMMAoGCCsGAQUFBwMDMIGiBgNVHQEEgZow
# gZeAEFvQcO9pcp4jUX4Usk2O/8uhcjBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMp
# IDE5OTcgTWljcm9zb2Z0IENvcnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xITAfBgNVBAMTGE1pY3Jvc29mdCBSb290IEF1dGhvcml0eYIPAMEAizw8
# iBHRPvZj7N9AMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFMwdznYAcFuv8drE
# TppRRC6jRGPwMAsGA1UdDwQEAwIBhjAJBgUrDgMCHQUAA4IBAQB7q65+SibyzrxO
# dKJYJ3QqdbOG/atMlHgATenK6xjcacUOonzzAkPGyofM+FPMwp+9Vm/wY0SpRADu
# lsia1Ry4C58ZDZTX2h6tKX3v7aZzrI/eOY49mGq8OG3SiK8j/d/p1mkJkYi9/uEA
# uzTz93z5EBIuBesplpNCayhxtziP4AcNyV1ozb2AQWtmqLu3u440yvIDEHx69dLg
# Qt97/uHhrP7239UNs3DWkuNPtjiifC3UPds0C2I3Ap+BaiOJ9lxjj7BauznXYIxV
# hBoz9TuYoIIMol+Lsyy3oaXLq9ogtr8wGYUgFA0qvFL0QeBeMOOSKGmHwXDi86er
# zoBCcnYOMIIEajCCA1KgAwIBAgIKYQ94TQAAAAAAAzANBgkqhkiG9w0BAQUFADB5
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpN
# aWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQTAeFw0wNzA4MjMwMDIzMTNaFw0wOTAy
# MjMwMDMzMTNaMHQxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# HjAcBgNVBAMTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAKLbCo3PwsFJm82qOjStI1lr22y+ISK3lMjqrr/G1SbC
# MhGLvNpdLPs2Vh4VK66PDd0Uo24oTH8WP0GsjUCxRogN2YGUrZcG0FdEdlzq8fwO
# 4n90ozPLdOXv42GhfgO3Rf/VPhLVsMpeDdB78rcTDfxgaiiFdYy3rbyF6Be0kL71
# FrZiXe0R3zruIVuLr4Bzw0XjlYl3YJvnrXfBN40zFC8T22LJrhqpT5hnrdQgOTBx
# 4I1nRuLGHPQNUHRBL+gFJGoha0mwksSyOcdCpW1cGEqrj9eOgz54CkfYpLKEI8Pi
# 8ntmsUp0vSZBS5xhFGBOMMiC89ALcHzuVU130ghVdoECAwEAAaOB+DCB9TAOBgNV
# HQ8BAf8EBAMCBsAwHQYDVR0OBBYEFPMhQI58UfhUS5jlF9dqgzQFLiboMBMGA1Ud
# JQQMMAoGCCsGAQUFBwMDMB8GA1UdIwQYMBaAFMwdznYAcFuv8drETppRRC6jRGPw
# MEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kv
# Y3JsL3Byb2R1Y3RzL0NTUENBLmNybDBIBggrBgEFBQcBAQQ8MDowOAYIKwYBBQUH
# MAKGLGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvQ1NQQ0EuY3J0
# MA0GCSqGSIb3DQEBBQUAA4IBAQBAV29TZ54ggzQBDuYXSzyt69iBf+4NeXR3T5dH
# GPMAFWl+22KQov1noZzkKCn6VdeZ/lC/XgmzuabtgvOYHm9Z+vXx4QzTiwg+Fhcg
# 0cC1RUcIJmBXCUuU8AjMuk1u8OJIEig1iyFy31+2r2kSJJTu6TQJ235ub5IKUsoq
# TEmqMiyG6KHMXSa8vDzgW7KDC7o1HE+ERUf/u5ShWQeplt14vVd/padOzPKtnJpB
# 4stcJD7cfzRHTvbPyHud67bJnGMUU6+tmu/Xv8+goauVynorhyzAx9n8bAPavzit
# 8dFcGRcPwPfKgKYQCBrdkCPnsKFMPuqwESZ4DsEsuaRrx488MIIEnTCCA4WgAwIB
# AgIKYUdSugAAAAAABDANBgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEG
# A1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWlj
# cm9zb2Z0IENvcnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1w
# aW5nIFBDQTAeFw0wNjA5MTYwMTUzMDBaFw0xMTA5MTYwMjAzMDBaMIGmMQswCQYD
# VQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEe
# MBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMScwJQYDVQQLEx5uQ2lwaGVy
# IERTRSBFU046RDhBOS1DRkNDLTU3OUMxJzAlBgNVBAMTHk1pY3Jvc29mdCBUaW1l
# c3RhbXBpbmcgU2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
# AJtt3IZR6DI7NzqWJbLPb+5htUHSGDtanXhnuvgf2QhVkoh+40FT+uwoVP612v5w
# O5UnSH5DoDIvJoFK8gJ2d8jJqfiiIVh+Db0B2iTG/kQRBTU6AajqVAozLIfSfkGz
# 6AnZsL7jmSWmvCXt19OO2/S3bRtJC+bTw4du7kbJf/Nt6+eDHqhTRj/KJH7mfMks
# +3kUKEXATzZrUxqnhrPn/OHBn1EJ27ylu/7Khwn2tzIZvuFKUby8fKwslWqXc+py
# V6Gci4bYm71L/CczwW0yrOBoGNhuOi4iQ9H5j+3xAAENZMDJo90P8cjpVMoR/9x4
# KT4drFjA29+q3K5lG9OdvGcCAwEAAaOB+DCB9TAdBgNVHQ4EFgQUTxiJitLKAHjG
# 7FkND/18xMEigN4wHwYDVR0jBBgwFoAUb+hOP5e5NKtLho+8nOqsO0FDxtAwRAYD
# VR0fBD0wOzA5oDegNYYzaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwv
# cHJvZHVjdHMvdHNwY2EuY3JsMEgGCCsGAQUFBwEBBDwwOjA4BggrBgEFBQcwAoYs
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy90c3BjYS5jcnQwEwYD
# VR0lBAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQDAgbAMA0GCSqGSIb3DQEBBQUA
# A4IBAQA3Jx71jEDg9mUmPmTEkLw+41eF3UMNQIRnvoeoKtrctDYgmI4zfC5f4FB7
# YTHzGhPehL3qaRxYfLMbk+EIJ4FFttRwyhS3X7pX6dRe0DtDqrc/ttphi3HP1H3V
# e26/tMpaMJHf2goOozWfJWFOwDJ0K3oGlHIArBidS+WeK8U6VKykYNin95t/2alt
# 7URrutzgEvrwrYcMlWMKMh6JTszMfqc3pf5f2Gf6RkvRbR2nfdK+Av/zboLzh3TE
# aeW5cMxLZaMHNalEnoR9OW7+FAW9GlAhtT6f83ccj8KanVfhaX1p6IPPAm8qIrs3
# Mzpy+tYwHZGt9lAa6xPeOsW3XM2zMIIEnTCCA4WgAwIBAgIKYUl87QAAAAAABTAN
# BgkqhkiG9w0BAQUFADB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQTAeFw0wNjA5
# MTYwMTU1MjJaFw0xMTA5MTYwMjA1MjJaMIGmMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMScwJQYDVQQLEx5uQ2lwaGVyIERTRSBFU046MTBEOC01
# ODQ3LUNCRjgxJzAlBgNVBAMTHk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcgU2Vydmlj
# ZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOq6BWPI2XmuhEQ+pbPE
# 7UyeJN85dh4J1jJKWHjSK9mlB5Dv5z37vSZ8o/vlfX4yz9k9izk38vjYOzQW1JKC
# +zTsaIVyGo/guEzguIXzMwoCwaJ2czVMXfG34Up9HbiUeNv/HoUVQkZxzn8nVxLR
# g087z/re9ovtPwDj1d5h+ReNS6SBPPVpQOrhib8HT7p0e+kM5Ufqq2zx1WeBCPgW
# yn0Tu3PiCUz6YvvtoDmaOv7rEchhHmJY2ApUg9U7S0viVb0vYBqOkgVD2l3rggoj
# lwmgBTFli5NOHkEhopKQ/UVERW81sUU3rWmpZfk0Q7EXwjs54RCM8hqH41RQHzud
# Ma0CAwEAAaOB+DCB9TAdBgNVHQ4EFgQUfnLwLj9WKeAl92i4AfxL4X7P4z4wHwYD
# VR0jBBgwFoAUb+hOP5e5NKtLho+8nOqsO0FDxtAwRAYDVR0fBD0wOzA5oDegNYYz
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvdHNwY2Eu
# Y3JsMEgGCCsGAQUFBwEBBDwwOjA4BggrBgEFBQcwAoYsaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraS9jZXJ0cy90c3BjYS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgbAMA0GCSqGSIb3DQEBBQUAA4IBAQBpeoIJDBbR3s9G
# iS6/0TR6gX8nKEEq89Mhkg6XrV9TXin57cFUSqh99xPQCxT5TfKGFQBu44MdKEWn
# LDky3W+aN1ruI1KPVAONP6ecZDj2NsgUQ7Y6PpjJDcNxgSjzZqcx4lxdj/lSUuFc
# 65OQnWkJTInR0XZMNA1q4XxEpytbg1R/RSQZJcSKRsUl4xmAaSkU9hfG8CIsgUZe
# K/T5psZ3PiNv+aZkhY6iYg2pLR6o5ZA+f/+wjvyX7PH9BK/NSc5adKz68xMfGznO
# o7TWvPS07sit8lYe+zzxyNYqRLy/nD99ZhjNsiBjCspAPWUyGXyyuD3BJkhOIhmZ
# bowwwfGRMIIEnTCCA4WgAwIBAgIQaguZT8AAJasR20UfWHpnojANBgkqhkiG9w0B
# AQUFADBwMSswKQYDVQQLEyJDb3B5cmlnaHQgKGMpIDE5OTcgTWljcm9zb2Z0IENv
# cnAuMR4wHAYDVQQLExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAfBgNVBAMTGE1p
# Y3Jvc29mdCBSb290IEF1dGhvcml0eTAeFw0wNjA5MTYwMTA0NDdaFw0xOTA5MTUw
# NzAwMDBaMHkxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD
# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xIzAh
# BgNVBAMTGk1pY3Jvc29mdCBUaW1lc3RhbXBpbmcgUENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEA3Ddu+6/IQkpxGMjOSD5TwPqrFLosMrsST1LIg+0+
# M9lJMZIotpFk4B9QhLrCS9F/Bfjvdb6Lx6jVrmlwZngnZui2t++Fuc3uqv0SpAtZ
# Iikvz0DZVgQbdrVtZG1KVNvd8d6/n4PHgN9/TAI3lPXAnghWHmhHzdnAdlwvfbYl
# BLRWW2ocY/+AfDzu1QQlTTl3dAddwlzYhjcsdckO6h45CXx2/p1sbnrg7D6Pl55x
# Dl8qTxhiYDKe0oNOKyJcaEWL3i+EEFCy+bUajWzuJZsT+MsQ14UO9IJ2czbGlXqi
# zGAG7AWwhjO3+JRbhEGEWIWUbrAfLEjMb5xD4GrofyaOawIDAQABo4IBKDCCASQw
# EwYDVR0lBAwwCgYIKwYBBQUHAwgwgaIGA1UdAQSBmjCBl4AQW9Bw72lyniNRfhSy
# TY7/y6FyMHAxKzApBgNVBAsTIkNvcHlyaWdodCAoYykgMTk5NyBNaWNyb3NvZnQg
# Q29ycC4xHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMY
# TWljcm9zb2Z0IFJvb3QgQXV0aG9yaXR5gg8AwQCLPDyIEdE+9mPs30AwEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFG/oTj+XuTSrS4aPvJzqrDtBQ8bQMBkGCSsG
# AQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
# AQH/MA0GCSqGSIb3DQEBBQUAA4IBAQCUTRExwnxQuxGOoWEHAQ6McEWN73NUvT8J
# BS3/uFFThRztOZG3o1YL3oy2OxvR+6ynybexUSEbbwhpfmsDoiJG7Wy0bXwiuEbT
# hPOND74HijbB637pcF1Fn5LSzM7djsDhvyrNfOzJrjLVh7nLY8Q20Rghv3beO5qz
# G3OeIYjYtLQSVIz0nMJlSpooJpxgig87xxNleEi7z62DOk+wYljeMOnpOR3jifLa
# OYH5EyGMZIBjBgSW8poCQy97Roi6/wLZZflK3toDdJOzBW4MzJ3cKGF8SPEXnBEh
# OAIch6wGxZYyuOVAxlM9vamJ3uhmN430IpaczLB3VFE61nJEsiP2MYIEsTCCBK0C
# AQEwgYcweTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEG
# A1UEAxMaTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0ECCmEPeE0AAAAAAAMwCQYF
# Kw4DAhoFAKCB3DAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3
# AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUcnt2wu0owSIEZSux
# vuaP/MnisucwfAYKKwYBBAGCNwIBDDFuMGygToBMAFQAZQByAG0AaQBuAGEAbAAg
# AFMAZQByAHYAaQBjAGUAcwAgAEIAZQBzAHQAIABQAHIAYQBjAHQAaQBjAGUAcwAg
# AE0AbwBkAGUAbKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcN
# AQEBBQAEggEALR/uuhZeiiOCgeXD18xAA7MQq1LppU8PAwyqK+MeYPbLcp6dPUOj
# gpiJw2LiRt7/koYfrwji+5W4imi2ir6mb2AldAy8XCtjEQcTrOhqmV4ZDdvgfJJF
# TiVItGssom7cJ6HDC4QVWrGUpEqP1PLjauPzhmGmUd2vhk3XTvFoXT8DrXhS+hpE
# iu8VQp4fVnANP4MqtFW5tJ6Yfvvhm86NcIIT/ucueIXBcK9/6VDNFlev6rbIaSVc
# DoG2vfqSi8yy6HHamZ+gvuHkvXRvx6WMsvAcfXjrndGvM6L18/YMFEdAYmPt92lw
# IO/tkd8v4nl5pf0+tYj+mPaKOfDpb+YCVaGCAh8wggIbBgkqhkiG9w0BCQYxggIM
# MIICCAIBATCBhzB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSMwIQYDVQQDExpNaWNyb3NvZnQgVGltZXN0YW1waW5nIFBDQQIKYUl87QAAAAAA
# BTAHBgUrDgMCGqBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcN
# AQkFMQ8XDTA4MDkxOTE5NDUxOFowIwYJKoZIhvcNAQkEMRYEFEHgT3+OFeiTT0Ub
# GghmBiBAa37GMA0GCSqGSIb3DQEBBQUABIIBALrpKlBoaY0QyXZe57LlcQtk1axZ
# hh0tw7LPTL0S5hbIgkJ93ZdmtmghIl54yQN7Apvjfk4qmAyqDGaI9vtJE/57gxAb
# jhd/kJAAWIYAlkFq3xOT3wxYopoa8p72hpZGDSRRjWWK/ATOwvp/mnrZ1h7mGWxu
# apDVnaYceBvLx5E82JkLI8pqZVI0BxcLLhalJcVWRDvdaAzEae/SSgxNmP65LjB7
# p0QTfRf+V4H37OCYqnvJZdQq6vr62wEEZ1fMGjBlDZ+80PmpHiUOIE5lvXjneOHu
# z2Weta84jC51CnQI6czDRJXcpb7Hhs3PrIHT8bCZTZ0bNeueweHKfJaGkuE=
# SIG # End signature block
