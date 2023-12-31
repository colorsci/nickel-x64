# Localized	05/07/2022 03:27 AM (GMT)	303:7.0.30723 	CL_LocalizationData.psd1
ConvertFrom-StringData @'
###PSLOC
progress_ts_indexingService=Checking the Windows Search service
progress_ts_indexerCrashing=Checking for recent Windows Search Service crashes
progress_ts_filterHostCrashing=Checking for recent Windows Search Filter Host crashes
progress_ts_protocolHostCrashing=Checking for recent Windows Search Protocol Host crashes
progress_ts_indexingServiceForcedShutdown=Checking for forced shutdown events
progress_ts_indexingServiceFailedRecovery=Checking for failed recovery events
progress_ts_checkPermissions=Checking for bad permissions on indexer directories
progress_ts_searchApp=Checking Windows Search
progress_rs_restorePermissions=Restoring correct permissions on indexer directories
progress_rs_startIndexingService=Starting the Windows Search service
progress_rs_restoreDefaults=Restoring default settings and restarting the Windows Search service
progress_rs_restoreSearchApp=Restarting the Windows Search application
indexerEvent_name=Windows Search Service Events
indexerEvent_description=The event(s) indicating a crash in the Windows Search service. The event payload may indicate the faulting module
filterHostEvent_name=Windows Search Filter Host Events
filterHostEvent_description=The event(s) indicating a crash in the Windows Search Filter Host. The event payload may indicate the faulting module
protocolHostEvent_name=Windows Search Protocol Host Events
protocolHostEvent_description=The event(s) indicating a crash in the Windows Search Protocol Host. The event payload may indicate the faulting module
dataDirectory_name=Directory
dataDirectory_description=Windows Search data directory
dataDirectoryOwner_name=Data directory owner
dataDirectoryOwner_description=Owner of Windows Search data directory
dataDirectoryPermissions_name=Data directory permissions
dataDirectoryPermissions_description=Permissions on Windows Search data directory
problemType_name=Problem Type
problemType_description=User-reported problems
userProblem_name=Problem
userProblem_description=User-defined problem
error_information=Exception Information
error_function_name=Calling {0} Failed
error_function_description=When the function {0} called an exception occurred
error_file_name=Executing {0} Failed
error_file_description=When the file {0} is executed an exception occurred
throw_invalidFileName=Invalid File Name
throw_noExecutableCommandSpecified=No executable command is specified
throw_win32APIFailed=Calling win32 API {0} failed. The error code is {1}
###PSLOC
'@
