// Copyright (C) Microsoft. All rights reserved.

define(['legacy/core'], (core) => {
    class OobeSignalAndWaitForResponse {
        launchAsync()
        {
            CloudExperienceHost.Telemetry.logEvent("OobeSignalAndWaitForResponse_CALLED");

            try
            {
                return CloudExperienceHostAPI.UtilStaticsCore.waitForNamedSignal("WNF", "DEVICE_ACCOUNT_FLOW_COMPLETED").then((result) =>
                {
                    CloudExperienceHost.Telemetry.logEvent("waitForNamedSignal_COMPLETED");
                    let retval = "(no result)";
                    try { if (result) retval = result.toString(); } catch(err){retval = err.toString();}
                    return WinJS.Promise.as(CloudExperienceHost.AppResult.success);
                });
            }
            catch (err)
            {
                CloudExperienceHost.Telemetry.logEvent("waitForNamedSignal_FAILED", core.GetJsonFromError(err));
                return WinJS.Promise.as(CloudExperienceHost.AppResult.success);
            }
            return WinJS.Promise.as(CloudExperienceHost.AppResult.success);
        }
    }
    return OobeSignalAndWaitForResponse;
});
