//
// Copyright (C) Microsoft. All rights reserved.
//
require.config(new RequirePathConfig('/webapps/inclusiveOobe'));
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'legacy/appObjectFactory'], (ko, bridge, constants, core, appObjectFactory) => {
    class TeamAdminDismbiguationViewModel {
        constructor(resourceStrings) {
            this.resourceStrings = resourceStrings;

            this.title = this.resourceStrings["Title"];
            this.subtitle = this.resourceStrings["AdminDisambiguationSubtitle"];
            this.processingFlag = ko.observable(false);
            this.nextCxid = ko.observable("");
            this.flexEndButtons = [
                {
                    buttonText: this.resourceStrings["NextButton"],
                    buttonType: "button",
                    isPrimaryButton: true,
                    disableControl: ko.pureComputed(() => {
                        return (this.processingFlag() || (!this.nextCxid()));
                    }),
                    buttonClickHandler: (() => {
                        if (this.nextCxid()) {
                            bridge.fireEvent(constants.Events.done, this.nextCxid());
                        }
                    })
                }
            ];
            this.flexStartHyperLinks = [
                {
                    handler: (() => { }),
                    hyperlinkText: this.resourceStrings["LearnMoreText"]
                }
            ];
            this.adminButtons = [
                {
                    buttonText: this.resourceStrings["ADText"],
                    radioButtonType: "radio",
                    id: "ADText",
                    adminButtonsGroupName:"adminButtonsGroup",
                    isPrimaryButton: false,
                    disableControl: false,
                    isVisible: true,
                    autofocus: false,
                    isSelected: ko.pureComputed(() => {
                        return (this.nextCxid() === "TeamDomainJoin");
                    }),
                    buttonClickHandler: (() => {
                        this.speakStrings(this.resourceStrings["ADTextVoiceOver"]);
                        this.nextCxid("TeamDomainJoin");
                    })
                },
                {
                    buttonText: this.resourceStrings["AADText"],
                    radioButtonType: "radio",
                    id: "AADText",
                    adminButtonsGroupName: "adminButtonsGroup",
                    isPrimaryButton: false,
                    autofocus: false,
                    disableControl: false,
                    isVisible: true,
                    isSelected: ko.pureComputed(() => {
                        return (this.nextCxid() === "OobeAAD");
                    }),
                    buttonClickHandler: (() => {
                        this.speakStrings(this.resourceStrings["AADTextVoiceOver"]);
                        this.nextCxid("OobeAAD");
                    })
                },
                {
                    buttonText: this.resourceStrings["LocalText"],
                    radioButtonType: "radio",
                    id: "LocalText",
                    adminButtonsGroupName: "adminButtonsGroup",
                    isPrimaryButton: false,
                    isSelected: ko.pureComputed(() => {
                        return (this.nextCxid() === "OobeLocal");
                    }),
                    disableControl: false,
                    isVisible: true,
                    autofocus: false,
                    buttonClickHandler: (() => {
                        this.speakStrings(this.resourceStrings["LocalTextVoiceOver"]);
                        this.nextCxid("OobeLocal");
                    })
                }
            ];
        }

        startVoiceOver() {
            // Speak out the string for the Title
            this.speakStrings(this.resourceStrings["MainVoiceOver"]);
        }

        speakStrings(voiceOverString) {
            appObjectFactory.getObjectFromString("CloudExperienceHostAPI.Speech.SpeechSynthesis").speakAsync(voiceOverString).done(() => {
                // Voice over completed successfully
            }, (error) => {
                // Check that the error object is defined
                if (error) {
                    bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "TeamAdminDisambiguationVoiceOverError", core.GetJsonFromError(error));
                }
            });
        }
    }
    return TeamAdminDismbiguationViewModel;
});
