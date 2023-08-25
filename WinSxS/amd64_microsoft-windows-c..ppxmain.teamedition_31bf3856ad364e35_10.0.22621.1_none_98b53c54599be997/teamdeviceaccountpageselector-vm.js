//
// Copyright (C) Microsoft. All rights reserved.
//
require.config(new RequirePathConfig('/webapps/inclusiveOobe'));
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'legacy/appObjectFactory'], (ko, bridge, constants, core, appObjectFactory) => {
    class TeamDeviceAccountPageSelectorViewModel {
        constructor(resourceStrings) {
            this.resourceStrings = resourceStrings;

            this.progressText = this.resourceStrings["ProgressText"];
            Team.DeviceAdmin.DeviceAdminAccount.isDeviceAccountListAvailableAsync().then(
                (isAccountListAvailable) => {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "isDeviceAccountListAvailableAsync_SUCCEEDED", isAccountListAvailable);
                    if (isAccountListAvailable) {
                        bridge.fireEvent(constants.Events.done, constants.AppResult.action1);
                    }
                    else {
                        bridge.fireEvent(constants.Events.done, constants.AppResult.success);
                    }
                },
                (error) => {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "isDeviceAccountListAvailableAsync_FAILED", core.GetJsonFromError(error));
                    bridge.fireEvent(constants.Events.done, constants.AppResult.failId);
                }
            );
        }

        startVoiceOver() {
            // Speak out the string for the progress text
            this.speakStrings(this.resourceStrings["ProgressTextVoiceOver"]);
        }

        speakStrings(voiceOverString) {
            appObjectFactory.getObjectFromString("CloudExperienceHostAPI.Speech.SpeechSynthesis").speakAsync(voiceOverString).done(() => {
                // Voice over completed successfully
            }, (error) => {
                // Check that the error object is defined
                if (error) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamDeviceAccountPageSelectorVoiceOverError", core.GetJsonFromError(error));
                }
            });
        }
    }
    return TeamDeviceAccountPageSelectorViewModel;
});
