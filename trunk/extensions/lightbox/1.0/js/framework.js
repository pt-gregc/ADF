/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	framework.js
Summary:
	ADF Lightbox Framework JavaScript
Version:
	1.0.0
History:
	2010-02-19 - MFC - Created
*/

// Set default variables
defaultWidth = 500;
defaultHeight = 500;

function initADFLB() {
	//alert("initADFLB");
	jQuery(".ADFLightbox").each(function(){
        var relValArray = processRel(jQuery(this).attr("rel"));
      	// Unbind any click actions before resetting the binding events
      	jQuery(this).unbind('click');
      	
      	// Bind a click to each instance on this page
        jQuery(this).click(function () { 
        	// Check if the commonspot OR lightbox space has been built
        	if ( (typeof commonspot == 'undefined') || (typeof commonspot.lightbox == 'undefined') )
        		parent.commonspot.lightbox.openDialog(relValArray[0]);
        	else
        		commonspot.lightbox.openDialog(relValArray[0]);
        });
     });
}

/*	
 *	Returns Array of the Rel URL and Width
 *		retVals[0] = URL
 *		retVals[1] = width
 */ 
function processRel(relParam) {
	// Split the full url to get the values
	var urlStr = relParam.split("?");
	var urlVal = urlStr[0];
	// Split the url params and get the value for width
	var urlParams = urlStr[1].split("&");
	
	// Set a default width
	var width = defaultWidth;
	
	// Loop over the params
	for (i = 0; i <= (urlParams.length - 1); i = i + 1)
	{
		// Split the current param
		var urlParamVal = urlParams[i].split("=");
		// Check if this is the width
		if ( urlParamVal[0] == 'width' )
		{
			// Set the width variable
			width = urlParamVal[1];
			
			// Set the i value to the urlParams length to break the loop
			i = urlParams.length;
		}
	}
	
	// Set the return Array
	//var retVals = new Array(urlVal, width);
	var retVals = new Array(relParam, width);
	return retVals;
}

// Close the lightbox layer
function closeLB(){
	// Check if the commonspot OR lightbox space has been built
	if ( (typeof commonspot == 'undefined') || (typeof commonspot.lightbox == 'undefined') )
		parent.commonspot.lightbox.closeCurrent();
	else
		commonspot.lightbox.closeCurrent();
}

// Open the lightbox layer based on URL and set the width and height
function openLB(url) {
	// Check if the commonspot OR lightbox space has been built
	if ( (typeof commonspot == 'undefined') || (typeof commonspot.lightbox == 'undefined') )
		parent.commonspot.lightbox.openDialog(url);
	else
		commonspot.lightbox.openDialog(url);
}

// Close the current lightbox and open a new lightbox, thus replacing the current lightbox
// Calls the window.parent to run the actions
//	This allows to just call "replaceLB(...)" in the current pages code
function replaceLB(url){
	window.parent.parentReplaceLB(url);
}
// Close the current lightbox and open a new lightbox, thus replacing the current lightbox
function parentReplaceLB(url){
	closeLB();
	openLB(url);
}

// Calls a JS function loaded from the parent window
function getCallback(cbFunct, inArgsArray) {
	// Check if window.parent is defined,
	//	then call the load callback function
	//if ( typeof(window.parent) != 'undefined' )
	//	window.parent.loadCallback(cbFunct, inArgsArray);
	//else
		loadCallback(cbFunct, inArgsArray);	
}

// Loads the JS call back function defined in the params
function loadCallback(cbFunct, inArgsArray){
	//alert("callback -> CBFunct = " + cbFunct);
	
	// Check that we have a callback function defined
	if ( cbFunct.length > 0 ){
	
		// Get the lightbox stack count then decrement by 2 to get the parent lb level
		callBackLevel = commonspot.lightbox.stack.length - 2;
		//alert("callBackLevel = " + callBackLevel);
		
		if ( callBackLevel >= 0 ) {
		
			// Get the current LB's parent LB object and set the parent LB iframe name
			//console.dir(commonspot.lightbox.stack[callBackLevel]);
			parentIFrameName = commonspot.lightbox.stack[callBackLevel].frameName;
			//alert("parentIFrameName = " + parentIFrameName);
			
			// Check if the inArgs Array is defined, 
			//	if not then initialize it so we can pass it to the function 
			if ( typeof(inArgsArray) == 'undefined' ){	
				inArgsArray = new Array();
			}
			//alert("inArgsArray = " + inArgsArray);
			
			// Evaluate the iframe by Name and run the callback function
			//console.dir(document.getElementsByName(parentIFrameName));
			// Build the function document JS path
			functPath = "top.document.getElementsByName(parentIFrameName)[0].contentWindow." + cbFunct;
		}
		else {
			//alert("need to get the parent!");
			
			// Check if the 'page_frame' iframe exists,
			//	this means we are in CS 6 LView
			if ( typeof(top.document.getElementsByName('page_frame')[0]) != 'undefined' )
			{
				// FOR CS 6 when in LView
				functPath = "top.document.getElementsByName('page_frame')[0].contentWindow." + cbFunct;
			}
			else
			{
				// FOR CS 5 and CS 6 when NOT in LView
				// Build the function back to the TOP of this window
				functPath = "top." + cbFunct;
			}
			alert("functPath = " + functPath);
		}
		
		// Verify that the function exists
		if ( typeof(eval(functPath)) != 'undefined' ){
			// Evaluate the iframe by Name and run the callback function
			eval(functPath + "(inArgsArray)");
		}
	}	
}

// Close the current lightbox and refresh its parent lightbox
function closeLBReloadParent(){
	// Check if the commonspot OR lightbox space has been built
	if ( (typeof commonspot == 'undefined') || (typeof commonspot.lightbox == 'undefined') )
		parent.commonspot.lightbox.closeCurrentWithReload();
	else
		commonspot.lightbox.closeCurrentWithReload();
}


/*
 *	loadUtilDom function - Loads in the Commonspot.util.dom space for CS 5.
 *							This exists already in CS 6.
 *	
 */
function loadUtilDom(){

	// Check that "commonspot.util" does not exist and we don't have "dom" variable
	if ( (typeof commonspot.util == 'undefined') || (typeof commonspot.util.dom == 'undefined') )
	{
		/**
		 * commonspot.util.dom: package for dom-related utilities
		 */
		commonspot.util.dom = {};
		
		/**
		 * commonspot.util.dom.getWinScrollSize: returns actual content size of given window; 
		 * @param win (object): window object. if not supplied returns value for current window
		 * @return {width, height}
		 */	
		commonspot.util.dom.getWinScrollSize = function()
		{
			var sWidth=0, sHeight=0;
			var winSize = commonspot.util.dom.getWinSize();
			var win = self;
			if (win.document.body.clientHeight)
			{
				sHeight = win.document.body.clientHeight;
				sWidth = win.document.body.clientWidth;
			}	
			else if (win.document.height)
			{
				sHeight = win.document.height;
				sWidth = win.document.width;
			}
			return {width: Math.max(sWidth,winSize.width), height: Math.max(sHeight,winSize.height)};
		};
		
		/**
		 * commonspot.util.dom.getWinSize: returns inner size of current window; from PPK
		 * @return {width, height}
		 */
		commonspot.util.dom.getWinSize = function()
		{
			var width, height;
			if (self.innerHeight) // all except Explorer
			{
				width = self.innerWidth;
				height = self.innerHeight;
			}
			else if (document.documentElement && document.documentElement.clientHeight) // Explorer 6 Strict Mode
			{
				width = document.documentElement.clientWidth;
				height = document.documentElement.clientHeight;
			}
			else if (document.body) // other Explorers
			{
				width = document.body.clientWidth;
				height = document.body.clientHeight;
			}
			return {width: width, height: height};
		};
		
		/**
		 * removes all child nodes from passed obj
		 * needed because IE won't directly set innerHTML of some tags
		 * 
		 * @param obj (object): object to remove all children from
		 */
		commonspot.util.dom.removeAllChildren = function(obj)
		{
			while(obj.firstChild)
				obj.removeChild(obj.firstChild);
		};
		
		/**
		 * finds tag w requested name further up in dom hierarchy from passed obj
		 * 
		 * @param obj (dom node): object to find an ancestor of
		 * @param tagName (string): tag name to find
		 * 	not case sensitive
		 * 	won't find body or anything above there; those are singletons w simpler ways to find them
		 * @param level (int, optional): if passed, return level'th matching ancestor, not just first one
		 */
		commonspot.util.dom.getAncestorTag = function(obj, tagName, level)
		{
			if(!obj || !obj.parentNode)
				return null;
				
			tagName = tagName.toUpperCase();
			if(typeof level == 'undefined')
				level = 1;
			
			var tag = obj.parentNode;
			var curLevel = 0;
			
			while((tag.nodeName != tagName || curLevel < level) && tag.parentNode && tag.parentNode.nodeName != 'BODY')
			{
				tag = tag.parentNode;
				if(tag.nodeName == tagName)
					curLevel++;
			}
			
			if(tag.nodeName != tagName || curLevel < level)
				tag = null;
			return tag;
		};
		
		/**
		 * returns elements w passed className inside element w passed id.
		 * homegrown because Prototype 1.5's getElementsBySelector seems broken in IE7.
		 * @param id (string): id of element to look inside
		 * @param className (string): className to look for
		 * @param tagName (string, optional): if passed, looks only at tags w this name 
		 * @param getAll (boolean, optional): if true, return array of all found elements, otherwise, return first one
		 */
		commonspot.util.dom.getChildrenByClassName = function(id, className, tagName, getAll)
		{
			var results = [];
			var classMatchRegex = new RegExp("(^|\\s)" + className + "(\\s|$)");
			var tags = document.getElementById(id).getElementsByTagName(tagName || '*');
			for(var i = 0; i < tags.length; i++)
			{
				if(tags[i].className == className || tags[i].className.match(classMatchRegex))
				{
					if(getAll)
						results.push(tags[i]);
					else
						return tags[i];
				}
			}
			return results;
		};
	}
}
