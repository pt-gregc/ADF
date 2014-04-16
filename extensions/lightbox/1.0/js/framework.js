/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	1.0.3
History:
	2010-02-19 - MFC - Created
	2010-08-26 - MFC - Updated processRel function to not force the "addMainTable" parameter.
	2010-12-21 - MFC - Updated loadCallback function to look in the current lightbox window
						for the callback function.
	2010-12-23 - MFC - Updated loadCallback function to loop over the level of lightbox windows
						to locate the callback function.
	2012-04-10 - MFC - Updated "loadCallback" function to set the commonspot.lightbox variable
						from the "commonspot" or "top.commonspot" variables.
	2012-10-17 - GAC - Updated the "replaceLB" function to work with commonspot v6.2+ lightbox
						windows and the opener page is in or out of the LView.
	2013-02-06 - MFC - Removed JS 'alert' commands for CS 8.0.1 and CS 9 compatibility
	2013-01-03 - GAC - Added missing semi-colons to the ends of variablized functions
*/

// Set default variables
defaultWidth = 500;
defaultHeight = 500;

function initADFLB() {
	jQuery(".ADFLightbox").each(function(){

      // Unbind any click actions before resetting the binding events
		jQuery(this).unbind('click');

		// Bind a click to each instance on this page
		jQuery(this).click(function () {
			var lightboxURL = processRel(jQuery(this).attr("rel"));
			// Check if the commonspot OR lightbox space has been built
			if ( (typeof commonspot == 'undefined') || (typeof commonspot.lightbox == 'undefined') ){
				parent.commonspot.lightbox.openDialog(lightboxURL);
			}else{
				commonspot.lightbox.openDialog(lightboxURL);
			}
		});
   });
}

/*
 * Returns the value of the rel="" tag with
 * additional parameters added to handle lightbox resizing
 * 2011-02-02 - RAK - Added replacing of ajaxProxy.cfm to lightboxProxy.cfm
 */
function processRel(relParam) {
	var newURL = relParam;
	newURL = newURL.replace(/ajaxProxy.cfm/i, "lightboxProxy.cfm");
	// Split the full url to see if there are parameters
	var urlArray = newURL.split("?");
	// create array of new parameters to be added
	//var addParam = [ 'addMainTable=1' ]
	var addParam = [ ];
	
	var initDelim = "?";
	// if there were URL parameters then there is already a ? so change the initial delimiter
	if( urlArray.length > 1 )
		initDelim = "&";
	for( var i=0; i < addParam.length; i++ ){
		if(i == 0)
			newURL = newURL + initDelim + addParam[i];
		else
			newURL = newURL + "&" + addParam[i];
	}
	return newURL;
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
// 2011-02-02 - RAK - Added replacing of ajaxProxy.cfm to lightboxProxy.cfm
function openLB(url) {
	url = url.replace(/ajaxProxy.cfm/i, "lightboxProxy.cfm");
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
	// Check to see if the lightbox we are replacing is opened on top of the LView iFrame
	var csLViewIFrameID = 'page_frame';
	var csIFrameObj = window.parent.document.getElementById(csLViewIFrameID);
	if ( csIFrameObj != null && csIFrameObj.contentWindow != 'undefined'){
		window.parent.document.getElementById('page_frame').contentWindow.parentReplaceLB(url);
	}
	else {
		window.parent.parentReplaceLB(url);
	}
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
	var i=0;
	var callBackLevel = 0;
	var lbFrame = "";
	var functPath = "";
	
	// Check that we have a callback function defined
	if ( cbFunct.length > 0 ){
		
		// Check if the JS commonspot lightbox exists
		if ( typeof commonspot != 'undefined' && typeof commonspot.lightbox != 'undefined' )
			csLbObj = commonspot.lightbox;
		else
			csLbObj = top.commonspot.lightbox;
	
		for (i=csLbObj.stack.length-1; i >= -1; i--) {
			
			callBackLevel = i;
			
			if ( callBackLevel >= 0 ) {
		
				// Get the current level LB frame
				lbFrame = csLbObj.stack[callBackLevel].frameName;
				
				// Build the function document JS path
				functPath = "top.document.getElementsByName(lbFrame)[0].contentWindow." + cbFunct;
			}
			else {
				// Find if the CB function is not in a lightbox page
				
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
			}
			
			// Verify that the callback function exists in this level
			if ( typeof(eval(functPath)) != 'undefined' ){
				// Evaluate the iframe by Name and run the callback function
				eval(functPath + "(inArgsArray)");
				// Get out of the loop
				i = -2;
			}
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

// Custom ResizeWindow function to resolve problems with the
// 	lightbox framework in CS 5.  
// CS 5 also uses the 'ResizeWindow' function to resize the window dialogs.
// A new custom resize function needs to be implemented. 
// If the user is runnin in CS 5, this function is overrided by loading the
//	cs5-overrides.js to replace this function with the lightbox resize code.
lbResizeWindow = function()
{
	// We are in CS 6 so resize the LB normally
	ResizeWindow();
};
