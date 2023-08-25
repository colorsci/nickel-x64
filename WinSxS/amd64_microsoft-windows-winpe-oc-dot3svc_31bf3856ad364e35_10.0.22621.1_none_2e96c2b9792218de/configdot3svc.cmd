cmd /c "netcfg -e -c p -i MS_NDISUIO"
cmd /c "reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinPE" /t REG_DWORD /v SkipWaitForNetwork /d 1 /f"
