# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Initialize
#====================================================================================
Import-LocalizedData -BindingVariable Strings_RC_BITSRegKeys -FileName CL_LocalizationData

#====================================================================================
# Load Utilities
#====================================================================================
. ./CL_Registry.ps1

#====================================================================================
# Main
#====================================================================================
Write-DiagProgress -Activity $Strings_RC_BITSRegKeys.ID_RC_BITSRegKeys_Progress

function TestAndReturnDetected()
{
	param($val,[switch]$lastcode)
	if($val -eq $false)
	{
		$detected = $true
		Update-DiagRootCause -ID 'RC_BITSRegKeys' -Detected $detected 
		return $detected
	}
	else
	{
		if($lastcode)
		{
			$detected = $false
			Update-DiagRootCause -ID 'RC_BITSRegKeys' -Detected $detected 
			return $detected
		}
	}
}

# Step 1: Process Registry entries for BITS
$RegistryPathBITS = 'HKLM:\SYSTEM\CurrentControlSet\Services\BITS'

$keyValue1 = 'DisplayName'
$valueType1 = 'String'
$valueData1 = '@%SystemRoot%\system32\qmgr.dll,-1000'

$keyValue2 = 'ImagePath'
$valueType2 = 'ExpandString'
$valueData2= '%SystemRoot%\System32\svchost.exe -k netsvcs -p'

$keyValue3 = 'Description'
$valueType3 = 'String'
$valueData3 = '@%SystemRoot%\system32\qmgr.dll,-1001'

$keyValue4 = 'ObjectName'
$valueType4 = 'String'
$valueData4 = 'LocalSystem'

$keyValue5 = 'ErrorControl'
$valueType5 = 'DWORD'
$valueData5 = '0x00000001'

$keyValue6 = 'Start'
$valueType6 = 'DWORD'
$valueData6 = '0x00000002'

$keyValue7 = 'DelayedAutoStart'
$valueType7 = 'DWORD'
$valueData7 = '0x00000001'

$keyValue8 = 'Type'
$valueType8 = 'DWORD'
$valueData8 = '0x00000020'

$keyValue9 = 'DependOnService'
$valueType9 = 'MultiString'
$valueData9 = [string[]]('RpcSs')

$keyValue10 = 'ServiceSidType'
$valueType10 = 'DWORD'
$valueData10 = '0x00000001'

$keyValue11 = 'RequiredPrivileges'
$valueType11 = 'MultiString'
$valueData11 = [string[]]('SeCreateGlobalPrivilege','SeImpersonatePrivilege','SeTcbPrivilege',
 'SeAssignPrimaryTokenPrivilege', 'SeIncreaseQuotaPrivilege', 'SeDebugPrivilege')

$keyValue12 = 'FailureActions'
$valueType12 = 'BINARY'
$valueData12=[Byte[]] (0x80,0x51,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x14,0x00,0x00,
  0x00,0x01,0x00,0x00,0x00,0x60,0xea,0x00,0x00,0x01,0x00,0x00,0x00,0xc0,0xd4,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)

for($i = 1; $i -le 12;$i= $i+1)
{
	$keyValue = (Invoke-Expression('$keyValue' + $i))
	$valueType = (Invoke-Expression('$valueType' + $i)) 
	$valueData = (Invoke-Expression('$valueData' + $i))

	$val = Test-RegistryValueThorough -key_path $RegistryPathBITS -key_value $keyValue -value_data $valueData  -value_type $valueType 

	if(TestAndReturnDetected $val)
	{	
		return $true
	}
}

# Step 2: Process Registry entries for BITS Parameters
$RegistryPathBitsParameters = 'HKLM:\SYSTEM\CurrentControlSet\Services\BITS\Parameters'

$keyValue13 = 'ServiceDll'
$valueData13 = [Environment]::ExpandEnvironmentVariables('%SystemRoot%\System32\qmgr.dll')
$valueType13 = 'ExpandString'

$val = Test-RegistryValueThorough -key_path $RegistryPathBitsParameters  -key_value $keyValue13 -value_data $valueData13 -value_type $valueType13

if(TestAndReturnDetected $val)
{
	return $true
}

# Step 3: Process Registry entries for BITS Security
$RegistryPathBitsSecurity = 'HKLM:\SYSTEM\CurrentControlSet\Services\BITS\Security'

$keyValue27 = 'Security' 
$valueType27 = 'BINARY'
$valueData27 = [Byte[]] (0x01,0x00,0x14,0x80,0x90,0x00,0x00,0x00,0xa0,0x00,0x00,0x00,0x14,0x00,0x00,0x00,0x34,0x00,0x00,0x00,0x02,
  0x00,0x20,0x00,0x01,0x00,0x00,0x00,0x02,0xc0,0x18,0x00,0x00,0x00,0x0c,0x00,0x01,0x02,0x00,0x00,0x00,0x00,0x00,0x05,0x20,0x00,
  0x00,0x00,0x20,0x02,0x00,0x00,0x02,0x00,0x5c,0x00,0x04,0x00,0x00,0x00,0x00,0x02,0x14,0x00,0xff,0x01,0x0f,0x00,0x01,0x01,0x00,
  0x00,0x00,0x00,0x00,0x05,0x12,0x00,0x00,0x00,0x00,0x00,0x18,0x00,0xff,0x01,0x0f,0x00,0x01,0x02,0x00,0x00,0x00,0x00,0x00,0x05,
  0x20,0x00,0x00,0x00,0x20,0x02,0x00,0x00,0x00,0x00,0x14,0x00,0x8d,0x01,0x02,0x00,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x05,0x04,
  0x00,0x00,0x00,0x00,0x00,0x14,0x00,0x8d,0x01,0x02,0x00,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x05,0x06,0x00,0x00,0x00,0x01,0x02,
  0x00,0x00,0x00,0x00,0x00,0x05,0x20,0x00,0x00,0x00,0x20,0x02,0x00,0x00,0x01,0x02,0x00,0x00,0x00,0x00,0x00,0x05,0x20,0x00,0x00,
  0x00,0x20,0x02,0x00,0x00)

$val = Test-RegistryValueThorough -key_path $RegistryPathBitsSecurity -key_value $keyValue27 -value_data $valueData27 -value_type $valueType27

# NOTE: Force detection of 'Security' to false if bits ACL is setup by the pack.
# The registry value of 'Security' will change its value after RS_BITSACL ran

if ($global:RSbitsACLran -eq $true)
{
	$val = $true
}

if(TestAndReturnDetected $val -lastcode)
{
	return $true
}
else
{
	return $false
}