/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
All Rights Reserved.

By downloading, modifying, distributing, using and/or accessing any files 
in this directory, you agree to the terms and conditions of the applicable 
end user license agreement.
*/

/* *************************************************************** */
/*
Author: 	
	PaperThin Inc.
	M. Carroll
Name:
	browser-all.js
Summary:
	ADF Lightbox Framework JavaScript
Version:
	1.0.0
History:
	2010-02-19 - MFC - Created
	2010-04-19 - MFC - Commented out some functions that conflict with CS 5.x styles.
	2013-01-03 - GAC - Added missing semi-colons to the ends of variablized functions
*/

function loadNonDashboardFiles()
{
	if (setUpComplete())
		return;
	var filesToLoad = [];
	
	
	/*	
	 *	ADF Update - Updated the file paths
	 */
	filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/js/util.js', fileType: 'script', fileID: null});
	filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/css/buttons.css', fileType: 'link', fileID: 'buttons_css'});
	filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/css/lightbox.css', fileType: 'link', fileID: null});
	//filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/css/dialog.css', fileType: 'link', fileID: null});
	filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/js/lightbox.js', fileType: 'script', fileID: null, callback: setCommonspot});
	filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/js/overrides.js', fileType: 'script', fileID: null});
	filesToLoad.push({fileName: '/ADF/extensions/lightbox/1.0/js/window_ref.js', fileType: 'script', fileID: null});
		
	
	loadDashboardFiles(filesToLoad);
	//temp.onload = newWindow(name,workUrl);
}

if(typeof IncludeJsCache=='undefined') 
{
	IncludeJsCache= {};
}
function IncludeJs(src,fileType,fileID,callback,doc) 
{
	if(typeof doc=="undefined") 
	{
		doc=document;
	}
	if(typeof IncludeJsCache[src]!='undefined') 
	{
		if(IncludeJsCache[src].ready) 
		{
			if(typeof callback=='function')
			{
				callback(src);
			}
		}
		else 
		{
			IncludeJsCache[src].deferred.push(callback);
			return;
		}
	}
	else 
	{
		IncludeJsCache[src]={'source':src,'ready':false,'deferred':[]};
		var scriptElement=doc.createElement(fileType);
		var is = BrowserCheck();
		if(is.mozilla) 
		{
			scriptElement.readyState='loaded';
			scriptElement.onload = function() 
			{
				IncludeJsCache[src].ready=true;
				if(typeof callback=='function') 
				{
					callback(src);
				}
			};
		}
		else 
		{
			scriptElement.onreadystatechange = function() 
			{
				if(scriptElement.readyState=='loaded'||scriptElement.readyState=='complete') 
				{
					IncludeJsCache[src].ready=true;
					if(typeof callback=='function') 
					{
						callback(src);
					}
				}
			};
		}
		if (fileID)
			scriptElement.id = fileID;
		switch (fileType)
		{
			case 'script':
				scriptElement.type = 'text/javascript';
				scriptElement.src = src;
				break;
			case 'link':
				scriptElement.type = 'text/css';
				scriptElement.rel = 'stylesheet';
				scriptElement.href = src;
				break;				
		}		
		var headElement=doc.getElementsByTagName('head')[0];
		headElement.appendChild(scriptElement);
	}
};

function loadDashboardFiles(arrFiles)
{
	var callback;
	for(var i=0; i<arrFiles.length; i++)
	{
		callback = arrFiles[i].callback ? arrFiles[i].callback : null;
		IncludeJs(arrFiles[i].fileName, arrFiles[i].fileType, arrFiles[i].fileID, callback);
	}	
}
function setUpComplete()
{
	if ((top.commonspot && top.commonspot.lightbox) || (parent.commonspot && parent.commonspot.lightbox))
		return true;
	else
		return false;	
}
	
function newCenteredWindow(name, url, width, height, windowFeatures)
{
	var left = (screen.availWidth - width) / 2;
	var top = ((screen.availHeight - height) / 2) - 20; // a bit above center
	if(!windowFeatures)
		var windowFeatures = 'toolbar=no,menubar=no,location=no,scrollbars,resizable';
	windowFeatures += ',top=' + top + ',left=' + left + ',width=' + width + ',height=' + height;
	newWindow(name, url, windowFeatures);
}
function submitFormToNewWindow(windowName, loader, csModule, args)
{
	var form, fldName;
	form = document.createElement('form');
	form.target = windowName;
	form.action = loader;
	form.method = 'post';
	//form.enctype = 'multipart/form-data'; // NEEDSWORK: we may need to do this for UTF8???
	form.style.display = 'none';
	createField(form, 'csModule', csModule);
	for(fldName in args)
		createField(form, fldName, args[fldName]);
	document.body.appendChild(form);
	var win = openEmptyLightBox(null, null, windowName);
	form.target = win;
	form.submit();
	document.body.removeChild(form);
	
	function createField(form, name, value)
	{
		var fld = document.createElement('input');
		fld.type = 'hidden';
		fld.name = name;
		fld.value = value;
		form.appendChild(fld);
	}
}
function AskClearCache (workUrl)
{
	newWindow('clearcache', workUrl);
}
function setSelectedAudience(id)
{
	newWindow('SetAudience',jsDlgLoader + '?csModule=utilities/set-audience&amp;target='+id);
}
function doDisplayOptionsMenu(dlgloader,pageid,event)
{
	var thisMenu = document.getElementById("DisplayOptionsMenu");
	calcMenuPos ("DisplayOptionsMenu",event);
	stopEvent(event);
}
function doRolesMenu(dlgloader,pageid,event)
{
	var thisMenu = document.getElementById("RolesMenu");
	calcMenuPos ("RolesMenu",event);
	stopEvent(event);
}
function doPageManagementMenu(dlgloader,pageid,event)
{
	var thisMenu = document.getElementById("PageManagementMenu");
	calcMenuPos ("PageManagementMenu",event);
	stopEvent(event);
}
function toggleState (value, name)
{
	document.styleSheets[0].addRule(".cls" + name, (value) ? "display:block;" : "display:none;");
	document.cookie = name + "=" + value;
}
function toggleDesc (value, name)
{
	document.getElementById("id" + name).style.display =  (value) ? "block" : "none";
	document.getElementById("id" + name + "img").src =  (value) ? "/commonspot/images/arrow-right.gif" : "/commonspot/images/arrow.gif";
	document.cookie = name + "=" + value;
}
function stopEvent(event)
{
	if(event.preventDefault)
	{
		event.preventDefault();
		event.stopPropagation();
	}
	else
	{
		event.returnValue = false;
		event.cancelBubble = true;
	}
}
function canRollover(browserVersion)
{
	var agent = navigator.userAgent.toLowerCase();
	var isMoz = agent.match('mozilla') && agent.match('gecko');
	var minVers = isMoz ? 3 : 4;
	return (browserVersion >= minVers) ? 1 : 0;
}

var bVer = parseInt(navigator.appVersion);
var bCanRollover = canRollover(bVer);

function ImageSet(imgID,newTarget)
{
	if (bCanRollover)
		document[imgID].src=newTarget;
}

function gotoDiffLang(workUrl)
{
	window.location=workUrl+'&amp;pageid='+js_gvPageID;
}
var doRefresh = true;
function refreshParent()
{
	if ( self.opener && doRefresh )
	{
		self.opener.location.reload();
	}
	self.close;
}

function getFrameWindow(frameID,frameName)
{
	if (frameID)
		return window.document.getElementById(frameID).contentWindow;
	
	var frames = window.frames;
	for (var i=0; i<frames.length; i++)
	{
		if (frames[i].name == frameName)
			return frames[i];
	}
	return null;
}

function getContentFromChildFrame(frameName,fieldname,formname)
{
   if (formname == null)
		formname = "dlgform";
	var RTEFrame = getFrameWindow(frameName);
	if (RTEFrame && RTEFrame.saveKTML)
		RTEFrame.saveKTML(fieldname); // first call the save function of the KTML
	if (document.getElementById(frameName).contentDocument) { // moz
		var innertb=eval("document.getElementById('"+frameName+"').contentDocument."+fieldname+formname+"."+fieldname);
	} else { // IE
		var innertb=eval("document.frames['"+frameName+"'].document."+fieldname+formname+"."+fieldname);
	}
	var tb = eval ('document.' + formname + "." + fieldname);
	tb.value = innertb.value;
}
function glblLinkHandler(lobj, attr, val)
{
	lobj.style[attr]=val;
}
// we should replace tons of diff. instances of form validation codes with this one to make 
// sure we do not have diff. implementations for the same task.	
function stringTrim(_this,str) 
{
   if(!str) str = _this;
   return str.replace(/^\s*/,"").replace(/\s*$/,"");
}

function substringReplace(source,pattern,replacement)
{
	var pos = 0;
	var target="";
	while ((pos = source.indexOf(pattern)) != (-1))
	{
		target = target + source.substring(0,pos) + replacement;
		source = source.substring(pos+pattern.length);
		pos = source.indexOf(pattern);
	}
	return (target + source);
}

function unescapeHTML(msg)
{
	var msg = msg.replace(/<\/?[^>]+>/gi, '');
	//return msg.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&');
    return msg.replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&amp;/g,'&').replace(/&quot;/g,'"');
}

function BrowserCheck() {
	var b=navigator.appName.toString();
	var up=navigator.platform.toString();
	var ua=navigator.userAgent.toString().toLowerCase();
	var re_opera=/Opera.([0-9\.]*)/i;
	var re_msie=/MSIE.([0-9\.]*)/i;
	var re_gecko=/gecko/i;
	var re_safari=/safari\/([\d\.]*)/i;	
	var re_mozilla=/firefox\/([\d\.]*)/i;
	var browserType = {};
	browserType.mozilla=browserType.ie=browserType.opera=r=false;
	browserType.version = (ua.match( /.+(?:rv|it|ra|ie|me)[\/: ]([\d.]+)/ ) || [])[1];
	browserType.chrome = /chrome/.test(ua);
	browserType.safari = /webkit/.test(ua) && !/chrome/.test(ua);
	browserType.opera = /opera/.test(ua);
	browserType.ie = /msie/.test(ua) && !/opera/.test(ua);
	browserType.mozilla = /mozilla/.test(ua) && !/(compatible|webkit)/.test(ua);
	if(ua.match(re_opera)) 
	{
		r=ua.match(re_opera);
		browserType.version=parseFloat(r[1]);
	}
	else if(ua.match(re_msie)) 
	{
		r=ua.match(re_msie);
		browserType.version=parseFloat(r[1]);
	}
	else if(ua.match(re_safari)) 
	{
		browserType.version=1.4;
	}
	else if(ua.match(re_gecko)) 
	{
		var re_gecko_version=/rv:\s*([0-9\.]+)/i;
		r=ua.match(re_gecko_version);
		browserType.version=parseFloat(r[1]);
		if (ua.match(re_mozilla))
		{
			r=ua.match(re_mozilla);
			browserType.version=parseFloat(r[1]);
		}		
	}
	else if (ua.match(re_mozilla))
	{
		r=ua.match(re_mozilla);
		browserType.version=parseFloat(r[1]);
	}
	browserType.windows=browserType.mac=browserType.linux=false;
	browserType.Platform=ua.match(/windows/i)?"windows":(ua.match(/linux/i)?"linux":(ua.match(/mac/i)?"mac":ua.match(/unix/i)?"unix":"unknown"));
	this[browserType.Platform]=true;
	browserType.v=browserType.version;
	browserType.valid=browserType.ie&&browserType.v>=6||browserType.mozilla&&browserType.v>=1.4;
	return browserType;
};

function setCommonspot()
{
	if (commonspot && !top.commonspot)
		top.commonspot = commonspot;
}

var last = function last() {
	return this[this.length - 1];
};

var each = function each(iterator) {
    for (var i = 0, length = this.length; i < length; i++)
      iterator(this[i]);
};

if (!Array.last)
{
	Array.prototype.last = last;
	Array.prototype.each = each;
}

if (typeof document.getElementsByClassName == 'undefined') 
{
	document.getElementsByClassName = function(searchClass,node,tag) {
		var classElements = new Array();
		if ( node == null )
			node = document;
		if ( tag == null )
			tag = '*';
		var els = node.getElementsByTagName(tag);
		var elsLen = els.length;
		var pattern = new RegExp("(^|\\s)"+searchClass+"(\\s|$)");
		for (i = 0, j = 0; i < elsLen; i++) {
			if ( pattern.test(els[i].className) ) {
			        classElements[j] = els[i];
			        j++;
			}
		}
		return classElements;
	};
}