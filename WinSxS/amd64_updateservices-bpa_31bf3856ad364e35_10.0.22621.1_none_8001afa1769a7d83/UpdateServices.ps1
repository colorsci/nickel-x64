
Import-LocalizedData -BindingVariable _system_translations -filename UpdateServices.psd1

#
# ------------------
# CONSTANTS - START
# ------------------
#

$RoleUpdateName = "UpdateServices"
$RoleUpdateDBName = "UpdateServices-DB"
$RoleUpdateWidName = "UpdateServices-WidDB"
$RoleUpdateServiceName = "UpdateServices-Services"
$UpdateServicesDefaultPort = 80
$UpdateServicesAssemgblyPartialName = "Microsoft.UpdateServices.Administration"
$UpdateServicesURL = "http://{0}:{1}/SelfUpdate/iuident.cab"
$WyukonInstanceName = "MICROSOFT##SSEE"
$DefaultDatabaseName = "SUSDB"
$WSUSRegistryKey = "HKLM:\Software\Microsoft\Update Services\Server\Setup"
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

#
# Role Information obtained.
#
RoleQueryShutdown

$doc

# Invoke submodels
#
if ( $wsusInstalled )
{
    $wsusDBInstalled = ((IsRoleInstalled $RoleUpdateDBName) -or (IsRoleInstalled $RoleUpdateWidName))
    if( $wsusDBInstalled )
    {
        Invoke-BpaModel Microsoft/Windows/UpdateServices -SubModelId UpdateServices-DB
    }

    $wsusServiceInstalled = (IsRoleInstalled $RoleUpdateName) 
    if( $wsusServiceInstalled )
    {
        Invoke-BpaModel Microsoft/Windows/UpdateServices -SubModelId UpdateServices-Services
    }
}


#
# ------------------------
# SCRIPT MAIN BODY - END
# ------------------------
#
