# Copyright (c) 2017 Microsoft Corporation. All rights reserved.
#
# This script is used to automatically removes support for the legacy SMB 1.0/CIFS protocol when such support isn�t actively needed during normal system usage..
Param
(
    [Parameter(Mandatory=$True)]
    [ValidateSet("Client", "Server")]
    [string]
    $Scenario
)

#
# ------------------
# FUNCTIONS - START
# ------------------
#
Function UninstallSmb1 ($FeatureNames)
{
  try
    {
       Remove-SMBComponent -Name $FeatureNames
    }
    catch {}
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

$ScenarioData = @{
    "Client" = @{
        "FeatureName" = "SMB1Protocol-Client";
        "ServiceName" = "LanmanWorkstation"
    };
    "Server" = @{
        "FeatureName" = "SMB1Protocol-Server";
        "ServiceName" = "LanmanServer"
    }
}

$FeaturesToRemove = @()

foreach ($key in $ScenarioData.Keys)
{
    $FeatureName = $ScenarioData[$key].FeatureName
    $ServiceName = $ScenarioData[$key].ServiceName

    $ScenarioData[$key].FeatureState = (Get-WindowsOptionalFeature -Online -FeatureName $FeatureName).State
    $ScenarioData[$key].ServiceParameters = Get-ItemProperty "HKLM:\System\CurrentControlSet\Services\${ServiceName}\Parameters"
}

$FeaturesToRemove += $ScenarioData[$Scenario].FeatureName

$RemoveOtherFeatures = $true

foreach ($key in $ScenarioData.Keys)
{
    if($key -ne $Scenario)
    {
      if($ScenarioData[$key].ServiceParameters.AuditSmb1Access -ne 0) {
        $RemoveOtherFeatures = $false
      }
    }
}

if ($RemoveOtherFeatures) {
    $FeaturesToRemove += "SMB1Protocol-Deprecation"
    $FeaturesToRemove += "SMB1Protocol"
}

UninstallSmb1 -FeatureName $FeaturesToRemove

$ServiceName = $ScenarioData[$Scenario].ServiceName
$RegistryPath = "HKLM:\System\CurrentControlSet\Services\${ServiceName}\Parameters"
New-ItemProperty -Path $RegistryPath -Name AuditSmb1Access -Value 0 -PropertyType DWORD -Force | Out-Null
