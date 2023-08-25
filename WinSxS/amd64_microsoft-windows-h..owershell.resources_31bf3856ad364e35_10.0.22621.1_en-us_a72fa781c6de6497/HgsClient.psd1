# Localized	05/07/2022 03:33 AM (GMT)	303:7.0.30723 	HgsClient.psd1
#/*++
#
#    Copyright (c) Microsoft Corporation.  All rights reserved.
#
#    Abstract:
#
#        String table for the Host Guardian Client (HGS) PowerShell
#
#--*/

#
# Data table for the format strings
#
ConvertFrom-StringData @"
    ###PSLOC - Localizable string
ErrorSetHostKeyAlreadySet=A host key has already been set. To specify a new one, first run Remove-HgsClientHostKey.
ErrorSetHostKeyMissingPrivateKey=A certificate with thumbprint {0} was found, but its private key was not usable.
ErrorSetHostKeyThumbprintInvalid=A certificate with thumbprint {0} could not be found.
ErrorGetHostKeyNotSet=A host key has not been set. To set a host key, use Set-HgsClientHostKey.
ErrorGetHostKeyNotFound=Cannot find the host key certificate with thumbprint '{0}'. Reinstall the certificate in LocalMachine\\My or use Remove-HgsClientHostKey and Set-HgsClientHostKey to configure a new host key.
WarningRemoveHostKeyProvided=The certificate with thumbprint {0} was not removed because it was not generated by Set-HgsClientHostKey.
    ###PSLOC - End of localizable string
"@
