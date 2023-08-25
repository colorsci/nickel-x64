﻿var USB4View=USB4View?USB4View:{};USB4View.DFPLaneAdapterHorizontalOuterPad=10;USB4View.DFPPortBaseHeight=100;USB4View.DFPPortBaseWidth=85;USB4View.DFPPortNumberHeight=20;USB4View.DFPPortNumberWidth=40;USB4View.PortNumberPad=3;USB4View.LaneNumberPad=3;USB4View.KonvaDFP=(class{constructor(n,t){this._container=t;this.port=n;this._group=new Konva.Group;this._boundingRect=new Konva.Rect({width:USB4View.DFPPortBaseWidth,height:USB4View.DFPPortBaseHeight,stroke:"black",fill:"grey",strokeWidth:USB4View.STROKEWIDTH});this._group.add(this._boundingRect);const i=USB4View.DFPPortBaseWidth/2-USB4View.DFPPortNumberWidth/2;this._portNumberGroup=new Konva.Group({x:i,y:USB4View.DefaultPad});this._portNumberBox=new Konva.Rect({width:USB4View.DFPPortNumberWidth,height:USB4View.DFPPortNumberHeight,stroke:"black",fill:"white",strokeWidth:3});this._portNumberText=new Konva.Text({width:this._portNumberBox.width(),height:this._portNumberBox.height()+USB4View.PortNumberPad,text:n.portNumber,fontSize:20,fontFamily:"Consolas",align:"center",verticalAlign:"middle"});this._portNumberGroup.add(this._portNumberBox,this._portNumberText);this._group.add(this._portNumberGroup);this.lane0AdapterGroup=this._drawLaneAdapter(n.lane0Adapter,USB4View.DFPLaneAdapterHorizontalOuterPad,USB4View.DefaultPad+this._portNumberBox.height()+USB4View.DefaultPad);this.lane1AdapterGroup=this._drawLaneAdapter(n.lane1Adapter,USB4View.DFPPortBaseWidth-USB4View.DFPLaneAdapterHorizontalOuterPad-USB4View.LaneAdapterBoundingCircleRadius*2,USB4View.DefaultPad+this._portNumberBox.height()+USB4View.DefaultPad);this._konvaPCIeUSB3Adapters={};this._dpInGroup=new USB4View.KonvaDPGroup(this._group,!0);this._lane0Toggled=!1;this._lane1Toggled=!1;this.konvaObject=null}get width(){return this._boundingRect.width()}get height(){return this._boundingRect.height()}static get baseWidth(){return USB4View.DFPPortBaseWidth}static get baseHeight(){return USB4View.DFPPortBaseHeight}setPosition(n,t){this._group.setAttrs({x:n,y:t});this.konvaObject==null&&(this.konvaObject=this._group,this._container.add(this.konvaObject))}addAdapter(n){n&&!n.isDrawn()&&(n.adapter.kind==USB4View.USB3||n.adapter.kind==USB4View.PCIe?this._addPCIeUSB3Adapter(n):n.adapter.kind==USB4View.DP&&this._addDPAdapter(n))}removeAdapter(n){return this._containsPCIeUSB3DownAdapter(n)?this._removePCIeUSBAdapter(n):this._containsDPAdapter(n)?this._removeDPAdapter(n):null}toggleAdapterHighlight(n){this.port.lane0Adapter==n.adapterNumber?this._toggleLaneAdapterHighlight(!0):this.port.lane1Adapter==n.adapterNumber?this._toggleLaneAdapterHighlight(!1):this._containsDPAdapter(n.adapterNumber)?this._dpInGroup.toggleDPAdapterHighlight(n.adapterNumber):this._containsPCIeUSB3DownAdapter(n.adapterNumber)&&this._konvaPCIeUSB3Adapters[n.adapterNumber].toggleHighlight()}containsPCIeUSB3DownOrDPAdapter(n){return this._containsPCIeUSB3DownAdapter(n)||this._containsDPAdapter(n)}_containsPCIeUSB3DownAdapter(n){return n in this._konvaPCIeUSB3Adapters}_containsDPAdapter(n){return this._dpInGroup.containsDPAdapter(n)}_addPCIeUSB3Adapter(n){n.setPosition(USB4View.DefaultPad,this._lastPCIeUSB3AdapterBottomWithPaddingYPos(),this._group);this._konvaPCIeUSB3Adapters[n.adapter.adapterNumber]=n;let t=this._repositionDPInGroup();this._boundingRect.height(t);this._group.y(USB4View.DFPPortBaseHeight-t)}_removePCIeUSBAdapter(n){let t=this._konvaPCIeUSB3Adapters[n];t.remove();delete this._konvaPCIeUSB3Adapters[n];let i=this._repositionDPInGroup();return Object.values(this._konvaPCIeUSB3Adapters).forEach((n,t)=>{const i=this._firstPCIeUSB3AdapterYPos()+t*USB4View.KonvaProtocolAdapter.baseHeight;n.setPosition(USB4View.DefaultPad,i)}),this._boundingRect.height(i),this._group.y(USB4View.DFPPortBaseHeight-i),t}_repositionDPInGroup(){let n=this._lastPCIeUSB3AdapterBottomWithPaddingYPos();return this._dpInGroup.isDrawn()&&(this._dpInGroup.setPosition(this._dpInGroup.konvaObject.x(),n),n+=this._dpInGroup.height+USB4View.DefaultPad),Math.max(n,USB4View.DFPPortBaseHeight)}_addDPAdapter(n){if(!this._dpInGroup.isDrawn()){this._dpInGroup.setPosition(USB4View.DefaultPad,this._lastPCIeUSB3AdapterBottomWithPaddingYPos());const n=this._dpInGroup.konvaObject.y()+this._dpInGroup.height+USB4View.DefaultPad;this._boundingRect.height(n);this._group.y(USB4View.DFPPortBaseHeight-n)}this._dpInGroup.addDPAdapter(n)}_lastPCIeUSB3AdapterBottomWithPaddingYPos(){const n=Object.keys(this._konvaPCIeUSB3Adapters).length;return this._firstPCIeUSB3AdapterYPos()+n*(USB4View.KonvaProtocolAdapter.baseHeight+USB4View.DefaultPad)}_firstPCIeUSB3AdapterYPos(){return this.lane0AdapterGroup.y()+USB4View.LaneAdapterBoundingCircleRadius*2+USB4View.DefaultPad}_removeDPAdapter(n){let t=this._dpInGroup.removeDPAdapter(n);if(this._dpInGroup.size==0){const n=Math.max(this._dpInGroup.konvaObject.y(),USB4View.KonvaDFP.baseHeight);this._dpInGroup.remove();this._boundingRect.height(n);this._group.y(USB4View.KonvaDFP.baseHeight-n)}return t}_drawLaneAdapter(n,t,i){let r=new Konva.Group({x:t,y:i});const u=new Konva.Circle({x:USB4View.LaneAdapterBoundingCircleRadius,y:USB4View.LaneAdapterBoundingCircleRadius,radius:USB4View.LaneAdapterBoundingCircleRadius,stroke:"black",fill:"black",strokeWidth:USB4View.STROKEWIDTH}),f=new Konva.Text({width:u.radius()*2,height:u.radius()*2+USB4View.LaneNumberPad,text:n,fontSize:20,fontFamily:"Consolas",align:"center",fill:"white",verticalAlign:"middle"});return r.add(u,f),this._group.add(r),r}_toggleLaneAdapterHighlight(n){if(n){let n=this.lane0AdapterGroup.children[0];this._lane0Toggled?(this._lane0Toggled=!1,n.setAttrs(USB4View.KonvaUntoggledProperty)):(this._lane0Toggled=!0,n.setAttrs(USB4View.KonvaToggledProperty))}else{let n=this.lane1AdapterGroup.children[0];this._lane1Toggled?(this._lane1Toggled=!1,n.setAttrs(USB4View.KonvaUntoggledProperty)):(this._lane1Toggled=!0,n.setAttrs(USB4View.KonvaToggledProperty))}}})