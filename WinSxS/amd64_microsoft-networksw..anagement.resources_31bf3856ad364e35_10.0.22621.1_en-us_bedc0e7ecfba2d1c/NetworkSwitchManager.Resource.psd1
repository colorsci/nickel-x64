# Localized	05/07/2022 03:27 AM (GMT)	303:7.0.30723 	NetworkSwitchManager.Resource.psd1
#################################################################
#                                                               #
#   Module Name: NetworkSwitchManager.Resources.psd1            #
#                                                               #
#   Description: Network switch manager localized strings       #
#                                                               #
#   Copyright (c) Microsoft Corporation. All rights reserved.   #
#                                                               #
#################################################################

ConvertFrom-StringData @'
###PSLOC
ErrorMessageNoTarget={0} encountered an error. Ensure that you are using a valid CIM session and that the Ethernet Switch Profile is correctly registered. If you are passing input objects, ensure these are valid instances of the appropriate type. See the Exception member of this error record for more details on the underlying issue.
ErrorMessageTarget={0} encountered an error while processing {1}. Ensure that you are using a valid CIM session and that the Ethernet Switch Profile is correctly registered. If you are passing input objects, ensure these are valid instances of the appropriate type. See the Exception member of this error record for more details on the underlying issue.
WarningMessageNoTarget={0} encountered a warning: {1}.
WarningMessageTarget={0} encountered a warning while processing {1}: {2}.
UnknownError=An unknown error has occurred - error code {0}.
NoValidAssociatedSwitch=The registered Ethernet Switch Profile is not associated with a conforming switch. Please register your switch as conforming to the Ethernet Switch Profile.
NoValidAssociatedNamespace=The switch registered as conforming to the Ethernet Switch Profile is not associated with a valid namespace. Please verify your switch implementation and registration.
NoValidRegisteredProfile=The Ethernet Switch Profile was not registered in root/interop, interop, /root/interop or /interop. Please register the Ethernet Switch Profile in one of these namespaces.
NoMatchingInstance=Did not find any instances matching search criteria: {0} = {1}.
###PSLOC
'@
