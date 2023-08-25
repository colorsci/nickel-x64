//
// Copyright (C) Microsoft. All rights reserved.
//
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'corejs/knockouthelpers'], (ko, bridge, constants, core, KoHelpers) => {
    class NetworkLossAversionViewModel {
        constructor(resources) {
            this.resources = resources;
            this.title = this.resources["NetworkLossAversionTitle"];
            this.descriptionText = this.resources["descriptionText"];
            this.processingFlag = ko.observable(false);

            this.constraintTags = {
                optIn: "optIn",
                optOut: "optOut"
            };
            this.checkBoxAriaLabel = this.resources.checkBoxAriaLabel;
            this.featureOnForFullSetup = "icon-oobe icon-checkmark";
            this.flexEndButtons = [
                {
                    buttonText: this.resources["NetworkLossAversionOptOut"],
                    buttonType: "button",
                    isPrimaryButton: false,
                    buttonClickHandler: (() => {
                        this.onNo();
                    }),
                },
                {
                    buttonText: this.resources["NetworkLossAversionOptIn"],
                    buttonType: "button",
                    isPrimaryButton: true,
                    autoFocus: true,
                    buttonClickHandler: (() => {
                        this.onYes();
                    }),
                }
            ];
            
        }

        startVoiceOver() {
            try {
                let constraints = this.createSpeechRecognitionConstraints();
                CloudExperienceHostAPI.Speech.SpeechRecognition.promptForCommandsAsync(this.resources.NetworkLossAversionVoiceOver, constraints).done((result) => {
                    this.onSpeechRecognitionResult(result);
                });
            }
            catch (err) {
                bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "SpeechNetworkLossAversionPageFailure: ", core.GetJsonFromError(err));
            }
        }

        createSpeechRecognitionConstraints() {
            let constraints = new Array(CloudExperienceHostAPI.Speech.SpeechRecognitionKnownCommands.yes, CloudExperienceHostAPI.Speech.SpeechRecognitionKnownCommands.no);
            return constraints;
        }

        onSpeechRecognitionResult(result) {
            if (result && !this.processingFlag()) {
                if (result.constraint.tag === CloudExperienceHostAPI.Speech.SpeechRecognitionKnownCommands.no.tag) {
                    this.onNo();
                }
                else if (result.constraint.tag === CloudExperienceHostAPI.Speech.SpeechRecognitionKnownCommands.yes.tag) {
                    this.onYes();
                }
            }
        }

        onNo() {
            if (!this.processingFlag()) {
                this.processingFlag(true);
                bridge.invoke("CloudExperienceHost.Telemetry.logUserInteractionEvent", "GoToNetworkPage", "No");
                bridge.fireEvent(constants.Events.done, constants.AppResult.success);
            }
        }

        onYes() {
            if (!this.processingFlag()) {
                this.processingFlag(true);
                bridge.invoke("CloudExperienceHost.Telemetry.logUserInteractionEvent", "GoToNetworkPage", "Yes");
                bridge.fireEvent(constants.Events.done, constants.AppResult.action1);
            }
        }

        getFeatureContents() {
            let featureContents = [];
            // the first one is for the table header
            let numOfFeatures = 3;
            let featureClasses = [
                "icon-oobe icon-shield",
                "icon-oobe icon-onedrive",
                "icon-oobe icon-windowsLogo"
            ];
            for (let i = 0; i <= numOfFeatures; i++) {
                let totalContent;
                if (i === 0) {
                    totalContent = {
                        featureHeader: this.resources.featureHeader,
                        featureTemplateName: "nla-TableHeader-Template"
                    };
                }
                else {
                    totalContent = {
                        featureTitle: this.resources["featureTitle" + i],
                        featureDesc: this.resources["featureDesc" + i],
                        featureClass: featureClasses[i-1],
                        featureTemplateName: "nla-TableItem-Template"
                    };
                }
                featureContents.push(totalContent);
            }
            return featureContents;
        }

        getFeatureTemplateName(featureContent) {
            return featureContent.featureTemplateName;
        }
    }
    return NetworkLossAversionViewModel;
});
