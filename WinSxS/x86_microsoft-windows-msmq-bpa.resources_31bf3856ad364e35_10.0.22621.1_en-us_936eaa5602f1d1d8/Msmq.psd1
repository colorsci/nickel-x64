# Localized	05/07/2022 02:21 AM (GMT)	303:7.0.30723 	MsmqBpa.psd1
# 
# Only add new (name,value) pairs to the end of this table
# Do not remove, insert or re-arrange entries
#

ConvertFrom-StringData @'

###PSLOC start localizing
    #
    # Install on non-DC servers
    #
InstallOnNonDC_Title=MSMQ should be installed on a non-domain controller.
InstallOnNonDC_Problem=MSMQ is installed on a domain controller.
InstallOnNonDC_Impact=Under heavy load, normal domain operations may be affected.
InstallOnNonDC_Resolution=Install MSMQ on a non-domain controller.
InstallOnNonDC_Compliant=The MSMQ Best Practices Analyzer scan has determined that you are in compliance with this best practice.

###PSLOC
'@
