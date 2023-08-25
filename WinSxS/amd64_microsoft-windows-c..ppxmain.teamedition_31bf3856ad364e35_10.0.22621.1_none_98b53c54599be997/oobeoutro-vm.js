//
// Copyright (C) Microsoft. All rights reserved.
//
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'oobewelcome-vm'], (ko, bridge, constants, core, WelcomeViewModel) => {
    class OutroViewModel {
        constructor(resourceStrings) {
            this.resourceStrings = resourceStrings;
            let speakingSequence = [
                // Less than default minTimeShown to account for the fact that we wait for the speech loop
                // to finish before actually ending the last string shown
                // i.e. If there are N strings, only use a smaller minTimeShown on Nth string
                { resourceName: "OutroVoiceOver1", minTimeShown: 4000 }
            ];

            this.outroText = ko.observable("");
            this.outroText.subscribe((newTitle) => {
                document.title = newTitle;
            });

            this.animationSequence = new WelcomeViewModel.CortanaAnimationSequence({
                resourceStrings,
                speakingSequence,
                captionText: this.outroText,
                animationCanvasElement: document.querySelector(".animationCanvas"),
                textElement: document.querySelector(".content-subheader"),
                entranceFileName: "oobe-bookend-cortanain-outro.gif",
                doneResult: constants.AppResult.exitCxhSuccess,
            });
        }

        waitForAssetLoadAsync() {
            return this.animationSequence.waitForAssetLoadAsync();
        }

        startAnimation() {
            return this.animationSequence.startAnimation();
        }

        onSpeechStarting() {
            this.animationSequence.onSpeechStarting();
        }

        onSpeechComplete() {
            this.animationSequence.onSpeechComplete();
        }

        onSpeechError(error) {
            bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "OutroVoiceOverError", core.GetJsonFromError(error));
            this.onSpeechComplete();
        }
    }

    return OutroViewModel;
});
