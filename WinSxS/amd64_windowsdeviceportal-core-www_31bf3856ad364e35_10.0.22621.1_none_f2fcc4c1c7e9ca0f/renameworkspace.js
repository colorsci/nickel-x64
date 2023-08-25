(function () {

    "use strict";

    function renameWorkspace(ev) {
        var name = document.getElementById("renameworkspace-name").value;
        var succeeded = Wdp.Utils._workspaceManager._rename(name);
        if (!succeeded) {
            var dialog = new Wdp.Utils._showPopUp(
                "Error",
                "There was an error renaming the workspace."
            );
        } else {
            history.back();
            workspaceManager._load();
            workspaceManager._refreshNav();
            ev.stopPropagation();
            ev.preventDefault();
        }
    }
    document.getElementById("renameworkspace-submit").addEventListener("click", renameWorkspace, false);
    document.getElementById("renameworkspace-form").addEventListener("submit", renameWorkspace, false);
    var nameTextbox = document.getElementById("renameworkspace-name");
    var workspaceManager = Wdp.Utils._workspaceManager;
    var activeWorkspace = workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId);
    if (activeWorkspace) {
        nameTextbox.value = activeWorkspace.name;
    }
    nameTextbox.focus();
    nameTextbox.select();
})();
//@ sourceURL=menu/renameworkspace/renameworkspace.js