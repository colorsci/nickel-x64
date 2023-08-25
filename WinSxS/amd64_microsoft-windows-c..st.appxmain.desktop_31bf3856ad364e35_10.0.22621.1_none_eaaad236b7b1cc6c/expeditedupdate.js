//
// Copyright (C) Microsoft. All rights reserved.
//
/// <disable>JS2085.EnableStrictMode</disable>
"use strict";
var CloudExperienceHost;
(function (CloudExperienceHost) {
    class ExpeditedUpdate {
        static getShouldSkipAsync() {
            let localAccountManager = new CloudExperienceHostBroker.Account.LocalAccountManager();
            let zdpManager = AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeZdpManagerStaticsCore");
            let skipExpeditedUpdate = localAccountManager.unattendCreatedUser || zdpManager.shouldSkip;
            if (!skipExpeditedUpdate) {
                skipExpeditedUpdate = true;
                try {
                    let expeditedUpdateManager = AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeExpeditedUpdateManagerStatics");
                    skipExpeditedUpdate = expeditedUpdateManager.shouldSkip;
                }
                catch (error) {
                }
            }
            return WinJS.Promise.wrap(skipExpeditedUpdate);
        }
        // Monitor status change
        static setStatusHandler() {
            try {
                CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_setStatusHandlerStarted");
                AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeExpeditedUpdateManagerStatics").onstatuschanged = (status) => {
                    let bridge = CloudExperienceHost.AppManager.getGlobalBridgeInstance();
                    bridge.fireEvent(CloudExperienceHost.Events.windowsUpdateStatus, status.detail);
                };
                CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_setStatusHandlerCompleted");
            }
            catch (err) {
                CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_setStatusHandlerFailure", CloudExperienceHost.GetJsonFromError(err));
            }
        }
        // Start WU scan
        static startWUScan() {
            CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_startWUScanStarted");
            return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch*/) {
                AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeExpeditedUpdateManagerStatics").startScanAsync().then(() => {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_startWUScanStartedSuccedded");
                    completeDispatch();
                }, (err) => {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_startWUScanStartedFailure", CloudExperienceHost.GetJsonFromError(err));
                    errorDispatch(err);
                });
            });
        }
        // Cancel WU scan
        static cancelWUScan() {
            CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_cancelWUScanStarted");
            return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch*/) {
                AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeExpeditedUpdateManagerStatics").cancelScanAsync().then(() => {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_cancelWUScanSucceeded");
                    completeDispatch();
                }, (err) => {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_cancelWUScanFailure", CloudExperienceHost.GetJsonFromError(err));
                    errorDispatch(err);
                });
            });
        }
        // Get scan results
        static getUpdateResults() {
            return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch*/) {
                try {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_getUpdateResultsStarted");
                    let updateResults = AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeExpeditedUpdateManagerStatics").getUpdateResults();
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_getUpdateResultsUpdateResults", JSON.stringify(updateResults));
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_getUpdateResultsSucceeded");
                    completeDispatch(updateResults);
                }
                catch (err) {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_getUpdateResultsFailure", CloudExperienceHost.GetJsonFromError(err));
                    errorDispatch(err);
                }
            });
        }
        static commitExpeditionChoiceForSync(guidNdupPropList) {
            CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_commitExpeditionChoiceForSyncStarted");
            return this.dispatchCommitExpeditionChoice(guidNdupPropList, 1);
        }
        static commitExpeditionChoiceForAsync(guidNdupPropList) {
            CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_commitExpeditionChoiceForAsyncStarted");
            return this.dispatchCommitExpeditionChoice(guidNdupPropList, 2);
        }
        static commitExpeditionChoiceForDeferred(guidNdupPropList) {
            CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_commitExpeditionChoiceForDeferredStarted");
            return this.dispatchCommitExpeditionChoice(guidNdupPropList, 3);
        }
        static dispatchCommitExpeditionChoice(guidNdupPropList, commitChoice) {
            CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_dispatchCommitExpeditionChoiceStarted");
            return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch*/) {
                let guidNDUPMap = new Windows.Foundation.Collections.StringMap();
                Object.keys(guidNdupPropList).forEach(function (key) {
                    guidNDUPMap.insert(key, guidNdupPropList[key]);
                });
                CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_dispatchCommitExpeditionChoiceCommitList: ", JSON.stringify(guidNDUPMap));
                CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_dispatchCommitExpeditionChoiceCommitChoice: ", JSON.stringify(commitChoice));
                AppObjectFactory.getInstance().getObjectFromString("CloudExperienceHostAPI.OobeExpeditedUpdateManagerStatics").commitExpeditionChoiceAsync(guidNDUPMap.getView(), commitChoice).then(() => {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_dispatchCommitExpeditionChoiceSucceeded");
                    completeDispatch();
                }, (err) => {
                    CloudExperienceHost.Telemetry.logEvent("ExpeditedUpdate_dispatchCommitExpeditionChoiceFailure", CloudExperienceHost.GetJsonFromError(err));
                    errorDispatch(err);
                });
            });
        }
    }
    CloudExperienceHost.ExpeditedUpdate = ExpeditedUpdate;
})(CloudExperienceHost || (CloudExperienceHost = {}));
//# sourceMappingURL=expeditedupdate.js.map