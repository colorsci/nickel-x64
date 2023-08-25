(function () {

    "use strict";

    function showError(errorMessage) {
        var dialog = new Wdp.Utils._showPopUp(
            "Something went wrong",
            errorMessage
        );
    };

    function importWorkspace(ev) {
        var fileInput = document.getElementById("importworkspace-path");
        var file = fileInput.files[0];
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.addEventListener("load", function (ev) {
                var dataAsString = ev.target.result;
                var workspaceManager = Wdp.Utils._workspaceManager;
                var workspace = null;
                try {
                    workspace = JSON.parse(dataAsString);
                } catch (ex) {
                    // Do nothing, we handle the error later. If the workspace is null,
                    // then we will show an error.
                }
                // Append the new workspace to the end of the workspaces list
                // and reload it.
                if (workspace) {
                    var existingWorkspaceIndex = workspaceManager._findWorkspaceById(workspace.id, true);
                    if (existingWorkspaceIndex != -1) {
                        if (workspaceManager._workspaceData.workspaces[existingWorkspaceIndex].name == workspace.name) {
                            // Names and IDs are equal.  The new workspace is probably meant to overwrite the existing workspace.
                            workspaceManager._workspaceData.workspaces[existingWorkspaceIndex] = workspace;
                        } else {
                            // IDs are equal, but names are not.  The new workspace is probably meant to be a new workspace, but originated from an existing workspace.
                            do {
                                workspace.id = workspaceManager._generateGUID();
                            } while (workspaceManager._findWorkspaceById(workspace.id, true) !== -1)
                            workspace.editable = true;
                            workspaceManager._workspaceData.workspaces.push(workspace);
                        }
                    } else {
                        workspace.editable = true;
                        workspaceManager._workspaceData.workspaces.push(workspace);
                    }
                    workspaceManager._load(workspace);
                    workspaceManager._refreshNav();
                } else {
                    showError("Corrupt or invalid workspace file.");
                }
            }.bind(this), false);
            reader.addEventListener("error", function (ev) {
                showError("There was an error reading the file.");
            }.bind(this), false);
        } else {
            showError("The file could not be found.");
        }
    };
    document.getElementById("importworkspace-submit").addEventListener("click", importWorkspace, false);

})();
//@ sourceURL=menu/ImportWorkspace/ImportWorkspace.js