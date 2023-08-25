$CommonTypeDefinition = @"
using System;
using Microsoft.RemoteDesktopServices.Common;
using System.Runtime.InteropServices;
using System.Management;

namespace Microsoft.RemoteDesktopServices.Management
{
    // Common classes

    [Flags]
    public enum RDClientDeviceRedirectionOptions
    {
        None                = 0x0000,
        AudioVideoPlayBack  = 0x0001,
        AudioRecording      = 0x0002,
        COMPort             = 0x0004,
        PlugAndPlayDevice   = 0x0008,
        SmartCard           = 0x0010,
        Clipboard           = 0x0020,
        LPTPort             = 0x0040,
        Drive               = 0x0080,
        TimeZone            = 0x0100
    };    
    
    // Certificate classes
    
    public class Certificate
    {
        public string Subject { get; private set; }
        public string[] SubjectAlternateName { get; private set; }
        public string IssuedBy { get; private set; }
        public string IssuedTo { get; private set; }
        public string ExpiresOn { get; private set; }
        public string Thumbprint { get; private set; }
        public CertificateRole Role { get; private set; }
        public string Level { get; private set; }

        public Certificate(string subject,
                            string[] subjectAlternateName,
                            string issuedBy,
                            string issuedTo,
                            string notAfter,
                            string thumbprint,
                            CertificateRole role,
                            string level)
        {
            Subject = subject;
            SubjectAlternateName = subjectAlternateName;
            IssuedBy = issuedBy;
            IssuedTo = issuedTo;
            ExpiresOn = notAfter;
            Thumbprint = thumbprint;
            Role = role;
            Level = level;
        }
    }
    
    // Deployment classes
    
    public enum DeploymentStatus
    {
        Succeeded,
        SucceededWithErrors,
        Failed
    }
    
    // Deployment Property classes
    
    public enum LicensingMode
    {
        NotConfigured = 5,
        PerDevice = 2,
        PerUser = 4
    }

    public class LicensingSetting
    {
        public LicensingMode Mode { get; private set; }
        public string[] LicenseServer { get; private set; }

        public LicensingSetting (int mode, string[] licenseServers)
        {
            Mode = (LicensingMode) mode;
            LicenseServer = licenseServers;
        }
    }
    
    public enum GatewayUsage
    {
        DoNotUse = 0,
        Custom = 2,
        Automatic = 3
    }
    
    public enum GatewayAuthMode
    {
        Password = 0,
        Smartcard = 1,
        AllowUserToSelectDuringConnection = 4
    }
    
    public class GatewaySettings
    {
        public GatewayUsage GatewayMode { get; private set; }
        
        public GatewaySettings(
            GatewayUsage gatewayMode
            )
        {
            GatewayMode = gatewayMode;
        }
    }

    public class CustomGatewaySettings
    {
        public GatewayUsage GatewayMode { get; private set; }
        public string GatewayExternalFqdn { get; private set; }
        public GatewayAuthMode LogonMethod { get; private set; }
        public bool UseCachedCredentials { get; private set; }
        public bool BypassLocal { get; private set; }
        
        public CustomGatewaySettings(
            GatewayUsage gatewayMode,
            string serverFQDN,
            GatewayAuthMode logonMethod,
            bool useCachedCreds,
            bool bypassLocal
            )
        {
            GatewayMode = gatewayMode;
            GatewayExternalFqdn = serverFQDN;
            LogonMethod = logonMethod;
            UseCachedCredentials = useCachedCreds;
            BypassLocal = bypassLocal;
        }
    }

    // RemoteApp Publishing classes
    
    public enum CommandLineSettingValue
    {
        DoNotAllow = 0,
        Allow = 1,
        Require = 2
    }

    public enum RDCertificateRole
    {
        RDGateway = 0x1,
        RDWebAccess = 0x2,
        RDRedirector = 0x4,
        RDPublishing = 0x8
    }

    public class FileTypeAssociation
    {
        public string FileExtension { get; private set; }
        public string CollectionName { get; private set; }
        public string AppAlias { get; private set; }
        public string Description { get; private set; }
        public bool IsPublished { get; private set; }
        public byte[] IconContents { get; private set; }
        public Int32 IconIndex { get; private set; }
        public string IconPath { get; private set; }
        
        public FileTypeAssociation(string collectionName,
                   string appAlias,
                   string fileExtension,
                   string description,
                   bool isPublished,
                   byte[] iconContents,
                   Int32 iconIndex,
                   string iconPath)
        {
            CollectionName = collectionName;
            AppAlias = appAlias;
            FileExtension = fileExtension;
            Description = description;
            IsPublished = isPublished;
            IconContents = iconContents;
            IconIndex = iconIndex;
            IconPath = iconPath;
        }
    }

    public class RemoteApp
    {
        public string CollectionName { get; private set; }
        public string Alias { get; private set; }
        
        public string DisplayName { get; private set; }
        public string FolderName { get; private set; }
        
        public string FilePath { get; private set; }
        public string FileVirtualPath { get; private set; }
        
        public CommandLineSettingValue CommandLineSetting { get; private set; }
        public string RequiredCommandLine { get; private set; }
        
        public byte[] IconContents { get; private set; }
        public Int32 IconIndex { get; private set; }
        public string IconPath { get; private set; }
        
        public string[] UserGroups { get; private set; }
        public bool ShowInWebAccess { get; private set; }
        
        public RemoteApp(string collectionName,
                         string alias,
                         string displayName,
                         string folderName,
                         string filePath,
                         string fileVirtualPath,
                         CommandLineSettingValue commandLineSetting,
                         string requiredCommandLine,
                         byte[] iconContents,
                         Int32 iconIndex,
                         string iconPath,
                         string[] userGroups,
                         bool showInWebAccess)
        {
            CollectionName = collectionName;
            Alias = alias;
            DisplayName = displayName;
            FolderName = folderName;
            FilePath = filePath;
            FileVirtualPath = fileVirtualPath;
            CommandLineSetting = commandLineSetting;
            RequiredCommandLine = requiredCommandLine;
            IconContents = iconContents;
            IconIndex = iconIndex;
            IconPath = iconPath;
            UserGroups = userGroups;
            ShowInWebAccess = showInWebAccess;
        }
    }

    public class RDEndpoint
    {
        public string RDSHName { get; private set; }
        public string VMHostName { get; private set; }
        public string VMName { get; private set; }
        
        public RDEndpoint(string rdshName,
                                string vmHostName,
                                string vmName)
        {
            RDSHName = rdshName;
            VMHostName = vmHostName;
            VMName = vmName;
        }
    }

    // Remote Desktop Publishing classes
    
    public class RDPublishedRemoteDesktop
    {
        public string CollectionName    {get; private set;}
        public bool   ShowInWebAccess   {get; private set;}

        public RDPublishedRemoteDesktop(
            string collectionName,
            bool   showInWebAccess
            )
        {
            CollectionName = collectionName;
            ShowInWebAccess = showInWebAccess;
        }
    }

    // Remote Session Management classes
    
    public enum SESSION_STATE
    {
        STATE_ACTIVE = 0,
        STATE_CONNECTED,
        STATE_CONNECTQUERY,
        STATE_SHADOW,
        STATE_DISCONNECTED,
        STATE_IDLE,
        STATE_LISTEN,
        STATE_RESET,
        STATE_DOWN,
        STATE_INIT
    }

    public enum COLLECTION_TYPE
    {
        RD_FARM_RDSH = 0,
        RD_FARM_TEMP_VM,
        RD_FARM_MANUAL_PERSONAL_VM,
        RD_FARM_AUTO_PERSONAL_VM,
        RD_FARM_MANUAL_PERSONAL_SESSION,
        RD_FARM_AUTO_PERSONAL_SESSION
    }

    public class RDUserSession
    {
        public string ServerName { get; private set; }
        public UInt32? SessionId { get; private set; }
        public string UserName { get; private set; }
        public string DomainName { get; private set; }
        public string ServerIPAddress { get; private set; }
        public UInt32? TSProtocol { get; private set; }
        public string ApplicationType { get; private set; }
        public UInt32? ResolutionWidth { get; private set; }
        public UInt32? ResolutionHeight { get; private set; }
        public UInt32? ColorDepth { get; private set; }
        public DateTime? CreateTime { get; private set; }
        public DateTime? DisconnectTime { get; private set; }
        public SESSION_STATE? SessionState { get; private set; }

        public string CollectionName { get; private set; }
        public COLLECTION_TYPE? CollectionType { get; private set; }
        public UInt32? UnifiedSessionId { get; private set; }
        public string HostServer { get; private set; }
        public UInt32? IdleTime { get; private set; }

        public bool? RemoteFxEnabled { get; private set; }

        public RDUserSession(
             string serverName,
             UInt32? sessionId,
             string userName,
             string domainName,
             string serverIPAddress,
             UInt32? tsProtocol,
             string applicationType,
             UInt32? resolutionWidth,
             UInt32? resolutionHeight,
             UInt32? colorDepth,
             string createTime,
             string disconnectTime,
             UInt32? sessionState,

             string collectionName,
             UInt32? collectionType,
             UInt32? unifiedSessionId,
             string hostServer,
             UInt32? idleTime,

             bool? remoteFxEnabled
            )
        {
            ServerName = serverName;
            SessionId = sessionId;
            UserName = userName;
            DomainName = domainName;
            ServerIPAddress = serverIPAddress;
            TSProtocol = tsProtocol;
            ApplicationType = applicationType;
            ResolutionWidth = resolutionWidth;
            ResolutionHeight = resolutionHeight;
            ColorDepth = colorDepth;
            CreateTime = (String.IsNullOrEmpty(createTime) ? null : (DateTime?)ManagementDateTimeConverter.ToDateTime(createTime));
            DisconnectTime = (String.IsNullOrEmpty(disconnectTime) ? null : (DateTime?)ManagementDateTimeConverter.ToDateTime(disconnectTime));
            SessionState = (sessionState == null ? null : (SESSION_STATE?)sessionState);

            CollectionName = collectionName;
            CollectionType = (collectionType == null ? null : (COLLECTION_TYPE?)collectionType);
            UnifiedSessionId = unifiedSessionId;
            HostServer = hostServer;
            IdleTime = idleTime;

            RemoteFxEnabled = remoteFxEnabled;
        }
    }

    public class WTSSessionManagement
    {
        public const Int32 ERROR_NOT_FOUND = 1168;

        enum WTS_CONNECTSTATE_CLASS
        {
            WTSActive,
            WTSConnected,
            WTSConnectQuery,
            WTSShadow,
            WTSDisconnected,
            WTSIdle,
            WTSListen,
            WTSReset,
            WTSDown,
            WTSInit
        }

        enum WTS_TYPE_CLASS
        {
            WTSTypeProcessInfoLevel0,
            WTSTypeProcessInfoLevel1,
            WTSTypeSessionInfoLevel1
        }

        [StructLayout(LayoutKind.Sequential)]
        struct WTS_SESSION_INFO_1
        {
            public Int32 ExecEnvId;
            public WTS_CONNECTSTATE_CLASS State;
            public Int32 SessionId;

            [MarshalAs(UnmanagedType.LPStr)]
            public String pSessionName;

            [MarshalAs(UnmanagedType.LPStr)]
            public String pHostName;

            [MarshalAs(UnmanagedType.LPStr)]
            public String pUserName;

            [MarshalAs(UnmanagedType.LPStr)]
            public String pDomainName;

            [MarshalAs(UnmanagedType.LPStr)]
            public String pFarmName;
        }

        [DllImport("wtsapi32.dll", SetLastError = true)]
        static extern bool WTSEnumerateSessionsEx(
                IntPtr hServer,
                [MarshalAs(UnmanagedType.U4)] ref UInt32 pLevel,
                [MarshalAs(UnmanagedType.U4)] UInt32 Filter,
                ref IntPtr ppSessionInfo,
                [MarshalAs(UnmanagedType.U4)] out UInt32 pCount);

        [DllImport("wtsapi32.dll", SetLastError = true)]
        static extern Int32 WTSFreeMemoryEx(WTS_TYPE_CLASS WTSTypeClass, IntPtr pMemory, UInt32 NumberOfEntries);

        [DllImport("wtsapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        static extern IntPtr WTSOpenServer(string pServerName);

        [DllImport("wtsapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        static extern IntPtr WTSOpenServerEx(string pServerName);

        [DllImport("wtsapi32.dll")]
        static extern void WTSCloseServer(IntPtr hServer);

        [DllImport("wtsapi32.dll", SetLastError = true)]
        static extern bool WTSSendMessage(
            IntPtr hServer,
            [MarshalAs(UnmanagedType.I4)] int SessionId,
            String pTitle,
            [MarshalAs(UnmanagedType.U4)] int TitleLength,
            String pMessage,
            [MarshalAs(UnmanagedType.U4)] int MessageLength,
            [MarshalAs(UnmanagedType.U4)] int Style,
            [MarshalAs(UnmanagedType.U4)] int Timeout,
            [MarshalAs(UnmanagedType.U4)] out int pResponse,
            bool bWait);

        [DllImport("wtsapi32.dll", SetLastError = true)]
        static extern bool WTSLogoffSession(IntPtr hServer, int SessionId, bool bWait);

        [DllImport("wtsapi32.dll", SetLastError = true)]
        static extern bool WTSDisconnectSession(IntPtr hServer, int SessionId, bool bWait);

        static Int32 InternalFindSession(IntPtr hServer, int UnifiedSessionId, out WTS_SESSION_INFO_1? Session)
        {
            Int32 retValue = 0;
            UInt32 Level = 1;
            UInt32 Count;
            IntPtr SessionInfo = IntPtr.Zero;
            Session = null;
            Int32 dataSize = Marshal.SizeOf(typeof(WTS_SESSION_INFO_1));

            if (!WTSEnumerateSessionsEx(hServer, ref Level, 0, ref SessionInfo, out Count))
            {
                retValue = Marshal.GetLastWin32Error();
            }
            else
            {
                long currentSession = SessionInfo.ToInt64();

                for (int i = 0; i < Count; i++)
                {
                    WTS_SESSION_INFO_1 si = (WTS_SESSION_INFO_1)Marshal.PtrToStructure((System.IntPtr)currentSession, typeof(WTS_SESSION_INFO_1));
                    currentSession += dataSize;
                    if (si.ExecEnvId == UnifiedSessionId)
                    {
                        Session = si;
                        break;
                    }
                }

                WTSFreeMemoryEx(WTS_TYPE_CLASS.WTSTypeSessionInfoLevel1, SessionInfo, Count);
            }

            return retValue;
        }

        static Int32 InternalOpenServer(string ServerName, int UnifiedSessionId, out IntPtr ServerHandle, out int SessionId)
        {
            Int32 retValue = 0;
            IntPtr hServer;
            int NewSessionId = UnifiedSessionId;
            ServerHandle = IntPtr.Zero;
            SessionId = 0;

            hServer = WTSOpenServerEx(ServerName);
            if (hServer == IntPtr.Zero)
            {
                retValue = Marshal.GetLastWin32Error();
            }
            else
            {
                WTS_SESSION_INFO_1? Session;
                retValue = InternalFindSession(hServer, UnifiedSessionId, out Session);
                if (retValue == 0)
                {
                    if (Session.HasValue)
                    {
                        if (Session.Value.pHostName == null)
                        {
                            NewSessionId = Session.Value.SessionId;
                            WTSCloseServer(hServer);
                            hServer = WTSOpenServer(ServerName);
                            if (hServer == IntPtr.Zero)
                            {
                                retValue = Marshal.GetLastWin32Error();
                            }
                        }
                    }
                    else
                    {
                        retValue = ERROR_NOT_FOUND;
                    }
                }
            }

            if (retValue == 0)
            {
                ServerHandle = hServer;
                SessionId = NewSessionId;
            }

            return retValue;
        }

        public static Int32 SendMessage(string ServerName, int UnifiedSessionId, string MessageTitle, string MessageBody)
        {
            int response = 0;
            IntPtr hServer = IntPtr.Zero;
            int SessionId = 0;
            Int32 retValue = InternalOpenServer(ServerName, UnifiedSessionId, out hServer, out SessionId);

            if (retValue == 0)
            {
                if (!WTSSendMessage(hServer, SessionId, MessageTitle, MessageTitle.Length, MessageBody, MessageBody.Length, 0, 0, out response, false))
                {
                    retValue = Marshal.GetLastWin32Error();
                }
            }

            WTSCloseServer(hServer);
            return retValue;
        }

        public static Int32 LogoffSession(string ServerName, int UnifiedSessionId)
        {
            IntPtr hServer = IntPtr.Zero;
            int SessionId = 0;
            Int32 retValue = InternalOpenServer(ServerName, UnifiedSessionId, out hServer, out SessionId);

            if (retValue == 0)
            {
                if (!WTSLogoffSession(hServer, SessionId, true))
                {
                    retValue = Marshal.GetLastWin32Error();
                }
            }

            WTSCloseServer(hServer);
            return retValue;
        }

        public static Int32 DisconnectSession(string ServerName, int UnifiedSessionId)
        {
            IntPtr hServer = IntPtr.Zero;
            int SessionId = 0;
            Int32 retValue = InternalOpenServer(ServerName, UnifiedSessionId, out hServer, out SessionId);

            if (retValue == 0)
            {
                if (!WTSDisconnectSession(hServer, SessionId, true))
                {
                    retValue = Marshal.GetLastWin32Error();
                }
            }

            WTSCloseServer(hServer);
            return retValue;
        }
    }
    
    // Session Collection Property classes
    
    public class RDSessionHostCollectionGeneralProperties 
    {
        public string CollectionName        { get; private set; }
        public string CollectionDescription { get; set; }
        public string CustomRdpProperty     { get; set; }

        public RDSessionHostCollectionGeneralProperties( 
            string collectionName,
            string collectionDescription,
            string customRdpProperty
            )
        {
            CollectionName        = collectionName;
            CollectionDescription = collectionDescription;
            CustomRdpProperty = customRdpProperty;
        }
    }

    public class RDSessionHostCollectionUserGroupProperties 
    {
        public string   CollectionName { get; private set; }
        public string[] UserGroup      { get; set; }

        public RDSessionHostCollectionUserGroupProperties( 
            string   collectionName,
            string[] userGroup
            )
        {
            CollectionName = collectionName;
            UserGroup      = userGroup;
        }
    }
    
    public enum RDBrokenConnectionAction
    {
        None       = 0,
        Disconnect = 1,
        LogOff     = 2
    };
    
    public class RDSessionHostCollectionConnectionProperties 
    {
        public string                   CollectionName                { get; private set; }
        public int                      DisconnectedSessionLimitMin   { get; set; }
        public RDBrokenConnectionAction BrokenConnectionAction        { get; set; }
        public bool                     TemporaryFoldersDeletedOnExit { get; set; }
        public bool                     AutomaticReconnectionEnabled  { get; set; }
        public int                      ActiveSessionLimitMin         { get; set; }
        public int                      IdleSessionLimitMin           { get; set; }
        
        public RDSessionHostCollectionConnectionProperties( 
            string                   collectionName,
            int                      disconnectedSessionLimitMin,
            RDBrokenConnectionAction brokenConnectionAction,
            bool                     temporaryFoldersDeletedOnExit,
            bool                     automaticReconnectionEnabled,
            int                      activeSessionLimitMin,
            int                      idleSessionLimitMin
            )
        {
            CollectionName                = collectionName;
            DisconnectedSessionLimitMin   = disconnectedSessionLimitMin;
            BrokenConnectionAction        = brokenConnectionAction;
            TemporaryFoldersDeletedOnExit = temporaryFoldersDeletedOnExit;
            if (BrokenConnectionAction == RDBrokenConnectionAction.Disconnect)
            {
                AutomaticReconnectionEnabled = automaticReconnectionEnabled;
            }
            else
            {
                AutomaticReconnectionEnabled = false;
            }
            ActiveSessionLimitMin = activeSessionLimitMin;
            IdleSessionLimitMin   = idleSessionLimitMin;
        }
    }

    public class RDSessionHostCollectionUserProfileDiskProperties 
    {
        public string     CollectionName           { get; private set; }
        public string[]   IncludeFolderPath        { get; set; }
        public string[]   ExcludeFolderPath        { get; set; }
        public string[]   IncludeFilePath          { get; set; }
        public string[]   ExcludeFilePath          { get; set; }
        public string     DiskPath                 { get; set; }
        public bool       EnableUserProfileDisk    { get; set; }
        public int        MaxUserProfileDiskSizeGB { get; set; }
                        
        public RDSessionHostCollectionUserProfileDiskProperties( 
            string     collectionName,
            string[]   includeFolderPath,
            string[]   excludeFolderPath,
            string[]   includeFilePath,
            string[]   excludeFilePath,
            string     diskPath,
            bool       enableUserProfileDisk,
            int        maxUserProfileDiskSizeGB
            )
        {
            CollectionName           = collectionName;
            IncludeFolderPath        = includeFolderPath;
            ExcludeFolderPath        = excludeFolderPath;
            IncludeFilePath          = includeFilePath;
            ExcludeFilePath          = excludeFilePath;
            DiskPath                 = diskPath;
            EnableUserProfileDisk    = enableUserProfileDisk;
            MaxUserProfileDiskSizeGB = maxUserProfileDiskSizeGB;
        }
    }
    
    public enum RDEncryptionLevel
    {
        None             = 0,
        Low              = 1,
        ClientCompatible = 2,
        High             = 3,
        FipsCompliant    = 4
    };
    
    public enum RDSecurityLayer
    {
        RDP       = 0,
        Negotiate = 1,
        SSL       = 2
    };

    public class RDSessionHostCollectionSecurityProperties 
    {
        public string             CollectionName       { get; private set; }
        public bool               AuthenticateUsingNLA { get; set; }
        public RDEncryptionLevel  EncryptionLevel      { get; set; }
        public RDSecurityLayer    SecurityLayer        { get; set; }
        
        public RDSessionHostCollectionSecurityProperties( 
            string            collectionName,
            bool              authenticateUsingNLA,
            RDEncryptionLevel encryptionLevel,
            RDSecurityLayer   securityLayer
            )
        {
            CollectionName       = collectionName;
            AuthenticateUsingNLA = authenticateUsingNLA;
            EncryptionLevel      = encryptionLevel;
            SecurityLayer        = securityLayer;
        }
    }
    
    public class RDSessionHostCollectionLoadBalancingInstance 
    {
        public string CollectionName { get; private set; }
        public int    RelativeWeight { get; set; }
        public int    SessionLimit   { get; set; }
        public string SessionHost    { get; set; }
                
        public RDSessionHostCollectionLoadBalancingInstance( 
            string collectionName,
            int    relativeWeight,
            int    sessionLimit,
            string sessionHost
            )
        {
            CollectionName = collectionName;
            RelativeWeight = relativeWeight;
            SessionLimit   = sessionLimit;
            SessionHost    = sessionHost;
        }
    }

    public class RDSessionHostCollectionClientProperties 
    {
        public string                           CollectionName                 { get; private set; }
        public RDClientDeviceRedirectionOptions ClientDeviceRedirectionOptions { get; set; }
        public int                              MaxRedirectedMonitors          { get; set; }
        public int                              ClientPrinterRedirected        { get; set; }
        public int                              RDEasyPrintDriverEnabled       { get; set; }
        public int                              ClientPrinterAsDefault         { get; set; }
        
        public RDSessionHostCollectionClientProperties( 
            string                           collectionName,
            RDClientDeviceRedirectionOptions clientDeviceRedirectionOptions,
            int                              maxRedirectedMonitors,
            int                              clientPrinterRedirected,
            int                              rdEasyPrintDriverEnabled,
            int                              clientPrinterAsDefault
            )
        {
            CollectionName                 = collectionName;
            ClientDeviceRedirectionOptions = clientDeviceRedirectionOptions;
            MaxRedirectedMonitors          = maxRedirectedMonitors;
            ClientPrinterRedirected        = clientPrinterRedirected;
            RDEasyPrintDriverEnabled       = rdEasyPrintDriverEnabled;
            ClientPrinterAsDefault         = clientPrinterAsDefault;
        }
    }

    // Session Desktop Collection classes

    public enum RDSessionCollectionType {
        Unknown    = 0,
        PooledUnmanaged    = 1,
        PersonalUnmanaged  = 2
    }
    
    public class RDSessionCollection 
    {
        public string   CollectionName        { get; private set; }
        public string   CollectionAlias       { get; private set; }
        public string   CollectionDescription { get; set; }
        public int      Size                  { get; private set; }
        public string   ResourceType          { get; private set; }

        public bool     AutoAssignPersonalDesktop { get; private set; }
        public bool     GrantAdministrativePrivilege{get; private set;}

        public RDSessionCollectionType CollectionType { get; private set; }

        public RDSessionCollection( 
            string   collectionName, 
            string   collectionAlias,
            string   collectionDescription,
            int      size,
            string   resourceType,
            RDSessionCollectionType collectionType,
            bool     autoAssignPersonalDesktop,
            bool     grantAdministrativePrivilege
            )
        {
            CollectionName        = collectionName;
            CollectionAlias       = collectionAlias;
            CollectionDescription = collectionDescription;
            Size                  = size;
            ResourceType          = resourceType;
            CollectionType        = collectionType;
            AutoAssignPersonalDesktop = autoAssignPersonalDesktop;
            GrantAdministrativePrivilege = grantAdministrativePrivilege;
        }
    }

    public enum RDServerNewConnectionAllowed
    {
        Yes            = 0,
        NotUntilReboot = 1,
        No             = 2
    };

    public class RDServer
    {
        public string                       CollectionName          { get; private set; }
        public string                       SessionHost             { get; private set; }
        public RDServerNewConnectionAllowed NewConnectionAllowed    { get; private set; }

        public RDServer( 
            string                       collectionName,
            string                       sessionHost, 
            RDServerNewConnectionAllowed newConnectionAllowed
            )
        {
            CollectionName          = collectionName;
            SessionHost             = sessionHost;
            NewConnectionAllowed    = newConnectionAllowed;
        }
    }
    
    // Start Menu Application classes
    
    public class StartMenuApp
    {
        public string CollectionName { get; private set; }
        public string DisplayName { get; private set; }
        public string FilePath { get; private set; }
        public string FileVirtualPath { get; private set; }
        public string CommandLineArguments { get; private set; }
        
        public byte[] IconContents { get; private set; }
        public Int32 IconIndex { get; private set; }
        public string IconPath { get; private set; }
        
        public StartMenuApp(string collectionName,
                            string displayName,
                            string filePath,
                            string fileVirtualPath,
                            string commandLineArguments,
                            byte[] iconContents,
                            Int32 iconIndex,
                            string iconPath)
        {
            CollectionName = collectionName;
            DisplayName = displayName;
            FilePath = filePath;
            FileVirtualPath = fileVirtualPath;
            CommandLineArguments = commandLineArguments;
            IconContents = iconContents;
            IconIndex = iconIndex;
            IconPath = iconPath;
        }
    }

    // Virtual Desktop Collection classes
    
    public enum VirtualDesktopStorageType
    {
        LocalStorage = 1,
        CentralSmbShareStorage = 2,
        CentralSanStorage = 3
    }

    public enum RDVirtualDesktopCollectionType
    {
        Unknown            = 0,
        PooledManaged      = 1,
        PooledUnmanaged    = 2,
        PersonalManaged    = 3,
        PersonalUnmanaged  = 4
    }
    
    public enum VirtualDesktopCollectionUpdateStatus
    {
        INITIALIZED = 0,
        SUBMITTED = 1,
        UPDATE_STARTED = 2,
        FORCE_LOGOFF_STARTED = 3,
        UPDATE_COMPLETE = 4,
        UPDATE_FAILED = 5,
        UPDATE_CANCELLED = 6
    }

    public enum VirtualDesktopCollectionJobStatus
    {
        UNKNOWN = 0,
        POOL_CREATED = 1,
        CREATE_VIRTUAL_DESKTOP_INPROGRESS = 2,
        ADD_VIRTUAL_DESKTOP_INPROGRESS = 3,
        UPDATE_VIRTUAL_DESKTOP_INPROGRESS = 4,
        DELETE_VIRTUAL_DESKTOP_INPROGRESS = 5,
        UPDATE_SCHEDULED = 6,
        UPDATE_FAILED = 7,
        UPDATE_CANCELLED = 8,
        JOB_COMPLETED = 10,
        CANCEL_INPROGRESS = 11,
        JOB_ABORTED = 12,
        EXPORT_INPROGRESS = 13
    }

    public class RDVirtualDesktopCollectionJobStatus
    {
        public String CollectionName{ get; private set; }
        public VirtualDesktopCollectionJobStatus Status{ get; private set; }
        public DateTime StartTime{ get; private set; }
        public DateTime LastModifiedTime{ get; private set; }
        public uint TotalVirtualDesktop{ get; private set; }
        public string PercentCompleted{ get; private set; }
        public uint FailedVirtualDesktop{ get; private set; }
        public VirtualDesktopJobStatus[] VirtualDesktopStatus{ get; private set; }

        public RDVirtualDesktopCollectionJobStatus(
            String collectionName,
            VirtualDesktopCollectionJobStatus status,
            DateTime startTime,
            DateTime lastModTime,
            uint totalDesktop,
            string completed,
            uint failed,
            VirtualDesktopJobStatus[] virtualDesktopStatus
        )
        {
            CollectionName=collectionName;
            Status=status;
            StartTime=startTime;
            LastModifiedTime=lastModTime;
            TotalVirtualDesktop=totalDesktop;
            PercentCompleted=completed;
            FailedVirtualDesktop=failed;
            VirtualDesktopStatus=virtualDesktopStatus;
        }
    }

    public class RDVirtualDesktopCollectionUpdateJobStatus
    {
        public String CollectionName{ get; private set; }
        public VirtualDesktopCollectionJobStatus Status{ get; private set; }
        public DateTime StartTime{ get; private set; }
        public DateTime ForceLogoffTime{ get; private set; }

        public RDVirtualDesktopCollectionUpdateJobStatus(
            String collectionName,
            VirtualDesktopCollectionJobStatus status,
            DateTime startTime,
            DateTime logoffTime)
        {
            CollectionName=collectionName;
            Status=status;
            StartTime=startTime;
            ForceLogoffTime=logoffTime;
        }
    }

    public class RDVirtualDesktopCollectionExportStatus
    {
        public String CollectionName{ get; private set; }
        public VirtualDesktopCollectionJobStatus Status{ get; private set; }
        public String VirtualDesktopTemplateName{ get; private set; }

        public RDVirtualDesktopCollectionExportStatus(
            String collectionName,
            String templateVmName
            )
        {
            CollectionName=collectionName;
            VirtualDesktopTemplateName=templateVmName;
            Status = VirtualDesktopCollectionJobStatus.EXPORT_INPROGRESS;
        }
    }

    public class RDVirtualDesktopCollection
    {
        public string   CollectionName { get; private set; }
        public string   CollectionAlias { get; private set; }
        public RDVirtualDesktopCollectionType Type { get; private set; }
        public string   Description { get; private set; }
        public bool     ShowInWebAccess{get; private set;}
        public bool     AutoAssignPersonalDesktop{get; private set;}
        public bool     GrantAdministrativePrivilege{get; private set;}
        public bool     VirtualDesktopRollback{get; private set;}
        public string[] Users { get; private set; }
        public uint     Size{get; private set;}
        public uint     PercentInUse{get; private set;}

        public RDVirtualDesktopCollection( 
            string   alias, 
            string   name, 
            string   description,
            RDVirtualDesktopCollectionType type,
            bool     showInPortal,
            bool     autoAssign,
            bool     userAdmin,
            bool     rollback,
            string[]    users,
            uint     size,
            uint     percentInUse
            )
        {
            CollectionAlias = alias;
            CollectionName = name;
            Description = description;
            Type = type;
            ShowInWebAccess=showInPortal;
            AutoAssignPersonalDesktop=autoAssign;
            GrantAdministrativePrivilege=userAdmin;
            VirtualDesktopRollback=rollback;
            Users = users;
            Size=size;
            PercentInUse=percentInUse;
        }
    }

    public enum VirtualDesktopState : uint
    {
        UNKNOWN = 0,
        RESUMING = 32777,
        RUNNING = 2,
        SAVED = 6,
        STOPPED = 3
    }

    public enum VirtualDesktopProvisioningStatus : uint
    {
        UNKNOWN = 0,
        SUCCESS = 2,
        FAILED = 3
    }

    public class RDVirtualDesktop
    {
        public string VirtualDesktopName {get; private set;}
        public string CollectionName {get; private set;}
        public string HostName {get; private set;}
        public VirtualDesktopState State {get; private set;}
        public VirtualDesktopProvisioningStatus ProvisioningStatus {get; private set;}

        public RDVirtualDesktop( 
            string   name,
            string   collectionName, 
            string   hostName, 
            uint     vmState,
            uint     provisioningStatus
            )
        {
            VirtualDesktopName = name;
            CollectionName = collectionName;
            HostName = hostName;
            State = VirtualDesktopState.UNKNOWN;
            switch(vmState)
            {
                case (uint)VirtualDesktopState.RESUMING:
                    State = VirtualDesktopState.RESUMING;
                    break;
                case (uint)VirtualDesktopState.RUNNING:
                    State = VirtualDesktopState.RUNNING;
                    break;
                case (uint)VirtualDesktopState.SAVED:
                    State = VirtualDesktopState.SAVED;
                    break;
                case (uint)(VirtualDesktopState.STOPPED):
                    State = VirtualDesktopState.STOPPED;
                    break;
            }
            ProvisioningStatus = VirtualDesktopProvisioningStatus.UNKNOWN;
            switch(provisioningStatus)
            {
                case (uint)VirtualDesktopProvisioningStatus.SUCCESS:
                    ProvisioningStatus = VirtualDesktopProvisioningStatus.SUCCESS;
                    break;
                case (uint)VirtualDesktopProvisioningStatus.FAILED:
                    ProvisioningStatus = VirtualDesktopProvisioningStatus.FAILED;
                    break;
            }
        }
    }

    public class RDPersonalVirtualDesktopAssignment
    {
        public string VirtualDesktopName{get; private set;}
        public string User{get; private set;}
        public RDPersonalVirtualDesktopAssignment(
            string   virtDesktopName, 
            string   user
            )
        {
            VirtualDesktopName = virtDesktopName;
            User = user;
        }
    }

    public class RDPersonalSessionDesktopAssignment
    {
        public string CollectionName{get; private set;}
        public string DesktopName{get; private set;}
        public string User{get; private set;}
        public RDPersonalSessionDesktopAssignment(
            string   InCollectionName,
            string   InDesktopName, 
            string   Inuser
            )
        {
            CollectionName = InCollectionName;
            DesktopName = InDesktopName;
            User = Inuser;
        }
    }


    // Virtual Desktop Collection Properties classes

    public class RDVirtualDesktopCollectionGeneralProperties 
    {
        public string CollectionDescription { get; private set; }
        public RDVirtualDesktopCollectionType CollectionType { get; private set; }
        public bool AutoAssignPersonalDesktop { get; private set; }
        public Int32 SaveDelayMinutes { get; private set; }
        public string CustomRdpProperty { get; private set; }

        public RDVirtualDesktopCollectionGeneralProperties( 
            string collectionDescription,
            bool autoAssignPersonalDesktop,
            RDVirtualDesktopCollectionType collectionType,
            Int32 saveDelay,
            string customRdpProperty
            )
        {
            CollectionDescription = collectionDescription;
            AutoAssignPersonalDesktop = autoAssignPersonalDesktop;
            CollectionType = collectionType;
            SaveDelayMinutes = saveDelay;
            CustomRdpProperty = customRdpProperty;
        }
    }
  
    public class RDVirtualDesktopCollectionUserProfileDisksProperties 
    {
        public string[]   IncludeFolderPath      { get; private set; }
        public string[]   ExcludeFolderPath      { get; private set; }
        public string[]   IncludeFilePath        { get; private set; }
        public string[]   ExcludeFilePath        { get; private set; }
        public string     DiskPath               { get; private set; }
        public bool       EnableUserProfileDisks { get; private set; }
        public int        MaxUserProfileDiskSizeGB { get; private set; }
                        
        public RDVirtualDesktopCollectionUserProfileDisksProperties( 
            string[]   includeFolderPath,
            string[]   excludeFolderPath,
            string[]   includeFilePath,
            string[]   excludeFilePath,
            string     diskLocation,
            bool       enableUserProfileDisks,
            int        maxUserProfileDiskSizeGB
            )
        {
            IncludeFolderPath = includeFolderPath;
            ExcludeFolderPath = excludeFolderPath;
            IncludeFilePath = includeFilePath;
            ExcludeFilePath = excludeFilePath;
            DiskPath = diskLocation;
            EnableUserProfileDisks = enableUserProfileDisks;
            MaxUserProfileDiskSizeGB = maxUserProfileDiskSizeGB;
        }
    }

    public class RDVirtualDesktopCollectionClientProperties 
    {
        public RDClientDeviceRedirectionOptions   ClientDeviceRedirectionOptions  { get; private set; }
        public bool  RedirectAllMonitors { get; private set; }
        public bool  RedirectClientPrinter   { get; private set; }
        
        public RDVirtualDesktopCollectionClientProperties( 
            RDClientDeviceRedirectionOptions   clientDeviceRedirectionOptions,
            bool  redirectAllMonitors,
            bool  redirectClientPrinter
            )
        {
            ClientDeviceRedirectionOptions = clientDeviceRedirectionOptions;
            RedirectAllMonitors = redirectAllMonitors;
            RedirectClientPrinter = redirectClientPrinter;
        }
    }
    
    public class RDVirtualDesktopCollectionVirtualDesktopsProperties
    {
        public string Domain { get; private set; }
        public string OU { get; private set; }
        public VirtualDesktopStorageType StorageType { get; private set; }
        public string CentralStoragePath { get; private set; }
        public string LocalStoragePath { get; private set; }
        public string VirtualDesktopTemplateName { get; private set; }
        public string VirtualDesktopTemplateHostServer{ get; private set; }
        public string VirtualDesktopTemplateExportPath { get; private set; }
        public string VirtualDesktopNamePrefix { get; private set; }
        public uint   VirtualDesktopNamePostfixStartIndex { get; private set; }
        
        public RDVirtualDesktopCollectionVirtualDesktopsProperties(
            string domain,
            string ou,
            VirtualDesktopStorageType storageType,
            string centralStorageLocation,
            string localVMCreationLocation,
            string virtualDesktopTemplateName,
            string virtualDesktopTemplateHostServer,
            string virtualDesktopTemplateExportLocation,
            string virtualDesktopNamePrefix,
            uint   virtualDesktopNamePostfixStartIndex
            )
        {
            Domain = domain;
            OU = ou;
            StorageType = storageType;
            CentralStoragePath = centralStorageLocation;
            LocalStoragePath = localVMCreationLocation;
            VirtualDesktopTemplateName = virtualDesktopTemplateName;
            VirtualDesktopTemplateHostServer = virtualDesktopTemplateHostServer;
            VirtualDesktopTemplateExportPath = virtualDesktopTemplateExportLocation;
            VirtualDesktopNamePrefix = virtualDesktopNamePrefix;
            VirtualDesktopNamePostfixStartIndex = virtualDesktopNamePostfixStartIndex;
        }
    }

    public enum RDPatchStatus
    {
        Unknown,
        Searching,
        Downloading,
        Applying,
        Rebooting,
        Rebooted,
        Success,
        Failure,
        Timeout
    }

    public class RDPersonalVirtualDesktopPatchSchedule
    {
        public string VirtualDesktopName { get; private set; }
        public byte[] Context { get; private set; }
        public DateTime Deadline { get; private set; }
        public DateTime StartTime  { get; private set; }
        public DateTime EndTime  { get; private set; }
        public string ID  { get; private set; }
        public string Label  { get; private set; }
        public string Plugin  { get; private set; }
        public RDPatchStatus   PatchStatus   { get; private set; }
        
        public RDPersonalVirtualDesktopPatchSchedule(
            string virtualDesktopName,
            byte[] context,
            DateTime deadline,
            DateTime startTime,
            DateTime endTime,
            string id,
            string label,
            string plugin,
            RDPatchStatus   patchStatus
            )
        {
            VirtualDesktopName = virtualDesktopName;
            Context = context;
            Deadline = deadline;
            StartTime = startTime;
            EndTime = endTime;
            ID = id;
            Label = label;
            Plugin = plugin;
            PatchStatus = patchStatus;
        }
    }

    // Workspace Management classes

    public class WorkspaceClass
    {
        public string WorkspaceID   {get; private set;}
        public string WorkspaceName {get; private set;}

        public WorkspaceClass(
            string wkspID,
            string wkspName
            )
        {
            WorkspaceID = wkspID;
            WorkspaceName = wkspName;
        }            
    }

    public class RDDeploymentServer
    {
        public string Server { get; private set; }
        public string[] Roles { get; private set; }

        public RDDeploymentServer(
                            string server,
                            string[] roles
                            )
        {
            Server = server;
            Roles = roles;
        }
    }

    public class RDVirtualDesktopConcurrency
    {
        public string FQDN { get; private set; }
        public int? Concurrency { get; private set; }

        public RDVirtualDesktopConcurrency(
            string fqdn,
            int? concurrency
            )
        {
            FQDN = fqdn;
            Concurrency = concurrency;
        }
    }

    public class RDVirtualDesktopIdleCount
    {
        public string FQDN { get; private set; }
        public int? Count { get; private set; }

        public RDVirtualDesktopIdleCount(
            string fqdn,
            int? count
            )
        {
            FQDN = fqdn;
            Count = count;
        }
    }

    public enum RDSH_TARGET_STATE
    {
        TARGET_UNKNOWN = 1,
        TARGET_INITIALIZING = 2,
        TARGET_RUNNING = 3,
        TARGET_DOWN = 4,
        TARGET_HIBERNATED =5 ,
        TARGET_STOPPED = 7,
        TARGET_INVALID = 8,
        TARGET_STARTING = 9,
        TARGET_STOPPING = 10
    }
}
"@

# Create all types for the module, as defined above.
Add-Type -TypeDefinition $CommonTypeDefinition -ReferencedAssemblies @("Microsoft.RemoteDesktopServices.Management.Activities","System.Management")
