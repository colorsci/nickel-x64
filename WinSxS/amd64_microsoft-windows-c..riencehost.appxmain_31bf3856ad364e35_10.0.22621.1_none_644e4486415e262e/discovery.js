//
// Copyright (C) Microsoft. All rights reserved.
//
/// <disable>JS2085.EnableStrictMode</disable>
/// <reference path="error.ts" />
"use strict";
var CloudExperienceHost;
(function (CloudExperienceHost) {
    class ExperienceDescription {
        static _parse(uri) {
            var a = document.createElement('a');
            a.href = uri;
            var winUri = new Windows.Foundation.Uri(uri);
            return {
                source: uri,
                protocol: a.protocol.replace(':', ''),
                host: a.hostname,
                port: a.port,
                query: a.search,
                paramsParsed: winUri.queryParsed,
                params: (function () {
                    var ret = {}, seg = a.search.replace(/^\?/, '').split('&'), len = seg.length, i = 0, s;
                    for (; i < len; i++) {
                        if (!seg[i]) {
                            continue;
                        }
                        s = seg[i].split('=');
                        ret[s[0].toLowerCase()] = s[1];
                    }
                    return ret;
                })(),
                file: (a.pathname.match(/\/([^\/?#]+)$/i) || [, ''])[1],
                hash: a.hash.replace('#', ''),
                path: a.pathname.replace(/^([^\/])/, '/$1'),
                segments: a.pathname.replace(/^\//, '').split('/')
            };
        }
        static _validate(experience) {
            if ((experience.port.length > 0) ||
                (experience.hash.length > 0) ||
                (experience.segments.length > 1) ||
                (experience.protocol.toUpperCase() != "MS-CXH")) {
                throw new CloudExperienceHost.InvalidExperienceError();
            }
        }
        static Create(uri) {
            var description = ExperienceDescription._parse(uri);
            ExperienceDescription._validate(description);
            return description;
        }
        static getExperience(experience) {
            var exp = null;
            if (experience) {
                exp = experience.host.toUpperCase() + experience.segments[0].toUpperCase();
            }
            return exp;
        }
        static GetHeaderParams(experience) {
            let headerParams = "";
            let headerParamsParameterName = "headerparams";
            if (experience.params.hasOwnProperty(headerParamsParameterName)) {
                headerParams = experience.params[headerParamsParameterName];
            }
            return headerParams;
        }
        static GetCorrelationId(experience) {
            var correlationId = "";
            var correlationIdParameterName = "correlationid";
            if (experience.params.hasOwnProperty(correlationIdParameterName)) {
                correlationId = experience.params[correlationIdParameterName];
            }
            return correlationId;
        }
        static GetStart(experience) {
            var start = "";
            var startParameterName = "start";
            if (experience.params.hasOwnProperty(startParameterName)) {
                start = experience.params[startParameterName];
            }
            return start;
        }
        static GetTargetedContentId(experience) {
            let contentId = "";
            let contentIdParameterName = "tccontentid";
            if (experience.params.hasOwnProperty(contentIdParameterName)) {
                contentId = experience.params[contentIdParameterName];
            }
            return contentId;
        }
        static GetTargetedContentPath(experience) {
            let contentPath = "";
            let contentPathParameterName = "tccontentpath";
            if (experience.params.hasOwnProperty(contentPathParameterName)) {
                contentPath = experience.params[contentPathParameterName];
            }
            return contentPath;
        }
        static GetShouldReportRewards(experience) {
            let shouldReportRewards = false;
            let shouldReportRewardsParameterName = "rewards";
            if (experience.params.hasOwnProperty(shouldReportRewardsParameterName)) {
                let value = experience.params[shouldReportRewardsParameterName];
                shouldReportRewards = ((value === "true") || (value === "1"));
            }
            return shouldReportRewards;
        }
        static GetLaunchSurface(experience) {
            let launchSurface = "";
            let launchSurfaceParameterName = "surface";
            if (experience.params.hasOwnProperty(launchSurfaceParameterName)) {
                launchSurface = experience.params[launchSurfaceParameterName];
            }
            return launchSurface;
        }
        static RemovePIIFromExperienceDescription(experience) {
            // Remove the query string from the source as it has the potential to contain PII
            // Also filter out the "query" and "paramsParsed" elements entirely
            // 'params' can be kept via a recursive strategy (only allow sub-params that we know don't contain PII)
            let experienceToReturn = Object.assign({}, experience);
            experienceToReturn.source = CloudExperienceHost.UriHelper.RemovePIIFromUri(experienceToReturn.source);
            let descriptionAllowlist = [
                'source',
                'protocol',
                'host',
                'port',
                // 'query', explicitly block this to avoid sending the query string
                'params',
                'ocid',
                'ccid',
                'version',
                'clr',
                'scenarioId',
                'referrerCid',
                'surface',
                'file',
                'hash',
                'path',
                'segments'
            ];
            return JSON.stringify(experienceToReturn, descriptionAllowlist);
        }
    }
    CloudExperienceHost.ExperienceDescription = ExperienceDescription;
    class ServiceEndpoint {
        constructor(address) {
            this._address = address;
        }
        getAddress() {
            return this._address;
        }
    }
    CloudExperienceHost.ServiceEndpoint = ServiceEndpoint;
    var appDataType;
    (function (appDataType) {
        appDataType[appDataType["navMesh"] = 0] = "navMesh";
        appDataType[appDataType["uriRules"] = 1] = "uriRules";
    })(appDataType || (appDataType = {}));
    class Discovery {
        static _getUrl() {
            var url = "data\\prod";
            CloudExperienceHost.Telemetry.AppTelemetry.getInstance().logEvent("Discovery_URL", url);
            return url;
        }
        static _getMeshData() {
            return Discovery._getJSONFileData(appDataType.navMesh, Discovery._getUrl());
        }
        static _getJSONFileData(dt, url) {
            return Windows.ApplicationModel.Package.current.installedLocation.getFolderAsync(url).then((folder) => {
                let queryResult = folder.createFileQuery();
                return queryResult.getFilesAsync();
            }).then(function (filesList) {
                let filePromises = filesList.map((file) => {
                    switch (dt) {
                        case appDataType.navMesh:
                            if (file.displayName.toLowerCase().includes("navigation")) {
                                return Windows.Storage.FileIO.readTextAsync(file);
                            }
                            return null;
                        case appDataType.uriRules:
                            if (file.displayName.toLowerCase().includes("urirules")) {
                                return Windows.Storage.FileIO.readTextAsync(file);
                            }
                            return null;
                        default:
                            return null;
                    }
                });
                return WinJS.Promise.join(filePromises).then((results) => {
                    let resultMesh = {};
                    for (let i = 0; i < results.length; i++) {
                        if (results[i] != null) {
                            let fileJson = JSON.parse(results[i]);
                            Object.keys(fileJson).forEach((key) => resultMesh[key] = fileJson[key]);
                        }
                    }
                    switch (dt) {
                        case appDataType.navMesh:
                            return JSON.stringify(resultMesh);
                        case appDataType.uriRules:
                            let apiRules = JSON.parse(JSON.stringify(resultMesh)).apiRules;
                            for (let rule in apiRules) {
                                if (apiRules.hasOwnProperty(rule)) {
                                    for (let i = 0; i < apiRules[rule].length; i++) {
                                        apiRules[rule][i] = apiRules[rule][i].trim();
                                    }
                                }
                            }
                            return apiRules;
                    }
                });
            });
        }
        static _getMesh(experience) {
            return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch */) {
                Discovery._getMeshData().then(function (navData) {
                    var exp = ExperienceDescription.getExperience(experience);
                    var navigationList = JSON.parse(navData);
                    var mesh = navigationList[exp];
                    if (mesh) {
                        // The nav mesh may specify an optional "urlint" property to be used in place
                        // of "url" when the target environment is INT (as opposed to PROD). In that
                        // case, we replace the contents of the "url" property with "urlint" when
                        // present. We also always delete all "urlint" properties from the mesh, to
                        // eliminate the possibility that the wrong URL will be selected later.
                        CloudExperienceHost.Telemetry.AppTelemetry.getInstance().logEvent("NavMeshPreReplace", JSON.stringify(mesh));
                        let target;
                        try {
                            target = CloudExperienceHost.Environment.getTarget();
                            CloudExperienceHost.Telemetry.AppTelemetry.getInstance().logEvent("TargetEnvironment", target);
                        }
                        catch (ex) {
                            target = CloudExperienceHost.TargetEnvironment.PROD;
                        }
                        Object.keys(mesh).forEach(function (key) {
                            if (mesh[key].url !== undefined) {
                                let urlOverride = CloudExperienceHostAPI.Environment.getRegValue(mesh[key].cxid + "Override");
                                if (urlOverride !== "") {
                                    mesh[key].url = urlOverride;
                                }
                                else if ((mesh[key].urlint !== undefined) && (target == CloudExperienceHost.TargetEnvironment.INT)) {
                                    mesh[key].url = mesh[key].urlint;
                                }
                            }
                            delete mesh[key].urlint;
                        });
                    }
                    else {
                        // If we tried to load a Scenario not defined in the parsed navigationList,
                        // it could be a scenario from a .json file that wasn't packaged on the install
                        // or an invalid param passed in from protocol activation.
                        // We don't want to blow up here so that control can return to appmanager to cleanly exit the app.
                        CloudExperienceHost.Telemetry.AppTelemetry.getInstance().logEvent("NavigationMeshNotDefinedInJson", exp);
                    }
                    completeDispatch(mesh);
                }, function (e) {
                    errorDispatch(e);
                });
            });
        }
        static getNavMesh(experience) {
            return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch */) {
                CloudExperienceHost.Telemetry.AppTelemetry.getInstance().logEvent("ExperienceDescription", CloudExperienceHost.ExperienceDescription.RemovePIIFromExperienceDescription(experience));
                Discovery._getMesh(experience).then(function (mesh) {
                    CloudExperienceHost.Telemetry.AppTelemetry.getInstance().logEvent("NavMesh", JSON.stringify(mesh));
                    completeDispatch(new CloudExperienceHost.NavMesh(mesh, experience.paramsParsed));
                }, function (e) {
                    errorDispatch(e);
                });
            });
        }
        static getApiRules() {
            return Discovery._getJSONFileData(appDataType.uriRules, Discovery._getUrl());
        }
    }
    CloudExperienceHost.Discovery = Discovery;
})(CloudExperienceHost || (CloudExperienceHost = {}));
//# sourceMappingURL=discovery.js.map