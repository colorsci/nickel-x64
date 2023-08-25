(function () {

    "use strict";

    var workspaceManager = Wdp.Utils._workspaceManager;
    function exportWorkspace(ev) {
        var workspace = workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId);
        var jsonData = JSON.stringify(workspace, null, " ");
        // The following will open the file in the users browser. I decided to use this approach
        // rather than exposing a rest endpoint because I want to keep this private because
        // workspace persistence will change once we have "the cloud" for a roaming story.
        var blob = new Blob([jsonData], { type: 'application/json' });
        var link = document.createElement('a');
        link.href = window.URL.createObjectURL(blob);
        link.download = workspace.name + ".workspace";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        history.back();
    };
    document.getElementById("exportworkspace-submit").addEventListener("click", exportWorkspace, false);

    var explanationText = document.getElementById("exportworkspace-explanationtext");
    var workspaceName = workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId).name;
    explanationText.textContent = "Export the \"" + workspaceName + "\" workspace. Exporting a workspace will save your customizations, allowing you to import them to another machine using the Import workspace option in the menu.";

})();
//@ sourceURL=menu/ExportWorkspace/ExportWorkspace.js