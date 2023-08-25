trap { break }

. .\CL_Telemetry.ps1
#send start time
ReportDiagnosis

#run Text Services Framework diagnostic
.\TS_Cicero.ps1

