//
// Copyright (C) Microsoft. All rights reserved.
//
require.config(new RequirePathConfig('/webapps/inclusiveOobe'));
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'legacy/appObjectFactory'], (ko, bridge, constants, core, appObjectFactory) => {
    class TeamFriendlyNameViewModel {
        constructor(resourceStrings) {
            this.resourceStrings = resourceStrings;

            this.title = this.resourceStrings["FriendlyNameTitle"];

            this.friendlyNameInfo = this.resourceStrings["FriendlyName_DeviceName_Info"];

            this.friendlyNameLabel = this.resourceStrings["FriendlyName_DeviceName"];
            this.friendlyNamePlaceHolder = this.resourceStrings["FriendlyName_DeviceName_Hint"];
            this.friendlyName = ko.observable("");
            this.friendlyNameErrorText = ko.observable("");

            this.computerNameInfo = ko.observable(this.resourceStrings["FriendlyName_ComputerName_Info_Alias"]);
            this.computerNameLabel = this.resourceStrings["FriendlyName_ComputerName"];
            this.computerNamePlaceHolder = this.resourceStrings["FriendlyName_ComputerName_Hint"];
            this.computerName = ko.observable("");
            this.computerNameErrorText = ko.observable("");
            this.disableComputerName = ko.observable(false);

            this.setNameErrorText = ko.observable("");
            this.processingFlag = ko.observable(false);

            Team.DeviceAdmin.DeviceAdminAccount.isDeviceDomainJoinedAsync().then((isDomainJoined) => {
                this.disableComputerName(isDomainJoined);
                if (isDomainJoined) {
                    this.computerNameInfo(this.resourceStrings["FriendlyName_ComputerName_Info_Dj"]);
                }
            });

            Team.DeviceAdmin.DeviceAdminAccount.getFriendlyNameAsync().then((friendlyName) => {
                this.friendlyName(friendlyName);
            });

            Team.DeviceAdmin.DeviceAdminAccount.getDeviceNameAsync().then((computerName) => {
                this.computerName(computerName);
            });

            this.flexStartHyperLinks = [
                {
                    handler: (() => {}),
                    hyperlinkText: this.resourceStrings["LearnMoreText"]
                }
            ];
            this.flexStartButtons = [
                {
                    buttonText: this.resourceStrings["BackButton"],
                    buttonType: "button",
                    isPrimaryButton: true,
                    disableControl: ko.pureComputed(() => {
                        return this.processingFlag();
                    }),
                    buttonClickHandler: (() => {
                    })
                }
            ];

            this.flexEndButtons = [
                {
                    buttonText: this.resourceStrings["NextButton"],
                    buttonType: "button",
                    isPrimaryButton: true,
                    disableControl: ko.pureComputed(() => {
                        return this.processingFlag();
                    }),
                    buttonClickHandler: (() => {
                        this.validateAndSetupNames();
                    })
                }
            ];
        }

        getErrorMessage(hrCode) {
            let hr = parseInt(hrCode);

            switch (hr) {
                default:
                    this.setNameErrorText(this.resourceStrings["Unknown_Error"]);
                    break;
            }
        }
        validateFriendlyName() {
            let name = this.friendlyName().trim();
            this.friendlyName(name);
            if (name.length === 0) {
                this.friendlyNameErrorText(this.resourceStrings["FriendlyName_DeviceName_Blank"]);
                return false;
            }
            else if (name.length < 3) {
                this.friendlyNameErrorText(this.resourceStrings["FriendlyName_DeviceName_Short"]);
                return false;
            }
            return true;
        }

        validateDeviceName() {
            let regex = /[\s()\\\/:*?"<>|]/;
            let name = this.computerName().trim();

            this.computerName(name);
            if (name.length === 0) {
                this.computerNameErrorText(this.resourceStrings["FriendlyName_ComputerName_Blank"]);
                return false;
            }
            else if (name.length > 15) {
                this.computerNameErrorText(this.resourceStrings["FriendlyName_ComputerName_Length_Error"]);
                return false;
            }

            let isNotValid = regex.exec(name);
            if (isNotValid) {
                this.computerNameErrorText(this.resourceStrings["FriendlyName_ComputerName_Format_Error"]);
                return false;
            }
            return true;
        }

        validateAndSetupNames() {
            this.friendlyNameErrorText("");
            this.computerNameErrorText("");
            this.setNameErrorText("");
            let isFriendlyNameValid = this.validateFriendlyName();
            let isDeviceNameValid = this.validateDeviceName();

            let shouldSkip = !(isFriendlyNameValid && isDeviceNameValid);
            if (shouldSkip) {
                return;
            }
            this.processingFlag(true);
            try {
                Team.DeviceAdmin.DeviceAdminAccount.setFriendlyAndComputerNameAsync(this.friendlyName(), this.computerName()).done(
                    () => {
                        this.processingFlag(false);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setFriendlyAndComputerNameAsync_SUCCEEDED");
                        bridge.invoke("CloudExperienceHost.setRebootForOOBE");
                        bridge.fireEvent(constants.Events.done, constants.AppResult.success);
                    },
                    (error) => {
                        this.processingFlag(false);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setFriendlyAndComputerNameAsync_FAILED", core.GetJsonFromError(error));
                        this.getErrorMessage(error.number);
                    }
                );
            }
            catch (error) {
                this.processingFlag(false);
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setupFriendlyAndComputerNamesAsync_THREW", core.GetJsonFromError(error));
                this.getErrorMessage(error.number);
            }
        }

        startVoiceOver() {
            // Speak out the string for the Title
            this.speakStrings(this.resourceStrings["FriendlyNameVoiceOver"]);
        }

        speakStrings(voiceOverString) {
            appObjectFactory.getObjectFromString("CloudExperienceHostAPI.Speech.SpeechSynthesis").speakAsync(voiceOverString).done(() => {
                // Voice over completed successfully
            }, (error) => {
                // Check that the error object is defined
                if (error) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamFriendlyNameVoiceOverError", core.GetJsonFromError(error));
                }
            });
        }
    }

    return TeamFriendlyNameViewModel;
});
