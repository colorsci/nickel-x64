# Disable the one time scheduled task that migrates Office license
Function DisableScheduledTask
{
    & schtasks /change /TN "\Microsoft\AppV\Office License Migrator" /disable

    return
}

# Found "Integrator.exe" in this folder which is the program used to migrate\install Office License.
# Double check if this is indeed the folder that has Office package
Function IsOfficePackage 
{
    param ([System.IO.FileInfo]$integratorexe)
    
    $packageDirectory = Split-Path -parent $integratorexe.DirectoryName
    $files = Get-ChildItem $packageDirectory -Recurse | Where-Object {$_.GetType().Name -eq "FileInfo"} ;
    foreach ($file in $files) 
    {
        # If an executable by name MSO.DLL is found then we will treat this as an Office package
        if ($file.Name -eq "MSO.DLL")
        {              
            return $true
        }
    }
    
    return $false
}

Function GetIntegratorArgumentsFromAppxManifest()
{
    param ([String]$packageFolder)

    # Read the arguments to be passed to Integrator.exe from AppxManifest.xml

    $integratorArguments = ''

    [xml]$appxManifest = Get-Content $packageFolder\AppxManifest.xml
    $xmlNamespace = @{ appv = 'http://schemas.microsoft.com/appv/2010/manifest'}
    $addPackageArgNode = Select-Xml -Xml $appxManifest -XPath '//appv:MachineScripts/appv:AddPackage/appv:Arguments' -Namespace $xmlNamespace
    $addPackageArgs = $addPackageArgNode.Node."#text"

    return $addPackageArgs
}

# Look for Office package and if found execute "Integrator.exe" to migrate Office license
Function ExecuteOfficeIntegrator 
{
    param ([String]$appVIntegrationFolder)

    # Unless there is an error executing Office License migration program assume migration is successful
    $migrationSuccessful = $true

    if ($appVIntegrationFolder -eq '')
    {
        return $migrationSuccessful
    }

    # First check if App-V is installed on this machine. If not, nothing more to do
    if (!(Test-Path -Path $appVIntegrationFolder))
    {        
        return $migrationSuccessful
    }

    # Found App-V client directory. Search for Office package
    pushd $appVIntegrationFolder

    $files = Get-ChildItem $appVIntegrationFolder -Recurse | Where-Object {$_.GetType().Name -eq "FileInfo"} ;
    foreach ($file in $files) 
    {
        # If an executable by name Integrator.exe is found check if this in an Office Package
        if ($file.Name -eq "Integrator.exe")
        {   
            # integrator.exe found. Check if this folder indeed contains Office package
            if (IsOfficePackage($file))
            {
                # Found Office package. Extract the Package GUID, Package Root Directory, 
                # and full path to "integrator.exe"
                $integratorFileFullName = $file.FullName
                $scriptDirectory = $file.DirectoryName
                $packageDirectory = Split-Path -parent $scriptDirectory 
                $rootDirectory = $packageDirectory + '\Root'

                $folderArray = $packageDirectory.split('\')
                if ($folderArray.Length -gt 0)
                {
                    $packageGuid = $folderArray[$folderArray.Length - 1]

                    $integratorArguments = GetIntegratorArgumentsFromAppxManifest($packageDirectory)
                    if ($integratorArguments -ne $null)
                   {
                        $integratorArguments = $integratorArguments.Replace("[{AppVPackageRoot}]", $rootDirectory)

                        # Now have all the data to execute integrator.exe to migrate the license. Execute the program now.
                        $integratorProcess = Start-Process $integratorFileFullName $integratorArguments -Passthru -Wait
                        if ($integratorProcess.ExitCode -eq 0)
                        {
                            $migrationSuccessful = $true
                        }
                        else
                        {
                            $migrationSuccessful = $false
                        }
                   }
                } 

                break
            }
        }
    }

    popd

    return $migrationSuccessful
}

Function GetAppVIntegrationFolder()
{
    $integrationGlobal = (Get-AppvClientConfiguration | ?{$_.Name -eq 'IntegrationRootGlobal'}).Value
    if ($integrationGlobal -ne $null)
    {
        return [System.Environment]::ExpandEnvironmentVariables($integrationGlobal)
    }

    return $null
}

# Script execution starts here
$appVIntegrationFolder = GetAppVIntegrationFolder
if ($appVIntegrationFolder -ne $null)
{    
    # First execute the Office Integrator to migrate the license
    if (ExecuteOfficeIntegrator($appVIntegrationFolder))
    {
        # Now disable the scheduled task since it needs to be run only once
        DisableScheduledTask
    }
}





