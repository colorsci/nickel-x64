﻿//
// Copyright (C) Microsoft. All rights reserved.
//
(() => {
    WinJS.UI.Pages.define("/webapps/inclusiveOobe/view/networkDropoffHandler-main.html", {
        init: (element, options) => {
            require.config(new RequirePathConfig('/webapps/inclusiveOobe'));

            // Load css per scenario
            let loadCssPromise = requireAsync(['legacy/uiHelpers', 'legacy/bridge']).then((result) => {
                return result.legacy_uiHelpers.LoadCssPromise(document.head, "", result.legacy_bridge);
            });

            let langAndDirPromise = requireAsync(['legacy/uiHelpers', 'legacy/bridge']).then((result) => {
                return result.legacy_uiHelpers.LangAndDirPromise(document.documentElement, result.legacy_bridge);
            });

            // Load resource strings
            let getLocalizedStringsPromise = requireAsync(['legacy/bridge']).then((result) => {
                return result.legacy_bridge.invoke("CloudExperienceHost.StringResources.makeResourceObject", "networkDropoffHandler");
            }).then((result) => {
                this.resourceStrings = JSON.parse(result);
            });

            return WinJS.Promise.join({ loadCssPromise: loadCssPromise, langAndDirPromise: langAndDirPromise, getLocalizedStringsPromise: getLocalizedStringsPromise });
        },
        error: (e) => {
            require(['legacy/bridge', 'legacy/events', 'legacy/core'], (bridge, constants, core) => {
                if (e) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "NetworkDropoffHandlerPageError", core.GetJsonFromError(e));
                } else {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "NetworkDropoffHandlerPageError");
                }
                bridge.fireEvent(constants.Events.done, constants.AppResult.error);
            });
        },
        ready: (element, options) => {
            require(['lib/knockout', 'corejs/knockouthelpers', 'legacy/bridge', 'legacy/events', 'legacy/core', 'networkDropoffHandler-vm', 'lib/knockout-winjs'], (ko, KoHelpers, bridge, constants, core, NetworkDropoffHandlerViewModel) => {
                // Setup knockout customizations
                koHelpers = new KoHelpers();
                koHelpers.registerComponents(CloudExperienceHost.RegisterComponentsScenarioMode.InclusiveOobe);
                window.KoHelpers = KoHelpers;

                // Apply bindings and show the page
                try {
                    if (!this.resourceStrings) {
                        throw { "error": "ResourceStringsNull" };
                    }
                    let vm = new NetworkDropoffHandlerViewModel.NetworkDropoffHandlerViewModel(this.resourceStrings);
                    if (!vm) {
                        throw { "error": "ViewModelConstructorFailed" };
                    }
                    ko.applyBindings(vm);
                }
                catch (err) {
                    if (err) {
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "NetworkDropoffHandlerViewModelError", core.GetJsonFromError(err));
                    } else {
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "NetworkDropoffHandlerViewModelError");
                    }
                    host.exit(Host.AppResult.Error);
                    return;
                }
                KoHelpers.waitForInitialComponentLoadAsync().then(() => {
                    WinJS.Utilities.addClass(document.body, "pageLoaded");
                    bridge.fireEvent(constants.Events.visible, true);
                    KoHelpers.setFocusOnAutofocusElement();
                });
            });
        }
    });
})();
