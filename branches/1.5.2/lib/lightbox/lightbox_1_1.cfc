<!--- 
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
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	lightbox_1_1.cfc
Summary:
	Lightbox functions for the ADF Library
Version
	1.1
History:
	2012-01-30 - MFC - Created
--->
<cfcomponent displayname="lightbox" extends="ADF.lib.lightbox.lightbox_1_0" hint="Lightbox functions for the ADF Library">
	
<cfproperty name="version" value="1_1_2">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_1">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="lightbox_1_1">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadADFLightbox
Summary:
	Loads the ADF lightbox framework to the page.
Returns:
	string
Arguments:
	Void
History:
	2012-01-30 - MFC - Created
	2012-02-01 - MFC - Replaced all single quotes in script tags with double quotes.
						Added cfouput around the loading script for 2.0.
	2012-02-03 - MFC - Rearchitected commonspot.lightbox loading process for CS 7.0.
--->
<cffunction name="loadADFLightbox" access="public" returntype="string" output="true" hint="Loads the ADF Lightbox Framework into the page.">
	
	<cfscript>
		var outputHTML = "";
		
		// Check if we have LB properties
		// Default Title
		if ( NOT StructKeyExists(request.params, "title") )
			request.params.title = "";

		// Default Subtitle
		if ( NOT StructKeyExists(request.params, "subtitle") )
			request.params.subtitle = "";
		
		// Default Width
		if ( NOT StructKeyExists(request.params, "width") )
			request.params.width = 500;

		// Default Height
		if ( NOT StructKeyExists(request.params, "height") )
			request.params.height = 500;
	</cfscript>

	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<!-- ADF Lightbox Framework Loaded @ #now()# -->
			<!--- Load lightbox override styles --->
			<cfif application.ADF.csVersion GTE 6.1>
				<link href="/ADF/extensions/lightbox/1.0/css/lightbox_overrides_6_1.css" rel="stylesheet" type="text/css">
			<cfelse>
		    	<link href="/ADF/extensions/lightbox/1.0/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
			</cfif>
		</cfoutput>
		<!--- Load the CommonSpot Lightbox when not in version 6.0 --->
		<cfif application.ADF.csVersion LT 6>
			<cfoutput>
				<!--- Load the Lightbox Framework for CS 5.x --->
				#loadLighboxCS5()#
			</cfoutput>
		<cfelse>
			<cfoutput>
				<script type="text/javascript" src="/ADF/extensions/lightbox/2.0/js/framework.js"></script>	
			</cfoutput>
		</cfif>
		<cfoutput>
			
			<!--- 
			<!--- NEW SOLUTION 2 --->
			<script type="text/javascript">
				
				if (top.commonspot && top.commonspot.lightbox) 
					var commonspot = top.commonspot;
				else if (parent.commonspot && parent.commonspot.lightbox)
					var commonspot = parent.commonspot;
				else
					loadNonDashboardFiles();
				
				
				jQuery(document).ready(function(){
					/*
						Set the Jquery to initialize the ADF Lightbox
					*/
					initADFLB();
					
					//commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
				});
			</script>
			 --->
			
			<!--- 
			<!--- SOLUTION 1 --->
			<!--- Creates the "commonspot" JS variable space --->
			<script type="text/javascript" src="/commonspot/javascript/lightbox/lightbox.js"></script>
			<!--- Need this for when NOT in CS Mode --->
			<script type="text/javascript" src="/commonspot/javascript/browser-all.js"></script>
			<script type="text/javascript" src="/commonspot/javascript/util.js"></script>
			<link rel="stylesheet" type="text/css" href="/commonspot/dashboard/css/buttons.css"></link>
			<link rel="stylesheet" type="text/css" href="/commonspot/javascript/lightbox/lightbox.css"></link>
			<script type="text/javascript" src="/commonspot/javascript/lightbox/lightbox.js"></script>
			<script type="text/javascript" src="/commonspot/javascript/lightbox/overrides.js"></script>
			<script type="text/javascript" src="/commonspot/javascript/lightbox/window_ref.js"></script>
			<script type="text/javascript">
				jQuery(document).ready(function(){
					/*
						Set the Jquery to initialize the ADF Lightbox
					*/
					initADFLB();
				});
			</script>
			 --->
			
			<!--- SOLUTION 3 --->
			<script type="text/javascript">
				 
				if (top.commonspot && top.commonspot.lightbox) 
					var commonspot = top.commonspot;
				else if (parent.commonspot && parent.commonspot.lightbox)
					var commonspot = parent.commonspot;
				
				jQuery(document).ready(function(){
					/*
						Set the Jquery to initialize the ADF Lightbox
					*/
					initADFLB();
				});
			</script>
			<!--- Need this for when NOT in CS Mode --->
			<script type="text/javascript" src="/commonspot/javascript/browser-all.js"></script>
			
			
			
			
			<!--- Need this for when NOT in CS Mode --->
			<!--- <script type="text/javascript" src="/commonspot/javascript/browser-all.js"></script>
			<script>
				console.log(top.commonspot.lightbox);
				console.log(parent.commonspot.lightbox);
			</script>
			
			<script type="text/javascript">
				/* if (top.commonspot && top.commonspot.lightbox) 
					var commonspot = top.commonspot;
				else if (parent.commonspot && parent.commonspot.lightbox)
					var commonspot = parent.commonspot;
				else  */
				//	loadNonDashboardFiles();
			</script> --->
			
			
			
			<!--- 
			<script>
			//console.log(commonspot.lightbox);
			</script>
			<!--- Creates the "commonspot" JS variable space --->
			<script type="text/javascript" src="/commonspot/javascript/lightbox/lightbox.js"></script>
			
			<!--- Need this for when NOT in CS Mode --->
			<script type="text/javascript" src="/commonspot/javascript/browser-all.js"></script>
			
			<script type="text/javascript" src="/commonspot/javascript/util.js"></script>
			<link rel="stylesheet" type="text/css" href="/commonspot/dashboard/css/buttons.css"></link>
			<link rel="stylesheet" type="text/css" href="/commonspot/javascript/lightbox/lightbox.css"></link>
			<script type="text/javascript" src="/commonspot/javascript/lightbox/lightbox.js"></script>
			<script type="text/javascript" src="/commonspot/javascript/lightbox/overrides.js"></script>
			<script type="text/javascript" src="/commonspot/javascript/lightbox/window_ref.js"></script>
			
			<script>
			//console.log(commonspot.lightbox);
			</script>
				 --->
			<!--- <script type="text/javascript">
				// make sure we're in the dashboard frame
				/* if(!parent || !parent.commonspot)
				{
					alert('This page is part of the CommonSpot dashboard.\n\nTaking you there now...');
					document.location.href = '/commonspot/dashboard/index.html' + document.location.hash;
				}
	
				// get local references to objects we need in parent frame
				// commonspot object has state, so we need that instance; others are static, but why load them again
				var commonspot = parent.commonspot;
				 */
				
				/* if(parent && parent.commonspot){
					// get local references to objects we need in parent frame
					// commonspot object has state, so we need that instance; others are static, but why load them again
					var commonspot = parent.commonspot;
				} */
				
			</script>
			<script type="text/javascript">
				
											
				// get local references to objects we need in parent frame
				// commonspot object has state, so we need that instance; others are static, but why load them again
				/* if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) {
					if(parent && parent.commonspot) {
						var commonspot = parent.commonspot;
					}
				} */
				
				/* if(parent && parent.commonspot) {
					var commonspot = parent.commonspot;
				} */
				
				
				/* if (typeof commonspot == 'undefined' || !commonspot.lightbox){	
					if ( typeof parent.commonspot != 'undefined' ){
						var commonspot = parent.commonspot;
					}
					else if ( typeof top.commonspot != 'undefined' ){
						var commonspot = top.commonspot;
					}
					else {
						loadNonDashboardFiles();
					}
				} */
				
				//var commonspot = top.commonspot;
				
				//console.log(top.commonspot);
				//console.log(parent.commonspot);
				//var commonspot = top.commonspot;
				
				// Run check for if commonspot.lightbox is defined yet
				//if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) {
					
					/* var defaultOptions =
					{
						title: "#request.params.title#",
						subtitle: "#request.params.subtitle#",
						helpId: "",
						width: 100,
						name: 'customDlg',
						height: 50,
						hasMaximizeIcon: true,
						hasCloseIcon: true,
						hasHelpIcon: false,
						hasReloadIcon: true,
						url: "/commonspot/dashboard/dialogs/blank-dialog.html",
						dialogType: "dialog"
					};	
					commonspot.lightbox.openURL(defaultOptions); */			
					
					//commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
					//commonspot.lightbox.initCurrent(defaultOptions.width, defaultOptions.height, {title: options.title, subtitle: options.subtitle, reload: options.hasReloadIcon, helpId: options.helpId, maximize: options.hasMaximizeIcon}); 
				
				//}
				
				//var commonspot = top.commonspot;
				
				jQuery(document).ready(function(){
					/*
						Set the Jquery to initialize the ADF Lightbox
					*/
					initADFLB();
					
					/* if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) {
						commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
					}  */
				});
			</script> --->
		</cfoutput>
	</cfsavecontent>
	<cfreturn outputHTML>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadLighboxCS5
Summary:
	Loads the lightbox framework for CommonSpot v5.x
Returns:
	string
Arguments:
	Void
History:
	2012-01-30 - MFC - Created
	2012-02-01 - MFC - Replaced all single quotes in script tags with double quotes.
--->
<cffunction name="loadLighboxCS5" access="private" returntype="string" output="true">

	<cfscript>
		// Initialize the variables
		var retHTML = "";
	</cfscript>
	<cfsavecontent variable="retHTML">
		<cfscript>
			// Default Width
			if ( NOT StructKeyExists(request.params, "width") )
				request.params.width = 500;
	
			// Default Height
			if ( NOT StructKeyExists(request.params, "height") )
				request.params.height = 500;
		</cfscript>
		
		<!--- Load the CommonSpot 6.0 Lightbox Framework --->
		<cfoutput>
			<script type="text/javascript" src="/ADF/extensions/lightbox/1.0/js/framework.js"></script>					
			<script type="text/javascript" src="/ADF/extensions/lightbox/1.0/js/browser-all.js"></script>
			
			<!--- Setup the CommonSpot 6.0 Lightbox framework --->
			<script type="text/javascript">	
				if ((typeof commonspot == 'undefined' || !commonspot.lightbox) && (!top.commonspot || !top.commonspot.lightbox))
					loadNonDashboardFiles();
				else if ( typeof parent.commonspot != 'undefined' ){
					var commonspot = parent.commonspot;
				}
				else if ( typeof top.commonspot != 'undefined' ){
					var commonspot = top.commonspot;
				}
				
				/*
				 Loads in the Commonspot.util space for CS 5. This exists already in CS 6.
				 
	   			 Check if the commonspot.util.dom space exists,
					If none, then build this from the Lightbox Util.js
				*/
				if ( (typeof commonspot.util == 'undefined') || (typeof commonspot.util.dom == 'undefined') )
				{
					IncludeJs('/ADF/extensions/lightbox/1.0/js/util.js', 'script');
				}
	   		</script>
			
			<!--- Load the CS5 Resize override functions --->
			<script type="text/javascript" src="/ADF/extensions/lightbox/1.0/js/cs5-overrides.js"></script>
		</cfoutput>
		
	</cfsavecontent>
	<cfreturn retHTML>
</cffunction>

</cfcomponent>