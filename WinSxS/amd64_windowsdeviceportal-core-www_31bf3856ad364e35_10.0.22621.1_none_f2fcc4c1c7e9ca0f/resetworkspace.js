(function () {

    "use strict";

    function resetWorkspace(ev) {
        var workspaceManager = Wdp.Utils._workspaceManager;
        var workspaceId = workspaceManager._activeWorkspaceId;
        var workspaceIndex = workspaceManager._findWorkspaceById(workspaceId, true);
        if (workspaceIndex !== -1) {
            // Find the origional workspace data
            var origionalWorkspaces = workspaceManager._origionalWorkspaceData.workspaces;
            for (var i = 0, len = origionalWorkspaces.length; i < len; i++) {
                if (workspaceId === origionalWorkspaces[i].id) {
                    workspaceManager._workspaceData.workspaces[workspaceIndex].data = origionalWorkspaces[i].data;
                    // Doing a load will implicitly call save, so when the user reloads the page. The workspace
                    // layout will still be reset. That is why we don't need to call save here.
                    workspaceManager._load(origionalWorkspaces[i]);
                    break;
                }
            }
        }
        history.back();
    };
    document.getElementById("resetworkspace-submit").addEventListener("click", resetWorkspace, false);

})();
//@ sourceURL=menu/resetworkspace/resetworkspace.js