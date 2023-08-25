// Copyright (C) Microsoft. All rights reserved.
//
/// <disable>JS2085.EnableStrictMode</disable>
"use strict";
var CloudExperienceHost;
(function (CloudExperienceHost) {
    var Globalization;
    (function (Globalization) {
        class GeographicRegion {
            static getAll() {
                return new WinJS.Promise(function (completeDispatch, errorDispatch /*, progressDispatch */) {
                    CloudExperienceHostAPI.GeographicRegion.getAll().done(function (regions) {
                        completeDispatch(JSON.parse(regions));
                    }, errorDispatch);
                });
            }
            static getCode() {
                return new Windows.Globalization.GeographicRegion().code;
            }
        }
        Globalization.GeographicRegion = GeographicRegion;
        class Language {
            static getPreferredLang() {
                return Windows.Globalization.ApplicationLanguages.languages[0];
            }
            static getReadingDirection() {
                // Check reading direction from a Windows.Globalization DateTimeFormatting Pattern generated from the ApplicationLanguages list
                var dtf = new Windows.Globalization.DateTimeFormatting.DateTimeFormatter("month.full", Windows.Globalization.ApplicationLanguages.languages, "ZZ", "GregorianCalendar", "24HourClock");
                var pat = dtf.patterns[0];
                var isRTL = pat.charCodeAt(0) === 8207; // Right-To-Left Mark
                return isRTL ? "rtl" : "ltr";
            }
        }
        Globalization.Language = Language;
        class Utils {
            static setDocumentElementLangAndDir() {
                document.documentElement.lang = CloudExperienceHost.Globalization.Language.getPreferredLang();
                document.documentElement.dir = CloudExperienceHost.Globalization.Language.getReadingDirection();
            }
        }
        Globalization.Utils = Utils;
    })(Globalization = CloudExperienceHost.Globalization || (CloudExperienceHost.Globalization = {}));
})(CloudExperienceHost || (CloudExperienceHost = {}));
//# sourceMappingURL=globalization.js.map