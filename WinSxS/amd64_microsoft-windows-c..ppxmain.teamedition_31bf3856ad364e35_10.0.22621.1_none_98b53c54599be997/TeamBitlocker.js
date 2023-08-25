//
// Copyright (C) Microsoft. All rights reserved.
//
// This launcher enables bitlocker in Surface Hub

define(['legacy/core'], (core) => {
    class TeamBitlocker {
        launchAsync(currentNode) {
            return new WinJS.Promise(function (completeDispatch /*, errorDispatch, progressDispatch */) {
                try {
                    CloudExperienceHost.Telemetry.logEvent("enableBitlockerCalled");
                    Team.DeviceAdmin.DeviceAdminAccount.enableBitlockerAsync().done(
                        () => {
                            CloudExperienceHost.Telemetry.logEvent("enableBitlockerAsyncCompleted");
                            completeDispatch(CloudExperienceHost.AppResult.success);
                        },
                        (error) => {
                            CloudExperienceHost.Telemetry.logEvent("enableBitlockerAsyncError", core.GetJsonFromError(error));
                            completeDispatch(CloudExperienceHost.AppResult.fail);
                        }
                    );
                }
                catch (err) {
                    CloudExperienceHost.Telemetry.logEvent("enableBitlockerAsyncThrew", core.GetJsonFromError(err));
                    completeDispatch(CloudExperienceHost.AppResult.fail);
                }
            });
        }
    }
    return TeamBitlocker;
});
