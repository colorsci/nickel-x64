//
// Copyright (C) Microsoft. All rights reserved.
//
/// <disable>JS2085.EnableStrictMode</disable>
"use strict";
var CloudExperienceHost;
(function (CloudExperienceHost) {
    var BackupRestore;
    (function (BackupRestore) {
        function setRestoreProfileAsync(profileId, correlationVector) {
            return new WinJS.Promise(function (completeDispatch, errorDispatch) {
                if ((correlationVector === null) || (correlationVector === undefined)) {
                    correlationVector = "";
                }
                CloudExperienceHostAPI.BackupRestoreManager.setRestoreProfileAsync(profileId, correlationVector).done(function () {
                    completeDispatch();
                }, function (e) { errorDispatch(e); });
            });
        }
        BackupRestore.setRestoreProfileAsync = setRestoreProfileAsync;
        var OobeCloudBackupRestore;
        (function (OobeCloudBackupRestore) {
            function getShouldSkipAsync() {
                return new WinJS.Promise(function (completeDispatch /*, errorDispatch */) {
                    let policyValue = CloudExperienceHostAPI.UtilStaticsCore.getLicensingPolicyValue("OOBE-Skip-CloudBackupRestore");
                    completeDispatch(policyValue != 0);
                });
            }
            OobeCloudBackupRestore.getShouldSkipAsync = getShouldSkipAsync;
        })(OobeCloudBackupRestore = BackupRestore.OobeCloudBackupRestore || (BackupRestore.OobeCloudBackupRestore = {}));
    })(BackupRestore = CloudExperienceHost.BackupRestore || (CloudExperienceHost.BackupRestore = {}));
})(CloudExperienceHost || (CloudExperienceHost = {}));
//# sourceMappingURL=backuprestore.js.map