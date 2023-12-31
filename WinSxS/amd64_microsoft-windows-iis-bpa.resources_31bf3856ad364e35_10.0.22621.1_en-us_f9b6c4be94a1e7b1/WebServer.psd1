# Localized	05/07/2022 03:33 AM (GMT)	303:7.0.30723 	WebServer.psd1
# Localized	11/10/2008 10:09 AM (GMT)	303:4.80.0411 	WebServer_Model.psd1
# Localized	11/04/2008 10:15 AM (GMT)	303:4.80.0411 	WebServer_Model.psd1
# 
# Only add new (name,value) pairs to the end of this table
# Do not remove, insert or re-arrange entries
#

ConvertFrom-StringData @'
       
###PSLOC start localizing
    #
	# Execute/Script and Write for handler
	#
ExecuteWritePermissionsCheck_Title=Grant a handler execute/script or write permissions, but not both
ExecuteWritePermissionsCheck_Problem=The attribute 'accessPolicy' in the handlers section under path '{0}' is set to allow both Execute/Script and Write permissions.
ExecuteWritePermissionsCheck_Impact=By allowing both Execute/Script and Write permissions, a handler can run malicious code on the target server.
ExecuteWritePermissionsCheck_Resolution=Determine if the handler requires both Execute/Script and Write permissions, and revoke the one that is not needed.
ExecuteWritePermissionsCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# Expired Certificates
	#
ExpiredCertificatesCheck_Title=Make sure that your certificates are current
ExpiredCertificatesCheck_Problem=SSL Binding '{0}:{1}:' has a certificate that has expired, or will expire in 30 days. The certificate has thumbprint '{2}' and is located in store '{3}'.
ExpiredCertificatesCheck_Impact=An expired certificate becomes invalid and can prevent users from accessing your site.
ExpiredCertificatesCheck_Resolution=Renew the certificate or choose a new certificate for the site.
ExpiredCertificatesCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# notListedIsapisAllowed should not be true
	#
NotListedISAPIsAllowedCheck_Title=The configuration attribute 'notListedIsapisAllowed' should be false
NotListedISAPIsAllowedCheck_Problem=The configuration attribute 'notListedIsapisAllowed' in section 'system.webServer/security/isapiCgiRestriction' is set to true.
NotListedISAPIsAllowedCheck_Impact=Any unlisted ISAPI extension, including potentially malicious extensions, will be allowed to run.
NotListedISAPIsAllowedCheck_Resolution=Set 'notListedIsapisAllowed' to false and add each ISAPI extension to the list of allowed extensions.
NotListedISAPIsAllowedCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# notListedCgisAllowed should not be true
	#
NotListedCGIsAllowedCheck_Title=The configuration attribute 'notListedCgisAllowed' should be false
NotListedCGIsAllowedCheck_Problem=The configuration attribute 'notListedCgisAllowed' in section 'system.webServer/security/isapiCgiRestriction' is set to true.
NotListedCGIsAllowedCheck_Impact=Any unlisted CGI extension, including potentially malicious extensions, will be allowed to run.
NotListedCGIsAllowedCheck_Resolution=Set 'notListedCgisAllowed' to false and add each CGI extension to the allowed list.
NotListedCGIsAllowedCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# Application Pool should not be priviliged
	#
AppPoolIdentityCheck_Title=Application pools should be set to run as application pool identities
AppPoolIdentityCheck_Problem=Application pool '{0}' is set to run as an administrator, as local system, or to 'Act as part of the operating system'.
AppPoolIdentityCheck_Impact=The application pool can execute high-privileged code, including potentially malicious code that can negatively affect your server.
AppPoolIdentityCheck_Resolution=Set the application pool to run as the application pool identity.
AppPoolIdentityCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

	#
	# Custom errors should be set to LocalOnly or Custom
	#
CustomErrorsCheck_Title=Hide Custom Errors from displaying remotely
CustomErrorsCheck_Problem=The errorMode attribute of section '{0}' [path:{1}] is set to Detailed.
CustomErrorsCheck_Impact=Users browsing to your site or application could see some privileged information that is contained in the detailed error pages being sent remotely.
CustomErrorsCheck_Resolution=Set the Custom Errors 'errorMode' to 'DetailedLocalOnly' or 'Custom'.
CustomErrorsCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.
	
	#
	# Basic Authentication should not be used without SSL
	#
BasicAuthSSLCheck_Title=Use SSL when you use Basic authentication
BasicAuthSSLCheck_Problem=Basic authentication is enabled for configuration path '{0}' but it lacks a required SSL binding.
BasicAuthSSLCheck_Impact=If you use Basic authentication without SSL, credentials will be sent in clear text that might be intercepted by malicious code.
BasicAuthSSLCheck_Resolution=Use Basic authentication with an SSL binding, and make sure that the site or application is set to require SSL. Alternatively, use a different method of authentication.
BasicAuthSSLCheck_Compliant=The IIS Best Practices Analyzer scan has determined that you are in compliance with this best practice.

###PSLOC
'@
