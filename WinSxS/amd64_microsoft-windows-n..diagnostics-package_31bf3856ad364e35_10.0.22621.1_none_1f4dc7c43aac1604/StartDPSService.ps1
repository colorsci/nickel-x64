# Copyright © 2008, Microsoft Corporation. All rights reserved.

PARAM($SetAuto)

#include localization data
Import-LocalizedData -BindingVariable localizationString -FileName LocalizationData

if($SetAuto)
{
    #make DPS automatic
    Write-DiagProgress -activity $localizationString.progress_Repairing -status $localizationString.repair_SetAutoDPS
    set-service dps -StartupType Automatic
}

#start the DPS service
Write-DiagProgress -activity $localizationString.progress_Repairing -status $localizationString.repair_StartDPS
start-service dps
