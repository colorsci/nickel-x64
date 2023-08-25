function OSInformationControl(n){var t=this;t.parent=n;(new WebbRest).getSoftwareInfo().done(function(t){var i='<table> <tbody id="HostInfoDataBody">';i+='<tr><td><b><label for="machineNameField">Device name<\/label>: <\/b><\/td>';i+='<td><div id="deviceNameSection"><\/div><\/td>';i+="<\/tr>";i+="<tr><td><b>OS version: <\/b><\/td><td>"+t.OsVersion+"<\/td><\/tr>";i+="<\/tbody><\/table>";$("#"+n).html(i);new MachineNameControl("deviceNameSection")}).fail(function(){$("#"+n).append('<p class="warning">Failed to get system information<\/p>')})}var WebbRest;$(function(){new OSInformationControl("OSInformationSection")});
/*!
//@ sourceURL=tools/DeviceInfo/DeviceInfo.js
*/
