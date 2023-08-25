/// <reference path="jquery/jquery.js" />

(function () {
    "use strict";

    function DevicePairControl(parentId) {
        // setup the DOM for this control
        var controlHtml =
            '<div id="initiatePairGroup"> \
            <p>Request a PIN to set your user name and password</p> \
            <button id="requestPairing" class="commonButton">Request pin</button> \
        </div> \
        <div id="doPairGroup"> \
            </br> \
            <span>PIN displayed on your device:</span></br> \
            <input type="text" name="pin" id="pin"/></br> \
            </br> \
            <span class="credentialsInput">New user name:</span></br> \
            <input type="text" name="userName" id="userName"/><br/> \
            <br/> \
            <span>New password:</span></br> \
            <input type="password" name="password" id="password"/></br> \
            <span>Confirm password:</span></br> \
            <input type="password" name="confirmPassword" id="confirmPassword"/></br> \
            <br/> \
            <button id="doPair" class="commonButton">Pair</button> \
        </div>';
        $('#' + parentId).html(controlHtml);

        $("#requestPairing").click(OnStartPairingClick);
        $("#doPair").click(OnDoPairingButton);
        $('#password').keyup(OnPasswordEnter);
        $('#confirmPassword').keyup(OnPasswordEnter);

        function OnPasswordEnter(event) {
            if (event.which == 13) {
                // Enter on the password field is equivalent to clicking the pairing button
                OnDoPairingButton();
            }
        };

        function OnStartPairingClick() {
            $("#requestPairing").attr("disabled", true);

            $.post("/api/authorize/startpair").done(function () {
                GoToRunPairState();
            })
            .fail(function () {
                alert("Failed to start pairing");
                GotoInitState();
            });
        };

        function OnDoPairingButton() {
            var pin = $("#pin").val();
            var userName = $("#userName").val();
            var password = $("#password").val();
            var confirmPassword = $("#confirmPassword").val();

            if (password != confirmPassword) {
                alert("Passwords do not match! Unable to start device pairing.");
                return;
            }

            $("#doPair").attr("disabled", true);

            var params = { pin: pin, username: userName, password: password };
            var pairUri = "/api/authorize/pair?" + $.param(params);

            $.post(pairUri).done(function () {
                window.location.href = '/default.htm';
            })
            .fail(function (errorResponse) {
                var errorMessage = "";

                try {
                    var obj = jQuery.parseJSON(errorResponse.responseText);
                    if (obj.Reason != undefined) {
                        errorMessage = obj.Reason;
                    }
                } catch (error) {
                }

                if (errorMessage.length != 0) {
                    alert("Failed to pair with device: " + errorMessage);
                } else {
                    alert("Failed to pair with device");
                }

                GotoInitState();
            });
        };

        function GotoInitState() {
            $("#requestPairing").attr("disabled", false);
            $("#initiatePairGroup").show();
            $('#doPairGroup').hide();
        };

        function GoToRunPairState() {
            $("#pin").val("");
            $("#doPair").attr("disabled", false);
            $("#initiatePairGroup").hide();
            $('#doPairGroup').show();
        };
    };

    function SSLCertDownloadControl(parentId) {
        var self = this;
        self.parentId = parentId;

        $.ajax({ url: '/config/rootcertificate', cache: true, type: 'head' })
            .done(function (data, textStatus, error) {
                if (error.status == 200) {
                    createUIForSSLEnabled();
                } else if (error.status == 404) {
                    createUIForSSLDisabled();
                } else {
                    createUIForUnknownSSLStatus();
                }
            })
            .error(function (data) {
                if (data.status == 404) {
                    createUIForSSLDisabled();
                } else {
                    createUIForUnknownSSLStatus();
                }
            });

        function createUIForSSLEnabled() {
            var controlHtml =
                '<div class="indentSection"> \
                <p>Seeing a "certificate error" in your browser? You can fix that by creating a trusted relationship with this device. Follow these steps:</p> \
                <p class="indentSection">1. <a class="navigationLink" href="/config/rootcertificate">Download and open this device\'s certificate</a>.</p> \
                <p class="indentSection">2. Go to the Details tab and make note of the certificate\'s thumbprint value.</p> \
                <p class="indentSection">3. Check that the thumbprint value matches the thumbprint displayed in your device\'s Windows Device Portal settings area.</p> \
                <p class="indentSection warning">4. If it does not match, the certificate could be from a malicious third party on your network. Delete the certificate and contact your network administrator.</p> \
                <p class="indentSection">5. If it does match, go back to the General tab and install the certificate to the "Trusted Root Certification Authorities" store.<p> \
                <p>For more information, see the <a class="navigationLink" href="https://go.microsoft.com/fwlink/?LinkID=735015#Security_certificate">documentation</a>.</p> \
            </div>';
            $('#' + parentId).html(controlHtml);
        };

        function createUIForSSLDisabled() {
            $('#' + self.parentId).html('<p>This device does not have a certificate</p>');
        };

        function createUIForUnknownSSLStatus() {
            $('#' + self.parentId).html('<p>No certificate information available!</p>');
        };
    };

    var sslCertDownloadControl = new SSLCertDownloadControl("deviceCertSection");
}())
//@ sourceURL=menu/devicecert/devicecert.js
