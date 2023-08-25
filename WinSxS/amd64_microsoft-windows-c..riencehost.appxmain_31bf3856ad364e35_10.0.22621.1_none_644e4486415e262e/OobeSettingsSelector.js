//
// Copyright (C) Microsoft. All rights reserved.
//

define(() => {
    class OOBESettingsSelector {
        launchAsync() {
            let self = this;
            return new WinJS.Promise((completeDispatch /*, errorDispatch, progressDispatch */) => {
                self.recordAadcApplicabilityBreadcrumbAsync( 1 /* breadcrumbValue */).then(() => {
                    CloudExperienceHost.AgeAppropriateDesignCode.Eligibility.shouldRestrictionsApplyToCurrentUserAsync().then((shouldRestrictionsApply) => {
                        if (shouldRestrictionsApply && (CloudExperienceHost.getContext().personality === CloudExperienceHost.TargetPersonality.LiteWhite)) {
                            // If AADC restrictions apply to the current user and we're running in a CXH flow with LiteWhite personality, go to the AADC settings page
                            completeDispatch(CloudExperienceHost.AppResult.action2);
                        } else {
                            // If AADC restrictions don't apply or we're running in a CXH flow with InclusiveBlue personality, choose between single-page and multi-page privacy settings
                            completeDispatch(self.selectPrivacySettingsPage());
                        }
                    }, (e) => {
                        // In error cases, choose between single-page and multi-page privacy settings
                        completeDispatch(self.selectPrivacySettingsPage());
                    });
                }, (e) => {
                    // In error cases, choose between single-page and multi-page privacy settings
                    completeDispatch(self.selectPrivacySettingsPage());
                });
            });
        }

        // Record an override for the "FirstLogonOnAadcCompliantInstallation" value written in LogonTasks
        // This applies specifically for the OOBE case, where the device could receive an update after the privacy settings page but before the first user logon
        recordAadcApplicabilityBreadcrumbAsync(breadcrumbValue) {
            return CloudExperienceHostAPI.UserIntentRecordCore.setIntentPropertyDWORDAsync("OobeSettingsSelector", "FirstLogonOnAadcCompliantInstallationOverride", breadcrumbValue);
        }

        selectPrivacySettingsPage() {
            // List of regions that use the multi-page version of settings
            // Please be aware of the lists in %SDXROOT%\onecoreuap\shell\inc\PrivacyConsentHelpers.h
            // and %SDXROOT%\onecoreuap\shell\cloudexperiencehost\onecore\app\App\ts\environment.ts,
            // which are not necessarily the same as this list
            let multiPageSettingsSupportedRegionList = ["AT", "AUT", "BE", "BEL", "BG", "BGR", "BR", "BRA", "CA", "CAN", "HR", "HRV", "CY", "CYP",
                "CZ", "CZE", "DK", "DNK", "EE", "EST", "FI", "FIN", "FR", "FRA", "DE", "DEU", "GR", "GRC",
                "HU", "HUN", "IS", "ISL", "IE", "IRL", "IT", "ITA", "KR", "KOR", "LV", "LVA", "LI", "LIE", "LT", "LTU",
                "LU", "LUX", "MT", "MLT", "NL", "NLD", "NO", "NOR", "PL", "POL", "PT", "PRT", "RO", "ROU",
                "SK", "SVK", "SI", "SVN", "ES", "ESP", "SE", "SWE", "CH", "CHE", "GB", "GBR"];
            let region = CloudExperienceHost.Globalization.GeographicRegion.getCode();
            let result = CloudExperienceHost.AppResult.success;
            if (multiPageSettingsSupportedRegionList.includes(region))
            {
                result = CloudExperienceHost.AppResult.action1;
            }
            return result;
        }
    }
    return OOBESettingsSelector;
});