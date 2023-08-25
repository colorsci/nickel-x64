# Copyright © 2008, Microsoft Corporation. All rights reserved.

function GetRuntimePath([string]$fileName = $(throw "No file name is specified"))
{
    if([string]::IsNullorEmpty($fileName))
    {
        throw "Invalid file name"
    }

     [string]$runtimePath =  [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
     return Join-Path $runtimePath $fileName
}

function RegSnapin([string]$dllName = $(throw "No dll is specified"))
{
    $dllPath = ".\" + $dllName
    Import-Module $dllPath
}

function UnregSnapin([string]$dllName = $(throw "No dll is specified"))
{    
    $moduleName = $dllName.TrimEnd(".dll")
    Remove-Module $moduleName
}

function GetExistingNDFInstance($IncidentID)
{
    &{
        #if fails we start a new session
        $script:ExpectingException = $true
        $ndf = new-object -comObject ndfapi.NetworkDiagnostics.1 -strict
        $ndf.OpenExistingIncident($IncidentID); #throws exception if fails
        $script:ExpectingException = $false
        return $ndf
    }
    trap [Exception]
    {
        if($script:ExpectingException)
        {
            $script:ExpectingException = $false
            "Exception: " + $_.Exception.GetType().FullName + " Message: " + $_.Exception.Message  | convertto-xml | Update-DiagReport -id OpenExistingSessionFailure -name "Open Existing Session" -description "Failed while opening existing NDF session." -verbosity Debug
            return $null;
        }
        else
        {
            #rethrow exception
            throw $_.Exception;
        }
    }
}

function WaitWithProgress($ActivityNoDetails, $WaitHandle, $Ndf)
{
    $lastProgress = $null
    do {
        $progress = $Ndf.Progress
        if(($progress -ne $null) -and ($progress.Length -gt 0) -and !($progress -eq $lastProgress))
        {
           Write-DiagProgress -activity $progress
            $lastProgress = $progress
        }
        elseif(($progress.Length -eq 0) -and !($ActivityNoDetails -eq $lastProgress))
        {
            #clear the last progress string, use alternate description of operation
            Write-DiagProgress -activity $ActivityNoDetails
            $lastProgress = $ActivityNoDetails
        }

        &{
            $WaitHandle.Wait($ProgressUpdateDelay)
            break
        }
        trap [Exception]
        {
            #timed out, continue waiting
            continue
        }
    } while($true)
}

# if filtered mode is enabled and the root cause is not on the filter list then return TRUE
function GetRootCauseFilterValue($RootCause, [ref]$FilterMode)
{
    #assume filtering is enabled
    $filteringEnabled = $true;
    if($FilterMode)
    {
        $FilterMode.value = 0;
    }

    $regValue = get-itemproperty -path hklm:\SYSTEM\CurrentControlSet\Control\NetDiagFx\Config  -name FilterMode -ErrorAction SilentlyContinue -ErrorVariable regError
    if($regValue)
    {
        if($FilterMode)
        {
            $FilterMode.value = $regValue.FilterMode;
        }
        $filteringEnabled = !($regValue.FilterMode -eq $FM_DISABLED);
    }
    elseif($regError)
    {
        if(!($regError[0].CategoryInfo.Category -eq "InvalidArgument") -and !($regError[0].CategoryInfo.Category -eq "ObjectNotFound"))
        {
            " Warning: Unexpected error when reading FilterMode key: " + $regError[0].CategoryInfo.Category | convertto-xml | Update-DiagReport -id UnexpectedRegError -name "Unexpected Registry Error" -verbosity Debug
        }
    }

    if(!$filteringEnabled)
    {
        #allow all root causes
        return $FV_NOTFILTERED;
    }
    else
    {
        #get the registry value and make the filtering decision
        $rootCauseID = $RootCause.RootCauseID;
        $regValue = get-itemproperty -path hklm:\SYSTEM\CurrentControlSet\Control\NetDiagFx\Config\RC  -name $rootCauseID -ErrorAction SilentlyContinue -ErrorVariable regError
        if($regValue)
        {
            #root cause present, check the entry type
            $filterValue = $regValue.$rootCauseID;
            if($filterValue -eq 1)
            {
                #exclusion list, force enabled filter mode so that the RC is dropped
                if($FilterMode)
                {
                    $FilterMode.value = $FM_ENABLED;
                }
                return $FV_FILTERED;
            }
            else
            {
                #inclusion list, not filtered
                return $FV_NOTFILTERED;
            }
        }
        else
        {
            if(!($regError[0].CategoryInfo.Category -eq "InvalidArgument") -and  !($regError[0].CategoryInfo.Category -eq "ObjectNotFound"))
            {
                " Warning: Unexpected error when reading Root Cause key : " + $regError[0].CategoryInfo.Category | convertto-xml | Update-DiagReport -id UnexpectedRegError -name "Unexpected Registry Error" -verbosity Debug
            }
            #could not find root cause
            return $FV_MISSING;
        }
    }
}

function GetCatchAllInformation($RootCauseEnum, [ref]$CatchAlls, [ref]$CatchAllsIndex, [ref]$CatchAllsAltRC)
{
    $localCatchAlls  = @{}; #will contain the RC's with catch all repairs, indexed by HC it applies to
    $localCatchAllsIndex = @{}; #will hold the index of the catch-all in the root cause list
    $localCatchAllsAltRC = @{}; #will contain the alternate RC ID for the catch all, if available, indexed by root cause

    $rootCauseCount = $RootCauseEnum.Count;
    $RootCauseEnum.Reset()
    for($i=0; $i -lt $rootCauseCount; $i++)
    {
        $rootCause=$RootCauseEnum.Next;
        $repairEnum = $rootCause.Repairs;
        $repairCount = $repairEnum.Count;
        $repairEnum.Reset();
        for($curRep=0; $curRep -lt $repairCount; $curRep++)
        {
            $repair = $repairEnum.Next;
            if($repair.Flags -band $RF_RESERVED_CA)
            {
                $altRC = GetExtensionValue ($repair.DescriptionEx) ("CatchAllRC");

                #HC's this applies to
                $catchAllHCString =  GetExtensionValue ($repair.DescriptionEx) ("CatchAllHCs");
                if($catchAllHCString)
                {
                   #semi-colon separated
                   $catchAllHCList = $catchAllHCString.Split(";");
                   for($curHC=0; $catchAllHCList[$curHC]; $curHC++)
                   {
                        #if a RC is filtered for this HC, this catch all will be used
                        $localCatchAlls[$catchAllHCList[$curHC]]= $rootCause;
                        if($altRC)
                        {
                            #store the alternate RC
                            $localCatchAllsAltRC[$rootCause] = $altRC;
                        }
                   }
                   #store the index
                   $localCatchAllsIndex[$rootCause]= $i;
                }
                break;
            }
        }
    }

    #return back the values collected
    if($CatchAlls)
    {
        $CatchAlls.value = $localCatchAlls;
    }
    if($CatchAllsIndex)
    {
        $CatchAllsIndex.value = $localCatchAllsIndex;
    }
    if($CatchAllsAltRC)
    {
        $CatchAllsAltRC.value = $localCatchAllsAltRC;
    }
}

function GetParameters($DescriptionEx, $Params)
{
    $toReturn = @{};

    #this is a XML based root cause, get replacement parameters
    $paramEnum = $DescriptionEx.Parameters;
    $paramCount = $paramEnum.Count;
    $paramEnum.Reset()
    for($curP=0;$curP -lt $paramCount; $curP++)
    {
        $param = $paramEnum.Next;
        if($Params[$param.Name] -eq $null)
        {
            $toReturn += @{$param.Name = $param.Value}
        }
    }

    return $toReturn;
}

function GetKeywords($DescriptionEx)
{
    if($DescriptionEx -eq $nul)
    {
        return "";
    }

    $toReturn = "";

    #this is a XML based root cause, get replacement parameters
    $paramEnum = $DescriptionEx.Extensions;
    $paramCount = $paramEnum.Count;
    $paramEnum.Reset()
    for($curP=0;$curP -lt $paramCount; $curP++)
    {
        $param = $paramEnum.Next;
        if($param.Name -eq "Keyword")
        {
            if($toReturn.Length -gt 0)
            {
                $toReturn += "+";
            }
            $toReturn += """" + $param.Value + """";
        }
    }

    return $toReturn.Replace(" ", "+");
}

function GetExtensionValue($DescriptionEx, $ExtensionName)
{
    if($DescriptionEx)
    {
        $paramEnum = $DescriptionEx.Extensions;
        $paramCount = $paramEnum.Count;
        $paramEnum.Reset()
        for($curP=0;$curP -lt $paramCount; $curP++)
        {
            $param = $paramEnum.Next;
            if($param.Name -eq $ExtensionName)
            {
                return $param.Value;
            }
        }
    }

    return $null;
}

#are we an administrator or LUA?
function IsAdmin()
{
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [System.Security.Principal.WindowsPrincipal]($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

#the security boundary safe data now contains two items of information
#(1) the incident ID GUID (without the { } brackets)
#(2) flags: whether the process is LUA (0) or Admin (1)
#the two items are separated by a semicolon
function GetSBSData($IncidentID)
{
    $flags = 0
    $admin = IsAdmin
    if($admin)
    {
        $flags = 1
    }

    return $IncidentID.Substring(1,$IncidentID.Length-2) +":"+$flags
}

#the function takes a security boundary safe data and splits it into
#the incident ID GUID (putting back the {} brackets), and the
#flags
function SplitSBSData($SBSData, [ref]$IncidentID, [ref]$Flags)
{
    $IncidentID.value = "{" + $SBSData.Substring(0,$SBSData.IndexOf(":")) + "}"
    $Flags.value = $SBSData.Substring($SBSData.IndexOf(":")+1)
}

function GetInstanceHashCode($RootCause, $CatchAllInUse)
{
    $hashCode = "";

    $repairEnum = $RootCause.Repairs;
    $repairCount = $repairEnum.Count;
    $repairEnum.Reset();
    if($repairCount -gt 0)
    {
        $repair = $repairEnum.Next
        if($CatchAllInUse)
        {
            #make sure we use the hash for the first catch-all repair
            for($i=0; ($i -lt $repairEnum.Count) -and (!($repair.Flags -band $RF_RESERVED_CA)); $i++)
            {
                $repair = $repairEnum.Next;
            }
        }
        $hashCode = $repair.Description.GetHashCode();
    }
    else
    {
        $hashCode = $RootCause.Description.GetHashCode();
    }

    return $hashCode;
}

function GetInstanceIDRC($RootCause, $CatchAlls, $CatchAllsAltRC)
{

    $rootCause = $RootCause;
    $rootCauseID = $RootCause.RootCauseID;

    #if catch all is in use, we need to use the catch all root cause information in the
    #instance ID so that all catch-all matches go to the same root cause in the session
    $catchAllInUse = $null;
    $filterValue = GetRootCauseFilterValue ($RootCause) ($null);
    if($filterValue -eq $FV_MISSING)
    {
        #rc is not in the filter list, catch all instance ID information should be used if present
        $className = $rootCause.ClassName;
        if($className)
        {
            #is there a chatch all fo the helper class?
            $catchAllRC = $CatchAlls[$className];
            if($catchAllRC)
            {
                #user the catch-all root cause
                $rootCause = $catchAllRC;
                #does the catch-all have an alternate root cause?
                $altRCID = $CatchAllsAltRC[$catchAllRC];
                if($altRCID)
                {
                    #use alternate root cause ID
                    $rootCauseID = $catchAllsAltRC[$catchAllRC];
                }
                $catchAllInUse = $true;
            }
        }
    }

    $hashCode = GetInstanceHashCode($rootCause) ($catchAllInUse);
    return $rootCauseID.Substring(1,$rootCauseID.Length-2) + ":" + $hashCode;
}

function GetInstanceID($RootCauseIndex, $RootCauses, $CatchAlls, $CatchAllsAltRC)
{
    #approach for generating unique instance ID:
    # (1) the root cause GUID (stripped of the { })
    # (2) the hash code  of the first repair's text
    #     the repair text is guaranteed to be unique between root causes, and constant across reruns
    #     If no repairs, then the root cause text hash code is used

    $hashCode = 0
    $rootCauseID = 0

    #find the first repair for this root cause
    $rootCauseCount = $RootCauses.Count
    $RootCauses.Reset()
    for($i=0; $i -lt $rootCauseCount; $i++)
    {
        $rootCause=$RootCauses.Next;

        #root cause index is the index of the root cause in the root cause list
        #find the specific root cause
        if($i -eq $RootCauseIndex)
        {
            break;
        }
    }

    if($i -eq $rootCauseCount)
    {
        throw "Could not find a root cause with index " + $RootCauseIndex;
    }

    return GetInstanceIDRC($rootCause) ($CatchAlls) ($CatchAllsAltRC);
}

function GetSkipReasonText($Reason)
{
    #this is for debug, OK to not localize
    if($Reason -eq $NDF_SKIPREASON_ADAPTER)
    {
        return "An interactive fix for another network interface has been attempted."
    }
    elseif($Reason -eq $NDF_SKIPREASON_DUPLICATE)
    {
        return "Another repair with the same ID applying to the same network interface has been attempted."
    }
}

function InContextEntry()
{
    $IT_HelperClassName = Get-DiagInput -ID "IT_HelperClassName"
    if($IT_HelperClassName -eq $null   -or  $IT_HelperClassName[0].Length -eq 0) {
      #Failed retriving HelperClassName from In-Context answer file
      return $null
    }

    #get input attributes
    $IT_HelperAttributes = Get-DiagInput -ID "IT_HelperAttributes"
    if($IT_HelperAttributes -eq $null) {
      #Failed retriving HelperAttributes from In-Context answer file
      return $null
    }

    return @{"HelperClassName" = $IT_HelperClassName; "HelperAttributes" = $IT_HelperAttributes}
}

function EscapeForRTF($Text)
{
    $textToEscape = $Text.Replace("\","\\")

    $sb = New-Object System.Text.StringBuilder $textToEscape.Length;
    for($i=0; $i -lt $textToEscape.Length; $i++)
    {
        $curChar = $textToEscape[$i];
        if($curChar -eq '\n')
        {
            $null = $sb.Append("\par");
        }
        elseif(($curChar -lt 0x20) -or ($curChar -eq '{') -or ($curChar -eq '}') -or ($curChar -eq '\\'))
        {
            $null = $sb.Append("\'");
            $null = $sb.Append(([int]$curChar).ToString("X2", [System.Globalization.CultureInfo]::InvariantCulture));
        }
        elseif($curChar -lt 0x80)
        {
            $null = $sb.Append($curChar);
        }
        else
        {
            $null = $sb.Append("\u");
            $null = $sb.Append(([int]$curChar).ToString([System.Globalization.CultureInfo]::InvariantCulture));
            $null = $sb.Append('?');
        }

    }

   return $sb.ToString();

}

function IsValidURL($URL)
{
    &{
        $uri = [System.URI]($URL);
        $scheme = $uri.scheme;
        if(($scheme -eq "http" ) -or ($scheme -eq "https") -or ($scheme -eq "ftp"))
        {
            return $uri.ToString();
        }
        else
        {
            return $null;
        }
    }
     trap [Exception]
    {
        return $null;
    }
}

function GetDefaultBrowser()
{
    [string]$assocString = $null
    $dll = "NetworkDiagnosticSnapIn.dll"

    try
    {
        RegSnapin $dll
    
        $assocString = [Microsoft.Windows.Diagnosis.Network.AssociationInfo]::GetAssociation("http","open");
        trap [Exception]
        {
            $assocString = $null;
        }
    }
    finally
    {
        UnregSnapin $dll
    }

    return $assocString;
}

function GetWebNDFIncidentData($URL, $DefaultConnectivity)
{
    #build entry point parameters
    $haXML = "<HelperAttributes><HelperAttribute><Name>URL</Name><Type>AT_STRING</Type><Value><![CDATA[" + $URL +  "]]></Value></HelperAttribute>"
    if($DefaultConnectivity)
    {
        #sqm explorer as the client rather than sdiaghost.exe
        $haXML += "<HelperAttribute><Name>NDFSQMCallerApplication</Name><Type>AT_STRING</Type><Value>Windows\Explorer.EXE</Value></HelperAttribute>"
        $defaultBrowser = GetDefaultBrowser;
        if($defaultBrowser)
        {
            $haXML += "<HelperAttribute><Name>AppID</Name><Type>AT_STRING</Type><Value>"+ $defaultBrowser + "</Value></HelperAttribute>"
        }
    }
    $haXML += "</HelperAttributes>"
    return @{"HelperClassName" = "WinInetHelperClass"; "HelperAttributes" =$haXML}
}

function GetValidURL($CandidateURL)
{
    $toReturn = $null
    $url = IsValidURL $CandidateURL
    if($url -eq $null)
    {
        if($CandidateURL.IndexOf("://") -eq -1)
        {
            $updatedURL = "http://" + $CandidateURL
            $url = IsValidURL $updatedURL
            if($url)
            {
                $toReturn = $url
            }
        }
    }
    else
    {
        $toReturn = $url
    }

    return $toReturn
}

function GetErrorRTF($Description, $Error)
{
  $escapedDesc = EscapeForRTF $Description;
  $escapedError = EscapeForRTF $Error;
  $rtf = LoadResourceString($ERROR_MSG_RTF_RESOURCE);
  return $rtf.Replace("%DESC%", $escapedDesc).Replace("%ERROR%", $escapedError);
}

function WebEntry()
{
    $IT_WebChoice = Get-DiagInput -ID "IT_WebChoice"
    if($IT_WebChoice -eq $null)
    {
          #Failed retriving Web Choice
          return $null
    }

    $IT_URL = $DefaultDiagURL
    if(!($IT_WebChoice -eq "Internet"))
    {
        $IT_URL = Get-DiagInput -ID "IT_URL"
        if($IT_URL -eq $null) {
          #Failed retriving URL
          return $null
        }

        #verify that it is a valid URL
        $validURL = GetValidURL $IT_URL[0]
        while($validURL -eq $null)
        {
                #build the RTF text
                $replacedError = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.interaction_InvalidURL_FormatError, $IT_URL[0]);
                $RTFText = GetErrorRTF ($localizationString.interaction_InvalidURL_Desc) ($replacedError);

                #reprompt for input
                $IT_URL = Get-DiagInput -ID "IT_Invalid_URL" -p @{"URL" = $IT_URL; "RTFText" = $RTFText}
                if($IT_URL -eq $null) {
                      #Failed retriving URL
                      return $null
                }

                $validURL = GetValidURL $IT_URL[0]
        }
    }

    return GetWebNDFIncidentData $validURL $false
}

function IsUNCFormat($UNC)
{
     &{
        $uri = [System.URI]($UNC);
        $scheme = $uri.scheme;
        if(($scheme -eq "file" ))
        {
            if($uri.IsUnc)
            {
                return $uri.LocalPath;
            }
        }
        return $null;
    }
     trap [Exception]
    {
        return $null;
    }
}

#function assumes passed in UNC is in \\host\share form (share can be missing)
function ContainsInvalidUNCChars($UNC)
{
    &{
        #will return an exception if the string has invalid characters
        $ignoreResult = [System.IO.Path]::IsPathRooted($UNC)

        #check the path for invalid characters
        #remove the starting slashes
        $tmp = $UNC.Substring(2)
        $nextSlash = $tmp.IndexOf("\")
        if(($nextSlash -lt 0) -or ($nextSlash -eq ($nextSlash.Length - 1)))
        {
            #string only contains hostname
            #hostname is already validated in IsUNCFormat function
            return $false
        }
        #remove host and backslash after host
        $UNCPath = $tmp.Substring($nextSlash+1)

        #under certain circumstances some of these make it through the above check
        #so we do a direct sanity check here
        if(!($UNCPath.IndexOfAny(@('/',':','*','?','"','<','>','|')) -eq -1))
        {
            return $true;
        }

        return $false;
    }
    trap [Exception]
    {
        return $true;
    }
}

function GetValidUNC($CandidateUNC)
{
    $toReturn = $null

    #is it valid
    $unc = IsUNCFormat $CandidateUNC
    if($unc)
    {
        $invalidChars = ContainsInvalidUNCChars $unc
        if($invalidChars)
        {
            $toReturn = -1;
        }
        else
        {
            $toReturn = $unc
        }
    }

    return $toReturn;
}


function GetUNCNDFIncidentData($UNC)
{
    #build entry point parameters
    $haXML = "<HelperAttributes><HelperAttribute><Name>UNCPath</Name><Type>AT_STRING</Type><Value><![CDATA[" + $UNC +  "]]></Value></HelperAttribute></HelperAttributes>"
    return @{"HelperClassName" = "SMBHelperClass"; "HelperAttributes" =$haXML}
}

function FileSharingEntry()
{
    $IT_UNC = Get-DiagInput -ID "IT_UNC"
    if($IT_UNC -eq $null) {
      #Failed retriving UNC path
      return $null
    }

    #assign input to non-array variable to facilitate usage and transform
    $validUNC = GetValidUNC $IT_UNC[0]
    while((!$validUNC) -or ($validUNC -eq -1))
    {
        #build the RTF text
        #use original entry for re-prompt even though "file://" UNC may have been transformed
        $replacedError = "";
        if(!$validUNC)
        {
            $replacedError = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.interaction_InvalidUNC_FormatError, $IT_UNC[0]);
        }
        else
        {
            $replacedError = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.interaction_InvalidUNC_CharError, $IT_UNC[0]);
        }
        $RTFText = GetErrorRTF ($localizationString.interaction_InvalidUNC_Desc) ($replacedError);

        #reprompt for input
        $IT_UNC = Get-DiagInput -ID "IT_Invalid_UNC" -p @{"UNC" = $IT_UNC; "RTFText" = $RTFText}
        if($IT_UNC -eq $null) {
              #Failed retriving UNC path
              return $null
        }

        $validUNC = GetValidUNC $IT_UNC[0]
    }

    return GetUNCNDFIncidentData $validUNC
}

function NetworkAdapterEntry()
{
    #enumerate interfaces to build options list
    $interfaces = get-wmiobject -class Win32_NetworkAdapter
    #hash table with options
    $optionList = @()
    foreach($curInterface in $interfaces)
    {
        if($curInterface.GUID -ne $null)
        {
              $curHash = @{"Name"=$curInterface.NetConnectionID}
              $curHash += @{"Description"=$curInterface.NetConnectionID}
              $curHash += @{"Value"=$curInterface.GUID}

              $optionList += @($curHash)
        }
    }

    if($optionList.Count -gt 1)
    {
        #add zero guid entry to check all interfaces
        $optionList += @(@{"Name"=$localizationString.interaction_AllAdapters; "Description"=$localizationString.interaction_AllAdapters; "Value"="{00000000-0000-0000-0000-000000000000}"; "ExtensionPoint"="<Default />"})

        #get interface selection from user
        $IT_NetworkAdapter = Get-DiagInput -ID "IT_NetworkAdapter" -c $optionList

        if($IT_NetworkAdapter -eq $null) {
           throw "Failed retriving Network Connetion ID from user"
        }
    }
    elseif($optionList.Count -eq 1)
    {
        $IT_NetworkAdapter = $optionList[0]["Value"]
    }
    else
    {
        #No NICs, do zero GUID diag
        $IT_NetworkAdapter = "{00000000-0000-0000-0000-000000000000}"
    }

    #build entry point parameters
    $haXML = "<HelperAttributes><HelperAttribute><Name>guid</Name><Type>AT_GUID</Type><Value>" + $IT_NetworkAdapter +  "</Value></HelperAttribute></HelperAttributes>"
    return @{"HelperClassName" = "NetConnection"; "HelperAttributes" =$haXML}
}

function WinsockEntry()
{
    $IT_RemoteAddress = Get-DiagInput -ID "IT_RemoteAddress"
    if($IT_RemoteAddress -eq $null -or  $IT_RemoteAddress[0].Length -eq 0) {
      #Failed retriving Remote Address
      return $null
    }

    $IT_Protocol = Get-DiagInput -ID "IT_Protocol"
    if($IT_Protocol -eq $null -or  $IT_Protocol[0].Length -eq 0) {
      #Failed retriving Remote Port
      return $null
    }

    $IT_ApplicationID = Get-DiagInput -ID "IT_ApplicationID"
    if($IT_ApplicationID -eq $null -or  $IT_ApplicationID[0].Length -eq 0) {
      #Failed retriving Application ID
      return $null
    }

    #build entry point parameters
    $haXML = "<HelperAttributes><HelperAttribute><Name>remoteaddr</Name><Type>AT_SOCKADDR</Type><Value>" + $IT_RemoteAddress  +  "</Value></HelperAttribute>";
    $haXML += "<HelperAttribute><Name>protocol</Name><Type>AT_UINT32</Type><Value>" + $IT_Protocol +  "</Value></HelperAttribute>";
    $haXML += "<HelperAttribute><Name>localaddr</Name><Type>AT_SOCKADDR</Type><Value>0.0.0.0</Value></HelperAttribute>";
    $haXML += "<HelperAttribute><Name>appid</Name><Type>AT_STRING</Type><Value>" + $IT_ApplicationID + "</Value></HelperAttribute>";
    $haXML += "</HelperAttributes>";
    return @{"HelperClassName" = "Winsock"; "HelperAttributes" =$haXML}
}

function GroupingEntry()
{
    $IT_GroupName = Get-DiagInput -ID "IT_GroupName"
    if($IT_GroupName -eq $null -or  $IT_GroupName[0].Length -eq 0) {
      #Failed retriving Remote Address
      return $null
    }

    #build entry point parameters
    $haXML = "<HelperAttributes><HelperAttribute><Name>groupname</Name><Type>AT_STRING</Type><Value>" + $IT_GroupName +  "</Value></HelperAttribute></HelperAttributes>"
    return @{"HelperClassName" = "GroupingHelperClass"; "HelperAttributes" =$haXML}
}

function GetValidExePath($File)
{
     &{
        $uri = [System.URI]($File);
        $scheme = $uri.scheme;
        if(($scheme -eq "file" ))
        {
            #make sure it send in .exe
            if($File.ToLower().IndexOf(".exe") -eq ($File.Length - 4))
            {
                return $File;
            }
        }
        return $null;
    }
    trap [Exception]
    {
        return $null;
    }
}

function InboundEntry()
{
    $staticOptionRes = @($INBOUND_FILESHARE_RESOURCE, $INBOUND_REMOTEDESKTOP_RESOURCE, $INBOUND_DISCOVERY_RESOURCE)
    $staticOptions = @($INBOUND_FILESHARE_PARAM, $INBOUND_REMOTEDESKTOP_PARAM, $INBOUND_DISCOVERY_PARAM)
    # If defined for the corresponding option, the item will be filtered out if the current sku matches anything in the list
    # Sku values as defined in the OperatingSystemSKU property of Win32_OperatingSystem
    $SKUFilters = @($null, @(2,3,5,11), $null)

    #get the SKU, to filter out inappropriate static options
    $SKUObject = get-wmiobject -class Win32_OperatingSystem -property "OperatingSystemSKU"
    $SKU = $SKUObject.OperatingSystemSKU

    $optionList = @()
    $curOptionIndex = 0
    for($curStaticOption = 0; $curStaticOption -lt $staticOptions.Length; $curStaticOption++)
    {
        $SKUFilter = $SKUFilters[$curStaticOption]
        if($SKUFilter)
        {
            if($SKUFilter -contains $SKU)
            {
                #should filter out this option from the list because it is not present in the SKU
                continue;
            }
        }

        $curApp = LoadResourceString($staticOptionRes[$curStaticOption])
        $curHash = @{}
        $curHash.Add("Name",$curApp)
        $curHash.Add("Value",$curOptionIndex)
        $curHash.Add("Description",$curApp)
        $curHash.Add("HelperAttributeName","serviceid")
        $curHash.Add("HelperAttributeValue",$staticOptions[$curStaticOption])
        $optionList += $curHash
        $curOptionIndex++
    }

    #add dynamic options (do not fail if call fails)
    $script:ExpectingException = $true
    
    $dll = "NetworkDiagnosticSnapIn.dll"

    try
    {
        RegSnapin $dll
        
        $droppedApps = [Microsoft.Windows.Diagnosis.Network.FirewallApi.ManagedMethods]::GetDiagnosticAppInfo()
        $script:ExpectingException = $false
        if($droppedApps)
        {
            foreach($droppedApp in $droppedApps)
            {
                #omit svchosts since we cannot display a friendly name for them
                if($droppedApp.Path.IndexOf("svchost") -eq -1)
                {
                    $appEntryDisplayStr = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.interaction_Inbound_Exe, $droppedApp.FriendlyName);
                    $curHash = @{}
                    $curHash.Add("Name",$appEntryDisplayStr)
                    $curHash.Add("Value",$curOptionIndex)
                    $curHash.Add("Description",$droppedApp.FriendlyName)
                    $curHash.Add("HelperAttributeName","appid")
                    $curHash.Add("HelperAttributeValue",$droppedApp.Path)
                    $optionList += $curHash
                    $curOptionIndex++
                }
            }
        }
    }
    finally
    {
        UnregSnapin $dll
    }

    #add the last option to browse for files
    $curApp = LoadResourceString($INBOUND_OTHER_RESOURCE)
    $curHash = @{}
    $curHash.Add("Name",$curApp)
    $curHash.Add("Value",$curOptionIndex)
    $curHash.Add("Description",$curApp)
    $curHash.Add("HelperAttributeName","serviceid")
    $curHash.Add("HelperAttributeValue",$INBOUND_OTHER_RESOURCE)
    $optionList += $curHash


    #trap exception if it happens, and if expected don't fail
    trap [Exception]
    {
        if($script:ExpectingException)
        {
            $script:ExpectingException = $false
            "Exception: " + $_.Exception.GetType().FullName + " Message: " + $_.Exception.Message  | convertto-xml | Update-DiagReport -id GetDiagAppInfoFailure -name "GetDiagAppInfo" -verbosity Debug
            continue;
        }
        else
        {
            #rethrow exception
            throw $_.Exception;
        }
    }

    $IT_ServiceName = Get-DiagInput -ID "IT_ServiceName" -c $optionList
    if($IT_ServiceName -eq $null -or  $IT_ServiceName[0].Length -eq 0) {
      #Failed retriving service name
      return $null
    }

    $optionSelected = $optionList[$IT_ServiceName]
    $optionSelected = $optionSelected[0] #need to to this to get access to the dictionary entry object
    $HelperAttributeName = $null
    $HelperAttributeValue = $null

    if($optionSelected.HelperAttributeValue -eq $INBOUND_OTHER_RESOURCE)
    {
        #show the file browsing interaction so that the user can pick their own executable
        $IT_BrowseFile = Get-DiagInput -ID "IT_BrowseFile"
        if($IT_BrowseFile -eq $null) {
          #Failed retriving file
          return $null
        }

        $validExe = GetValidExePath $IT_BrowseFile[0]
        while(!$validExe)
        {
            #build the RTF text
            #build the error
            $replacedError = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.interaction_InvalidExe_FormatError , $IT_BrowseFile[0]);
            #only a single line
            $RTFText = GetErrorRTF ($localizationString.interaction_InvalidExe_Desc) ($replacedError);

            #reprompt for input
            $IT_BrowseFile = Get-DiagInput -ID "IT_Invalid_BrowseFile" -p @{"File" = $IT_BrowseFile[0]; "RTFText" = $RTFText}
            if($IT_BrowseFile -eq $null) {
              #Failed retriving file
              return $null
            }

            $validExe = GetValidExePath $IT_BrowseFile[0]
        }


        $HelperAttributeName = "appid"
        $HelperAttributeValue = $IT_BrowseFile;
    }
    else
    {
        $HelperAttributeName = $optionSelected.HelperAttributeName
        $HelperAttributeValue = $optionSelected.HelperAttributeValue
    }

    #build entry point parameters
    $haXML = "<HelperAttributes>"
    $haXML += "<HelperAttribute><Name>" + $HelperAttributeName + "</Name><Type>AT_STRING</Type><Value>" + $HelperAttributeValue +  "</Value></HelperAttribute>"
    $haXML += "<HelperAttribute><Name>localaddr</Name><Type>AT_SOCKADDR</Type><Value>0.0.0.0</Value></HelperAttribute>"
    $haXML += "</HelperAttributes>"
    return @{"HelperClassName" = "Winsock"; "HelperAttributes" =$haXML}
}

function DirectAccessEntry()
{
    $toReturn = $null;

    $path = "hklm:SOFTWARE\Policies\Microsoft\Windows\NetworkConnectivityStatusIndicator\CorporateConnectivity";
    if(test-path $path)
    {
        $corpReg = get-itemproperty -path $path
        if($corpReg.WebProbeURL -and $corpReg.WebProbeURL.Length -gt 0)
        {
            #build entry point parameters
            $haXML = "<HelperAttributes><HelperAttribute><Name>URL</Name><Type>AT_STRING</Type><Value>" + $corpReg.WebProbeURL +  "</Value></HelperAttribute></HelperAttributes>"
            $toReturn = @{"HelperClassName" = "WinInetHelperClass"; "HelperAttributes" =$haXML}
        }
        elseif($corpReg.DnsProbeHost -and $corpReg.DnsProbeHost  -gt 0)
        {
            #build entry point parameters
            $haXML = "<HelperAttributes><HelperAttribute><Name>QueryName</Name><Type>AT_STRING</Type><Value>" + $corpReg.DnsProbeHost +  "</Value></HelperAttribute></HelperAttributes>"
            $toReturn = @{"HelperClassName" = "DnsHelperClass"; "HelperAttributes" =$haXML}
        }
    }
    return $toReturn;
}

function DefaultConnectivityFollowUpEntry()
{
    $toReturn = $null

    $IT_DefaultConnectivityInitialChoice = Get-DiagInput -ID "IT_DefaultConnectivityInitialChoice"
    if($IT_DefaultConnectivityInitialChoice -eq $null -or  $IT_DefaultConnectivityInitialChoice[0].Length -eq 0)
    {
      #Failed retriving service name
      return $null
    }

    #clear the progress so that the last step doesn't show before things get started again
    Write-DiagProgress -activity " "

    if($IT_DefaultConnectivityInitialChoice -eq "Other")
    {
        #query which other entry point they wish to use
        $IT_DefaultConnectivityOtherChoice = Get-DiagInput -ID "IT_DefaultConnectivityOtherChoice"
        if($IT_DefaultConnectivityOtherChoice[0].Length -eq 0)
        {
          #Failed retriving service name
          return $null
        }

        if($IT_DefaultConnectivityOtherChoice -eq "Inbound")
        {
            $toReturn = InboundEntry
        }
        elseif($IT_DefaultConnectivityOtherChoice -eq "DirectAccess")
        {
            $toReturn = DirectAccessEntry
            if(!$toReturn)
            {
                #not provisioned, root cause outside of NDF
                Update-DiagRootCause -ID "{E42E5B5A-16E0-43f1-AB32-C94C608D269D}" -Detected $true
                return;
            }
        }
        elseif($IT_DefaultConnectivityOtherChoice -eq "NetworkAdapter")
        {
            $toReturn = NetworkAdapterEntry
        }
    }
    else
    {
        #query for the URL/UNC path
        $IT_URLOrUNC = Get-DiagInput -ID "IT_URLOrUNC"
        $validUNC = $null
        #Is it a valid URL?
        $validURL = GetValidURL $IT_URLOrUNC[0]
        if(!$validURL)
        {
            $validUNC = GetValidUNC $IT_URLOrUNC[0]
        }

        while((!$validURL) -and
                    ((!$validUNC) -or ($validUNC -eq -1)))
        {

            #build the RTF text
            $replacedError = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.interaction_InvalidURLOrUNC_FormatError, $IT_URLOrUNC[0]);
            $RTFText = GetErrorRTF ($localizationString.interaction_InvalidURLOrUNC_Desc) ($replacedError);

            #reprompt for input
            $IT_URLOrUNC = Get-DiagInput -ID "IT_Invalid_URLOrUNC" -p @{"URLOrUNC" = $IT_URLOrUNC; "RTFText" = $RTFText}
            if($IT_URLOrUNC -eq $null) {
                  #Failed retriving URL/UNC path
                  return $null
            }

            $validURL = GetValidURL $IT_URLOrUNC[0]
            if(!$validURL)
            {
                $validUNC = GetValidUNC $IT_URLOrUNC[0]
            }
        }

        if($validURL)
        {
            $toReturn = GetWebNDFIncidentData $validURL $false
        }
        else
        {
             $toReturn = GetUNCNDFIncidentData $validUNC
        }
    }

    return $toReturn
}

function GetRepair($RepairRank, $RCEnum)
{
    $RCEnum.Reset()
    $rootCauseCount = $RCEnum.Count
    for($i=0; $i -lt $rootCauseCount; $i++)
    {
        $rootCause = $RCEnum.Next;
        $repairEnum = $rootCause.Repairs
        $repairCount = $repairEnum.Count;
        for($r=0; $r -lt $repairCount; $r++)
        {
            $curRep = $repairEnum.Next
            if($curRep.Rank -eq $RepairRank)
            {
                return $curRep
            }
        }
    }
    return $null
}

function SplitString($FullString, [ref]$Title, [ref]$Rest)
{
     $newLineIndex = $FullString.IndexOf("`n");
     if(!($newLineIndex -eq -1))
     {
         $Title.value = $FullString.Substring(0, $newLineIndex)
         $Rest.value = $FullString.Substring($newLineIndex+1)
     }
     else
     {
        $Title.value = $FullString
        $Rest.value = ""
     }
}

function GetTitleAndDesc($RCorRep, [ref]$Title, [ref]$Desc)
{
    $descEx = $RCorRep.DescriptionEx
    if(!($descEx -eq $null))
    {
        $Title.value = $descEx.Title
        $Desc.value = $descEx.Description
        if($Desc.value -eq $null)
        {
            $Desc.value = ""
        }
    }
    else
    {
        #split the string into title and description using \n
        SplitString $RCorRep.Description ($Title) ($Desc)
    }
}

function GetButtonParams($Repair, [ref]$Params, $DefaultName, $DefaultDesc, $ExtensionName, $ButtonITName, $ButtonITDesc)
{
    #defaults
    $buttonName = $DefaultName;
    $buttonDesc = $DefaultDesc;

    $descriptionEx = $Repair.DescriptionEx;

    if($descriptionEx)
    {
        #this is a XML based root cause, get replacement parameters
        $paramEnum = $DescriptionEx.Extensions;
        $paramCount = $paramEnum.Count;
        $paramEnum.Reset()
        for($curP=0;$curP -lt $paramCount; $curP++)
        {
            $param = $paramEnum.Next;
            if($param.Name -eq $ExtensionName)
            {
                SplitString $param.Value ([ref]$buttonName) ([ref]$buttonDesc);
                break;
            }
        }
    }

    $Params.value.Add($ButtonITName, $buttonName);
    $Params.value.Add($ButtonITDesc, $buttonDesc);
}

function GetContinueButtonParams($Repair, [ref]$Params)
{
    GetButtonParams $Repair $Params $localizationString.interaction_DefaultContinueButtonName $localizationString.interaction_DefaultContinueButtonDescription "ContinueButtonText" "IT_P_ContinueButtonName" "IT_P_ContinueButtonDescription"
}

function GetLaunchButtonParams($Repair, [ref]$Params)
{
    GetButtonParams $Repair $Params $localizationString.interaction_DefaultLaunchButtonName "" "LaunchButtonText" "IT_P_LaunchButtonName" "IT_P_LaunchButtonDescription"
}

function GetUnmanifestedRootCause($RootCause, [ref]$Params, $catchAllRC)
{
    #Get name and description of root cause
    $Name = "";
    $Desc = "";
    #don't use DescriptionEx for unmanifested root causes
    SplitString $RootCause.Description ([ref]$Name) ([ref]$Desc)
    #add to outgoing param list
    $Params.value.Add("RootCauseName", $Name);
    $Params.value.Add("RootCauseDescription", $Desc);

    #check whether repairs require elevation of not
    $LUARepairs = @();
    $elevateRepairs = @();
    $localRepairs = @();

    $repairEnum = $rootCause.Repairs
    $repairEnum.Reset()
    for($i=0; $i -lt $repairEnum.Count; $i++)
    {
        $repair = $repairEnum.Next

        if($catchAllRC -and !($repair.Flags -band $RF_RESERVED_CA))
        {
            #this is a catch all RC treatment, so we should skip the non-catch all repairs
            continue;
        }
        elseif(!$catchAllRC -and ($repair.Flags -band $RF_RESERVED_CA))
        {
            #this is not a catch all RC treatment, so we should skip catch all repairs
            continue;
        }

        $requiredSid = $Repair.RequiredSidType;
        if($requiredSid -eq $null)
        {
            throw "Could not retrieve required repair SID"
        }
        elseif(($requiredSid -eq  $WinBuiltinAdministratorsSid) -or ($requiredSid -eq  $WinBuiltinNetworkConfigurationOperatorsSid))
        {
            $elevateRepairs += @($repair);
        }
        elseif($requiredSid -eq  $WinLocalLogonSid)
        {
            $localRepairs += @($repair);
        }
        else
        {
            $LUARepairs += @($repair);
        }
    }

    $LUACount = $LUARepairs.Length;
    $elevateCount = $elevateRepairs.Length;
    $localCount = $localRepairs.Length;

    if($elevateCount + $LUACount -gt 2)
    {
        #currently we don't support more than two repairs for
        #unmanifested repairs.
        "LUA: " + $LUACount + " Elevation: " + $elevateCount | convertto-xml | Update-DiagReport -id UnmanifestedRootCause -name "Unmanifested Root Cause" -description "Unsupported number of total repairs for unmanifested root cause." -verbosity Debug
        return $null;
    }
    elseif($localCount -and ($elevateCount -or $LUACount))
    {
        #we don't support a combination of Local repairs with any other kind of repair
        "LUA: " + $LUACount + " Elevation: " + $elevateCount | convertto-xml | Update-DiagReport -id UnmanifestedRootCause -name "Unmanifested Root Cause" -description "Unsupported repair combination including Local repair." -verbosity Debug
        return $null;
    }
    elseif($localCount -gt 1)
    {
        #we don't support more than one Local repair
        "Local: " + $localCount | convertto-xml | Update-DiagReport -id UnmanifestedRootCause -name "Unmanifested Root Cause" -description "Unsupported number of total Local repairs." -verbosity Debug
        return $null;
    }

    #populate the parameter data.
    #NOTE: LUA repairs always are listed before
    #          elevation repairs (makes manifesting easier)
    $repairCount = $null;

    #guarantees that LUA repairs are placed before elevated
    $allRepairs = $LUARepairs + $elevateRepairs + $localRepairs;

    #lua repairs
    for($i=0; $i -lt $allRepairs.Length; $i++, $repairCount++)
    {
        $repair = $allRepairs[$i];
        #get name and description of repair
        #don't use DescriptionEx for unmanifested root causes
        SplitString $repair.Description ([ref]$Name) ([ref]$Desc)
        #add to outgoing param list
        $Params.value.Add("RepairName"+$repairCount, $Name);
        $Params.value.Add("RepairDescription"+$repairCount, $Desc);
        $Params.value.Add("RepairID"+$repairCount, $repair.RepairID);
    }

    #add security boundary safe data
    $data = GetSBSData($Global:ndf.IncidentID)
    $params.value.Add("SBSData", $data)

    #keywords for escalation
    $keywords = GetKeywords($RootCause.DescriptionEx);
    if($keywords.Length -gt 0)
    {
        $params.value.Add("Keywords", $keywords);
    }

    if(($LUACount -eq 1) -and ($elevateCount -eq 1))
    {
        #return placeholder RC with mix of admin and LUA repairs
        return "{000000000-0000-0000-0000-000000000005}"
    }
    elseif($elevateCount -eq 1)
    {
        #return placeholder RC with single elevation repair
        return "{000000000-0000-0000-0000-000000000002}"
    }
    elseif($elevateCount -eq 2)
    {
        #return placeholder RC with two Admin repairs
        return "{000000000-0000-0000-0000-000000000004}"
    }
    elseif($LUACount -eq 1)
    {
        #check whether the single repair is info only or help topic to use alternate root cause
        $repair = $LUARepairs[0];
        #########
        try { $uiInfo = $repair.UiInfo; } catch{ $uiInfo = $null }
        
        $repairFlags = $repair.Flags;

        if(($uiInfo -and ($uiInfo.Type -eq $UIT_HELP_PANE)) -or ($repairFlags -band $RF_INFORMATION_ONLY))
        {
            #return placeholder RC with single info only or help topic repair
            return "{000000000-0000-0000-0000-000000000006}"
        }
        else
        {
            #return placeholder RC with single LUA repair
            return "{000000000-0000-0000-0000-000000000001}"
        }
    }
    elseif($LUACount -eq 2)
    {
        #return placeholder RC with two LUA repairs
        return "{000000000-0000-0000-0000-000000000003}"
    }
    elseif($localCount -eq 1)
    {
        #return placeholder RC with a single Local user repair
        return "{000000000-0000-0000-0000-000000000007}"
    }

    return $null;
} 

function CreateCab($FileList, $TargetFolder, $TargetCAB)
{

$ddf = @"
.OPTION EXPLICIT
.Set CabinetNameTemplate=$TargetCAB
.set DiskDirectoryTemplate=CDROM
.Set CompressionType=MSZIP
.Set UniqueFiles=`"OFF`"
.Set Cabinet=on
.Set DiskDirectory1=$TargetFolder
$($OFS="`r`n"; $FileList)
"@;

    $ddfFile = "NetworkConfiguration.ddf";

    $ddf | Out-File $ddfFile -Encoding Ascii;
    makecab /f $ddfFile;
    $succeeded = $?;
    #del $ddfFile;

    return $succeeded;
}

function HereString($text)
{
    $here = "@'`n" + $text + "`n'@"
    return $here
}

#$Commands is an array of hash pairs  "command": the command line to run, "file": the target filename,
#appended to the end of the command line
function AddCommandOutputToSession($Commands, $TargetCABName, $ReportHeader)
{
    #lets create the temporary folder for all this data
    $tempFolder = [System.IO.Path]::GetTempFileName();
    del $tempFolder; #delete the file
    mkdir $tempFolder; #make it into a folder

    #go into the folder to avoid leaving side-effect files behind
    pushd $tempFolder;

    #run the commands in the list
    $fileList = @();
    $timeMeasure = @(); #keeps track of length of execution for commands
    foreach($item in $Commands)
    {
        #measure time it takes to execute commands
        $start = get-date

        $targetFile = $tempFolder + "\" + $item["file"];
        $cmdline = $item["command"] + " " + (HereString $targetFile);
        $err = $($out = Invoke-expression  $cmdline) 2>&1;
        if(!$err)
        {
            #the call succeeded, add the target file to the list to CAB
            $fileList += @($item["file"]);
        }
        $runtime = (get-date) - $start;
        $timeMeasure += @(@{"command"=$item["command"];"runtime (ms)"=$runtime.TotalMilliseconds});
    }

    #create a CAB of the files
    $start = get-date
    if(CreateCab ($fileList) (".\") ($TargetCABName))
    {
        $runtime = (get-date) - $start;
        $timeMeasure += @(@{"command"="makecab.exe";"runtime (ms)"=$runtime.TotalMilliseconds});
        Update-DiagReport -ID NetworkData -name $ReportHeader -File ($tempFolder + "\"+ $TargetCABName)
    }

    $timeMeasure | convertto-xml | Update-DiagReport -ID ConfigCollectionRuntime -Name "Data Collection Time" -Verbosity Debug

    popd;

    remove-item -recurse -force $tempFolder;
}

function AddNetworkInfoToSession()
{
    Write-DiagProgress -activity $localizationString.progress_Collecting_Config

    $commands = @(
        @{"command"="ipconfig /all >"; "file"="ipconfig.all.txt"};
        @{"command"="route print >"; "file"="route.print.txt"};
    );

    AddCommandOutputToSession ($commands) ("NetworkConfiguration.cab") ($localizationString.OtherNetworkConfigReportName);

    Write-DiagProgress -activity " "
}

function GetUniqueFileName($IncidentID, $Operation)
{
    #get temp folder location
    $tempFolder = get-childitem -path env:temp

     #strip { } at the ends of the incident ID GUID, generate file name
     $uniqueFileName = $tempFolder.Value+"\"+$IncidentID.Substring(1,$IncidentID.Length-2)+"." + $Operation

    #append whether it's admin or not (to avoid name clashes, as op count resets after elevation)
    $isAdmin = IsAdmin
    if($isAdmin)
    {
        $uniqueFileName += ".Admin";
    }

    #initialize or increment op count
    if($Global:OpCount -eq $null)
    {
       $Global:OpCount = 0
    }
    else
    {
        $Global:OpCount++;
    }

    $uniqueFileName += "." + $Global:OpCount + ".etl";

    return $uniqueFileName
}

function AddTraceFileToSession($Ndf, $Name, $Operation)
{
    #NDF flushes the trace file every time we query for it
    #A unique name needs to be generated each time we add the file to the report,
    #otherwise it will overwrite the existing ETL file
    #The naming convention is as follows:
    #  IncidentID.Operation([Admin]).Counter.etl

    Write-DiagProgress -activity $localizationString.progress_Collecting_Logs

    $traceFile = $Ndf.TraceFile
    if($traceFile)
    {
        #get unique name
        $newFileName = GetUniqueFileName $Ndf.IncidentID $Operation

        #rename file
        move "$traceFile" "$newFileName"
        #add it to the report
        Update-DiagReport -ID NDFDebugLog -name $Name -File $newFileName
        #add HC events to the report
        AddNewHCEventsToSession $newFileName
        # delete the file name edited by Claton 
        #del "$newFileName"
    }
    else
    {
        $Name | convertto-xml | Update-DiagReport -id TraceFile -name "Trace File" -description "Failed while trying to retrieve the trace file for the session." -verbosity Debug
    }

    Write-DiagProgress -activity " "
}

function AddNewHCEventsToSession($TraceFile)
{
    #we keep track of all the events added to the report, so we don't add duplicates (this function is called multiple times)
    if($Global:ReportEvents -eq $null)
    {
        $Global:ReportEvents = @{};
    }

    $script:ExpectingException = $false

    &{
        $script:ExpectingException = $true
        $events = get-winevent -path $TraceFile -Oldest -FilterXPath "*[System[Provider[@Name='Microsoft-Windows-Diagnostics-Networking'] and (EventID=6100)]]" -ErrorAction SilentlyContinue
        $script:ExpectingException = $false
        foreach($event in $events)
        {
            #events indexed by time they were emitted
            if(($event -ne $null) -and !$Global:ReportEvents.ContainsKey($event.TimeCreated))
            {
                #Add helper class name to title so that it's easily distinguishable in the report without having to expand it
                $eventTitle = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.HelperClassEventNameWithHCName,
                                    [System.Globalization.CultureInfo]::CurrentUICulture.TextInfo.ToTitleCase($event.Properties[0].Value));

                "<Objects><Object Type=""System.String""><PRE><![CDATA["+$event.Message +"]]></PRE></Object></Objects>" | Update-DiagReport -id DiagInformation -name $eventTitle
                $Global:ReportEvents.Add($event.TimeCreated, $event)
            }
        }
    }
    trap [Exception]
    {
        if($script:ExpectingException)
        {
            "No admin helper class events were found." | convertto-xml | Update-DiagReport -id DiagEvents -name "Helper Class Events" -verbosity Debug
        }
        else
        {
            "Exception: " + $_.Exception.GetType().FullName + " Message: " + $_.Exception.Message  | convertto-xml | Update-DiagReport -id DiagEventsFailure -name "Helper Class Events" -description "Failed while retrieving helper class events." -verbosity Debug
        }
        return
    }
}

function LoadResourceString($ResourceString)
{
    [string]$bufStr = $null
    $dll = "NetworkDiagnosticSnapIn.dll"

    try
    {
        RegSnapin $dll
        
        $bufferSize = 512
        $buffer = New-Object System.Text.StringBuilder $bufferSize
        [Microsoft.Windows.Diagnosis.Network.NativeShellMethods]::SHLoadIndirectString($ResourceString, $buffer, $bufferSize, [IntPtr]::Zero)
        $bufStr = $buffer.ToString()
    }
    finally
    {
        UnregSnapin $dll
    }

    return $bufStr
}

function IsDPSStarted()
{
    $dpsService = get-service "DPS"
    if($dpsService)
    {
        if($dpsService.Status -ne "Running")
        {
            return $false;
        }
    }
    return $true;
}

function IsDPSDisabled()
{
    $dpsService = gwmi win32_service -f "name='DPS'"
    if($dpsService)
    {
        if($dpsService.StartMode -eq "Disabled")
        {
            return $true;
        }
    }
    return $false;
}

function IsSafeMode()
{
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    return [System.Windows.Forms.SystemInformation]::BootMode -ne 0
}

function IsHelpTopicAllowed($Link)
{
    $regValue = get-itemproperty -path hklm:\SYSTEM\CurrentControlSet\Control\NetDiagFx\Config\HelpTopic  -name $Link -ErrorAction SilentlyContinue -ErrorVariable regError
    if($regValue)
    {
        # check the DWORD value (the key to the value is the Value name: i.e., $Link) 
        # 1         - enabled
        # otherwise - disabled
        $filterValue = $regValue.$Link;
        if($filterValue -eq 1)
        {
            return $true;
        }
        else
        {
            return $false;
        }
    }
    elseif ($regError)
    {
        if(!($regError[0].CategoryInfo.Category -eq "InvalidArgument") -and  !($regError[0].CategoryInfo.Category -eq "ObjectNotFound"))
        {
            " Warning: Unexpected error when reading Help Topic Cause key : " + $regError[0].CategoryInfo.Category | convertto-xml | Update-DiagReport -id UnexpectedRegError -name "Unexpected Registry Error" -verbosity Debug
        }
        return $false;
    }
}
