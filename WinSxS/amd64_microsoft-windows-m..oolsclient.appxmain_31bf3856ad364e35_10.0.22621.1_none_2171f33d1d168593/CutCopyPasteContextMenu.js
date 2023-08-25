﻿var Common;!function(e){"use strict";class t{constructor(e,t){this._element=e;this._onModifyCallback=t;this._element.addEventListener("contextmenu",e=>this.handleContextMenu(e));this._element instanceof HTMLInputElement&&this._element.addEventListener("keyup",e=>this.handleKeyUp(e))}get isActive(){return this._isActive}show(t,n){var o=t,s=n;if(this._element instanceof HTMLInputElement&&(o<=0||s<=0)){var i=e.ToolWindowHelpers.getSelection(this._element),l=e.ToolWindowHelpers.getCharScreenPosition(this._element,i.end);o=l.left;s=l.top}var a=[];this._element instanceof HTMLInputElement&&a.push({id:"menuInputBoxCut",type:Microsoft.Plugin.ContextMenu.MenuItemType.command,label:Microsoft.Plugin.Resources.getString("/Common/CutMenuText"),accessKey:Microsoft.Plugin.Resources.getString("/Common/AccessKeyCtrlX")});a.push({id:"menuInputBoxCopy",type:Microsoft.Plugin.ContextMenu.MenuItemType.command,label:Microsoft.Plugin.Resources.getString("/Common/CopyMenuText"),accessKey:Microsoft.Plugin.Resources.getString("/Common/AccessKeyCtrlC")});this._element instanceof HTMLInputElement&&a.push({id:"menuInputBoxPaste",type:Microsoft.Plugin.ContextMenu.MenuItemType.command,label:Microsoft.Plugin.Resources.getString("/Common/PasteMenuText"),accessKey:Microsoft.Plugin.Resources.getString("/Common/AccessKeyCtrlV")});var r=(e,t,n)=>{this.invokeContextMenu(e,t)},u=Microsoft.Plugin.ContextMenu.create(a,null,null,null,r);u.attach(this._element);this._isActive=!0;u.show(o,s);u.addEventListener("dismiss",()=>{u.dispose();this._isActive=!1})}invokeContextMenu(e,t){switch(t.id){case"menuInputBoxCut":this.onCut();break;case"menuInputBoxPaste":this.onPaste();break;case"menuInputBoxCopy":this.onCopy()}}onCut(){var t=e.ToolWindowHelpers.getSelection(this._element),n=this.getSelectedText()||"",o=this._element;o.value=o.value.substring(0,t.start)+o.value.substring(t.end);this._onModifyCallback&&this._onModifyCallback();this._element.focus();o.setSelectionRange(t.start,t.start);e.ClipboardHelper.copyPlainText(n)}onCopy(){const t=this.getSelectedText()||"";e.ClipboardHelper.copyPlainText(t);this._element.focus()}async onPaste(){const t=await e.ClipboardHelper.getPasteTextAsync();var n=e.ToolWindowHelpers.getSelection(this._element),o=this._element;o.value=e.ToolWindowHelpers.replaceTextInRange(o.value,n.start,n.end,t);this._onModifyCallback&&this._onModifyCallback();o.focus();var s=n.start+t.length;setImmediate(()=>o.setSelectionRange(s,s))}getSelectedText(){var t;if(this._element instanceof HTMLInputElement){var n=e.ToolWindowHelpers.getSelection(this._element),o=this._element;t=o.value.substring(n.start,n.end)||o.value}else{var s=window.getSelection();if(1===s.rangeCount){var i=s.getRangeAt(0);i.startContainer.parentNode===this._element&&i.endContainer.parentNode===this._element&&(t=i.toString())}t||(t=this._element.textContent)}return t}handleContextMenu(e){this.show(e.clientX,e.clientY);e.stopImmediatePropagation();e.preventDefault();return!1}handleKeyUp(t){if(t.keyCode===e.KeyCodes.F10&&t.shiftKey&&!t.ctrlKey&&!t.altKey){this.show(0,0);t.stopImmediatePropagation();t.preventDefault();return!1}}}e.CutCopyPasteContextMenu=t}(Common||(Common={}));
