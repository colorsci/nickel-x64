<!--
  Schematron Rule Document for Scenario: Hyper-V
  -->
<schema xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:mssml="http://schemas.microsoft.com/sml/extensions/2007/03"
    xmlns:mssmlbpa="http://schemas.microsoft.com/sml/bpa/2008/02">

    <ns prefix="tns" uri="http://schemas.microsoft.com/mbca/models/Hyper-V/2010/12" />

    <pattern>
        <rule context="/tns:HyperVComposite">
            <report
                mssmlbpa:helpID="rule1"
                mssml:severity="error"
                mssml:category="mssmlbpa:pre-check mssmlbpa:advisory mssmlbpa:markupv2"
                test="(tns:violation[tns:ID = '1'])">

                <mssmlbpa:title mssml:locid="rule1_Title"/>
                <mssmlbpa:problem mssml:locid="rule1_Problem"/>
                <mssmlbpa:impact mssml:locid="rule1_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule1_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533538</mssmlbpa:helpTopic>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <report
                mssmlbpa:helpID="rule2"
                mssml:severity="error"
                mssml:category="mssmlbpa:pre-check mssmlbpa:advisory mssmlbpa:markupv2"
                test="(tns:violation[tns:ID = '2'])">

                <mssmlbpa:title mssml:locid="rule2_Title"/>
                <mssmlbpa:problem mssml:locid="rule2_Problem"/>
                <mssmlbpa:impact mssml:locid="rule2_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule2_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533539</mssmlbpa:helpTopic>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule21"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '21'])">
                
                <mssmlbpa:title mssml:locid="rule21_Title"/>
                <mssmlbpa:problem mssml:locid="rule21_Problem"/>
                <mssmlbpa:impact mssml:locid="rule21_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule21_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533540</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule21"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '21'])">

                <mssmlbpa:title mssml:locid="rule21_Title"/>
                <mssmlbpa:compliant mssml:locid="rule21_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule24"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '24'])">

                <mssmlbpa:title mssml:locid="rule24_Title"/>
                <mssmlbpa:problem mssml:locid="rule24_Problem"/>
                <mssmlbpa:impact mssml:locid="rule24_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule24_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533541</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule24"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '24'])">

                <mssmlbpa:title mssml:locid="rule24_Title"/>
                <mssmlbpa:compliant mssml:locid="rule24_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule26"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '26'])">

                <mssmlbpa:title mssml:locid="rule26_Title"/>
                <mssmlbpa:problem mssml:locid="rule26_Problem"/>
                <mssmlbpa:impact mssml:locid="rule26_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule26_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533543</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule26"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '26'])">

                <mssmlbpa:title mssml:locid="rule26_Title"/>
                <mssmlbpa:compliant mssml:locid="rule26_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule27"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '27'])">

                <value-of select="tns:violation[tns:ID='27']/*[2]" />

                <mssmlbpa:title mssml:locid="rule27_Title"/>
                <mssmlbpa:problem mssml:locid="rule27_Problem"/>
                <mssmlbpa:impact mssml:locid="rule27_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule27_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533544</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule27"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '27'])">

                <mssmlbpa:title mssml:locid="rule27_Title"/>
                <mssmlbpa:compliant mssml:locid="rule27_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule28"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '28'])">

                <value-of select="tns:violation[tns:ID='28']/*[2]" />

                <mssmlbpa:title mssml:locid="rule28_Title"/>
                <mssmlbpa:problem mssml:locid="rule28_Problem"/>
                <mssmlbpa:impact mssml:locid="rule28_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule28_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533545</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule28"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '28'])">

                <mssmlbpa:title mssml:locid="rule28_Title"/>
                <mssmlbpa:compliant mssml:locid="rule28_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule29"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '29'])">

                <value-of select="tns:violation[tns:ID='29']/*[2]" />

                <mssmlbpa:title mssml:locid="rule29_Title"/>
                <mssmlbpa:problem mssml:locid="rule29_Problem"/>
                <mssmlbpa:impact mssml:locid="rule29_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule29_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533546</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule29"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '29'])">

                <mssmlbpa:title mssml:locid="rule29_Title"/>
                <mssmlbpa:compliant mssml:locid="rule29_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule30"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '30'])">

                <value-of select="tns:violation[tns:ID='30']/*[2]" />

                <mssmlbpa:title mssml:locid="rule30_Title"/>
                <mssmlbpa:problem mssml:locid="rule30_Problem"/>
                <mssmlbpa:impact mssml:locid="rule30_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule30_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533547</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule30"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '30'])">

                <mssmlbpa:title mssml:locid="rule30_Title"/>
                <mssmlbpa:compliant mssml:locid="rule30_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule32"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '32'])">

                <value-of select="tns:violation[tns:ID='32']/*[2]" />

                <mssmlbpa:title mssml:locid="rule32_Title"/>
                <mssmlbpa:problem mssml:locid="rule32_Problem"/>
                <mssmlbpa:impact mssml:locid="rule32_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule32_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533549</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule32"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '32'])">

                <mssmlbpa:title mssml:locid="rule32_Title"/>
                <mssmlbpa:compliant mssml:locid="rule32_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule51"
                mssml:severity="error"
                mssml:category="mssmlbpa:policy mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '51'])">

                <mssmlbpa:title mssml:locid="rule51_Title"/>
                <mssmlbpa:problem mssml:locid="rule51_Problem"/>
                <mssmlbpa:impact mssml:locid="rule51_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule51_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533550</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule51"
                mssml:severity="info"
                mssml:category="mssmlbpa:policy mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '51'])">

                <mssmlbpa:title mssml:locid="rule51_Title"/>
                <mssmlbpa:compliant mssml:locid="rule51_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule53"
                mssml:severity="error"
                mssml:category="mssmlbpa:policy mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '53'])">
                
                <value-of select="tns:violation[tns:ID='53']/*[2]" />
                
                <mssmlbpa:title mssml:locid="rule53_Title"/>
                <mssmlbpa:problem mssml:locid="rule53_Problem"/>
                <mssmlbpa:impact mssml:locid="rule53_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule53_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533551</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule53"
                mssml:severity="info"
                mssml:category="mssmlbpa:policy mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '53'])">

                <mssmlbpa:title mssml:locid="rule53_Title"/>
                <mssmlbpa:compliant mssml:locid="rule53_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule54"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '54'])">
                
                <mssmlbpa:title mssml:locid="rule54_Title"/>
                <mssmlbpa:problem mssml:locid="rule54_Problem"/>
                <mssmlbpa:impact mssml:locid="rule54_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule54_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533552</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule54"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '54'])">

                <mssmlbpa:title mssml:locid="rule54_Title"/>
                <mssmlbpa:compliant mssml:locid="rule54_Compliant"/>
            </report>
        </rule>
    </pattern>
  
    <pattern>
      <rule context="/tns:HyperVComposite">
        <assert
            mssmlbpa:helpID="rule56"
            mssml:severity="warning"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '56'])">

          <mssmlbpa:title mssml:locid="rule56_Title"/>
          <mssmlbpa:problem mssml:locid="rule56_Problem"/>
          <mssmlbpa:impact mssml:locid="rule56_Impact"/>
          <mssmlbpa:resolution mssml:locid="rule56_Resolution"/>
          <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533655</mssmlbpa:helpTopic>
        </assert>
        <report
            mssmlbpa:helpID="rule56"
            mssml:severity="info"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '56'])">

          <mssmlbpa:title mssml:locid="rule56_Title"/>
          <mssmlbpa:compliant mssml:locid="rule56_Compliant"/>
        </report>
      </rule>
    </pattern>

    <pattern>
      <rule context="/tns:HyperVComposite">
        <assert
            mssmlbpa:helpID="rule57"
            mssml:severity="error"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '57'])">

          <mssmlbpa:title mssml:locid="rule57_Title"/>
          <mssmlbpa:problem mssml:locid="rule57_Problem"/>
          <mssmlbpa:impact mssml:locid="rule57_Impact"/>
          <mssmlbpa:resolution mssml:locid="rule57_Resolution"/>
          <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533624</mssmlbpa:helpTopic>
        </assert>
        <report
            mssmlbpa:helpID="rule57"
            mssml:severity="info"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '57'])">

          <mssmlbpa:title mssml:locid="rule57_Title"/>
          <mssmlbpa:compliant mssml:locid="rule57_Compliant"/>
        </report>
      </rule>
    </pattern>

    <pattern>
      <rule context="/tns:HyperVComposite">
        <assert
            mssmlbpa:helpID="rule59"
            mssml:severity="error"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '59'])">

            <value-of select="tns:violation[tns:ID='59']/*[2]" />

            <mssmlbpa:title mssml:locid="rule59_Title"/>
            <mssmlbpa:problem mssml:locid="rule59_Problem"/>
            <mssmlbpa:impact mssml:locid="rule59_Impact"/>
            <mssmlbpa:resolution mssml:locid="rule59_Resolution"/>
            <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533622</mssmlbpa:helpTopic>
        </assert>
        <report
            mssmlbpa:helpID="rule59"
            mssml:severity="info"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '59'])">

          <mssmlbpa:title mssml:locid="rule59_Title"/>
          <mssmlbpa:compliant mssml:locid="rule59_Compliant"/>
        </report>
      </rule>
    </pattern>

    <pattern>
      <rule context="/tns:HyperVComposite">
        <assert
            mssmlbpa:helpID="rule60"
            mssml:severity="warning"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '60'])">

            <value-of select="tns:violation[tns:ID='60']/*[2]" />

            <mssmlbpa:title mssml:locid="rule60_Title"/>
            <mssmlbpa:problem mssml:locid="rule60_Problem"/>
            <mssmlbpa:impact mssml:locid="rule60_Impact"/>
            <mssmlbpa:resolution mssml:locid="rule60_Resolution"/>
            <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533623</mssmlbpa:helpTopic>
        </assert>
        <report
            mssmlbpa:helpID="rule60"
            mssml:severity="info"
            mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
            test="not (tns:violation[tns:ID = '60'])">

          <mssmlbpa:title mssml:locid="rule60_Title"/>
          <mssmlbpa:compliant mssml:locid="rule60_Compliant"/>
        </report>
      </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule203"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '203'])">

                <value-of select="tns:violation[tns:ID='203']/*[2]" />

                <mssmlbpa:title mssml:locid="rule203_Title"/>
                <mssmlbpa:problem mssml:locid="rule203_Problem"/>
                <mssmlbpa:impact mssml:locid="rule203_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule203_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533555</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule204"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '204'])">

                <value-of select="tns:violation[tns:ID='204']/*[2]" />

                <mssmlbpa:title mssml:locid="rule204_Title"/>
                <mssmlbpa:problem mssml:locid="rule204_Problem"/>
                <mssmlbpa:impact mssml:locid="rule204_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule204_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533556</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule205"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '205'])">

                <value-of select="tns:violation[tns:ID='205']/*[2]" />

                <mssmlbpa:title mssml:locid="rule205_Title"/>
                <mssmlbpa:problem mssml:locid="rule205_Problem"/>
                <mssmlbpa:impact mssml:locid="rule205_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule205_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533557</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule206"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '206'])">

                <value-of select="tns:violation[tns:ID='206']/*[2]" />

                <mssmlbpa:title mssml:locid="rule206_Title"/>
                <mssmlbpa:problem mssml:locid="rule206_Problem"/>
                <mssmlbpa:impact mssml:locid="rule206_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule206_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533558</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule207"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '207'])">

                <value-of select="tns:violation[tns:ID='207']/*[2]" />

                <mssmlbpa:title mssml:locid="rule207_Title"/>
                <mssmlbpa:problem mssml:locid="rule207_Problem"/>
                <mssmlbpa:impact mssml:locid="rule207_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule207_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533559</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule208"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '208'])">

                <value-of select="tns:violation[tns:ID='208']/*[2]" />

                <mssmlbpa:title mssml:locid="rule208_Title"/>
                <mssmlbpa:problem mssml:locid="rule208_Problem"/>
                <mssmlbpa:impact mssml:locid="rule208_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule208_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533560</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule209"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '209'])">

                <value-of select="tns:violation[tns:ID='209']/*[2]" />

                <mssmlbpa:title mssml:locid="rule209_Title"/>
                <mssmlbpa:problem mssml:locid="rule209_Problem"/>
                <mssmlbpa:impact mssml:locid="rule209_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule209_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533561</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule210"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '210'])">

                <value-of select="tns:violation[tns:ID='210']/*[2]" />

                <mssmlbpa:title mssml:locid="rule210_Title"/>
                <mssmlbpa:problem mssml:locid="rule210_Problem"/>
                <mssmlbpa:impact mssml:locid="rule210_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule210_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533562</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule211"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '211'])">

                <value-of select="tns:violation[tns:ID='211']/*[2]" />

                <mssmlbpa:title mssml:locid="rule211_Title"/>
                <mssmlbpa:problem mssml:locid="rule211_Problem"/>
                <mssmlbpa:impact mssml:locid="rule211_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule211_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533625</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule212"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '212'])">

                <value-of select="tns:violation[tns:ID='212']/*[2]" />

                <mssmlbpa:title mssml:locid="rule212_Title"/>
                <mssmlbpa:problem mssml:locid="rule212_Problem"/>
                <mssmlbpa:impact mssml:locid="rule212_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule212_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533626</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule213"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '213'])">

                <value-of select="tns:violation[tns:ID='213']/*[2]" />

                <mssmlbpa:title mssml:locid="rule213_Title"/>
                <mssmlbpa:problem mssml:locid="rule213_Problem"/>
                <mssmlbpa:impact mssml:locid="rule213_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule213_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533627</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule214"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '214'])">

                <value-of select="tns:violation[tns:ID='214']/*[2]" />

                <mssmlbpa:title mssml:locid="rule214_Title"/>
                <mssmlbpa:problem mssml:locid="rule214_Problem"/>
                <mssmlbpa:impact mssml:locid="rule214_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule214_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533628</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule215"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '215'])">

                <value-of select="tns:violation[tns:ID='215']/*[2]" />
                <value-of select="tns:violation[tns:ID='215']/*[3]" />

                <mssmlbpa:title mssml:locid="rule215_Title"/>
                <mssmlbpa:problem mssml:locid="rule215_Problem"/>
                <mssmlbpa:impact mssml:locid="rule215_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule215_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533563</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule216"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '216'])">

                <value-of select="tns:violation[tns:ID='216']/*[2]" />
                <value-of select="tns:violation[tns:ID='216']/*[3]" />

                <mssmlbpa:title mssml:locid="rule216_Title"/>
                <mssmlbpa:problem mssml:locid="rule216_Problem"/>
                <mssmlbpa:impact mssml:locid="rule216_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule216_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533564</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule217"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '217'])">

                <value-of select="tns:violation[tns:ID='217']/*[2]" />
                <value-of select="tns:violation[tns:ID='217']/*[3]" />

                <mssmlbpa:title mssml:locid="rule217_Title"/>
                <mssmlbpa:problem mssml:locid="rule217_Problem"/>
                <mssmlbpa:impact mssml:locid="rule217_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule217_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533647</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule218"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '218'])">

                <value-of select="tns:violation[tns:ID='218']/*[2]" />
                <value-of select="tns:violation[tns:ID='218']/*[3]" />

                <mssmlbpa:title mssml:locid="rule218_Title"/>
                <mssmlbpa:problem mssml:locid="rule218_Problem"/>
                <mssmlbpa:impact mssml:locid="rule218_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule218_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533648</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule224"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '224'])">

                <value-of select="tns:violation[tns:ID='224']/*[2]" />

                <mssmlbpa:title mssml:locid="rule224_Title"/>
                <mssmlbpa:problem mssml:locid="rule224_Problem"/>
                <mssmlbpa:impact mssml:locid="rule224_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule224_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533563</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
  
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule225"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '225'])">

                <value-of select="tns:violation[tns:ID='225']/*[2]" />

                <mssmlbpa:title mssml:locid="rule225_Title"/>
                <mssmlbpa:problem mssml:locid="rule225_Problem"/>
                <mssmlbpa:impact mssml:locid="rule225_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule225_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533564</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule226"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '226'])">

                <mssmlbpa:title mssml:locid="rule226_Title"/>
                <mssmlbpa:problem mssml:locid="rule226_Problem"/>
                <mssmlbpa:impact mssml:locid="rule226_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule226_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533565</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule226"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '226'])">

                <mssmlbpa:title mssml:locid="rule226_Title"/>
                <mssmlbpa:compliant mssml:locid="rule226_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule227"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '227'])">

                <mssmlbpa:title mssml:locid="rule227_Title"/>
                <mssmlbpa:problem mssml:locid="rule227_Problem"/>
                <mssmlbpa:impact mssml:locid="rule227_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule227_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533566</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule227"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '227'])">

                <mssmlbpa:title mssml:locid="rule227_Title"/>
                <mssmlbpa:compliant mssml:locid="rule227_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule228"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '228'])">

                <value-of select="tns:violation[tns:ID='228']/*[2]" />

                <mssmlbpa:title mssml:locid="rule228_Title"/>
                <mssmlbpa:problem mssml:locid="rule228_Problem"/>
                <mssmlbpa:impact mssml:locid="rule228_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule228_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533567</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule228"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '228'])">

                <mssmlbpa:title mssml:locid="rule228_Title"/>
                <mssmlbpa:compliant mssml:locid="rule228_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule229"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '229'])">

                <value-of select="tns:violation[tns:ID='229']/*[2]" />

                <mssmlbpa:title mssml:locid="rule229_Title"/>
                <mssmlbpa:problem mssml:locid="rule229_Problem"/>
                <mssmlbpa:impact mssml:locid="rule229_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule229_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533568</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule229"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '229'])">

                <mssmlbpa:title mssml:locid="rule229_Title"/>
                <mssmlbpa:compliant mssml:locid="rule229_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule230"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '230'])">

                <value-of select="tns:violation[tns:ID='230']/*[2]" />

                <mssmlbpa:title mssml:locid="rule230_Title"/>
                <mssmlbpa:problem mssml:locid="rule230_Problem"/>
                <mssmlbpa:impact mssml:locid="rule230_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule230_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533569</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule230"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '230'])">

                <mssmlbpa:title mssml:locid="rule230_Title"/>
                <mssmlbpa:compliant mssml:locid="rule230_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule231"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '231'])">

                <value-of select="tns:violation[tns:ID='231']/*[2]" />

                <mssmlbpa:title mssml:locid="rule231_Title"/>
                <mssmlbpa:problem mssml:locid="rule231_Problem"/>
                <mssmlbpa:impact mssml:locid="rule231_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule231_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533629</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule231"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '231'])">

                <mssmlbpa:title mssml:locid="rule231_Title"/>
                <mssmlbpa:compliant mssml:locid="rule231_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule232"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '232'])">

                <mssmlbpa:title mssml:locid="rule232_Title"/>
                <mssmlbpa:problem mssml:locid="rule232_Problem"/>
                <mssmlbpa:impact mssml:locid="rule232_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule232_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533570</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule232"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '232'])">

                <mssmlbpa:title mssml:locid="rule232_Title"/>
                <mssmlbpa:compliant mssml:locid="rule232_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule233"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '233'])">

                <value-of select="tns:violation[tns:ID='233']/*[2]" />

                <mssmlbpa:title mssml:locid="rule233_Title"/>
                <mssmlbpa:problem mssml:locid="rule233_Problem"/>
                <mssmlbpa:impact mssml:locid="rule233_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule233_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533630</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule233"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '233'])">

                <mssmlbpa:title mssml:locid="rule233_Title"/>
                <mssmlbpa:compliant mssml:locid="rule233_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule234"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '234'])">

                <value-of select="tns:violation[tns:ID='234']/*[2]" />

                <mssmlbpa:title mssml:locid="rule234_Title"/>
                <mssmlbpa:problem mssml:locid="rule234_Problem"/>
                <mssmlbpa:impact mssml:locid="rule234_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule234_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533571</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule234"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '234'])">

                <mssmlbpa:title mssml:locid="rule234_Title"/>
                <mssmlbpa:compliant mssml:locid="rule234_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule235"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '235'])">

                <value-of select="tns:violation[tns:ID='235']/*[2]" />

                <mssmlbpa:title mssml:locid="rule235_Title"/>
                <mssmlbpa:problem mssml:locid="rule235_Problem"/>
                <mssmlbpa:impact mssml:locid="rule235_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule235_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533572</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule235"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '235'])">

                <mssmlbpa:title mssml:locid="rule235_Title"/>
                <mssmlbpa:compliant mssml:locid="rule235_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule236"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '236'])">

                <value-of select="tns:violation[tns:ID='236']/*[2]" />

                <mssmlbpa:title mssml:locid="rule236_Title"/>
                <mssmlbpa:problem mssml:locid="rule236_Problem"/>
                <mssmlbpa:impact mssml:locid="rule236_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule236_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533573</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule236"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '236'])">

                <mssmlbpa:title mssml:locid="rule236_Title"/>
                <mssmlbpa:compliant mssml:locid="rule236_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule237"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '237'])">

                <value-of select="tns:violation[tns:ID='237']/*[2]" />

                <mssmlbpa:title mssml:locid="rule237_Title"/>
                <mssmlbpa:problem mssml:locid="rule237_Problem"/>
                <mssmlbpa:impact mssml:locid="rule237_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule237_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533574</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule237"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '237'])">

                <mssmlbpa:title mssml:locid="rule237_Title"/>
                <mssmlbpa:compliant mssml:locid="rule237_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule238"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '238'])">

                <value-of select="tns:violation[tns:ID='238']/*[2]" />

                <mssmlbpa:title mssml:locid="rule238_Title"/>
                <mssmlbpa:problem mssml:locid="rule238_Problem"/>
                <mssmlbpa:impact mssml:locid="rule238_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule238_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533575</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule238"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '238'])">

                <mssmlbpa:title mssml:locid="rule238_Title"/>
                <mssmlbpa:compliant mssml:locid="rule238_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule239"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '239'])">

                <value-of select="tns:violation[tns:ID='239']/*[2]" />

                <mssmlbpa:title mssml:locid="rule239_Title"/>
                <mssmlbpa:problem mssml:locid="rule239_Problem"/>
                <mssmlbpa:impact mssml:locid="rule239_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule239_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533576</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule239"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '239'])">

                <mssmlbpa:title mssml:locid="rule239_Title"/>
                <mssmlbpa:compliant mssml:locid="rule239_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule240"
                mssml:severity="error"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '240'])">

                <value-of select="tns:violation[tns:ID='240']/*[2]" />

                <mssmlbpa:title mssml:locid="rule240_Title"/>
                <mssmlbpa:problem mssml:locid="rule240_Problem"/>
                <mssmlbpa:impact mssml:locid="rule240_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule240_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533577</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule240"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '240'])">

                <mssmlbpa:title mssml:locid="rule240_Title"/>
                <mssmlbpa:compliant mssml:locid="rule240_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule241"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '241'])">

                <value-of select="tns:violation[tns:ID='241']/*[2]" />

                <mssmlbpa:title mssml:locid="rule241_Title"/>
                <mssmlbpa:problem mssml:locid="rule241_Problem"/>
                <mssmlbpa:impact mssml:locid="rule241_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule241_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533578</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule241"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '241'])">

                <mssmlbpa:title mssml:locid="rule241_Title"/>
                <mssmlbpa:compliant mssml:locid="rule241_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule245"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '245'])">

                <value-of select="tns:violation[tns:ID='245']/*[2]" />

                <mssmlbpa:title mssml:locid="rule245_Title"/>
                <mssmlbpa:problem mssml:locid="rule245_Problem"/>
                <mssmlbpa:impact mssml:locid="rule245_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule245_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533631</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule245"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '245'])">

                <mssmlbpa:title mssml:locid="rule245_Title"/>
                <mssmlbpa:compliant mssml:locid="rule245_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule251"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '251'])">

                <value-of select="tns:violation[tns:ID='251']/*[2]" />

                <mssmlbpa:title mssml:locid="rule251_Title"/>
                <mssmlbpa:problem mssml:locid="rule251_Problem"/>
                <mssmlbpa:impact mssml:locid="rule251_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule251_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533579</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule251"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '251'])">

                <mssmlbpa:title mssml:locid="rule251_Title"/>
                <mssmlbpa:compliant mssml:locid="rule251_Compliant"/>
            </report>
        </rule>
    </pattern>  
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule252"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '252'])">

                <value-of select="tns:violation[tns:ID='252']/*[2]" />

                <mssmlbpa:title mssml:locid="rule252_Title"/>
                <mssmlbpa:problem mssml:locid="rule252_Problem"/>
                <mssmlbpa:impact mssml:locid="rule252_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule252_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533580</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule300"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '300'])">

                <value-of select="tns:violation[tns:ID='300']/*[2]" />

                <mssmlbpa:title mssml:locid="rule300_Title"/>
                <mssmlbpa:problem mssml:locid="rule300_Problem"/>
                <mssmlbpa:impact mssml:locid="rule300_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule300_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533581</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule300"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '300'])">

                <mssmlbpa:title mssml:locid="rule300_Title"/>
                <mssmlbpa:compliant mssml:locid="rule300_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule351"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '351'])">

                <value-of select="tns:violation[tns:ID='351']/*[2]" />

                <mssmlbpa:title mssml:locid="rule351_Title"/>
                <mssmlbpa:problem mssml:locid="rule351_Problem"/>
                <mssmlbpa:impact mssml:locid="rule351_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule351_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533582</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule351"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '351'])">

                <mssmlbpa:title mssml:locid="rule351_Title"/>
                <mssmlbpa:compliant mssml:locid="rule351_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule352"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '352'])">

                <value-of select="tns:violation[tns:ID='352']/*[2]" />

                <mssmlbpa:title mssml:locid="rule352_Title"/>
                <mssmlbpa:problem mssml:locid="rule352_Problem"/>
                <mssmlbpa:impact mssml:locid="rule352_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule352_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533583</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule352"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '352'])">

                <mssmlbpa:title mssml:locid="rule352_Title"/>
                <mssmlbpa:compliant mssml:locid="rule352_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule353"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '353'])">

                <value-of select="tns:violation[tns:ID='353']/*[2]" />

                <mssmlbpa:title mssml:locid="rule353_Title"/>
                <mssmlbpa:problem mssml:locid="rule353_Problem"/>
                <mssmlbpa:impact mssml:locid="rule353_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule353_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533584</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule353"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '353'])">

                <mssmlbpa:title mssml:locid="rule353_Title"/>
                <mssmlbpa:compliant mssml:locid="rule353_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule354"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '354'])">

                <value-of select="tns:violation[tns:ID='354']/*[2]" />

                <mssmlbpa:title mssml:locid="rule354_Title"/>
                <mssmlbpa:problem mssml:locid="rule354_Problem"/>
                <mssmlbpa:impact mssml:locid="rule354_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule354_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533633</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule354"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '354'])">

                <mssmlbpa:title mssml:locid="rule354_Title"/>
                <mssmlbpa:compliant mssml:locid="rule354_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule355"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '355'])">

                <value-of select="tns:violation[tns:ID='355']/*[2]" />

                <mssmlbpa:title mssml:locid="rule355_Title"/>
                <mssmlbpa:problem mssml:locid="rule355_Problem"/>
                <mssmlbpa:impact mssml:locid="rule355_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule355_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533634</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule355"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '355'])">

                <mssmlbpa:title mssml:locid="rule355_Title"/>
                <mssmlbpa:compliant mssml:locid="rule355_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule401"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '401'])">

                <value-of select="tns:violation[tns:ID='401']/*[2]" />

                <mssmlbpa:title mssml:locid="rule401_Title"/>
                <mssmlbpa:problem mssml:locid="rule401_Problem"/>
                <mssmlbpa:impact mssml:locid="rule401_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule401_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533585</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule401"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '401'])">

                <mssmlbpa:title mssml:locid="rule401_Title"/>
                <mssmlbpa:compliant mssml:locid="rule401_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule402"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '402'])">

                <value-of select="tns:violation[tns:ID='402']/*[2]" />

                <mssmlbpa:title mssml:locid="rule402_Title"/>
                <mssmlbpa:problem mssml:locid="rule402_Problem"/>
                <mssmlbpa:impact mssml:locid="rule402_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule402_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533586</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule402"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '402'])">

                <mssmlbpa:title mssml:locid="rule402_Title"/>
                <mssmlbpa:compliant mssml:locid="rule402_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule403"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '403'])">

                <value-of select="tns:violation[tns:ID='403']/*[2]" />

                <mssmlbpa:title mssml:locid="rule403_Title"/>
                <mssmlbpa:problem mssml:locid="rule403_Problem"/>
                <mssmlbpa:impact mssml:locid="rule403_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule403_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533587</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule403"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '403'])">

                <mssmlbpa:title mssml:locid="rule403_Title"/>
                <mssmlbpa:compliant mssml:locid="rule403_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule404"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '404'])">

                <value-of select="tns:violation[tns:ID='404']/*[2]" />

                <mssmlbpa:title mssml:locid="rule404_Title"/>
                <mssmlbpa:problem mssml:locid="rule404_Problem"/>
                <mssmlbpa:impact mssml:locid="rule404_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule404_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533588</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule404"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '404'])">

                <mssmlbpa:title mssml:locid="rule404_Title"/>
                <mssmlbpa:compliant mssml:locid="rule404_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule426"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '426'])">
                
                <mssmlbpa:title mssml:locid="rule426_Title"/>
                <mssmlbpa:problem mssml:locid="rule426_Problem"/>
                <mssmlbpa:impact mssml:locid="rule426_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule426_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533589</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule426"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '426'])">

                <mssmlbpa:title mssml:locid="rule426_Title"/>
                <mssmlbpa:compliant mssml:locid="rule426_Compliant"/>
            </report>
        </rule>
    </pattern>
        
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule427"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '427'])">
                
                <mssmlbpa:title mssml:locid="rule427_Title"/>
                <mssmlbpa:problem mssml:locid="rule427_Problem"/>
                <mssmlbpa:impact mssml:locid="rule427_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule427_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533590</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule427"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '427'])">

                <mssmlbpa:title mssml:locid="rule427_Title"/>
                <mssmlbpa:compliant mssml:locid="rule427_Compliant"/>
            </report>
        </rule>
    </pattern>
        
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule429"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '429'])">

                <value-of select="tns:violation[tns:ID='429']/*[2]" />

                <mssmlbpa:title mssml:locid="rule429_Title"/>
                <mssmlbpa:problem mssml:locid="rule429_Problem"/>
                <mssmlbpa:impact mssml:locid="rule429_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule429_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533591</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule429"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '429'])">

                <mssmlbpa:title mssml:locid="rule429_Title"/>
                <mssmlbpa:compliant mssml:locid="rule429_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule430"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '430'])">

                <value-of select="tns:violation[tns:ID='430']/*[2]" />

                <mssmlbpa:title mssml:locid="rule430_Title"/>
                <mssmlbpa:problem mssml:locid="rule430_Problem"/>
                <mssmlbpa:impact mssml:locid="rule430_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule430_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533592</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule430"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '430'])">

                <mssmlbpa:title mssml:locid="rule430_Title"/>
                <mssmlbpa:compliant mssml:locid="rule430_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule432"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '432'])">

                <value-of select="tns:violation[tns:ID='432']/*[2]" />

                <mssmlbpa:title mssml:locid="rule432_Title"/>
                <mssmlbpa:problem mssml:locid="rule432_Problem"/>
                <mssmlbpa:impact mssml:locid="rule432_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule432_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533594</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule432"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '432'])">

                <mssmlbpa:title mssml:locid="rule432_Title"/>
                <mssmlbpa:compliant mssml:locid="rule432_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule433"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '433'])">

                <value-of select="tns:violation[tns:ID='433']/*[2]" />

                <mssmlbpa:title mssml:locid="rule433_Title"/>
                <mssmlbpa:problem mssml:locid="rule433_Problem"/>
                <mssmlbpa:impact mssml:locid="rule433_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule433_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533595</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule433"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '433'])">

                <mssmlbpa:title mssml:locid="rule433_Title"/>
                <mssmlbpa:compliant mssml:locid="rule433_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule434"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '434'])">

                <value-of select="tns:violation[tns:ID='434']/*[2]" />

                <mssmlbpa:title mssml:locid="rule434_Title"/>
                <mssmlbpa:problem mssml:locid="rule434_Problem"/>
                <mssmlbpa:impact mssml:locid="rule434_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule434_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533638</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule434"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '434'])">

                <mssmlbpa:title mssml:locid="rule434_Title"/>
                <mssmlbpa:compliant mssml:locid="rule434_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule435"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '435'])">

                <value-of select="tns:violation[tns:ID='435']/*[2]" />

                <mssmlbpa:title mssml:locid="rule435_Title"/>
                <mssmlbpa:problem mssml:locid="rule435_Problem"/>
                <mssmlbpa:impact mssml:locid="rule435_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule435_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533639</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule435"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '435'])">

                <mssmlbpa:title mssml:locid="rule435_Title"/>
                <mssmlbpa:compliant mssml:locid="rule435_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule436"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '436'])">

                <value-of select="tns:violation[tns:ID='436']/*[2]" />

                <mssmlbpa:title mssml:locid="rule436_Title"/>
                <mssmlbpa:problem mssml:locid="rule436_Problem"/>
                <mssmlbpa:impact mssml:locid="rule436_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule436_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533640</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule436"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '436'])">

                <mssmlbpa:title mssml:locid="rule436_Title"/>
                <mssmlbpa:compliant mssml:locid="rule436_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule437"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '437'])">

                <value-of select="tns:violation[tns:ID='437']/*[2]" />

                <mssmlbpa:title mssml:locid="rule437_Title"/>
                <mssmlbpa:problem mssml:locid="rule437_Problem"/>
                <mssmlbpa:impact mssml:locid="rule437_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule437_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533641</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule437"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '437'])">

                <mssmlbpa:title mssml:locid="rule437_Title"/>
                <mssmlbpa:compliant mssml:locid="rule437_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule438"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '438'])">

                <value-of select="tns:violation[tns:ID='438']/*[2]" />

                <mssmlbpa:title mssml:locid="rule438_Title"/>
                <mssmlbpa:problem mssml:locid="rule438_Problem"/>
                <mssmlbpa:impact mssml:locid="rule438_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule438_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533642</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule438"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '438'])">

                <mssmlbpa:title mssml:locid="rule438_Title"/>
                <mssmlbpa:compliant mssml:locid="rule438_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule439"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '439'])">

                <value-of select="tns:violation[tns:ID='439']/*[2]" />

                <mssmlbpa:title mssml:locid="rule439_Title"/>
                <mssmlbpa:problem mssml:locid="rule439_Problem"/>
                <mssmlbpa:impact mssml:locid="rule439_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule439_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533643</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule439"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '439'])">

                <mssmlbpa:title mssml:locid="rule439_Title"/>
                <mssmlbpa:compliant mssml:locid="rule439_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule440"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '440'])">

                <value-of select="tns:violation[tns:ID='440']/*[2]" />

                <mssmlbpa:title mssml:locid="rule440_Title"/>
                <mssmlbpa:problem mssml:locid="rule440_Problem"/>
                <mssmlbpa:impact mssml:locid="rule440_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule440_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533644</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule440"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '440'])">

                <mssmlbpa:title mssml:locid="rule440_Title"/>
                <mssmlbpa:compliant mssml:locid="rule440_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule476"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '476'])">

                <value-of select="tns:violation[tns:ID='476']/*[2]" />

                <mssmlbpa:title mssml:locid="rule476_Title"/>
                <mssmlbpa:problem mssml:locid="rule476_Problem"/>
                <mssmlbpa:impact mssml:locid="rule476_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule476_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533596</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule476"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '476'])">

                <mssmlbpa:title mssml:locid="rule476_Title"/>
                <mssmlbpa:compliant mssml:locid="rule476_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule477"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '477'])">

                <value-of select="tns:violation[tns:ID='477']/*[2]" />

                <mssmlbpa:title mssml:locid="rule477_Title"/>
                <mssmlbpa:problem mssml:locid="rule477_Problem"/>
                <mssmlbpa:impact mssml:locid="rule477_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule477_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533597</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule477"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '477'])">

                <mssmlbpa:title mssml:locid="rule477_Title"/>
                <mssmlbpa:compliant mssml:locid="rule477_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule478"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '478'])">

                <value-of select="tns:violation[tns:ID='478']/*[2]" />

                <mssmlbpa:title mssml:locid="rule478_Title"/>
                <mssmlbpa:problem mssml:locid="rule478_Problem"/>
                <mssmlbpa:impact mssml:locid="rule478_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule478_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533645</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule478"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '478'])">

                <mssmlbpa:title mssml:locid="rule478_Title"/>
                <mssmlbpa:compliant mssml:locid="rule478_Compliant"/>
            </report>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule502"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '502'])">

                <value-of select="tns:violation[tns:ID='502']/*[2]" />

                <mssmlbpa:title mssml:locid="rule502_Title"/>
                <mssmlbpa:problem mssml:locid="rule502_Problem"/>
                <mssmlbpa:impact mssml:locid="rule502_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule502_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533599</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
   
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule506"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '506'])">

                <value-of select="tns:violation[tns:ID='506']/*[2]" />

                <mssmlbpa:title mssml:locid="rule506_Title"/>
                <mssmlbpa:problem mssml:locid="rule506_Problem"/>
                <mssmlbpa:impact mssml:locid="rule506_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule506_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533656</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule514"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '514'])">

                <value-of select="tns:violation[tns:ID='514']/*[2]" />

                <mssmlbpa:title mssml:locid="rule514_Title"/>
                <mssmlbpa:problem mssml:locid="rule514_Problem"/>
                <mssmlbpa:impact mssml:locid="rule514_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule514_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533607</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule515"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '515'])">

                <value-of select="tns:violation[tns:ID='515']/*[2]" />

                <mssmlbpa:title mssml:locid="rule515_Title"/>
                <mssmlbpa:problem mssml:locid="rule515_Problem"/>
                <mssmlbpa:impact mssml:locid="rule515_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule515_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533608</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule516"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '516'])">

                <value-of select="tns:violation[tns:ID='516']/*[2]" />

                <mssmlbpa:title mssml:locid="rule516_Title"/>
                <mssmlbpa:problem mssml:locid="rule516_Problem"/>
                <mssmlbpa:impact mssml:locid="rule516_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule516_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533609</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule517"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '517'])">

                <value-of select="tns:violation[tns:ID='517']/*[2]" />

                <mssmlbpa:title mssml:locid="rule517_Title"/>
                <mssmlbpa:problem mssml:locid="rule517_Problem"/>
                <mssmlbpa:impact mssml:locid="rule517_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule517_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533610</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule518"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '518'])">

                <value-of select="tns:violation[tns:ID='518']/*[2]" />

                <mssmlbpa:title mssml:locid="rule518_Title"/>
                <mssmlbpa:problem mssml:locid="rule518_Problem"/>
                <mssmlbpa:impact mssml:locid="rule518_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule518_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533611</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule519"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '519'])">

                <value-of select="tns:violation[tns:ID='519']/*[2]" />

                <mssmlbpa:title mssml:locid="rule519_Title"/>
                <mssmlbpa:problem mssml:locid="rule519_Problem"/>
                <mssmlbpa:impact mssml:locid="rule519_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule519_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533612</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule520"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '520'])">

                <value-of select="tns:violation[tns:ID='520']/*[2]" />

                <mssmlbpa:title mssml:locid="rule520_Title"/>
                <mssmlbpa:problem mssml:locid="rule520_Problem"/>
                <mssmlbpa:impact mssml:locid="rule520_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule520_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533613</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule521"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '521'])">

                <value-of select="tns:violation[tns:ID='521']/*[2]" />

                <mssmlbpa:title mssml:locid="rule521_Title"/>
                <mssmlbpa:problem mssml:locid="rule521_Problem"/>
                <mssmlbpa:impact mssml:locid="rule521_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule521_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533614</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule522"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '522'])">

                <value-of select="tns:violation[tns:ID='522']/*[2]" />

                <mssmlbpa:title mssml:locid="rule522_Title"/>
                <mssmlbpa:problem mssml:locid="rule522_Problem"/>
                <mssmlbpa:impact mssml:locid="rule522_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule522_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533635</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule523"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '523'])">

                <value-of select="tns:violation[tns:ID='523']/*[2]" />

                <mssmlbpa:title mssml:locid="rule523_Title"/>
                <mssmlbpa:problem mssml:locid="rule523_Problem"/>
                <mssmlbpa:impact mssml:locid="rule523_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule523_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533636</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule524"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '524'])">

                <value-of select="tns:violation[tns:ID='524']/*[2]" />

                <mssmlbpa:title mssml:locid="rule524_Title"/>
                <mssmlbpa:problem mssml:locid="rule524_Problem"/>
                <mssmlbpa:impact mssml:locid="rule524_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule524_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533637</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule525"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '525'])">

                <value-of select="tns:violation[tns:ID='525']/*[2]" />

                <mssmlbpa:title mssml:locid="rule525_Title"/>
                <mssmlbpa:problem mssml:locid="rule525_Problem"/>
                <mssmlbpa:impact mssml:locid="rule525_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule525_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533632</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule526"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '526'])">

                <value-of select="tns:violation[tns:ID='526']/*[2]" />
                <value-of select="tns:violation[tns:ID='526']/*[3]" />

                <mssmlbpa:title mssml:locid="rule526_Title"/>
                <mssmlbpa:problem mssml:locid="rule526_Problem"/>
                <mssmlbpa:impact mssml:locid="rule526_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule526_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533649</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule527"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '527'])">

                <value-of select="tns:violation[tns:ID='527']/*[2]" />
                <value-of select="tns:violation[tns:ID='527']/*[3]" />

                <mssmlbpa:title mssml:locid="rule527_Title"/>
                <mssmlbpa:problem mssml:locid="rule527_Problem"/>
                <mssmlbpa:impact mssml:locid="rule527_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule527_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533650</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule528"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '528'])">

                <value-of select="tns:violation[tns:ID='528']/*[2]" />
                <value-of select="tns:violation[tns:ID='528']/*[3]" />

                <mssmlbpa:title mssml:locid="rule528_Title"/>
                <mssmlbpa:problem mssml:locid="rule528_Problem"/>
                <mssmlbpa:impact mssml:locid="rule528_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule528_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533651</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
    
    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule529"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '529'])">

                <value-of select="tns:violation[tns:ID='529']/*[2]" />
                <value-of select="tns:violation[tns:ID='529']/*[3]" />

                <mssmlbpa:title mssml:locid="rule529_Title"/>
                <mssmlbpa:problem mssml:locid="rule529_Problem"/>
                <mssmlbpa:impact mssml:locid="rule529_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule529_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533652</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule530"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '530'])">

                <value-of select="tns:violation[tns:ID='530']/*[2]" />
                <value-of select="tns:violation[tns:ID='530']/*[3]" />

                <mssmlbpa:title mssml:locid="rule530_Title"/>
                <mssmlbpa:problem mssml:locid="rule530_Problem"/>
                <mssmlbpa:impact mssml:locid="rule530_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule530_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533657</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule531"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '531'])">

                <value-of select="tns:violation[tns:ID='531']/*[2]" />
                <value-of select="tns:violation[tns:ID='531']/*[3]" />

                <mssmlbpa:title mssml:locid="rule531_Title"/>
                <mssmlbpa:problem mssml:locid="rule531_Problem"/>
                <mssmlbpa:impact mssml:locid="rule531_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule531_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533926</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule532"
                mssml:severity="error"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '532'])">

                <value-of select="tns:violation[tns:ID='532']/*[2]" />
                <value-of select="tns:violation[tns:ID='532']/*[3]" />

                <mssmlbpa:title mssml:locid="rule532_Title"/>
                <mssmlbpa:problem mssml:locid="rule532_Problem"/>
                <mssmlbpa:impact mssml:locid="rule532_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule532_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533928</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule533"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '533'])">

                <value-of select="tns:violation[tns:ID='533']/*[2]" />
                <value-of select="tns:violation[tns:ID='533']/*[3]" />

                <mssmlbpa:title mssml:locid="rule533_Title"/>
                <mssmlbpa:problem mssml:locid="rule533_Problem"/>
                <mssmlbpa:impact mssml:locid="rule533_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule533_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533929</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule576"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '576'])">

                <value-of select="tns:violation[tns:ID='576']/*[2]" />

                <mssmlbpa:title mssml:locid="rule576_Title"/>
                <mssmlbpa:problem mssml:locid="rule576_Problem"/>
                <mssmlbpa:impact mssml:locid="rule576_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule576_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533615</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule576"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '576'])">

                <mssmlbpa:title mssml:locid="rule576_Title"/>
                <mssmlbpa:compliant mssml:locid="rule576_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule600"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '600'])">

                <value-of select="tns:violation[tns:ID='600']/*[2]" />

                <mssmlbpa:title mssml:locid="rule600_Title"/>
                <mssmlbpa:problem mssml:locid="rule600_Problem"/>
                <mssmlbpa:impact mssml:locid="rule600_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule600_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533616</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule600"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '600'])">

                <mssmlbpa:title mssml:locid="rule600_Title"/>
                <mssmlbpa:compliant mssml:locid="rule600_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule602"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '602'])">

                <value-of select="tns:violation[tns:ID='602']/*[2]" />

                <mssmlbpa:title mssml:locid="rule602_Title"/>
                <mssmlbpa:problem mssml:locid="rule602_Problem"/>
                <mssmlbpa:impact mssml:locid="rule602_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule602_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533618</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule602"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '602'])">

                <mssmlbpa:title mssml:locid="rule602_Title"/>
                <mssmlbpa:compliant mssml:locid="rule602_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule604"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '604'])">

                <value-of select="tns:violation[tns:ID='604']/*[2]" />

                <mssmlbpa:title mssml:locid="rule604_Title"/>
                <mssmlbpa:problem mssml:locid="rule604_Problem"/>
                <mssmlbpa:impact mssml:locid="rule604_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule604_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533619</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule604"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '604'])">

                <mssmlbpa:title mssml:locid="rule604_Title"/>
                <mssmlbpa:compliant mssml:locid="rule604_Compliant"/>
            </report>
        </rule>
    </pattern>           

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule605"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '605'])">

                <value-of select="tns:violation[tns:ID='605']/*[2]" />

                <mssmlbpa:title mssml:locid="rule605_Title"/>
                <mssmlbpa:problem mssml:locid="rule605_Problem"/>
                <mssmlbpa:impact mssml:locid="rule605_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule605_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533653</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule605"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '605'])">

                <mssmlbpa:title mssml:locid="rule605_Title"/>
                <mssmlbpa:compliant mssml:locid="rule605_Compliant"/>
            </report>
        </rule>
    </pattern>           

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule606"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '606'])">

                <value-of select="tns:violation[tns:ID='606']/*[2]" />

                <mssmlbpa:title mssml:locid="rule606_Title"/>
                <mssmlbpa:problem mssml:locid="rule606_Problem"/>
                <mssmlbpa:impact mssml:locid="rule606_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule606_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=627284</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule606"
                mssml:severity="info"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '606'])">

                <mssmlbpa:title mssml:locid="rule606_Title"/>
                <mssmlbpa:compliant mssml:locid="rule606_Compliant"/>
            </report>
        </rule>
    </pattern>                            

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule652"
                mssml:severity="warning"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '652'])">

                <mssmlbpa:title mssml:locid="rule652_Title"/>
                <mssmlbpa:problem mssml:locid="rule652_Problem"/>
                <mssmlbpa:impact mssml:locid="rule652_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule652_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/?LinkId=533621</mssmlbpa:helpTopic>
            </assert>
            <report
                mssmlbpa:helpID="rule652"
                mssml:severity="info"
                mssml:category="mssmlbpa:operation mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '652'])">

                <mssmlbpa:title mssml:locid="rule652_Title"/>
                <mssmlbpa:compliant mssml:locid="rule652_Compliant"/>
            </report>
        </rule>
    </pattern>

    <pattern>
        <rule context="/tns:HyperVComposite">
            <assert
                mssmlbpa:helpID="rule675"
                mssml:severity="warning"
                mssml:category="mssmlbpa:configuration mssmlbpa:advisory mssmlbpa:markupv2"
                test="not (tns:violation[tns:ID = '675'])">

                <value-of select="tns:violation[tns:ID='675']/*[2]" />

                <mssmlbpa:title mssml:locid="rule675_Title"/>
                <mssmlbpa:problem mssml:locid="rule675_Problem"/>
                <mssmlbpa:impact mssml:locid="rule675_Impact"/>
                <mssmlbpa:resolution mssml:locid="rule675_Resolution"/>
                <mssmlbpa:helpTopic>http://go.microsoft.com/fwlink/p/?LinkId=533646</mssmlbpa:helpTopic>
            </assert>
        </rule>
    </pattern>
</schema>
