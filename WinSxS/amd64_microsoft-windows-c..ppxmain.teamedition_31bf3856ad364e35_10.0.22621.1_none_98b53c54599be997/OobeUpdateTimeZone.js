// Copyright (C) Microsoft. All rights reserved.

define(['legacy/core'], (core) => {
    class OobeUpdateTimeZone {
        launchAsync() {
            return new WinJS.Promise(function (completeDispatch /*, errorDispatch, progressDispatch */) {
                CloudExperienceHost.Telemetry.logEvent("OobeUpdateTimeZoneCalled");
                try {
                    CloudExperienceHostAPI.UtilStaticsCore.updateTimeZoneAsync().done(
                        function () {
                            CloudExperienceHost.Telemetry.logEvent("OobeUpdateTimeZoneSucceeded");
                            completeDispatch(CloudExperienceHost.AppResult.success);
                        },
                        function (err) {
                            CloudExperienceHost.Telemetry.logEvent("OobeUpdateTimeZoneFailed", core.GetJsonFromError(err));
                            completeDispatch(CloudExperienceHost.AppResult.fail);
                        }
                    );
                } catch (err) {
                    CloudExperienceHost.Telemetry.logEvent("OobeUpdateTimeZoneThrew", core.GetJsonFromError(err));
                    completeDispatch(CloudExperienceHost.AppResult.fail);
                }
            });
        }
    }
    return OobeUpdateTimeZone;
});
