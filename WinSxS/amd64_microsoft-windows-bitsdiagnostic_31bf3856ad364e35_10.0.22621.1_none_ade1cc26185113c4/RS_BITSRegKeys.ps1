# Copyright © 2015, Microsoft Corporation. All rights reserved.
# :: ======================================================= ::

#====================================================================================
# Load Utilities
#====================================================================================
. ./CL_Registry.ps1
. ./Cl_Service.ps1

#====================================================================================
# Main
#====================================================================================
 
SServicer 'bits' 'Stopped'

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
	
	if(!(Test-Path  $RegistryPathBITS))
	{
		$n =  New-Item -Path $RegistryPathBITS -ItemType Directory -Force
	}
	
	New-ItemProperty -Path $RegistryPathBITS -Name $keyValue -PropertyType $valueType -Value $valueData -force

	cmd /c 'sc config bits start= auto'
}

# Step 2: Process Registry entries for BITS Parameters
$RegistryPathBitsParameters = 'HKLM:\SYSTEM\CurrentControlSet\Services\BITS\Parameters'

$keyValue13 = 'ServiceDll'
$valueData13 = '%SystemRoot%\System32\qmgr.dll'
$valueType13 = 'ExpandString'

# Set permission
if (Test-Path $RegistryPathBitsParameters)
{
	$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\BITS\Parameters', [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::ChangePermissions)
	$acl = $key.GetAccessControl()
	$currentuser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
	$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($currentuser, 'FullControl', 'Allow')
	$acl.SetAccessRule($rule)
	$key.SetAccessControl($acl)
	$permGrantedByThePack = $true
}

if(!(Test-path  $RegistryPathBitsParameters))
{
	$n =  New-Item -Path $RegistryPathBitsParameters -ItemType Directory -Force
}
New-ItemProperty -Path $RegistryPathBitsParameters -Name $keyValue13 -PropertyType $valueType13 -Value $valueData13 -Force

# Remove permission
if ($permGrantedByThePack -eq $true)
{
	$acl.RemoveAccessRule($rule)
	$key.SetAccessControl($acl)
	$key.Close()
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

if(!(Test-path  $RegistryPathBitsSecurity))
{
	$n =  New-Item -Path $RegistryPathBitsSecurity -ItemType Directory -Force
}
New-ItemProperty -Path $RegistryPathBitsSecurity -Name $keyValue27 -PropertyType $valueType27 -Value $valueData27 -Force

SServicer 'bits' 'Running'