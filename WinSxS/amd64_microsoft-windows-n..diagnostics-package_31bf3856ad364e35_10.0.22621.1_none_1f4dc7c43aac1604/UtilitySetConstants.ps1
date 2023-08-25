# Copyright © 2008, Microsoft Corporation. All rights reserved.

function DefineConstant($curVal, $name, $value)
{
    if($curVal -eq $null)
    {
        set-variable -name $name -value $value -option constant -scope Global
    }
}

DefineConstant $DiagnoseWaitTime "DiagnoseWaitTime" 90000
DefineConstant $RepairWaitTime "RepairWaitTime" 90000
DefineConstant $ValidateWaitTime "ValidateWaitTime" 90000
DefineConstant $ProgressUpdateDelay "ProgressUpdateDelay" 1000
DefineConstant $WinBuiltinAdministratorsSid "WinBuiltinAdministratorsSid" 26
DefineConstant $WinBuiltinNetworkConfigurationOperatorsSid "WinBuiltinNetworkConfigurationOperatorsSid" 37
DefineConstant $WinLocalLogonSid "WinLocalLogonSid" 80
DefineConstant $GuidLength "GuidLength" 38
DefineConstant $DefaultDiagURL "DefaultDiagURL" ""
DefineConstant $S_OK "S_OK" 0
DefineConstant $S_FALSE "S_FALSE" 1
DefineConstant $RF_USER_ACTION "RF_USER_ACTION" 0x10000000
DefineConstant $RF_INFORMATION_ONLY "RF_INFORMATION_ONLY"  0x2000000
DefineConstant $RF_USER_CONFIRMATION "RF_USER_CONFIRMATION" 0x8000000
DefineConstant $RF_VALIDATE_HELPTOPIC "RF_VALIDATE_HELPTOPIC" 0x400000
DefineConstant $RF_CONTACT_ADMIN "RF_CONTACT_ADMIN" 0x20000
DefineConstant $RF_RESERVED_CA "RF_RESERVED_CA" 0x80000000
DefineConstant $RCF_ISCONFIRMED "RCF_ISCONFIRMED" 0x2
DefineConstant $RCF_ISTHIRDPARTY  "RCF_ISTHIRDPARTY" 0x4
DefineConstant $UIT_HELP_PANE "UIT_HELP_PANE" 3
DefineConstant $NDF_STOP_STATUS_FAILEDVALIDATE "NDF_STOP_STATUS_FAILEDVALIDATE" 2
DefineConstant $NDF_STOP_STATUS_SUCCESSVALIDATE "NDF_STOP_STATUS_SUCCESSVALIDATE" 5
DefineConstant $NDF_STOP_STATUS_FAILEDREPAIR "NDF_STOP_STATUS_FAILEDREPAIR" 1
DefineConstant $NDF_STOP_STATUS_SUCCESSDIAG "NDF_STOP_STATUS_SUCCESSDIAG" 3
DefineConstant $NDF_SKIPREASON_NONE "NDF_SKIPREASON_NONE" 0
DefineConstant $NDF_SKIPREASON_ADAPTER "NDF_SKIPREASON_ADAPTER" 1
DefineConstant $NDF_SKIPREASON_DUPLICATE "NDF_SKIPREASON_DUPLICATE" 2
DefineConstant $ERROR_MSG_RTF_RESOURCE "ERROR_MSG_RTF_RESOURCE" "@DiagPackage.dll,-10103"
DefineConstant $INBOUND_FILESHARE_RESOURCE "INBOUND_FILESHARE_RESOURCE" "@DiagPackage.dll,-10012"
DefineConstant $INBOUND_FILESHARE_PARAM "INBOUND_FILESHARE_PARAM" "@FirewallAPI.dll,-28502"
DefineConstant $INBOUND_REMOTEDESKTOP_RESOURCE "INBOUND_REMOTEDESKTOP_RESOURCE" "@DiagPackage.dll,-10013"
DefineConstant $INBOUND_REMOTEDESKTOP_PARAM "INBOUND_REMOTEDESKTOP_PARAM" "@FirewallAPI.dll,-28752"
DefineConstant $INBOUND_DISCOVERY_RESOURCE "INBOUND_DISCOVERY_RESOURCE" "@DiagPackage.dll,-10014"
DefineConstant $INBOUND_DISCOVERY_PARAM "INBOUND_DISCOVERY_PARAM" "@FirewallAPI.dll,-32752"
DefineConstant $INBOUND_OTHER_RESOURCE "INBOUND_OTHER_RESOURCE" "@DiagPackage.dll,-10011"
DefineConstant $FM_ENABLED "FM_ENABLED" 0
DefineConstant $FM_DISABLED "FM_DISABLED" 1
DefineConstant $FM_CATCHALL "FM_CATCHALL" 2
DefineConstant $FV_NOTFILTERED "FV_NOTFILTERED" 0
DefineConstant $FV_FILTERED "FV_FILTERED" 1
DefineConstant $FV_MISSING "FV_MISSING" -1