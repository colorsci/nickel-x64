# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

<#
	DESCRIPTION:
	  CL_Registry.ps1 is common library for BITS troubleshooter.

	ARGUMENTS:
	  None

	RETURNS:
	  None

	FUNCTIONS:
	  CompareByteArray
	  Test-Value
	  CreateRegObject
	  Create-RegistryValue
	  Test-RegistryValue
	  Test-RegistryValueThorough
	  Convert-IntoPSRegistryValueType
	  Get-RegValueKind
	  Get-Hive
	  Get-SubKey
	  Get-RegValueData
	  Create-SubKeyRecursive
	  Concatenate-RegistryPaths
	  Trim-StringStartsWithChar
	  Trim-StringEndsWithChar
	  Get-RegistryKeyShortName
	  Create-PackageRegistryKey
	  Create-RestartedByPackKey
	  Set-RestorePointRegistry
	  Get-RestorePoint
	  Create-StateAll
	  Reset-State
	  Delete-CurrentPackageStates
	  Delete-AllPackageStates
	  Set-RestartFlag
	  Create-RegistryKeys
	  Is-PackRestart
	  Is-ScriptRun
	  Is-RootCauseDetected
	  Is-VerifierDetected
	  Save-Parameter
	  Get-Parameter
	  Delete-PreviousStatesIfALLRcFalse
#>

function CompareByteArray()
{
	param($array1,$array2)
	if($array1 -eq $null -or $array2 -eq $null)
	{
		return $false
	}
	$array2 = $array2.Split(' ')
	for($i=0;$i -lt $array2.Length;$i = $i+1)
	{
		if($array1[$i] -ne $array2[$i])
		{
			$x = $array1[$i]
			$y = $array2[$i]
			return $false
		}
	}
	return $true;

}

function Test-Value
{
	param(	[string]$Path = $(throw 'A path must be specified'), 
			[string]$ValueName = $(throw 'A value name must be specified') )

	if(Test-Path $path)
	{	
		[bool]$ValueFound = $false
		$myKey = Get-item -path $path -Force
		$values = $myKey.GetValueNames()
		foreach($name in $values)
		{
			if($name.ToLower() -eq $ValueName.ToLower())
			{ 
				$ValueFound = $true
				break
			}
		}
		return $ValueFound
	}
	else
	{
		return $false
	}
}

function CreateRegObject([string]$reg_path = $(throw 'No registry path is specified'),[string]$value_name = $(throw 'No registry value name is specified'), [string]$regitemvalue_original = $(throw 'No original registry value is specified'), [string]$regitemvalue_reset = $(throw 'No new registry value is specified'))
{
	$regitemvalue_original = $regitemvalue_original
	$regitemvalue_reset = $regitemvalue_reset
	$regitem = New-Object -TypeName System.Management.Automation.PSObject
	$regpath = $reg_path.replace('Registry::','')
	$valuename = $value_name

	Add-Member -InputObject $regitem -MemberType NoteProperty -Name 'reg_path'-Value $regpath
	Add-Member -InputObject $regitem -MemberType NoteProperty -Name 'value_name'-Value $valuename
	Add-Member -InputObject $regitem -MemberType NoteProperty -Name 'regitemvalue_original'  -Value $regitemvalue_original
	Add-Member -InputObject $regitem -MemberType NoteProperty -Name 'regitemvalue_reset' -Value $regitemvalue_reset

	return $regitem
}

Function Create-RegistryValue
{
	<#
		DESCRIPTION
		  Uses Key, Value, Data & Type to write registry if set incorrectly or not exist
	
		PARAMETERS
		  key_path ie: hklm:\software\microsoft\windows
		  key_value ie: 'RegistrationID'
		  value_data ie: 'THIS-IS-USER-LICENSE-12345'
		  value_type ie: 'String' (accepts String, ExpandString, Binary, DWord, MultiString, QWord)

		RESULT
		Creates Registry Value with optional return value      
	#>

	param ( [string]$key_path, [string]$key_value, [string]$value_data, [string]$value_type )

	$key_all_values = Get-ItemProperty $key_path
	$value_type_equivalent = Convert-IntoPSRegistryValueType $value_type

	# Key Exists
	if( Test-RegistryValue $key_path $key_value )
	{    
		$type_check = Get-RegValueKind . $key_path $key_value  
		# Check Value Type & Data
		if( $value_type -eq $type_check -and $key_all_values.$key_value -eq $value_data )
		{    
			# Everything is correct
			"$key_value exists and set correctly."
		}
		else 
		{
			# delete regKey value
			Remove-ItemProperty $key_path $key_value -Force -ea silentlycontinue | Out-Null        
			# create correct one
			New-ItemProperty $key_path -Name $key_value -Value $value_data -PropertyType $value_type -force -ea silentlycontinue | Out-Null
			"$key_value was reset."
		}
	}
	else
	{   
		# create correct regKey value
		New-ItemProperty $key_path -Name $key_value -Value $value_data -PropertyType $value_type | Out-Null
		"$key_value didn't exist. Just created."
	}
}

Function Test-RegistryValue
{
	<#
		DESCRIPTION
		  Checks whether Registry Key exist or not.
		
		ARGUMENTS
		  key_path: Registry key path
		  key_value: Value of registry key

		RETURNS
		  True if exists otherwise False
	#>

	param ([string]$key_path, [string]$key_value)
	
	if (Test-Path $key_path)
	{
		$k = Get-Item $key_path
		foreach ($i in $k.Property)
		{
			if($i -eq $key_value)
			{
				return $true
			}
		}
	}
	return $false
}

#################################################
#  FUNCTION : Is Registry Value Set Correctly ? T/F
#################################################
Function Test-RegistryValueThorough()
{
	Param( [string]$key_path, [string]$key_value, [string]$value_data, [string]$value_type )

	$key_all_values = Get-ItemProperty $key_path -ea SilentlyContinue
	$value_type_equivalent = Convert-IntoPSRegistryValueType $value_type
	[bool] $tf = 0
	### Key Exists
	if( Test-RegistryValue $key_path $key_value )
	{
		# Check Key Type & Value
		#Make sure you expand the variable if it doesn't start with @
		#Expand before hand any variable with %systemroot% etc.
		# Compare Byte arrays alone
		if($value_type -eq "MultiString")
		{	    
			$isdataequal = CompareByteArray -array1 ([String[]]$key_all_values.$key_value) -array2 $value_data
		}
		elseif($value_type -eq "BINARY")
		{
			$isdataequal = CompareByteArray -array1 ([Byte[]]$key_all_values.$key_value) -array2 $value_data
		}
		elseif($value_type_equivalent -eq "String" -and $value_data.Startswith("%"))
		{
			$value_data = [Environment]::ExpandEnvironmentVariables($value_data)
			$isdataequal =  $key_all_values.$key_value -eq $value_data 
		}
		elseif("Int32" -eq $value_type_equivalent)
		{
			$isdataequal =  [Convert]::ToInt32([int32]$key_all_values.$key_value) -eq  [Convert]::ToInt32([int32]$value_data)
		
		}
		elseif("Int64" -eq $value_type_equivalent )
		{
			$isdataequal =  [Convert]::ToInt64($key_all_values.$key_value) -eq  [Convert]::ToInt64($value_data)
		}
		else
		{
			$isdataequal =  $key_all_values.$key_value -eq $value_data 
		}
		if( $key_all_values.$key_value.GetType().Name -eq $value_type_equivalent -and $isdataequal )
		{    
			$tf = 1
		}
		else 
		{
			$tf = 0
		}
	}
	else
	{   
		$tf = 0
	}
	$tf
}

#################################################
#  FUNCTION : Return Type that Powershell reads from GetType().Name
#  $key_all_values = Get-ItemProperty $key_path
#  $key_all_values.$key_value.GetType().Name
#################################################
Function Convert-IntoPSRegistryValueType($key_type)
{
	# "String, ExpandString, Binary, DWord, MultiString, QWord, Unknown"
	switch ($value_type) 
	{ 
		"String" {$value_type_equivalent = "String" } 
		"ExpandString" {$value_type_equivalent = "String" } 
		"Binary" {$value_type_equivalent = "Byte[]" } 
		"DWord" {$value_type_equivalent = "Int32" }         
		"MultiString" {$value_type_equivalent = "String[]" } 
		"QWord" {$value_type_equivalent = "Int64" } 
		#"Unknown" {$value_data_equivalent = }                                         
		default {$value_type_equivalent = "String" }
	}
	$value_type_equivalent    

}

#################################################
# Function: Get-RegValueKind
# Description: Get the registry value type (e.g, string,dword etc)
# Return Value: None
#################################################

function Get-RegValueKind{
	param(
		[string]$server = ".",
		[string]$key_path, 
		[string]$valueName
	)

	$hive = Get-Hive $key_path
	### $keyHive
	$keyName = Get-SubKey $key_path
	#### $key_path    

	$hives = [enum]::getnames([Microsoft.Win32.RegistryHive])

	if($hives -notcontains $hive){
		write-error "Invalid hive value";
		return;
	}
	$regHive = [Microsoft.Win32.RegistryHive]$hive;

	if( -not ( test-path $regHive ) ){
		return
	}

	$regKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($regHive,$server);
	$subKey = $regKey.OpenSubKey($keyName);
		
	if(!$subKey){
		### write-error "The specified registry key does not exist.";
		return;
	}
	$regVal=$subKey.GetValueKind($valueName);

	if(!$regVal){
		### write-error "The specified registry value does not exist.";
		return;
	} else {
		$regVal;
	}
}

#################################################
# Function: Get-RegValueKind
# Description: Get the registry value type (e.g, string,dword etc)
# Return Value: None
#################################################
function Get-Hive
{
		param( [string]$key )    
		#$SubKey
			
		$subkey = $key.split(":")
		#$subkey[0] 
	   
		switch ($subkey[0]) 
		{ 
			"hklm" {$Hive = "LocalMachine" } 
			"hkcu" {$Hive = "CurrentUser" }                                    
			default {write-error "invalid path. only HKLM and HKCU is supported" }
		}       
		$Hive
}

#################################################
# Function: Get-RegValueKind
# Description: Get the registry value type (e.g, string,dword etc)
# Return Value: None
#################################################
function Get-SubKey 
{
	param( [string]$key )    
	$subkey = $key.split(":")
	$subkey = $subkey[1]
	$subkey = $subkey.Remove(0, 1)
	$subkey
}

#################################################
#
# Function: Get-RegValueData
# Description: Read RegKey Value Data
# Return Value: Path
#
#################################################
Function Get-RegValueData ( [string]$key_path, [string]$key_value ) 
{

if( $null -eq $key_path ){
	return $null
}

if ( test-path ($key_path) ){

	$key_all_values = Get-ItemProperty $key_path
	$RegValueData = $null
	
	# Key Exists
	if( Test-RegistryValue $key_path $key_value )
	{
		$RegValueData = $key_all_values.$key_value
	}  
	return $RegValueData
}

else {
return $null
}

}

#################################################
# Function: Create-SubKeyRecursive
# Input:    registrykey (string), subkeypath (string)
# Return:   null
# Desc:     Recursively creates subkey path under registrykey (firstarg), if not already exist
#
# Example:  Create-SubKeyRecursive "hkcu:\Software\Microsoft\" "\Windows\CurrentVersion\Group Policy Objects\"
# Result:   Full Key will be created if its not there. First arg registry key must exist. 
#           "hkcu:\Software\Microsoft\Windows\CurrentVersion\Group Policy Objects"
#################################################
Function Create-SubKeyRecursive
{
	param(
		[string]$currentKey,
		[string]$subkey        
	)
	
	
	# No need if its already there
	$FULLPATH = Concatenate-RegistryPaths $currentKey $subkey
	if (test-path $FULLPATH){ return }
		  
	# Check current Key Exist
	if (test-path $currentKey)
	{    
		# RegEx split subkey '\', Checksubkey & create
		$arrSubkey = $subkey.Split("\")
		
		$nextLevel = $currentKey
		# Recursively create keys if not there already
		foreach( $key in $arrSubkey )
		{
			$nextLevel = Concatenate-RegistryPaths $nextLevel $key            
			if (!(test-path $nextLevel)) 
			{
				# Create Key
				New-Item -Path $nextLevel
			}
					
		}                                                
	}
	else{ Write-Error "$currentKey does not exist"}           
	
}

#################################################
# Function: Concatenate-RegistryPaths
# Input:    Registry Key Path (string), Registry Key Subkey (string)
# Return:   Combination of both Registry Paths
#
# Example:  Concatenate-RegistryPaths "hkcu:\Software\Microsoft\" "\Windows\CurrentVersion\"
# Result:   "hkcu:\Software\Microsoft\Windows\CurrentVersion"
# DependsOn: Trim-StringStartsWithChar & Trim-StringEndsWithChar
#
# (Don't worry about paths with single slash '\' or double slash '\\') 
#################################################
Function Concatenate-RegistryPaths
{
	param(
		[string]$currentKey,
		[string]$subkey        
	)
	
	if ( ($currentKey -like "\\") -or ($subkey -like "\\") )
	{
		$currentKey = Trim-StringEndsWithChar $currentKey "\"
		$subkey = Trim-StringStartsWithChar $subkey "\"
		$subkey = Trim-StringEndsWithChar $subkey "\"
		return $currentKey + "\\" + $subKey                 
	}
	else
	{
		$currentKey = Trim-StringEndsWithChar $currentKey "\"
		$subkey = Trim-StringStartsWithChar $subkey "\"
		$subkey = Trim-StringEndsWithChar $subkey "\"
		return $currentKey + "\" + $subKey
	}
	
}

#################################################
#
# Function: Trim-StringStartsWithChar
# Input: String, Character
# Return: Same string with characters trimmed from start
#
# Example: Trim-StringStartsWithChar "\\\substring\deeper\deeper" "\"
# Result:  "substring\deeper\deeper"
#
#################################################
Function Trim-StringStartsWithChar
{
	param(
		[string]$str,
		[char]$c        
	)
	
	for( [int]$i = 0; $i -lt $str.length; $i++ )
	{
		# current key should with '\'
		if ( $str.StartsWith($c) )
		{
			#amputate '\'
			$str = $str.Remove(0, 1)
		}
		
	}
	return $str
}

#################################################
#
# Function: Trim-StringStartsWithChar
# Input: String, Character
# Return: Same string with characters trimmed from end
#
# Example: Trim-StringEndsWithChar "substring\deeper\deeper\\\\\" "\"
# Result:  "substring\deeper\deeper"
#
#################################################
Function Trim-StringEndsWithChar
{
	param(
		[string]$str,
		[char]$c        
	)
	
	for( [int]$i = 0; $i -lt $str.length; $i++ )
	{
		# current key should with '\'
		if ( $str.EndsWith($c) )
		{
			#amputate '\'
			$str = $str.Remove($str.length-1, 1)
		}
		
	}
	return $str
}

#################################################
#
# Function: Get-RegistryKeyShortName
# Input: Full path of a registry key.
# Return: Short Name for that registry key.
#
# Example: hklm:\software\microsoft\windows
# Result:  windows
#
#################################################
Function Get-RegistryKeyShortName
{
	param( [string]$RegKey_FullName )
	$arrKeys = $RegKey_FullName.Split("\")
	return $arrKeys[$arrKeys.Length - 1]    
}

# functions below this point is used to preserve states using registry

#global Variables

<#
$global:HKCR = 2147483648 #HKEY_CLASSES_ROOT 
$global:HKCU = 2147483649 #HKEY_CURRENT_USER 
$global:HKLM = 2147483650 #HKEY_LOCAL_MACHINE 
$global:HKUS = 2147483651 #HKEY_USERS 
$global:HKCC = 2147483653 #HKEY_CURRENT_CONFIG 



$global:reg = [wmiclass]‘\\.\root\default:StdRegprov’ 
$global:key = "SOFTWARE\DiagPackage\$global:Packname"

#>

#global Variables
$global:Packname = "PackName"
$global:RC_detected = "RC_Detected_"
$global:VF_detected = "VF_Detected_"
$global:RC_ran = "RC_Ran_"
$global:RS_ran = "RS_Ran_"
$global:VF_ran = "VF_Ran_"
$global:RestorePoint = "RestorePoint"

if($global:Package -ne $null){

}else{
	$global:Package = "Registry::HKEY_CURRENT_CONFIG\software\"
}

# $global:RestartedByPack = "RestartedByPack" 
# $global:reg.GetDwordValue($global:HKCC, $global:key, $value) 

# get-regvaluedate $global:key $value

# create registry keys for a package
function Create-PackageRegistryKey($Packname){

	$Package = "hkcu:\software\"
	$Package1 = "\DiagPackage\" +$Packname
	$global:Packname = $Packname
	$p1 = $Package+$Package1
	$p1
	if($false -eq (Test-Path ($p1))){
		Create-SubKeyRecursive $Package $Package1
		"$p1 Created"
	}else{
		"$p1 already Exist"
	}
	
}

# create a key called restartedbypack and set to false by default
function Create-RestartedByPackKey($p1,$defaultValue = $false){
	Create-RegistryValue ($p1) "RestartedByPack" $defaultValue "String"
}

# create a key called RestorePoint and set to false by default
function Set-RestorePointRegistry($p1,$defaultValue = $false){
	Create-RegistryValue ($p1) ($global:RestorePoint) $defaultValue "String"
}

# create a key called restorepoint and set to false by default
function Get-RestorePoint(){
	$a = Get-RegValueData ($global:Package[0]) ($global:RestorePoint)
	$a = [string]$a
	$a = $a.trim()
	if(($null -eq $a) -or ($a -eq "")){
		return $false
	}
	return ("True" -ieq $a.Trim())
}

function Create-StateAll($p1,$name,$defaultValue = $false){
	Create-RegistryValue ($p1) ("RC_Detected_$name") $defaultValue "String"
	Create-RegistryValue ($p1) ("RC_Ran_$name") $false "String"
	Create-RegistryValue ($p1) ("RS_Ran_$name") $false "String"
	Create-RegistryValue ($p1) ("VF_Ran_$name") $false "String"
	Create-RegistryValue ($p1) ($global:RestorePoint + "_" + $name) $false "String"
}

# Resets the value of registry key
function Reset-State($p1,$name,$defaultValue = $false){
	Create-RegistryValue ($p1) $name $defaultValue "String"
}

# Deletes current pack states
function Delete-CurrentPackageStates($packName){
	$Package = "hkcu:\software\diagpackage\$packName"
	del $Package -recurse -force
}

# Deletes all pack states
function Delete-AllPackageStates(){
	del "hkcu:\software\diagpackage" -recurse -force
}

# Sets the flag if restarted by the pack
function Set-RestartFlag($value){
	Create-RestartedByPackKey $global:Package[0] $value
}

# Create new registry keys
function Create-RegistryKeys($PackName){
	$global:Package  = Create-PackageRegistryKey "$PackName"
	$str = [string]$global:Package[-1]
	if($str.indexof("Exist") -eq -1){
		Create-RestartedByPackKey $global:Package[0]
	}
}

# Checks if this pack has restarted the machine or not
function Is-PackRestart(){
	$a = Get-RegValueData $global:Package[0] "RestartedByPack"
	return ("True" -ieq $a.Trim())
}

# Checks if this script has ran earlier or not
function Is-ScriptRun($name){
	$a = Get-RegValueData $global:Package[0] $name
	$a = [string]$a
	return ("True" -ieq $a.Trim())
}

# Checks if this root cause is detected earlier
function Is-RootCauseDetected($name){
	$a = Get-RegValueData $global:Package[0] ("RC_Detected_"+$name)
	$a = [string]$a
	return ("True" -ieq $a.Trim())
}

# Checks if this verifier is detected or not
function Is-VerifierDetected($name){
	$a = Get-RegValueData $global:Package[0] ("vf_Detected_"+$name)
	$a = [string]$a
	return ("True" -ieq $a.Trim())
}

# Saves the parameter in registry key
function Save-Parameter($scriptname,$parameterName,$parameterValue){
	if($null -eq $parameterValue){
		return
	}

	if($parameterValue.Trim() -eq ""){
		return
	}

	$Package = "hkcu:\software\"
	$Package1 = "\DiagPackage\" +$global:Packname+"\$scriptName"
	$p1 = $Package+$Package1

	Create-SubKeyRecursive $Package $Package1

	Create-RegistryValue ($p1) ("$parameterName") $parameterValue "String"
}

# Gets the parameter value
function Get-Parameter($scriptname,$parameterName){
	$a = Get-RegValueData $global:Package[0] "$scriptname\$parameterName"
	return $a
}

# Deletes previous state where all RCs are detected as false
function Delete-PreviousStatesIfALLRcFalse(){
	$Package = "hkcu:\software\DiagPackage"
	$Package1 = "\" +$global:Packname

	if( -not ( test-path ($package+$package1) ) ){
		return
	}
	
	$a =  get-item ($package+$package1) 
	

	$hDetected = @{}
	$hRan = @{}

	$rcs_Detected = $a.getvaluenames() | ? { $_ -match $global:RC_detected }
	$rcs_Ran = $a.getvaluenames() | ? { $_ -match $global:RC_ran }

	$a = get-itemproperty ($package+$package1)
	
	foreach($a1 in $rcs_Detected){
		[string]$a1 = $a1
		if("True" -ieq $a1){
			return $true
		}
	}

	Delete-CurrentPackageStates ($global:PackName)
	return $false
}