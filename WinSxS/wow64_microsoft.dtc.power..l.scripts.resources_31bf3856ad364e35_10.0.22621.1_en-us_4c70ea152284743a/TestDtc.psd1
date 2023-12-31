# Localized	05/07/2022 02:18 AM (GMT)	303:7.0.30723 	TestDtc.psd1
ConvertFrom-StringData @'
       
###PSLOC start localizing

FirewallRuleEnabled="{0}: Firewall rule for {1} is enabled."
FirewallRuleDisabled="{0}: Firewall rule for {1} is disabled. This computer cannot participate in network transactions."
CmdletFailed="The {0} cmdlet failed. Please make sure the {1} module is installed."
InvalidLocalComputer="{0} is not a valid local computer name."
RPCEndpointMapper="RPC Endpoint Mapper"
DtcIncomingConnection="DTC incoming connections"
DtcOutgoingConnection="DTC outgoing connections"
MatchingDtcNotFound="A DTC instance with VirtualServerName {0} does not exist."
InboundDisabled="{0}: Inbound transactions are not allowed and this computer cannot participate in network transactions."
OutboundDisabled="{0}: Outbound transactions are not allowed and this computer cannot participate in network transactions."
OSVersion="{0} Operating System Version: {1}."
OSQueryFailed="Failed to query operating system of {0}."
VersionNotSupported="Testing DTC on Windows versions below {0} is not supported with this cmdlet."
FailedToCreateCimSession="Failed to create a CIM Session to {0}."
NotARemoteComputer="{0} is not a remote computer."
PingingSucceeded="Pinging computer {0} from {1} succeeded."
PingingFailed="Pinging computer {0} from {1} failed."
SameCids="The {0} CID on {1} and {2} is the same. The CID should be unique to each computer."
DiagnosticTestPrompt="This diagnostic test will attempt to carry out a transaction propagation between {0} and {1}. It requires that a TCP port is opened on {0} so that a Test Resource Manager can participate in network transactions."
DefaultPortDescription="The default port is {0} and you can change it using the 'ResourceManagerPort' parameter and rerunning the test. "
PortDescription="You have specified {0} as the 'ResourceManagerPort'."
FirewallRequest="Please open port {0} in the firewall to proceed with the test."
QueryText="Do you want to proceed with the test?"
InvalidDefaultCluster="{0} is not the Virtual Server Name of the default DTC configured on this computer. You can use 'Set-DtcClusterDefault' cmdlet configure the default DTC on this computer."
InvalidDefault="{0} is not the Virtual Server Name of the default DTC configured on this computer. You can use 'Set-DtcDefault' cmdlet to configure the default DTC on this computer."
NeedDtcSecurityFix="DTC security settings and firewall settings should be fixed in order to complete the transactions propagation test."
StartResourceManagerFailed="Test resource manager creation failed."
ResourceManagerStarted="Test resource manager started."
PSSessionCreated="A new PSSession to {0} created."
TransactionPropagated="Transaction propagated from {0} to {1} using {2} propagation."
TransactionPropagationFailed="Transaction propagation {0} to {1} failed using {2} propagation."
TestRMVerboseLog="Test Resource Manager Verbose Log:"
TestRMWarningLog="Test Resource Manager Warning Log:"
InvalidParameters="At least one of LocalComputerName or RemoteComputerName parameters should be specified."

###PSLOC
'@
