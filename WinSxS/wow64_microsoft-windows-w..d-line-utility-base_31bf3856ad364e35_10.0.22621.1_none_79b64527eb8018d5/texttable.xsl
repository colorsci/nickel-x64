<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:vb="urn:the-xml-files:xslt-vb" xmlns:user="placeholder" version="1.0">
<!-- Copyright (c) Microsoft Corporation.  All rights reserved. -->

<xsl:output method="text" omit-xml-declaration="yes" indent="no"/>
<xsl:strip-space elements="*" />

<ms:script implements-prefix="user" language="VBScript">
<![CDATA[
Option Explicit
'This stylesheet formats DMTF XML encoded CIM objects into a tabular
'format using carriage returns and space characters only.
Dim sPXML
Dim propname(128)
Dim lenarr(128)
Dim bN(128)
Dim iLens
Dim iLensMax
Dim propvalue(2048, 128)
Dim iRow
iRow = -1 
Dim iResultCount
Function CountResults(n)
    iResultCount = iResultCount + 1
    CountResults = ""
End Function
Function PadIt(ilen)
    Dim i
    Dim pads
    i = ilen + 2
    pads = "                "
    while (i > len(pads))
	pads = pads & pads
    wend
    PadIt = Left(pads, i)
End Function
Function GotInstance()
    iLensMax = iLens
    iLens = 0
    iRow = iRow + 1
    GotInstance = ""
End Function
Function GetValues(n)
    Dim child, iNum, i, strType
    If iRow = 0 Then
        'this is the first row - set up the headers
        propname(iLens) = n.item(0).attributes.GetNamedItem("NAME").Value
    Else
        If propname(iLens) <> n.item(0).attributes.GetNamedItem("NAME").Value Then
            'This is going to be messy - Find it or add it on the end
        End If
    End If
    If strcomp(n.item(0).NodeName,"Property.Array",1) = 0 Then
	if (n.item(0).hasChildNodes) then
		propvalue(iRow, iLens) = "{"
		iNum = n.item(0).FirstChild.ChildNodes.Length
		i = 1
		strType = n.item(0).attributes.getNamedItem("TYPE").nodeValue
		For each child in n.item(0).FirstChild.ChildNodes
		    if (strType = "string") then
		        propvalue(iRow, iLens) = propvalue(iRow, iLens) & """" & child.nodeTypedValue & """"
		    elseif (strType = "char16") then
	        	propvalue(iRow, iLens) = propvalue(iRow, iLens) & "'" & child.nodeTypedValue & "'"
		    else
		        propvalue(iRow, iLens) = propvalue(iRow, iLens) & child.nodeTypedValue
		    end if
		    if (i <> iNum) then
           		propvalue(iRow, iLens) = propvalue(iRow, iLens) & ", "
		    end if
		    i = i + 1
		Next
		propvalue(iRow, iLens) = propvalue(iRow, iLens) & "}"
	end if
    ElseIf strcomp(n.item(0).NodeName,"Property.Reference",1) = 0 Then
	dim valref, node, hostnode, localnamespace, namespacenode, keybindings, keybinding
	for each valref in n.item(0).selectNodes("VALUE.REFERENCE")
		for each node in valref.selectNodes(".//NAMESPACEPATH")
			set hostnode = node.selectsinglenode("HOST")
			if not hostnode is nothing then
				propvalue(irow, ilens) = "\\" & hostnode.text
			end if
			set localnamespace = node.selectsinglenode("LOCALNAMESPACEPATH")
			if not localnamespace is nothing then
				for each namespacenode in localnamespace.selectnodes("NAMESPACE")
					propvalue(irow,ilens) = propvalue(irow,ilens) & "\" & namespacenode.attributes.getNamedItem("NAME").nodeValue
				next
			end if
			propvalue(irow,ilens) = propvalue(irow,ilens) & ":"
		next
		for each node in valref.selectNodes(".//INSTANCENAME")
			propvalue(irow,ilens) = propvalue(irow,ilens) & node.attributes.getNamedItem("CLASSNAME").nodevalue
			set keybindings = node.selectnodes("KEYBINDING")
			i = 0
			for each keybinding in keybindings
				i = i + 1
				if (i = 1) then
					propvalue(irow,ilens) = propvalue(irow,ilens) & "." 
				end if
				propvalue(irow,ilens) = propvalue(irow,ilens) & keybinding.attributes.getnameditem("NAME").nodeValue & "=""" & _
					keybinding.selectsinglenode("KEYVALUE").text & """"
				if (i <> keybindings.length) then
					propvalue(irow,ilens) = propvalue(irow,ilens) & ","
				end if
			next
		next
	next		
    Else
	propvalue(iRow, iLens) = replace(replace(n.item(0).nodeTypedValue, vbCr, ""), vbLF, "")
    End If
    iLens = iLens + 1
    GetValues = ""
End Function
Function DisplayValues(n)
    Dim sT
    Dim sV
    Dim i
    Dim j
    Dim k
    'Determine the column widths
    'look at the column headers first
    iLensMax = iLens
    iLens = 0
    iRow = iRow + 1
    i = 0
    While i < iLensMax
        k = getlength(propname(i))
        If k > lenarr(i) Then
            lenarr(i) = k
        End If
        i = i + 1
    Wend
    'look at the values
    i = 0
    While i < iRow
        j = 0
        While j < iLensMax
            k = getlength(propvalue(i, j))
            If k > lenarr(j) Then
                lenarr(j) = k
            End If
            j = j + 1
        Wend
        i = i + 1
    Wend
    'set up the column headers
    i = 0
    While i < iLensMax
        j = lenarr(i) - getlength(propname(i))
        sT = sT & propname(i) & PadIt(j)
        i = i + 1
    Wend
    i = 0
    While i < iRow
        j = 0
        While j < iLensMax
            k = lenarr(j) - getlength(propvalue(i, j))
	    if bN(j)= 1 then
                sV = sV & PadIt(k-2) & propvalue(i, j) & "  "
	    Else
                sV = sV & propvalue(i, j) & PadIt(k)
	    End If
            j = j + 1
        Wend
        sV = sV & vbCrLf
        i = i + 1
    Wend
    DisplayValues = sT & vbCrLf & sV
End Function
Function GetLength(str)
	Dim i, ch
	'we have to manually compute length
	GetLength = 0
	For i = 1 to len(str)
		ch = ascw(mid(str,i,1))
		if (ch > 255) or (ch < 0) then
			GetLength = GetLength + 2	'assume two byte spaces
		else
			GetLength = GetLength + 1
		end if
	Next
End Function

  ]]></ms:script>
<xsl:template match="/"><xsl:apply-templates select="//RESULTS"/><xsl:apply-templates select="//INSTANCE"/><xsl:value-of select="user:DisplayValues(.)"/></xsl:template>
<xsl:template match="RESULTS"><xsl:value-of select="user:CountResults(.)"/></xsl:template>
<xsl:template match="INSTANCE"><xsl:value-of select="user:GotInstance()"/><xsl:apply-templates select="PROPERTY|PROPERTY.ARRAY|PROPERTY.REFERENCE"/></xsl:template>
<xsl:template match="PROPERTY|PROPERTY.ARRAY|PROPERTY.REFERENCE"><xsl:value-of select="user:GetValues(.)"/></xsl:template>
</xsl:stylesheet>
