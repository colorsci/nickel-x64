$typeDefinitions = @"
using System;
using System.Management.Automation;

namespace Microsoft.Windows.NetworkController
{
  public class NrpApiVersionAttribute : System.Attribute
  {
    public NrpApiVersionAttribute(string value)
    {
      this.Value = value;
    }
    public string Value
    {
      get; set;
    }
  }

  public class Sample
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.SampleResourceProperties  Properties;
  }

  public class SampleResourceProperties
  {
     public PSObject  PutExecuteDuration;
     public PSObject  PutBackgroundTaskDuration;
     public PSObject  DeleteExecuteDuration;
     public PSObject  DeleteBackgroundTaskDuration;
     public Boolean  IsStarted;
     public String  ProvisioningState;
  }

  public class ResourceProperties
  {
     public String  ProvisioningState;
  }

  public class IKeyedResourceList
  {
     public String  CollectionName;
     public Int32  Count;
  }

  public class InternalIDToResourceMapping
  {
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.InternalIDToResourceMappingProperties  Properties;
  }

  public class InternalIDToResourceMappingProperties
  {
     public String  ResourceReference;
     public String  ProvisioningState;
  }

  public class IResourceHashSet
  {
     public Int32  Count;
     public Boolean  IsReadOnly;
     public Microsoft.Windows.NetworkController.ReferenceScope  ReferenceScope;
     public String  CollectionName;
     public Microsoft.Windows.NetworkController.Resource  Parent;
  }

  public class ITopLevelResource
  {
     public String  Location;
     public PSObject  Tags;
     public Microsoft.Windows.NetworkController.ResourceProperties  Properties;
  }

  public class Resource
  {
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  Etag;
     public String  ProvisioningState;
     public Guid  InstanceId;
     public String  ResourceRef;
     public Microsoft.Windows.NetworkController.ResourceReferenceComparer  ReferenceComparer;
  }

  public class ResourceChild
  {
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  Etag;
     public String  ProvisioningState;
     public Guid  InstanceId;
     public String  ResourceRef;
  }

  public class ResourceDependency
  {
     public String  Name;
     public Microsoft.Windows.NetworkController.ResourceDependencyComparer  Comparer;
     public Microsoft.Windows.NetworkController.ReferenceScope  ReferenceScope;
     public Microsoft.Windows.NetworkController.Resource  Source;
     public Microsoft.Windows.NetworkController.Resource  Destination;
  }

  public class ResourceVersion
  {
     public Int32  Major;
     public Int32  Minor;
  }

  public class Subscription
  {
     public String  State;
     public DateTime  LastChangedDate;
     public PSObject  Properties;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ProvisioningState;
     public Guid  InstanceId;
     public String  ResourceRef;
  }

  public class Subnet
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.SubnetProperties  Properties;
  }

  public class SubnetProperties
  {
     public String  AddressPrefix;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     public Microsoft.Windows.NetworkController.ServiceInsertion  ServiceInsertion;
     public Microsoft.Windows.NetworkController.IpConfiguration[]  IpConfigurations;
  }

  public class AccessControlList
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.AccessControlListProperties  Properties;
  }

  public class AccessControlListProperties
  {
     public Microsoft.Windows.NetworkController.AccessControlListConfigurationState  ConfigurationState;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.AclRule[]  AclRules;
     public Microsoft.Windows.NetworkController.IpConfiguration[]  IpConfigurations;
     public Microsoft.Windows.NetworkController.Subnet[]  Subnets;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.SecurityTag[]  SecurityTags;
  }

  public class AclRule
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.AclRuleProperties  Properties;
  }

  public class AclRuleProperties
  {
     public String  Protocol;
     public String  SourcePortRange;
     public String  DestinationPortRange;
     public String  Action;
     public String  SourceAddressPrefix;
     public String  DestinationAddressPrefix;
     public String  Priority;
     public String  Description;
     public String  Type;
     public String  Logging;
     public String  ProvisioningState;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.SecurityTag[]  SourceSecurityTags;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.SecurityTag[]  DestinationSecurityTags;
  }

  public class LoadBalancerFrontendIpConfiguration
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfigurationProperties  Properties;
  }

  public class IpConfiguration
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.IpConfigurationProperties  Properties;
  }

  public class LoadBalancerFrontendIpConfigurationProperties
  {
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.ResourceCounter[]  Counters;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.LoadBalancerVipConfigurationState  ConfigurationState;
     public String  PrivateIPAddress;
     public String  PrivateIPAllocationMethod;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancingRule[]  LoadBalancingRules;
     public Microsoft.Windows.NetworkController.LoadBalancerInboundNatRule[]  InboundNatRules;
     public Microsoft.Windows.NetworkController.LoadBalancerOutboundNatRule[]  OutboundNatRules;
     public Microsoft.Windows.NetworkController.PublicIpAddress  PublicIPAddress;
     public Microsoft.Windows.NetworkController.Subnet  Subnet;
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     public Microsoft.Windows.NetworkController.ServiceInsertion  ServiceInsertion;
  }

  public class IpConfigurationProperties
  {
     public String  PrivateIPAddress;
     public String  PrivateIPAllocationMethod;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.PublicIpAddress  PublicIPAddress;
     public Microsoft.Windows.NetworkController.Subnet  Subnet;
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     public Microsoft.Windows.NetworkController.ServiceInsertion  ServiceInsertion;
  }

  public class LoadBalancerInboundNatRule
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerInboundNatRuleProperties  Properties;
  }

  public class LoadBalancerInboundRule
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerInboundRuleProperties  Properties;
  }

  public class LoadBalancerInboundNatRuleProperties
  {
     public Int32  FrontendPort;
     public Int32  BackendPort;
     public Boolean  EnableFloatingIP;
     public Int32  IdleTimeoutInMinutes;
     public String  Protocol;
     [NrpApiVersion("V3.2")]
     public Boolean  EnableTcpReset;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.NetworkInterfaceIpConfiguration  BackendIPConfiguration;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfiguration[]  FrontendIPConfigurations;
  }

  public class LoadBalancerInboundRuleProperties
  {
     public Int32  FrontendPort;
     public Int32  BackendPort;
     public Boolean  EnableFloatingIP;
     public Int32  IdleTimeoutInMinutes;
     public String  Protocol;
     [NrpApiVersion("V3.2")]
     public Boolean  EnableTcpReset;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfiguration[]  FrontendIPConfigurations;
  }

  public class LoadBalancer
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerProperties  Properties;
  }

  public class LoadBalancerProperties
  {
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfiguration[]  FrontendIPConfigurations;
     public Microsoft.Windows.NetworkController.LoadBalancerBackendAddressPool[]  BackendAddressPools;
     public Microsoft.Windows.NetworkController.LoadBalancingRule[]  LoadBalancingRules;
     public Microsoft.Windows.NetworkController.LoadBalancerProbe[]  Probes;
     public Microsoft.Windows.NetworkController.LoadBalancerInboundNatRule[]  InboundNatRules;
     public Microsoft.Windows.NetworkController.LoadBalancerOutboundNatRule[]  OutboundNatRules;
  }

  public class LoadBalancerRuleBase
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerRuleBaseProperties  Properties;
  }

  public class LoadBalancerRuleBaseProperties
  {
     public String  Protocol;
     [NrpApiVersion("V3.2")]
     public Boolean  EnableTcpReset;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfiguration[]  FrontendIPConfigurations;
  }

  public class LoadBalancerOutboundNatRule
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerOutboundNatRuleProperties  Properties;
  }

  public class LoadBalancerOutboundNatRuleProperties
  {
     public String  Protocol;
     [NrpApiVersion("V3.2")]
     public Boolean  EnableTcpReset;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerBackendAddressPool  BackendAddressPool;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfiguration[]  FrontendIPConfigurations;
  }

  public class LoadBalancerProbe
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerProbeProperties  Properties;
  }

  public class LoadBalancerProbeProperties
  {
     public String  Protocol;
     public Int32  Port;
     public String  RequestPath;
     public Int32  IntervalInSeconds;
     public Int32  NumberOfProbes;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancingRule[]  LoadBalancingRules;
  }

  public class LoadBalancingRule
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancingRuleProperties  Properties;
  }

  public class LoadBalancingRuleProperties
  {
     public String  LoadDistribution;
     public Int32  FrontendPort;
     public Int32  BackendPort;
     public Boolean  EnableFloatingIP;
     public Int32  IdleTimeoutInMinutes;
     public String  Protocol;
     [NrpApiVersion("V3.2")]
     public Boolean  EnableTcpReset;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerBackendAddressPool  BackendAddressPool;
     public Microsoft.Windows.NetworkController.LoadBalancerProbe  Probe;
     public Microsoft.Windows.NetworkController.LoadBalancerFrontendIpConfiguration[]  FrontendIPConfigurations;
  }

  public class NetworkInterface
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkInterfaceProperties  Properties;
  }

  public class NetworkInterfaceProperties
  {
     public String  PrivateMacAddress;
     public String  PrivateMacAllocationMethod;
     public Boolean  IsHostVirtualNetworkInterface;
     public Boolean  IsPrimary;
     public String  InternalDnsNameLabel;
     public Microsoft.Windows.NetworkController.VirtualNetworkInterfaceConfigurationState  ConfigurationState;
     public Boolean  IsMultitenantStack;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.ResourceCounter[]  Counters;
     public Microsoft.Windows.NetworkController.NetworkInterfaceDnsSettings  DnsSettings;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.NetworkInterfaceIpConfiguration[]  IpConfigurations;
     public Microsoft.Windows.NetworkController.ServiceInsertionElement[]  ServiceInsertionElements;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.SecurityTag[]  SecurityTags;
     public Microsoft.Windows.NetworkController.Gateway  Gateway;
     public Microsoft.Windows.NetworkController.LoadBalancerMux  LoadBalancerMuxInternal;
     public Microsoft.Windows.NetworkController.LoadBalancerMux  LoadBalancerMuxExternal;
     public Microsoft.Windows.NetworkController.Server  Server;
     public Microsoft.Windows.NetworkController.VirtualPort  VirtualPortAssociation;
     public Microsoft.Windows.NetworkController.VirtualNetworkInterfaceSettings  PortSettings;
  }

  public class NetworkInterfaceIpConfiguration
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkInterfaceIpConfigurationProperties  Properties;
  }

  public class NetworkInterfaceIpConfigurationProperties
  {
     [NrpApiVersion("V4")]
     public Boolean  IsPrimary;
     public String  PrivateIPAddress;
     public String  PrivateIPAllocationMethod;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerBackendAddressPool[]  LoadBalancerBackendAddressPools;
     public Microsoft.Windows.NetworkController.LoadBalancerInboundNatRule[]  LoadBalancerInboundNatRules;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.LearnedIpAddress  LearnedIp;
     public Microsoft.Windows.NetworkController.PublicIpAddress  PublicIPAddress;
     public Microsoft.Windows.NetworkController.Subnet  Subnet;
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     public Microsoft.Windows.NetworkController.ServiceInsertion  ServiceInsertion;
  }

  public class VirtualNetworkInterfaceQosSettings
  {
     public Int64  OutboundReservedValue;
     public Int64  OutboundMaximumMbps;
     public Int64  InboundMaximumMbps;
     [NrpApiVersion("V3.1")]
     public Boolean  EnableHardwareLimits;
     public String  ProvisioningState;
  }

  public class VirtualNetworkInterfaceSettings
  {
     public String  MacSpoofingEnabled;
     public String  ArpGuardEnabled;
     public String  ArpFilter;
     public String  DhcpGuardEnabled;
     public Int64  StormLimit;
     public Int64  PortFlowLimit;
     public Int16  IovWeight;
     public String  IovInterruptModeration;
     public Int16  IovQueuePairsRequested;
     public Int16  VmqWeight;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VirtualNetworkInterfaceQosSettings  QosSettings;
  }

  public class LoadBalancerBackendAddressPool
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerBackendAddressPoolProperties  Properties;
  }

  public class LoadBalancerBackendAddressPoolProperties
  {
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.NetworkInterfaceIpConfiguration[]  BackendIPConfigurations;
     public Microsoft.Windows.NetworkController.LoadBalancerOutboundNatRule[]  OutboundNatRules;
     public Microsoft.Windows.NetworkController.LoadBalancingRule[]  LoadBalancingRules;
  }

  public class PublicIpAddress
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.PublicIpAddressProperties  Properties;
  }

  public class PublicIpAddressProperties
  {
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.ResourceCounter[]  Counters;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.LoadBalancerVipConfigurationState  ConfigurationState;
     public String  IpAddress;
     [NrpApiVersion("V2")]
     public String  PublicIPAddressVersion;
     public String  PublicIPAllocationMethod;
     public Int32  IdleTimeoutInMinutes;
     public Microsoft.Windows.NetworkController.PublicIPAddressDnsSettings  DnsSettings;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.IpConfiguration  IpConfiguration;
     public Microsoft.Windows.NetworkController.IpConfiguration  PreviousIpConfiguration;
  }

  public class ServiceInsertion
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ServiceInsertionProperties  Properties;
  }

  public class ServiceInsertionProperties
  {
     public Int32  Priority;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.ServiceInsertionRule[]  ServiceInsertionRules;
     public Microsoft.Windows.NetworkController.ServiceInsertionElement[]  ServiceInsertionElements;
     public Microsoft.Windows.NetworkController.IpConfiguration[]  IpConfigurations;
     public Microsoft.Windows.NetworkController.Subnet[]  Subnets;
  }

  public class ServiceInsertionRule
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ServiceInsertionRuleProperties  Properties;
  }

  public class ServiceInsertionRuleProperties
  {
     public String  Description;
     public String  Protocol;
     public Int32  SourcePortRangeStart;
     public Int32  SourcePortRangeEnd;
     public Int32  DestinationPortRangeStart;
     public Int32  DestinationPortRangeEnd;
     public String[]  SourceSubnets;
     public String[]  DestinationSubnets;
     public String  ProvisioningState;
  }

  public class ServiceInsertionElement
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ServiceInsertionElementProperties  Properties;
  }

  public class ServiceInsertionElementProperties
  {
     public String  Description;
     public Int32  Order;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.NetworkInterface  NetworkInterface;
  }

  public class SecurityTag
  {
     [NrpApiVersion("V5")]
     public PSObject  Tags;
     [NrpApiVersion("V5")]
     public String  ResourceRef;
     [NrpApiVersion("V5")]
     public Guid  InstanceId;
     [NrpApiVersion("V5")]
     public String  Etag;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     [NrpApiVersion("V5")]
     public String  ResourceId;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.SecurityTagProperties  Properties;
  }

  public class SecurityTagProperties
  {
     [NrpApiVersion("V5")]
     public String  Type;
     [NrpApiVersion("V5")]
     public String  ProvisioningState;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.NetworkInterface[]  NetworkInterfaces;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.AclRule[]  AclRulesAsSource;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.AclRule[]  AclRulesAsDestination;
  }

  public class LearnedIpAddress
  {
     [NrpApiVersion("V5")]
     public PSObject  Tags;
     [NrpApiVersion("V5")]
     public String  ResourceRef;
     [NrpApiVersion("V5")]
     public Guid  InstanceId;
     [NrpApiVersion("V5")]
     public String  Etag;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     [NrpApiVersion("V5")]
     public String  ResourceId;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.LearnedIpAddressProperties  Properties;
  }

  public class LearnedIpAddressProperties
  {
     [NrpApiVersion("V5")]
     public String  IpAddress;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     [NrpApiVersion("V5")]
     public String  ProvisioningState;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.NetworkInterfaceIpConfiguration[]  IpConfiguration;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.VirtualSubnet  VirtualSubnet;
  }

  public class NetworkControllerState
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkControllerStateProperties  Properties;
  }

  public class NetworkControllerStateProperties
  {
     public String  ProvisioningState;
  }

  public class NetworkControllerBackup
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkControllerBackupProperties  Properties;
  }

  public class NetworkControllerBackupProperties
  {
     public String  BackupPath;
     public String  ErrorMessage;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.Credential  Credential;
  }

  public class NetworkControllerRestore
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkControllerRestoreProperties  Properties;
  }

  public class NetworkControllerRestoreProperties
  {
     public String  RestorePath;
     public String  ErrorMessage;
     public String[]  FailedResources;
     public String[]  SuccessfulResources;
     public String[]  StatusMessages;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.Credential  Credential;
  }

  public class NetworkControllerStatistics
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkControllerStatisticsProperties  Properties;
  }

  public class NetworkControllerStatisticsProperties
  {
     public Microsoft.Windows.NetworkController.ResourceHealthStatistic[]  HealthStatistics;
     public Microsoft.Windows.NetworkController.ResourceUsageStatistic[]  UsageStatistics;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.ResourceCounter[]  Counters;
     public String  ProvisioningState;
  }

  public class ConnectivityCheck
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ConnectivityCheckProperties  Properties;
  }

  public class ConnectivityCheckProperties
  {
     public PSObject  SubmitTime;
     public String  SenderIpAddress;
     public String  ReceiverIpAddress;
     public Boolean  DisableTracing;
     public String  Protocol;
     public Microsoft.Windows.NetworkController.IcmpProtocolConfiguration  IcmpProtocolConfig;
     public Guid  OperationId;
     public Microsoft.Windows.NetworkController.ConnectivityCheckResultProperties  Result;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VirtualNetwork  SenderVirtualNetwork;
     public Microsoft.Windows.NetworkController.VirtualNetwork  ReceiverVirtualNetwork;
     public Microsoft.Windows.NetworkController.LogicalNetwork  SenderLogicalNetwork;
     public Microsoft.Windows.NetworkController.LogicalNetwork  ReceiverLogicalNetwork;
     public Microsoft.Windows.NetworkController.ConnectivityCheckResult  ConnectivityCheckResult;
  }

  public class ConnectivityCheckResult
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ConnectivityCheckProperties  Properties;
  }

  public class Discovery
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.DiscoveryProperties  Properties;
  }

  public class DiscoveryProperties
  {
     public String  NetworkControllerVersion;
     public String[]  SupportedRestVersions;
     public String  CurrentRestVersion;
     public String  ProvisioningState;
  }

  public class Credential
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.CredentialProperties  Properties;
  }

  public class CredentialProperties
  {
     public String  Type;
     public String  UserName;
     public String  Value;
     public String  ProvisioningState;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.VirtualNetwork[]  Networks;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.AuditingSettings  AuditingSettings;
  }

  public class Connection
  {
     public String[]  ManagementAddresses;
     public String  CredentialType;
     public String  Protocol;
     public String  Port;
     public Microsoft.Windows.NetworkController.Credential  Credential;
  }

  public class IConnectionInfo
  {
     public String  Certificate;
     public Microsoft.Windows.NetworkController.Connection[]  Connections;
  }

  public class Server
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.ServerProperties  Properties;
  }

  public class ServerProperties
  {
     public String  Certificate;
     public String  RackSlot;
     public String  OS;
     public String  Model;
     public String  Vendor;
     public String  Serial;
     [NrpApiVersion("V3")]
     public String[]  AuditingEnabled;
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.Connection[]  Connections;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.NetworkInterface[]  VirtualNetworkInterfaces;
     public Microsoft.Windows.NetworkController.NwInterface[]  NetworkInterfaces;
  }

  public class InternalDnsServer
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.InternalDnsServerProperties  Properties;
  }

  public class InternalDnsServerProperties
  {
     public String  Zone;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.Connection[]  Connections;
  }

  public class VirtualServer
  {
     public Boolean  MarkServerReadOnly;
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualServerProperties  Properties;
  }

  public class VirtualServerProperties
  {
     public String  Certificate;
     public String  ProvisioningState;
     public String  VMGuid;
     public Microsoft.Windows.NetworkController.Connection[]  Connections;
     public Microsoft.Windows.NetworkController.Server  Server;
  }

  public class VirtualSwitch
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualSwitchProperties  Properties;
  }

  public class VirtualSwitchProperties
  {
     public String  Id;
     public String  Name;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.Server  Server;
     public Microsoft.Windows.NetworkController.VirtualPort[]  VirtualPorts;
     public Microsoft.Windows.NetworkController.NwInterface[]  PhysicalInterfaces;
  }

  public class NwInterface
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NwInterfaceProperties  Properties;
  }

  public class NwInterfaceProperties
  {
     public String  InterfaceName;
     public String  Mac;
     public Microsoft.Windows.NetworkController.InterfaceIPConfiguration[]  IPConfiguration;
     public String[]  VlanIds;
     public String  AdminStatus;
     public String  OperationalStatus;
     public String  InterfaceIndex;
     public String  InterfaceSpeed;
     public String  IsBMC;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LogicalSubnet[]  LogicalSubnets;
     public Microsoft.Windows.NetworkController.VirtualSwitch  VirtualSwitch;
  }

  public class VirtualPort
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualPortProperties  Properties;
  }

  public class VirtualPortProperties
  {
     public String  Id;
     public String  Name;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.NetworkInterface  NetworkInterface;
  }

  public class BaseBGPRouter
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.BaseBgpRouterProperties  Properties;
  }

  public class BaseBgpRouterProperties
  {
     public Boolean  IsEnabled;
     public Boolean  RequireIgpSync;
     public String  AsNumber;
     public String  ExtAsNumber;
     public String  RouterId;
     public String  ProvisioningState;
  }

  public class BaseBGPPeer
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.BaseBgpPeerProperties  Properties;
  }

  public class BaseBgpPeerProperties
  {
     public Boolean  IsEnabled;
     public String  AsNumber;
     public String  ExtAsNumber;
     public String  PeerIpAddress;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.BasePolicyMap  PolicyMapIn;
     public Microsoft.Windows.NetworkController.BasePolicyMap  PolicyMapOut;
  }

  public class BasePolicyMap
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.BasePolicyMapProperties  Properties;
  }

  public class BasePolicyMapProperties
  {
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.BaseBGPPeer[]  BgpPeersWithPolicyMapIn;
     public Microsoft.Windows.NetworkController.BaseBGPPeer[]  BgpPeersWithPolicyMapOut;
  }

  public class AuditingSettings
  {
     [NrpApiVersion("V3")]
     public PSObject  Tags;
     [NrpApiVersion("V3")]
     public String  ResourceRef;
     [NrpApiVersion("V3")]
     public Guid  InstanceId;
     [NrpApiVersion("V3")]
     public String  Etag;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     [NrpApiVersion("V3")]
     public String  ResourceId;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.AuditingSettingsProperties  Properties;
  }

  public class AuditingSettingsProperties
  {
     [NrpApiVersion("V3")]
     public String  OutputDirectory;
     [NrpApiVersion("V3")]
     public String  ProvisioningState;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.Credential  EncryptionCredential;
  }

  public class IpPool
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.IpPoolProperties  Properties;
  }

  public class IpPoolProperties
  {
     public String  StartIpAddress;
     public String  EndIpAddress;
     public Microsoft.Windows.NetworkController.IpPoolUtilization  Usage;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LoadBalancerManager  LoadBalancerManager;
  }

  public class IpReservation
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.IpReservationProperties  Properties;
  }

  public class IpReservationProperties
  {
     public Boolean  IsIpV6AddressReservation;
     public Int64  NumberOfAddresses;
     public String[]  ReservedAddresses;
     public String  ProvisioningState;
  }

  public class MacPool
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.MacPoolProperties  Properties;
  }

  public class MacPoolProperties
  {
     public String  StartMacAddress;
     public String  EndMacAddress;
     public Microsoft.Windows.NetworkController.MacPoolUtilization  Usage;
     public String  ProvisioningState;
  }

  public class VirtualNetwork
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualNetworkProperties  Properties;
  }

  public class VirtualNetworkProperties
  {
     public Microsoft.Windows.NetworkController.AddressSpace  AddressSpace;
     public Microsoft.Windows.NetworkController.DhcpOptions  DhcpOptions;
     [NrpApiVersion("V2")]
     public String  UnbilledAddressRanges;
     public Microsoft.Windows.NetworkController.VirtualNetworkConfigurationState  ConfigurationState;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VirtualSubnet[]  Subnets;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.VirtualNetworkPeering[]  VirtualNetworkPeerings;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.Credential  EncryptionCredential;
     public Microsoft.Windows.NetworkController.LogicalNetwork  LogicalNetwork;
  }

  public class VirtualNetworkPeering
  {
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     [NrpApiVersion("V3")]
     public String  ResourceRef;
     [NrpApiVersion("V3")]
     public Guid  InstanceId;
     [NrpApiVersion("V3")]
     public String  Etag;
     [NrpApiVersion("V3")]
     public String  ResourceId;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.VirtualNetworkPeeringProperties  Properties;
  }

  public class VirtualNetworkPeeringProperties
  {
     [NrpApiVersion("V3")]
     public String  PeeringState;
     [NrpApiVersion("V3")]
     public Boolean  AllowVirtualNetworkAccess;
     [NrpApiVersion("V3")]
     public Boolean  AllowForwardedTraffic;
     [NrpApiVersion("V3")]
     public Boolean  AllowGatewayTransit;
     [NrpApiVersion("V3")]
     public Boolean  UseRemoteGateways;
     [NrpApiVersion("V3")]
     public Guid  RemoteVirtualNetworkInstanceGuid;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.AddressSpace  RemoteAddressSpace;
     [NrpApiVersion("V3")]
     public String  ProvisioningState;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.VirtualNetwork  RemoteVirtualNetwork;
  }

  public class VirtualSubnet
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualSubnetProperties  Properties;
  }

  public class VirtualSubnetProperties
  {
     public String  AddressPrefix;
     [NrpApiVersion("V2")]
     public String  VirtualSubnetId;
     [NrpApiVersion("V2")]
     public Int64  UnbilledEgressBytes;
     [NrpApiVersion("V2")]
     public Int64  BilledEgressBytes;
     [NrpApiVersion("V2")]
     public Boolean  EncryptionEnabled;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     public Microsoft.Windows.NetworkController.RouteTable  RouteTable;
     [NrpApiVersion("V3")]
     public Microsoft.Windows.NetworkController.VirtualSubnet  DualStackSubnet;
     [NrpApiVersion("V5")]
     public Microsoft.Windows.NetworkController.LearnedIpAddress[]  LearnedIpAddresses;
     public Microsoft.Windows.NetworkController.ServiceInsertion  ServiceInsertion;
     public Microsoft.Windows.NetworkController.IpConfiguration[]  IpConfigurations;
  }

  public class SubnetEgressReset
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.SubnetEgressResetProperties  Properties;
  }

  public class SubnetEgressResetProperties
  {
     public String  VirtualSubnetResourceReference;
     public String  ProvisioningState;
  }

  public class SlbState
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.SlbStateProperties  Properties;
  }

  public class SlbStateProperties
  {
     public Guid  OperationId;
     public PSObject  SubmitTime;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.SlbStateResult  SlbStateResult;
     public Microsoft.Windows.NetworkController.SlbStateResultProperties  Result;
  }

  public class SlbStateResult
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.SlbStateResultProperties  Properties;
  }

  public class SlbStateResultProperties
  {
     public PSObject  SubmitTime;
     public String  Status;
     public Microsoft.Windows.NetworkController.SlbStateData  Output;
     public String  ProvisioningState;
  }

  public class LoadBalancerManager
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerManagerProperties  Properties;
  }

  public class LoadBalancerManagerProperties
  {
     public String  LoadBalancerManagerIPAddress;
     public String[]  OutboundNatIPExemptions;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.IpPool[]  VipIpPools;
  }

  public class LoadBalancerMux
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LoadBalancerMuxProperties  Properties;
  }

  public class LoadBalancerMuxProperties
  {
     public Microsoft.Windows.NetworkController.RouterConfiguration  RouterConfiguration;
     public String  Certificate;
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.ResourceCounter[]  Counters;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VirtualServer  VirtualServer;
     public Microsoft.Windows.NetworkController.Connection[]  Connections;
     public Microsoft.Windows.NetworkController.MuxNetworkInterfaces  NetworkInterfaces;
  }

  public class MuxNetworkInterfaces
  {
     public Microsoft.Windows.NetworkController.NetworkInterface  ExternalNetworkInterface;
     public Microsoft.Windows.NetworkController.NetworkInterface  InternalNetworkInterface;
  }

  public class VirtualNetworkManager
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualNetworkManagerProperties  Properties;
  }

  public class VirtualNetworkManagerProperties
  {
     public String  DistributedRouterState;
     public String  NetworkVirtualizationProtocol;
     [NrpApiVersion("V2")]
     public Microsoft.Windows.NetworkController.VirtualSubnetIdRange  VirtualSubnetIdRange;
     public String  ProvisioningState;
  }

  public class VirtualSwitchManager
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualSwitchManagerProperties  Properties;
  }

  public class VirtualSwitchManagerProperties
  {
     public Int64  NumInterfacesHavingQos;
     [NrpApiVersion("V3.1")]
     public String  PortDefaultState;
     public Microsoft.Windows.NetworkController.VirtualSwitchQosSettings  QosSettings;
     public String  ProvisioningState;
  }

  public class RouteTable
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.RouteTableProperties  Properties;
  }

  public class RouteTableProperties
  {
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.Route[]  Routes;
     public Microsoft.Windows.NetworkController.VirtualSubnet[]  Subnets;
  }

  public class Route
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.RouteProperties  Properties;
  }

  public class RouteProperties
  {
     public String  AddressPrefix;
     public String  NextHopType;
     public String  NextHopIpAddress;
     public String  ProvisioningState;
  }

  public class LogicalNetwork
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LogicalNetworkProperties  Properties;
  }

  public class LogicalNetworkProperties
  {
     public String  NetworkVirtualizationEnabled;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.LogicalSubnet[]  Subnets;
     public Microsoft.Windows.NetworkController.VirtualNetwork[]  VirtualNetworks;
  }

  public class LogicalSubnet
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.LogicalSubnetProperties  Properties;
  }

  public class LogicalSubnetProperties
  {
     public String  VlanID;
     public String[]  DnsServers;
     public String[]  DefaultGateways;
     public Boolean  IsPublic;
     public Microsoft.Windows.NetworkController.IpPoolUtilization  Usage;
     public String  AddressPrefix;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.NwInterface[]  NetworkInterfaces;
     public Microsoft.Windows.NetworkController.GatewayPool[]  GatewayPools;
     public Microsoft.Windows.NetworkController.NetworkConnection[]  NetworkConnections;
     public Microsoft.Windows.NetworkController.FabricRoute[]  Routes;
     public Microsoft.Windows.NetworkController.IpReservation[]  IpReservations;
     public Microsoft.Windows.NetworkController.IpPool[]  IpPools;
     public Microsoft.Windows.NetworkController.AccessControlList  AccessControlList;
     public Microsoft.Windows.NetworkController.ServiceInsertion  ServiceInsertion;
     public Microsoft.Windows.NetworkController.IpConfiguration[]  IpConfigurations;
  }

  public class FabricRoute
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.FabricRouteProperties  Properties;
  }

  public class FabricRouteProperties
  {
     public String  Destination;
     public String  NextHop;
     public String  ProvisioningState;
  }

  public class VirtualGateway
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VirtualGatewayProperties  Properties;
  }

  public class VirtualGatewayProperties
  {
     public String  RoutingType;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     public Microsoft.Windows.NetworkController.NetworkConnection[]  NetworkConnections;
     public Microsoft.Windows.NetworkController.VGwBgpRouter[]  BgpRouters;
     public Microsoft.Windows.NetworkController.VGwPolicyMap[]  PolicyMaps;
     public Microsoft.Windows.NetworkController.GatewayPool[]  GatewayPools;
     public Microsoft.Windows.NetworkController.VirtualSubnet[]  GatewaySubnets;
  }

  public class NetworkConnection
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.NetworkConnectionProperties  Properties;
  }

  public class NetworkConnectionProperties
  {
     public String  ConnectionType;
     public Int64  OutboundKiloBitsPerSecond;
     public Int64  InboundKiloBitsPerSecond;
     public Microsoft.Windows.NetworkController.IpSecConfiguration  IpSecConfiguration;
     public Microsoft.Windows.NetworkController.GreConfiguration  GreConfiguration;
     public Microsoft.Windows.NetworkController.CidrIPAddress[]  IPAddresses;
     public String[]  PeerIPAddresses;
     public Microsoft.Windows.NetworkController.RouteInfo[]  Routes;
     public String  ConnectionStatus;
     public String  ConnectionState;
     public String  ConnectionUpTime;
     public String  ConnectionErrorReason;
     public String  UnreachabilityReason;
     public Microsoft.Windows.NetworkController.NetworkConnectionStatistics  Statistics;
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     public String  SourceIPAddress;
     public String  DestinationIPAddress;
     public String  PreferredGatewayVIP;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.L3Configuration  L3Configuration;
     public Microsoft.Windows.NetworkController.Gateway  Gateway;
  }

  public class L3Configuration
  {
     public Microsoft.Windows.NetworkController.LogicalSubnet  VlanSubnet;
  }

  public class VGwBgpRouter
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VGwBgpRouterProperties  Properties;
  }

  public class VGwBgpRouterProperties
  {
     public String  AdministrativeStatus;
     public String  AggregationType;
     public String[]  RouterIP;
     public Boolean  IsGenerated;
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     public Boolean  IsEnabled;
     public Boolean  RequireIgpSync;
     public String  AsNumber;
     public String  ExtAsNumber;
     public String  RouterId;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VGwBgpPeer[]  BgpPeers;
  }

  public class VGwBgpPeer
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VGwBgpPeerProperties  Properties;
  }

  public class VGwBgpPeerProperties
  {
     public String  AdministrativeStatus;
     public String  ConnectionState;
     public Microsoft.Windows.NetworkController.VGwBgpPeerStatistics  Statistics;
     public Boolean  IsGenerated;
     public Boolean  IsEnabled;
     public String  AsNumber;
     public String  ExtAsNumber;
     public String  PeerIpAddress;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VGwPolicyMap  PolicyMapIn;
     public Microsoft.Windows.NetworkController.VGwPolicyMap  PolicyMapOut;
  }

  public class VGwPolicyMap
  {
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.VGwPolicyMapProperties  Properties;
  }

  public class VGwPolicyMapProperties
  {
     public Microsoft.Windows.NetworkController.VGwPolicyMapEntry[]  PolicyMapEntryList;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.BaseBGPPeer[]  BgpPeersWithPolicyMapIn;
     public Microsoft.Windows.NetworkController.BaseBGPPeer[]  BgpPeersWithPolicyMapOut;
  }

  public class Gateway
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.GatewayProperties  Properties;
  }

  public class GatewayProperties
  {
     public Microsoft.Windows.NetworkController.ResourceConfigurationState  ConfigurationState;
     public String  Type;
     public String  State;
     public String  HealthState;
     public Int64  TotalCapacity;
     public Int64  AvailableCapacity;
     public Microsoft.Windows.NetworkController.GatewayBgpConfig  BgpConfig;
     public String  Certificate;
     public Microsoft.Windows.NetworkController.CidrIPAddress[]  ExternalIPAddress;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.VirtualServer  VirtualServer;
     public Microsoft.Windows.NetworkController.NetworkInterfaces  NetworkInterfaces;
     public Microsoft.Windows.NetworkController.Connection[]  Connections;
     public Microsoft.Windows.NetworkController.GatewayPool  Pool;
  }

  public class NetworkInterfaces
  {
     public Microsoft.Windows.NetworkController.NetworkInterface  ExternalNetworkInterface;
     public Microsoft.Windows.NetworkController.NetworkInterface  InternalNetworkInterface;
  }

  public class GatewayPool
  {
     public PSObject  Tags;
     public String  ResourceRef;
     public Guid  InstanceId;
     public String  Etag;
     public Microsoft.Windows.NetworkController.ResourceMetadata  ResourceMetadata;
     public String  ResourceId;
     public Microsoft.Windows.NetworkController.GatewayPoolProperties  Properties;
  }

  public class GatewayPoolProperties
  {
     public String  Type;
     public Int64  RedundantGatewayCount;
     public Int64  GatewayCapacityKiloBitsPerSecond;
     public Microsoft.Windows.NetworkController.VipAddresses[]  PreferredGatewayVipAddressesesMapping;
     public String  ProvisioningState;
     public Microsoft.Windows.NetworkController.IpConfig  IpConfiguration;
     public Microsoft.Windows.NetworkController.Gateway[]  Gateways;
     public Microsoft.Windows.NetworkController.VirtualGateway[]  VirtualGateways;
  }

  public class IpConfig
  {
     public Microsoft.Windows.NetworkController.LogicalSubnet[]  GreVipSubnets;
     public Microsoft.Windows.NetworkController.PublicIpAddress[]  PublicIPAddresses;
  }

  public class VirtualGatewayRef
  {
     public Microsoft.Windows.NetworkController.VirtualGateway  VirtualGateway;
     public Microsoft.Windows.NetworkController.NetworkConnection[]  NetworkConnections;
     public Microsoft.Windows.NetworkController.VGwBgpRouter  BgpRouter;
  }

  public class ResourceMetadata
  {
     public String  Client;
     public String  TenantId;
     public String  GroupId;
     public String  ResourceName;
     public String  OriginalHref;
  }

  public class SubscriptionLimits
  {
     public Int32  MaxVnetsPerSubscription;
     public Int32  MaxDnsServersPerVnet;
     public Int32  MaxPublicIpsPerSubscription;
     public Int32  MaxNicsPerSubscription;
     public Int32  MaxRouteTablesPerSubscription;
     public Int32  MaxRoutesPerRouteTable;
     public String  SubscriptionLimitsLevel;
  }

  public class ResourceCounter
  {
     public String  Name;
     public String  Unit;
     public Microsoft.Windows.NetworkController.ResourceCounterContext  Context;
     public PSObject  CurrentValue;
  }

  public class ResourceCounterContext
  {
     public String  Source;
     public String  Category;
  }

  public class ResourceConfigurationState
  {
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class ResourceConfigurationStateInfo
  {
     public String  Source;
     public String  Message;
     public String  Code;
  }

  public class AddressSpace
  {
     public String[]  AddressPrefixes;
  }

  public class DhcpOptions
  {
     public String[]  DnsServers;
  }

  public class VirtualNetworkConfigurationState
  {
     public Guid  Id;
     public Microsoft.Windows.NetworkController.VirtualNetworkInterfaceConfigurationState[]  VirtualNetworkInterfaceErrors;
     public Microsoft.Windows.NetworkController.HostConfigurationState[]  HostErrors;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class VirtualNetworkInterfaceConfigurationState
  {
     public Guid  Id;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class HostConfigurationState
  {
     public Guid  Id;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class AccessControlListConfigurationState
  {
     public Guid  Id;
     public Microsoft.Windows.NetworkController.VirtualNetworkInterfaceConfigurationState[]  VirtualNetworkInterfaceErrors;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class LoadBalancerVipConfigurationState
  {
     public Guid  Id;
     public Microsoft.Windows.NetworkController.LoadBalancerVipEndPointConfigurationState[]  VipEndpointStates;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class LoadBalancerVipEndPointConfigurationState
  {
     public String  VipEndpoint;
     public Microsoft.Windows.NetworkController.LoadBalancerDipEndPointConfigurationState[]  DipEndpointStates;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class LoadBalancerDipEndPointConfigurationState
  {
     public String  DipEndpoint;
     public String  HostIPAddress;
     public String  HostId;
     public String  AdapterId;
     public String  ProbeRule;
     public String  Status;
     public Microsoft.Windows.NetworkController.ResourceConfigurationStateInfo[]  DetailedInfo;
     public DateTime  LastUpdatedTime;
  }

  public class PublicIPAddressDnsSettings
  {
     public String  DomainNameLabel;
     public String  ReverseFqdn;
     public String  Fqdn;
  }

  public class IpAddressReservation
  {
     public String  ReservedIPAddress;
     public Guid  ReservationId;
  }

  public class ReferenceScope
  {
  }

  public class ResourceDependencyComparer
  {
  }

  public class NetworkInterfaceDnsSettings
  {
     public String[]  DnsServers;
  }

  public class ResourceHealthStatistic
  {
     public String  ResourceType;
     public Int64  TotalResourceCount;
     public Int64  HealthyResourceCount;
     public Int64  ErrorResourceCount;
     public Int64  WarningResourceCount;
     public Int64  HealthUnknownCount;
  }

  public class ResourceUsageStatistic
  {
     public String  ResourceType;
     public Int64  TotalResourceCount;
     public Int64  InUseResourceCount;
  }

  public class TelemetryStatistics
  {
     public Int32  MonitoringStateReportingFailureCount;
     public Int32  MonitoringCountersReportingFailureCount;
     public Int32  MonitoringStateChangeToUnhealthyCount;
     public Int32  MonitoringStateChangeToHealthyCount;
  }

  public class IcmpProtocolConfiguration
  {
     public Int64  SequenceNumber;
     public Int64  Length;
  }

  public class ConnectivityCheckResultProperties
  {
     public String  Status;
     public Int64  RoundTripTimeMSec;
     public String  ErrorMessage;
     public Microsoft.Windows.NetworkController.NodeOutput[]  NodeOuput;
  }

  public class NodeOutput
  {
     public String  IpAddress;
     public String  NodeType;
     public Int64  NodeSequenceNumber;
     public String  ErrorMessage;
     public String[]  TraceOutput;
  }

  public class DiscoveryFeature
  {
     public String  FeatureName;
     public Boolean  Enabled;
     public Boolean  CanBeDisabled;
     public String  RestVersionAvailableFrom;
     public String  Description;
  }

  public class InterfaceIPConfiguration
  {
     public String  IpAddress;
     public String  NetworkPrefix;
     public String  DefaultGateway;
     public String  VLAN;
     public String  IsDhcpEnabled;
  }

  public class IpPoolUtilization
  {
     public Int64  NumberOfIPAddresses;
     public Int64  NumberofIPAddressesAllocated;
     public Int64  NumberOfIPAddressesInTransition;
  }

  public class MacPoolUtilization
  {
     public Int64  NumberOfMacAddresses;
     public Int64  NumberofMacAddressesAllocated;
  }

  public class SlbStateData
  {
     public Microsoft.Windows.NetworkController.SlbStateDataGroup[]  DataGroups;
  }

  public class SlbStateDataGroup
  {
     public String  Name;
     public String  Description;
     public Microsoft.Windows.NetworkController.SlbStateDataSection[]  DataSections;
  }

  public class SlbStateDataSection
  {
     public String  Name;
     public String  Description;
     public Boolean  DataRetrievalFailed;
     public Microsoft.Windows.NetworkController.SlbStateDataUnit[]  DataUnits;
  }

  public class SlbStateDataUnit
  {
     public String  Name;
     public String  Description;
     public String[]  Value;
  }

  public class RouterConfiguration
  {
     public Int32  LocalASN;
     public Microsoft.Windows.NetworkController.PeerRouterConfiguration[]  PeerRouterConfigurations;
  }

  public class PeerRouterConfiguration
  {
     public String  LocalIPAddress;
     public String  RouterName;
     public String  RouterIPAddress;
     public Int32  PeerASN;
     public Guid  Id;
  }

  public class VirtualSubnetIdRange
  {
     public Int64  StartId;
     public Int64  EndId;
  }

  public class VirtualSwitchQosSettings
  {
     public String  ReservationMode;
     public Int64  LinkSpeedPercentage;
     public Int64  DefaultReservation;
     public Boolean  EnableHardwareLimits;
     public Boolean  EnableHardwareReservations;
     public Boolean  EnableSoftwareReservations;
  }

  public class VGwBgpPeerStatistics
  {
     public DateTime  TcpConnectionEstablished;
     public DateTime  TcpConnectionClosed;
     public Microsoft.Windows.NetworkController.VGwMessageStatistics  OpenMessageStats;
     public Microsoft.Windows.NetworkController.VGwMessageStatistics  NotificationMessageStats;
     public Microsoft.Windows.NetworkController.VGwMessageStatistics  KeepAliveMessageStats;
     public Microsoft.Windows.NetworkController.VGwMessageStatistics  RouteRefreshMessageStats;
     public Microsoft.Windows.NetworkController.VGwMessageStatistics  UpdateMessageStats;
     public Microsoft.Windows.NetworkController.VGwRouteStatistics  Ipv4Route;
     public Microsoft.Windows.NetworkController.VGwRouteStatistics  Ipv6Route;
     public DateTime  LastUpdated;
  }

  public class VGwMessageStatistics
  {
     public DateTime  LastSent;
     public DateTime  LastReceived;
     public Int64  SentCount;
     public Int64  ReceivedCount;
  }

  public class VGwRouteStatistics
  {
     public Int64  UpdateSentCount;
     public Int64  UpdateReceivedCount;
     public Int64  WithdrawlSentCount;
     public Int64  WithdrawlReceivedCount;
  }

  public class VGwPolicyMapEntry
  {
     public String  Action;
     public Microsoft.Windows.NetworkController.VGwPolicyMapEntryMatchCriteria[]  MatchCriteria;
     public Microsoft.Windows.NetworkController.VGwPolicyMapEntrySetAction[]  SetActions;
  }

  public class VGwPolicyMapEntryMatchCriteria
  {
     public String  Property;
     public String[]  Value;
  }

  public class VGwPolicyMapEntrySetAction
  {
     public String  Property;
     public String[]  Value;
  }

  public class IpSecConfiguration
  {
     public String  AuthenticationMethod;
     public String  SharedSecret;
     public Microsoft.Windows.NetworkController.QuickMode  QuickMode;
     public Microsoft.Windows.NetworkController.MainMode  MainMode;
     public Microsoft.Windows.NetworkController.TrafficSelector[]  LocalVpnTrafficSelector;
     public Microsoft.Windows.NetworkController.TrafficSelector[]  RemoteVpnTrafficSelector;
  }

  public class QuickMode
  {
     public String  PerfectForwardSecrecy;
     public String  CipherTransformationConstant;
     public String  AuthenticationTransformationConstant;
     public Int64  IdleDisconnectSeconds;
     public Int64  SALifeTimeSeconds;
     public Int64  SALifeTimeKiloBytes;
  }

  public class MainMode
  {
     public String  DiffieHellmanGroup;
     public String  EncryptionAlgorithm;
     public String  IntegrityAlgorithm;
     public Int64  SALifeTimeSeconds;
     public Int64  SALifeTimeKiloBytes;
  }

  public class TrafficSelector
  {
     public String  Type;
     public Int64  ProtocolId;
     public Int64  PortStart;
     public Int64  PortEnd;
     public String  IpAddressStart;
     public String  IpAddressEnd;
     public Int32  TsPayloadId;
  }

  public class GreConfiguration
  {
     public String  GreKey;
  }

  public class CidrIPAddress
  {
     public String  IPAddress;
     public Int64  PrefixLength;
  }

  public class RouteInfo
  {
     public String  DestinationPrefix;
     public String  NextHop;
     public Int64  Metric;
     public String  Protocol;
  }

  public class NetworkConnectionStatistics
  {
     public Int64  OutboundBytes;
     public Int64  InboundBytes;
     public Int64  RxTotalPacketsDropped;
     public Int64  TxTotalPacketsDropped;
     public Int64  TxRateKbps;
     public Int64  RxRateKbps;
     public Int64  TxRateLimitedPacketsDropped;
     public Int64  RxRateLimitedPacketsDropped;
     public DateTime  LastUpdated;
  }

  public class GatewayBgpConfig
  {
     public String  ExtASNumber;
     public String  RouterID;
     public String[]  RouterIP;
     public Microsoft.Windows.NetworkController.GatewayBgpPeer[]  BgpPeer;
  }

  public class GatewayBgpPeer
  {
     public String  PeerIP;
     public String  PeerAsNumber;
     public String  PeerExtAsNumber;
  }

  public class VipAddresses
  {
     public PSObject  IpAddresses;
  }

  public class ResourceReferenceComparer
  {
  }
}
"@
Add-Type -TypeDefinition $typeDefinitions 

