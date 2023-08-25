# Intel GUIDs
# HECI Svc
$global:intelCpHeciSvcAppId = '{11AC3232-E7D7-49CD-ABFE-501700100B3A}'
$global:intelCphsSessionClsid = '{C41B1461-3F8C-4666-B512-6DF24DE566D1}'
$global:intelCphsSessionInterfaceId = '{A91E0BDD-79B0-42C5-A3A0-5BE434329577}'
$global:intelCpHeciSvcTypelibId = '{66DBA565-0D3D-4D8A-9391-A2A4CF16DF40}'
$global:intelCphsSessionProxyStubClsid = '{00020424-0000-0000-C000-000000000046}'  # PSOAInterface -> oleaut32.dll

$global:intelCpHeciSvcLibName = 'IntelCpHeciSvcLib'
$global:intelCpHeciSvcBinaryName = 'IntelCpHeciSvc.exe'
$global:intelCpHeciSvcShortName = 'cphs'
$global:intelCphsSessionInterfaceName = 'ICphsSession'

$global:intelCpHeciSvcSearchName1 = 'cphs'
$global:intelCpHeciSvcSearchName2 = 'cpheci'

# HDCP Svc
$global:intelCpHdcpSvcAppId = '{84081F6F-8B2D-4FFE-AF7F-E72D488FABEB}'
$global:intelCLSPCONSvcCOMChannelClsid = '{7637B024-FD72-43E4-BF24-DEEE8953A32D}'
$global:intelLSPCONSvcCOMChannelInterfaceId = '{9DB454D7-0207-4B21-84E9-847B52B8EED3}'
$global:intelCpLSPConSvcTypelibId = '{7C2047A4-47F1-4EEF-BAF5-082E4AAB8B38}'
$global:intelLSPConSvcProxyStubClsid = '{00020424-0000-0000-C000-000000000046}'  # PSOAInterface -> oleaut32.dll

$global:intelCpHdcpSvcBinaryName = 'IntelCpHDCPSvc.exe'
$global:intelCLSPCONClassName = 'CLSPCONSvcCOMChannel'
$global:intelCpHdcpSvcShortName = 'cplspcon'

$global:intelHdcpSvcSearchName1 = 'lspcon' 
$global:intelHdcpSvcSearchName2 = 'cphdcp'

# All that matters for these is registration, not current running
# Old and new driver UMDs are registered.  Need to know which ControlSet class GUID is the one.
#   Use HKLM\SYSTEM\CurrentControlSet\Control\Video
#    One of these GUID subdirs will be Intel.  Underneath:
#       0000 ....   Each has a gaggle of settings and VolatileSettings subdir
#       Video - keys:
#         DeviceDesc
#         Driver -> REG_SZ with GUID and current instance (0000, 0001, etc)
#         Service:  igfx

$global:intelUmdSpotCheck1 = 'igdumdim64.dll'    
$global:intelUmdSpotCheck2 = 'igd11dxva64.dll'
$global:intelUmdSpotCheck3 = 'iglhcp64.dll'

# The KMD can't unload unless the machine transitions back to the BDA driver, which does not happen normally with DriverStore
#  Old KMD and new UMD DLLs, and old KMD and new CP services, must maintain compatibility to function after update and before reboot
#  Intel input is that old KMD w/ new HDCP service cannot be guaranteed
#   Registry:  HKLM\SYSTEM\CurrentControlSet\Services\igfx\ImagePath - REG_EXPAND_SZ path to KMD binary
$global:intelKmdServiceName = 'igfx'
$global:intelKmd = 'igdkmd64.sys'


