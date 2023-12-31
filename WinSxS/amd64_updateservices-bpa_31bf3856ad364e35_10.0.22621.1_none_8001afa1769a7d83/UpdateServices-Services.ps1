
Import-LocalizedData -BindingVariable _system_translations -filename UpdateServices-Services.psd1

#
# ------------------
# CONSTANTS - START
# ------------------
#

$RoleUpdateName = "UpdateServices-Services"
$UpdateServicesDefaultPort = 8530
$UpdateServicesAssemgblyPartialName = "Microsoft.UpdateServices.Administration"
$UpdateServicesURL = "http://{0}:{1}/SelfUpdate/iuident.cab"
$SkipLanguageCheck = $false
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
# This function will check if the selfupdate tree is properly installed. A proper installation 
# of the SelfUpdate tree is determined by verifying that the file iuident.cab is located in the 
# SelfUpdate VDIR. The check is done by issuing a request over http to the Url of the file which 
# looks like http://<host>:<port>/SelfUpdate/iuident.cab, where <host> is the server where WSUS 
# is installed and <port> is the port at which WSUS is configured. WSUS server is always running 
# on port the default port 80. Beside the default port, WSUS could be configured to use another 
# port. If that is the case then an extra check to the file iuident.cab is made on the other port.
#
# <Arguments>
#
# None
#
# <Return Value>
#
#  An xml fragment of the element SelfUpdateTree in the xml document
#############################################################################################

function getSelfUpdateTreeData
{
    $hostName = [System.Net.Dns]::GetHostName()
    $defaultUrl = $UpdateServicesURL -f $hostName, $UpdateServicesDefaultPort
    
    try
    {
        $portNumber = $updateServer.PortNumber

        if($portNumber -ne $UpdateServicesDefaultPort)
        {
            $nonDefaultUrl = $UpdateServicesURL -f $hostName, $portNumber
            $webRequest = [System.Net.WebRequest]::Create($nonDefaultUrl)
        }
        else
        {
            $webRequest = [System.Net.WebRequest]::Create($defaultUrl)
        }
        
        $webResponse = $webRequest.GetResponse()
        $webResponse.Close()
        
        
        $cabExists = $true
    }
    catch
    {
        $cabExists = $false
    }
    
@"
    <SelfUpdateTree>
        <SelfUpdateNode>
            <CabFileExists>$cabExists</CabFileExists>
        </SelfUpdateNode>
    </SelfUpdateTree>
"@
}

#############################################################################################
# <Function Description>
#
# This function checks if all languages are enabled for WSUS.
#
# <Arguments>
#
# None
#
# <Return Value>
#
#  An xml fragment of the element ProductLanguage in the xml document
#############################################################################################

function getProductLanguageData
{
    if($SkipLanguageCheck)
    {
        $allLanguagesEnabled = $false
    }
    else
    {
        $allLanguagesEnabled = $updateServer.GetConfiguration().AllUpdateLanguagesEnabled
    }
    
@"
    <ProductLanguage>
        <AllUpdateLanguagesEnabled>$allLanguagesEnabled</AllUpdateLanguagesEnabled>
    </ProductLanguage>
"@
}

#############################################################################################
# <Function Description>
#
# This function determines whether WSUS content is located on system drive.
#
# <Arguments>
#
# None
#
# <Return Value>
#
#  An xml fragment of the element ContentDatabase in the xml document
#############################################################################################

function getContentData
{
    $configuration = $updateServer.GetConfiguration()
    $systemDrive = Get-WmiObject -ComputerName localhost -Class Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive
    
    if($configuration.HostBinariesOnMicrosoftUpdate -eq $true)
    {
        $localContentCacheOnSystemDrive = $false
        $SkipLanguageCheck = $true
    }
    else
    {
        $contentPath = $updateServer.GetConfiguration().LocalContentCachePath
    
        # check if the content cache is on system drive
        $localContentCacheOnSystemDrive = $contentPath.StartsWith($systemDrive, [System.StringComparison]::InvariantCultureIgnoreCase)
        $SkipLanguageCheck = $false
    }
    
@"
    <ContentDatabase>
        <LocalContentCacheOnSystemDrive>$localContentCacheOnSystemDrive</LocalContentCacheOnSystemDrive>
    </ContentDatabase>
"@
}


function main($document)
{
    $selfUpdateTreeText = getSelfUpdateTreeData
    
    if ($selfUpdateTreeText.Length -gt 0)
    {
        $document.DocumentElement.CreateNavigator().AppendChild($selfUpdateTreeText)
    }
    
    $productLanguageText = getProductLanguageData
    
    if ($productLanguageText.Length -gt 0)
    {
        $document.DocumentElement.CreateNavigator().AppendChild($productLanguageText)
    }  
    
    $contentDatabaseText = getContentData
    
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

$wsusInstalled = (IsRoleInstalled $RoleUpdateName) -and (initializeEnvironment)

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
