<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

    <ns prefix="tns" uri="http://schemas.microsoft.com/bestpractices/models/ServerManager/DHCP/DHCPServer/2008/12" />	

    <ns prefix="mssmltrans" uri="http://schemas.microsoft.com/sml/functions/transform/2007/03" />
    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:Bindings">
	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:V4Binding = 'true' or tns:V6Binding = 'true'">
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157517</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "BindingExists_title"/>
		<mssmlbpa:problem mssml:locid = "BindingExists_problem"/>
		<mssmlbpa:impact mssml:locid = "BindingExists_impact"/>
		<mssmlbpa:resolution mssml:locid = "BindingExists_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:V4Binding = 'true' or tns:V6Binding = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157517</mssmlbpa:helpTopic>>
		<mssmlbpa:title mssml:locid = "BindingExists_title"/>
		<mssmlbpa:compliant mssml:locid = "BindingExists_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V4ScopeExists = 'true']">
	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Bindings/tns:V4Binding = 'true'">
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157519</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "BindingExistsV4_title"/>
		<mssmlbpa:problem mssml:locid = "BindingExistsV4_problem"/>
		<mssmlbpa:impact mssml:locid = "BindingExistsV4_impact"/>
		<mssmlbpa:resolution mssml:locid = "BindingExistsV4_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Bindings/tns:V4Binding = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157519</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "BindingExistsV4_title"/>
		<mssmlbpa:compliant mssml:locid = "BindingExistsV4_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V6ScopeExists = 'true' or tns:V6OptionExists = 'true']">
	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Bindings/tns:V6Binding = 'true'">
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157520</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "BindingExistsV6_title"/>
		<mssmlbpa:problem mssml:locid = "BindingExistsV6_problem"/>
		<mssmlbpa:impact mssml:locid = "BindingExistsV6_impact"/>
		<mssmlbpa:resolution mssml:locid = "BindingExistsV6_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Bindings/tns:V6Binding = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157520</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "BindingExistsV6_title"/>
		<mssmlbpa:compliant mssml:locid = "BindingExistsV6_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:DhcpRegistryPathHasPerm">
	    <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = ". = 'true'">
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157521</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RegistryPermissions_title"/>
		<mssmlbpa:problem mssml:locid = "RegistryPermissions_problem"/>
		<mssmlbpa:impact mssml:locid = "RegistryPermissions_impact"/>
		<mssmlbpa:resolution mssml:locid = "RegistryPermissions_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = ". = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157521</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RegistryPermissions_title"/>
		<mssmlbpa:compliant mssml:locid = "RegistryPermissions_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DhcpDatabasePath">
	    <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "count(tns:Path) = 1 and tns:HasPermissions = 'true'">
		<value-of select="tns:Path"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157522</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DatabasePermissions_title"/>
		<mssmlbpa:problem mssml:locid = "DatabasePermissions_problem"/>
		<mssmlbpa:impact mssml:locid = "DatabasePermissions_impact"/>
		<mssmlbpa:resolution mssml:locid = "DatabasePermissions_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "count(tns:Path) = 1 and tns:HasPermissions = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157522</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DatabasePermissions_title"/>
		<mssmlbpa:compliant mssml:locid = "DatabasePermissions_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DhcpDatabaseBackupPath">
	    <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "count(tns:Path) = 1 and tns:HasPermissions = 'true'">
		<value-of select="tns:Path"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157523</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DatabaseBackupPermissions_title"/>
		<mssmlbpa:problem mssml:locid = "DatabaseBackupPermissions_problem"/>
		<mssmlbpa:impact mssml:locid = "DatabaseBackupPermissions_impact"/>
		<mssmlbpa:resolution mssml:locid = "DatabaseBackupPermissions_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "count(tns:Path) = 1 and tns:HasPermissions = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157523</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DatabaseBackupPermissions_title"/>
		<mssmlbpa:compliant mssml:locid = "DatabaseBackupPermissions_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DhcpAuditlogPath">
	    <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "count(tns:Path) = 1 and tns:HasPermissions = 'true'">
		<value-of select="tns:Path"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157524</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AuditlogPermissions_title"/>
		<mssmlbpa:problem mssml:locid = "AuditlogPermissions_problem"/>
		<mssmlbpa:impact mssml:locid = "AuditlogPermissions_impact"/>
		<mssmlbpa:resolution mssml:locid = "AuditlogPermissions_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "count(tns:Path) = 1 and tns:HasPermissions = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157524</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AuditlogPermissions_title"/>
		<mssmlbpa:compliant mssml:locid = "AuditlogPermissions_compliant"/>              
	    </report>       
        </rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:DhcpDatabaseStatus">                       
            <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:operation mssmlbpa:markupv2"
		test = ". = 0 " >
                <value-of select="."/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157525</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "Database_title"/>
		<mssmlbpa:problem mssml:locid = "Database_problem"/>
		<mssmlbpa:impact mssml:locid = "Database_impact"/>
		<mssmlbpa:resolution mssml:locid = "Database_resolution"/>                
	    </assert>        	       
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:operation mssmlbpa:markupv2"
		test = ". = 0 " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157525</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "Database_title"/>
		<mssmlbpa:compliant mssml:locid = "Database_compliant"/>              
	    </report>  
  	</rule>
    </pattern>   

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration">
	    <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:RogueDetectionEnabled = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157526</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RogueDetection_title"/>
		<mssmlbpa:problem mssml:locid = "RogueDetection_problem"/>
		<mssmlbpa:impact mssml:locid = "RogueDetection_impact"/>
		<mssmlbpa:resolution mssml:locid = "RogueDetection_resolution"/>                
  	    </assert>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:RogueDetectionEnabled = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157526</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RogueDetection_title"/>
		<mssmlbpa:compliant mssml:locid = "RogueDetection_compliant"/>              
	    </report>          
 	</rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DhcpServerADAuthorization">
	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157527</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ADAuthExists_title"/>
		<mssmlbpa:problem mssml:locid = "ADAuthExists_problem"/>
		<mssmlbpa:impact mssml:locid = "ADAuthExists_impact"/>
		<mssmlbpa:resolution mssml:locid = "ADAuthExists_resolution"/>                
  	    </assert>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157527</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ADAuthExists_title"/>
		<mssmlbpa:compliant mssml:locid = "ADAuthExists_compliant"/>              
	    </report>          
 	</rule>
    </pattern>

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:RogueDetectionEnabled = 'true' and tns:DhcpDomainJoined = 'false']/tns:RogueDetection[tns:Number > 0]/tns:OpenedPort">    
            <report				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = " ../tns:Protocol = 'IPV4' ">
                <value-of select="tns:PID" />  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157530</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RogueDetectionV4_title"/>
		<mssmlbpa:problem mssml:locid = "RogueDetectionV4_problem"/>
		<mssmlbpa:impact mssml:locid = "RogueDetectionV4_impact"/>
		<mssmlbpa:resolution mssml:locid = "RogueDetectionV4_resolution"/>                
 	    </report>
    	    <report			
		mssml:severity = "error"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = " ../tns:Protocol = 'IPV6' " >
                <value-of select="tns:PID" />  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157531</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RogueDetectionV6_title"/>
		<mssmlbpa:problem mssml:locid = "RogueDetectionV6_problem"/>
		<mssmlbpa:impact mssml:locid = "RogueDetectionV6_impact"/>
		<mssmlbpa:resolution mssml:locid = "RogueDetectionV6_resolution"/>             
	    </report>                   
  	</rule>
    </pattern>

    <pattern> 
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:RogueDetectionEnabled = 'true' and tns:DhcpDomainJoined = 'false']/tns:RogueDetection[tns:Number='0']">    
	    <report				
		mssml:severity = "info"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Protocol = 'IPV4' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157530</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RogueDetectionV4_title"/>
		<mssmlbpa:compliant mssml:locid = "RogueDetectionV4_compliant"/>                
	    </report>
    	    <report				
		mssml:severity = "info"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Protocol = 'IPV6' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157531</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "RogueDetectionV6_title"/>
		<mssmlbpa:compliant mssml:locid = "RogueDetectionV6_compliant"/>                
 	    </report>
        </rule>             
    </pattern>     

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:OpenedPorts[tns:Number>0]/tns:OpenedPort">    
	    <report			
		mssml:severity = "error"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "../tns:Protocol = 'IPV4' " >
                <value-of select="tns:PID" />  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157528</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "OpenedPortsV4_title"/>
		<mssmlbpa:problem mssml:locid = "OpenedPortsV4_problem"/>
		<mssmlbpa:impact mssml:locid = "OpenedPortsV4_impact"/>
		<mssmlbpa:resolution mssml:locid = "OpenedPortsV4_resolution"/>                
 	    </report>
	    <report				
		mssml:severity = "error"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "../tns:Protocol = 'IPV6' " >
                <value-of select="tns:PID" />  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157529</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "OpenedPortsV6_title"/>
		<mssmlbpa:problem mssml:locid = "OpenedPortsV6_problem"/>
		<mssmlbpa:impact mssml:locid = "OpenedPortsV6_impact"/>
		<mssmlbpa:resolution mssml:locid = "OpenedPortsV6_resolution"/>             
	    </report>                   
	</rule>
    </pattern>

    <pattern> 
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:OpenedPorts[tns:Number=0]">    
	    <report				
		mssml:severity = "info"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Protocol = 'IPV4' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157528</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "OpenedPortsV4_title"/>
		<mssmlbpa:compliant mssml:locid = "OpenedPortsV4_compliant"/>                
 	    </report>
   	    <report				
		mssml:severity = "info"
		mssml:category = "mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:Protocol = 'IPV6' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157529</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "OpenedPortsV6_title"/>
		<mssmlbpa:compliant mssml:locid = "OpenedPortsV6_compliant"/>                
 	    </report>
        </rule>             
    </pattern>      

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:Bindings/tns:V4Binding = 'true']">    
 	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:V4ScopeExists = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157532</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ScopesV4_title"/>
		<mssmlbpa:problem mssml:locid = "ScopesV4_problem"/>
		<mssmlbpa:impact mssml:locid = "ScopesV4_impact"/>
		<mssmlbpa:resolution mssml:locid = "ScopesV4_resolution"/>                
	    </assert>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:V4ScopeExists = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157532</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ScopesV4_title"/>
		<mssmlbpa:compliant mssml:locid = "ScopesV4_compliant"/>              
	    </report>                   
  	</rule>
    </pattern>   
    
    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:Bindings/tns:V6Binding = 'true']">    
 	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:V6ScopeExists = 'true' or tns:V6OptionExists = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157533</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ScopesV6_title"/>
		<mssmlbpa:problem mssml:locid = "ScopesV6_problem"/>
		<mssmlbpa:impact mssml:locid = "ScopesV6_impact"/>
		<mssmlbpa:resolution mssml:locid = "ScopesV6_resolution"/>                
	    </assert>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:V6ScopeExists = 'true' or tns:V6OptionExists = 'true'" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157533</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ScopesV6_title"/>
		<mssmlbpa:compliant mssml:locid = "ScopesV6_compliant"/>              
	    </report>                   
  	</rule>
    </pattern>   

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V4ScopeExists = 'true']">    
 	    <report				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:ScopesWithoutIpRange) = 1" >
		<value-of select="tns:ScopesWithoutIpRange"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157534</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "IpRangeExists_title"/>
		<mssmlbpa:problem mssml:locid = "IpRangeExists_problem"/>
		<mssmlbpa:impact mssml:locid = "IpRangeExists_impact"/>
		<mssmlbpa:resolution mssml:locid = "IpRangeExists_resolution"/>                
	    </report>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:ScopesWithoutIpRange) = 0" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157534</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "IpRangeExists_title"/>
		<mssmlbpa:compliant mssml:locid = "IpRangeExists_compliant"/>              
	    </report>                   
  	</rule>
    </pattern>   
    
    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:ScopesDeactivated">    
	    <report				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 1 " >
                <value-of select="tns:Protocol" />
                <value-of select="tns:Scopes" />                   
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157535</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ScopesDeactivated_title"/>
		<mssmlbpa:problem mssml:locid = "ScopesDeactivated_problem"/>
		<mssmlbpa:impact mssml:locid = "ScopesDeactivated_impact"/>
		<mssmlbpa:resolution mssml:locid = "ScopesDeactivated_resolution"/>                
 	    </report>
 	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 0 " >
                <value-of select="tns:Protocol" />                
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157535</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ScopesDeactivated_title"/>
		<mssmlbpa:compliant mssml:locid = "ScopesDeactivated_compliant"/>              
	    </report>                   
  	</rule>
    </pattern>  
    
    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:DuplicateAddressDetection > 0]">
            <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:DuplicateAddressDetection &lt; '4' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157536</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DAD_title"/>
		<mssmlbpa:problem mssml:locid = "DAD_problem"/>
		<mssmlbpa:impact mssml:locid = "DAD_impact"/>
		<mssmlbpa:resolution mssml:locid = "DAD_resolution"/>                
 	    </assert>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:DuplicateAddressDetection &lt; '4' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157536</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DAD_title"/>
		<mssmlbpa:compliant mssml:locid = "DAD_compliant"/>              
 	    </report>    
  	</rule>
    </pattern>
    
    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DhcpSecurityGroups">                       
            <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:security mssmlbpa:markupv2"
		test = ". = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157537</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DhcpSecurityGroups_title"/>
		<mssmlbpa:problem mssml:locid = "DhcpSecurityGroups_problem"/>
		<mssmlbpa:impact mssml:locid = "DhcpSecurityGroups_impact"/>
		<mssmlbpa:resolution mssml:locid = "DhcpSecurityGroups_resolution"/>                
	    </assert>        	       
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:security mssmlbpa:markupv2"
		test = ". = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157537</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DhcpSecurityGroups_title"/>
		<mssmlbpa:compliant mssml:locid = "DhcpSecurityGroups_compliant"/>              
	    </report>  
        </rule>
    </pattern>                                                                 
	
    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:Bindings/tns:V4Binding = 'true']">
	    <report				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:ServerIPV4Excl) = 1">
		<value-of select="tns:ServerIPV4Excl"/>  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157538</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ServerIPV4Excl_title"/>
		<mssmlbpa:problem mssml:locid = "ServerIPV4Excl_problem"/>
		<mssmlbpa:impact mssml:locid = "ServerIPV4Excl_impact"/>
		<mssmlbpa:resolution mssml:locid = "ServerIPV4Excl_resolution"/>                
 	    </report>
	    <report				
		mssml:severity = "info"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:ServerIPV4Excl) = 0" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157538</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ServerIPV4Excl_title"/>
		<mssmlbpa:compliant mssml:locid = "ServerIPV4Excl_compliant"/>               
 	    </report>
 	</rule>
    </pattern> 

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:Bindings/tns:V6Binding = 'true']">
	    <report				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:ServerIPV6Excl) = 1">
		<value-of select="tns:ServerIPV6Excl"/>  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157539</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ServerIPV6Excl_title"/>
		<mssmlbpa:problem mssml:locid = "ServerIPV6Excl_problem"/>
		<mssmlbpa:impact mssml:locid = "ServerIPV6Excl_impact"/>
		<mssmlbpa:resolution mssml:locid = "ServerIPV6Excl_resolution"/>                
 	    </report>
	    <report				
		mssml:severity = "info"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:ServerIPV6Excl) = 0" >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157539</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ServerIPV6Excl_title"/>
		<mssmlbpa:compliant mssml:locid = "ServerIPV6Excl_compliant"/>               
 	    </report>
 	</rule>
    </pattern> 

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:AuditLog">         
	    <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157540</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AuditLog_title"/>
		<mssmlbpa:problem mssml:locid = "AuditLog_problem"/>
		<mssmlbpa:impact mssml:locid = "AuditLog_impact"/>
		<mssmlbpa:resolution mssml:locid = "AuditLog_resolution"/>                
 	    </assert>
   	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157540</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AuditLog_title"/>
		<mssmlbpa:compliant mssml:locid = "AuditLog_compliant"/>              
	    </report> 
        </rule>
    </pattern>  

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:AllowList[tns:Status = 'true']">    
	    <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:List = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157541</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AllowList_title"/>
		<mssmlbpa:problem mssml:locid = "AllowList_problem"/>
		<mssmlbpa:impact mssml:locid = "AllowList_impact"/>
		<mssmlbpa:resolution mssml:locid = "AllowList_resolution"/>                
 	    </assert>
 	    <report			
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:List = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157541</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AllowList_title"/>
		<mssmlbpa:compliant mssml:locid = "AllowList_compliant"/>              
	    </report>                   
  	</rule>
    </pattern>   

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:AllowList[tns:Status = 'false']">    
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:List = 'true' or tns:List = 'false' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157541</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "AllowList_title"/>
		<mssmlbpa:compliant mssml:locid = "AllowList_compliant"/>              
	    </report>                   
  	</rule>
    </pattern>   

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V4ScopeExists = 'true']/tns:ConflictReservations">                       
            <assert				
		mssml:severity = "warning"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:Status = 'true' " >
                <value-of select="tns:Reservations"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157542</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ReservationConflict_title"/>
		<mssmlbpa:problem mssml:locid = "ReservationConflict_problem"/>
		<mssmlbpa:impact mssml:locid = "ReservationConflict_impact"/>
		<mssmlbpa:resolution mssml:locid = "ReservationConflict_resolution"/>                
 	    </assert>        	       
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "tns:Status = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157542</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "ReservationConflict_title"/>
		<mssmlbpa:compliant mssml:locid = "ReservationConflict_compliant"/>              
	    </report>  
        </rule>
    </pattern>   

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:IAS[tns:NAPState = 'true']">    
	    <assert				
	 	mssml:severity = "warning"
		mssml:category = "mssmlbpa:operation mssmlbpa:markupv2"
		test = "tns:NPSState = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157543</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "IAS_title"/>
		<mssmlbpa:problem mssml:locid = "IAS_problem"/>
		<mssmlbpa:impact mssml:locid = "IAS_impact"/>
		<mssmlbpa:resolution mssml:locid = "IAS_resolution"/>                
 	    </assert>
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:operation mssmlbpa:markupv2"
		test = "tns:NPSState = 'true' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157543</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "IAS_title"/>
		<mssmlbpa:compliant mssml:locid = "IAS_compliant"/>              
  	    </report>                   
 	</rule>
    </pattern>          

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V4ScopeExists = 'true']/tns:DefaultGateway">                       
            <report				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 1 " >
                <value-of select="tns:Scopes"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157544</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DefaultGateway_title"/>
		<mssmlbpa:problem mssml:locid = "DefaultGateway_problem"/>
		<mssmlbpa:impact mssml:locid = "DefaultGateway_impact"/>
		<mssmlbpa:resolution mssml:locid = "DefaultGateway_resolution"/>                
 	    </report>        	       
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 0 " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157544</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DefaultGateway_title"/>
		<mssmlbpa:compliant mssml:locid = "DefaultGateway_compliant"/>              
	    </report>  
  	</rule>
    </pattern>   

    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V4ScopeExists = 'true']">
            <assert		 			
                 mssml:severity = "warning"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = "count(tns:DnsV4DynamicUpdate) = 0 " >
                 <value-of select="tns:DnsV4DynamicUpdate"/> 
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157545</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "DnsV4DynUpdate_title"/>
		 <mssmlbpa:problem mssml:locid = "DnsV4DynUpdate_problem"/>
		 <mssmlbpa:impact mssml:locid = "DnsV4DynUpdate_impact"/>
		 <mssmlbpa:resolution mssml:locid = "DnsV4DynUpdate_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = "count(tns:DnsV4DynamicUpdate) = 0 " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157545</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "DnsV4DynUpdate_title"/>
		 <mssmlbpa:compliant mssml:locid = "DnsV4DynUpdate_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          

    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration[tns:V6ScopeExists = 'true']">
            <assert				
                 mssml:severity = "warning"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = "count(tns:DnsV6DynamicUpdate) = 0 " >
                 <value-of select="tns:DnsV6DynamicUpdate"/> 
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157546</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "DnsV6DynUpdate_title"/>
		 <mssmlbpa:problem mssml:locid = "DnsV6DynUpdate_problem"/>
		 <mssmlbpa:impact mssml:locid = "DnsV6DynUpdate_impact"/>
		 <mssmlbpa:resolution mssml:locid = "DnsV6DynUpdate_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		  test = "count(tns:DnsV6DynamicUpdate) = 0 " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157546</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "DnsV6DynUpdate_title"/>
		 <mssmlbpa:compliant mssml:locid = "DnsV6DynUpdate_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsServerOption[tns:Protocol = 'IPv4']">                       
            <report				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 1 " >
                <value-of select="tns:Scopes"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157547</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsServerV4_title"/>
		<mssmlbpa:problem mssml:locid = "DnsServerV4_problem"/>
		<mssmlbpa:impact mssml:locid = "DnsServerV4_impact"/>
		<mssmlbpa:resolution mssml:locid = "DnsServerV4_resolution"/>                
 	    </report>        	       
    	    <report			
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 0 " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157547</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsServerV4_title"/>
		<mssmlbpa:compliant mssml:locid = "DnsServerV4_compliant"/>              
	    </report>  
  	</rule>
    </pattern> 

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsServerOption[tns:Protocol = 'IPv6']">                       
            <report				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 1 " >
                <value-of select="tns:Scopes"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157548</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsServerV6_title"/>
		<mssmlbpa:problem mssml:locid = "DnsServerV6_problem"/>
		<mssmlbpa:impact mssml:locid = "DnsServerV6_impact"/>
		<mssmlbpa:resolution mssml:locid = "DnsServerV6_resolution"/>                
 	    </report>        	       
    	    <report			
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 0 " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157548</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsServerV6_title"/>
		<mssmlbpa:compliant mssml:locid = "DnsServerV6_compliant"/>              
	    </report>  
  	</rule>
    </pattern>                 

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:InvalidDnsIPV4Servers">                       
            <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = '' ">
                <value-of select="."/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157549</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsV4ServerValidation_title"/>
		<mssmlbpa:problem mssml:locid = "DnsV4ServerValidation_problem"/>
		<mssmlbpa:impact mssml:locid = "DnsV4ServerValidation_impact"/>
		<mssmlbpa:resolution mssml:locid = "DnsV4ServerValidation_resolution"/>                
   	    </assert>        	       
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = '' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157549</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsV4ServerValidation_title"/>
		<mssmlbpa:compliant mssml:locid = "DnsV4ServerValidation_compliant"/>              
	    </report>  
  	</rule>
    </pattern>             

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:InvalidDnsIPV6Servers">                       
            <assert				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = '' ">
                <value-of select="."/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157550</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsV6ServerValidation_title"/>
		<mssmlbpa:problem mssml:locid = "DnsV6ServerValidation_problem"/>
		<mssmlbpa:impact mssml:locid = "DnsV6ServerValidation_impact"/>
		<mssmlbpa:resolution mssml:locid = "DnsV6ServerValidation_resolution"/>                
   	    </assert>        	       
	    <report				
		mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = ". = '' " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157550</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsV6ServerValidation_title"/>
		<mssmlbpa:compliant mssml:locid = "DnsV6ServerValidation_compliant"/>              
	    </report>  
  	</rule>
    </pattern>             

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsDomainOption[tns:Protocol = 'IPv4']">                       
            <report				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 1 " >
                <value-of select="tns:Scopes"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157551</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsDomainOptionV4_title"/>
		<mssmlbpa:problem mssml:locid = "DnsDomainOptionV4_problem"/>
		<mssmlbpa:impact mssml:locid = "DnsDomainOptionV4_impact"/>
		<mssmlbpa:resolution mssml:locid = "DnsDomainOptionV4_resolution"/>                
 	    </report>        	       
	    <report				
	        mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 0 " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157551</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsDomainOptionV4_title"/>
		<mssmlbpa:compliant mssml:locid = "DnsDomainOptionV4_compliant"/>              
	    </report>  
  	</rule>
    </pattern> 

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsDomainOption[tns:Protocol = 'IPv6']">                       
            <report				
		mssml:severity = "error"
		mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 1 " >
                <value-of select="tns:Scopes"/>                                  
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157552</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsDomainOptionV6_title"/>
		<mssmlbpa:problem mssml:locid = "DnsDomainOptionV6_problem"/>
		<mssmlbpa:impact mssml:locid = "DnsDomainOptionV6_impact"/>
		<mssmlbpa:resolution mssml:locid = "DnsDomainOptionV6_resolution"/>                
 	    </report>        	       
	    <report				
	        mssml:severity = "info"
		mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		test = "count(tns:Scopes) = 0 " >
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157552</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "DnsDomainOptionV6_title"/>
		<mssmlbpa:compliant mssml:locid = "DnsDomainOptionV6_compliant"/>              
	    </report>  
  	</rule>
    </pattern> 


    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:ForwardZonesV4Configured">
            <assert				
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = '' " >
		 		 <value-of select="."/>
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157553</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "FwdLookupZonesV4_title"/>
		 <mssmlbpa:problem mssml:locid = "FwdLookupZonesV4_problem"/>
		 <mssmlbpa:impact mssml:locid = "FwdLookupZonesV4_impact"/>
		 <mssmlbpa:resolution mssml:locid = "FwdLookupZonesV4_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = '' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157553</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "FwdLookupZonesV4_title"/>
		 <mssmlbpa:compliant mssml:locid = "FwdLookupZonesV4_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          
	
    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:ForwardZonesV6Configured">
            <assert				
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = '' " >
				 <value-of select="."/>
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157554</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "FwdLookupZonesV6_title"/>
		 <mssmlbpa:problem mssml:locid = "FwdLookupZonesV6_problem"/>
		 <mssmlbpa:impact mssml:locid = "FwdLookupZonesV6_impact"/>
		 <mssmlbpa:resolution mssml:locid = "FwdLookupZonesV6_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = '' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157554</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "FwdLookupZonesV6_title"/>
		 <mssmlbpa:compliant mssml:locid = "FwdLookupZonesV6_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          

    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:SecureDynamicV4Updates">
            <assert				
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = '' " >
                 <value-of select="."/>    
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157555</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdatesV4_title"/>
		 <mssmlbpa:problem mssml:locid = "SecureDnsUpdatesV4_problem"/>
		 <mssmlbpa:impact mssml:locid = "SecureDnsUpdatesV4_impact"/>
		 <mssmlbpa:resolution mssml:locid = "SecureDnsUpdatesV4_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = '' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157555</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdatesV4_title"/>
		 <mssmlbpa:compliant mssml:locid = "SecureDnsUpdatesV4_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          

    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:SecureDynamicV6Updates">
            <assert				
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = '' " >
                 <value-of select="."/>    
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157556</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdatesV6_title"/>
		 <mssmlbpa:problem mssml:locid = "SecureDnsUpdatesV6_problem"/>
		 <mssmlbpa:impact mssml:locid = "SecureDnsUpdatesV6_impact"/>
		 <mssmlbpa:resolution mssml:locid = "SecureDnsUpdatesV6_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = '' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157556</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdatesV6_title"/>
		 <mssmlbpa:compliant mssml:locid = "SecureDnsUpdatesV6_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          
	
    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsUpdateProxySecuredV4">
            <assert				
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = '' " >
		 <value-of select="."/>
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157558</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdateProxyV4_title"/>
		 <mssmlbpa:problem mssml:locid = "SecureDnsUpdateProxyV4_problem"/>
		 <mssmlbpa:impact mssml:locid = "SecureDnsUpdateProxyV4_impact"/>
		 <mssmlbpa:resolution mssml:locid = "SecureDnsUpdateProxyV4_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = '' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157558</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdateProxyV4_title"/>
		 <mssmlbpa:compliant mssml:locid = "SecureDnsUpdateProxyV4_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          
	
    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsUpdateProxySecuredV6">
            <assert				
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = '' " >
		 <value-of select="."/>
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157559</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdateProxyV6_title"/>
		 <mssmlbpa:problem mssml:locid = "SecureDnsUpdateProxyV6_problem"/>
		 <mssmlbpa:impact mssml:locid = "SecureDnsUpdateProxyV6_impact"/>
		 <mssmlbpa:resolution mssml:locid = "SecureDnsUpdateProxyV6_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = '' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157559</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "SecureDnsUpdateProxyV6_title"/>
		 <mssmlbpa:compliant mssml:locid = "SecureDnsUpdateProxyV6_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          

    <pattern>
        <rule context = "tns:DHCPSERVER/tns:DHCP[tns:DhcpError=0]/tns:ServerConfiguration/tns:DnsCredentials">
            <assert		 			
                 mssml:severity = "error"
                 mssml:category = "mssmlbpa:configuration mssmlbpa:markupv2"
                 test = ". = 'true' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157557</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "DnsCredentials_title"/>
		 <mssmlbpa:problem mssml:locid = "DnsCredentials_problem"/>
		 <mssmlbpa:impact mssml:locid = "DnsCredentials_impact"/>
		 <mssmlbpa:resolution mssml:locid = "DnsCredentials_resolution"/>                
            </assert>
            <report				
                 mssml:severity = "info"
                 mssml:category ="mssmlbpa:configuration mssmlbpa:markupv2"
		 test = ". = 'true' " >
                 <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157557</mssmlbpa:helpTopic>
		 <mssmlbpa:title mssml:locid = "DnsCredentials_title"/>
		 <mssmlbpa:compliant mssml:locid = "DnsCredentials_compliant"/>              
   	    </report> 
        </rule>
    </pattern>          

    <pattern>
	<rule context = "tns:DHCPSERVER/tns:DHCP">    
	    <report				
		mssml:severity = "error"
		mssml:category ="mssmlbpa:pre-deployment mssmlbpa:markupv2"
		test = "tns:DhcpError &gt; '0'" >
		<value-of select="tns:DhcpError" />
		<value-of select="tns:DhcpErrorText" />
        	<mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=157560</mssmlbpa:helpTopic>
		<mssmlbpa:title mssml:locid = "Error_title"/>
		<mssmlbpa:problem mssml:locid = "Error_problem"/>
		<mssmlbpa:impact mssml:locid = "Error_impact"/>
		<mssmlbpa:resolution mssml:locid = "Error_resolution"/>                
	    </report>                   
  	</rule>
    </pattern>   

</schema>