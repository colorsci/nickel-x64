﻿USB4View.SidebarTunnel=(class{constructor(n,t){this._tunnel=n;this._sidebarDivId=t;this._sidebarDivElement=document.getElementById(t);this._sidebarDivElement.innerHTML="";this._tunnelTableProperties={domainId:"Domain ID"};this._segmentTableProperties={topologyId:"Topology ID","startAdapter.kind":"Start Adapter Type","startAdapter.adapterNumber":"Start Adapter Number","endAdapter.kind":"End Adapter Type","endAdapter.adapterNumber":"End Adapter Number",weight:"Weight",priority:"Priority",inHopId:"In HopID",outHopId:"Out HopID",pathCredits:"Path Credits"};this._componentTables={}}render(){this._generateTunnelInfoBox();this._generatePathInfoBoxes()}destroy(){this._sidebarDivElement.innerHTML=""}_generateTunnelInfoBox(){let n="TunnelHandle: "+USB4View.intToHexString(this._tunnel.tunnelHandle),t=$(document.createElement("div")).addClass("info-box").attr("tabindex",0).attr("aria-label",n).appendTo(this._sidebarDivElement);$(document.createElement("div")).addClass("main-info sidebar-center").append("<a>"+n+"<\/a>").on("click",USB4View.onCollapsibleHeaderClick).appendTo(t);$(document.createElement("div")).addClass("info-table commonTable collapsible-content").attr("style","display: block;").attr("id","tunnelTable").appendTo(t);let i=[];Object.keys(this._tunnelTableProperties).forEach(n=>{USB4View.appendPropertyValue(i,n,this._tunnelTableProperties[n],this._tunnel)});USB4View.createSlickGridTable("tunnelTable",i,this)}_generatePathInfoBoxes(){let n=$(document.createElement("div")).addClass("info-container").appendTo(this._sidebarDivElement);this._tunnel.paths.forEach(t=>{this._addPathInfoBox(t,t.isIncoming,n)})}_addPathInfoBox(n,t,i){let u=$(document.createElement("div")).addClass("info-box").attr("tabindex",0).attr("aria-label",n.name).appendTo(i),r=$(document.createElement("div")).append('<div class="sidebar-center tunnel-title">'+n.name+" "+this._getPathDirectionArrow(t)+"<\/div>").appendTo(u);n.segments.forEach((t,i)=>{$(document.createElement("div")).append("<a>Segment["+i+"]<\/a>").addClass("collapsible-header main-info sidebar-center").attr("tabindex",0).attr("aria-label","Segment "+i).on("click",USB4View.onCollapsibleHeaderClick).appendTo(r);let u=n.name+"segment"+i+"Table";$(document.createElement("div")).addClass("info-table commonTable collapsible-content").attr("style","display: block;").attr("id",u).appendTo(r);let f=[];Object.keys(this._segmentTableProperties).forEach(n=>{USB4View.appendPropertyValue(f,n,this._segmentTableProperties[n],t)});USB4View.createSlickGridTable(u,f,this)})}_getPathDirectionArrow(n){return n?"&#x2191":"&#x2193"}})