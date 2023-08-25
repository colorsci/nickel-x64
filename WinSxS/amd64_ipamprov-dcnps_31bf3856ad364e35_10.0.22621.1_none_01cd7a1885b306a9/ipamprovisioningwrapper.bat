
set TargetType=%1
set IpamUgName=%2
set IpamUgSid=%3

md %windir%\temp
del %windir%\temp\ipamprovisioning.ps1

copy ipampathtoken\ipamprovisioning.ps1 %windir%\temp\.

ServerManagerCmd.exe -install powershell

cd %windir%\temp

%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -command "&{get-executionpolicy}" >%windir%\temp\psExecutionPolicy.txt

%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -command "&{set-executionpolicy unrestricted}" 

%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -command "&{.\ipamprovisioning.ps1 %TargetType% %IpamUgName% %IpamUgSid%}"

%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -command "&{$policy=get-content $env:windir\temp\psExecutionPolicy.txt;set-executionpolicy $policy}" 

del %windir%\temp\ipamprovisioning.ps1
del %windir%\temp\psExecutionPolicy.txt