//
// Copyright (C) Microsoft. All rights reserved.
//
define(['lib/knockout', 'legacy/bridge', 'legacy/events', 'legacy/core', 'jsCommon/GifSequencePlayer'], (ko, bridge, constants, core, GifSequencePlayer) => {
    class WelcomeViewModel {
        constructor(resourceStrings, gestureManager) {
            this.resourceStrings = resourceStrings;
            this.gestureManager = gestureManager;
            this.optinHotKey = true;
            this.useVoiceOver = true;
            let speakingSequence = [
                { resourceName: "Intro1VoiceOver", minTimeShown: 2000, }, // Short string
                { resourceName: "Intro2VoiceOver" },
                { resourceName: "Intro3VoiceOver" },
                { resourceName: "Intro4VoiceOver" },
                // Less than default minTimeShown to account for the fact that we wait for the speech loop
                // to finish before actually ending the last one (and short string).
                { resourceName: "Intro5VoiceOver", minTimeShown: 1500 }
            ];

            this.welcomeText = ko.observable("");
            this.welcomeText.subscribe((newTitle) => {
                document.title = newTitle;
            });

            this.animationSequence = new CortanaAnimationSequence({
                resourceStrings,
                speakingSequence,
                captionText: this.welcomeText,
                animationCanvasElement: document.querySelector(".animationCanvas"),
                textElement: document.querySelector(".content-subheader"),
                gestureManager: this.gestureManager
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
            bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "WelcomeVoiceOverError", core.GetJsonFromError(error));
            this.onSpeechComplete();
        }

        subscribeToDeviceInsertion(gestureManager) {
            uiHelpers.PortableDeviceHelpers.subscribeToDeviceInsertion(gestureManager, bridge, core);
        }
    }

    class CortanaAnimationSequence {
        // NOTE: Also used by oobeoutro-vm.js
        constructor(options) {
            this.resourceStrings = options.resourceStrings;

            this.gestureManager = options.gestureManager;

            this.speakingSequence = options.speakingSequence;
            this.currentSpeakingIndex = 0;

            this.entranceFileName = options.entranceFileName || "oobe-bookend-cortanain.gif";
            this.speakingFileName = "oobe-bookend-cortanaspeak.gif";
            this.exitFileName = "oobe-bookend-cortanaout.gif";
            this.textElement = options.textElement;
            this.textElement.style.opacity = 0;
            this.captionText = options.captionText;
            this.doneResult = options.doneResult || constants.AppResult.success;

            this.maxSpeechWaitDelay = 3000;
            this.speechMinTimeShown = 5000;
            this.shortSpeechMinTimeShown = 2000;

            this.player = new GifSequencePlayer(options.animationCanvasElement);

            this.loadPromise = WinJS.Promise.as(null).then(() => {
                return this.loadSequencesAsync().then((sequences) => {
                    this.animationSequences = sequences;
                });
            });
        }

        loadSequencesAsync() {
            return Windows.ApplicationModel.Package.current.installedLocation.getFolderAsync("webapps\\inclusiveOobe\\media").then(imageFolder => {
                let intro1Promise = imageFolder.getFileAsync(this.entranceFileName).then(file => {
                    return GifSequencePlayer.frameSequenceFromStorageFileAsync(file);
                });
                let intro2Promise = imageFolder.getFileAsync(this.speakingFileName).then(file => {
                    return GifSequencePlayer.frameSequenceFromStorageFileAsync(file);
                });
                let intro3Promise = imageFolder.getFileAsync(this.exitFileName).then(file => {
                    return GifSequencePlayer.frameSequenceFromStorageFileAsync(file);
                });

                return WinJS.Promise.timeout(10000, WinJS.Promise.join({ introSequence: intro1Promise, speakingSequence: intro2Promise, exitSequence: intro3Promise }));
            });
        }

        waitForAssetLoadAsync() {
            return this.loadPromise;
        }

        startAnimation() {
            return this.loadPromise.then(() => {
                return this.player.playSequence(this.animationSequences.introSequence);
            }).then(() => {
                this.player.playSequence(this.animationSequences.speakingSequence, { loop: true });
                this.startSpeaking();
            });
        }

        startSpeaking() {
            let speechStartingPromise = new WinJS.Promise((completeDispatch) => {
                this.speechStartingDispatch = completeDispatch;
            });

            let speechFinishedPromise = new WinJS.Promise((completeDispatch) => {
                this.speechCompleteDispatch = completeDispatch;
            });

            let fadeOutPromise = WinJS.Promise.as(null);
            if (this.textElement.style.opacity != 0) {
                fadeOutPromise = WinJS.UI.Animation.fadeOut(this.textElement);
            }

            let speechData = this.speakingSequence[this.currentSpeakingIndex];

            fadeOutPromise.done(() => {
                this.captionText(this.resourceStrings[speechData.resourceName]);
                // Just to be safe, ensure we also continue if we only get a "finished" callback from speech
                WinJS.Promise.any([speechStartingPromise, speechFinishedPromise, WinJS.Promise.timeout(this.maxSpeechWaitDelay)]).then(() => {
                    WinJS.UI.Animation.fadeIn(this.textElement);
                });
            });

            let minTimeShown = speechData.minTimeShown || 5000;
            let isLastSequence = (this.currentSpeakingIndex + 1) == this.speakingSequence.length;
            if (isLastSequence) {
                // On the last loop, we wait for the pulsing animation sequence to finish the current loop before moving on.
                // To avoid a long delay waiting for an entire extra loop, let it start completing while Cortana is still speaking.

                // Just to be safe, ensure we also continue if we only get a "finished" callback from speech
                let lastSpeechPromise = WinJS.Promise.any([speechStartingPromise, speechFinishedPromise]).then(() => WinJS.Promise.timeout(minTimeShown));
                let animationEndPromise = lastSpeechPromise.then(() => {
                    return this.player.finishLoopAndStop().then(() => {
                        WinJS.UI.Animation.fadeOut(this.textElement);
                        return this.player.playSequence(this.animationSequences.exitSequence).then(() => WinJS.Promise.timeout(200));
                    });
                });

                // But we wait for the longer of her speaking and the animation before moving on.
                WinJS.Promise.join([speechFinishedPromise, animationEndPromise]).then(() => {
                    if (this.gestureManager) {
                        uiHelpers.PortableDeviceHelpers.unsubscribeToDeviceInsertion(this.gestureManager, bridge, core);
                    }
                    bridge.fireEvent(constants.Events.done, this.doneResult);
                });
            }
            else {
                var speakingDelayPromise = WinJS.Promise.timeout(minTimeShown);
                WinJS.Promise.join([speechFinishedPromise, speakingDelayPromise]).then((completeDispatch, error) => {
                    if (this.currentSpeakingIndex + 1 < this.speakingSequence.length) {
                        this.currentSpeakingIndex++;
                        setTimeout(() => {
                            this.startSpeaking();
                        }, 200);
                    }
                });
            }
        }

        onSpeechStarting() {
            this.speechStartingDispatch();
        }

        onSpeechComplete() {
            this.speechCompleteDispatch();
        }

        onSpeechError(error) {
            bridge.invoke("CloudExperienceHost.Telemetry.logEvent", "WelcomeVoiceOverError", core.GetJsonFromError(error));
            this.speechCompleteDispatch();
        }
    }
    return { WelcomeViewModel, CortanaAnimationSequence };
});
