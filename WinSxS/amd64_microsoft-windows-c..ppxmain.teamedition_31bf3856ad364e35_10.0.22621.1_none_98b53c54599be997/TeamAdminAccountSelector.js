//
// Copyright (C) Microsoft. All rights reserved.
//
// This launcher checks whether Surface Hub needs a device admin or not.
// Device admin is needed in the following situations:
//  1. If device has no local admin account
//  2. If device has not been AADJed
//  3. If device has not been Domain Joined, or
//  4. If device has been Domain Joined but no security group has yet been configured.
// Depending the situation, launcher navigates to different CXH nodes

define(['legacy/core'], (core) => {
    class TeamAdminAccountSelector {
        launchAsync(currentNode) {
            return new WinJS.Promise(function (completeDispatch /*, errorDispatch, progressDispatch */) {
                Team.DeviceAdmin.DeviceAdminAccount.isDeviceAdminNeededAsync().then(
                    (isAdminNeeded) => {
                        CloudExperienceHost.Telemetry.logEvent("isDeviceAdminNeededAsyncCompleted", isAdminNeeded);
                        if (isAdminNeeded) {
                            Team.DeviceAdmin.DeviceAdminAccount.isDeviceDomainJoinedAsync().then(
                                (isDomainJoined) => {
                                    CloudExperienceHost.Telemetry.logEvent("isDeviceDomainJoinedAsyncCompleted", isDomainJoined);
                                    if (isDomainJoined) {
                                        completeDispatch(CloudExperienceHost.AppResult.action2);
                                    }
                                    else {
                                        completeDispatch(CloudExperienceHost.AppResult.success);
                                    }
                                },
                                (error) => {
                                    CloudExperienceHost.Telemetry.logEvent("isDeviceDomainJoinedAsyncError", core.GetJsonFromError(error));
                                }
                            );
                        }
                        else {
                            completeDispatch(CloudExperienceHost.AppResult.action1);
                        }
                    },
                    (error) => {
                        CloudExperienceHost.Telemetry.logEvent("isDeviceAdminNeededAsyncError", core.GetJsonFromError(error));
                        completeDispatch(CloudExperienceHost.AppResult.fail);
                    }
                );
            });
        }
    }
    return TeamAdminAccountSelector;
});
