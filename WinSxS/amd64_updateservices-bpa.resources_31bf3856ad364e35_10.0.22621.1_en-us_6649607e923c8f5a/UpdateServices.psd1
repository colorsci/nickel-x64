# Localized	05/07/2022 03:34 AM (GMT)	303:7.0.30723 	UpdateServices.psd1
# Localized	03/24/2010 06:35 PM (GMT)	303:4.80.0411 	WSUS_model.psd1
# Localized	04/07/2009 09:40 AM (GMT)	303:4.80.0411 	WSUS_Model.psd1
# Localized	11/10/2008 10:09 AM (GMT)	303:4.80.0411 	WSUS_Model.psd1
# Localized	11/04/2008 10:15 AM (GMT)	303:4.80.0411 	WSUS_Model.psd1
# 
# Only add new (name,value) pairs to the end of this table
# Do not remove, insert or re-arrange entries
#

ConvertFrom-StringData @'
       
###PSLOC start localizing

    #
	# WSUS Role is installed
	#
WsusNotInstalled_Title=The Windows Server Update Services Role should be installed
WsusNotInstalled_Problem=The Windows Server Update Services Role is not installed.
WsusNotInstalled_Impact=The WSUS Best Practices Analyzer scan will not run unless the WSUS Role is installed on the machine.
WsusNotInstalled_Resolution=Install the WSUS Role through Server Manager.
WsusNotInstalled_Compliant=The WSUS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

    #
	# Self update tree must be correctly installed
	#
SelfUpdateTreeCheck_Title=The SelfUpdate folder should be correctly installed on the default Web site or the WSUS Administration site
SelfUpdateTreeCheck_Problem=WSUS service might not be installed or the SelfUpdate folder is missing or incorrectly installed on the default Web site or the WSUS Administration site.
SelfUpdateTreeCheck_Impact=Windows Update Agents will fail to verify the required version of the installed agent, which is required to communicate with the server. This will prevent Windows Update Agents from scanning for new updates or reporting their current status to the server.
SelfUpdateTreeCheck_Resolution=If WSUS service is installed, create a SelfUpdate folder on the default Web site or the WSUS Administration site.
SelfUpdateTreeCheck_Compliant=The WSUS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# Products/Languages selected
	#
ProductLanguageCheck_Title=Only required languages should be selected in the WSUS Configuration Wizard
ProductLanguageCheck_Problem=WSUS service might not be installed or multiple update languages are selected in the Configuration Wizard.
ProductLanguageCheck_Impact=If all or multiple languages are selected, a large portion of disk space will be used. This option could easily fill the content drive's capacity.
ProductLanguageCheck_Resolution=If WSUS service is installed, select only required languages.
ProductLanguageCheck_Compliant=The WSUS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
		
	#
	# Wsus should not be running on domain controller
	#
DomainControllerCheck_Title=WSUS should be installed on a non-domain controller
DomainControllerCheck_Problem=WSUS might not be installed or it may be installed on a domain controller.
DomainControllerCheck_Impact=If WSUS is installed a domain controller, this may cause database access issues due to how the database is configured. Installing WSUS on a domain controller can also cause problems upgrading or installing WSUS in the future.
DomainControllerCheck_Resolution=If WSUS is installed, uninstall it from the domain controller, demote the server to a non-domain controller and reinstall WSUS. Another alternative is to install WSUS on a different non-domain controller server.
DomainControllerCheck_Compliant=The WSUS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# WSUS content installed on system drive
	#
ContentSystemDriveCheck_Title=WSUS content should be installed on a non-system drive
ContentSystemDriveCheck_Problem=WSUS service might not be installed or WSUS content is installed on the system drive.
ContentSystemDriveCheck_Impact=Installing WSUS content in the system drive can lead to corruption of the operating system and denial of service for any other service if the system drive runs out of disk space.
ContentSystemDriveCheck_Resolution=If WSUS service is installed, move content to another drive to prevent WSUS content from consuming all disk space on the system drive.
ContentSystemDriveCheck_Compliant=The WSUS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

	#
	# WSUS database data and log files should not be located on system drive
	#
DatabaseSystemDriveCheck_Title=WSUS database should be installed on a non-system drive
DatabaseSystemDriveCheck_Problem=WSUS database might not be installed or it may be installed on the system drive.
DatabaseSystemDriveCheck_Impact=Installing WSUS database in the system drive can lead to corruption of the operating system and denial of service for any other service if the system drive runs out of disk space.
DatabaseSystemDriveCheck_Resolution=If WSUS database is installed, move the WSUS database (SUSDB) to a non-system drive.
DatabaseSystemDriveCheck_Compliant=The WSUS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
###PSLOC
'@
