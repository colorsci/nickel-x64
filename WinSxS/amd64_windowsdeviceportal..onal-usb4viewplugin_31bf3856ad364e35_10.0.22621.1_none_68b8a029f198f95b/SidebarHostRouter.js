﻿USB4View.SidebarHostRouter=(class{constructor(n,t){this._hostRouter=n;this._sidebarDivId=t;this._sidebarDivElement=document.getElementById(t);this._sidebarDivElement.innerHTML="";this._hostRouterTableProperties={domainId:" Domain ID",productId:"Product ID",revisionId:"Revision ID",subVendorId:"Sub Vendor ID",subSystemId:"Sub System ID"};this._componentTables={}}render(){this._generateHostRouterInfoBox()}destroy(){this._sidebarDivElement.innerHTML=""}_generateHostRouterInfoBox(){let n=$(document.createElement("div")).addClass("info-box").attr("tabindex",0).attr("aria-label",this._hostRouter.pnpDeviceDescription).appendTo(this._sidebarDivElement);$(document.createElement("div")).addClass("collapsible-header main-info sidebar-center").append("<a>"+this._hostRouter.pnpDeviceDescription+"<\/a>").on("click",USB4View.onCollapsibleHeaderClick).appendTo(n);$(document.createElement("div")).addClass("info-table commonTable collapsible-content").attr("style","display: block;").attr("id","hostRouterTable").appendTo(n);let t=[];Object.keys(this._hostRouterTableProperties).forEach(n=>{USB4View.appendPropertyValue(t,n,this._hostRouterTableProperties[n],this._hostRouter)});USB4View.createSlickGridTable("hostRouterTable",t,this)}})