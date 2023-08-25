#*=================================================================================
# Copyright © 2018, Microsoft Corporation. All rights reserved.

#*=================================================================================
#Function:	find-typeassembly
#Purpose:	Search all loaded assemblies for the named type
#Return:	assembly
#*=================================================================================
function find-typeassembly($typename) # return assembly
{
	foreach ($assembly in [appdomain]::currentdomain.getassemblies())
	{
		foreach ($type in $assembly.gettypes())
		{
			if ($type.fullname -eq $typename)
			{
				return $assembly
			}
		} # $type
	} # $assembly
	return $null
} # find-classassembly

# Initializing VideoDiagnosticUtil.dll and respective PInvokes
Set-Variable MAX_ADAPTERS -option Constant -value 10
Set-Variable MAX_OUTPUTS_PER_ADAPTER -option Constant -value 10
Set-Variable MAX_MONITORS_PER_OUTPUT -option Constant -value 5
Set-Variable DESCRIPTION_LENGTH -option Constant -value 128

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;


[StructLayout(LayoutKind.Sequential)]  
public struct PRIVATEMONITORINFO
{
    public uint  uiIsClone;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=128, ArraySubType=UnmanagedType.I2)]
    public char[] chConnectorType;
    public uint  uiConnectorType;
}

[StructLayout(LayoutKind.Sequential)]  
public struct OUTPUTINFO
{
    public uint uiIsPrimary;
    public uint uiResolutionX;
    public uint uiResolutionY;
    public uint uiAdapterId;
    public uint uiAttachedToDesktop;
    public uint uiNumMonitorsAttached;
    [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.Struct, SizeConst = 5)] 
    public PRIVATEMONITORINFO[] rgMonitorInfo;
}

[StructLayout(LayoutKind.Sequential)]  
public struct ADAPTERINFO
{
    public uint uiVendorId;
    public uint uiDeviceId;
    public uint uiSubSysId;
    public uint uiRevision;
    public uint uiIsSWAdapter;
    public uint uiNumOutputs;
    [MarshalAs(UnmanagedType.ByValArray, SizeConst=128, ArraySubType=UnmanagedType.I2)]
    public char[] chDescription;
    [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.Struct, SizeConst = 10)] 
    public OUTPUTINFO[] rgOutputInfo;
}

[StructLayout(LayoutKind.Sequential)]  
public struct DISPLAYTOPOLOGYMAP
{
    public uint hr;
    public uint uiNumAdapters;
    [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.Struct, SizeConst = 10)] 
    public ADAPTERINFO[] rgAdapterInfo;
}

namespace VideoDiagnostic
{
	public static class VideoConfigManager
	{
        //https://docs.microsoft.com/en-us/dotnet/framework/interop/marshaling-different-types-of-arrays
        [DllImport("VideoDiagnosticUtil.dll", PreserveSig = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern void IsDone( IntPtr aDisplayTopologyMap );
		[DllImport("VideoDiagnosticUtil.dll", PreserveSig = true, CallingConvention = CallingConvention.Cdecl)]
        public static extern uint IsHWDRMSupported( ref bool pfHWDRMSupported );

        public static DISPLAYTOPOLOGYMAP IsDiagnosticDone()
		{   		
            int iSizeOfStruct = Marshal.SizeOf( typeof( DISPLAYTOPOLOGYMAP ) );
            IntPtr pg_DisplayTopologyMap = Marshal.AllocCoTaskMem( iSizeOfStruct );
            
            IsDone( pg_DisplayTopologyMap );
            
            DISPLAYTOPOLOGYMAP g_DisplayTopologyMap = ( DISPLAYTOPOLOGYMAP )( Marshal.PtrToStructure( pg_DisplayTopologyMap, typeof( DISPLAYTOPOLOGYMAP ) ) );

            return g_DisplayTopologyMap;		
		}
    }
}

"@

#*=================================================================================
#Function:	cwos-stack
#Purpose:	Wrap current stack trace as a multi line string.
#Param:		optional $format -- default $null is 'long'
#Param:		optional $maxparamlength -- -1 is full, default 0 is interpreted as 50
#Return:	[string]
#*=================================================================================
function cwos-stack([string] $stackformat, [int] $maxparamlength)
{
	if ([string]::isnullorempty($stackformat)) 
	{ $stackformat = 'long' }
	if ($maxparamlength -eq 0) 
	{ $maxparamlength = 50 }
	if (@(get-command *get-pscallstack).length -eq 0)
	{ return '(Stack trace is unavailable)' }	
	$callstack = @( &{
		get-pscallstack
		trap [management.automation.commandnotfoundexception] 
		{ throw 'Failed obtain call stack' }
	} )
	$trimargs = {
		# debug: [console]::error.writeline("trimargs $($_.command) $($_.arguments)")
		$args = $_.arguments
		if ($maxparamlength -gt 1 -and $_.arguments.length -gt $maxparamlength)
		{ 
			$x = $_ | select *
			$x.arguments = '[' + $_.arguments.substring(1, $maxparamlength - 2) + '...]'
			return $x
		}
		else
		{
			return $_
		}
	} # $trimargs
	switch ($stackformat)
	{
		'long' {
			$f = { "$($_.location): $($_.command)$($_.arguments)" }
		} # long
	} # switch
	$l = @( $callstack |% $trimargs |% $f )
	return [string]::join("`n", $l)
} # cwos-stack

#*=================================================================================
#Function:	Import-CS
#Purpose:	Encapsulate loading of C# code.
#			The sourcefiles are ignored when the sourcetext is specified.
#			The classname should be declared by the c# source to indicate that the source was successfully loaded.
#Throw:		If $sourcefile is missing and $sourcetext is blank.
#Throw:		If $classname is not declared by the c# source.
#Throw:		If the class already exists, and -force is requested.  Re-loading a class is not supported.
#Return:	type
#Notice:	The source may declare many types, and NOT necessary to use the returned type reference.
#Notice:	The source files should have any import statements INSIDE the namespace.
#			At runtime, the c# code will fail to compile if import statements are outside 
#			namespace in the second and following files.
#*=================================================================================
function import-cs([string] $classname, [string[]] $sourcefile, [string] $sourcetext, [switch] $force, [string[]] $referencedassemblies,[string]$Language = "CSharp",[string]$CodeDomProvider)
{
	$type = $classname -as [type]
	if ($type -ne $null)
	{
		if ($force)
		{
			# Remove the old instance of this class
			throw "Unloading assemblies is not supported in this version"
		}
		else
		{
			# The class has already been loaded
			return $type
		}
	}
	if ($sourcetext -lt ' ')
	{
		foreach ($file in $sourcefile)
		{
			if (test-path $file)
			{
				$sourcetext += "`n" + [string]::join("`n", (get-content $file))
			}
			else
			{
				$title = "Missing c# source $file"
				[string] $message = $myinvocation.positionmessage
				$xml = $myinvocation | convertto-xml
				update-diagreport `
					-xml $xml `
					-id 'embeddedcodemissing' `
					-name $title `
					-description $message `
					-verbosity 'error' 
				throw "Source file $file does not exist"
			}
		} # for $file
	}
	&{
		$compilefile = 'compilefile.txt'
		$count = $error.count
		if(![string]::IsNullOrEmpty($CodeDomProvider))
		{
				$out = add-type `
			-typedefinition $sourcetext `
			-referencedassemblies $referencedassemblies -CodeDomProvider $CodeDomProvider `
			-ignorewarnings 2> $compilefile
		}
		else
		{		
				$out = add-type `
			-typedefinition $sourcetext `
			-referencedassemblies $referencedassemblies -Language $language `
			-ignorewarnings  2> $compilefile
		}

		$compileresult = cat $compilefile
		if ($error.count -ne $count)
		{
			$e = $error[0]
			$title = "Error " + $e.FullyQualifiedErrorId
			[string] $position = $e.invocationinfo.positionmessage
			[string] $message = $e.exception
			$message += $position
			$xml = @(cwos-stack) + $e + $sourcefile + $stdout + $stderr + $out | convertto-xml
			update-diagreport `
				-xml $xml `
				-id 'embeddedcodeerror' `
				-name 'Embedded Code Error' `
				-description $position `
				-verbosity 'error' 
			throw "Error compiling $sourcefile"
		}
		trap 
		{
			#$stdout = cat $outfile
			#$stderr = cat $errfile
			$e = $error[0]
			$title = "Error " + $e.FullyQualifiedErrorId
			[string] $position = $e.invocationinfo.positionmessage
			[string] $message = $e.exception
			$message += $position
			$xml = @(cwos-stack) + $sourcefile + $compileresult + $out + $e | convertto-xml
			update-diagreport `
				-xml $xml `
				-id 'embeddedcodeerror' `
				-name 'Embedded Code Error' `
				-description $position `
				-verbosity 'error' 
			throw "Error compiling $sourcefile"
		}
	} # compile
	$type = $classname -as [type]
	if ($type -eq $null)
	{
		$xml = @(cwos-stack) + $sourcefile + $compileresult + $out + $e | convertto-xml
		update-diagreport `
			-xml $xml `
			-id 'embeddedcodeerror' `
			-name 'Embedded Code Error' `
			-description $position `
			-verbosity 'error' 
		throw "The type [$classname] was not defined after compiling files [$sourcefile]"
	}
	return $type
} # Import-CS

#*=================================================================================
#Function : log-cwosscriptexception
#Purpose :  Writes the latest script exception to the diagnostic report
#Return  : [bool] $continue -- the script should terminate if $continue is false.
#*=================================================================================
function log-cwosscriptexception()
{
	$e = $error[0]
	$title = "Error " + $e.FullyQualifiedErrorId
	[string] $position = $e.invocationinfo.positionmessage
	[string] $message = $e.exception
	$message += $position
	[bool] $continue = $false
		$flags = [windows.forms.messageboxbuttons]::okcancel
		$result = [windows.forms.messagebox]::show($message, $title, $flags)
		$continue = $result -eq [windows.forms.dialogresult]::ok
##line 219
	$xml = $e | convertto-xml
	update-diagreport `
		-xml $xml `
		-id 'scripterror' `
		-name 'Script Error' `
		-description $position `
		-verbosity 'error' 
	return $continue
	
	trap
	{
		$null = [reflection.assembly]::loadwithpartialname("system.windows.forms")
		$message = "Error while writing error report"
		$message += $error[0].invocationinfo.positionmessage
		$message += $error[0].exception
		[windows.forms.messagebox]::show($message)
	}
} # log-cwosscriptexception

#*=================================================================================
#Function : Set-PSVersionTable
#Purpose :  Check system for current PowerShell Version
#Return  : void
#*=================================================================================
function Set-PSVersionTable 

{ 
     if (!(test-path variable:PSVersionTable))
	 {
	 	$myPSVersionTable = @{}		
		[Version]$CLRVersion = $([System.Reflection.Assembly]::GetExecutingAssembly().ImageRuntimeVersion).TrimStart("v")
		[Version]$BuildVersion = $(Get-WmiObject Win32_OperatingSystem).Version
		[Version]$PSVersion = "1.0"
		[Version]$WSManStackVersion = "0.0"
		[Array]$PSCompatibleVersions = @($PSVersion)
		[Version]$SerializationVersion = "0.0.0.0"
		[Version]$PSRemotingProtocolVersion = "0.0.0.0"

		$myPSVersionTable.Add('CLRVersion', $CLRVersion)		
		$myPSVersionTable.Add('BuildVers$PSion', $BuildVersion)
		$myPSVersionTable.Add('PSVersion', $PSVersion)
		$myPSVersionTable.Add('WSManStackVersion', $WSManStackVersion)
		$myPSVersionTable.Add('PSCompatibleVersions', $PSCompatibleVersions)
		$myPSVersionTable.Add('SerializationVersion', $SerializationVersion)
		$myPSVersionTable.Add('PSRemotingProtocolVersion', $PSRemotingProtocolVersion)
		
		Set-Variable -Name PSVersionTable -Scope Global -Value $myPSVersionTable -Option Constant
	 } 
}
Set-PSVersionTable

# If Powershell Version is less than 2.0 load compatibility scripts
#if ($PSVersionTable.PSVersion -lt '2.0')
#{ 
#	. .\utils_PowerShell_1_0.ps1
#}

#*=================================================================================
#Function : Save
#Purpose :  will check the version and accordingly save input xml to a file
#Return  : 
#*=================================================================================
function Save()
{
    param($xmldoc,$path)
    trap [Exception] {continue;}
    if($PSVersionTable.PSVersion -lt '2.0')
    { 
        if($xmldoc -ne $null)
        {
            $xmldoc | out-file $path -Force
        }
    }
    else 
    {
        if($xmldoc -ne $null)
        {
            $xmldoc.save($path)
        }
    } 
}
# Place ProductID in Debug Report
function Set-DiagPID([string]$ProductName, [string]$ProductID)
{
	$PIDObject = "" | Select-Object ProductName						# Return object
	$PIDObject.ProductName = $ProductName
	
	add-member -inputobject $PIDObject -membertype noteproperty -name ProductID -value $ProductID
	
	(convertto-xml -InputObject $PIDObject) | update-diagreport -id OAS_DATAPOINT_ID -name "OAS_DATAPOINT" -description "OAS Data Point for OAS submission" -verbosity debug
}

#postback
function Test-PostBack
{
    [CmdletBinding()]
    PARAM
    (
        [Alias('S')]
        [Parameter(Position = 1, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string] $CurrentScriptName
    )
    PROCESS 
    {
        # Writing the trace to current directory
        $CurrentScriptName = ("{0}.temp" -f [System.IO.Path]::GetFileNameWithoutExtension($CurrentScriptName))

        if(Test-Path($CurrentScriptName))
        {
            return $true
        }

        'Executed' >> $CurrentScriptName
        return $false
    }
}

#*=================================================================================
#End
#*=================================================================================
# ///////////////////////////////////////////////////////////////////
# adding pop messagebox for compatibility with ps1 and ps2
###########
# Pop up window
############
function Pop-Msg {
	 param([string]$msg ="message",
	 [string]$ttl = "Title",
	 [int]$type = 64) 
	 $popwin = new-object -comobject wscript.shell
	 $null = $popwin.popup($msg,0,$ttl,$type)
	 remove-variable popwin
}
