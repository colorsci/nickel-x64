//
// Copyright (C) Microsoft. All rights reserved.
//
(() => {
    WinJS.UI.Pages.define("/webapps/shubOobe/view/teamdeviceaccountlist-main.html", {
        init: (element, options) => {
            require.config(new RequirePathConfig('/webapps/inclusiveOobe'));

            // Load css per scenario
            let loadCssPromise = requireAsync(['legacy/uiHelpers', 'legacy/bridge']).then((result) => {
                return result.legacy_uiHelpers.LoadCssPromise(document.head, "", result.legacy_bridge);
            });

            let langAndDirPromise = requireAsync(['legacy/uiHelpers', 'legacy/bridge']).then((result) => {
                return result.legacy_uiHelpers.LangAndDirPromise(document.documentElement, result.legacy_bridge);
            });

            let getLocalizedStringsPromise = requireAsync(['legacy/bridge']).then((result) => {
                return result.legacy_bridge.invoke("CloudExperienceHost.StringResources.makeResourceObject", "teamAdminDisambiguation");
            }).then((result) => {
                this.resourceStrings = JSON.parse(result);
                });
            let getDeviceAccountList = requireAsync(['legacy/bridge']).then((result) => {
                return Team.DeviceAdmin.DeviceAdminAccount.getDeviceAccountListAsync().then(
                    (deviceAccountList) => {
                        result.legacy_bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setDeviceAccountAsync_SUCCEEDED");
                        try {
                            this.deviceAccountList = JSON.parse(deviceAccountList);
                        }
                        catch (e) {
                            result.legacy_bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setDeviceAccountAsync_PARSEFAILED");
                            this.deviceAccountList = [];
                        }
                    },
                    (error) => {
                        result.legacy_bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "getDeviceAccountListAsync_FAILED", core.GetJsonFromError(error));
                        this.deviceAccountList = [];
                    })
            });
            return WinJS.Promise.join({ loadCssPromise: loadCssPromise, langAndDirPromise: langAndDirPromise, getLocalizedStringsPromise: getLocalizedStringsPromise, getDeviceAccountList: getDeviceAccountList });
        },
        error: (e) => {
            bridge.fireEvent(constants.Events.done, constants.AppResult.error);
        },
        ready: (element, options) => {
            require.config(new RequirePathConfig('/webapps/shubOobe'));
            require(['lib/knockout', 'corejs/knockouthelpers', 'legacy/bridge', 'legacy/events', 'teamdeviceaccountlist-vm', 'lib/knockout-winjs'], (ko, KoHelpers, bridge, constants, TeamDeviceAccountListViewModel) => {
                // Setup knockout customizations
                koHelpers = new KoHelpers();
                koHelpers.registerComponents(CloudExperienceHost.RegisterComponentsScenarioMode.InclusiveOobe);
                window.KoHelpers = KoHelpers;

                // Apply bindings and show the page
                let vm = new TeamDeviceAccountListViewModel(this.resourceStrings, this.deviceAccountList);
                ko.applyBindings(vm);
                KoHelpers.waitForInitialComponentLoadAsync().then(() => {
                    WinJS.Utilities.addClass(document.body, "pageLoaded");
                    bridge.fireEvent(constants.Events.visible, true);
                    KoHelpers.setFocusOnAutofocusElement();
                    vm.startVoiceOver();
                });
            });
        }
    });
})();
