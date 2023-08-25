# Copyright © 2018, Microsoft Corporation. All rights reserved.

#*=================================================================================
# Parameters
#*=================================================================================

#*=================================================================================
# Load Utilities
#*=================================================================================
. ./utils_SetupEnv.ps1

#*=================================================================================
# Initialize 
#*=================================================================================
Import-LocalizedData -BindingVariable Strings_Main -FileName CL_LocalizationData  

#*=================================================================================
# Run resolver logic
#*=================================================================================

$path = "registry::HKEY_LOCAL_MACHINE\software\microsoft\windows\currentversion\audio"
Remove-ItemProperty -Path $path -Name "DisableprotectedaudioDG" -Force -ErrorAction SilentlyContinue
net stop audiosrv /y
net start audiosrv
