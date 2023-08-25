(function () {

    "use strict";

    function deleteWorkspace(ev) {
        var succeeded = workspaceManager._remove();
        if (succeeded) {
            document.getElementById("wdp-aria-message").innerHTML = "Workspace successfully deleted";
        } else {
            // TODO - Error handling
        }
    };
    var workspaceManager = Wdp.Utils._workspaceManager;
    document.getElementById("deleteworkspace-submit").addEventListener("click", deleteWorkspace, false);
    document.getElementById("deleteworkspace-label").textContent = "Are you sure you want to delete " + workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId).name + "?";

})();
//@ sourceURL=menu/DeleteWorkspace/DeleteWorkspace.js