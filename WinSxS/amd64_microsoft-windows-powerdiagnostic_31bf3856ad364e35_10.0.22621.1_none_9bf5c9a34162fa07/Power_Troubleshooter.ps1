# Copyright © 2008, Microsoft Corporation. All rights reserved.

# Break on all uncaught exceptions
trap {break}

#run screen saver diagnostic
.\TS_ScreenSaver.ps1

#run high performance Power plan diagnostic
.\TS_Balanced.ps1

#run USB Selective diagnostic
.\TS_USBSelective.ps1

#run Display Idle Timeout diagnostic
.\TS_DisplayIdleTimeout.ps1

#run Idle Disk Timeout diagnostic
.\TS_IdleDiskTimeout.ps1

#run Idle Sleep setting diagnostic
.\TS_IdleSleepsetting.ps1

#run Wireless adapter settings diagnostic
.\TS_Wirelessadaptersettings.ps1

#run screen brightness diagnostic
.\TS_ScreenBrightness.ps1

#run processor state diagnostic
.\TS_MinProcessorState.ps1

#run dim display diagnostic
.\TS_DimDisplay.ps1