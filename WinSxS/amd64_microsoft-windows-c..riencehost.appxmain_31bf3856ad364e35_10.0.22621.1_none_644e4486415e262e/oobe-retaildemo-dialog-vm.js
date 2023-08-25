//
// Copyright (C) Microsoft. All rights reserved.
//
define(["lib/knockout", "legacy/bridge", "jsCommon/oobe-gesture-manager", "legacy/core", "winjs/ui"], (ko, bridge, gestureManager, core) => {
    class RetailDemoConfirmDlgViewModel {
        constructor(params, element) {
            this.dlgContent = ko.observable("");
            this.confirmed = false;
            this.dlgCtrl = null;

            this.loadPromise = bridge.invoke("CloudExperienceHost.StringResources.makeResourceObject", "oobeRetailDemoEntry").then((result) => {
                this.resourceStrings = JSON.parse(result);
                return WinJS.UI.processAll(element).done(() => {
                    this.dlgCtrl = element.querySelector(".win-contentdialog").winControl;
                });
            }, (err) => {
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "getOobeRetailDemoEntryStringResourcesFailure", core.GetJsonFromError(err));
            });
        }

        onAfterhide(eventInfo) {
            if (eventInfo.detail.result == WinJS.UI.ContentDialog.DismissalResult.primary) {
                if (!this.confirmed) {
                    this.confirmed = true;
                    // show confirmed dlg
                    this.showDlg(this.confirmed);
                }
                else {
                    // Save the value;
                    bridge.invoke("CloudExperienceHost.Storage.SharableData.getValue", "retailDemoEnabled").done((result) => {
                        if (!result) {
                            bridge.invoke("CloudExperienceHost.Storage.SharableData.addValue", "retailDemoEnabled", true).done(() => {
                                bridge.invoke("CloudExperienceHost.Telemetry.oobeHealthEvent", CloudExperienceHostAPI.HealthEvent.retailDemoFlowStartedCensusResult, 0);
                                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "RetailDemoEnabled");
                                gestureManager.disableRetailDemoEntryPoint();
                            }, (err) => {
                                bridge.invoke("CloudExperienceHost.Telemetry.oobeHealthEvent", CloudExperienceHostAPI.HealthEvent.retailDemoFlowStartedCensusResult, err.number ? err.number : 0x8000ffff);
                                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "AddSharableDataRetailDemoEnabledFailure", core.GetJsonFromError(err));
                            });
                        }
                    }, (err) => {
                        bridge.invoke("CloudExperienceHost.Telemetry.oobeHealthEvent", CloudExperienceHostAPI.HealthEvent.retailDemoFlowStartedCensusResult, err.number ? err.number : 0x8000ffff);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "GetSharableDataRetailDemoEnabledFailure", core.GetJsonFromError(err));
                    });
                    this.dlgCtrl.removeEventListener("afterhide", this.onAfterhide);
                }
            }
            else {
                this.dlgCtrl.removeEventListener("afterhide", this.onAfterhide);
            }
        }

        dispose() {
            this.dlgCtrl.removeEventListener("afterhide", this.onAfterhide);
        }

        showDlg(confirmed) {
            this.loadPromise.then(() => {
                if (!confirmed) {
                    this.dlgContent(this.resourceStrings.confirmContent);

                    this.dlgCtrl.title = this.resourceStrings.confirmTitle;
                    this.dlgCtrl.primaryCommandText = this.resourceStrings.confirmPrimaryCommandText;
                    this.dlgCtrl.secondaryCommandText = this.resourceStrings.confirmSecondayCommandText;
                    this.dlgCtrl.addEventListener("afterhide", this.onAfterhide.bind(this));
                }
                else {
                    this.dlgContent(this.resourceStrings.confirmedContent);

                    this.dlgCtrl.title = this.resourceStrings.confirmedTitle;
                    this.dlgCtrl.primaryCommandText = this.resourceStrings.confirmedPrimaryCommandText;
                    this.dlgCtrl.secondaryCommandText = "";
                    this.dlgCtrl.secondaryCommandDisabled = true;
                }
                this.dlgCtrl.show();
            });
        }
    }
    return RetailDemoConfirmDlgViewModel;
});