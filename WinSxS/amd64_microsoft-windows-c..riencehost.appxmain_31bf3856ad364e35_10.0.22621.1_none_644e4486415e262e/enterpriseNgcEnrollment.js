//
// Copyright (C) Microsoft. All rights reserved.
//
/// <disable>JS2085.EnableStrictMode</disable>
"use strict";
var CloudExperienceHost;
(function (CloudExperienceHost) {
    var EnterpriseNgcEnrollment;
    (function (EnterpriseNgcEnrollment) {
        function didHelloEnrollmentSucceed() {
            return (CloudExperienceHost.getCurrentNode().cxid === "EnterpriseHelloNGC");
        }
        EnterpriseNgcEnrollment.didHelloEnrollmentSucceed = didHelloEnrollmentSucceed;

        function enrollForNgc() {
            return new WinJS.Promise((completeDispatch, errorDispatch) => {
                var NgcContainerOptionsEnum = {
                    Default : 0,
                    PreserveContainer: 1,
                    ClearContainer : 2
                };
                var ContainerOptions;
                if (CloudExperienceHost.getCurrentNode().cxid === "EnterpriseNGCReset") {
                    ContainerOptions = NgcContainerOptionsEnum.ClearContainer;
                }
                else if (CloudExperienceHost.getCurrentNode().cxid === "EnterpriseNGCFixMe") {
                    ContainerOptions = NgcContainerOptionsEnum.PreserveContainer;
                }
                else {
                    ContainerOptions = NgcContainerOptionsEnum.Default;
                }

                let isTransparencyOptionSetOnCredUICoordinator = false;
                if (CloudExperienceHost.getContext().personality === CloudExperienceHost.TargetPersonality.LiteWhite) {
                    // Attempt to launch CredUI as transparent in this specific context
                    isTransparencyOptionSetOnCredUICoordinator = CloudExperienceHost.CredUI.setTransparencyOptionOnCredUICoordinator();
                    if (isTransparencyOptionSetOnCredUICoordinator) {
                        CloudExperienceHost.AppFrameInternal.setChromeDimBasedOnFocus(isTransparencyOptionSetOnCredUICoordinator);
                        CloudExperienceHost.dimChrome();
                    }
                }

                // https://microsoftarchive.visualstudio.com/OS/_workitems/edit/11246443: Converge the WinRT activations for NgcRegManager and userNgcRegManager into one call
                var platform = CloudExperienceHost.Environment.getPlatform();
                var userObj = CloudExperienceHost.getIUser();
                if (platform == CloudExperienceHost.TargetPlatform.DESKTOP || !userObj) {
                    CloudExperienceHost.AppFrameInternal.showProgress().done(() => {
                        UserDeviceRegistration.Ngc.NgcRegManager.registerAsync(ContainerOptions).done((GUID) => {
                            _showViewAndRemoveTransparencyIfSet(isTransparencyOptionSetOnCredUICoordinator).done(() => {
                                completeDispatch();
                            });
                        }, (err) => {
                            _showViewAndRemoveTransparencyIfSet(isTransparencyOptionSetOnCredUICoordinator).done(() => {
                                errorDispatch({ number: err.number });
                            });
                        });
                    });
                }
                else {
                    var userNgcRegManager = UserDeviceRegistration.Ngc.UserNgcRegManagerFactory.getNgcRegManagerForUser(userObj);
                    CloudExperienceHost.AppFrameInternal.showProgress().done(() => {
                        userNgcRegManager.registerAsync(ContainerOptions).done((GUID) => {
                            _showViewAndRemoveTransparencyIfSet(isTransparencyOptionSetOnCredUICoordinator).done(() => {
                                completeDispatch();
                            });
                        }, (err) => {
                            _showViewAndRemoveTransparencyIfSet(isTransparencyOptionSetOnCredUICoordinator).done(() => {
                                errorDispatch({ number: err.number });
                            });
                        });
                    });
                }
            });
        }
        EnterpriseNgcEnrollment.enrollForNgc = enrollForNgc;

        function resetForNgc(ContainerOptions) {
            return new WinJS.Promise((completeDispatch, errorDispatch) => {
                // https://microsoftarchive.visualstudio.com/OS/_workitems/edit/11246443: Converge the WinRT activations for NgcRegManager and userNgcRegManager into one call
                let platform = CloudExperienceHost.Environment.getPlatform();
                let userObj = CloudExperienceHost.getIUser();
                if (platform == CloudExperienceHost.TargetPlatform.DESKTOP || !userObj) {
                    UserDeviceRegistration.Ngc.NgcRegManager.registerAsync(ContainerOptions).done((GUID) => {
                        completeDispatch();
                    }, (err) => {
                        errorDispatch({ number: err.number });
                    });
                }
                else {
                    let userNgcRegManager = UserDeviceRegistration.Ngc.UserNgcRegManagerFactory.getNgcRegManagerForUser(userObj);
                    userNgcRegManager.registerAsync(ContainerOptions).done((GUID) => {
                        completeDispatch();
                    }, (err) => {
                        errorDispatch({ number: err.number });
                    });
                }
            });
        }
        EnterpriseNgcEnrollment.resetForNgc = resetForNgc;

        function recoverForNgc() {
            return new WinJS.Promise((completeDispatch, errorDispatch) => {
                // https://microsoftarchive.visualstudio.com/OS/_workitems/edit/11246443: Converge the WinRT activations for NgcRegManager and userNgcRegManager into one call
                let platform = CloudExperienceHost.Environment.getPlatform();
                let userObj = CloudExperienceHost.getIUser();
                if (platform == CloudExperienceHost.TargetPlatform.DESKTOP || !userObj) {
                    UserDeviceRegistration.Ngc.NgcRegManager.recoverPinAsync().done((GUID) => {
                        completeDispatch();
                    }, (err) => {
                        errorDispatch({ number: err.number });
                    });
                }
                else {
                    let userNgcRegManager = UserDeviceRegistration.Ngc.UserNgcRegManagerFactory.getNgcRegManagerForUser(userObj);
                    userNgcRegManager.recoverPinAsync().done((GUID) => {
                        completeDispatch();
                    }, (err) => {
                        errorDispatch({ number: err.number });
                    });
                }
            });
        }
        EnterpriseNgcEnrollment.recoverForNgc = recoverForNgc;

        function _showViewAndRemoveTransparencyIfSet(isTransparencySet) {
            return new WinJS.Promise((completeDispatch, errorDispatch) => {
                CloudExperienceHost.AppFrameInternal.showView().done(() => {
                    if (isTransparencySet) {
                        CloudExperienceHost.AppFrameInternal.setChromeDimBasedOnFocus(false);
                        CloudExperienceHost.CredUI.removeTransparencyOptionOnCredUICoordinator();
                        CloudExperienceHost.undimChrome();
                    }
                    completeDispatch();
                }, (err) => {
                    CloudExperienceHost.Telemetry.logEvent("EnterpriseNgcEnrollment_ShowViewError", err);
                    errorDispatch({ number: err.number });
                });
            });
        }

    })(CloudExperienceHost.EnterpriseNgcEnrollment || (CloudExperienceHost.EnterpriseNgcEnrollment = {}));
})(CloudExperienceHost || (CloudExperienceHost = {}));
