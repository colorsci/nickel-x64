# Copyright © 2008, Microsoft Corporation. All rights reserved.

trap { break }


#run phishing filter diagnostics
.\TS_PhishingFilter.ps1

#run Block pop-ups diagnostics
.\TS_Blockpopups.ps1

#run IE security levels diagnostics
.\TS_IEsecuritylevels.ps1
