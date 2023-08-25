//
// Copyright (C) Microsoft. All rights reserved.
//
/// <disable>JS2085.EnableStrictMode</disable>
/// <reference path="error.ts" />
"use strict";
var CloudExperienceHost;
(function (CloudExperienceHost) {
    class NavMesh {
        constructor(mesh, uriArguments) {
            this._mesh = mesh;
            this._uriArguments = uriArguments;
        }
        getStart() {
            return this.getNode(this._mesh.start);
        }
        getNode(cxid) {
            var node = this._mesh[cxid];
            return node;
        }
        addOrUpdateNode(node) {
            this._mesh[node.cxid] = node;
        }
        getErrorNode() {
            return this.getNode(this._mesh.error);
        }
        getErrorNodeName() {
            return this._mesh.error;
        }
        getDiagnosticsNode() {
            return this.getNode(this.getDiagnosticsNodeName());
        }
        getDiagnosticsNodeName() {
            // The first time this function is called, it will check if navigation should be to the ROOBE page
            if (typeof (this._mesh.diagnostics) !== "string") {
                this._mesh.diagnostics = this.evaluateOverridableValue(this._mesh.diagnostics);
            }
            return this._mesh.diagnostics;
        }
        getNotifyOnFirstVisible() {
            return this._mesh.notifyOnFirstVisible;
        }
        getNotifyOnLastFinished() {
            // getNotifyOnLastFinished could be called when closing CXH before the mesh object is created
            return (this._mesh != null) && this._mesh.notifyOnLastFinished;
        }
        getMsaTicketContext() {
            return this._mesh.msaTicketContext;
        }
        getMsaTicketBroker() {
            return this._mesh.msaTicketBroker;
        }
        getUriArguments() {
            return this._uriArguments;
        }
        getFrameName() {
            if (this._mesh.frameName == null) {
                return "default-frame";
            }
            if (typeof (this._mesh.frameName) !== "string") {
                this._mesh.frameName = this.evaluateOverridableValue(this._mesh.frameName);
            }
            return this._mesh.frameName;
        }
        getInitializeExternalModalRects() {
            if (this._mesh.initializeExternalModalRects == null) {
                return false;
            }
            if (typeof (this._mesh.initializeExternalModalRects) !== "boolean") {
                this._mesh.initializeExternalModalRects = this.evaluateOverridableValue(this._mesh.initializeExternalModalRects);
            }
            return this._mesh.initializeExternalModalRects;
        }
        getPersonality() {
            if (this._mesh.personality == null) {
                return "CloudExperienceHost.Personality.Unspecified";
            }
            if (typeof (this._mesh.personality) !== "string") {
                this._mesh.personality = this.evaluateOverridableValue(this._mesh.personality);
            }
            return this._mesh.personality;
        }
        getInclusive() {
            return (this._mesh.speechCapable ? 1 : 0);
        }
        getSpeechDisabled() {
            if (this._mesh.speechDisabled == null) {
                return false;
            }
            if (typeof (this._mesh.speechDisabled) !== "boolean") {
                this._mesh.speechDisabled = this.evaluateOverridableValue(this._mesh.speechDisabled);
            }
            return this._mesh.speechDisabled;
        }
        shouldRunNarratorInstruction() {
            if (this._mesh.narratorInstruction == null) {
                return false;
            }
            if (typeof (this._mesh.narratorInstruction) !== "boolean") {
                this._mesh.narratorInstruction = this.evaluateOverridableValue(this._mesh.narratorInstruction);
            }
            return this._mesh.narratorInstruction;
        }
        getIntroVideoPath() {
            if (this._mesh.introVideoPath == null) {
                return "";
            }
            if (typeof (this._mesh.introVideoPath) !== "string") {
                this._mesh.introVideoPath = this.evaluateOverridableValue(this._mesh.introVideoPath);
            }
            return this._mesh.introVideoPath;
        }
        blockLateWebAppCalls() {
            return this._mesh.blockLateWebAppCalls ? true : false;
        }
        blockEarlyExit() {
            return this._mesh.blockEarlyExit ? true : false;
        }
        checkpointsEnabled() {
            return this._mesh.checkpointsEnabled ? true : false;
        }
        isBackstackForBackNavigationSupported() {
            return this._mesh.useBackstackForBackNavigation;
        }
        isCloseToExitCxhSupported() {
            return this._mesh.useCloseToExitCxh;
        }
        getReconnectHandlerCxid() {
            return this._mesh.reconnectHandlerCxid;
        }
        getRestrictNavigationToAllowList() {
            return this._mesh.restrictNavigationToAllowList ? true : false;
        }
        getScenarioCustomHeaders() {
            return this._mesh.scenarioCustomHeaders ? this._mesh.scenarioCustomHeaders : [];
        }
        evaluateOverridableValue(property) {
            return (property.overrideFunction ? (new CloudExperienceHost.InvokeAPIHelper).invokeByName(property.overrideFunction, [property.overrideFeature])
                : CloudExperienceHost.FeatureStaging.isOobeFeatureEnabled(property.overrideFeature)) ? property.overrideValue : property.value;
        }
    }
    CloudExperienceHost.NavMesh = NavMesh;
})(CloudExperienceHost || (CloudExperienceHost = {}));
//# sourceMappingURL=navmesh.js.map