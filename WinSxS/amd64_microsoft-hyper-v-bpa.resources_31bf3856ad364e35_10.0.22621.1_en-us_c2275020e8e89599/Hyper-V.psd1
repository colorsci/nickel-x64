# Localized	05/07/2022 03:33 AM (GMT)	303:7.0.30723 	Hyper-V.psd1
#
# Hyper-V BPA Localization File
#

ConvertFrom-StringData @'
###PSLOC - Start Localization

rule1_Title=Windows hypervisor must be running
rule1_Problem=Windows hypervisor is not running.
rule1_Impact=Virtual machines cannot be started until Windows hypervisor is running.
rule1_Resolution=Check the Hyper-V-Hypervisor event log for information.
rule1_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule2_Title=The Hyper-V Virtual Machine Management Service must be running
rule2_Problem=The service required to manage virtual machines is not running.
rule2_Impact=No virtual machine management operations can be performed until the service is started.
rule2_Resolution=Use the Services snap-in, the Set-Service cmdlet, or sc config command-line tool to reconfigure the service to start automatically.
rule2_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule21_Title=The Hyper-V Virtual Machine Management Service should be configured to start automatically
rule21_Problem=The Hyper-V Virtual Machine Management Service is not configured to start automatically.
rule21_Impact=Virtual machines cannot be managed until the service is started.
rule21_Resolution=Use the Services snap-in, the Set-Service cmdlet, or sc config command-line tool to reconfigure the service to start automatically.
rule21_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule24_Title=Hyper-V should be the only enabled role
rule24_Problem=Roles other than Hyper-V are enabled on this server.
rule24_Impact=The Hyper-V role should be the only role enabled on a server.
rule24_Resolution=Use Server Manager to remove all roles except Hyper-V.
rule24_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule26_Title=Domain membership is recommended for servers running Hyper-V
rule26_Problem=This server is a member of a workgroup.
rule26_Impact=There is no central management for this server.
rule26_Resolution=If you have a domain environment available, join this server to that domain.
rule26_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule27_Title=Avoid pausing a virtual machine
rule27_Problem=This server has one or more virtual machines in a paused state.
rule27_Impact=Depending on the amount of available memory, you might not be able to run additional virtual machines.
rule27_Resolution=If this is intentional, no further action is required. Otherwise, consider resuming these virtual machines or shutting them down.
rule27_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule28_Title=Offer all available integration services to virtual machines
rule28_Problem=One or more available integration services are not enabled on virtual machines.
rule28_Impact=Some capabilities will not be available to the following virtual machines: \n{0}
rule28_Resolution=If this is intentional, no further action is required. Otherwise, consider offering all integration services in the settings of these virtual machines.
rule28_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule29_Title=Storage controllers should be enabled in virtual machines to provide access to attached storage
rule29_Problem=One or more storage controllers may be disabled in a virtual machine.
rule29_Impact=Virtual machines cannot use storage connected to a disabled storage controller. This impacts the following virtual machines:  \n{0}
rule29_Resolution=Use Device Manager in the guest operating system to enable all storage controllers. If the storage controller is not required, use Hyper-V Manager to remove it from the virtual machine.
rule29_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule30_Title=Display adapters should be enabled in virtual machines to provide video capabilities
rule30_Problem=The Microsoft Virtual Machine Bus Video Device may be disabled in a virtual machine.
rule30_Impact=Video performance for the following virtual machines will be degraded: \n{0}
rule30_Resolution=Use Device Manager in the guest operating system to enable the Microsoft Virtual Machine Bus Video Device.
rule30_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule32_Title=Enable all integration services in virtual machines
rule32_Problem=One or more integration services are disabled or not working in a virtual machine.
rule32_Impact=The service or integration feature may not operate correctly for the following virtual machines: \n{0}
rule32_Resolution=Use the Services snap-in or sc config command-line tool to verify that the service is configured to start automatically and is not stopped.
rule32_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule51_Title=The number of logical processors in use must not exceed the supported maximum
rule51_Problem=The server is configured with too many logical processors.
rule51_Impact=Microsoft does not support running Hyper-V on this computer.
rule51_Resolution=Remove some processors from this machine or use msconfig to limit the number of available processors.
rule51_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule53_Title=Use RAM that provides error correction
rule53_Problem=The RAM in use on this computer is not error-correcting (ECC) RAM.
rule53_Impact=Microsoft does not support {0} on computers without error-correcting RAM.
rule53_Resolution=Verify the server is listed in the Windows Server catalog and qualified for Hyper-V.
rule53_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule54_Title=The number of running or configured virtual machines must be within supported limits
rule54_Problem=More virtual machines are running or configured than are supported.
rule54_Impact=Microsoft does not support the current number of virtual machines running or configured on this server.
rule54_Resolution=Move one or more virtual machines to another server.
rule54_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule56_Title=At least one GPU on the physical computer should support RemoteFX and meet the minimum requirements for DirectX when virtual machines are configured with a RemoteFX 3D video adapter
rule56_Problem=The physical computer has no graphics processing units (GPUs) that support RemoteFX and that meet the minimum requirements for DirectX.
rule56_Impact=Microsoft does not provide support for RemoteFX-enabled virtual machines on physical computers that lack valid GPUs.
rule56_Resolution=Install at least one supported GPU on the physical computer.
rule56_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule57_Title=Avoid installing RemoteFX on a computer that is configured as an Active Directory domain controller
rule57_Problem=RemoteFX is installed on a domain controller.
rule57_Impact=Virtual machines configured for RemoteFX cannot be used on this computer.
rule57_Resolution=Decide whether you want to this computer configured for RemoteFX or as an Active Directory domain controller, then reconfigure the computer if necessary.
rule57_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule59_Title=Use at least SMB protocol version 3.0 for file shares that store files for virtual machines.
rule59_Problem=Virtual machine files or virtual hard disk files are stored on a file share that does not support at least SMB protocol version 3.0.
rule59_Impact=Microsoft does not support this configuration. This impacts the following virtual machines:\n{0}
rule59_Resolution=Move the files to a file share that uses at least SMB protocol version 3.0.
rule59_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule60_Title=Use at least SMB protocol version 3.0 configured for continuous availability on file shares that store files for virtual machines.
rule60_Problem=Virtual machine files or virtual hard disk files are stored on a network file share that is not configured with the continuous availability feature of SMB protocol version 3.0.
rule60_Impact=Microsoft does not recommend this configuration because it might impact the availability of the virtual machines using the file server. This impacts the following virtual machines:\n{0}
rule60_Resolution=Do one of the following: \n\t1. Move the files to an SMB 3.0 file share that is configured for continuous availability.\n\t2. Reconfigure the current file share to provide continuous availability.
rule60_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule203_Title=Configure at least the required amount of memory for a virtual machine running Windows Server 2008 and enabled for Dynamic Memory
rule203_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows Server 2008.
rule203_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule203_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
rule203_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule204_Title=A virtual machine running Windows Server 2008 and configured with Dynamic Memory should use recommended values for memory settings
rule204_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows Server 2008.
rule204_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule204_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB.
rule204_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule205_Title=Configure at least the required amount of memory for a virtual machine running Windows Vista and enabled for Dynamic Memory
rule205_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows Vista.
rule205_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule205_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
rule205_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule206_Title=A virtual machine running Windows Vista and configured with Dynamic Memory should use recommended values for memory settings
rule206_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows Vista.
rule206_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule206_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB.
rule206_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule207_Title=Configure at least the required amount of memory for a virtual machine running Windows Server 2008 R2 and enabled for Dynamic Memory
rule207_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory  required for Windows Server 2008 R2.
rule207_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule207_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
rule207_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule208_Title=A virtual machine running Windows Server 2008 R2 and configured with Dynamic Memory should use recommended values for memory settings
rule208_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory  recommended for Windows Server 2008 R2.
rule208_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule208_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB.
rule208_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule209_Title=Configure at least the required amount of memory for a virtual machine running Windows 7 and enabled for Dynamic Memory
rule209_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows 7.
rule209_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule209_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB.
rule209_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule210_Title=A virtual machine running Windows 7 and configured with Dynamic Memory should use recommended values for memory settings
rule210_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows 7.
rule210_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule210_Resolution=Use Hyper-V Manager or Windows PowerShell to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB.
rule210_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule211_Title=Configure at least the required amount of memory for a virtual machine running Windows Server 2012 and enabled for Dynamic Memory
rule211_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows Server 2012.
rule211_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule211_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB for this virtual machine.
rule211_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule212_Title=A virtual machine running Windows Server 2012 and configured with Dynamic Memory should use recommended values for memory settings
rule212_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows Server 2012.
rule212_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule212_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB for this virtual machine.
rule212_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule213_Title=Configure at least the required amount of memory for a virtual machine running Windows 8 and enabled for Dynamic Memory
rule213_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for Windows 8.
rule213_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule213_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB for this virtual machine.
rule213_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule214_Title=A virtual machine running Windows 8 and configured with Dynamic Memory should use recommended values for memory settings
rule214_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for Windows 8.
rule214_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule214_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB for this virtual machine.
rule214_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule215_Title=Configure at least the required amount of memory for a virtual machine running {1} and enabled for Dynamic Memory
rule215_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for {1}.
rule215_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule215_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB for this virtual machine.
rule215_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule216_Title=A virtual machine running {1} and configured with Dynamic Memory should use recommended values for memory settings
rule216_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for {1}.
rule216_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule216_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 2 GB for this virtual machine.
rule216_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule217_Title=Configure at least the required amount of memory for a virtual machine running {1} and enabled for Dynamic Memory
rule217_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory required for {1}.
rule217_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule217_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, and the startup memory and maximum memory to at least 512 MB for this virtual machine.
rule217_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule218_Title=A virtual machine running {1} and configured with Dynamic Memory should use recommended values for memory settings
rule218_Problem=One or more virtual machines are configured to use Dynamic Memory with less than the amount of memory recommended for {1}.
rule218_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule218_Resolution=Use Hyper-V Manager to increase the minimum memory to at least 256 MB, startup memory to at least 512 MB and maximum memory to at least 1 GB for this virtual machine.
rule218_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule224_Title=Dynamic Memory is enabled but not responding on some virtual machines
rule224_Problem=One or more virtual machines are experiencing problems with the driver required for Dynamic Memory in the guest operating system.
rule224_Impact=The guest operating system in the following virtual machines might not run or might run unreliably because Hyper-V cannot adjust the memory dynamically to respond to changes in memory demand. This impacts the following virtual machines:\n{0}
rule224_Resolution=This is expected behavior if the virtual machine is booting. If the virtual machine is not booting, make sure that integration services are upgraded to the latest version and that the guest operating system supports Dynamic Memory.
rule224_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule225_Title=Avoid storing Smart Paging files on a system disk
rule225_Problem=The memory configuration for one or more virtual machines might require the use of Smart Paging if the virtual machine is rebooted, and the specified location for the Smart Paging file is the system disk of the server running Hyper-V.
rule225_Impact=Use of the system disk for Smart Paging might cause the server running Hyper-V to experience problems. This affects the following virtual machines:\n{0}
rule225_Resolution=Reconfigure the virtual machines to store the Smart Paging files on a non-system disk.
rule225_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule226_Title=A Replica server must be configured to accept replication requests
rule226_Problem=This computer is designated as a Hyper-V Replica server but is not configured to accept incoming replication data from primary servers.
rule226_Impact=This server cannot accept replication traffic from primary servers.
rule226_Resolution=Use Hyper-V Manager to specify which primary servers this Replica server should accept replication data from.
rule226_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule227_Title=Replica servers should be configured to identify specific primary servers authorized to send replication traffic
rule227_Problem=As configured, this Replica server accepts replication traffic from all primary servers and stores them in a single location.
rule227_Impact=All replication from all primary servers is stored in one location, which might introduce privacy or security problems.
rule227_Resolution=Use Hyper-V Manager to create new authorization entries for the specific primary servers and specify separate storage locations for each of them. You can use wildcard characters to group primary servers into sets for each authorization entry.
rule227_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule228_Title=Compression is recommended for replication traffic
rule228_Problem=The replication traffic sent across the network from the primary server to the Replica server is uncompressed.
rule228_Impact=Replication traffic will use more bandwidth than necessary. This impacts the following virtual machines:\n{0}
rule228_Resolution=Configure Hyper-V Replica to compress the data transmitted over the network in the settings for the virtual machine in Hyper-V Manager. You can also use tools outside of Hyper-V to perform compression.
rule228_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule229_Title=Configure guest operating systems for VSS-based backups to enable application-consistent snapshots for Hyper-V Replica
rule229_Problem=Application-consistent snapshots requires that Volume Shadow Copy Services (VSS) is enabled and configured in the guest operating systems of virtual machines participating in replication.
rule229_Impact=Even if application-consistent snapshots are specified in the replication configuration, Hyper-V will not use them unless VSS is configured. This impacts the following virtual machines:\n{0}
rule229_Resolution=Use Virtual Machine Connection to install or update integration services in the virtual machine.
rule229_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule230_Title=Integration services must be installed before primary or Replica virtual machines can use an alternate IP address after a failover
rule230_Problem=Virtual machines participating in replication can be configured to use a specific IP address in the event of failover, but only if integration services are installed in the guest operating system of the virtual machine.
rule230_Impact=In the event of a failover (planned, unplanned, or test), the Replica virtual machine will come online using the same IP address as the primary virtual machine. This configuration might cause connectivity issues. This impacts the following virtual machines:\n{0}
rule230_Resolution=Use Virtual Machine Connection to install or update integration services in the virtual machine.
rule230_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule231_Title=Authorization entries should have distinct trust group names for primary servers with virtual machines that are not part of the same trust group.
rule231_Problem=The server will accept replication requests for the replica virtual machine from any of the servers in the authorization list associated with the same trust group as the virtual machine.
rule231_Impact=There might be privacy and security concerns with a virtual machine accepting replication from primary servers belonging to different authorization entries. This impacts the following authorization entries:\n{0}
rule231_Resolution=Use different trust group names in the authorization entries for primary servers with virtual machines that are not part of the same trust group. Modify the Hyper-V settings to configure the trust group names.
rule231_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule232_Title=To participate in replication, servers in failover clusters must have a Hyper-V Replica Broker configured
rule232_Problem=For failover clusters, Hyper-V Replica requires the use of a Hyper-V Replica Broker name instead of an individual server name.
rule232_Impact=If the virtual machine is moved to a different failover cluster node, replication cannot continue.
rule232_Resolution=Use Failover Cluster Manager to configure the Hyper-V Replica Broker. In Hyper-V Manager, ensure that the replication configuration uses the Hyper-V Replica Broker name as the server name.
rule232_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule233_Title=Certificate-based authentication is recommended for replication.
rule233_Problem=One or more virtual machines selected for replication are configured for Kerberos authentication.
rule233_Impact=The replication network traffic from the primary server to the replication server is unencrypted. This impacts the following virtual machines:\n{0}
rule233_Resolution=If another method is being used to perform encryption, you can ignore this. Otherwise, modify the virtual machine settings to choose certificate-based authentication.
rule233_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule234_Title=Virtual hard disks with paging files should be excluded from replication
rule234_Problem=Paging files should be excluded from participating in replication, but no disks have been excluded.
rule234_Impact=Paging files experience a high volume of input/output activity, which will unnecessarily require much greater resources to participate in replication. This impacts the following virtual machines:\n{0}
rule234_Resolution=If you have not already done so, create a separate virtual hard disk for the Windows paging file. If initial replication has already been completed, use Hyper-V Manager to remove replication. Then, configure replication again and exclude the virtual hard disk with the paging file from replication.
rule234_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule235_Title=Configure a policy to throttle the replication traffic on the network
rule235_Problem=There might not be a limit on the amount of network bandwidth that replication is allowed to consume.
rule235_Impact=Network bandwidth could become completely dominated by replication traffic, affecting other critical network activity. This impacts the following ports:\n{0}
rule235_Resolution=If you use another method to throttle network traffic, you can ignore this. Otherwise, use Group Policy Editor to configure a policy that will throttle the network traffic to the relevant port of the Replica server.
rule235_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule236_Title=Configure the Failover TCP/IP settings that you want the Replica virtual machine to use in the event of a failover
rule236_Problem=Replica virtual machines configured with a static IP address should be configured to use a different IP address from their primary virtual machine counterpart in the event of failover.
rule236_Impact=Clients using the workload supported by the primary virtual machine might not be able to connect to the Replica virtual machine after a failover. Also, the primary virtual machine's original IP address will not be valid in the Replica virtual machine network topology. This impacts the following virtual machine(s):\n{0}
rule236_Resolution=Use Hyper-V Manager to configure the IP address that the Replica virtual machine should use in the event of failover.
rule236_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule237_Title=Resynchronization of replication should be scheduled for off-peak hours
rule237_Problem=Resynchronization of replication for the primary virtual machines is not scheduled for off-peak hours.
rule237_Impact=Resynchronization process requires significant storage and processing resources. It is recommended to schedule resynchronization during off-peak hours to reduce the impact on the system, and to ensure replication isn’t blocked for manual intervention. This impacts the following virtual machines:\n{0}
rule237_Resolution=Use Hyper-V Manager to modify the replication settings for the virtual machine to perform resynchronization automatically during off-peak hours.
rule237_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule238_Title=Certificate-based authentication is configured, but the specified certificate is not installed on the Replica server or failover cluster nodes
rule238_Problem=The security certificate that Hyper-V Replica has been configured to use to provide certificate-based replication is not installed on the Replica server (or any failover cluster nodes).
rule238_Impact=In the event of a cluster failover or move to another node, Hyper-V replication will pause if the new node does not also have the appropriate certificate installed. This impacts the following nodes:\n{0}
rule238_Resolution=Install the configured certificate on the Replica server (and all associated nodes in the failover cluster, if any).
rule238_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule239_Title=Replication is paused for one or more virtual machines on this server
rule239_Problem=Replication is paused for one or more of the virtual machines. While the primary virtual machine is paused, any changes that occur will be accumulated and will be sent to the Replica virtual machine once replication is resumed.
rule239_Impact=As long as replication is paused, accumulated changes occurring in the primary virtual machine will consume available disk space on the primary server. After replication is resumed, there might be a large burst of network traffic to the Replica server. This impacts the following virtual machines:\n{0}
rule239_Resolution=Confirm that pausing replication was intended. If replication was paused to address low disk space or network connectivity, resume replication as soon as those issues are resolved.
rule239_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule240_Title=Test failover should be attempted after initial replication is complete
rule240_Problem=No test failovers have been attempted after completing initial replication.
rule240_Impact=There is no confirmation that a planned or unplanned failover will succeed or workload operations will continue properly after a failover. This impacts the following virtual machines:\n{0}
rule240_Resolution=Use Hyper-V Manager to conduct a test failover.
rule240_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule241_Title=Test failovers should be carried out at least monthly to verify that failover will succeed and that virtual machine workloads will operate as expected after failover
rule241_Problem=There has been no test failover in at least one month.
rule241_Impact=There is no confirmation that a planned or unplanned failover will succeed or workload operations will continue properly after a failover. This impacts the following virtual machines:\n{0}
rule241_Resolution=Use Hyper-V Manager to conduct a test failover.
rule241_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule245_Title=Recovery snapshots should be removed after failover
rule245_Problem=A failed over virtual machine has one or more recovery snapshots.
rule245_Impact=Available space may run out on the physical disk that stores the snapshot files. If this occurs, no additional disk operations can be performed on the physical storage. Any virtual machine that relies on the physical storage could be affected. This impacts the following virtual machines:\n{0}
rule245_Resolution=For each failed over virtual machine, use the Complete-VMFailover cmdlet in Windows PowerShell to remove the recovery snapshots and indicate failover completion.
rule245_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule251_Title=At least one network for live migration traffic should have a link speed of at least 1 Gbps
rule251_Problem=None of the networks for live migration traffic have a link speed of at least 1 Gbps.
rule251_Impact=Live migrations might occur slowly, which could disrupt the network connection due to a TCP connection timeout.
rule251_Resolution=Configure at least one live migration network with a speed of 1 Gbps or faster.
rule251_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule252_Title=All networks for live migration traffic should have a link speed of at least 1 Gbps
rule252_Problem=The link speed is less than 1 Gbps on some networks for live migration.
rule252_Impact=Live migrations might occur slowly, which could disrupt the network connection due to a TCP connection timeout.
rule252_Resolution=Verify that all live migration networks are configured for a speed of 1 Gbps or faster.
rule252_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule300_Title=Virtual machines should be backed up at least once every week
rule300_Problem=One or more virtual machines have not been backed up in the past week.
rule300_Impact=Significant data loss might occur if the virtual machine encounters a problem and a recent backup does not exist. This impacts the following virtual machines:\n{0}
rule300_Resolution=Schedule a backup of the virtual machines to run at least once a week. You can ignore this rule if this virtual machine is a replica and its primary virtual machine is being backed up, or if this is the primary virtual machine and its replica is being backed up.
rule300_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule351_Title=Ensure sufficient physical disk space is available when virtual machines use dynamically expanding virtual hard disks
rule351_Problem=One or more virtual machines are using dynamically expanding virtual hard disks
rule351_Impact=Dynamically expanding virtual hard disks require available space on the hosting volume so that space can be allocated when writes to the virtual hard disks occur. If available space is exhausted, any virtual machine that relies on the physical storage could be affected. This impacts the following virtual machines:\n{0}
rule351_Resolution=Monitor available disk space to ensure sufficient space is available for expansion. Consider shutting down the virtual machine and use the Edit Disk Wizard in Hyper-V Manager to convert each dynamically expanding virtual hard disk for this virtual machine to a fixed sized virtual hard disk.
rule351_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule352_Title=Ensure sufficient physical disk space is available when virtual machines use differencing virtual hard disks
rule352_Problem=One or more virtual machines are using differencing virtual hard disks.
rule352_Impact=Differencing virtual hard disks require available space on the hosting volume so that space can be allocated when writes to the virtual hard disks occur. If available space is exhausted, any virtual machine that relies on the physical storage could be affected. This impacts the following virtual machines:\n{0}
rule352_Resolution=Monitor available disk space to ensure sufficient space is available for virtual hard disk expansion. Consider merging differencing virtual hard disks into their parent. In Hyper-V Manager, inspect the differencing disk to determine the parent virtual hard disk. If you merge a differencing disk to a parent disk that is shared by other differencing disks, that action will corrupt the relationship between the other differencing disks and the parent disk, making them unusable. After verifying that the parent virtual hard disk is not shared, you can use the Edit Disk Wizard to merge the differencing disk to the parent virtual hard disk.
rule352_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule353_Title=Avoid alignment inconsistencies between virtual blocks and physical disk sectors on dynamic virtual hard disks or differencing disks
rule353_Problem=Alignment inconsistencies were detected for one or more virtual hard disks.
rule353_Impact=If the virtual hard disks are stored on physical disk that has a sector size of 4K, the virtual machine or applications that use the virtual hard disk might experience performance problems. This affects the following virtual machines:\n{0}
rule353_Resolution=Use the Create Virtual Hard Disk Wizard to create a new VHD-format or VHDX-format virtual hard disk and specify the existing virtual hard disk as the source disk. The new virtual hard disk will be created with alignment between the virtual blocks and physical disk.
rule353_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule354_Title=VHD-format dynamic virtual hard disks are not recommended for virtual machines that run server workloads in a production environment
rule354_Problem=One or more virtual machines use VHD-format dynamically expanding virtual hard disks.
rule354_Impact=VHD-format dynamic virtual hard disks could experience consistency issues if a power failure occurs. Consistency issues can happen if the physical disk performs an incomplete or incorrect update to a sector in a .vhd file that is being modified when a power failure occurs. This affects the following virtual machines:\n{0}
rule354_Resolution=Shut down the virtual machine and convert the VHD-format dynamic virtual hard disk to a VHDX-format virtual hard disk or to a fixed virtual hard disk. (The VHDX format has reliability mechanisms that help protect the disk from corruptions due to system power failures.) However, do not convert the virtual hard disk if it is likely to be attached to an earlier release of Windows at some point. Windows releases earlier than Windows Server 2012 do not support the VHDX format.
rule354_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule355_Title=Avoid using VHD-format differencing virtual hard disks on virtual machines that run server workloads in a production environment.
rule355_Problem=One or more virtual machines use VHD-format differencing virtual hard disks.
rule355_Impact=VHD-format differencing virtual hard disks could experience consistency issues if a power failure occurs. Consistency issues can happen if the physical disk performs an incomplete or incorrect update to a sector in a .vhd file that is being modified when a power failure occurs. This affects the following virtual machines:\n{0}
rule355_Resolution=Shut down the virtual machine and convert the chain of VHD-format differencing virtual hard disks to the VHDX format or merge the chain to a fixed virtual hard disk. (The VHDX format has reliability mechanisms that help protect the disk from corruptions due to power failures.) However, do not convert the virtual hard disk if it is likely to be attached to an earlier release of Windows at some point. Windows releases earlier than Windows Server 2012 do not support the VHDX format.
rule355_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule401_Title=Use all virtual functions for networking when they are available
rule401_Problem=Some hardware acceleration capabilities are not being utilized.
rule401_Impact=This configuration might cause overall CPU utilization to be higher than necessary. Networking performance might not be optimal on the following virtual machines:\n{0}
rule401_Resolution=Consider configuring the virtual network adapter for SR-IOV if the physical hardware supports SR-IOV and if this configuration does not conflict with the networking features required by the virtual machine.
rule401_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule402_Title=The number of running virtual machines configured for SR-IOV should not exceed the number of virtual functions available to the virtual machines
rule402_Problem=There are not enough virtual functions available for the number of running virtual machines configured for single-root I/O virtualization (SR-IOV).
rule402_Impact=Networking performance might not be optimal on the following virtual machines: \n{0}
rule402_Resolution=Consider disabling SR-IOV on one or more virtual machines that do not require an SR-IOV virtual function.
rule402_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule403_Title=Configure virtual machines to use SR-IOV only when supported by the guest operating system
rule403_Problem=One or more virtual machines are configured to use single-root I/O virtualization (SR-IOV), but the guest operating system does not support SR-IOV.
rule403_Impact=SR-IOV virtual functions will not be allocated to the following virtual machines:\n{0}
rule403_Resolution=Disable SR-IOV on all virtual machines that run guest operating systems which do not support SR-IOV.
rule403_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule404_Title=Ensure that the virtual function driver operates correctly when a virtual machine is configured to use SR-IOV
rule404_Problem=The virtual function driver is not operating correctly in the guest operating system of one or more virtual machines.
rule404_Impact=Networking performance is not optimal on the following virtual machines:\n{0}
rule404_Resolution=In the guest operating system, do the following: Verify that appropriate drivers are installed and all networking devices are enabled, and check the Event log for errors or warnings.
rule404_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule426_Title=Configure the server with a sufficient amount of dynamic MAC addresses
rule426_Problem=The number of available dynamic MAC addresses is low.
rule426_Impact=When no dynamic MAC addresses are available, virtual machines configured to use a dynamic MAC address cannot be started.
rule426_Resolution=Use Virtual Switch Manager to view and extend the range of dynamic addresses.
rule426_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule427_Title=More than one network adapter should be available
rule427_Problem=This server is configured with one network adapter, which must be shared by the management operating system and all virtual machines that require access to a physical network.
rule427_Impact=Networking performance may be degraded in the management operating system.
rule427_Resolution=Add more network adapters to this computer. To reserve one network adapter for exclusive use by the management operating system, do not configure it for use with an external virtual network.
rule427_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule429_Title=All virtual network adapters should be enabled
rule429_Problem=One or more virtual network adapters associated with a physical network adapter are disabled in the management operating system.
rule429_Impact=The configuration of this server is not optimal.
rule429_Resolution=Use Network Connections to enable the virtual network adapter. Or, use Virtual Switch Manager to reconfigure the external virtual network so that it is not shared with the management operating system.
rule429_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule430_Title=Enable all virtual network adapters configured for a virtual machine
rule430_Problem=One or more network adapters may be disabled in a virtual machine.
rule430_Impact=The following virtual machines might not have network connectivity: \n{0}
rule430_Resolution=Use Device Manager in the guest operating system to enable all virtual network adapters. If the adapter is not required, use Hyper-V Manager to remove it from the virtual machine.
rule430_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule432_Title=Avoid using legacy network adapters when the guest operating system supports network adapters
rule432_Problem=A guest operating system that supports a network adapter is configured with a legacy network adapter. This configuration is not recommended.
rule432_Impact=Networking performance may be degraded for the following virtual machines:\n{0}
rule432_Resolution=Use Hyper-V Manager to shut down the virtual machine and remove the legacy network adapter. If the virtual machine needs network connectivity, it requires at least one network adapter. If integration services are available, make sure they are installed.
rule432_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule433_Title=Ensure that all mandatory virtual switch extensions are available
rule433_Problem=One or more virtual network adapters are connected to a virtual switch with mandatory extensions that are disabled or not installed.
rule433_Impact=Network traffic is blocked on one or more virtual network adapters on the following virtual machines:\n{0}
rule433_Resolution=First, make sure that the mandatory extension has been installed on the host and install the extension if necessary. Then, if the mandatory extension is disabled, use Virtual Switch Manager or the Windows PowerShell cmdlet Enable-VMSwitchExtension to enable the extension.
rule433_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule434_Title=A team bound to a virtual switch should only have one exposed team interface
rule434_Problem=One or more virtual switches are bound to a team that has multiple team interfaces.
rule434_Impact=The following virtual switches might not have access to VLANs and bandwidth used by other team interfaces:\n{0}
rule434_Resolution=Use the Windows PowerShell cmdlet Remove-NetLbfoTeamNic to remove all team interfaces from the team other than the default team interface.
rule434_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule435_Title=The team interface bound to a virtual switch should be in default mode
rule435_Problem=Some virtual switches are bound to a team interface but the team interface doesn’t pass traffic on all VLANs to the virtual switches.
rule435_Impact=The following virtual switches cannot have access to all VLANs: \n{0}
rule435_Resolution=Use Server Manager or the Windows PowerShell cmdlet Set-NetLbfoTeamNic to reset the team interface to the default mode.
rule435_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
rule436_Title=VMQ should be enabled on VMQ-capable physical network adapters bound to an external virtual switch
rule436_Problem=The following network adapters are capable of (virtual machine queue) VMQ but the capability is disabled.
rule436_Impact=Windows is unable to take full advantage of available hardware offloads on the following network adapters: \n{0}
rule436_Resolution=Enable VMQ using the Enable-NetAdapterVmq Powershell cmdlet or using the Advanced Properties user interface for the network adapter.
rule436_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
rule437_Title=One or more network adapters should be configured as the destination for Port Mirroring
rule437_Problem=One or more virtual machines have a network adapter configured as a source for Port Mirroring, but there is no corresponding destination on the virtual switch.
rule437_Impact=Port Mirroring will not operate correctly for the following virtual switches and virtual machines:\n{0}
rule437_Resolution=Use PowerShell or Hyper-V Manager to complete or correct the Port Mirroring configuration.
rule437_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
rule438_Title=One or more network adapters should be configured as the source for Port Mirroring
rule438_Problem=One or more virtual machines have a network adapter configured as a destination for Port Mirroring, but there is no corresponding source on the virtual switch.
rule438_Impact=Port Mirroring will not operate correctly for the following virtual switches and virtual machines:\n{0}
rule438_Resolution=Use PowerShell or Hyper-V Manager to complete or correct the Port Mirroring configuration.
rule438_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
rule439_Title=PVLAN configuration on a virtual switch must be consistent
rule439_Problem=Private Virtual Local Area Network (PVLAN) is not configured correctly on one or more virtual network adapters
rule439_Impact=PVLAN might not isolate network traffic between virtual machines correctly. Error code:\n{0}
rule439_Resolution=Use the Windows PowerShell cmdlet, Set-VMNetworkAdapterVlan, to configure PVLAN correctly.
rule439_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
rule440_Title=The WFP virtual switch extension should be enabled if it is required by third party extensions
rule440_Problem=The Windows Filtering Platform (WFP) virtual switch extension is disabled.
rule440_Impact=Some third party virtual switch extensions may not operate correctly on the following virtual switches:\n{0}
rule440_Resolution=Use the Windows PowerShell cmdlet, Enable-VMSwitchExtension, to enable the Windows Filtering Platform if it is required by third party extensions.
rule440_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule476_Title=A virtual SAN should be associated with a physical host bus adapter
rule476_Problem=A virtual storage area network (SAN) has been configured without an association to a host bus adapter (HBA).
rule476_Impact=A virtual machine will fail to start when it is configured with a virtual Fibre Channel adapter connected to a misconfigured virtual SAN. This impacts the following virtual SANs:\n{0}
rule476_Resolution=Reconfigure the virtual SAN by connecting it to a host bus adapter.
rule476_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule477_Title=Virtual machines configured with a virtual Fibre Channel adapter should be configured for high availability to the Fibre Channel-based storage
rule477_Problem=One or more virtual machines lack a highly available connection to Fibre Channel-based storage because those virtual machines are configured with a virtual Fibre Channel adapter that is connected to only one host bus adapter (HBA).
rule477_Impact=A failure of the host bus adapter might block the Fibre Channel connection between the storage and the virtual machines. This impacts the following virtual machines:\n{0}
rule477_Resolution=Add another connection from the virtual machine to the host bus adapter and configure multipath I/O (MPIO) in the guest operating system to establish redundant Fibre Channel connections.
rule477_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
    
rule478_Title=Avoid enabling virtual machines configured with virtual Fibre Channel adapters to allow live migrations when there are fewer paths to Fibre Channel logical units (LUNs) on the destination than on the source
rule478_Problem=One or more virtual machines have the AllowReducedFcRedunancy property set in the virtualization WMI provider.
rule478_Impact=Live migration of the following virtual machines might lead to data loss or interrupt I/O to storage:/n {0}
rule478_Resolution=Consider clearing the AllowReducedFcRedundancy  WMI property on the affected virtual machines. When this property is cleared, you can perform a live migration on virtual machines configured with virtual Fibre Channel adapters only when the number of paths to Fibre Channel on the destination is the same or more than the number of paths on the source. These checks help prevent loss of data or interruption of I/O to the storage.
rule478_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule502_Title=Configure virtual machines running Windows Vista with 1 or 2 virtual processors
rule502_Problem=A virtual machine running Windows Vista is configured with more than 2 virtual processors.
rule502_Impact=Microsoft does not support the configuration of the following virtual machines: \n{0}
rule502_Resolution=Shut down the virtual machine and remove one or more virtual processors.
rule502_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule506_Title=Configure virtual machines running Windows 7 with no more than 4 virtual processors
rule506_Problem=A virtual machine running Windows 7 is configured with more than 4 virtual processors.
rule506_Impact=Microsoft does not support the configuration of the following virtual machines: \n{0}
rule506_Resolution=Shut down the virtual machine and remove one or more virtual processors.
rule506_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule514_Title=Windows Vista should be configured with at least the minimum amount of memory
rule514_Problem=A virtual machine running Windows Vista is configured with less than the minimum amount of RAM, which is 512 MB.
rule514_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule514_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule514_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule515_Title=Windows Vista should be configured with the recommended amount of memory
rule515_Problem=A virtual machine running Windows Vista is configured with less than the recommended amount of RAM, which is 1 GB.
rule515_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule515_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
rule515_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule516_Title=Windows Server 2008 should be configured with at least the minimum amount of memory
rule516_Problem=A virtual machine running Windows Server 2008 is configured with less than the minimum amount of RAM, which is 512 MB.
rule516_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule516_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule516_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule517_Title=Windows Server 2008 should be configured with the recommended amount of memory
rule517_Problem=A virtual machine running Windows Server 2008 is configured with less than the recommended amount of RAM, which is 2 GB.
rule517_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule517_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
rule517_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule518_Title=Windows Server 2008 R2 should be configured with at least the minimum amount of memory
rule518_Problem=A virtual machine running Windows Server 2008 R2 is configured with less than the minimum amount of RAM, which is 512 MB.
rule518_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule518_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule518_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule519_Title=Windows Server 2008 R2 should be configured with the recommended amount of memory
rule519_Problem=A virtual machine running Windows Server 2008 R2 is configured with less than the recommended amount of RAM, which is 2 GB.
rule519_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule519_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
rule519_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule520_Title=Windows 7 should be configured with at least the minimum amount of memory
rule520_Problem=A virtual machine running Windows 7 is configured with less than the minimum amount of RAM, which is 512 MB.
rule520_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule520_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule520_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule521_Title=Windows 7 should be configured with the recommended amount of memory
rule521_Problem=A virtual machine running Windows 7 is configured with less than the recommended amount of RAM, which is 1 GB.
rule521_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule521_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
rule521_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule522_Title=Windows Server 2012 should be configured with at least the minimum amount of memory
rule522_Problem=A virtual machine running Windows Server 2012 is configured with less than the minimum amount of RAM, which is 512 MB.
rule522_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule522_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule522_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule523_Title=Windows Server 2012 should be configured with the recommended amount of memory
rule523_Problem=A virtual machine running Windows Server 2012 is configured with less than the recommended amount of RAM, which is 2 GB.
rule523_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule523_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
rule523_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule524_Title=Windows 8 should be configured with at least the minimum amount of memory
rule524_Problem=A virtual machine running Windows 8 is configured with less than the minimum amount of RAM, which is 512 MB.
rule524_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule524_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule524_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule525_Title=Windows 8 should be configured with the recommended amount of memory
rule525_Problem=A virtual machine running Windows 8 is configured with less than the recommended amount of RAM, which is 1 GB.
rule525_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule525_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
rule525_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule526_Title={1} should be configured with at least the minimum amount of memory
rule526_Problem=A virtual machine running {1} is configured with less than the minimum amount of RAM, which is 512 MB.
rule526_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule526_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule526_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule527_Title={1} should be configured with the recommended amount of memory
rule527_Problem=A virtual machine running {1} is configured with less than the recommended amount of RAM, which is 2 GB.
rule527_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule527_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 2 GB.
rule527_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule528_Title={1} should be configured with at least the minimum amount of memory
rule528_Problem=A virtual machine running {1} is configured with less than the minimum amount of RAM, which is 512 MB.
rule528_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule528_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule528_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule529_Title={1} should be configured with the recommended amount of memory
rule529_Problem=A virtual machine running {1} is configured with less than the recommended amount of RAM, which is 1 GB.
rule529_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule529_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
rule529_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule530_Title={1} should be configured with at least the minimum amount of memory
rule530_Problem=A virtual machine running {1} is configured with less than the minimum amount of RAM, which is 512 MB.
rule530_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule530_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule530_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule531_Title={1} should be configured with the recommended amount of memory
rule531_Problem=A virtual machine running {1} is configured with less than the recommended amount of RAM, which is 1 GB.
rule531_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule531_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
rule531_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule532_Title={1} should be configured with at least the minimum amount of memory
rule532_Problem=A virtual machine running {1} is configured with less than the minimum amount of RAM, which is 512 MB.
rule532_Impact=The guest operating system on the following virtual machines might not run or might run unreliably:\n{0}
rule532_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 512 MB.
rule532_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule533_Title={1} should be configured with the recommended amount of memory
rule533_Problem=A virtual machine running {1} is configured with less than the recommended amount of RAM, which is 1 GB.
rule533_Impact=The guest operating system and applications might not perform well. There might not be enough memory to run multiple applications at once. This impacts the following virtual machines:\n{0}
rule533_Resolution=Use Hyper-V Manager to increase the memory allocated to this virtual machine to at least 1 GB.
rule533_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule576_Title=Avoid using checkpoints on a virtual machine that runs a server workload in a production environment
rule576_Problem=A virtual machine with one or more checkpoints has been found.
rule576_Impact=Available space may run out on the physical disk that stores the checkpoint files. If this occurs, no additional disk operations can be performed on the physical storage. Any virtual machine that relies on the physical storage could be affected.
rule576_Resolution=If the virtual machine runs a server workload in a production environment, use Hyper-V Manager to apply or delete the checkpoints.
rule576_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.
        
rule600_Title=Configure a virtual machine with a SCSI controller to be able to hot plug and hot unplug storage
rule600_Problem=A virtual machine was found that is not configured with a SCSI controller.
rule600_Impact=You will not be able to hot plug or hot unplug storage for the following virtual machines:\n{0}
rule600_Resolution=If you do not need to hot plug or hot unplug storage for this virtual machine, no action is required. Otherwise, shut down the virtual machine and add a SCSI controller to the configuration.
rule600_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule602_Title=Avoid configuring virtual machines to allow unfiltered SCSI commands
rule602_Problem=A virtual machine is configured to allow unfiltered SCSI commands.
rule602_Impact=Bypassing SCSI command filtering poses a security risk. This configuration should be enabled only if it is required for compatibility with storage applications running in the guest operating system. The following virtual machines are configured to allow unfiltered SCSI commands:\n{0}
rule602_Resolution=Contact your storage vendor to determine if this configuration is required. Also, if the management operating system or other guest operating systems are compromised or exhibit unusual behavior, reconfigure the virtual machine to block the commands.
rule602_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule604_Title=Avoid using virtual hard disks with a sector size less than the sector size of the physical storage that stores the virtual hard disk file
rule604_Problem=One or more virtual hard disks have a physical sector size that is smaller than the physical sector size of the storage on which the virtual hard disk file is located.
rule604_Impact=Performance problems might occur on the virtual machine or application that use the virtual hard disk. This impacts the following virtual machines:\n{0}
rule604_Resolution=Do one of the following: Perform a storage migration to move the virtual hard disk to a new physical system, use Windows PowerShell or WMI to enable a VHDX-format virtual hard disk to report a specific sector size, or use a registry setting to enable a VHD-format virtual hard disk to report a physical sector size of 4k.
rule604_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule605_Title=Avoid enabling storage Quality of Service when using a differencing virtual hard disk when the parent and child virtual hard disks are on different volumes.
rule605_Problem=A differencing virtual hard disk with the parent and child virtual hard disks on different volumes has storage Quality of Service enabled.
rule605_Impact=This configuration may result in unexpected storage Quality of Service behavior for the differencing virtual hard disk, as well as other virtual hard disks on the parent and child volumes. This impacts the following the virtual hard disks:\n{0}
rule605_Resolution=Disable storage Quality of Service on the referenced virtual hard disks, or perform a storage migration to move the parent and the child virtual hard disk to the same volume.
rule605_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule606_Title=Shared virtual hard disks should only be assigned to virtual machines in the same virtual machine group.
rule606_Problem=A shared virtual hard disk is assigned to two or more virtual machines not in the same virtual machine group.
rule606_Impact=This may result in unexpected checkpoint behavior for the following virtual machines: \n{0}
rule606_Resolution=Ensure that the referenced virtual machines with the same shared virtual hard disk attached are in the same virtual machine group.
rule606_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule652_Title=Avoid mapping one storage path to multiple resource pools.
rule652_Problem=A storage file path is mapped to multiple resource pools.
rule652_Impact=For the specified storage pool type, the following parent and child pools share the same storage path:\n{0}
rule652_Resolution=Use Windows PowerShell to reconfigure the storage resource pools so that multiple pools do not use the same storage path.
rule652_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

rule675_Title=Serial ports should not be configured on generation 2 virtual machines.
rule675_Problem=One or more generation 2 virtual machines have a serial port configured.
rule675_Impact=Performance might be affected for the following virtual machines: \n{0}
rule675_Resolution=If this is intentional, no further action is required. Otherwise consider using Hyper-V Manager or PowerShell to remove the connection string from the serial ports on the virtual machine.
rule675_Compliant=The Hyper-V Best Practices Analyzer scan has determined that you are in compliance with this best practice.

###PSLOC - End Localization
'@
