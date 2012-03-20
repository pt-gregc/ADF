/* 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	2.0.1
History:
	2012-01-30 - MFC - Created new version 2.0.1 based on LB v1
*/

function initADFLB() {
	//alert("initADFLB");
	var lightboxURL = "";
	jQuery(".ADFLightbox").each(function(){
		// Unbind any click actions before resetting the binding events
		jQuery(this).unbind('click');
		
		// Bind a click to each instance on this page
		jQuery(this).click(function () {
			lightboxURL = processRel(jQuery(this).attr("rel"));
			// Call the function to open the LB
			openLB(lightboxURL);
		});
   });
}

// Open the lightbox dialog
function openLB(lbUrl) {
	var newLBUrl = processRel(lbUrl);
	//var newLBUrl = lbUrl;
	// Call the function to open the LB
	
	/*
	newWindow(name="", 
					url=newLBUrl, 
					customOverlayMsg="", 
					openInWindow=false,
					windowProps="maximize=1,hideHelp=1");
	*/
	
	// TODO - Add in the URL params for the fields for title, width, & height
	/*
	commonspot.lightbox.openURL(
		{	url: newLBUrl,
			title:'', 
			subtitle: '', 
			hasCloseIcon: true, 
			hasMaximizeIcon: true, 
			width: 500, 
			height: 500
		}
	);
	*/
	
	commonspot.lightbox.openDialog(
			url=newLBUrl, 
			hideClose=0, 
			name='test', 
			customOverlayMsg='', 
			dialogType='', 
			opener='', 
			hideHelp=1, 
			hideReload=0);
	
	
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

// Close the current lightbox and open a new lightbox, thus replacing the current lightbox
// Calls the window.parent to run the actions
//	This allows to just call "replaceLB(...)" in the current pages code
function replaceLB(url){
	parentReplaceLB(url);
}

// Close the current lightbox and open a new lightbox, thus replacing the current lightbox
function parentReplaceLB(url){
	closeLB();
	openLB(url);
}

// Calls a JS function loaded from the parent window
function getCallback(cbFunct, inArgsArray) {
	//alert("getCallback");
	loadCallback(cbFunct, inArgsArray);	
}

// Loads the JS call back function defined in the params
function loadCallback(cbFunct, inArgsArray){
	//alert("callback -> CBFunct = " + cbFunct);
	var i=0;
	var callBackLevel = 0;
	var lbFrame = "";
	var functPath = "";
	
	// Check that we have a callback function defined
	if ( cbFunct.length > 0 ){
		
		// Loop over all the Lightbox levels to find the CB function
		for (i=commonspot.lightbox.stack.length-1; i >= -1; i--) {	
			callBackLevel = i;
			//alert("callBackLevel = " + callBackLevel);
			
			if ( callBackLevel >= 0 ) {
		
				// Get the current level LB frame
				lbFrame = commonspot.lightbox.stack[callBackLevel].frameName;
				//alert("lbFrame = " + lbFrame);
			
				// Build the function document JS path
				functPath = "top.document.getElementsByName(lbFrame)[0].contentWindow." + cbFunct;
				//alert("functPath = " + functPath);
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
			//alert("functPath = " + functPath);
			
			// Verify that the callback function exists in this level
			if ( typeof(eval(functPath)) != 'undefined' ){
				// Evaluate the iframe by Name and run the callback function
				eval(functPath + "(inArgsArray)");
				// Get out of the loop
				//i = -2;
			}
		}
	}	
}

// Close the current lightbox and refresh its parent lightbox
function closeLBReloadParent(){
	//alert("closeLBReloadParent");
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
}
