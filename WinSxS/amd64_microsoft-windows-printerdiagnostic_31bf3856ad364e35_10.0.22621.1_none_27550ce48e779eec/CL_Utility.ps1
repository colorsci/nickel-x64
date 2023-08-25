# Copyright © 2008, Microsoft Corporation. All rights reserved.

Import-LocalizedData -BindingVariable localizationString -FileName CL_LocalizationData

Function Write-ExceptionTelemetry($FunctionName, [System.Management.Automation.ErrorRecord] $ex)
{
    <#
    DESCRIPTION:
      Writes script error information into telemetry stream
     
    EXAMPLE:
      try
      {
         0 / 0
      }
      catch [System.Exception]
      {
         Write-ExceptionTelemetry "DivideByZeroTest" $_
      }
    #>

    $ExceptionMessage = $ex.Exception.Message
    $ScriptFullPath = $ex.InvocationInfo.ScriptName
    $ExceptionScript = [System.IO.Path]::GetFileName($ScriptFullPath)
    $ExceptionScriptLine = $ex.InvocationInfo.ScriptLineNumber
    $ExceptionScriptColumn = $ex.InvocationInfo.OffsetInLine
    
	Write-DiagTelemetry "ScriptError" "$ExceptionScript\$FunctionName\$ExceptionScriptLine\$ExceptionScriptColumn\$ExceptionMessage"
}

function GetAbsolutionPath([string]$fileName)
{
    if([string]::IsNullorEmpty($fileName))
    {
        WriteFunctionExceptionReport "GetAbsolutionPath" $localizationString.throw_invalidFileName
        return
    }

    return Join-Path (Get-Location).Path $fileName
}

#
# Get system path of a file by adding the system path of current directory in the head of the specified file
#
function GetSystemPath([string]$fileName)
{
    if([string]::IsNullorEmpty($fileName))
    {
        WriteFunctionExceptionReport "GetSystemPath" $localizationString.throw_invalidFileName
        return
    }

    [string]$systemPath = [System.Environment]::SystemDirectory
    return Join-Path $systemPath $fileName
}

#
# Check if the printer is a virtual printer by the printer name.
#
function IsVirtualPrinter([string]$printerDeviceID)
{
    if([string]::IsNullorEmpty($printerDeviceID))
    {
        WriteFunctionExceptionReport "IsVirtualPrinter" $localizationString.throw_noPrinterDeviceIDSpecified
        return
    }
    [bool]$result = $false
    $virtualPrinterDeviceIDs = ("Microsoft Print to PDF", "Adobe PDF", "Print as a PDF", "Microsoft XPS Document Writer", "Send To OneNote" , "Microsoft Office Live Meeting", "Fax", "Journal Note Writer")
    foreach($deviceID in $virtualPrinterDeviceIDs)
    {
        if($printerDeviceID.Contains($deviceID))
        {
            $result = $true
            break
        }
    }
    return $result
}

#
# Run power shell script and return the bool value
#
function RunDiagnosticScript([string]$scriptPath)
{
    if([string]::IsNullorEmpty($scriptPath) -or -not (Test-Path $scriptPath))
    {
        WriteFunctionExceptionReport "RunDiagnosticScript" $localizationString.throw_invalidFileName
        return
    }
    $result = &($scriptPath)
    if($result -is [bool])
    {
        return [bool]$result
    }
    else
    {
        return $false
    }
}

#
# Get the printer API
#
function GetPrinterType()
{
$winSpoolDefinition = @"
    [DllImport("winspool.drv", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int OpenPrinter([MarshalAs(UnmanagedType.LPWStr)] string pPrinterName, ref IntPtr phPrinter, IntPtr pDefault);

    [DllImport("winspool.drv", CharSet = CharSet.Unicode, SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetPrinter(IntPtr hPrinter, int dwLevel, IntPtr pPrinter, int dwBuf, ref int dwNeeded);

    [DllImport("winspool.Drv", CharSet = CharSet.Unicode, SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool SetPrinter(IntPtr hPrinter,  int Level,  IntPtr pPrinter, uint Command);

    [DllImport("Winspool.drv", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int EnumJobs(IntPtr hPrinter, int FirstJob, int NoJobs, int Level, IntPtr pJob, int cbBuf, ref int pcbNeeded, ref int pcReturned);

    [DllImport("winspool.drv", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern int SetJob(IntPtr hPrinter, UInt32 JobId, int Level, ref JOB_INFO_2 pJob, int Command_Renamed);

    [DllImport("winspool.drv", SetLastError=false)]
    public static extern int ClosePrinter(IntPtr hPrinter);

    [DllImport("winspool.drv", CharSet = CharSet.Unicode, SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetPrinterDriver(IntPtr hPrinter, IntPtr pEnvironment, int dwLevel, IntPtr phDriverInfo, int dwBuf, ref int dwNeeded);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct PRINTER_INFO_2
    {
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pServerName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pPrinterName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pShareName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pPortName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDriverName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pComment;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pLocation;
        public IntPtr pDevMode;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pSepFile;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pPrintProcessor;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDatatype;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pParameters;
        public IntPtr pSecurityDescriptor;
        public uint Attributes;
        public uint Priority;
        public uint DefaultPriority;
        public uint StartTime;
        public uint UntilTime;
        public uint Status;
        public uint cJobs;
        public uint AveragePPM;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct JOB_INFO_2
    {
        public UInt32 JobId;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pPrinterName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pMachineName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pUserName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDocument;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pNotifyName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDatatype;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pPrintProcessor;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pParameters;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDriverName;
        public IntPtr pDevMode;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pStatus;
        public IntPtr pSecurityDescriptor;
        public UInt32 Status;
        public UInt32 Priority;
        public UInt32 Position;
        public uint StartTime;
        public uint UntilTime;
        public UInt32 TotalPages;
        public UInt32 size;
        public SYSTEMTIME Submitted;
        public UInt32 time;
        public UInt32 PagesPrinted;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct SYSTEMTIME
    {
        [MarshalAs(UnmanagedType.U2)]
        public short Year;
        [MarshalAs(UnmanagedType.U2)]
        public short Month;
        [MarshalAs(UnmanagedType.U2)]
        public short DayOfWeek;
        [MarshalAs(UnmanagedType.U2)]
        public short Day;
        [MarshalAs(UnmanagedType.U2)]
        public short Hour;
        [MarshalAs(UnmanagedType.U2)]
        public short Minute;
        [MarshalAs(UnmanagedType.U2)]
        public short Second;
        [MarshalAs(UnmanagedType.U2)]
        public short Milliseconds;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PRINTER_DEFAULTS
    {
        public IntPtr pDatatype;
        public IntPtr pDevMode;
        public int DesiredAccess;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct DRIVER_INFO_2
    {
        public uint cVersion;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pName;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pEnvironment;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDriverPath;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pDataFile;
        [MarshalAs(UnmanagedType.LPWStr)]
        public string pConfigFile;
    }
"@

    $winSpoolType = Add-Type -MemberDefinition $winSpoolDefinition -Name "winSpoolCL" -UsingNamespace "System.Reflection","System.Diagnostics" -PassThru
    return $winSpoolType
}

#
# Get the printer status
#
function GetPrinterStatus([string]$printerName)
{
    #
    # the function return value
    #
    [int]$printStatus = 0
    #
    # Gets related report string.
    #
    [string]$functionName = "GetPrinterStatus"
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    if([string]::IsNullorEmpty($printerName))
    {
        WriteFunctionExceptionReport $functionName $localizationString.throw_invalidPrinterName
        return $printStatus
    }

    #
    # Get the printer API
    #
    $winSpoolType = GetPrinterType

    [IntPtr]$hPrinter = [IntPtr]::Zero
    [int]$result = $winSpoolType[0]::OpenPrinter($printerName, [ref]$hPrinter, [IntPtr]::Zero)
    [int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if($result -eq 0)
    {
        WriteFunctionAPIExceptionReport $functionName "OpenPrinter" $errorCode
        return $printStatus
    }

    try
    {
        [int]$cbNeeded = 0

        [bool]$bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, [IntPtr]::Zero, 0, [ref]$cbNeeded)
        if($cbNeeded -gt 0)
        {
            $pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($cbNeeded)
            try
            {
                $bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, $pAddr, $cbNeeded, [ref]$cbNeeded)
                $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                if ($bRet)
                {
                    $PRINTER_INFO_2 = New-Object $winSpoolType[1]
                    $info2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$PRINTER_INFO_2.GetType())
                    $printStatus = $info2.Status
                }
                else
                {
                    WriteFunctionAPIExceptionReport $functionName "GetPrinter" $errorCode
                    return $printStatus
                }
            }
			catch [System.Exception]
			{
				Write-ExceptionTelemetry "GetPrinterStatus" $_
			}
            finally
            {
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
            }

        }
    }
    finally
    {
        $winSpoolType[0]::ClosePrinter($hPrinter) > $null
    }
    return $printStatus
}

#
# Get the printer driver name
#
function GetPrinterDriverName([string]$printerName)
{
    #
    # the function return value
    #
    [string]$printerDriverName = ""
    #
    # Gets related report string.
    #
    [string]$functionName = "GetPrinterDriverName"
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    if([string]::IsNullorEmpty($printerName))
    {
        throw $localizationString.throw_invalidPrinterName
        return $printerDriverName
    }

    #
    # Get the printer API
    #
    $winSpoolType = GetPrinterType

    [IntPtr]$hPrinter = [IntPtr]::Zero
    [int]$result = $winSpoolType[0]::OpenPrinter($printerName, [ref]$hPrinter, [IntPtr]::Zero)
    [int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if($result -eq 0)
    {
        WriteFunctionAPIExceptionReport $functionName "OpenPrinter" $errorCode
        return $printerDriverName
    }

    try
    {
        [int]$cbNeeded = 0

        [bool]$bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, [IntPtr]::Zero, 0, [ref]$cbNeeded)
        if($cbNeeded -gt 0)
        {
            $pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($cbNeeded)
            try
            {
                $bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, $pAddr, $cbNeeded, [ref]$cbNeeded)
                $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                if ($bRet)
                {
                    $PRINTER_INFO_2 = New-Object $winSpoolType[1]
                    $info2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$PRINTER_INFO_2.GetType())
                    $printerDriverName = $info2.pDriverName
                }
                else
                {
                    WriteFunctionAPIExceptionReport $functionName "GetPrinter" $errorCode
                    return $printerDriverName
                }
            }
            finally
            {
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
            }

        }
    }
    finally
    {
        $winSpoolType[0]::ClosePrinter($hPrinter) > $null
    }
    return $printerDriverName
}

#
# Get the printer port name
#
function GetPrinterPortName([string]$printerName)
{
    #
    # the function return value
    #
    [string]$printerPortName = ""
    #
    # Gets related report string.
    #
    [string]$functionName = "GetPrinterPortName"
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    if([string]::IsNullorEmpty($printerName))
    {
        throw $localizationString.throw_invalidPrinterName
        return $printerPortName
    }

    #
    # Get the printer API
    #
    $winSpoolType = GetPrinterType

    [IntPtr]$hPrinter = [IntPtr]::Zero
    [int]$result = $winSpoolType[0]::OpenPrinter($printerName, [ref]$hPrinter, [IntPtr]::Zero)
    [int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if($result -eq 0)
    {
        WriteFunctionAPIExceptionReport $functionName "OpenPrinter" $errorCode
        return $printerPortName
    }

    try
    {
        [int]$cbNeeded = 0

        [bool]$bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, [IntPtr]::Zero, 0, [ref]$cbNeeded)
        if($cbNeeded -gt 0)
        {
            $pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($cbNeeded)
            try
            {
                $bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, $pAddr, $cbNeeded, [ref]$cbNeeded)
                $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                if ($bRet)
                {
                    $PRINTER_INFO_2 = New-Object $winSpoolType[1]
                    $info2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$PRINTER_INFO_2.GetType())
                    $printerPortName = $info2.pPortName
                }
                else
                {
                    WriteFunctionAPIExceptionReport $functionName "GetPrinter" $errorCode
                    return $printerPortName
                }
            }
            finally
            {
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
            }

        }
    }
    finally
    {
        $winSpoolType[0]::ClosePrinter($hPrinter) > $null
    }
    return $printerPortName
}

#
# Get the printer driver version
#
function GetPrinterDriverVersion([string]$printerName)
{
    #
    # the function return value
    #
    [int]$printerDriverVersion = 0
    #
    # Gets related report string.
    #
    [string]$functionName = "GetPrinterDriverVersion"
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    if([string]::IsNullorEmpty($printerName))
    {
        throw $localizationString.throw_invalidPrinterName
        return $printerDriverVersion
    }

    #
    # Get the printer API
    #
    $winSpoolType = GetPrinterType

    [IntPtr]$hPrinter = [IntPtr]::Zero
    [int]$result = $winSpoolType[0]::OpenPrinter($printerName, [ref]$hPrinter, [IntPtr]::Zero)
    [int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if($result -eq 0)
    {
        WriteFunctionAPIExceptionReport $functionName "OpenPrinter" $errorCode
        return $printerDriverVersion
    }

    try
    {
        [int]$cbNeeded = 0

        [bool]$bRet = $winSpoolType[0]::GetPrinterDriver($hPrinter, [IntPtr]::Zero, 2, [IntPtr]::Zero, 0, [ref]$cbNeeded)
        if($cbNeeded -gt 0)
        {
            $pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($cbNeeded)
            try
            {
                $bRet = $winSpoolType[0]::GetPrinterDriver($hPrinter, [IntPtr]::Zero, 2, $pAddr, $cbNeeded, [ref]$cbNeeded)
                $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                if ($bRet)
                {
                    $DRIVER_INFO_2 = New-Object $winSpoolType[5]
                    $info2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$DRIVER_INFO_2.GetType())
                    $printerDriverVersion = $info2.cVersion
                }
                else
                {
                    WriteFunctionAPIExceptionReport $functionName "GetPrinterDriver" $errorCode
                    return $printerDriverVersion
                }
            }
            finally
            {
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
            }

        }
    }
    finally
    {
        $winSpoolType[0]::ClosePrinter($hPrinter) > $null
    }
    return $printerDriverVersion
}

#
# Get the printer attributes
#
function GetPrinterAttributes([string]$printerName)
{
    #
    # the function return value
    #
    [int]$printerAttributes = 0
    #
    # Gets related report string.
    #
    [string]$functionName = "GetPrinterAttributes"
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    if([string]::IsNullorEmpty($printerName))
    {
        throw $localizationString.throw_invalidPrinterName
        return $printerAttributes
    }

    #
    # Get the printer API
    #
    $winSpoolType = GetPrinterType

    [IntPtr]$hPrinter = [IntPtr]::Zero
    [int]$result = $winSpoolType[0]::OpenPrinter($printerName, [ref]$hPrinter, [IntPtr]::Zero)
    [int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    if($result -eq 0)
    {
        WriteFunctionAPIExceptionReport $functionName "OpenPrinter" $errorCode
        return $printerAttributes
    }

    try
    {
        [int]$cbNeeded = 0

        [bool]$bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, [IntPtr]::Zero, 0, [ref]$cbNeeded)
        if($cbNeeded -gt 0)
        {
            $pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($cbNeeded)
            try
            {
                $bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, $pAddr, $cbNeeded, [ref]$cbNeeded)
                $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
                if ($bRet)
                {
                    $PRINTER_INFO_2 = New-Object $winSpoolType[1]
                    $info2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$PRINTER_INFO_2.GetType())
                    $printerAttributes = $info2.Attributes
                }
                else
                {
                    WriteFunctionAPIExceptionReport $functionName "GetPrinter" $errorCode
                    return $printerAttributes
                }
            }
            finally
            {
                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
            }

        }
    }
    finally
    {
        $winSpoolType[0]::ClosePrinter($hPrinter) > $null
    }
    return $printerAttributes
}

#
# Set the printer attributes
#
function SetPrinterAttributes([string]$printerName, [int]$printerAttributes)
{
    #
    # Gets related report string.
    #
    [string]$functionName = "SetPrinterAttributes"
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    if([string]::IsNullorEmpty($printerName))
    {
        throw $localizationString.throw_invalidPrinterName
    }


    #
    # Get the printer API
    #
    $winSpoolType = GetPrinterType

    [int]$PRINTER_ACCESS_ADMINISTER = 0x00000004
    [int]$PRINTER_ACCESS_USE = 0x00000008
    $defaults =New-Object $winSpoolType[4]
    $defaults.pDatatype = [IntPtr]::Zero
    $defaults.pDevMode = [IntPtr]::Zero
    $defaults.DesiredAccess = $PRINTER_ACCESS_ADMINISTER -bor $PRINTER_ACCESS_USE
    $pDefaults = [System.Runtime.InteropServices.Marshal]::AllocHGlobal([System.Runtime.InteropServices.Marshal]::SizeOf($defaults))
    try
    {
	    [System.Runtime.InteropServices.Marshal]::StructureToPtr($defaults, $pDefaults, $true)

	    [IntPtr]$hPrinter = [IntPtr]::Zero
	    [int]$result = $winSpoolType[0]::OpenPrinter($printerName, [ref]$hPrinter, $pDefaults)
	    [int]$errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
	    if($result -eq 0)
	    {
	        throw [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, "OpenPrinter", $errorCode)
	    }

	    try
	    {
	        [int]$cbNeeded = 0

	        [bool]$bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, [IntPtr]::Zero, 0, [ref]$cbNeeded)
	        if($cbNeeded -gt 0)
	        {
	            #
	            # In order to avoid that printer share name is null, add the max size of printer share name to allocated memory.
	            #
	            [int]$addLength = 164
	            $pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($cbNeeded + $addLength)
	            try
	            {
	                $bRet = $winSpoolType[0]::GetPrinter($hPrinter, 2, $pAddr, $cbNeeded, [ref]$cbNeeded)
	                $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
	                if ($bRet)
	                {
	                    $PRINTER_INFO_2 = New-Object $winSpoolType[1]
	                    $info2 = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$PRINTER_INFO_2.GetType())
	                    $info2.Attributes = $info2.Attributes -bor $printerAttributes
	                    if([string]::IsNullorEmpty($info2.pShareName))
	                    {
	                        $info2.pShareName = $info2.pPrinterName
	                    }
	                    [System.Runtime.InteropServices.Marshal]::StructureToPtr($info2, $pAddr, $false)
	                    $bRet = $winSpoolType[0]::SetPrinter($hPrinter, 2, $pAddr, 0)
	                    $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
	                    if(-not $bRet)
	                    {
	                        throw [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, "SetPrinter", $errorCode)
	                    }
	                }
	                else
	                {
	                    throw [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, "GetPrinter", $errorCode)
	                }
	            }
	            finally
	            {
	                [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
	            }

	        }
	    }
	    finally
	    {
	        $winSpoolType[0]::ClosePrinter($hPrinter) | out-null
	    }
    }
    finally
    {
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pDefaults)
    }
}

#
# Get the printer according printer name
#
function GetPrinterFromPrinterName([string]$printerName)
{
    $printerSpecified = $null
    $printers = Get-WmiObject Win32_Printer
    if($printers -ne $null)
    {
        foreach($printer in $printers)
        {
            if($printerName -eq $printer.Name)
            {
                $printerSpecified = $printer
                break
            }
        }
    }
    return $printerSpecified
}

#
# Check if the printer is a virtual printer by the printer name.
#
function PrinterIsShared([string]$printerName)
{
    if([string]::IsNullorEmpty($printerName))
    {
        WriteFunctionExceptionReport "PrinterIsShared" $localizationString.throw_noPrinterNameSpecified
        return
    }
    [bool]$result = $false
    [int]$PRINTER_ATTRIBUTE_SHARED = 0x00000008
    $printerAttributes = GetPrinterAttributes $printerName
    if($printerAttributes -band $PRINTER_ATTRIBUTE_SHARED)
    {
        $result = $true
    }
    return $result
}

#
# Write function exception to debug report
#
function WriteFunctionExceptionReport([string]$functionName, [string]$exceptionInfo)
{
    [string]$errorFunctionName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_name, $functionName)
    [string]$errorFunctionDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_function_description, $functionName)
    $exceptionInfo | select-object -Property @{Name=$localizationString.error_information; Expression={$_}} | convertto-xml | Update-DiagReport -id $functionName -name $errorFunctionName -description $errorFunctionDescription -verbosity Debug
}

#
# Write API exception in function to debug report
#
function WriteFunctionAPIExceptionReport([string]$functionName, [string]$APIName, [int]$errorCode)
{
    [string]$exceptionInfo = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, $APIName, $errorCode)
    WriteFunctionExceptionReport $functionName $exceptionInfo
}

#
# Write function exception to debug report
#
function WriteFileExceptionReport([string]$fileName, [string]$exceptionInfo)
{
    [string]$errorFileName = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_file_name, $fileName)
    [string]$errorFileDescription = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.error_file_description, $fileName)
   # $exceptionInfo | select-object -Property @{Name=$localizationString.error_information; Expression={$_}} | convertto-xml | Update-DiagReport -id $fileName -name $errorFileName -description $errorFileDescription -verbosity Debug
}

#
# Write API exception in file to debug report
#
function WriteFileAPIExceptionReport([string]$fileName, [string]$APIName, [int]$errorCode)
{
    [string]$exceptionInfo = [System.String]::Format([System.Globalization.CultureInfo]::InvariantCulture, $localizationString.throw_win32APIFailed, $APIName, $errorCode)
    WriteFileExceptionReport $fileName $exceptionInfo
}

# Function to wait for expected service status
function WaitFor-ServiceStatus([string]$serviceName=$(throw "No service name is specified"), [ServiceProcess.ServiceControllerStatus]$serviceStatus=$(throw "No service status is specified"))
{
    [ServiceProcess.ServiceController]$sc = New-Object "ServiceProcess.ServiceController" $serviceName
    [TimeSpan]$timeOut = New-Object TimeSpan(0,0,0,5,0)
    $sc.WaitForStatus($serviceStatus, $timeOut)
}

