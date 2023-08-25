//
// Copyright (C) Microsoft. All rights reserved.
//
require.config(new RequirePathConfig('/webapps/inclusiveOobe'));
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'legacy/appObjectFactory', 'legacy/uiHelpers'], (ko, bridge, constants, core, appObjectFactory, uiHelpers) => {
    class TeamDomainJoinViewModel {
        constructor(resourceStrings) {
            this.resourceStrings = resourceStrings;

            this.domainJoinTitle = this.resourceStrings["DomainJoinTitle"];
            this.domainJoinSubtitle = this.resourceStrings["DomainJoinSubtitle"].replace("%1", this.resourceStrings["JoinDomain"]);

            this.domainNameLabel = this.resourceStrings["DomainLabel"];
            this.domainNamePlaceHolder = this.resourceStrings["DomainPlaceHolder"];
            this.domainName = ko.observable("");
            this.domainNameErrorText = ko.observable("");

            this.userNameLabel = this.resourceStrings["UserNameLabel"];
            this.userNamePlaceHolder = this.resourceStrings["UserNamePlaceHolder"];
            this.userName = ko.observable("");
            this.userNameErrorText = ko.observable("");

            this.passwordLabel = this.resourceStrings["PasswordLabel"];
            this.passwordPlaceHolder = this.resourceStrings["PasswordPlaceHolder"];
            this.password = ko.observable("");
            this.passwordErrorText = ko.observable("");

            this.joinErrorText = ko.observable("");

            this.processingFlag = ko.observable(false);

            this.flexStartHyperLinks = [
                {
                    handler: (() => { }),
                    hyperlinkText: this.resourceStrings["LearnMoreText"]
                }
            ];

            this.flexEndButtons = [
                {
                    buttonText: this.resourceStrings["JoinDomain"],
                    buttonType: "button",
                    isPrimaryButton: true,
                    disableControl: ko.pureComputed(() => {
                        return this.processingFlag();
                    }),
                    buttonClickHandler: (() => {
                        this.validateAndJoinDomain();
                    })
                }
            ];
        }

        getErrorMessage(hrCode) {
            let hr = parseInt(hrCode);
            bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "getErrorCode: " + hr);

            switch (hr) {
                case 0:
                    this.joinErrorText("");
                    break;
                case -2147023570:
                case -2147023584:
                case -2147023573:
                    this.joinErrorText(this.resourceStrings["UsernamePassword_Error"]);
                    break;
                case -2147023541:
                    this.joinErrorText(this.resourceStrings["NoSuchDomain"]);
                    break;
                case 0x80000A83:
                case 0x80000032:
                    this.joinErrorText(this.resourceStrings["AlreadyJoined"]);
                    break;
                case 0x80000005:
                    this.joinErrorText(this.resourceStrings["NameUsed_Error"]);
                    break;
                default:
                    this.joinErrorText(this.resourceStrings["Unknown_Error"]);
                    break;
            }
            bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "joinErrorText: " + this.joinErrorText());
        }

        validateAndJoinDomain() {
            this.domainNameErrorText("");
            this.userNameErrorText("");
            this.passwordErrorText("");
            this.joinErrorText("");
            let skipDomainJoin = false;
            if (!this.domainName()) {
                skipDomainJoin = true;
                this.domainNameErrorText(this.resourceStrings["DomainBlank_Error"]);
            }

            if (!this.userName()) {
                skipDomainJoin = true;
                this.userNameErrorText(this.resourceStrings["UserName_Error"]);
            }

            if (!this.password()) {
                skipDomainJoin = true;
                this.passwordErrorText(this.resourceStrings["PasswordEmpty_Error"])
            }

            if (skipDomainJoin) {
                return;
            }

            let localUserName = this.userName();
            let index = localUserName.indexOf("@");
            if (index === -1) {
                index = localUserName.indexOf("\\");
                if (index === -1) {
                    localUserName = this.domainName() + "\\" + this.userName();
                }
            }
            try {
                this.processingFlag(true);
                // Show the progress ring while committing async.
                bridge.fireEvent(CloudExperienceHost.Events.showProgressWhenPageIsBusy);
                Team.DeviceAdmin.DeviceAdminAccount.joinDomainAsync(this.domainName(), localUserName, this.password()).done(
                    () => {
                        this.processingFlag(false);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "joinDomainAsync_SUCCEEDED");
                        bridge.invoke("CloudExperienceHost.setRebootForOOBE");
                        bridge.fireEvent(constants.Events.done, constants.AppResult.success);
                    },
                    (error) => {
                        this.processingFlag(false);
                        bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "joinDomainAsync_FAILED", core.GetJsonFromError(error));
                        this.getErrorMessage(error.number);
                        bridge.invoke("CloudExperienceHost.setDisableBackNavigation", false);
                        bridge.fireEvent(constants.Events.visible, true);
                    }
                );
            }
            catch (error) {
                this.processingFlag(false);
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "joinDomainAsync_THREW", core.GetJsonFromError(error));
                this.getErrorMessage(error.number);
                bridge.invoke("CloudExperienceHost.setDisableBackNavigation", false);
                bridge.fireEvent(constants.Events.visible, true);
            }
        }

        startVoiceOver() {
            // Speak out the string for the Title
            this.speakStrings(this.resourceStrings["DomainVoiceOver"]);
        }

        speakStrings(voiceOverString) {
            appObjectFactory.getObjectFromString("CloudExperienceHostAPI.Speech.SpeechSynthesis").speakAsync(voiceOverString).done(() => {
                // Voice over completed successfully
            }, (error) => {
                // Check that the error object is defined
                if (error) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamDomainJoinVoiceOverError", core.GetJsonFromError(error));
                }
            });
        }
    }

    return TeamDomainJoinViewModel;
});
