# Copyright © 2008, Microsoft Corporation. All rights reserved.

#terminate on uncaught exception
trap { break }


#Localization Data
Import-LocalizedData localizationString

#run IE add-on diagnostic
.\VF_IEDefectiveAddon.ps1

#run IE Cache policy for temporary internet files diagnostic
.\TS_pagesyncpolicy.ps1

#run Disk space setting for temporary internet files diagnostic
.\TS_tempfilecachesize.ps1

#run Number of concurrent server connections diagnostic
.\TS_IEconnection.ps1

#run IE add-on loading time
.\TS_IEAddonLoadingTime.ps1