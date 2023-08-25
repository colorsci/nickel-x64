(function () {

    "use strict";

    var wdpPsuedoNamespace = "wdp-",
    dockPsuedoNamespace = "dock-",
    wdpMenuPsuedoNamespace = wdpPsuedoNamespace + "menu-",
    cssClassContent = dockPsuedoNamespace + "content",
    cssClassIcon = wdpPsuedoNamespace + "icon",
    cssClassMenuTools = wdpMenuPsuedoNamespace + "tools",
    cssClassMenuToolAlreadyAdded = wdpMenuPsuedoNamespace + "toolalreadyadded",
    cssClassMenuToolName = wdpMenuPsuedoNamespace + "tool-label",
    cssClassTool = wdpPsuedoNamespace + "addtool-tool",
    dockPsuedoNamespace = "data-dock-",
    attributeUri = dockPsuedoNamespace + "uri";

    // Look at the list of tools & add them
    function refresh(pluginTools) {
        var activeWorkspace = workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId);
        // Get all the tools defined in workspace-definitions.js
        var tools = menu._tools;

        function sortTools(a, b) {
            var nameA = a.name.toLowerCase();
            var nameB = b.name.toLowerCase();
            if (nameA < nameB) return -1;
            if (nameA > nameB) return 1;
            return 0;
        };

        if (pluginTools) {
            tools = tools.concat(pluginTools);
            tools.sort(sortTools);
        }

        var htmlString = "";
        var tags = false;
        for (var i = 0, len = tools.length; i < len; i++) {
            var tool = tools[i];
            if (tool.tag) {
                // If we detect tags, then layout the tools using categories to group related tools together.
                tags = true;
                break;
            }
            htmlString += '<li class="' + cssClassTool + '" ' + attributeUri + '="' + tool.uri + '"><input type="checkbox" id="addTool' + i + '" /><label for="addTool' + i + '">' + tool.name + '</label></li>';
        }

        if (tags) {
            var miscTagName = "Other";
            var untaggedTools = false;
            htmlString = "";
            // Find all the tags
            var tags = [];
            for (var i = 0, len = tools.length; i < len; i++) {
                var tag = tools[i].tag;
                if (!tag) {
                    tools[i].tag = miscTagName;
                    untaggedTools = true;
                } else {
                    // Check if we already have this tag in our tags list
                    var found = false;
                    for (var j = 0, len2 = tags.length; j < len2; j++) {
                        if (tag === tags[j]) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        tags.push(tag);
                    }
                }
            }
            if (untaggedTools) {
                tags.push(miscTagName);
            }
            // Loop through tags and place the menu options
            for (var i = 0, len = tags.length; i < len; i++) {
                var tag = tags[i];
                htmlString += '<div class="' + cssClassMenuCategory + '"><div class="' + cssClassMenuCategoryName + '">' + tag + '</div>';
                for (var j = 0, len2 = tools.length; j < len2; j++) {
                    var tool = tools[j];
                    if (tool.tag === tag) {
                        htmlString += '<li class="wdp-addtool-tool" ' + attributeUri + '="' + tool.uri + '"><input type="checkbox" id="addTool' + i + '" /><label for="addtool' + i + '" class="' + cssClassAddToolName + '">' + tool.name + '</label></li>';
                    }
                }
                htmlString += '</div>';
            }
        }
        availableToolsElement.innerHTML = htmlString;

        // Get all the tools in the current workspace
        var toolsInWorkspace = workspaceManager._element.querySelectorAll("." + cssClassContent);
        var toolMenuItems = availableToolsElement.querySelectorAll("." + cssClassTool);
        // Loop through tools & put check or not class
        for (var i = 0, len = toolMenuItems.length; i < len; i++) {
            var toolMenuItem = toolMenuItems[i];
            // See if the tool is already on the canvas
            var alreadyInWorkspace = false;
            for (var j = 0, len2 = toolsInWorkspace.length; j < len2; j++) {
                var toolUri = toolMenuItem.getAttribute(attributeUri).replace(location.origin, "");
                if (toolsInWorkspace[j].getAttribute(attributeUri).replace("/ws/", "") === toolUri.replace("/ws/", "")) {
                    alreadyInWorkspace = true;
                    break;
                }
            }
            if (toolsInWorkspace.length &&
                alreadyInWorkspace) {
                toolMenuItem.style.display = "none";
            }
        }
    };

    function save(ev) {
        // Need to find all the selected tools & then add them.
        var selectedTools = availableToolsElement.querySelectorAll(".wdp-addtool-tool input:checked");
        for (var i = 0, len = selectedTools.length; i < len; i++) {
            var selectedTool = selectedTools[i].parentNode;
            var name = selectedTool.textContent.trim();
            var uri = selectedTool.getAttribute(attributeUri).replace(location.origin, "");
            workspaceManager._addTool(name, uri);
        }
        // Set the window title back to the workspace name
        if (window.DeviceSettings && window.DeviceSettings.DeviceLabel) {
            location.title = workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId).name + " - " + window.DeviceSettings.DeviceLabel + " Device Portal";
            var titleLabel = document.querySelector("#wdp-titlelabel");
            titleLabel.textContent = location.title;
        }
        history.back();
    };
    var workspaceManager = Wdp.Utils._workspaceManager;
    var menu = Wdp.Utils._menu;
    document.getElementById("wdp-addtool-description").textContent = "Choose which tools from the list below you would like to add to the " + workspaceManager._findWorkspaceById(workspaceManager._activeWorkspaceId).name + " workspace.";
    var availableToolsElement = document.getElementById("wdp-addtool-availabletools");
    document.getElementById("wdp-addtool-submit").addEventListener("click", save, false);

    var webbRest = new WebbRest();
    webbRest.getPluginTools()
        .done(function (data) {
            refresh(data.Tools);
        })
        .fail(function (data) {
            refresh(null);
        });
})();
//@ sourceURL=menu/AddTool/AddTool.js
