//
// Copyright (C) Microsoft. All rights reserved.
//
require.config(new RequirePathConfig('/webapps/inclusiveOobe'));
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'legacy/appObjectFactory'], (ko, bridge, constants, core, appObjectFactory) => {
    class TeamDeviceAccountListViewModel {
        constructor(resourceStrings, deviceAccountListData) {
            this.resourceStrings = resourceStrings;

            this.title = this.resourceStrings["AccountCSV_Title"];
            this.subtitle = this.resourceStrings["AccountCsv_Info"];
            this.friendlyNameLabel = this.resourceStrings["AccountCsv_FriendlyNameLabel"];
            this.deviceAccountLabel = this.resourceStrings["AccountCsv_AccountNameLabel"];
            this.listAccessibleName = this.resourceStrings["AccountCsv_AccountSelection"];
            this.processingFlag = ko.observable(false);

            this.deviceAccountList = deviceAccountListData;
            this.selectedAccount = ko.observable();

            this.selectedAccount((ko.utils.arrayFirst(this.deviceAccountList, (deviceAccount) => {
                return true;
            })));

            this.deviceAccountErrorText = ko.observable("");

            this.flexEndButtons = [
                {
                    buttonText: this.resourceStrings["NextButton"],
                    buttonType: "button",
                    isPrimaryButton: true,
                    disableControl: ko.pureComputed(() => {
                        return this.processingFlag();
                    }),
                    buttonClickHandler: (() => {
                        this.setupDeviceAcount();
                    })
                }
            ];
            this.flexStartHyperLinks = [
                {
                    handler: () => {
                        this.onLinkClick();
                    },
                    hyperlinkText: resourceStrings["AccountCsv_Manual_Link"]
                }
            ];

        }

        getErrorMessage(hrCode) {
            let hr = parseInt(hrCode);

            switch (hr) {
                case 0:
                    this.deviceAccountErrorText("");
                    break;
                case -2130771961:
                    this.deviceAccountErrorText(this.resourceStrings["AccountCsv_Logon_Failure_Error"]);
                    break;
                default:
                    this.deviceAccountErrorText(this.resourceStrings["Unknown_Error"]);
                    break;
            }
        }

        setupDeviceAcount() {
            this.deviceAccountErrorText("");
            this.processingFlag(true);
            Team.DeviceAdmin.DeviceAdminAccount.setDeviceAccountAsync(this.selectedAccount().deviceAccount).done(
                () => {
                    this.processingFlag(false);
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setDeviceAccountAsync_SUCCEEDED");
                    bridge.fireEvent(constants.Events.done, constants.AppResult.success);
                },
                (error) => {
                    this.processingFlag(false);
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "setDeviceAccountAsync_FAILED", core.GetJsonFromError(error));
                    this.getErrorMessage(error.number);
                }
            );
        }

        onLinkClick() {
            if (!this.processingFlag()) {
                this.processingFlag(true);
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamDeviceAccountList", "Manual flow invoked");
                bridge.fireEvent(constants.Events.done, constants.AppResult.cancel);
            }
        }

        startVoiceOver() {
            // Speak out the string for the Title
            this.speakStrings(this.resourceStrings["AccountCsv_Info_VoiceOver"]);
        }

        speakStrings(voiceOverString) {
            appObjectFactory.getObjectFromString("CloudExperienceHostAPI.Speech.SpeechSynthesis").speakAsync(voiceOverString).done(() => {
                // Voice over completed successfully
            }, (error) => {
                // Check that the error object is defined
                if (error) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamDeviceAccountListVoiceOverError", core.GetJsonFromError(error));
                }
            });
        }
    }
    return TeamDeviceAccountListViewModel;
});
