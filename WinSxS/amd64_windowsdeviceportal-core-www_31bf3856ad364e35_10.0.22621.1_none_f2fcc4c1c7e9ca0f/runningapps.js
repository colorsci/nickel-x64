﻿var WebbRest,RunningAppsViewer,ProcessDataUpdater;$(function(){function i(t){t?(n.stop(),$("#RunningAppsGridPauseButton").text("Resume updates"),document.cookie="RunningAppsGridPauseButtonState=Pause",enableSlickGridTabbing("RunningAppsGrid",!0)):(n.start(),$("#RunningAppsGridPauseButton").text("Pause updates"),document.cookie="RunningAppsGridPauseButtonState=Resume",enableSlickGridTabbing("RunningAppsGrid",!1))}function r(){var t=$("#RunningAppsContainerIdSelect"),i;t.on("change",function(){var i=t.val();n.updateContainerId(i)});i=new WebbRest;i.getContainersList().done(function(n){if(n.Supported){for(index=0;index<n.Containers.length;index++){container=n.Containers[index];var i=container.Id.replace("{","").replace("}","");t.append($("<option>",{value:i,text:container.Owner,selected:!1}))}t.show()}})}var t=new RunningAppsViewer("RunningAppsGrid",{gridLabel:"Running apps",rowHeaderName:"Process Name"}),n=new ProcessDataUpdater;n.dataAvailable.add(t.updateRunningAppsList.bind(t));n.start();getCookie("RunningAppsGridPauseButtonState")==="Pause"&&(i(!0),n.refresh());$("#RunningAppsGridPauseButton").click(function(){i($("#RunningAppsGridPauseButton").text()==="Pause updates")});$("#RunningAppsGridRefreshButton").click(function(){n.refresh()});r()});
/*!
//@ sourceURL=tools/RunningApps/RunningApps.js
*/
