<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:user="urn:my-scripts">
    <xsl:output method="html" indent="no"  encoding="UTF-8" />
    <xsl:param name="muiFolder"/>
    <xsl:param name="strings" select="document(concat($muiFolder,'\dfsrPropagationStrings.xml'))/child::node()" />
    <xsl:param name="strData" select="$strings/strings/string" />
    <xsl:param name="testFileReports" select="/child::node()/Reports/ReportTestFile" />
    <xsl:param name="reportCount" select="count($testFileReports)" />
    <xsl:param name="report" select="/child::node()" />
    <xsl:param name="timezone" select="$report/Details/timestamp/@timezone" />
    <xsl:param name="testcountcomplete">
        <xsl:call-template name="countTests">
            <xsl:with-param name="nodes" select="$testFileReports" />
            <xsl:with-param name="pos" select="1" />
            <xsl:with-param name="type" select="'complete'" />
            <xsl:with-param name="count" select="0" />
        </xsl:call-template>
    </xsl:param>
    <xsl:param name="testcountincomplete">
        <xsl:call-template name="countTests">
            <xsl:with-param name="nodes" select="$testFileReports" />
            <xsl:with-param name="pos" select="1" />
            <xsl:with-param name="type" select="'incomplete'" />
            <xsl:with-param name="count" select="0" />
        </xsl:call-template>
    </xsl:param>
    <xsl:param name="testcounterror">
        <xsl:call-template name="countTests">
            <xsl:with-param name="nodes" select="$testFileReports" />
            <xsl:with-param name="pos" select="1" />
            <xsl:with-param name="type" select="'error'" />
            <xsl:with-param name="count" select="0" />
        </xsl:call-template>
    </xsl:param>
    <msxsl:script language="JavaScript" implements-prefix="user">
        <![CDATA[
    function GetMaxTimeForPercentageSet(startTime, nsUpdateTimes, nsStatus, nsPercentages) {
        // I don't understand yet the syntax for passing in the array of percentages and what appears to
        // return one number.  Is some data getting chnaged which is making GetMaxTimeForPercentage return
        // null?
        var createDate = parseInt(startTime);
        var avg = null;
        var per = new Array();
        var total = nsPercentages.length - 1;
        for (var i = 0; i < nsPercentages.length; i++)
            per[total - i] = parseInt(nsPercentages[i].text);

        var t = 0;
        while (avg == null && t < per.length) {
            avg = _GetMaxTimeForPercentage(createDate, nsUpdateTimes, nsStatus, per[t]);
            t++;
        }
        if (avg == null)
            return(0);
        else
            return(createDate + avg);
    }

    function DisplayMaxTimeForPercentage(startTime, nsUpdateTimes, nsStatus, percentage) {
        var createDate = parseInt(startTime);
        var avg = _GetMaxTimeForPercentage(createDate, nsUpdateTimes, nsStatus, percentage);
        if (avg == null)
            return(0);
        else
            return(createDate + avg);
    }

    function max(a, b) {
        if(a==NaN || b==NaN)
          return NaN;
        
        if(a < b)
          return b;
        else
          return a;
    }

    function _ComputeDifferences(date, nsUpdateTimes) {
        if (nsUpdateTimes == null) return(0);
        var o = new Array();
        for (var i = 0; i < nsUpdateTimes.length; i++) {
            var d = parseInt(nsUpdateTimes[i].text);
            o[i] = d == null ? null : d - date;
        }
        return(o);
    }

    function _GetMaxTimeForPercentage(date, nsUpdateTimes, nsStatus, percentage) {
        var diffs = _ComputeDifferences(date, nsUpdateTimes);
        var arrived = new Array();
        for (var i = 0; i < nsStatus.length; i++)
            arrived[i] = (nsStatus[i].text == '0') ? true : false;
        var valid = 0;
        for (var i = 0; i < diffs.length; i++)
            if (diffs[i] != null && arrived[i] == true) valid++;
        if (valid / diffs.length < percentage / 100)
            return(null);

        // Need to sort the values first and then extract the right percentage
        var sortedDiffs = new Array();
        for (var i = 0; i < diffs.length; i++)
            if (diffs[i] != null && arrived[i] == true) {
                if (sortedDiffs.length == 0)
                    sortedDiffs.push(diffs[i]);
                else {
                    // TODO:  Review sorting logic
                    var spliced = false;
                    for (var j = 0; j < sortedDiffs.length && spliced == false; j++) {
                        if (sortedDiffs[j] >= diffs[i]) {
                            sortedDiffs.splice(j, 0, diffs[i]);
                            spliced = true;
                        }
                    }
                    if (!spliced)
                        sortedDiffs.push(diffs[i]);
                }
            }
        // Next, get only the needed values
        var num = Math.ceil(percentage / 100 * diffs.length);
        // if (num >= 0) num = 1;
        var total = 0;
        return(sortedDiffs[num - 1]);
    }

    ]]>
    </msxsl:script>
    <xsl:template match="/">
      <xsl:comment> saved from url=(0014)about:internet </xsl:comment>
      <xsl:text>&#13;&#10;</xsl:text>
      <html>
            <head>
                <title>
                    <xsl:value-of select="$strData[@id='titlebar']" />
                </title>
                <style type="text/css">
                    body    { background-color:#FFFFFF; border:1px solid#buttonshadow; color:windowframe; font-size:68%; font-family:Tahoma; margin:10,10,10px,10; word-break:normal; word-wrap:break-word; }

                    table   { table-layout:fixed; width:100%; font-size:100%; font-family:Tahoma; }

                    td,th   { overflow:visible; text-align:left; vertical-align:top; text-indent: 0pt; white-space:normal; padding: 3px;  }

                    .center  { text-align:left; }
                    .right  { text-align:left; }

                    .report  { border:none; color:buttonshadow; display:block; margin:-18px,0px,-1px,0px; position:relative; table-layout:fixed; width:100%; z-index:5; }

                    .he0_expanded    { background-color:background; border-top-width: 1px; border-top-style: solid; border-top-color: #ffffff; color:#FFFFFF; display:block; font-weight:bold; margin-bottom:0px; margin-left:0px; margin-right:0px; padding-left:3px; padding-right:5em; padding-top:0px; padding-bottom:4px; position:relative; width:100%; height:28px;}

                    <!--
                        .he0    { background-color:background; border-top-width: 1px; border-top-style: solid; border-top-color: #ffffff; color:#FFFFFF; cursor:hand; display:block; font-weight:bold; margin-bottom:0px; margin-left:0px; margin-right:0px; padding-left:3px; padding-right:5em; padding-top:0px; padding-bottom:4px; position:relative; width:100%; height:28px;}
                        .he1_expanded    { background-color:buttonshadow; border:1px solid #inactiveborder; border-color:#FFFFFF,inactiveborder,#FFFFFF,inactiveborder ; cursor:hand; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:0px; padding-right:5em; padding-top:4px; position:relative; width:100%; } 
                    -->

                    .he1    { background-color:appworkspace; border-top:1px solid inactiveborder; border-right:1px solid background; border-bottom:1px solid inactiveborder; border-left:1px solid background; color:#FFFFFF; display:block;font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:0px; padding-right:5em; padding-top:4px; position:relative; width:100%; }

                    <!--
                        .he2    { background-color:#FFFFFF; border-bottom-width: 0px; border-bottom-style: solid; border-bottom-color: buttonshadow; border-top-width: 1px; border-top-style: solid; border-top-color: buttonshadow; color:#000000; cursor:hand; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:26px; margin-right:10px; padding-left:0px; padding-top:4px; text-indent: 0pt; position:relative; width:100%; } 
                    -->

                    .he2_expanded    {  border-bottom-width: 0px; border-bottom-style: solid; border-bottom-color: buttonshadow; border-top-width: 1px; border-top-style: solid; border-top-color: buttonshadow; color:#000000; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:-2px; margin-right:10px; padding-left:0px; padding-top:4px; text-indent: 0pt; position:relative; width:100%; }

                    <!--
                        .he3    { background-color:#ffffff; border:1px solid buttonshadow; color:#000000; cursor:hand; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; text-indent: 30pt; position:relative; width:100%; } 
                        .he4    { background-color:#ffffff; border:1px solid buttonshadow; color:#000000; cursor:hand; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:11px; padding-right:5em; padding-top:4px; text-indent: 40pt; position:relative; width:100%; }
                    -->

                    .he4h   {; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:15px; margin-right:0px; padding-left:2px; padding-right:5em; padding-top:4px; text-indent: 0pt; position:relative; width:100%; }

                    .he4i   { border:1px solid background; color:#000000; display:block; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-bottom:5px; padding-left:0px; padding-top:0px; text-indent: 30pt; position:relative; width:100%; }

                    .he4i2   { border:0px solid buttonshadow; color:#000000; display:block; margin-bottom:-1px; margin-left:20px; margin-right:10px; padding-bottom:5px; padding-left:0px; padding-top:0px; text-indent: 0pt; position:relative; width:100%; }

                    .he4i3   { border-top:1px solid buttonshadow; border-right:1px solid background; border-bottom:1px solid background; border-left:1px solid background; color:#000000; display:block; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-bottom:5px; padding-left:46px; padding-top:0px; text-indent: 0pt; position:relative; width:100%; }

                    .he4i4   { border:0px solid buttonshadow; color:#000000; display:block; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-bottom:5px; padding-left:38px; padding-top:0px; text-indent: 0pt; position:relative; width:100%; }

                    .he4i4b  {  border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; color:#000000; display:block; font-weight:bold; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-bottom:5px; padding-left:40px; padding-top:0px; text-indent: 0pt; position:relative; width:100%; }

                    <!--
                        .he5    {  border:0px solid buttonshadow; color:#000000; cursor:hand; display:block; font-weight:bold; height:2.25em; margin-bottom:-1px; margin-left:10px; margin-right:0px; padding-left:0px; padding-right:5em; padding-top:4px; position:relative; width:100%; }
                        .he5h   {  border:0px solid buttonshadow; color:#000000; cursor:hand; display:block; padding-left:20px; padding-right:5em; padding-top:4px; margin-bottom:-1px; margin-left:0px; margin-right:0px; position:relative; width:100%; } 
                    -->

                    .he5i   { border:0px solid #inactiveborder; color:#000000; display:block; margin-bottom:-1px; margin-left:0px; margin-right:0px; padding-left:0px; padding-bottom:5px; padding-top: 4px; position:relative; width:100%; }

                    .he5ib   {  border:0px solid buttonshadow; color:#000000; display:block; font-weight:bold; margin-bottom:-1px; margin-left:-27px; margin-right:0px; padding-left:0px; padding-bottom:5px; padding-top: 4px; position:relative; width:100%; }

                    DIV .expando  { display:block; font-weight:normal; margin-left:5px; margin-top:6px; z-index: 0; }

                    DIV .expando2 { display:block; font-weight:normal; margin-left:29px; margin-top:4px; z-index: 0; }

                    DIV .expando3 { display:block; font-weight:normal; margin-left:5px; z-index: 0; }

                    DIV .expando4 { display:block; font-weight:normal; position:absolute; left:12px; vertical-align:middle;  z-index: 0; }

                    .showhide  { color:appworkspace; display:block; font-weight:normal; position:absolute; right:20px; top:30px; z-index: 1000; }
                    .showhide2  { color:inactiveborder; display:block; font-weight:normal; position:absolute; right:5px; margin-top:-12px; z-index:0; }
                    .loading  { color:background; display:block; font-weight:bold; margin-top:20px; z-index: 1000; }

                    .msgtbl  { line-height:1em; padding:0px,0px,0px,0px; margin:0px,0px,0px,0px; }

                    .info, .info3, .info4, .info5, .info6, { border:1px solid inactiveborder; color:#000000; display:block; line-height:1.6em; padding:5px; margin:0px,0px,0px,0px; }

                    .warnings  { margin:0px,0px,0px,0px; }

                    .unavailableservers  { margin:0px,0px,0px,0px; }

                    .servertestDetails  { margin:0px,0px,0px,0px; border-left-width: 1px; border-left-style: solid; border-left-color: background; border-right-width: 1px; border-right-style: solid; border-right-color: background; }

                    tr.info                 { padding:0px; }

                    .info TD                      { font-weight:normal; border:1px solid inactiveborder; padding-left:10px; padding-right:10px; }

                    .info3 TD                      { font-weight:normal; border:1px solid inactiveborder; padding-left:10px; padding-right:10px; width:33%; }

                    .info4 TD                           { font-weight:normal; border:1px solid inactiveborder; padding-left:10px; padding-right:10px; width:25%; }

                    .info5 TD                      { font-weight:normal; border:1px solid inactiveborder; padding-left:10px; padding-right:10px; width:20%; }

                    .info6 TD                      { font-weight:normal; border:1px solid inactiveborder; padding-left:10px; padding-right:10px; width:16%; }

                    td.tblwhiteleft   { background-color:inactiveborder; border-left-width: 1px; border-left-style: solid; border-left-color: inactiveborder; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; border-right-width: 1px; border-right-style: solid; border-right-color: #ffffff; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: inactiveborder; color:#000000; display:block; padding-left:10px; padding-right:10px; text-align:left; }

                    td.tblwhiteright  { background-color:inactiveborder; border-left-width: 1px; border-left-style: solid; border-left-color: #ffffff; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; border-right-width: 1px; border-right-style: solid; border-right-color: inactiveborder; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: inactiveborder; color:#000000; display:block; padding-left:10px; padding-right:10px; text-align:left; }

                    td.tblwhiteboth   { background-color:inactiveborder; border-left-width: 1px; border-left-style: solid; border-left-color: #ffffff; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; border-right-width: 1px; border-right-style: solid; border-right-color: #ffffff; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: inactiveborder; color:#000000; display:block; padding-left:10px; padding-right:10px; text-align:left; }

                    .container { display:block; position:relative; }

                    .reportheader { background-color:#ffffff; border-bottom:0px solid black; color:background; font-size:24pt; font-weight:bold; padding-bottom:2px; text-align:left; }

                    .reporttestDetails { background-color:#ffffff; border-bottom:0px solid black; color:#000000; font-weight:bold; padding-bottom:2px; text-align:left; }

                    td.topline  {  text-align: left; padding: 2px; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; position: relative;  }

                    <!--
                        td.firsttopline  {  margin-left:-20px; text-align: left; padding: 2px; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; position: relative;  } 
                    -->

                  td.toplinenarrow  {  width: 175px; text-align: left; padding: 2px; border-top-width: 1px; border-top-style: solid; border-top-color: inactiveborder; position: relative;  }

                  td.line  {  color: #000000; text-align: left; padding-left:9px; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: inactiveborder; position: relative;  }

                  <!-- 
                        td.linedark  {  text-align: left; padding-left:9px; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: buttonshadow; position: relative;  } 
                    -->

                    td.linenarrow   {  width: 175px; text-align: left; padding-left:9px; border-bottom-width: 1px; border-bottom-style: solid; border-bottom-color: inactiveborder; position: relative;  }

                    td.nolinenarrow  {  width: 175px; text-align: left; padding-left:9px;  position: relative;  }

                    .narrow {  width: 125px;  }

                    .error {  text-indent: 0px; padding-left:12px;  }

                    .server {  text-indent: 2pt; padding-left:24px; position:absolute: left:0px; font-weight:bold; }

                    v\:* {behavior:url(#default#VML);}

                    .er1    { width:14px;height:14px;font-size:1%; position: relative; top: 3px; }
                    .er1a    { width:14px;height:14px;font-size:1%; position: relative; top: 0px; }
                    .er2    { width:20px;height:20px;font-size:1%; position: relative; top: 6px; margin-top:-2px;}

                    .wa1    { width:16px;height:16px;font-size:1%; position: relative; top: 2px; }
                    <!--
                        .wa1a    { width:16px;height:16px;font-size:1%; position: relative; top: 0px; } 
                    -->
                    .wa2    { width:20px;height:20px;font-size:1%; position: relative; top: 4px; margin-top:-2px;}

                    <!--
                        .in1    { width:14px;height:14px;font-size:1%; position: relative; top: 2px; }
                        .in1a    { width:14px;height:14px;font-size:1%; position: relative; top: 0px; }
                        .in2    { width:18px;height:18px;font-size:1%; position: relative; top: 2px; }
                        .icon1    { width:14px;height:14px;font-size:1%; position: relative; top: 2px; }
                        .icon2    { width:18px;height:18px;font-size:1%; position: relative; top: 2px; } 
                    -->

                    .pm1    { width:12px;height:12px;}

                    .sectionTitle {position:absolute; top:0px; left:0px; margin-left:30px;}
                    .sectionTitle2 {position:absolute; top:4px; left:0px; margin-left:50px;}
                    .sectionTitle3 {position:absolute; top:4px; left:0px; margin-left:25px;}

                    .normal { font-weight:normal; text-decoration:none; color:#000000; }
                    .normal2{ font-weight:normal; text-decoration:none; color:appworkspace; }

                    .infobar {font: bold 16px verdana; color: #000000; background-color: #ffcc00; border: 2px solid #ffaa00; padding: 4px;}
                </style>
                <!-- Javascript starts here -->
                <script type="text/javascript" language="javascript">
                    <xsl:text>&#60;!--</xsl:text>
                    <!-- Set Globals -->
                    var initialized=false;
                    var srcObj, targetObj, tid, tid2, locate, pmNodeSet, showHideNodeSet;
                    var IE = (document.all) ? true : false;
                    var show='#Plus';
                    var hide='#Minus';

                    <!-- init() from onload event of body -->
                    function init(){
                    initialized=true;
                    getObj('infobar').innerHTML = '';                 // hide infobar message
                    getObj('infobar').style.display='none';

                    getObj('showhideall').innerHTML='<xsl:value-of select="$strData[@id='showall']" />';         // display Show All text at top of doc
                    getObj('message').style.display='none';                 // hide report loading message
                    getObj('main').style.display='block';                         // show main body of report
                    document.body.style.cursor='auto';                          // change wait cursor
                    }

                    <!-- Changes the +/- icons for a nodeset passed from other functions-->
                    function procAllPlusMinus(nodeSet, val) {
                    var sign='Plus';
                    if(!val) val=show;
                    if(val == hide) sign='Minus';
                    var i=0;
                    for( i=0; i &#60; nodeSet.length; i++) {
                    nodeSet[i].setAttribute('sign',sign);
                    nodeSet[i].childNodes[0].src=val;
                    }
                    }

                    <!-- Removes hilighting for link roll overs  (onmouseout event)-->
                    function unhilite(obj, color){
                    if(!color)color='background';
                    obj.style.color='';
                    obj.style.textDecoration='none';
                    obj.style.cursor='auto';
                    }

                    <!-- Provides hilighting for link roll overs (onmouseover event)-->
                    function hilite(obj, color){
                    if(!initialized){event.cancelBubble=true;  return;}                  // prevent hilite function from running when onclick functions are runnning
                    if(!color)color='background';
                    obj.style.color=color;
                    obj.style.textDecoration='underline';
                    obj.style.cursor='hand';
                    }

                    <!-- Switches the +/- icon for passed object containing a plusminus child -->
                    <!-- Called by doShowError, showInfo, and by onlcick event of container divs in  HTML-->
                    function switchSign(obj){
                    var i=0;
                    for( i=0; i &lt; obj.length; i++) {
                    if (obj[i].id=='plusminus') {
                    if(obj[i].childNodes[0].src.indexOf('#Plu')>=0){
                    obj[i].childNodes[0].src=hide;
                    }
                    else{
                    obj[i].childNodes[0].src=show;
                    }
                    }
                    }
                    }

                    <!-- Called by onclick event  in id=showhidesection  elements to expand or collapse a section with Show All /  Hide All-->
                    <!-- Note: These elements are inserted by showHideSectionCode template in XSLT -->
                    function showHideSection(obj, showBlock){
                    if(!initialized){event.cancelBubble=true;  return;}
                    event.cancelBubble=true;                                  // Cancel onclick event propagation to enclosing elements with onclick events
                    initialized=false;                                                // Set busy flag
                    obj.style.cursor='wait';                                    // Set wait cursors
                    document.body.style.cursor='wait';
                    showBlock=getObj(showBlock);                    //  Get element corresponding to passed id val
                    if(showBlock.id=='testDetails'){                            // If we're expanding  testDetails, first hide it to improve redraw performance
                    if(obj.innerHTML=='(Show All)'){
                    if(showBlock.style.display=='block'){
                    showBlock.style.display='none';
                    message2.style.display='block';
                    }
                    }
                    }
                    showHideNodeSet=showBlock.all.namedItem('showhidesection');                    // set global to contain plusminus child nodes of showBlock
                    targetObj=showBlock.parentNode.all.tags('div');                                                // set gloabl to contain all the container divs of parent node
                    srcObj=obj;                // set global to event source obj used later for resetting the cursor
                    pmNodeSet=showBlock.parentNode.all.namedItem('plusminus');                        // set global to collection of +/- nodes in enclosing div
                    tid=setTimeout('showHideAllContinue()', 250);                                                    // set timeout to allow for cursor change (this value may be high)
                    }

                    <!-- Similar to showHideSection but for the whole documentl -->
                    function showHideAll(obj){
                    if(!initialized){event.cancelBubble=true;  return;}
                    initialized=false;
                    document.body.style.cursor='wait';
                    obj.style.cursor='wait';
                    pmNodeSet=document.getElementsByName('plusminus');        // get all the +/- elements in the document
                    showHideNodeSet=document.getElementsByName('showhidesection');        // get all the Show All / Hide All elements
                    srcObj=obj;
                    targetObj=document.getElementsByTagName('div');
                    tid=setTimeout('showHideAllContinue()', 250);
                    }

                    <!-- This gets called from timeouts in showHideSection and showHideAll -->
                    function showHideAllContinue(){
                    obj=srcObj;
                    if(obj.innerHTML=='(Show All)'){            // If Show All, change to Hide All and set +/- to -
                    style='block';
                    obj.innerHTML='(Hide All)';
                    if(showHideNodeSet){
                    var i;
                    for(i=0; i &lt; showHideNodeSet.length; i++){
                    showHideNodeSet[i].innerHTML='(Hide All)';
                    }
                    }
                    procAllPlusMinus(pmNodeSet, hide);
                    }
                    else {                                                        // Must be Hide All so change to Hide All and set +/- to -
                    style='none';
                    obj.innerHTML='(Show All)';
                    if(showHideNodeSet){
                    var i;
                    for(i=0; i &lt; showHideNodeSet.length; i++){
                    showHideNodeSet[i].innerHTML='(Show All)';
                    }
                    }
                    procAllPlusMinus(pmNodeSet);
                    }
                    showHide(targetObj, style);                    //  Show or hide all the class="container" divs in the global nodeSet
                    pmNodeSet=null;                                        // clear the globals
                    showHideNodeSet=null;
                    message2.style.display='none';                // ide the message if showing
                    document.body.style.cursor='auto';         // reset the cursors
                    obj.style.cursor='auto';
                    initialized=true;                // reset the busy flag
                    clearTimeout(tid);            // clear the timeout
                    }

                    <!-- called from showHideAllContinue. Shows or hides class="container" divs in passed collection -->
                    function showHide(obj, style){
                    if(!style) style='none';
                    var i=0;
                    for( i=0; i &lt; obj.length; i++) {
                    if (obj[i].className=='container') {
                    obj[i].style.display=style;
                    }
                    }
                    }

                    <!-- Jump to an error or warning in server section from listing in errors, warnings, or unavailable servers -->
                    function doShowError(obj, str, loc){
                    if(!initialized){event.cancelBubble=true;  return;}
                    obj2=getObj(obj+str);                    // get the enclosing section (errors or warnings) that we want to jump to
                    if(obj2.style.display=='none') {    // if it's not showing, show it and change the +/- to -
                    obj2.style.display='block';
                    switchSign(obj2.previousSibling.childNodes);
                    }
                    doShowInfo(obj, loc);                    // Make sure the server info block is displayed and go to the location
                    }

                    <!-- Shows the server info bloack for a given server id -->
                    function doShowInfo(obj, loc){
                    if(!initialized){event.cancelBubble=true;  return;}
                    initialized=false;
                    event.cancelBubble=true;        // stop propagation of onclick event to enclosing div
                    locate=loc;                                // global to hold the target window location
                    obj=getObj(obj);                        // get the object with id=obj
                    srcObj=event.srcElement;        // set global to event source
                    srcObj.style.cursor='wait';            // set the wait cursors
                    document.body.style.cursor='wait';
                    tid=setTimeout('showInfo()', 250);            // timeout to activate cursors
                    }

                    <!-- called from timeout in doShowInfo. Displays server info block if hidden -->
                    function showInfo() {
                    initialized=false;
                    var obj2=document.getElementById('testDetails');
                    if(obj2.style.display=='none') {   // change the sign on the +/- of server info block
                    obj2.style.display='block';
                    switchSign(obj2.parentNode.childNodes);
                    }
                    if(obj.style.display=='none') {            // show appropriate error or warning block and switch the +/- sign
                    obj.style.display='block';
                    switchSign(obj.previousSibling.childNodes);
                    }
                    if (locate) {
                    if(tid2) clearTimeout(tid2);                // if we set this timeout previously, clear it
                    locate='#'+locate;
                    tid2=setTimeout('window.location=locate', 250);        // set a timeout before calling window.location
                    }
                    resetCursors();                                    // reset the wait cursors
                    if(tid) clearTimeout(tid);                        // clear timeout
                    //if(tid2) clearTimeout(tid2);
                    initialized=true;                                    // reset busy flag
                    }

                    <!-- shows or hides an individual class="container" div. Called from the onclick event of the header div -->
                    function doShowBlock(objID){
                    if(!initialized){event.cancelBubble=true;  return;}
                    initialized=false;                                                        // set busy flag
                    var obj=getObj(objID);                                                // get obj to show/hide from passed id value
                    srcObj=event.srcElement.parentElement;                //pass the parent element to the global to reset cursor
                    srcObj.style.cursor='wait';                                        // set wait cursors
                    document.body.style.cursor='wait';
                    tid = setTimeout('showBlock(this.obj)', 250);            // set timeout for wait cursor to activate
                    }

                    <!-- called in timeout from doShowBlock -->
                    function showBlock(obj){
                    if(obj.style.display=='none') obj.style.display='block';           // if obj is hidden, display it
                    else  obj.style.display='none';                                                // else hide it
                    document.body.style.cursor='auto';                                    // reset cursors
                    srcObj.style.cursor='hand';
                    clearTimeout(tid);                                                            // clear timeout
                    initialized=true;                                                                // reset busy flag
                    }

                    <!-- uses DOM method to get an object from its passed ID value -->
                    function getObj(objIdString){
                    obj = document.getElementById(objIdString);
                    return obj;
                    }

                    <!-- reset cursors on document body and obj contained in global-->
                    function resetCursors(){
                    document.body.style.cursor='auto';
                    srcObj.style.cursor='hand';
                    if(tid) clearTimeout(tid);
                    }

                    <!-- Like hilite, but only changes the cursor for mouseover and mouseout events on clickable headers -->
                    function pointer(obj, cursor){
                    if(!initialized){event.cancelBubble=true;  return;}
                    if(cursor) obj.style.cursor=cursor;
                    else obj.style.cursor='auto';
                    }

                    var errorNA = '<xsl:value-of select="$strData[@id='notapplicable']" />';
                    var strings = new Array();
                    strings['at'] = '<xsl:value-of select="$strData[@id='at']" />';
                    strings['day'] = '<xsl:value-of select="$strData[@id='day']" />';
                    strings['days'] = '<xsl:value-of select="$strData[@id='days']" />';
                    strings['hr'] = '<xsl:value-of select="$strData[@id='hr']" />';
                    strings['min'] = '<xsl:value-of select="$strData[@id='min']" />';
                    strings['sec'] = '<xsl:value-of select="$strData[@id='sec']" />';

                    function dateDiff(startDate, endDate) {
                    <!--if (1==1) return(endDate + '-' + startDate);-->
                    if (!startDate || ! endDate) return(errorNA);
                    if (endDate == 116444736000000000) return(errorNA);
                    if (startDate > endDate) return(0);
                    var s = new Date((startDate - 116444736000000000) / 10000);
                    var e = new Date((endDate - 116444736000000000) / 10000);
                    var d = new Date(e - s);
                    var days = d.getUTCDate() - 1;
                    var hours = d.getUTCHours();
                    var mins = d.getUTCMinutes();
                    var secs = d.getUTCSeconds();
                    var out = '';

                    if (days > 0 || hours > 0 || mins >= 15) {
                    // if(secs > 30) mins++; -- always show the floor
                    secs = 0;
                    }

                    if (days == 1) out += days + strings['day'] + ' ';
                    else if (days > 1) out += days + strings['days'] + ' ';
                    if (hours > 0) out += hours + strings['hr'] + ' ';
                    if (mins > 0) out += mins + strings['min'] + ' ';
                    if (secs > 0) out += secs + strings['sec'];

                    return(out);
                    }
                    
                    function showDateInOtherTimezone(dateval, offset) {
                    if (!dateval) return(errorNA);
                    var d = new Date((dateval - 116444736000000000) / 10000);
                    var d2 = new Date(d); //  + (offset * 60000));
                    return(d2.toLocaleDateString() + '<xsl:value-of select="$strData[@id='at']" />' + d2.toLocaleTimeString() + ' ' + showTimezone(offset));
                    }
                    
                    function showTimezone(offset) {
                    var tzHours = Math.floor(offset / 60);
                    var tzMinutes = Math.abs(offset - 60 * tzHours);
                    var str = (tzMinutes > 9) ? '' : '0';
                    return('<xsl:value-of select="$strData[@id='gmt']" />' + tzHours + ':' + str + tzMinutes + ')');
                    }
                    <xsl:text>--&#62;</xsl:text>
                </script>

                <!-- VML icons for this report -->
                <v:group id="Time" style="width:90px;height:90.05px;" coordorigin="1800,1440" coordsize="1800,1801">
                    <v:oval class="vmlimage" style="position:absolute;left:1800;top:1440;width:1799;height:1800" fillcolor="#cff" />
                    <v:oval class="vmlimage" style="position:absolute;left:1980;top:1620;width:1440;height:1440">
                        <v:stroke dashstyle="1 1" />
                    </v:oval>
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,1440" to="2701,1801" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,2880" to="2701,3241" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="1800,2340" to="2160,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="3240,2340" to="3600,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute" from="2160,1620" to="2700,2340" strokeweight="4px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x" from="2700,1980" to="2880,2340" strokeweight="4px" />
                </v:group>

                <v:group id="TimeGreen" style="width:90px;height:90.05px;" coordorigin="1800,1440" coordsize="1800,1801">
                    <v:oval class="vmlimage" style="position:absolute;left:1800;top:1440;width:1799;height:1800" fillcolor="#ccffcc" />
                    <v:oval class="vmlimage" style="position:absolute;left:1980;top:1620;width:1440;height:1440" fillcolor="#ccffcc">
                        <v:stroke dashstyle="1 1" />
                    </v:oval>
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,1440" to="2701,1801" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,2880" to="2701,3241" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="1800,2340" to="2160,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="3240,2340" to="3600,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute" from="2160,1620" to="2700,2340" strokeweight="4px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x" from="2700,1980" to="2880,2340" strokeweight="4px" />
                </v:group>

                <v:group id="TimeYellow" style="width:90px;height:90.05px;" coordorigin="1800,1440" coordsize="1800,1801">
                    <v:oval class="vmlimage" style="position:absolute;left:1800;top:1440;width:1799;height:1800" fillcolor="#ffffcc" />
                    <v:oval class="vmlimage" style="position:absolute;left:1980;top:1620;width:1440;height:1440" fillcolor="#ffffcc">
                        <v:stroke dashstyle="1 1" />
                    </v:oval>
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,1440" to="2701,1801" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,2880" to="2701,3241" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="1800,2340" to="2160,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="3240,2340" to="3600,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute" from="2160,1620" to="2700,2340" strokeweight="4px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x" from="2700,1980" to="2880,2340" strokeweight="4px" />
                </v:group>

                <v:group id="TimeRed" style="width:90px;height:90.05px;" coordorigin="1800,1440" coordsize="1800,1801">
                    <v:oval class="vmlimage" style="position:absolute;left:1800;top:1440;width:1799;height:1800" fillcolor="#ffcccc" />
                    <v:oval class="vmlimage" style="position:absolute;left:1980;top:1620;width:1440;height:1440" fillcolor="#ffcccc">
                        <v:stroke dashstyle="1 1" />
                    </v:oval>
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,1440" to="2701,1801" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:y" from="2700,2880" to="2701,3241" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="1800,2340" to="2160,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x y" from="3240,2340" to="3600,2341" strokeweight="2px" />
                    <v:line class="vmlimage" style="position:absolute" from="2160,1620" to="2700,2340" strokeweight="4px" />
                    <v:line class="vmlimage" style="position:absolute;flip:x" from="2700,1980" to="2880,2340" strokeweight="4px" />
                </v:group>

                <v:group id="Err1" style="width:12px;height:12px;vertical-align:middle" coordsize="100,100">
                    <v:oval class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="red" strokecolor="red"></v:oval>
                    <v:line class="vmlimage" style="z-index:1" from="25,25" to="75,75" strokecolor="white" strokeweight="2px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="75,25" to="25,75" strokecolor="white" strokeweight="2px"></v:line>
                </v:group>

                <v:group id="Err2" style="width:20px;height:20px;vertical-align:middle" coordsize="100,100">
                    <v:oval class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="red" strokecolor="red"></v:oval>
                    <v:line class="vmlimage" style="z-index:1" from="25,25" to="75,75" strokecolor="white" strokeweight="3px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="75,25" to="25,75" strokecolor="white" strokeweight="3px"></v:line>
                </v:group>

                <v:group id="UnAv1" class="vmlimage" style="width:12px;height:12px;vertical-align:middle" coordsize="100,100" alt="Unavailable Servers">
                    <v:oval class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="white" strokecolor="black"></v:oval>
                    <v:line class="vmlimage" style="z-index:1" from="50,15" to="50,65" strokecolor="red" strokeweight="3px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="25,60" to="75,60" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:3" from="30,65" to="70,65" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:4" from="35,70" to="65,70" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:5" from="40,75" to="60,75" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:6" from="45,80" to="55,80" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:7" from="50,85" to="50,85" strokecolor="red" strokeweight="1px"></v:line>
                </v:group>

                <v:group id="UnAv2" class="vmlimage" style="width:20px;height:20px;vertical-align:middle" coordsize="100,100" alt="Unavailable Servers">
                    <v:oval class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="white" strokecolor="black"></v:oval>
                    <v:line class="vmlimage" style="z-index:1" from="50,15" to="50,65" strokecolor="red" strokeweight="3px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="25,60" to="75,60" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:3" from="30,65" to="70,65" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:4" from="35,70" to="65,70" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:5" from="40,75" to="60,75" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:6" from="45,80" to="55,80" strokecolor="red" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:7" from="50,85" to="50,85" strokecolor="red" strokeweight="1px"></v:line>
                </v:group>

                <v:group id="Warn1" class="vmlimage" style="width:16px;height:16px;vertical-align:middle" coordsize="100,100" alt="Warning">
                    <v:polyline class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="yellow" strokecolor="black" points="0,100 50,0 100,100 0,100"></v:polyline>
                    <v:line class="vmlimage" style="z-index:1" from="50,30" to="50,70" strokecolor="black" strokeweight="2px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="50,75" to="50,85" strokecolor="black" strokeweight="2px"></v:line>
                </v:group>

                <v:group id="Warn2" class="vmlimage" style="width:24px;height:24px;vertical-align:middle" coordsize="100,100" alt="Warning">
                    <v:polyline class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="yellow" strokecolor="black" points="0,100 50,0 100,100 0,100"></v:polyline>
                    <v:line class="vmlimage" style="z-index:1" from="50,30" to="50,70" strokecolor="black" strokeweight="2px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="50,75" to="50,85" strokecolor="black" strokeweight="2px"></v:line>
                </v:group>

                <v:group id="NoErr" class="vmlimage" style="width:12px;height:12px;vertical-align:middle" coordsize="100,100" alt="Servers with no errors or warnings">
                    <v:oval class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="white" strokecolor="black"></v:oval>
                    <v:line class="vmlimage" style="z-index:1" from="25,50" to="50,80" strokecolor="green" strokeweight="2px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="50,80" to="80,25" strokecolor="green" strokeweight="2px"></v:line>
                </v:group>

                <v:group id="Details" class="vmlimage" style="width:20px;height:20px;vertical-align:middle;" coordsize="100,100" alt="Test Details">
                    <v:rect class="vmlimage" style="left:40px;width:40;height:95;z-index:0" fillcolor="#cccccc" strokecolor="black"></v:rect>
                    <v:line class="vmlimage" style="z-index:1" from="40,25" to="80,25" strokecolor="black" strokeweight="0px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="40,45" to="80,45" strokecolor="black" strokeweight="0px"></v:line>
                    <v:line class="vmlimage" style="z-index:3" from="87,5" to="87,100" strokecolor="#999999" strokeweight="3px"></v:line>
                    <v:line class="vmlimage" style="z-index:5" from="40,100" to="80,100" strokecolor="#cccccc" strokeweight="0px"></v:line>
                </v:group>

                <v:group id="Inf1" class="vmlimage" style="width:10px;height:10px;vertical-align:middle" coordsize="100,100" alt="Information">
                    <v:oval class="vmlimage" style='width:100;height:100;z-index:0' fillcolor="white" strokecolor="#336699"></v:oval>
                    <v:line class="vmlimage" style="z-index:1" from="50,15" to="50,25" strokecolor="#336699" strokeweight="3px"></v:line>
                    <v:line class="vmlimage" style="z-index:2" from="50,35" to="50,80" strokecolor="#336699" strokeweight="3px"></v:line>
                </v:group>

                <v:group id="Plus" class="vmlimage" style="width:15px;height:15px;vertical-align:middle;" coordsize="100,100" alt="Expand">
                    <v:rect class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="#ffffff" strokecolor="#666666"></v:rect>
                    <v:polyline class="vmlimage" style="z-index:1" fillcolor="#cccccc" strokecolor="none" points="90,10 90,90 10,90 30,80 70,50 90,10"></v:polyline>
                    <v:line class="vmlimage" style="z-index:2" from="0,0" to="0,100" strokecolor="black"></v:line>
                    <v:line class="vmlimage" style="z-index:3" from="25,50" to="75,50" strokecolor="black" strokeweight="1px"></v:line>
                    <v:line class="vmlimage" style="z-index:4" from="50,25" to="50,75" strokecolor="black" strokeweight="1px"></v:line>
                </v:group>

                <v:group id="Minus" class="vmlimage" style="width:15px;height:15px;vertical-align:middle;" coordsize="100,100" alt="Collapse">
                    <v:rect class="vmlimage" style="width:100;height:100;z-index:0" fillcolor="#ffffff" strokecolor="#666666"></v:rect>
                    <v:polyline class="vmlimage" style="z-index:1" fillcolor="#cccccc" strokecolor="none" points="10,90 10,10 90,10 40,30 30,60 10,90"></v:polyline>
                    <v:line class="vmlimage" style="z-index:2" from="0,0" to="0,100" strokecolor="black"></v:line>
                    <v:line class="vmlimage" style="z-index:3" from="25,50" to="75,50" strokecolor="black" strokeweight="1px"></v:line>
                </v:group>
                <!-- end VML icons for this report -->
                <xsl:call-template name="renderMembersToJS">
                    <xsl:with-param name="fileList" select="$testFileReports" />
                </xsl:call-template>
            </head>
            <body onload="init();" style="cursor:wait;">
                <div class="infobar" id="infobar">
                    <xsl:value-of select="$strData[@id='infobar']" />
                </div>
                <!-- Create report title -->
                <table cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <div class="reportheader">
                                <xsl:value-of select="$strData[@id='title']" />
                            </div>
                        </td>
                        <td>
                            <span id="showhideall" tabindex="0" onclick="showHideAll(this)" onmouseover="hilite(this)" onmouseout="unhilite(this)" class="showhide"></span>
                        </td>
                    </tr>
                </table>
                <!-- Create report header -->
                <xsl:variable name="firstReportFile">
                    <xsl:for-each select="$testFileReports">
                        <xsl:sort select="FileCreateTime/fileTime" order="descending" />
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="." />
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="firstReport" select="firstReportFile" />
                <table class="report" cellpadding="0" cellspacing="0" border="0">
                    <xsl:text>&#160;</xsl:text>
                    <tr>
                        <td class="toplinenarrow" height="4px">&#160;</td>
                        <td class="topline" height="4px">&#160;</td>
                    </tr>
                    <tr>
                        <td class="linenarrow">
                            <div class="reporttestDetails">
                                <xsl:value-of select="$strData[@id='reportgeneratedon']" />
                            </div>
                        </td>
                        <td class="line">
                            <script>
                                document.write(showDateInOtherTimezone('<xsl:value-of select="$report/Details/timestamp/fileTime" />', <xsl:value-of select="$timezone" />));
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="linenarrow">
                            <div class="reporttestDetails">
                                <xsl:value-of select="$strData[@id='replicationgroup']" />
                            </div>
                        </td>
                        <td class="line">
                            <xsl:value-of select="$report/Details/ReplicationGroupName" />
                        </td>
                    </tr>
                    <tr>
                        <td class="linenarrow">
                            <div class="reporttestDetails">
                                <xsl:value-of select="$strData[@id='replicatedfolder']" />
                            </div>
                        </td>
                        <td class="line">
                            <xsl:value-of select="$report/Details/ContentSetName" />
                        </td>
                    </tr>
                    <!--
                      - Remove the number of members from the transform, as it may not be consistent
                      - accross all tests.  
                        <tr>
                            <td class="linenarrow">
                                <div class="reporttestDetails">
                                    <xsl:value-of select="$strData[@id='nummembers']" />
                                </div>
                            </td>
                            <td class="line">
                                <xsl:value-of select="count($firstReport/Member[MemberDns != $firstReport/MemberDns])" />
                            </td>
                        </tr>
                        
                    -->
                    <tr>
                        <td class="linenarrow">
                            <div class="reporttestDetails">
                                <xsl:value-of select="$strData[@id='numtestsreported']" />
                            </div>
                        </td>
                        <td class="line">
                            <xsl:value-of select="count($testFileReports)" />
                        </td>
                    </tr>
                    <tr>
                        <td class="linenarrow">
                            <div class="reporttestDetails">
                                <xsl:value-of select="$strData[@id='avgreplicationtime']" />
                            </div>
                        </td>
                        <td class="line">
                            <script>document.write(dateDiff(116444736000000000, calculateGlobalAverage()));</script>
                        </td>
                    </tr>
                    <tr>
                        <td class="linenarrow">
                            <div class="reporttestDetails">
                                <xsl:value-of select="$strData[@id='maxreplicationtime']" />
                            </div>
                        </td>
                        <td class="line">
                            <script>document.write(dateDiff(116444736000000000, calculateGlobalMax()));</script>
                        </td>
                    </tr>
                    <td class="nolinenarrow">
                        <div class="reporttestDetails">
                            <xsl:value-of select="$strData[@id='testreportstatus']" />
                        </div>
                    </td>
                    <td>
                        <table cellpadding="0" cellspacing="0">
                            <tr>
                                <td width="50%">
                                    <v:vmlframe src="#TimeGreen" class="er1" />
                                    <xsl:text>&#160;</xsl:text>
                                    <span>
                                        <xsl:value-of select="$strData[@id='testscompleted']" />
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="$testcountcomplete" />
                                        <xsl:text>)</xsl:text>
                                    </span>
                                </td>
                                <td width="50%">
                                    <v:vmlframe src="#TimeYellow" class="er1" />
                                    <xsl:text>&#160;</xsl:text>
                                    <span>
                                        <xsl:value-of select="$strData[@id='testsincomplete']" />
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="$testcountincomplete" />
                                        <xsl:text>)</xsl:text>
                                    </span>
                                </td>
                                <td>&#160;</td>
                            </tr>
                            <tr>
                              <td>
                                <span>
                                  <v:vmlframe src="#TimeRed" class="er1" />
                                </span>
                                <xsl:text>&#160;</xsl:text>
                                <span>
                                  <xsl:value-of select="$strData[@id='testswitherrors']" />
                                  <xsl:text> (</xsl:text>
                                  <xsl:value-of select="$testcounterror" />
                                  <xsl:text>)</xsl:text>
                                </span>
                              </td>
                            </tr>
                            <xsl:if test="$testcounterror + $testcountincomplete + $testcountcomplete &gt; count($testFileReports)">
                              <tr>
                                <td colspan="2">
                                  <span>
                                    <v:vmlframe src="#Inf1" class="er1"/>
                                  </span>
                                  <xsl:text>&#160;</xsl:text>
                                  <xsl:value-of select="$strData[@id='errorAndIncomplete']"/>
                                </td>
                              </tr>
                            </xsl:if>
                        </table>
                    </td>
                    <tr>
                      <td height="4px">&#160;</td>
                      <td height="4px">&#160;</td>
                    </tr>
                </table>
                <div id="message" align="center">
                    <span class="loading">
                        <xsl:value-of select="$strData[@id='loading']" />
                    </span>
                </div>
                <!-- Start Complete Tests Section -->
                <xsl:comment>Complete Tests Section Start </xsl:comment>
                <!-- Create Complete Tests section header -->
                <div class="error">
                    <div class="he0_expanded">
                        <xsl:if test="$testcountcomplete&gt;0">
                            <!-- Only insert the onclick handler and +/- icon if there are tests to report -->
                            <xsl:attribute name="onmouseover">
                                <xsl:text>pointer(this, 'hand')</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onmouseout">
                                <xsl:text>pointer(this)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                            <xsl:attribute name="onclick">
                                <xsl:text>doShowBlock('testsComplete');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onkeypress">
                                <xsl:text>doShowBlock('testsComplete');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <span id="plusminus" class="expando" sign="plus">
                                <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                            </span>
                        </xsl:if>
                        <!-- indicate the # of tests -->
                        <span class="sectionTitle" tabindex="0">
                            <v:vmlframe src="#TimeGreen" class="er2" />  &#160;<xsl:value-of select="$strData[@id='completetestsheader']" /><xsl:text>&#160;(</xsl:text><xsl:value-of select="$testcountcomplete" /><xsl:value-of select="$strData[@id='completedtestcount']" /><xsl:text>)</xsl:text>
                        </span>
                    </div>
                    <xsl:if test="$testcountcomplete&gt;0">
                      <div id="main">
                        <div id="testsComplete" class="container" style="display:none;">
                          <div class="he4i">
                            <table class="msgtbl" cellpadding="0" cellspacing="0">
                              <xsl:for-each select="$testFileReports">
                                <xsl:sort select="FileCreateTime/fileTime" order="descending" />
                                <xsl:variable name="testinerror" select="./Error" />
                                <xsl:variable name="report" select="." />
                                <xsl:variable name="testcount" select="count($report/Member[Status != '0' and MemberDns != $report/MemberDns])" />
                                <xsl:if test="$testcount = 0 and not($testinerror)">
                                  <xsl:variable name="srvrID" select="concat('testDetails_', position())" />
                                  <tr>
                                    <td  class="line" width="15px">&#160;</td>
                                    <td  class="line" align="right" colspan="2">
                                      <div class="normal2" onmouseover="hilite(this)" onmouseout="unhilite(this)">
                                        <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                                        <xsl:attribute name="onclick">
                                          <xsl:text>doShowInfo('</xsl:text>
                                          <xsl:value-of select="$srvrID" />
                                          <xsl:text>', '</xsl:text>
                                          <xsl:value-of select="format-number(position(),'0000')" />
                                          <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="onkeypress">
                                          <xsl:text>doShowInfo('</xsl:text>
                                          <xsl:value-of select="$srvrID" />
                                          <xsl:text>', '</xsl:text>
                                          <xsl:value-of select="format-number(position(),'0000')" />
                                          <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="$strData[@id='testlaunched']" />
                                        <xsl:value-of select="$report/MemberDns" />
                                        <xsl:value-of select="$strData[@id='on']" />
                                        <script>
                                          document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                                        </script>
                                      </div>
                                    </td>
                                  </tr>
                                </xsl:if>
                              </xsl:for-each>
                            </table>
                          </div>
                          <xsl:comment>End Complete Tests Section </xsl:comment>
                          <!--End Complete Tests Section -->
                        </div>
                      </div>
                    </xsl:if>
                </div>
                <!-- Start Incomplete Tests Section -->
                <xsl:comment>Incomplete Tests Section Start </xsl:comment>
                <!-- Create Incomplete Tests section header -->
                <div class="error">
                    <div class="he0_expanded">
                        <xsl:if test="$testcountincomplete&gt;0">
                            <!-- Only insert the onclick handler and +/- icon if there are tests to report -->
                            <xsl:attribute name="onmouseover">
                                <xsl:text>pointer(this, 'hand')</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onmouseout">
                                <xsl:text>pointer(this)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                            <xsl:attribute name="onclick">
                                <xsl:text>doShowBlock('testsIncomplete');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onkeypress">
                                <xsl:text>doShowBlock('testsIncomplete');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <span id="plusminus" class="expando" sign="plus">
                                <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                            </span>
                        </xsl:if>
                        <!-- indicate the # of tests -->
                        <span class="sectionTitle" tabindex="0">
                            <v:vmlframe src="#TimeYellow" class="er2" />  &#160;<xsl:value-of select="$strData[@id='incompletetestsheader']" /><xsl:text>&#160;(</xsl:text><xsl:value-of select="$testcountincomplete" /><xsl:value-of select="$strData[@id='incompletetestcount']" /><xsl:text>)</xsl:text>
                        </span>
                    </div>
                    <xsl:if test="$testcountincomplete&gt;0">
                      <div id="main">
                        <div id="testsIncomplete" class="container" style="display:none;">
                          <div class="he4i">
                            <table class="msgtbl" cellpadding="0" cellspacing="0">
                              <xsl:for-each select="$testFileReports">
                                <xsl:sort select="FileCreateTime/fileTime" order="descending" />
                                <xsl:variable name="report" select="." />
                                <xsl:variable name="testinerror" select="./Error" />
                                <xsl:variable name="testcount" select="count($report/Member[Status = '1' and MemberDns != $report/MemberDns])" />
                                <xsl:if test="$testcount &gt; 0 and not($testinerror)">
                                  <xsl:variable name="srvrID" select="concat('testDetails_', position())" />
                                  <tr>
                                    <td  class="line" width="15px">&#160;</td>
                                    <td  class="line" align="right" colspan="2">
                                      <div class="normal2" onmouseover="hilite(this)" onmouseout="unhilite(this)">
                                        <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                                        <xsl:attribute name="onclick">
                                          <xsl:text>doShowInfo('</xsl:text>
                                          <xsl:value-of select="$srvrID" />
                                          <xsl:text>', '</xsl:text>
                                          <xsl:value-of select="format-number(position(),'0000')" />
                                          <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="onkeypress">
                                          <xsl:text>doShowInfo('</xsl:text>
                                          <xsl:value-of select="$srvrID" />
                                          <xsl:text>', '</xsl:text>
                                          <xsl:value-of select="format-number(position(),'0000')" />
                                          <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="$strData[@id='testlaunched']" />
                                        <xsl:value-of select="$report/MemberDns" />
                                        <xsl:value-of select="$strData[@id='on']" />
                                        <script>
                                          document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                                        </script>
                                      </div>
                                    </td>
                                  </tr>
                                </xsl:if>
                              </xsl:for-each>
                            </table>
                          </div>
                          <xsl:comment>End Incomplete Tests Section </xsl:comment>
                          <!--End Incomplete Tests Section -->
                        </div>
                      </div>
                    </xsl:if>
                </div>
                <!-- Start Error Tests Section -->
                <xsl:comment>Error Tests Section Start </xsl:comment>
                <!-- Create Error Tests section header -->
                <div class="error">
                    <div class="he0_expanded">
                        <xsl:if test="$testcounterror&gt;0">
                            <!-- Only insert the onclick handler and +/- icon if there are tests to report -->
                            <xsl:attribute name="onmouseover">
                                <xsl:text>pointer(this, 'hand')</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onmouseout">
                                <xsl:text>pointer(this)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                            <xsl:attribute name="onclick">
                                <xsl:text>doShowBlock('testsError');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onkeypress">
                                <xsl:text>doShowBlock('testsError');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <span id="plusminus" class="expando" sign="plus">
                                <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                            </span>
                        </xsl:if>
                        <!-- indicate the # of tests -->
                        <span class="sectionTitle" tabindex="0">
                            <v:vmlframe src="#TimeRed" class="er2" />  &#160;<xsl:value-of select="$strData[@id='errortestsheader']" /><xsl:text>&#160;(</xsl:text><xsl:value-of select="$testcounterror" /><xsl:value-of select="$strData[@id='errortestcount']" /><xsl:text>)</xsl:text>
                        </span>
                    </div>
                    <xsl:if test="$testcounterror&gt;0">
                      <div id="main">
                        <div id="testsError" class="container" style="display:none;">
                          <div class="he4i">
                            <table class="msgtbl" cellpadding="0" cellspacing="0">
                              <xsl:for-each select="$testFileReports">
                                <xsl:sort select="FileCreateTime/fileTime" order="descending" />
                                <xsl:variable name="thisreport" select="." />
                                <xsl:variable name="reporterrors">
                                  <xsl:choose>
                                    <xsl:when test="not(Error)">
                                      <xsl:value-of select="count(Member[(Status = '2') and (MemberDns!=$thisreport/MemberDns)])" />
                                    </xsl:when>
                                    <xsl:otherwise>0</xsl:otherwise>
                                  </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="err" select="." />
                                <xsl:variable name="testcount" select="count(Error) + number($reporterrors)" />
                                <xsl:if test="$testcount &gt; 0">
                                  <xsl:variable name="srvrID" select="concat('testDetails_', position())" />
                                  <tr>
                                    <td  class="line" width="15px">&#160;</td>
                                    <td  class="line" align="right" colspan="2">
                                      <div class="normal2" onmouseover="hilite(this)" onmouseout="unhilite(this)">
                                        <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                                        <xsl:attribute name="onclick">
                                          <xsl:text>doShowInfo('</xsl:text>
                                          <xsl:value-of select="$srvrID" />
                                          <xsl:text>', '</xsl:text>
                                          <xsl:value-of select="format-number(position(),'0000')" />
                                          <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="onkeypress">
                                          <xsl:text>doShowInfo('</xsl:text>
                                          <xsl:value-of select="$srvrID" />
                                          <xsl:text>', '</xsl:text>
                                          <xsl:value-of select="format-number(position(),'0000')" />
                                          <xsl:text>')</xsl:text>
                                        </xsl:attribute>
                                        <xsl:choose>
                                          <xsl:when test="not(Error)">
                                            <xsl:variable name="report" select="." />
                                            <xsl:value-of select="$strData[@id='testlaunched']" />
                                            <xsl:value-of select="$report/MemberDns" />
                                            <xsl:value-of select="$strData[@id='on']" />
                                            <script>
                                              document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                                            </script>
                                          </xsl:when>
                                          <xsl:otherwise>
                                            <xsl:value-of select="$strData[@id='errortitle']" /><xsl:value-of select="$err/FileName" /> (<xsl:value-of select="$err/ErrorMessage" />)
                                          </xsl:otherwise>
                                        </xsl:choose>
                                      </div>
                                    </td>
                                  </tr>
                                </xsl:if>
                              </xsl:for-each>
                            </table>
                          </div>
                          <xsl:comment>End Error Tests Section </xsl:comment>
                          <!--End Error Tests Section -->
                        </div>
                      </div>
                    </xsl:if>
                </div>

                <!-- Start Details Section -->
                <xsl:comment>Details Section Start </xsl:comment>
                <!-- Create Details section header -->
                <div class="error">
                    <div class="he0_expanded">
                        <xsl:if test="$reportCount&gt;0">
                            <!-- Only insert the onclick handler and +/- icon if there are errors to report -->
                            <xsl:attribute name="onmouseover">
                                <xsl:text>pointer(this, 'hand')</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onmouseout">
                                <xsl:text>pointer(this)</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                            <xsl:attribute name="onclick">
                                <xsl:text>doShowBlock('testDetails');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="onkeypress">
                                <xsl:text>doShowBlock('testDetails');switchSign(this.childNodes);</xsl:text>
                            </xsl:attribute>
                            <span id="plusminus" class="expando" sign="plus">
                                <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                            </span>
                        </xsl:if>
                        <!-- indicate the # of servers reporting errors -->
                        <span class="sectionTitle" tabindex="0">
                            <v:vmlframe src="#Details" class="er2" />  &#160;<xsl:value-of select="$strData[@id='detailsheader']" />
                            <xsl:text>&#160;&#160;(</xsl:text>
                            <xsl:value-of select="$reportCount" />
                            <xsl:choose>
                                <xsl:when test="$reportCount=1">
                                    <xsl:value-of select="$strData[@id='test']" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$strData[@id='tests']" />
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text>)</xsl:text>
                        </span>
                        <xsl:if test="$reportCount&gt;0">
                            <!-- Only insert Show All/hide All if there are errors to report -->
                            <xsl:call-template name="showHideSectionCode">
                                <xsl:with-param name="blockID">
                                    <xsl:text>'testDetails'</xsl:text>
                                </xsl:with-param>
                                <xsl:with-param name="hiliteColor">
                                    <xsl:text>'white'</xsl:text>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:if>
                    </div>

                    <!-- message2 div displays when doing a Show All on Server Info with testDetails block showing -->
                    <div id="message2" align="center" style="display:none;">
                        <span class="loading">
                            <xsl:value-of select="$strData[@id='loading']" />
                        </span>
                    </div>
                    <div id="main">
                        <div id="testDetails" class="container" style="display:none;">
                            <xsl:if test="$reportCount&gt;0">
                                <xsl:for-each select="$testFileReports">
                                    <xsl:sort select="FileCreateTime/fileTime" order="descending" />
                                    <xsl:variable name="srvrID" select="concat('testDetails_', position())" />
                                    <xsl:variable name="testDetails" select="." />
                                    <xsl:call-template name="renderDetails">
                                        <xsl:with-param name="report" select="$testDetails" />
                                        <xsl:with-param name="pos" select="position()" />
                                        <xsl:with-param name="srvrID" select="$srvrID" />
                                        <xsl:with-param name="rootnode" select="." />
                                    </xsl:call-template>
                                </xsl:for-each>
                            </xsl:if>
                            <xsl:comment>End Details Section </xsl:comment>
                            <!--End Details Section -->
                        </div>
                    </div>
                </div>

            </body>
        </html>
    </xsl:template>

    <!--Adds SPAN element and onclick, mouseover, mouseout handlers for section level Show All/Hide All. -->
    <xsl:template name="showHideSectionCode">
        <xsl:param name="blockID" />
        <xsl:param name="hiliteColor" />
        <div width="50px" class="showhide2">
            <span  id="showhidesection">
                <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                <xsl:attribute name="onclick">
                    <xsl:text>showHideSection(this, </xsl:text>
                    <xsl:value-of select="$blockID" />
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="onkeypress">
                    <xsl:text>showHideSection(this, </xsl:text>
                    <xsl:value-of select="$blockID" />
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="onmouseover">
                    <xsl:text>hilite(this, </xsl:text>
                    <xsl:value-of select="$hiliteColor" />
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="onmouseout">
                    <xsl:text>unhilite(this, </xsl:text>
                    <xsl:value-of select="$hiliteColor" />
                    <xsl:text>)</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$strData[@id='showall']" />
            </span>
            <!--(<xsl:value-of select="$blockID" />)-->
        </div>
    </xsl:template>

    <xsl:template name="renderDetails">
        <xsl:param name="report" />
        <xsl:param name="rootnode" />
        <xsl:param name="pos" />
        <xsl:param name="srvrID" />
        <xsl:variable name="testinerror" select="$rootnode/Error" />
        <xsl:variable name="countall" select="count($report/Member[MemberDns != $report/MemberDns])" />
        <xsl:variable name="countcomplete" select="count($report/Member[Status='0' and MemberDns != $report/MemberDns])" />
        <xsl:variable name="counterror" select="count($report/Member[Status='2' and MemberDns != $report/MemberDns])" />
        <xsl:variable name="countincomplete" select="$countall - $countcomplete - $counterror" />
        <div>
            <a>
                <xsl:attribute name="name">
                    <xsl:value-of select="format-number(position(),'0000')" />
                </xsl:attribute>
            </a>
            <!-- Header DIV for individual Server Information Block -->
            <div class="he1" onmouseover="pointer(this, 'hand')" onmouseout="pointer(this)">
                <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                <xsl:attribute name="onclick">
                    <xsl:text>doShowBlock('</xsl:text>
                    <xsl:value-of select="$srvrID" />
                    <xsl:text>');switchSign(this.childNodes);</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="onkeypress">
                    <xsl:text>doShowBlock('</xsl:text>
                    <xsl:value-of select="$srvrID" />
                    <xsl:text>');switchSign(this.childNodes);</xsl:text>
                </xsl:attribute>
                <span id="plusminus" class="expando2" sign="plus">
                    <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                </span>
                <span class="sectionTitle2" tabindex="0">
                    <xsl:choose>
                        <xsl:when test="$testinerror">
                            <v:vmlframe src="#TimeRed" class="er1" /><xsl:text>  &#160;</xsl:text><xsl:value-of select="$strData[@id='errortitle']" /><xsl:value-of select="$rootnode/FileName" /> (<xsl:value-of select="$rootnode/ErrorMessage" />)
                        </xsl:when>
                        <xsl:when test="$counterror &gt; 0">
                            <v:vmlframe src="#TimeRed" class="er1" />
                            <xsl:text>  &#160;</xsl:text>
                            <xsl:value-of select="$strData[@id='testlaunched']" />
                            <xsl:value-of select="$report/MemberDns" />
                            <xsl:value-of select="$strData[@id='on']" />
                            <script>
                              document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                            </script>
                        </xsl:when>
                        <xsl:when test="$countincomplete &gt; 0">
                            <v:vmlframe src="#TimeYellow" class="er1" />
                            <xsl:text>  &#160;</xsl:text>
                            <xsl:value-of select="$strData[@id='testlaunched']" />
                            <xsl:value-of select="$report/MemberDns" />
                            <xsl:value-of select="$strData[@id='on']" />
                            <script>
                              document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                            </script>
                        </xsl:when>
                        <xsl:otherwise>
                            <v:vmlframe src="#TimeGreen" class="er1" />
                            <xsl:text>  &#160;</xsl:text>
                            <xsl:value-of select="$strData[@id='testlaunched']" />
                            <xsl:value-of select="$report/MemberDns" />
                            <xsl:value-of select="$strData[@id='on']" />
                            <script>
                              document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                            </script>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:call-template name="showHideSectionCode">
                    <!-- Add Show All/Hide All functionality-->
                    <xsl:with-param name="blockID">
                        <xsl:text>'</xsl:text>
                        <xsl:value-of select="$srvrID" />
                        <xsl:text>'</xsl:text>
                    </xsl:with-param>
                    <xsl:with-param name="hiliteColor">
                        <xsl:text>'white'</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
            <!-- End header DIV for individual Server Information Block -->
            <!-- Start Server Overview DIV id="$srvrID"  -->
            <div class="container" style="display:none;" name="container">
                <xsl:attribute name="id">
                    <xsl:value-of select="$srvrID" />
                </xsl:attribute>
                <div class="he4i3">
                    <xsl:choose>
                        <xsl:when test="$testinerror">
                            <v:vmlframe src="#Err1" class="er1a" style="margin-top: 3px;" /> &#160; <xsl:value-of select="$strData[@id='testinerror']" />
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td class="toplinenarrow" height="4px">&#160;</td>
                                    <td class="topline" colspan="2" height="4px">&#160;</td>
                                </tr>
                                <tr>
                                    <td class="narrow">
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='testfile']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <xsl:value-of select="$rootnode/FileName" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="narrow">
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='errorcode']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <xsl:value-of select="$rootnode/Error" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="narrow">
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='errormessage']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <xsl:value-of select="$rootnode/ErrorMessage" />
                                    </td>
                                </tr>
                            </table>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="membercount" select="count($report/Member) - 1" />
                            <xsl:variable name="nonReferenceMembers" select="$report/Member[MemberDns != $report/MemberDns]" />
                            <table cellpadding="0" cellspacing="0" border="0">
                                <tr>
                                    <td class="toplinenarrow" height="4px">&#160;</td>
                                    <td class="topline" colspan="2" height="4px">&#160;</td>
                                </tr>
                                <tr>
                                    <td class="narrow">
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='referenceserver']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                            <xsl:value-of select="$report/MemberDns" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='referencesite']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <xsl:choose>
                                            <xsl:when test="$report/MemberSite != ''">
                                                <xsl:value-of select="$report/MemberSite" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$strData[@id='notavailable']" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='status']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <xsl:variable name="memError" select="count($report/Member[Status='2' and MemberDns != $report/MemberDns])" />
                                        <xsl:variable name="memDone" select="count($report/Member[Status='0' and MemberDns != $report/MemberDns])" />
                                        <xsl:variable name="memTotal" select="count($report/Member[MemberDns != $report/MemberDns])" />
                                        <xsl:choose>
                                            <xsl:when test="$memDone &lt; $memTotal">
                                                <xsl:value-of select="$strData[@id='pending']" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$strData[@id='done']" />
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="$memDone" />
                                        <xsl:value-of select="$strData[@id='of']" />
                                        <xsl:value-of select="$memTotal" />
                                        <xsl:value-of select="$strData[@id='completed']" />
                                        <xsl:if test="$memError &gt; 0">
                                            <xsl:value-of select="$strData[@id='with']" />
                                            <xsl:value-of select="$memError" />
                                            <xsl:value-of select="$strData[@id='inerror']" />
                                        </xsl:if>
                                        <xsl:text>)</xsl:text>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='datelaunched']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <script>
                                            document.write(showDateInOtherTimezone(<xsl:value-of select="$report/FileCreateTime/fileTime" />, <xsl:value-of select="$timezone" />));
                                        </script>
                                    </td>
                                </tr>
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="($countincomplete + $counterror) = 0">
                                            <td>
                                                <div class="reportdetails">
                                                    <xsl:value-of select="$strData[@id='replicationtime']" />
                                                </div>
                                            </td>
                                            <td colspan="2">
                                              <xsl:call-template name="calcTimeDiff">
                                                    <xsl:with-param name="startTime" select="$report/FileCreateTime/fileTime" />
                                                    <xsl:with-param name="endTime" select="user:DisplayMaxTimeForPercentage(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, 100)" />
                                                </xsl:call-template>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td>
                                                <div class="reportdetails">
                                                    <xsl:value-of select="$strData[@id='timeelapsed']" />
                                                </div>
                                            </td>
                                            <td colspan="2">
                                                <xsl:call-template name="calcTimeDiff">
                                                    <xsl:with-param name="startTime" select="$report/FileCreateTime/fileTime" />
                                                    <xsl:with-param name="endTime" select="$report/timestamp/fileTime" />
                                                </xsl:call-template>
                                            </td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="reportdetails">
                                            <xsl:value-of select="$strData[@id='testfile']" />
                                        </div>
                                    </td>
                                    <td colspan="2">
                                        <xsl:value-of select="$report/FileName" />
                                    </td>
                                </tr>
                            </table>
                            <!-- Start extended details -->
                            <xsl:if test="$membercount&gt;0">
                                <!-- Only show if there are members -->
                                <!-- First section is the maximum replication time graph -->
                                <div class="he2_expanded" onmouseover="pointer(this, 'hand')" onmouseout="pointer(this)">
                                    <xsl:attribute name="style">
                                        <!--xsl:if test="./serverErrors/error[@type='unavailableServerError'][1]"-->
                                        <xsl:text>border-top:1px solid #999999;</xsl:text>
                                        <!--/xsl:if-->
                                    </xsl:attribute>
                                    <xsl:if test="$membercount&gt;0">
                                        <!-- If server has errors, add onclick code -->
                                        <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                                        <xsl:attribute name="onclick">
                                            <xsl:text>doShowBlock('</xsl:text>
                                            <xsl:value-of select="concat($srvrID, '_graph')" />
                                            <xsl:text>'); switchSign(this.childNodes);</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="onkeypress">
                                            <xsl:text>doShowBlock('</xsl:text>
                                            <xsl:value-of select="concat($srvrID, '_graph')" />
                                            <xsl:text>'); switchSign(this.childNodes);</xsl:text>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <span id="plusminus" class="expando3" sign="plus">
                                        <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                                    </span>
                                    <span class="sectionTitle3" tabindex="0">
                                        <v:vmlframe src="#Time" class="er1" />
                                        <xsl:text> &#160;</xsl:text>
                                        <xsl:value-of select="$strData[@id='maximumsgraphtitle']" />
                                    </span>
                                </div>
                                <!--End Section Header-->
                                <!-- Process maximums for the report -->
                                <!--Create the DIV to hold the maximums list-->
                                <div class="container" style="display:none;" name="container">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="concat($srvrID, '_graph')" />
                                    </xsl:attribute>
                                    <div class="he4i2">
                                        <xsl:choose>
                                            <xsl:when test="count($nonReferenceMembers[Status=0]) = 0">
                                                <v:vmlframe src="#Warn1" class="er1a" style="margin-top: 3px;" /> &#160; <xsl:value-of select="$strData[@id='nograph']" />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <div class="graph" id="{concat($srvrID, '_maximumsgraphparent')}" style="width:expression(body.clientWidth &gt; 750 ? '700px' : '100%');">
                                                    <xsl:variable name="prefix" select="concat($srvrID, '_maximumsgraph')" />
                                                    <xsl:variable name="height" select="300" />
                                                    <xsl:variable name="width" select="700" />
                                                    <xsl:variable name="heightm" select="60" />
                                                    <xsl:variable name="widthm" select="100" />
                                                    <xsl:variable name="heightg" select="$height - $heightm" />
                                                    <xsl:variable name="widthg" select="$width - $widthm" />
                                                    <xsl:variable name="buffer" select="10" />
                                                    <v:group id="{$prefix}" editas="canvas" style="width:{$width};height:{$height};" coordorigin="0,0" coordsize="{$width},{$height}">
                                                        <v:rect fillcolor="white" strokeweight="0px" stroked="f" style="position:absolute;left:0;top:0;width:100%;height:100%;"></v:rect>
                                                        <v:line style="position:absolute" from="{$widthm},{$buffer}" to="{$widthm},{$heightg + $buffer}" strokeweight="1px"/>
                                                        <v:line style="position:absolute" from="{$width},{$buffer}" to="{$width},{$heightg + $buffer}" strokeweight="1px"/>
                                                        <v:rect style="position:absolute;left:{0};top:{$buffer div 2};width:{35};height:{$heightg}" filled="f" stroked="f">
                                                            <v:textbox inset="0,0,0,0">
                                                                <div style="direction:ltr; writing-mode:tb-rl;width:{35};height:{$heightg};text-align:center;font:normal 8pt tahoma;">
                                                                    <xsl:value-of select="$strData[@id='percentofmembers']" />
                                                                </div>
                                                            </v:textbox>
                                                        </v:rect>
                                                        <v:line style="position:absolute" from="{$widthm},{$heightg + $buffer}" to="{$width},{$heightg + $buffer}" strokeweight="1px"/>
                                                        <v:rect style="position:absolute;left:{$widthm div 2};top:{$heightg + $buffer - $buffer div 2};width:{35};height:{12}" filled="f" stroked="f">
                                                            <v:textbox inset="0,0,0,0">
                                                                <div style="text-align:right;font:normal 8pt tahoma;">0%</div>
                                                            </v:textbox>
                                                        </v:rect>
                                                        <v:oval style="position:absolute;left:{$widthm + $buffer - 3};top:{$heightg + $buffer - 3};width:6;height:6;z-index:500;" fillcolor="white" title="0% of members (0), 0 min."/>
                                                        <!-- Insert the time values -->
                                                        <xsl:variable name="maxtime" select="user:GetMaxTimeForPercentageSet(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, $strings/replicationpercentages/percent/@value)" />
                                                        <xsl:variable name="difftime" select="$maxtime - number($report/FileCreateTime/fileTime)" />
                                                        <v:rect style="position:absolute;left:{$widthm + $buffer};top:{$height - $heightm div 2 + $buffer};width:{$widthg - $buffer};height:{12}" filled="f" stroked="f">
                                                            <v:textbox inset="0,0,0,0">
                                                                <div style="text-align:center;font:normal 8pt tahoma;">
                                                                    <xsl:value-of select="$strData[@id='maximumreplicationtime']" />
                                                                </div>
                                                            </v:textbox>
                                                        </v:rect>
                                                        <xsl:for-each select="$strings/replicationtimepercentages/percent/@value">
                                                            <xsl:variable name="cper" select="100 - number(.)" />
                                                            <xsl:variable name="x1" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * ($cper div 100))" />
                                                            <xsl:variable name="x2" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * ((100 - $cper) div 100))" />
                                                            <v:line style="position:absolute" from="{$x2},{$heightg + $buffer - 5}" to="{$x2},{$heightg + $buffer + 5}" strokeweight="1px"/>
                                                            <v:rect style="position:absolute;left:{$widthm + $buffer};top:{$heightg + $buffer + $buffer div 2};width:{$width - $x1};height:{12}" filled="f" stroked="f">
                                                                <v:textbox inset="0,0,0,0">
                                                                    <div style="text-align:right;font:normal 8pt tahoma;">
                                                                        <xsl:call-template name="calcTimeDiff">
                                                                            <xsl:with-param name="startTime" select="$report/FileCreateTime/fileTime" />
                                                                            <xsl:with-param name="endTime" select="$maxtime - ceiling($difftime * $cper div 100)" />
                                                                        </xsl:call-template>
                                                                    </div>
                                                                </v:textbox>
                                                            </v:rect>
                                                        </xsl:for-each>
                                                        <!-- Draw the graph bars and values -->
                                                        <xsl:variable name="starttime" select="number($report/FileCreateTime/fileTime)" />
                                                      <xsl:choose>
                                                        <xsl:when test="count($nonReferenceMembers) &lt; 10">
                                                          <xsl:for-each select="$nonReferenceMembers">
                                                            <xsl:variable name="posx" select="position()" />
                                                            <xsl:variable name="curr" select="floor(($posx div count($nonReferenceMembers))*100)" />
                                                            <xsl:variable name="prev" select="floor((($posx - 1) div count($nonReferenceMembers))*100)" />
                                                            <xsl:variable name="max" select="user:DisplayMaxTimeForPercentage(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, $curr)" />
                                                            <xsl:variable name="maxlast" select="user:DisplayMaxTimeForPercentage(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, $prev)" />
                                                            <xsl:variable name="top" select="$heightg + $buffer - floor((($heightg) div 100) * $curr)" />
                                                            <xsl:variable name="top2" select="$heightg + $buffer - floor((($heightg) div 100) * $prev)" />
                                                            <xsl:variable name="x1" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * user:max(0, (($max - $starttime) div ($maxtime - $starttime))))"/>
                                                            <xsl:variable name="x2" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * user:max(0, (($maxlast - $starttime) div ($maxtime - $starttime))))" />
                                                            <xsl:variable name="x0" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * 0)" />
                                                            <!-- Graph bars -->
                                                            <v:line style="position:absolute" from="{$widthm},{$top}" to="{$width},{$top}" strokeweight="1px"/>
                                                            <!-- Text -->
                                                            <v:rect style="position:absolute;left:{$widthm - 35 - $buffer};top:{$top - $buffer div 2};width:{35};height:{12}" filled="f" stroked="f">
                                                              <v:textbox inset="0,0,0,0">
                                                                <div style="text-align:right;font:normal 8pt tahoma;">
                                                                  <xsl:value-of select="$curr" />%
                                                                </div>
                                                              </v:textbox>
                                                            </v:rect>
                                                            <!-- Value line -->
                                                            <xsl:if test="$curr &gt; 0 and $curr &lt;= 100 and $max &gt; 0">
                                                              <xsl:text>&#13;&#10;</xsl:text>
                                                              <!--
                                                                    <xsl:value-of select="." />%:
                                                                    prev: <xsl:value-of select="$prev" />%,
                                                                    top: <xsl:value-of select="$top" />,
                                                                    top2: <xsl:value-of select="$top2" />,
                                                                    x0: <xsl:value-of select="$x0" />,
                                                                    x1: <xsl:value-of select="$x1" />,
                                                                    x2: <xsl:value-of select="$x2" />,
                                                                    max: <xsl:value-of select="$max" />,
                                                                    maxlast: <xsl:value-of select="$maxlast" />,
                                                                    maxtime: <xsl:value-of select="$maxtime" />,
                                                                    max/maxtime: <xsl:value-of select="$max div $maxtime" />
                                                                    maxlast/maxtime: <xsl:value-of select="$maxlast div $maxtime" />
                                                                -->
                                                              <xsl:text>&#13;&#10;</xsl:text>
                                                              <xsl:choose>
                                                                <xsl:when test="not($maxlast) or $maxlast &lt; 0">
                                                                  <v:line style="position:absolute" from="{$x1},{$top}" to="{$x0},{$heightg + $buffer}" strokeweight="3px" strokecolor="blue"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                  <v:line style="position:absolute" from="{$x1},{$top}" to="{$x2},{$top2}" strokeweight="3px" strokecolor="blue"/>
                                                                </xsl:otherwise>
                                                              </xsl:choose>
                                                              <v:oval style="position:absolute;left:{$x1 - 3};top:{$top - 3};width:6;height:6;z-index:500;" fillcolor="white">
                                                                <xsl:attribute name="title">
                                                                  <xsl:value-of select="concat($curr, '%', ' of members (', ceiling($curr div 100 * count($nonReferenceMembers)), '), ')" />
                                                                  <xsl:call-template name="calcTimeDiff">
                                                                    <xsl:with-param name="startTime" select="$starttime" />
                                                                    <xsl:with-param name="endTime" select="$max" />
                                                                  </xsl:call-template>
                                                                </xsl:attribute>
                                                              </v:oval>
                                                            </xsl:if>
                                                            <!-- Value dot -->
                                                          </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                          <xsl:for-each select="$strings/replicationpercentages/percent/@value">
                                                            <xsl:variable name="top" select="$heightg + $buffer - floor((($heightg) div 100) * number(.))" />
                                                            <xsl:variable name="posx" select="position()" />
                                                            <xsl:variable name="prev" select="number(../../percent[$posx - 1]/@value)" />
                                                            <xsl:variable name="max" select="user:DisplayMaxTimeForPercentage(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, number(.))" />
                                                            <xsl:variable name="maxlast" select="user:DisplayMaxTimeForPercentage(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, $prev)" />
                                                            <xsl:variable name="top2" select="$heightg + $buffer - floor((($heightg) div 100) * $prev)" />
                                                            <xsl:variable name="x1" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * user:max(0,(($max - $starttime) div ($maxtime - $starttime))))" />
                                                            <xsl:variable name="x2" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * user:max(0,(($maxlast - $starttime) div ($maxtime - $starttime))))" />
                                                            <xsl:variable name="x0" select="$widthm + $buffer + ceiling(($widthg - $buffer * 2) * 0)" />
                                                            <!-- Graph bars -->
                                                            <v:line style="position:absolute" from="{$widthm},{$top}" to="{$width},{$top}" strokeweight="1px"/>
                                                            <!-- Text -->
                                                            <v:rect style="position:absolute;left:{$widthm - 35 - $buffer};top:{$top - $buffer div 2};width:{35};height:{12}" filled="f" stroked="f">
                                                              <v:textbox inset="0,0,0,0">
                                                                <div style="text-align:right;font:normal 8pt tahoma;">
                                                                  <xsl:value-of select="." />%
                                                                </div>
                                                              </v:textbox>
                                                            </v:rect>
                                                            <!-- Value line -->
                                                            <xsl:if test="number(.) &gt; 0 and number(.) &lt;= 100 and $max &gt; 0">
                                                              <xsl:text>&#13;&#10;</xsl:text>
                                                              <!--
                                                                    <xsl:value-of select="." />%:
                                                                    prev: <xsl:value-of select="$prev" />%,
                                                                    top: <xsl:value-of select="$top" />,
                                                                    top2: <xsl:value-of select="$top2" />,
                                                                    x0: <xsl:value-of select="$x0" />,
                                                                    x1: <xsl:value-of select="$x1" />,
                                                                    x2: <xsl:value-of select="$x2" />,
                                                                    max: <xsl:value-of select="$max" />,
                                                                    maxlast: <xsl:value-of select="$maxlast" />,
                                                                    maxtime: <xsl:value-of select="$maxtime" />,
                                                                    max/maxtime: <xsl:value-of select="$max div $maxtime" />
                                                                    maxlast/maxtime: <xsl:value-of select="$maxlast div $maxtime" />
                                                                -->
                                                              <xsl:text>&#13;&#10;</xsl:text>
                                                              <xsl:choose>
                                                                <xsl:when test="not($maxlast) or $maxlast &lt; 0">
                                                                  <v:line style="position:absolute" from="{$x1},{$top}" to="{$x0},{$heightg + $buffer}" strokeweight="3px" strokecolor="blue"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                  <v:line style="position:absolute" from="{$x1},{$top}" to="{$x2},{$top2}" strokeweight="3px" strokecolor="blue"/>
                                                                </xsl:otherwise>
                                                              </xsl:choose>
                                                              <v:oval style="position:absolute;left:{$x1 - 3};top:{$top - 3};width:6;height:6;z-index:500;" fillcolor="white">
                                                                <xsl:attribute name="title">
                                                                  <xsl:value-of select="concat(number(.), '%', ' of members (', ceiling(number(.) div 100 * count($nonReferenceMembers)), '), ')" />
                                                                  <xsl:call-template name="calcTimeDiff">
                                                                    <xsl:with-param name="startTime" select="$starttime" />
                                                                    <xsl:with-param name="endTime" select="$max" />
                                                                  </xsl:call-template>
                                                                </xsl:attribute>
                                                              </v:oval>
                                                            </xsl:if>
                                                            <!-- Value dot -->
                                                          </xsl:for-each>
                                                        </xsl:otherwise>
                                                      </xsl:choose>
                                                  </v:group>
                                                    <v:shape id="{$prefix}_disp" type="#{$prefix}" style="width:100%;height:100%;">
                                                        <v:imagedata croptop="0f" cropbottom="0f"/>
                                                    </v:shape>
                                                </div>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </div>
                                <!-- Second section is the maximum replication time -->
                                <div class="he2_expanded" onmouseover="pointer(this, 'hand')" onmouseout="pointer(this)">
                                    <xsl:attribute name="style">
                                        <!--xsl:if test="./serverErrors/error[@type='unavailableServerError'][1]"-->
                                        <xsl:text>border-top:1px solid #999999;</xsl:text>
                                        <!--/xsl:if-->
                                    </xsl:attribute>
                                    <xsl:if test="$membercount&gt;0">
                                        <!-- If server has errors, add onclick code -->
                                        <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                                        <xsl:attribute name="onclick">
                                            <xsl:text>doShowBlock('</xsl:text>
                                            <xsl:value-of select="concat($srvrID, '_maximums')" />
                                            <xsl:text>'); switchSign(this.childNodes);</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="onkeypress">
                                            <xsl:text>doShowBlock('</xsl:text>
                                            <xsl:value-of select="concat($srvrID, '_maximums')" />
                                            <xsl:text>'); switchSign(this.childNodes);</xsl:text>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <span id="plusminus" class="expando3" sign="plus">
                                        <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                                    </span>
                                    <span class="sectionTitle3" tabindex="0">
                                        <v:vmlframe src="#Time" class="er1" />
                                        <xsl:text> &#160;</xsl:text>
                                        <xsl:value-of select="$strData[@id='maximumstitle']" />
                                    </span>
                                </div>
                                <!--End Section Header-->
                                <!-- Process maximums for the report -->
                                <!--Create the DIV to hold the maximums list-->
                                <div class="container" style="display:none;" name="container">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="concat($srvrID, '_maximums')" />
                                    </xsl:attribute>
                                    <div class="he4i2">
                                        <div class="members">
                                            <table border="0" cellpadding="0" cellspacing="0" class="membersheader">
                                                <tr style="height:0px;">
                                                    <td width="18" height="0" style="line-height:0px;width:18px;height:0px;">&#160;</td>
                                                    <td colspan="2" height="0" style="line-height:0px;height:0px;">&#160;</td>
                                                </tr>
                                                <!--
                                                  - Removing the header for style reasons.
                                                  - We also don't need to show the filename twice
                                                    <tr class="header">
                                                        <td colspan="3">
                                                            <v:vmlframe src="#Time" class="er1" />  &#160; <xsl:value-of select="$strData[@id='maxrepltime']" /><xsl:value-of select="$report/TestFileName" />
                                                        </td>
                                                    </tr>
                                                -->
                                                <tr>
                                                    <td rowspan="{count($strings/replicationpercentages/percent/@value) + 1}">&#160;</td>
                                                    <td class="tblwhiteleft">
                                                        <xsl:value-of select="$strData[@id='percentofmembers']" />
                                                    </td>
                                                    <td class="tblwhiteright">
                                                        <xsl:value-of select="$strData[@id='maximumreplicationtime']" />
                                                    </td>
                                                </tr>
                                                <xsl:for-each select="$strings/replicationpercentages/percent/@value">
                                                    <tr>
                                                        <!--td class="icon"> </td-->
                                                        <xsl:variable name="percent" select="number(.)" />
                                                        <xsl:variable name="nummembers" select="ceiling(count($nonReferenceMembers) div 100 * $percent)" />
                                                        <td >
                                                            <xsl:value-of select="." />%<xsl:value-of select="$strData[@id='membercount']" /><xsl:value-of select="$nummembers" /><xsl:choose>
                                                                <xsl:when test="$nummembers = 1">
                                                                    <xsl:value-of select="$strData[@id='membercount1']" />
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="$strData[@id='membercount2']" />
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                        <td >
                                                            <xsl:call-template name="calcTimeDiff">
                                                                <xsl:with-param name="startTime" select="$report/FileCreateTime/fileTime" />
                                                                <xsl:with-param name="endTime" select="user:DisplayMaxTimeForPercentage(string($report/FileCreateTime/fileTime), $nonReferenceMembers/TestFileUpdateTime/fileTime, $nonReferenceMembers/Status, number(.))" />
                                                            </xsl:call-template>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>

                            <div class="he2_expanded" onmouseover="pointer(this, 'hand')" onmouseout="pointer(this)">
                                <xsl:attribute name="style">
                                    <!--xsl:if test="./serverErrors/error[@type='unavailableServerError'][1]"-->
                                    <xsl:text>border-top:1px solid #999999;</xsl:text>
                                    <!--/xsl:if-->
                                </xsl:attribute>
                                <xsl:if test="$membercount&gt;0">
                                    <!-- If server has errors, add onclick code -->
                                    <xsl:attribute name="tabindex"><xsl:text>0</xsl:text></xsl:attribute>
                                    <xsl:attribute name="onclick">
                                        <xsl:text>doShowBlock('</xsl:text>
                                        <xsl:value-of select="concat($srvrID, '_members')" />
                                        <xsl:text>'); switchSign(this.childNodes);</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="onkeypress">
                                        <xsl:text>doShowBlock('</xsl:text>
                                        <xsl:value-of select="concat($srvrID, '_members')" />
                                        <xsl:text>'); switchSign(this.childNodes);</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:choose>
                                    <xsl:when test="$membercount&gt;0">
                                        <!-- If server has errors, add +/- icon and indicate # of errors-->
                                        <span id="plusminus" class="expando3" sign="plus">
                                            <v:vmlframe src="#Plus" class="pm1"></v:vmlframe>
                                        </span>
                                        <span class="sectionTitle3" tabindex="0">
                                            <v:vmlframe src="#Details" class="er1" />
                                            <xsl:text> &#160;</xsl:text>
                                            <xsl:value-of select="$strData[@id='memberstitle']" />
                                            <xsl:value-of select="$strData[@id='membercount']" />
                                            <xsl:value-of select="$membercount" />
                                            <xsl:choose>
                                                <xsl:when test="$membercount=1">
                                                    <xsl:value-of select="$strData[@id='membercount1']" />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$strData[@id='membercount2']" />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="sectionTitle3" tabindex="0">
                                            <v:vmlframe src="#Details" class="er1" />
                                            <xsl:text> &#160;</xsl:text>
                                            <xsl:value-of select="$strData[@id='memberstitle']" />
                                            <xsl:value-of select="$strData[@id='membercount']" />
                                            <xsl:value-of select="$strData[@id='membercount0']" />
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                            <!--End Section Header-->
                            <!-- Process errors for the server -->
                            <!--Create the DIV to hold the error list-->
                            <xsl:if test="$membercount&gt;0">
                                <div class="container" style="display:none;" name="container">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="concat($srvrID, '_members')" />
                                    </xsl:attribute>
                                    <div class="he4i2">
                                        <div class="members">
                                            <table border="0" cellpadding="0" cellspacing="0" class="memberslist">
                                                <tr style="height:0px;">
                                                    <td width="18" height="0" style="line-height:0px;width:18px;height:0px;">&#160;</td>
                                                    <td colspan="2" height="0" style="line-height:0px;height:0px;">&#160;</td>
                                                </tr>
                                                <tr class="header">
                                                    <td rowspan="{count($report/Member) + 1}" />
                                                    <td class="tblwhiteleft">
                                                        <!-- member"> -->
                                                        <xsl:value-of select="$strData[@id='dtabh1']" />
                                                    </td>
                                                    <td class="tblwhiteboth">
                                                        <!-- membersite"> -->
                                                        <xsl:value-of select="$strData[@id='dtabh2']" />
                                                    </td>
                                                    <td class="tblwhiteright">
                                                        <!-- memberest"> -->
                                                        <xsl:value-of select="$strData[@id='dtabh3']" />
                                                    </td>
                                                </tr>
                                                <xsl:for-each select="$nonReferenceMembers">
                                                    <xsl:sort select="MemberDns" order="ascending" />
                                                    <tr>
                                                        <td class="member">
                                                            <xsl:value-of select="MemberDns" />
                                                        </td>
                                                        <td class="membersite">
                                                            <xsl:choose>
                                                                <xsl:when test="not(MemberSite) or MemberSite = ''">
                                                                    <xsl:value-of select="$strData[@id='notavailable']" />
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:value-of select="MemberSite" />
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                        <td class="memberest">
                                                            <xsl:choose>
                                                                <xsl:when test="Status='1'">
                                                                    <xsl:value-of select="$strData[@id='arrivalpending']" />
                                                                </xsl:when>
                                                                <xsl:when test="Status='2'">
                                                                    <xsl:value-of select="$strData[@id='error']" />
                                                                    <xsl:value-of select="LastErrorMessage" />
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:choose>
                                                                        <xsl:when test="TestFileUpdateTime/fileTime != ''">
                                                                            <xsl:value-of select="$strData[@id='arrivedin']" />                                                                          
                                                                            <xsl:call-template name="calcTimeDiff">
                                                                                <xsl:with-param name="startTime" select="$report/FileCreateTime/fileTime" />
                                                                                <xsl:with-param name="endTime" select="TestFileUpdateTime/fileTime" />
                                                                            </xsl:call-template>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:value-of select="$strData[@id='notapplicable']" />
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="calcTimeDiff">
        <xsl:param name="startTime" />
        <xsl:param name="endTime" />
        <xsl:param name="mode" />
        <xsl:variable name="runTimeHrs" select="($endTime - $startTime) div 36000000000" />
        <xsl:variable name="days">
            <xsl:choose>
                <xsl:when test="$mode">
                    <xsl:value-of select="0" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="floor($runTimeHrs div 24)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="hours" select="floor($runTimeHrs - ($days * 24))" />
        <xsl:variable name="mins" select="floor(($runTimeHrs - (($days * 24) + $hours)) * 60)" />
        <xsl:variable name="secs">
            <xsl:choose>
                <xsl:when test="$days = 0 and $hours = 0 and $mins &lt; 15">
                    <xsl:value-of select="floor(((($runTimeHrs - (($days * 24) + $hours)) * 60) - $mins) * 60)" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="0" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($startTime) or not($endTime)">
                <!--xsl:value-of select="$startTime" /-->
                <xsl:value-of select="$strData[@id='notapplicable']" />
              <!--xsl:value-of select="$endTime" /-->
            </xsl:when>
            <!--
                <xsl:when test="$endTime &gt; 0">
                    <xsl:value-of select="$endTime" />
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$startTime" />
                </xsl:when>
            -->
            <xsl:when test="$endTime &gt; $startTime">
                <xsl:if test="$days &gt; 0">
                    <xsl:value-of select="$days" />
                    <xsl:choose>
                        <xsl:when test="$days = 1">
                            <xsl:value-of select="$strData[@id='day']" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$strData[@id='days']" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="$hours &gt; 0">
                    <xsl:value-of select="$hours" />
                    <xsl:value-of select="$strData[@id='hr']" />
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="$mins &gt; 0">
                    <xsl:value-of select="$mins" />
                    <xsl:value-of select="$strData[@id='min']" />
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="$secs &gt; 0">
                    <xsl:value-of select="$secs" />
                    <xsl:value-of select="$strData[@id='sec']" />
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="($days = 0) and ($hours = 0) and ($mins = 0) and ($secs = 0)">
                    <xsl:text>&lt;1 </xsl:text>
                    <xsl:value-of select="$strData[@id='sec']" />
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>&lt;1 </xsl:text>
              <xsl:value-of select="$strData[@id='sec']" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="renderMembersToJS">
        <xsl:param name="fileList" />
        <script language="javascript">
            var reportStats = new Array();
            var count = 0;
            <xsl:for-each select="$fileList">
                <xsl:variable name="this" select="." />

                var tmp = new Array();
                tmp.push('<xsl:value-of select="$this/FileCreateTime/fileTime" />');
                <xsl:for-each select="$this/Member">
                    tmp.push('<xsl:value-of select="concat(Status, ';', TestFileUpdateTime/fileTime)" />');
                </xsl:for-each>
                reportStats.push(tmp);
            </xsl:for-each>
            <!--
            <xsl:for-each select="$fileList">
                <xsl:variable name="this" select="document(ReportPath)/child::node()" />
                var complete = 1;
                var maxTime = 0;
                    <xsl:for-each select="$this/Member">
                    var status = <xsl:value-of select="Status" />;
                    var updateTime = <xsl:value-of select="TestFileUpdateTime/fileTime" />;
                    var diffTime = updateTime - startTime;

                    if (status != 0) complete = 0;
                    if (diffTime > maxTime) maxTime = diffTime;
                </xsl:for-each>
                reportStats.push(concat(complete, ';', maxTime));                
                count++;
            </xsl:for-each>
            -->
            <![CDATA[
    function calculateGlobalAverage() {
        var globalAvg = 0;
        var globalCount = 0;
        for (var i = 0; i < reportStats.length; i++) {
            var thisArray = reportStats[i];
            var startTime = thisArray[0];
            var max = startTime;
            var complete = 1;
            for (var j = 1; j < thisArray.length; j++) {
                var tmp = thisArray[j].split(';');
                
                if (tmp[0] == 0)
                {
                   if (tmp[1] > max) max = tmp[1]; 
                }
                else
                {
                    complete = 0;
                    break;
                }
            }

            if (complete == 1)
            {
                globalAvg += (max - startTime);
                globalCount++;
            }
        }
        if (globalCount > 0) 
            globalAvg = Math.ceil(globalAvg / globalCount) + 116444736000000000;
        else
            globalAvg = 116444736000000000;
        return(globalAvg);
    }
    
    function calculateGlobalMax() {
        var globalMax = 0;
        for (var i = 0; i < reportStats.length; i++) {
            var thisArray = reportStats[i];
            var startTime = thisArray[0];
            var max = startTime;
            var complete = 1;
            for (var j = 1; j < thisArray.length; j++) {
                var tmp = thisArray[j].split(';');
                
                if (tmp[0] == 0)
                {
                   if (tmp[1] > max) max = tmp[1]; 
                }
                else
                {
                    complete = 0;
                    break;
                }
            }

            if (complete == 1)
            {
                var tmp = (max - startTime);

                if( tmp > globalMax) globalMax = tmp;
            }
        }
        globalMax = 116444736000000000 + globalMax;
        return(globalMax);
    }
    ]]>
        </script>
    </xsl:template>

    <xsl:template name="countTests">
        <xsl:param name="nodes" />
        <xsl:param name="pos" />
        <xsl:param name="type" />
        <xsl:param name="count" />
        <xsl:choose>
            <xsl:when test="$pos &gt; count($nodes)">
                <xsl:value-of select="$count" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="report" select="$nodes[$pos]" />
                <xsl:variable name="newcount">
                    <xsl:choose>
                        <xsl:when test="$type = 'incomplete' and not($nodes[$pos]/Error) and count($report/Member[(Status!='0' and Status!='2') and MemberDns != $report/MemberDns]) &gt; 0">
                            <xsl:value-of select="$count + 1" />
                        </xsl:when>
                        <xsl:when test="$type = 'complete' and not($nodes[$pos]/Error) and count($report/Member[Status!='0' and MemberDns != $report/MemberDns]) = 0">
                            <xsl:value-of select="$count + 1" />
                        </xsl:when>
                        <xsl:when test="$type = 'error' and (($nodes[$pos]/Error) or (count($report/Member[Status='2' and MemberDns != $report/MemberDns]) &gt; 0))">
                            <xsl:value-of select="$count + 1" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$count" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:call-template name="countTests">
                    <xsl:with-param name="nodes" select="$nodes" />
                    <xsl:with-param name="pos" select="$pos + 1" />
                    <xsl:with-param name="type" select="$type" />
                    <xsl:with-param name="count" select="number($newcount)" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
