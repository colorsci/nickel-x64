//
// Copyright (C) Microsoft. All rights reserved.
//
require.config(new RequirePathConfig('/webapps/inclusiveOobe'));
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'legacy/appObjectFactory'], (ko, bridge, constants, core, appObjectFactory) => {
    class TeamGroupAdminAccountViewModel {
        constructor(resourceStrings) {
            this.resourceStrings = resourceStrings;

            this.title = this.resourceStrings["GroupNameTitle"];
            this.subtitle = this.resourceStrings["GroupNameSubtitle"];

            this.groupNameLabel = this.resourceStrings["GroupNameLabel"];
            this.groupNamePlaceHolder = this.resourceStrings["GroupNamePlaceHolder"];
            this.groupName = ko.observable("");
            this.groupNameErrorText = ko.observable("");

            this.confirmGroupNameLabel = this.resourceStrings["ConfirmGroupNameLabel"];
            this.confirmGroupNamePlaceHolder = this.resourceStrings["ConfirmGroupNamePlaceHolder"];
            this.confirmGroupName = ko.observable("");
            this.confirmGroupNameErrorText = ko.observable("");

            this.configureAdminErrorText = ko.observable("");

            this.processingFlag = ko.observable(false);
            this.flexStartHyperLinks = [
                {
                    handler: (() => { }),
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
                        this.validateAndSetupGroupAdmin();
                    })
                }
            ];
        }

        getErrorMessage(hrCode) {
            let hr = parseInt(hrCode);

            switch (hr) {
                case 0:
                    this.configureAdminErrorText("");
                    break;
                case -2147023564:
                    this.configureAdminErrorText(this.resourceStrings["GroupName_NotFound_Error"]);
                    break;
                default:
                    this.configureAdminErrorText(this.resourceStrings["Unknown_Error"]);
                    break;
            }
            bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "configureAdminErrorText: " + this.configureAdminErrorText());
        }

        validateAndSetupGroupAdmin() {
            this.groupNameErrorText("");
            this.confirmGroupNameErrorText("");
            this.configureAdminErrorText("");
            let groupNameTrimmed = this.groupName().trim();
            this.groupName(groupNameTrimmed);

            let confirmGroupNameTrimmed = this.confirmGroupName().trim();
            this.confirmGroupName(confirmGroupNameTrimmed);

            if (!this.groupName()) {
                this.groupNameErrorText(this.resourceStrings["GroupName_Error"]);
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "groupNameErrorText: " + this.groupName());
                return;
            }

            if (!this.confirmGroupName()) {
                this.confirmGroupNameErrorText(this.resourceStrings["GroupName_Error"]);
                return;
            }

            if (groupNameTrimmed !== confirmGroupNameTrimmed) {
                this.configureAdminErrorText(this.resourceStrings["GroupConfirm_Error"]);
                return;
            }

            this.processingFlag(true);
            // Show the progress ring while committing async.
            bridge.fireEvent(CloudExperienceHost.Events.showProgressWhenPageIsBusy);
            try {
                Team.DeviceAdmin.DeviceAdminAccount.setupGroupAdminAsync(this.groupName()).done(
                    () => {
                        this.processingFlag(false);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setupGroupAdminAsync_SUCCEEDED");
                        bridge.fireEvent(constants.Events.done, constants.AppResult.success);
                    },
                    (error) => {
                        this.processingFlag(false);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setupGroupAdminAsync_FAILED", core.GetJsonFromError(error));
                        this.getErrorMessage(error.number);
                        bridge.invoke("CloudExperienceHost.setDisableBackNavigation", false);
                        bridge.fireEvent(constants.Events.visible, true);
                    }
                );
            }
            catch (error) {
                this.processingFlag(false);
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setupGroupAdminAsync_THREW", core.GetJsonFromError(error));
                this.getErrorMessage(error.number);
                bridge.invoke("CloudExperienceHost.setDisableBackNavigation", false);
                bridge.fireEvent(constants.Events.visible, true);
            }
        }

        startVoiceOver() {
            // Speak out the string for the Title
            this.speakStrings(this.resourceStrings["GroupNameVoiceOver"]);
        }

        speakStrings(voiceOverString) {
            appObjectFactory.getObjectFromString("CloudExperienceHostAPI.Speech.SpeechSynthesis").speakAsync(voiceOverString).done(() => {
                // Voice over completed successfully
            }, (error) => {
                // Check that the error object is defined
                if (error) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamGroupAdminAccountVoiceOverError", core.GetJsonFromError(error));
                }
            });
        }
    }

    return TeamGroupAdminAccountViewModel;
});
