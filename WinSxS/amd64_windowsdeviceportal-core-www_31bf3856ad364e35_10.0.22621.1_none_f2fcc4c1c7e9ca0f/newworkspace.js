(function () {

    "use strict";

    function newWorkspace(ev) {
        var name = document.getElementById("newworkspace-name").value;
        if (!name) {
            var dialog = new Wdp.Utils._showPopUp(
                "Error",
                "You must give the workspace a name."
            );
        }
        var succeeded = workspaceManager._new(name);
        ev.stopPropagation();
        ev.preventDefault();
    }
    document.getElementById("newworkspace-submit").addEventListener("click", newWorkspace, false);
    document.getElementById("newworkspace-form").addEventListener("submit", newWorkspace, false);

    var nameTextbox = document.getElementById("newworkspace-name");

    // Find a unique name
    var workspaceManager = Wdp.Utils._workspaceManager;
    var numberAppendedToName = 1;
    var suggestedName = "Workspace " + numberAppendedToName;
    while (workspaceManager._findWorkspaceByName(suggestedName)) {
        numberAppendedToName++;
        suggestedName = "Workspace " + numberAppendedToName;
    }
    nameTextbox.value = suggestedName;
    nameTextbox.focus();
    nameTextbox.select();
})();
//@ sourceURL=menu/newworkspace/newworkspace.js