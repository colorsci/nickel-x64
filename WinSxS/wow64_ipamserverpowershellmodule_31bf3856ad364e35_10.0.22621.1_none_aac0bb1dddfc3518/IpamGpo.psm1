
<#
  IPAM Provisioning Cmdlet Module
  This module contains cmdlet for Invoke-IpamGpoProvisioning
 #>

# .ExternalHelp IpamGpo.psm1-help.xml
function Invoke-IpamGpoProvisioning
{
<#    
    Input Parameters:
        ${Domain}: Name of the Domain on which Ipam GPOs will be created. This is a mandatory parameter
        ${GpoPrefixName}: Prefix of the GPO Name. This is a mandatory parameter        
        ${IpamServerFqdn}: Ipam Server name in FQDN format. If this parameter is not given, local machine FQDN name is used.        
        ${DelegatedGpoUser}: List of users to be given permission to edit/modify IPAM GPOs
        ${DelegatedGpoGroup}: List of groups to be given permission to edit/modify IPAM GPOs
        ${Force}: If given, default confirmation will not be shown        
#>    

#region Param declarations
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]    
    Param(        
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Domain},

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${GpoPrefixName},
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        ${IpamServerFqdn},
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${DelegatedGpoUser},

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        ${DelegatedGpoGroup},
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        ${DomainController},
        
        [Parameter()]
        [switch]
        ${PassThru},
        
        [Parameter()]
        [switch]
        ${Force}
    )
#endregion
    
    Process {
    
        [string] $MsgActivity = $_system_translations.MsgIpamProvisionining
        
        try 
        {
            $scriptCP = $null
            WriteTraceMessage "Invoke-IpamGpoProvisioning Entered"
                        
            if (!(HandleImportShouldProcessAndShouldContinue)) { WriteTraceMessage "ShouldProcess returned false .. exiting"; return }            
            
            #Make the CP as high so that we dont get any confirm prompt for calls before our own SP/SC calls
            set-variable -name ConfirmPreference -scope 0 -value ([System.Management.Automation.ConfirmImpact]$ConfirmImpactHigh) -Confirm:$false
            
            Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgValidatingParams

            [bool]$dcGiven = $true
            if ($null -eq ${DomainController} -or "" -eq ${DomainController}) { $dcGiven = $false }
            
            # Validate and retreive the domain controller name and ipamserver fqdn
            $domainObj      = GetDomainNameObj ${Domain}
            $domainName     = $domainObj.Name
            $dcServerName   = ${DomainController}
            $ipamServerName = GetIpamServerName

            CheckCrossForestGPOProvisioning $domainObj

            WriteTraceMessage ("domainName: $domainName ## dcServerName: $dcServerName ## DC-Given: $dcGiven ## ipamServerName: $ipamServerName");
	        
            # Provision Ipam
            ProvisionIpam $dcServerName $domainName $ipamServerName $dcGiven
            if (${PassThru}) {
                return $script:OutputObj
            }
        }
        
        catch { 
            WriteTraceMessage "Inside Invoke-IpamGpoProvisioning Process catch"            
            $PSCmdlet.ThrowTerminatingError($_) 
        }
        
        finally  {
            WriteTraceMessage "Inside Invoke-IpamGpoProvisioning Process finally"            
        }
    }
}

# This function will check if the GPO Provisioning is invoked on a domain from a different forest and update the flag IsCrossForestConfig
function CheckCrossForestGPOProvisioning($inputDomain)
{
    try
    {
        $currentForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

        if($null -eq $currentForest)
        {
            $errMsg = ($_system_translations.ErrorMsgGetCurrentForestFailed)
            ThrowTEString $errMsg
        }

        $currentForestName = $currentForest.Name.ToUpper()

        $inputForestName = $inputDomain.Forest.Name.ToUpper()

        if($currentForestName.Equals($inputForestName))
        {
            $Script:IsCrossForestConfig = $false
        }
        else
        {
            $Script:IsCrossForestConfig = $true
        }
    }
    catch {
        WriteTraceMessage "Getting current Forest failed with error $_ "
        throw
    }
}

# This function retrieves the current domain name and stores it in CurrentDomainName variable for creating IPAM UG 
function GetCurrentDomainForIPAMUG()
{
    try
    {
        $currentDomain=[System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

        if($null -eq $currentDomain)
        {
            $errMsg = ($_system_translations.ErrorMsgGetCurrentDomainFailed)
            ThrowTEString $errMsg
        }

        $Script:CurrentDomainName = $currentDomain.Name
    }
    catch {
        WriteTraceMessage "Getting current Domain failed with error $_ "
        throw
    }
}

# Provisions the Ipam by 
#   Creating the Universal Group if not already created and adding the IpamServer to the group
#   Creating the GPOs and linking it with domain name, removing the authenticated users and adding Users/Groups to the delegation group
#   Updating the DNS ACLs
#   Clear kerberose tickets for network service account
function ProvisionIpam([string]$dcServerName, [string]$domain, [string]$ipamServerName, [bool]$dcGiven)
{   
    WriteTraceMessage "ProvisionIpam entered"
    
    # Get the GPO name prefixing the user given GpoPrefixName
    [string] $gpoPrefix = ${GpoPrefixName}
    $DHCP_GPO           = "$gpoPrefix" + "_DHCP"
    $DNS_GPO            = "$gpoPrefix" + "_DNS"
    $DC_NPS_GPO         = "$gpoPrefix" + "_DC_NPS"
    
    $currentpath        = $env:SystemRoot + "\system32\ipam\Provisioning"
    
    # Get domainName for the IpamServer
    try {
        $compInfo = Invoke-Command -ComputerName $ipamServerName -ScriptBlock { Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem } -ErrorAction Stop
        $ipamServerDomain = $compInfo.Domain        
        WriteTraceMessage "IpamServer $ipamServerName domain is: $ipamServerDomain"
    }
    catch {
        WriteTraceMessage "Get-WmiObject for Win32_ComputerSystem failed for $ipamServerName, $_"
        $ipamServerDomain = ""
    }
    
    GetCurrentDomainForIPAMUG

    # Get DistinguishedName for IpamServer and Domain    
    $ipamServerDName    = GetComputerDNName $ipamServerName $false $ipamServerDomain
    $dcUniqeName        = GetComputerDNName $domain $true ""
    $currentDCName = GetComputerDNName $Script:CurrentDomainName $true ""
        
    $ipamUGCreated = $msdnAclObjAdded = $false
    $gpoCreatedCount = 0;
    
    TraceProvisioningEntities
    
    try
    {   
        # Create (if needed) the UG and Add the Ipam server machine to it
        $ugDNName = "CN=$IpamUGName,CN=Users," + $currentDCName
        $uGCNName = "CN=$IpamUGName"
        $userContainerLdap = "LDAP://CN=Users," + $currentDCName
        WriteTraceMessage "UG-DN-Name: $ugDNName"
        WriteTraceMessage "UG-CN-Name: $uGCNName"
        WriteTraceMessage "User-Container-Ldap: $userContainerLdap"
        
        CreateIpamUGAndAddIpamMachine $ugDNName $ipamServerName $ipamServerDName $ipamServerDomain ([ref] $ipamUGCreated)        
        
        WriteTraceMessage "UG-SID returned: #$script:ipamUGSid#"
        		
        # Create and import the GPOs
        ProvisionGPOs $script:ipamUGSid $dcUniqeName $dcServerName $domain $dcGiven ([ref] $gpoCreatedCount)
            
        # Update DNS ACLs
        $msdnsAclObject = "CN=MicrosoftDNS,CN=System," + $dcUniqeName;        
        
        Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgModifyDnsAcls         
        $msdnAclObjAdded = UpdateDnsAcls $msdnsAclObject $script:ipamUGSid $true        
		
        #  Clear kerberose tickets for network service account		
        klist -lh 0 -li 0x3e4 purge 1>$null
    }
    catch
    {
        # Rollback the changes in case there is any error        
        WriteTraceMessage "Exception in ProvisioningIpam" $true
        
        try
        {   
            if ($ipamUGCreated) {
                WriteTraceMessage "Deleting UGroup $ugDNName"
                try {
                    # Remove the UG                    
                    $dE = New-Object System.DirectoryServices.DirectoryEntry($userContainerLdap)
                    $childEntries = $dE.Children                    
                    $uGroupToDelete = $childEntries.Find($uGCNName, "Group")   
                	$childEntries.Remove($uGroupToDelete)
                }
                catch { 
                    WriteTraceMessage "Failed to remove IpamUGroup: $_" 
                }
            }        
            
            WriteTraceMessage "Inside ProvisionIpam-catch gpoCreatedCount: $gpoCreatedCount"
            if ($gpoCreatedCount -gt 0) {
                WriteTraceMessage "Deleting DNS GPO: $DNS_GPO"
                if ($dcGiven) {
                    Remove-GPO -Name $DNS_GPO -Domain $domain -Server $dcServerName
                }
                else {
                    Remove-GPO -Name $DNS_GPO -Domain $domain
                }
                $gpoCreatedCount -= 1
            }
            if ($gpoCreatedCount -gt 0) {
                WriteTraceMessage "Deleting DC GPO: $DC_NPS_GPO"
                if ($dcGiven) {
                    Remove-GPO -Name $DC_NPS_GPO -Domain $domain -Server $dcServerName        
                }
                else {
                    Remove-GPO -Name $DC_NPS_GPO -Domain $domain
                }
                $gpoCreatedCount -= 1
            }
            if ($gpoCreatedCount -gt 0) {
                WriteTraceMessage "Deleting DHCP GPO: $DHCP_GPO"
                if ($dcGiven) {
                    Remove-GPO -Name $DHCP_GPO -Domain $domain -Server $dcServerName
                }
                else {
                    Remove-GPO -Name $DHCP_GPO -Domain $domain
                }
                $gpoCreatedCount -= 1
            }
            if ($msdnAclObjAdded) {
                WriteTraceMessage "MsdnAclObject was added - removing ..."
                $msdnAclObjAdded = UpdateDnsAcls $msdnsAclObject $script:ipamUGSid $false
            }            
        }
        catch
        {
            WriteTraceMessage "Exception while roll-back ... $_"
        }
        
        throw
    }
}

function TraceProvisioningEntities()
{
    WriteTraceMessage "Domain               : $domainName"    
    WriteTraceMessage "DCServerName         : $dcServerName"
    WriteTraceMessage "IpamServerName       : $ipamServerDName"
    WriteTraceMessage "Current path         : $currentpath"
    WriteTraceMessage "IPAM Server DN-Name  : $ipamServerDName"
    WriteTraceMessage "DCUniqeName          : $dcUniqeName"    
    WriteTraceMessage "GPOs to be created   : $DNS_GPO, $DC_NPS_GPO, $DHCP_GPO"        
}

# Create the IpamUG if not already present
# Add the IpamSID to teh IpamUG
function CreateIpamUGAndAddIpamMachine($ugDNName, $ipamServerName, $IpamServerDName, $ipamServerDomainName, [ref] $ipamUGCreated)
{
    WriteTraceMessage "CreateIpamUG Entered"
    $internalExp = $false
    $ipamUGCreated.Value = $false    
    $uGroup = $null
    try
    { 
        $dE = New-Object System.DirectoryServices.DirectoryEntry($userContainerLdap)
        $childEntries = $dE.Children        
        if ($null -eq $childEntries) { # failed to enumerate child entried - this is generally because of permission issues
            $internalExp = $true
            WriteTraceMessage "CreateIpamUGAndAddIpamMachine: User container child entries is null"
            throw "ChildEntries null"
        }
    
        try {
        	# Get the group if its there
        	$uGroup = $childEntries.Find($uGCNName, "Group")   
        	WriteTraceMessage "$IpamUGName already exists, not creating"
        }
        catch {            
        	# IpamUG doesnt exists, add it
        	WriteTraceMessage "$IpamUGName does not exists, Adding ..."
        	$uGroup = $childEntries.Add($uGCNName, "Group")  	

            $uGroup.InvokeSet("GroupType", $ADS_GROUP_TYPE_UNIVERSAL -bor $ADS_GROUP_TYPE_SECURITY_ENABLED)
            
            $uGroup.CommitChanges()		#This will create the Group in the AD

        	$ipamUGCreated.Value = $true

        	$uGroup.sAMAccountName = $IpamUGName  # By-default auto-generated sAMName is given, give the sAMName as $IpamUGName
        	$uGroup.CommitChanges()	
        }
    
        $sidProperty = $uGroup.Properties["objectSid"]  #This will give the SID as byte array
        $sidObject = new-object System.Security.Principal.SecurityIdentifier($sidProperty.Value, 0)
        $script:ipamUGSid = $sidObject.ToString()        
    }    
    catch
    {
        if ($internalExp) {
            $errMsg = ($_system_translations.ErrorMsgCreateUGFailed -f $IpamUGName,$_system_translations.ErrorNotEnoughPriviledge)
            ThrowTEString $errMsg
        }
        else {
            $errMsg = ($_system_translations.ErrorMsgCreateUGFailed -f $IpamUGName,$_.ToString())            
            ThrowTEException $errMsg $_.Exception
        }
    }
    
    try
    {                
        # Add the IPAM Machine to the IPAMUG        
        Write-Progress -Activity $MsgActivity -Status ($_system_translations.MsgAddIpamServerToUG -f $ipamServerName,$IpamUGName)

        $IpamServerSid = GetIpamServerSidFromDNName $IpamServerDName
        
        #Check if the member is already added         
        $memberAlreadyAdded = $false
        $members = $uGroup.Invoke("Members", $null)
        foreach ( $member in $members) {
            $adMember = new-object System.DirectoryServices.DirectoryEntry($member)
            
            $distinguishedName = $adMember.distinguishedName.ToString()
                    	
            if (($adMember.distinguishedName -eq $IpamServerDName) -or ($distinguishedName.Contains($IpamServerSid)) ) {
    		    $memberAlreadyAdded = $true
    		    WriteTraceMessage "IpamServer $IpamServerDName already member of $IpamUGName"
    		    break
    	    }
        }
        
        # Add the member if its already not added
        if (!$memberAlreadyAdded) {
        	WriteTraceMessage "IpamServer $IpamServerDName NOT found in group $IpamUGName - adding ...."        	

            $ldapQueryForAdd = "LDAP://<SID=" + $IpamServerSid + ">"

        	$uGroup.Invoke("Add", $ldapQueryForAdd)
        }
    }
    catch
    {            
        $errMsg = ($_system_translations.ErrorMsgAddIpamToUGFailed -f $ipamServerName,$IpamUGName,$_.ToString())            
        ThrowTEException $errMsg $_.Exception        
    }
    
    WriteTraceMessage "IPAM UG SID: #$script:ipamUGSid#"        
}

# This function is used to obtain the SID of IPAM machine to add it to the User group
# This function returns the SID if available. If SID is null then it will return the specified DN Name
# It will throw the exception if the translation of DN Name to SID fails
function GetIpamServerSidFromDNName($ipamServerDNName)
{
    WriteTraceMessage "GetIpamServerSidFromDNName entered"
    try
    {
        $ipamServerDE = new-object System.DirectoryServices.DirectoryEntry("LDAP://" + $ipamServerDNName)

        $sidProperty = $ipamServerDE.Properties["objectSid"]  #This will give the SID as byte array

        if($null -ne $sidProperty)
        {
            $sidObject = new-object System.Security.Principal.SecurityIdentifier($sidProperty.Value, 0)
            return $sidObject.ToString()
        }
        else
        {
            return $ipamServerDNName
        }
    }
    catch
    {            
        $errMsg = ($_system_translations.ErrorMsgIpamMachineSIDNotAvaiable -f $ipamServerDNName,$_.ToString())            
        ThrowTEException $errMsg $_.Exception        
    }
}

# Create the GPOs
# Import the template settings
# Linking the GPOs with the domain
# Removing the authenticated users
# Adding Users/Groups to the delegation group if given
function ProvisionGPOs($ipamUGSid, $dcUniqeName, $dcServerName, $domain, $dcGiven, [ref] $gpoCreatedCount)
{     
    try 
    {           
        $gpoCreatedCount.Value = 0
        $gpoTempPath = [System.IO.Path]::GetTempPath() + "ipamprov"
                
        #Create GPOs - if GPOs already exist, its an error
        try
        {        
            Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgCreateGPOs
            WriteTraceMessage "Create GPOs ..."
            if ($dcGiven) {            
                $dnsGpoObj = New-Gpo -Name $DNS_GPO -Domain $domain -Server $dcServerName -ErrorAction Stop
                $gpoCreatedCount.Value = $gpoCreatedCount.Value + 1
                $dcNpsGpoObj = New-Gpo -Name $DC_NPS_GPO -Domain $domain -Server $dcServerName -ErrorAction Stop
                $gpoCreatedCount.Value = $gpoCreatedCount.Value + 1
                $dhcpGpoObj = New-Gpo -Name $DHCP_GPO -Domain $domain -Server $dcServerName -ErrorAction Stop
                $gpoCreatedCount.Value = $gpoCreatedCount.Value + 1
            }
            else {
                $dnsGpoObj = New-Gpo -Name $DNS_GPO -Domain $domain -ErrorAction Stop
                $gpoCreatedCount.Value = $gpoCreatedCount.Value + 1
                $dcNpsGpoObj = New-Gpo -Name $DC_NPS_GPO -Domain $domain -ErrorAction Stop
                $gpoCreatedCount.Value = $gpoCreatedCount.Value + 1
                $dhcpGpoObj = New-Gpo -Name $DHCP_GPO -Domain $domain -ErrorAction Stop
                $gpoCreatedCount.Value = $gpoCreatedCount.Value + 1
            }
            WriteTraceMessage "Create GPOs Completed"
        }
        catch
        {            
            $errMsg = ($_system_translations.ErrorMsgCreateGpoFailed -f $_.ToString())            
            ThrowTEException $errMsg $_.Exception
        }
        
        # Copy the Ipam Provisioning GPO Templates to temp path
        if (($gpoTempPath) -and (Test-Path $gpoTempPath)) { Remove-Item $gpoTempPath -Recurse -Force -ErrorAction SilentlyContinue }
        copy-item -Recurse -Force -Path $currentpath -Destination $gpoTempPath -ErrorAction Stop
        WriteTraceMessage "Temp GPO Path: $gpoTempPath"
        
        TraceProvisioningGpoEntities
        
        # Adjusting Migration Table
        WriteTraceMessage "Adjusting Migration Table - Start"

        $ipamUGFqdn = $IpamUGName + "`@" + $Script:CurrentDomainName        
        $dnsGpoScriptPath  = $StartupScriptRemotePath -f $domain,"{$($dnsGpoObj.Id)}"
        $dhcpGpoScriptPath = $StartupScriptRemotePath -f $domain,"{$($dhcpGpoObj.Id)}"
        $dcnpsGpoScriptPath = $StartupScriptRemotePath -f $domain,"{$($dcNpsGpoObj.Id)}" 
        $dnsWrapScriptLocalPath  = "$gpoTempPath\$DnsGpoGuid\$WrapperScriptLocalRelativePath"
        $dhcpWrapScriptLocalPath = "$gpoTempPath\$DhcpGpoGuid\$WrapperScriptLocalRelativePath"
        $dcnpsWrapScriptLocalPath = "$gpoTempPath\$DC_NpsGpoGuid\$WrapperScriptLocalRelativePath"
        $dnsSchedXmlLocalPath  = "$gpoTempPath\$DnsGpoGuid\$SchedXmlLocalRelativePath"
        $dhcpSchedXmlLocalPath  = "$gpoTempPath\$DhcpGpoGuid\$SchedXmlLocalRelativePath"
        $dcnpsSchedXmlLocalPath = "$gpoTempPath\$DC_NpsGpoGuid\$SchedXmlLocalRelativePath"
        
        WriteTraceMessage "IPAM-UG-FQDN: $ipamUGFqdn"
        WriteTraceMessage "DNS GPO Startup script Path: $dnsGpoScriptPath"
        WriteTraceMessage "DHCP GPO Startup script Path: $dhcpGpoScriptPath"
        WriteTraceMessage "DC-NPS Startup script Path: $dcnpsGpoScriptPath"
        WriteTraceMessage "DNS Wrapper Script Local Path: $dnsWrapScriptLocalPath"
        WriteTraceMessage "DHCP Wrapper Script Local Path: $dhcpWrapScriptLocalPath"
        WriteTraceMessage "DC-NPS Wrapper Script Local Path: $dcnpsWrapScriptLocalPath"
        WriteTraceMessage "DNS ScheduledTask Xml Local Path: $dnsSchedXmlLocalPath"
        WriteTraceMessage "DHCP ScheduledTask Xml Local Path: $dhcpSchedXmlLocalPath"
        WriteTraceMessage "DC-NPS ScheduledTask Xml Local Path: $dcnpsSchedXmlLocalPath"

        # Update IpamUGToken in the migration table for all 3 GPOs
        (get-content $gpoTempPath\dns.migtable)     | % { $_ -replace "ipamugtoken", "$ipamUGFqdn" }    | set-content $gpoTempPath\dns_mod.migtable -encoding Unicode       
        (get-content $gpoTempPath\dc_nps.migtable)  | % { $_ -replace "ipamugtoken", "$ipamUGFqdn" }    | set-content $gpoTempPath\dc_nps_mod.migtable -encoding Unicode       
        (get-content $gpoTempPath\dhcp.migtable)    | % { $_ -replace "ipamugtoken", "$ipamUGFqdn" }    | set-content $gpoTempPath\dhcp_mod.migtable -encoding Unicode   
        
        # Update IpamPathToken in the wrapper script file for DNS GPO
        $tempFile = $dnsWrapScriptLocalPath + "_Temp"
        #Use UTF8 encoding (not UTF-16) to support unicode for Windows server 2008 and also these scripts are originally written using encoding method: ANSI (UTF-8 supports ANSI)  
        (get-content $dnsWrapScriptLocalPath)   | % { $_ -replace "ipampathtoken", "$dnsGpoScriptPath"  }   | set-content $tempFile -encoding UTF8   
        Copy-Item $tempFile $dnsWrapScriptLocalPath -Force
        
        # Update IpamPathToken in the wrapper script file for DHCP GPO
        $tempFile = $dhcpWrapScriptLocalPath + "_Temp"
        (get-content $dhcpWrapScriptLocalPath)  | % { $_ -replace "ipampathtoken", "$dhcpGpoScriptPath" }   | set-content $tempFile -encoding UTF8
        Copy-Item $tempFile $dhcpWrapScriptLocalPath

        # Update IpamPathToken in the wrapper script file for DC-NPS GPO
        $tempFile = $dcnpsWrapScriptLocalPath + "_Temp"
        (get-content $dcnpsWrapScriptLocalPath)  | % { $_ -replace "ipampathtoken", "$dcnpsGpoScriptPath" }   | set-content $tempFile -encoding UTF8
        Copy-Item $tempFile $dcnpsWrapScriptLocalPath
        
        # Update ipamugtoken, ipampathToken, ipamsidtoken in the Schedular XML for DNS GPOs
        $tempFile = $dnsSchedXmlLocalPath + "_Temp"
        #Use UTF8 encoding (not UTF-16) to support unicode here as these xml files are originally written using encoding method: ANSI (UTF-8 supports ANSI) and also we have defined UTF-8 in xml tag for encoding method to be used for this xml
        (get-content $dnsSchedXmlLocalPath)   | % { $_ -replace "ipamugtoken", "$ipamUGFqdn" } | % { $_ -replace "ipampathtoken", "$dnsGpoScriptPath" } | % { $_ -replace "ipamsidtoken", "$ipamUGSid" } | set-content $tempFile -encoding UTF8
        Copy-Item $tempFile $dnsSchedXmlLocalPath -Force
        
        # Update ipamugtoken, ipampathToken, ipamsidtoken in the Schedular XML for DHCP GPOs
        $tempFile = $dhcpSchedXmlLocalPath + "_Temp"
        (get-content $dhcpSchedXmlLocalPath) | % { $_ -replace "ipamugtoken", "$ipamUGFqdn" } | % { $_ -replace "ipampathtoken", "$dhcpGpoScriptPath" } | % { $_ -replace "ipamsidtoken", "$ipamUGSid" } | set-content $tempFile -encoding UTF8
        Copy-Item $tempFile $dhcpSchedXmlLocalPath -Force

        # Update ipamugtoken, ipampathToken, ipamsidtoken in the Schedular XML for DC-NPS GPOs
        $tempFile = $dcnpsSchedXmlLocalPath + "_Temp"
        (get-content $dcnpsSchedXmlLocalPath) | % { $_ -replace "ipamugtoken", "$ipamUGFqdn" } | % { $_ -replace "ipampathtoken", "$dcnpsGpoScriptPath" } | % { $_ -replace "ipamsidtoken", "$ipamUGSid" } | set-content $tempFile -encoding UTF8
        Copy-Item $tempFile $dcnpsSchedXmlLocalPath -Force
                
        WriteTraceMessage "Adjusting Migration Table - Complete"
            
        # Import GPOs
        try
        {
        
            Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgImportGPOs
            WriteTraceMessage "Import GPOs - Start"     
            if ($dcGiven) {
                $temp = Import-Gpo -TargetName $DNS_GPO -BackupGpoName IPAMGPO_DNS -Path $gpoTempPath -MigrationTable "$gpoTempPath\dns_mod.migtable" -Domain $domain -Server $dcServerName -ErrorAction Stop
                $temp = Import-Gpo -TargetName $DC_NPS_GPO -BackupGpoName IPAMGPO_DC_NPS -Path $gpoTempPath -MigrationTable "$gpoTempPath\dc_nps_mod.migtable" -Domain $domain -Server $dcServerName -ErrorAction Stop
                $temp = Import-Gpo -TargetName $DHCP_GPO -BackupGpoName IPAMGPO_DHCP -Path $gpoTempPath -MigrationTable "$gpoTempPath\dhcp_mod.migtable" -Domain $domain -Server $dcServerName -ErrorAction Stop
            }
            else {
                $temp = Import-Gpo -TargetName $DNS_GPO -BackupGpoName IPAMGPO_DNS -Path $gpoTempPath -MigrationTable "$gpoTempPath\dns_mod.migtable" -Domain $domain -ErrorAction Stop
                $temp = Import-Gpo -TargetName $DC_NPS_GPO -BackupGpoName IPAMGPO_DC_NPS -Path $gpoTempPath -MigrationTable "$gpoTempPath\dc_nps_mod.migtable" -Domain $domain -ErrorAction Stop
                $temp = Import-Gpo -TargetName $DHCP_GPO -BackupGpoName IPAMGPO_DHCP -Path $gpoTempPath -MigrationTable "$gpoTempPath\dhcp_mod.migtable" -Domain $domain -ErrorAction Stop
            }
            WriteTraceMessage "Import GPOs - Complete"
        }
        catch
        {
            $errMsg = ($_system_translations.ErrorMsgImportGpoFailed -f $_.ToString())            
            ThrowTEException $errMsg $_.Exception
        }       

        # Link GPOs to the domain
        try
        {            
            Write-Progress -Activity $MsgActivity -Status ($_system_translations.MsgLinkingGPOs -f $domain)
            WriteTraceMessage "Linking new GPOs - Start"    
            if ($dcGiven) {
                $temp = New-GPLink -Name $DNS_GPO -Target $dcUniqeName -Domain $domain -Server $dcServerName
                $temp = New-GPLink -Name $DC_NPS_GPO -Target $dcUniqeName -Domain $domain -Server $dcServerName
                $temp = New-GPLink -Name $DHCP_GPO -Target $dcUniqeName -Domain $domain -Server $dcServerName
            }
            else {
                $temp = New-GPLink -Name $DNS_GPO -Target $dcUniqeName -Domain $domain
                $temp = New-GPLink -Name $DC_NPS_GPO -Target $dcUniqeName -Domain $domain
                $temp = New-GPLink -Name $DHCP_GPO -Target $dcUniqeName -Domain $domain
            }
            WriteTraceMessage "Linking new GPOs - Complete"
        }
        catch
        {
            $errMsg = ($_system_translations.ErrorMsgLinkGpoFailed -f $_.ToString())            
            ThrowTEException $errMsg $_.Exception
        }
        
        # Remove authenticated users
        try
        {        
			$objSID = New-Object System.Security.Principal.SecurityIdentifier($AuthenticatedUsersSid)  			
			$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
			$authUser = $objUser.Value
  			
            WriteTraceMessage "Remove $authUser - Start"
            if ($dcGiven) {
                $temp = Set-GPPermission -Name $DHCP_GPO -PermissionLevel none -TargetName $authUser -TargetType group -Domain $domain -Server $dcServerName
                $temp = Set-GPPermission -Name $DNS_GPO -PermissionLevel none -TargetName $authUser -TargetType group -Domain $domain -Server $dcServerName
                $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel none -TargetName $authUser -TargetType group -Domain $domain -Server $dcServerName
            }
            else {
                $temp = Set-GPPermission -Name $DHCP_GPO -PermissionLevel none -TargetName $authUser -TargetType group -Domain $domain
                $temp = Set-GPPermission -Name $DNS_GPO -PermissionLevel none -TargetName $authUser -TargetType group -Domain $domain
                $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel none -TargetName $authUser -TargetType group -Domain $domain
            }
            
            WriteTraceMessage "Remove $authUser - Complete"
        }
        catch
        {
            $errMsg = ($_system_translations.ErrorMsgRemoveAuthUserFailed -f $_.ToString())            
            ThrowTEException $errMsg $_.Exception
        }

        # Delegate permissions to Users and Groups        
        if ($null -ne ${DelegatedGpoUser} -and ${DelegatedGpoUser}.Length -gt 0) {
            try
            {
                Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgAddDelegatedUsers
                WriteTraceMessage "Delegating Privilege to Users - Start"
                if ($dcGiven) {
                    ${DelegatedGpoUser} | % { $temp = Set-GPPermission -Name $DNS_GPO    -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType User -Domain $domain -Server $dcServerName }
                    ${DelegatedGpoUser} | % { $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType User -Domain $domain -Server $dcServerName }
                    ${DelegatedGpoUser} | % { $temp = Set-GPPermission -Name $DHCP_GPO   -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType User -Domain $domain -Server $dcServerName }
                }
                else {
                    ${DelegatedGpoUser} | % { $temp = Set-GPPermission -Name $DNS_GPO    -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType User -Domain $domain }
                    ${DelegatedGpoUser} | % { $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType User -Domain $domain }
                    ${DelegatedGpoUser} | % { $temp = Set-GPPermission -Name $DHCP_GPO   -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType User -Domain $domain }
                }
            }
            catch
            {
                $errMsg = ($_system_translations.ErrorMsgDeleteUserFailed -f $_.ToString())            
                ThrowTEException $errMsg $_.Exception                
            }
        }
        
        if ($null -ne ${DelegatedGpoGroup} -and ${DelegatedGpoGroup}.Length -gt 0) {
            try
            {
                Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgAddDelegatedGroups
                WriteTraceMessage "Delegating Privilege to Groups - Start"
                if ($dcGiven) {
                    ${DelegatedGpoGroup} | % { $temp = Set-GPPermission -Name $DNS_GPO    -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain -Server $dcServerName }
                    ${DelegatedGpoGroup} | % { $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain -Server $dcServerName }
                    ${DelegatedGpoGroup} | % { $temp = Set-GPPermission -Name $DHCP_GPO   -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain -Server $dcServerName }
                }
                else {
                    ${DelegatedGpoGroup} | % { $temp = Set-GPPermission -Name $DNS_GPO    -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain }
                    ${DelegatedGpoGroup} | % { $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain }
                    ${DelegatedGpoGroup} | % { $temp = Set-GPPermission -Name $DHCP_GPO   -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain }
                }
            }
            catch
            {
                $errMsg = ($_system_translations.ErrorMsgDeleteGroupFailed -f $_.ToString())            
                ThrowTEException $errMsg $_.Exception
            }
        }
        
        $setPermissionSucceeded = $false;
        $timeout = New-TimeSpan -Minutes 2
        $stopWatch = [diagnostics.stopwatch]::StartNew()
        while ($stopWatch.elapsed -lt $timeout){

            try
            {
                #Write-Progress -Activity $MsgActivity -Status $_system_translations.MsgAddDelegatedIpamUGGroup
                WriteTraceMessage "Giving Privilege to $ipamUGFqdn"
                if ($dcGiven) {
                    ${ipamUGFqdn} | % { $temp = Set-GPPermission -Name $DNS_GPO    -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain -Server $dcServerName }
                    ${ipamUGFqdn} | % { $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain -Server $dcServerName }
                    ${ipamUGFqdn} | % { $temp = Set-GPPermission -Name $DHCP_GPO   -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain -Server $dcServerName }
                }
                else {
                    ${ipamUGFqdn} | % { $temp = Set-GPPermission -Name $DNS_GPO    -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain }
                    ${ipamUGFqdn} | % { $temp = Set-GPPermission -Name $DC_NPS_GPO -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain }
                    ${ipamUGFqdn} | % { $temp = Set-GPPermission -Name $DHCP_GPO   -PermissionLevel GpoEditDeleteModifySecurity -TargetName $_ -TargetType Group -Domain $domain }
                }

                $setPermissionSucceeded = $true;
                break;
            }
            catch
            {
                $errMsg = ($_system_translations.ErrorMsgDeleteGroupFailed -f $_.ToString())                            
            }
 
            Start-Sleep -seconds 10
        }
        $stopWatch.Stop()

        if(!$setPermissionSucceeded)
        {
            ThrowTEException $errMsg $_.Exception
        }


        $script:OutputObj = @($dnsGpoObj, $dcNpsGpoObj, $dhcpGpoObj)
    }
    catch
    {        
        WriteTraceMessage "Exception Thrown in ProvisionGPOs" $true        
        WriteTraceMessage "Inside ProvisionGpo $($gpoCreatedCount.Value)"
        throw
    }
    finally
    {
        # Cleanup
        Remove-Item $gpoTempPath -Recurse -Force -ErrorAction SilentlyContinue        
    }
}

function TraceProvisioningGpoEntities()
{
    WriteTraceMessage "Domain               : $domain"
    WriteTraceMessage "DCServerName         : $dcServerName"
    WriteTraceMessage "Current path         : $currentpath"
    WriteTraceMessage "DCUniqeName          : $dcUniqeName"
    WriteTraceMessage "GPOs to be created   : $DNS_GPO, $DC_NPS_GPO, $DHCP_GPO"       
    WriteTraceMessage "GPOs Temp Path       : $gpoTempPath"
    WriteTraceMessage "Delegated Users      : ${DelegatedGpoUser}"
    WriteTraceMessage "Delegated Groups     : ${DelegatedGpoGroup}"    
}

# Update (Add or Remove) the ACL from $aclObject
# ACL corresponds to the Read permission for IpamUG group
function UpdateDnsAcls($aclObject, $ipamUGSid, $toAdd=$true)
{
    WriteTraceMessage "UpdateDnsAcls for $aclObject,toAdd=$toAdd - Start"
    WriteTraceMessage "UpdateDnsAcls: Ipam SID: #$ipamUGSid#"
    
    $aclUpdated = $false;    
    try
    {   
        $sidObject = [System.Security.Principal.SecurityIdentifier]"$ipamUGSid"
        # Create the ACl to be added or removed
        $myAcl = $null
        $myObj = [ADSI]"LDAP://$aclObject"
        if ($null -ne $myObj) {
            $myAcl = $myObj.ObjectSecurity
        }        
        if ($null -eq $myAcl) {
            Write-Warning ($_system_translations.WarningDnsAclNotFound -f $aclObject)
            return $aclUpdated
        }
        
        [System.DirectoryServices.ActiveDirectoryRights]$rights = [System.DirectoryServices.ActiveDirectoryRights]"ReadProperty" -bor [System.DirectoryServices.ActiveDirectoryRights]"GenericExecute";
		
        # Check if ACL already exists
        $ugObj = $null
        $objCollection = $myAcl.GetAccessRules($true, $false, $sidObject.GetType()) | where { $_.IdentityReference -eq $sidObject }
        if ($null -ne $objCollection) {
            foreach ($obj in $objCollection) {
                if ($obj.ActiveDirectoryRights -eq $rights) {
                    $ugObj = $obj                        # Acl exist in the $aclObject
                    break;
                }                    
            }
        }
        
        # If the ACL doesnt exists in the $aclObject and function is called for Add, add the acl
        if ($null -eq $ugObj -and $toAdd) {
            $al = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($sidObject, $rights , [System.Security.AccessControl.AccessControlType]'Allow', [System.DirectoryServices.ActiveDirectorySecurityInheritance]'All');        		
            $myAcl.AddAccessRule($al)
            $myObj.PSBase.CommitChanges()            
            $aclUpdated = $true
        }
        # If the ACL exists in the $aclObject and function is called for Remove, remove the acl
        elseif ($null -ne $ugObj -and !$toAdd) {
            $myAcl.RemoveAccessRule($ugObj)
            $myObj.PSBase.CommitChanges()
            $aclUpdated = $true
        }
        else {
            $aclUpdated = $false
        }
    }
    catch
    {        
        WriteTraceMessage "UpdateDnsAcls failed: $_"
        ThrowTEString $_system_translations.ErrorMsgDnsAclUpdateFailed        
    }

    if ($aclUpdated) {
        if ($toAdd) { WriteTraceMessage "Acl was not present, added successfully" } else { WriteTraceMessage "Acl was present, removed successfully" }
    }
    else {
        if ($toAdd) { WriteTraceMessage "Acl was present, NOT added" }
    }

    WriteTraceMessage "UpdateDnsAcls for $aclObject,toAdd=$toAdd - Complete"    
    return $aclUpdated
}

function GetComputerDNName([string]$computerFqdn, [bool]$isDomain = $false, [string]$compDomainName="")
{
    WriteTraceMessage "GetComputerDNName entered ... computerFqdn=$computerFqdn, isDomain=$isDomain, compDomainName=$compDomainName"

    $domainDN = ""
    $computerDN = ""
    $internalException = $false

    $i = $computerFqdn.IndexOf(".")
    
    if ($isDomain) {
        $domainName = $computerFqdn
    }
    elseif ($compDomainName -eq "") {
    	$domainName = $computerFqdn.SubString($i+1)       	
    }
    else {
        $domainName = $compDomainName
    }
	
    # Load System.DirectoryServices.Protocols.dll assemly 
    [System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.Protocols") | Out-Null
    $conn = $null
    	
    try
    {
        # Create LDAP connection to computer's domain	    
        $di = New-Object System.DirectoryServices.Protocols.LdapDirectoryIdentifier($domainName, $LdapPort)
        $conn = New-Object System.DirectoryServices.Protocols.LdapConnection($di)
        
        # Get domain DN from RootDSE
        $rq = new-object System.DirectoryServices.Protocols.SearchRequest
        $rq.Attributes.Add("defaultNamingContext") | Out-Null
        $rq.scope=[System.DirectoryServices.Protocols.SearchScope]::Base
        [System.DirectoryServices.Protocols.ExtendedDNControl]$exDNRqc = New-Object System.DirectoryServices.Protocols.ExtendedDNControl([System.DirectoryServices.Protocols.ExtendedDNFlag]::StandardString)
        $rq.Controls.Add($exDNRqc) | Out-Null
        $rsp = $conn.SendRequest($rq)
        if ($rsp.ResultCode -eq [System.DirectoryServices.Protocols.ResultCode]::Success -and $rsp.Entries.Count -gt 0)
        {
            $sr = $rsp.Entries[0];
            if ($sr.Attributes["defaultnamingcontext"].Count -gt 0)
            {
            	$domainDN = ($sr.Attributes["defaultnamingcontext"][0] -as [String]).Split(";")[2]
    	     	WriteTraceMessage "ComputerDomainDN: $domainDN"
            }
        }
    	
    	if ("" -eq $domainDN) {
            WriteTraceMessage "Cannot retreive DomainDN"			
            $internalException = $true
            $errMsg = ($_system_translations.ErrorMsgServerDoesNotExist -f $computerFqdn)
            ThrowTEString $errMsg $EC_InvalidArgument InvalidArgument		
    	}
    	
    	if ($isDomain) { return $domainDN }
        
        # Now find the computer DN
        $rq = new-object System.DirectoryServices.Protocols.SearchRequest
        $rq.Attributes.Add("distinguishedName") | Out-Null
        $rq.Scope = [System.DirectoryServices.Protocols.SearchScope]::Subtree
        $servicePrincipleName = "host/$computerFqdn"
        $rq.Filter = [string]::Format("(&(objectCategory=computer)(servicePrincipalName={0}))",$servicePrincipleName) 
        $rq.DistinguishedName=$domainDN
        $rq.TimeLimit = New-Object Timespan(0, 0, $LdapConnectionTimeOut)    # Add 5 minutes timeout
        $rsp = $conn.SendRequest($rq)
        if ($rsp.ResultCode -eq [System.DirectoryServices.Protocols.ResultCode]::Success -and $rsp.Entries.Count -gt 0)
        {
            $sr = $rsp.Entries[0];
            if ($sr.Attributes["distinguishedname"].Count -gt 0)    #indexer must be low case
            {
                $computerDN = $sr.Attributes["distinguishedname"][0] -as [String]
                WriteTraceMessage "ComputerDN : $computerDN"
            }
        }
    	if ("" -eq $computerDN) {
            WriteTraceMessage "Cannot retreive computerDN"
            $internalException = $true
            $errMsg = ($_system_translations.ErrorMsgServerDoesNotExist -f $computerFqdn)
            ThrowTEString $errMsg $EC_InvalidArgument InvalidArgument
    	}	    
    }      
    catch
    {
    	if (!$internalException) {
            WriteTraceMessage "GetComputerDNName raised (external) exception for $computerFqdn"
            $errMsg = ($_system_translations.ErrorMsgServerDoesNotExist -f $computerFqdn)
            ThrowTEString $errMsg $EC_InvalidArgument InvalidArgument
    	}	    
        else {
            WriteTraceMessage "GetComputerDNName raised (internal) exception for $computerFqdn"
            throw
        }
    }
    finally 
    {
    	WriteTraceMessage "Inside Finally for GetComputerDNName for $computerFqdn"
        if($conn -ne $null) { $conn.Dispose() }
    }

    return $computerDN
}

function GetDomainNameObj([string]$domainName)
{
    try
    {        
        WriteTraceMessage "GetDomainNameObj entered"
        $directoryContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain, $domainName)
        return [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($directoryContext)
    }
    catch
    {
        $errMsg = ($_system_translations.ErrorMsgGetDomainFailed -f $domainName,$_.ToString())            
        ThrowTEException $errMsg $_.Exception
    }
}

function GetIpamServerName()
{
    WriteTraceMessage "GetIpamServerName entered"    
    if (IsNullOrEmptyString ${IpamServerFqdn}) {
        # Get the localhost FQDN name
        $ipamServer = [System.Net.Dns]::GetHostEntry("localhost").HostName
    }
    else {
        #Validate if the input is in correct format        
        $ipamServer = ${IpamServerFqdn}
        if (!$ipamServer.Contains(".")) {
            # Throw TE for bad format for input IpamServerFqdn
            $errMsg = ($_system_translations.ErrorMsgServerFqdnWrongFormat -f ${IpamServerFqdn})
            ThrowTEString $errMsg $EC_InvalidArgument InvalidArgument
        }
    }
    return $ipamServer
}

# Return $true if given input string is $null or EmptyString ("")
function IsNullOrEmptyString([string] $str) { return ($null -eq $str -or "" -eq $str) }    

#Handles the ShouldProcess and ShouldContinue
function HandleImportShouldProcessAndShouldContinue
{   
    if ($null -eq ${DelegatedGpoUser} -and $null -eq ${DelegatedGpoGroup})
    {
        $shouldProcesMsg    = $_system_translations.Msg_ShouldProcess_WithoutUserAndGroup
        $shouldContinueMsg  = ($_system_translations.Msg_ShouldContinue_WithoutUserAndGroup -f $_system_translations.ShoudContinueConfirmation) 
    }
    else
    {
        $shouldProcesMsg    = $_system_translations.Msg_ShouldProcess_WithUserOrGroup
        $shouldContinueMsg  = ($_system_translations.Msg_ShouldContinue_WithUserOrGroup -f $_system_translations.ShoudContinueConfirmation)         
    }
        
    $result = $PSCmdlet.ShouldProcess($shouldProcesMsg, $null, $null);
    if ($result -and (!${Force})) {
        $result = $PSCmdlet.ShouldContinue($shouldContinueMsg, $_system_translations.ShoudContinueCaption);
    }
    return $result;
}


function ThrowTEString([string]$errMessage, [string] $errorId=([System.Management.Automation.ErrorCategory]::InvalidOperation).ToString(), [System.Management.Automation.ErrorCategory]$errorCategory=[System.Management.Automation.ErrorCategory]::InvalidOperation, [Object] $targetObject=$null)
{ 
    $exception = New-Object System.Exception $errMessage
    $err = New-Object System.Management.Automation.ErrorRecord  ( 
                                $exception,
                                $errorId,
                                $errorCategory,
                                $targetObject 
                             )
    
    throw $err    
}

function ThrowTEException([string]$errMessage, [System.Exception]$exp, [string] $errorId=([System.Management.Automation.ErrorCategory]::InvalidOperation).ToString(), [System.Management.Automation.ErrorCategory]$errorCategory=[System.Management.Automation.ErrorCategory]::InvalidOperation, [Object] $targetObject=$null)
{     
    $exception = New-Object System.Exception($errMessage, $exp)
    $err = New-Object System.Management.Automation.ErrorRecord  ( 
                                $exception,
                                $errorId,
                                $errorCategory,
                                $targetObject 
                             )
    throw $err    
}

# Helper function to write trace messages only when $global:IpamTraceMessage is set to $true
function WriteTraceMessage([string] $message, [bool]$isRed=$false) {
    [System.ConsoleColor] $color = [System.ConsoleColor]::Cyan
    if ($isRed) { $color = [System.ConsoleColor]::Red }
    if ($global:IpamTraceMessage){
        Write-Host -ForegroundColor $color $message
    }
}

#region Constants

New-Variable -Option Constant -Name ERROR_GROUP_EXISTS          -Value 1318
New-Variable -Option Constant -Name IpamUGName                  -Value "IPAMUG"
New-Variable -Option Constant -Name DnsGpoGuid                  -Value "{09673450-4573-42E8-85D0-104144DF0BA3}"
New-Variable -Option Constant -Name DC_NpsGpoGuid               -Value "{8F608EC9-7E94-4203-AA9D-DBEEC85CA610}"
New-Variable -Option Constant -Name DhcpGpoGuid                 -Value "{374BCE3E-7B4E-49F5-811F-12195F97C910}"
New-Variable -Option Constant -Name LdapPort                    -Value 389
New-Variable -Option Constant -Name LdapConnectionTimeOut       -Value 300
New-Variable -Option Constant -Name EC_InvalidArgument          -Value ([System.Management.Automation.ErrorCategory]::InvalidArgument).ToString() 
New-Variable -Option Constant -Name ADS_GROUP_TYPE_SECURITY_ENABLED -Value 0x80000000
New-Variable -Option Constant -Name ADS_GROUP_TYPE_UNIVERSAL    -Value 0x00000008
New-Variable -Option Constant -Name ADS_GROUP_TYPE_DOMAIN_LOCAL    -Value 0x00000004
New-Variable -Option Constant -Name StartupScriptRemotePath     -Value "\\{0}\SYSVOL\{0}\Policies\{1}\Machine\Scripts\Startup"
New-Variable -Option Constant -Name WrapperScriptLocalRelativePath -Value "DomainSysvol\GPO\Machine\Scripts\Startup\ipamprovisioningwrapper.bat"
New-Variable -Option Constant -Name SchedXmlLocalRelativePath   -Value "DomainSysvol\GPO\Machine\Preferences\ScheduledTasks\ScheduledTasks.xml"
New-Variable -Option Constant -Name ConfirmImpactHigh           -Value "High"
New-Variable -Option Constant -Name AuthenticatedUsersSid       -Value "S-1-5-11"
#endregion

#region LocalizedString

# Localized strings

data _system_translations {
   ConvertFrom-StringData @'
   # fallback text goes here    
           
        
        #Error Msg
ErrorMsgServerDoesNotExist= Server {0} does not exist or could not be contacted.
ErrorMsgServerFqdnWrongFormat= Server name {0} should be given in 'Fully Qualified Domain Name' format.
ErrorMsgCreateGpoFailed= Failed to create GPO. {0}
ErrorMsgImportGpoFailed= Failed to import GPO. {0}
ErrorMsgLinkGpoFailed= Failed to link GPO. {0}
ErrorMsgRemoveAuthUserFailed= Failed to remove authenticated users from the GPO. {0}
ErrorMsgDeleteUserFailed= Failed to add user to the delegation list. {0}
ErrorMsgDeleteGroupFailed= Failed to add group to the delegation list. {0}
ErrorMsgGetDomainFailed= Failed to retrieve domain {0}. {1}
ErrorMsgGetDCServerFailed= Failed to retrieve domain controller for domain {0}. {1}
ErrorMsgDnsAclUpdateFailed= Failed to update DNS ACLs.
ErrorMsgIpamUGCreateFailed= Failed to create the universal group {0} on {1}. {2}
ErrorMsgCreateUGFailed= Failed to create universal group {0}. {1}
ErrorMsgAddIpamToUGFailed= Failed to add computer {0} to group {1}. {2}
ErrorMsgGetCurrentForestFailed= Failed to find the current forest. Please check connection to Domain Controller
ErrorMsgGetCurrentDomainFailed= Failed to find the current domain. Please check connection to Domain Controller
ErrorNotEnoughPriviledge= Make sure you have sufficient privileges to perform the operation.
ErrorMsgIpamMachineSIDNotAvaiable= IPAM machine SID could not be found from DN Name {0}. {1}
WarningDnsAclNotFound= Failed to update the DNS ACL {0} since the corresponding Active Directory object was not found. This is expected if you do not have the DNS Server role co-located with a domain controller in the domain. For standalone DNS servers, add the IPAM universal group (IPAMUG) or IPAM machine account to the local Administrators group on the DNS server in order to enable DNS RPC access for IPAM.

    #ShouldProcess/ShouldContinue Messages
Msg_ShouldProcess_WithUserOrGroup= The Invoke-IpamGpoProvisioning cmdlet creates and links three Group Policy Objects in the domain indicated by Domain parameter, for provisioning IPAM access settings on the servers that are managed by IPAM. The cmdlet also modifies the domain wide DNS ACL to enable read access for IPAM. The value of GpoPrefixName must be the same as the one provided in the IPAM provisioning wizard when selecting the option of Group Policy Based provisioning.
Msg_ShouldProcess_WithoutUserAndGroup= The Invoke-IpamGpoProvisioning cmdlet creates and links three Group Policy Objects in the domain indicated by Domain parameter, for provisioning IPAM access settings on the servers that are managed by IPAM. The cmdlet also modifies the domain wide DNS ACL to enable read access for IPAM. The value of GpoPrefixName must be the same as the one provided in the IPAM provisioning wizard when selecting the option of Group Policy Based provisioning.\n\nYou have not specified the optional parameters DelegatedGpoUser or DelegatedGpoGroup. The delegation parameters can be used to enable IPAM GPO edit privileges for users or groups who do not have domain or enterprise administrator privileges, but need to mark servers as managed or unmanaged in IPAM.
Msg_ShouldContinue_WithUserOrGroup= The Invoke-IpamGpoProvisioning cmdlet creates and links three Group Policy Objects in the domain indicated by Domain parameter, for provisioning IPAM access settings on the servers that are managed by IPAM. The cmdlet also modifies the domain wide DNS ACL to enable read access for IPAM. The value of GpoPrefixName must be the same as the one provided in the IPAM provisioning wizard when selecting the option of Group Policy Based provisioning. {0}
Msg_ShouldContinue_WithoutUserAndGroup= The Invoke-IpamGpoProvisioning cmdlet creates and links three Group Policy Objects in the domain indicated by Domain parameter, for provisioning IPAM access settings on the servers that are managed by IPAM. The cmdlet also modifies the domain wide DNS ACL to enable read access for IPAM. The value of GpoPrefixName must be the same as the one provided in the IPAM provisioning wizard when selecting the option of Group Policy Based provisioning.\n\nYou have not specified the optional parameters DelegatedGpoUser or DelegatedGpoGroup. The delegation parameters can be used to enable IPAM GPO edit privileges for users or groups who do not have domain or enterprise administrator privileges, but need to mark servers as managed or unmanaged in IPAM. {0}
ShoudContinueCaption= Confirm
ShoudContinueConfirmation= Do you want to perform this action?

    #Progress-bar messages
MsgIpamProvisionining= Provisioning IPAM ...
MsgValidatingParams= Validating parameters ...
MsgCreateUG= Creating IPAM universal group {0} ...
MsgAddIpamServerToUG= Adding IPAM Server {0} to universal group {1} ...
MsgCreateGPOs= Creating GPOs ...
MsgImportGPOs= Importing GPOs ...
MsgLinkingGPOs= Linking GPOs to domain {0} ...
MsgAddDelegatedUsers= Adding users to the delegation list ...
MsgAddDelegatedGroups= Adding groups to the delegation list ...
MsgAddDelegatedIpamUGGroup= Adding IPAM UG group to the delegation list ...
MsgModifyDnsAcls= Updating DNS ACLs ...
'@
}

Import-LocalizedData -BindingVariable _system_translations -filename IpamGPO.psd1

#endregion

[bool]$global:IpamTraceMessage = $false

Set-StrictMode -Version 3
Export-ModuleMember Invoke-IpamGpoProvisioning


