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
	if ( typeof(window.parent) != 'undefined' )
		window.parent.loadCallback(cbFunct, inArgsArray);
	else
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
		functPath = "document.getElementsByName(parentIFrameName)[0].contentWindow." + cbFunct;
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

