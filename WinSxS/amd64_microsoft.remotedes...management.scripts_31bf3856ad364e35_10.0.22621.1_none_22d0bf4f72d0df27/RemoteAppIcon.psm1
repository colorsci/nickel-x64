Import-Module $PSScriptRoot\Utility.psm1

function Get-RemoteAppIconContent {

param (
    [Parameter(Mandatory=$true)]
    [String]
    $MachineName,

    [Parameter(Mandatory=$true)]
    [String]
    $IconPath,
    
    [Parameter(Mandatory=$true)]
    [Int32]
    $IconIndex
)

    $nativeMethodSignatures = @"
            [DllImport("tspubiconhelper.dll", CharSet = CharSet.Unicode)]
            public static extern UInt32 TSGetIcon(String iconPath, int iconIndex, byte [] iconContents, ref UInt32 iconContentsSize );

            [DllImport("Shlwapi.dll", CharSet = CharSet.Unicode)]
            public static extern bool PathIsUNC([In] string pszPath);
"@
    
    $nativeMethods = Add-Type -MemberDefinition $nativeMethodSignatures `
                              -Name RemoteAppIconUtils -Namespace Microsoft.RemoteDesktopServices.Management `
                              -PassThru
    
    # First expand any environment variables in the passed-in icon path
    try
    {
        $ret = Invoke-WmiMethod -Class "Win32_TSExpandEnvironmentVariables" -namespace "root\cimv2\TerminalServices" `
                                -Name "EnvironmentVariables" -ArgumentList @($IconPath) `
                                -ComputerName $MachineName -Authentication PacketPrivacy -Impersonation Impersonate `
                                -ErrorAction Stop
    }
    catch
    {
        throw (Get-ResourceString TSGetIconResolveEnvVarError $MachineName, $IconPath, $_)
    }

    if ($ret.ReturnValue -ne 0)
    {
        throw (Get-ResourceString TSGetIconResolveEnvVarError $MachineName, $IconPath, $ret.ReturnValue)
    }
    
    $expandedIconPath = $ret.ExpandedString
    
    # Now convert the local path (without any environment variables) to a UNC path
    if($nativeMethods::PathIsUNC($expandedIconPath))
    {
        [String] $remoteIconPath = $expandedIconPath
    }
    else
    {
        $colonIndex = $expandedIconPath.IndexOf(':')
        [String] $remoteIconPath = "\\$MachineName\" + $expandedIconPath.Remove($colonIndex, 1).Insert($colonIndex, "$")
    }
    
    # Finally, get the icon at the specified UNC path & icon index
    [UInt32] $iconContentsSize = 0
    $ret = $nativeMethods::TSGetIcon($remoteIconPath, $IconIndex, $null, [REF]$iconContentsSize)
    if($ret -eq 0)
    {
        throw (Get-ResourceString TSGetIconError $MachineName, $IconPath, $IconIndex, $ret)
    }
    if($iconContentsSize -eq 0)
    {
        throw (Get-ResourceString TSGetIconNoIconFound $MachineName, $IconPath, $IconIndex)
    }
    
    $iconContents = New-Object byte[] $iconContentsSize
    
    $ret = $nativeMethods::TSGetIcon($remoteIconPath, $IconIndex, $iconContents, [REF]$iconContentsSize)
    if($ret -ne 0)
    {
        throw (Get-ResourceString TSGetIconError $MachineName, $IconPath, $IconIndex, $ret)
    }
    
    return $iconContents
}
