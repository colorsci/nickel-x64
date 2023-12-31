
Import-LocalizedData -BindingVariable _system_translations -filename UpdateServices-DB.psd1

#
# ------------------
# CONSTANTS - START
# ------------------
#

$RoleUpdateDBName = "UpdateServices-DB"
$RoleUpdateWidName = "UpdateServices-WidDB"
$UpdateServicesAssemgblyPartialName = "Microsoft.UpdateServices.Administration"
$WyukonInstanceName = "MICROSOFT##WID"
$DefaultDatabaseName = "SUSDB"
$WSUSRegistryKey = "HKLM:\Software\Microsoft\Update Services\Server\Setup"
$XmlDocumentNamespace = "http://schemas.microsoft.com/bestpractices/models/ServerManager/WSUS/WSUSComposite/2008/04"
#
# ------------------
# CONSTANTS - END
# ------------------
#

#
# ------------------
# FUNCTIONS - START
# ------------------
#

#############################################################################################
# Function Description:
#  Creates the Document element for the Xml Document
#
# Arguments:
#  $wsusInstalled - A value indicating whether wsus is installed on the machine.
#
# Return Value:
#  returns the created document element
#############################################################################################
function CreateXmlDocument( $wsusInstalled )
{
    # 
    # Set the Target Namespace to be used by XML
    #

    [xml] "<WSUSComposite xmlns='$XmlDocumentNamespace'><WSUSInstalled>$wsusInstalled</WSUSInstalled></WSUSComposite>"
}

#############################################################################################
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
#############################################################################################
function RoleQueryInitialize
{
    Import-Module ServerManager
}

#############################################################################################
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
#############################################################################################
function RoleQueryShutdown
{
    Remove-Module ServerManager
}

#############################################################################################
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
#############################################################################################
function IsRoleInstalled ( $roleId )
{
    $roleInstalled = $false
    
    #
    # Use the Server Manager CmdLet to obtain detail about Role
    #
    $Role = Get-WindowsFeature $roleId
    
    if ( $Role -ne $null ) 
    {
        $roleInstalled = $Role.Installed
    }

    $roleInstalled
}

# <Function Description>
#
# Initializes the environment/variables to collect WSUS configuration data
#
# <Arguments>
#
# None
#
# <Return Value>
#
# True if initialization is successful otherwise false.
#############################################################################################

function initializeEnvironment
{
    $updateServicesAssembly = [System.Reflection.Assembly]::LoadWithPartialName($UpdateServicesAssemgblyPartialName)

    if($updateServicesAssembly -ne $null)
    {
        # Delete the variable in case the script is executed multiple times from the same runspace
        if(test-path variable:\updateServer)
        {
            del variable:\updateServer -force
        }
        
        new-Variable -name updateServer -value $([Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()) -scope Global -option readonly 
        
        $true
    }
    else
    {
        $false
    }
}

#############################################################################################
# <Function Description>
#
# This function checks if WSUS is running on a domain controller.
#
# <Arguments>
#
# None
#
# <Return Value>
#
#  An xml fragment of the element DomainController in the xml document
#############################################################################################
function getDomainControllerData
{  
    switch( Get-WmiObject -ComputerName localhost -Class Win32_ComputerSystem | Select-Object -ExpandProperty DomainRole ){
                5{ $domainController = $true; break }
                4{ $domainController = $true; break }
                default{ $domainController = $false; break }
    }

@"
    <DomainController>
        <RunningOnDomainController>$domainController</RunningOnDomainController>
    </DomainController>
"@           
}

#############################################################################################
# <Function Description>
#
# This function determines whether WSUS database is located on system drive.
#
# <Arguments>
#
# None
#
# <Return Value>
#
#  An xml fragment of the element ContentDatabase in the xml document
#############################################################################################

function getDatabaseData
{
    $configuration = $updateServer.GetConfiguration()
    $systemDrive = Get-WmiObject -ComputerName localhost -Class Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive
    
    $setupRegistryKey = Get-ItemProperty -Path $WSUSRegistryKey
    
    #$sqlInstanceIsRemoteValue = $setupRegistryKey.SqlInstanceIsRemote
    

    $sqlServerName = $setupRegistryKey.SqlServerName
    
    # Build connection string
    if($sqlServerName.ToUpper([System.Globalization.CultureInfo]::InvariantCulture).EndsWith($WyukonInstanceName) -eq $true)
    {
        $connectionString = 'Net=dbnmpntw;Data Source=\\.\pipe\Microsoft##WID\tsql\query'
        $localMachine = $true
    }
    else
    {
        # In case sql server is running in a named instance
        $sqlMachineName = $sqlServerName.Split('\')[0]
        $localMachine = IsMachineLocal($sqlMachineName)
        
        $connectionString = "Data Source={0}" -f $sqlServerName
    }
    
    
    $AnyDatabaseFileOnSystemDrive = $false
    
    $connectionString = '{0};Trusted_Connection=Yes;' -f $connectionString
    
    try
    {
     $sqlConnection = new-Object System.Data.SqlClient.SqlConnection($connectionString)
        $sqlCommand = new-Object System.Data.SqlClient.SqlCommand("sp_helpdb N'SUSDB'", $sqlConnection)
        $sqlConnection.Open()
        $reader = $sqlCommand.ExecuteReader()
        
        if($reader.NextResult())
        {
        $databaseError = $false
        
        while($reader.Read())
        {
            $fileName = $reader.GetString(2)
            
            if($fileName.StartsWith($systemDrive, [System.StringComparison]::InvariantCultureIgnoreCase))
            {
            $AnyDatabaseFileOnSystemDrive = $true
            
            break
            }
            
        }
        }
        else
        {
        $databaseError = $true
        }
    }
    catch
    {
      $databaseError = $true
    }
    finally
    {
        $sqlConnection.Dispose()
    }
@"
    <ContentDatabase>
        <DatabaseError>$databaseError</DatabaseError>
        <AnyDatabaseFileOnSystemDrive>$AnyDatabaseFileOnSystemDrive</AnyDatabaseFileOnSystemDrive>
    </ContentDatabase>
"@
}

#############################################################################################
# <Function Description>
#
# This function determines whether a machine is local or remote.
#
# <Arguments>
#
# Machine name
#
# <Return Value>
#
#  True if the machine is local.
#############################################################################################

function IsMachineLocal
{
    param([string]$arg1)
    
    $localIps = [System.Net.Dns]::GetHostAddresses($([System.Net.Dns]::GetHostName()))
    $machineIps = [System.Net.Dns]::GetHostAddresses($arg1)
    $isLocal = $false
    
    foreach($ip in $machineIps)
    {
        if([System.Net.IPAddress]::IsLoopback($ip) -eq $true)
        {
            $isLocal = $true
        }
        else
        {
            foreach($localIp in $localIps)
            {
                if($ip.Equals($localIp) -eq $true)
                {
                    $isLocal = $true
                    
                    break
                }
            }
        }
        
        if($isLocal -eq $true)
        {
            break
        }
    }
    
    $isLocal
}

function main($document)
{
    $domainControllerText = getDomainControllerData
    
    if ($domainControllerText.Length -gt 0)
    {
        $document.DocumentElement.CreateNavigator().AppendChild($domainControllerText)
    }
    
    $contentDatabaseText = getDatabaseData
    
    if ($contentDatabaseText.Length -gt 0)
    {
        $document.DocumentElement.CreateNavigator().AppendChild($contentDatabaseText)
    }
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

#
# If WSUS installed, we need to discover data related to that
#

$wsusInstalled = ((IsRoleInstalled $RoleUpdateDBName) -or (IsRoleInstalled $RoleUpdateWidName)) -and (initializeEnvironment)

# Create a new XmlDocument
#
$doc = CreateXmlDocument $wsusInstalled

if ( $wsusInstalled )
{    
    main $doc
}


#
# Role Information obtained.
#
RoleQueryShutdown

$doc

#
# ------------------------
# SCRIPT MAIN BODY - END
# ------------------------
#
