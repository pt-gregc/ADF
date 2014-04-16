<!--- 
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
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	scripts_1_1.cfc
Summary:
	Scripts functions for the ADF Library
Version:
	1.1
History:
	2010-10-04 - RAK - Created - New v1.1
						Made massive revisons to script loading everything now goes 
						through one central script loader. Every single function was modified.
	2011-06-24 - GAC - Removed a misplaced double </cfcomponent> end tag
	2012-02-15 - MTT - Re-ordered the functions by name - ascending. This makes it easier to easily find the function you 
						want or want to add. 
	2012-08-16 - GAC - Added the force parameter to all the functions that did not already have it
	2012-12-07 - MFC - Moved new functions to Scripts v1.2.
--->
<cfcomponent displayname="scripts_1_1" extends="ADF.lib.scripts.scripts_1_0" hint="Scripts functions for the ADF Library">
	
<cfproperty name="version" value="1_1_21">
<cfproperty name="scriptsService" injectedBean="scriptsService_1_1" type="dependency">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Scripts_1_1">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$jQueryUIButtonClass
Summary:	
	Returns the classes required to make a button act like a jQueryUI button
Returns:
	String class
Arguments:
	Void
History:
 2009-10-15 - RLW - Created
--->
<cffunction name="jQueryUIButtonClass" access="public" returntype="string" hint="Returns the classes required to make a button act like a jQueryUI button">
	<cfreturn "ui-button ui-state-default ui-corner-all">
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadADFLightbox
Summary:
	ADF Lightbox Framework for the ADF Library
Returns:
	None
Arguments:
	String - version - ADF Lightbox version to load
	Boolean - Force
History:
	2009-10-27 - MFC - Created
	2009-11-17 - RLW - Updated to set dynamic ajaxProxy
	2010-02-19 - MFC - Updated the CS 6.0 lightbox framework
	2010-03-01 - MFC - Added IF block to load the browse-all.js in CS 6.0 if not in a CS page.
	2010-04-30 - MFC - Updated the Lightbox framework to resolve issues.
	2010-12-21 - MFC - Updated the codes for HTML and scripts.
						Commented IF condition for loading the "commonspot/javascript/browser-all.js" link.
	2011-04-08 - RAK - Added includes to 6.1 overrides if this is in fact 6.1 or greater.
	2011-07-14 - MFC - Run check for if commonspot.lightbox is defined yet
	2012-04-09 - MFC - Rolled back updates for Lightbox with CS 7 and 6.2.
						Added conditions for CS 7 and 6.2 lightbox handling.
	2013-05-07 - MFC - Changed the "lightbox_overrides" CSS file names for the file to load for CS versions
						less than 6.1 is called "lightbox_overrides_legacy".
--->
<cffunction name="loadADFLightbox" access="public" output="true" returntype="void" hint="ADF Lightbox Framework for the ADF Library">
	<cfargument name="version" type="string" required="false" default="1.0" hint="ADF Lightbox version to load">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfoutput>
		#LoadJQuery(force=arguments.force)#
		<!-- ADF Lightbox Framework Loaded @ #now()# -->
	</cfoutput>
	<!--- Check if we have LB properties --->
	<cfscript>
		// Default Width
		if ( NOT StructKeyExists(request.params, "width") )
			request.params.width = 500;

		// Default Height
		if ( NOT StructKeyExists(request.params, "height") )
			request.params.height = 500;

		// Default Title
		if ( NOT StructKeyExists(request.params, "title") )
			request.params.title = "";

		// Default Subtitle
		if ( NOT StructKeyExists(request.params, "subtitle") )
			request.params.subtitle = "";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/extensions/lightbox/#arguments.version#/js/framework.js'></script>
			<!--- Load lightbox override styles --->
			<cfif application.ADF.csVersion GTE 6.1>
				<link href="/ADF/extensions/lightbox/#arguments.version#/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
			<cfelse>
				<link href="/ADF/extensions/lightbox/#arguments.version#/css/lightbox_overrides_legacy.css" rel="stylesheet" type="text/css">
			</cfif>
		</cfoutput>
			<!--- Load the CommonSpot Lightbox when not in version 6.0 --->
			<cfif application.ADF.csVersion LT 6 >
				<!--- Load the CommonSpot 6.0 Lightbox Framework --->
				<cfoutput>
				<script type='text/javascript' src='/ADF/extensions/lightbox/#arguments.version#/js/browser-all.js'></script>
				
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
				<script type='text/javascript' src='/ADF/extensions/lightbox/#arguments.version#/js/cs5-overrides.js'></script>
				</cfoutput>
			<cfelseif application.ADF.csVersion GTE 6 AND application.ADF.csVersion LT 6.1>
				<cfoutput>
					<!--- Load lightbox override styles --->
					<!--- Check if the request page exists for if we are on a CS page --->
					<!--- <cfif NOT StructKeyExists(request, "page")> --->
						<!--- Load the CommonSpot 6.0 Lightbox Framework --->
						<script type='text/javascript' src='/commonspot/javascript/browser-all.js'></script>
					<!--- </cfif> --->

					<!--- Setup the CommonSpot 6.0 Lightbox framework --->
					<!--- <cfinclude template="/commonspot/non-dashboard-include.cfm"> --->
					<script type="text/javascript">
						if (typeof commonspot == 'undefined' || !commonspot.lightbox){	
							if ( typeof parent.commonspot != 'undefined' ){
								var commonspot = parent.commonspot;
							}
							else if ( typeof top.commonspot != 'undefined' ){
								var commonspot = top.commonspot;
							}
							else {
								loadNonDashboardFiles();
							}
						}
						if (parent.commonspot && typeof newWindow == 'undefined'){
							var arrFiles = [
										{fileName: '/commonspot/javascript/lightbox/overrides.js', fileType: 'script', fileID: null},
										{fileName: '/commonspot/javascript/lightbox/window_ref.js', fileType: 'script', fileID: null}
									];
							loadDashboardFiles(arrFiles);
						}	
					</script>
					<!--- Load this CSS for when in CS 7 and IE mode --->
					<link rel="stylesheet" type="text/css" href="/commonspot/javascript/lightbox/lightbox.css"></link>
					<link rel="stylesheet" type="text/css" href="/commonspot/dashboard/css/buttons.css"></link>
				</cfoutput>
			<cfelseif application.ADF.csVersion GTE 6.2>
				<!--- Load this CSS for when in CS 7 and 6.2 and IE mode --->
				<link rel="stylesheet" type="text/css" href="/commonspot/javascript/lightbox/lightbox.css"></link>
				<link rel="stylesheet" type="text/css" href="/commonspot/dashboard/css/buttons.css"></link>
			</cfif>
			<cfoutput>
			<script type="text/javascript">
				jQuery(document).ready(function(){
					/*
						Set the Jquery to initialize the ADF Lightbox
					*/
					initADFLB();
					
					/*
						get local references to objects we need in parent frame
						commonspot object has state, so we need that instance; others are static, but why load them again
						var commonspot = parent.commonspot;
					*/
					// Run check for if commonspot.lightbox is defined yet
					if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) {
						commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
					}
				});
			</script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("ADFLightbox",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadADFStyles
Summary:	
	Loads the generic ADF styles when needed
Returns:
	Void
Arguments:
	Boolean - Force
History:
	2009-05-28 - RLW - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadADFStyles" access="public" returntype="void">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/zstyle/ADF.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("ADFStyles",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadAutoGrow
Summary:
	Loads the AutoGrow Textarea jQuery Plug-in Headers if not loaded.
Returns:
	None
Arguments:
	String - version - AutoGrow version to load.
	Boolean - Force
History:
	2009-06-18 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadAutoGrow" access="public" output="true" returntype="void" hint="Loads the AutoGrow jQuery Plug-in Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.2.2" hint="AutoGrow version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/autogrow/autogrow-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("autogrow",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadCFJS
Summary:
	Loads the CFJS JQuery Plug-in Headers if not loaded.
	http://cjordan.us/index.cfm/CFJS
	Function Listing:
	http://cjordan.us/page.cfm/CFJS-function-listing-by-category
Returns:
	None
Arguments:
	String - version - CFJS version to load.
	Boolean - Force
History:
	2009-06-18 - GAC - Created
	2012-06-27 - MFC - Renamed the JS files to "jquery.cfjs-#version#.js".
						Set the default to v1.2.
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadCFJS" access="public" output="true" returntype="void" hint="Loads the CFJS jQuery Plug-in Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.2" hint="CFJS version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<!---  2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers. --->
	<cfset arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version)>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/cfjs/jquery.cfjs-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("cfjs",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadDropCurves
Summary:	
	Loads the Drop Curves plugin for jQuery
Returns:
	Void
Arguments:
	String - Version
	Boolean - Force
History:
 	2009-11-04 - MFC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadDropCurves" access="public" output="true" returntype="void" hint="Loads the Drop Curves plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="0.1.2" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/dropcurves/jquery.dropCurves-#arguments.version#.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("dropcurves",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$loadDynatree
Summary:
	Loads the Dynatree plugin
Returns:
	void
Arguments:
	Boolean - Force
History:
 	2011-09-09 - RAK - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadDynatree" access="public" returntype="void" hint="Loads the Dynatree plugin">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/dynatree/jquery-dynatree-1.1.1.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#loadJQuery(force=arguments.force)#
		#loadJQueryUI(force=arguments.force)#
		#loadJQueryCookie(force=arguments.force)#
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("dynatree",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadFileUploader
Summary:
	Loads the file upload javascript
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-11-21 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadFileUploader" access="public" output="true" returntype="void" hint="Loads the file uploader code.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/fileuploader/client/fileuploader.css">
			<script type="text/javascript" src="/ADF/thirdParty/jquery/fileuploader/client/fileuploader.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("fileUploader",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadGalleryView
Summary:
	Loads the JQuery GalleryView if not loaded.
Returns:
	None
Arguments:
	Numeric - version
	String - themeName
	Boolean - Force
History:
	2009-02-04 - MFC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadGalleryView" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="numeric" required="false" default="1.1" hint="">
	<cfargument name="themeName" type="string" required="false" default="light" hint="">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/galleryview/jquery-galleryview-#arguments.version#/jquery.galleryview-#arguments.version#-pack.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/galleryview/jquery-galleryview-#arguments.version#/jquery.timers-1.1.2.js'></script>
			<!--- render the css for 2.0 --->
			<cfif arguments.version NEQ "1.1">
				<link rel='stylesheet' href='/ADF/thirdParty/jquery/galleryview/jquery-galleryview-#arguments.version#/galleryview.css' type='text/css' media='screen' /> --->
			</cfif>
			<!--- Jquery easing --->
			<script type='text/javascript' src='/ADF/thirdParty/jquery/easing/jquery.easing.1.3.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("galleryview",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadJCarousel
Summary:
	Loads the JQuery JCarousel Headers if not loaded.
Returns:
	None
Arguments:
	Boolean - Force
History:
	2009-02-04 - MFC - Created
--->
<cffunction name="loadJCarousel" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="skinName" type="string" required="false" default="tango" hint="">
	<cfargument name="force" type="boolean" required="false" default="0" hint="">
	<cfargument name="version" type="string" required="false" default="2.2.4" hint="version to load - defaults to 2.2.4.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.pack.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.css' type='text/css' media='screen' />
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcarousel/skins/#arguments.skinName#/skin.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jcarousel",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadJCrop
Summary:	
	Loads the JQuery Crop Plugin
Returns:
	Void
Arguments:
	Boolean - Force
History:
 	2009-12-15 - MFC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJCrop" access="public" output="true" returntype="void" hint="Loads the JQuery Crop plugin"> 
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcrop/js/jquery.Jcrop.min.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcrop/css/jquery.Jcrop.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jquerycrop",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadJCycle
Summary:	
	Loads the jCycle plugin for jQuery
Returns:
	Void
Arguments:
	String - version
	Boolean - Force
History:
 	2009-10-20 - RLW - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJCycle" access="public" output="true" returntype="void" hint="Loads the jCycle plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="2.72" hint="jCycle version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcycle/jquery.cycle.all-#arguments.version#.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jcycle",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadJSONJS
Summary:
	Loads the JSON-JS scripts.
Returns:
	struct
Arguments:
	Boolean - Force
History:
	2012-02-23 - MFC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJSONJS" access="public" returntype="void" output="true">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/js/json-js/json2.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("json-js",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
	M. Carroll
Name:
	$loadJQuery
Summary:
	Loads the JQuery Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery version to load.
	Boolean - force - Forces JQuery script header to load.
	Boolean - noConflict - JQuery no conflict flag.
History:
	2009-07-20 - MFC - Created
	2009-11-11 - MFC - Update to force flag to not log the script loaded when forced.
	2010-08-26 - MFC - Updated to load 1.4 by default
	2011-01-19 - RAK - Updated to use findScript in scriptsService
	2011-06-29 - MFC - Force jQuery no conflict when in CS 6.2 or above.
	2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
					   Removed "Force jQuery no conflict" b/c not backwards compatiable with
							custom script code referencing "$". 
	2011-12-28 - MFC - Updated to load 1.7 by default.
--->
<cffunction name="loadJQuery" access="public" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.7" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="noConflict" type="boolean" required="false" default="0" hint="JQuery no conflict flag.">
	<cfscript>
		var outputHTML = "";
		var findScript = variables.scriptsService.findScript(arguments.version,"jquery","jquery-",".js");
		
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfif findScript.success>
		<cfsavecontent variable="outputHTML">
			<cfoutput>
				<script type="text/javascript" src="#findScript.message#"></script>
				<cfif arguments.noConflict>
					<!--- Put jQuery into a no conflict mode --->
					<script type="text/javascript">
						jQuery.noConflict();
					</script>
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfoutput>
			<cfif arguments.force>
				#outputHTML#
			<cfelse>
				#variables.scriptsService.renderScriptOnce("jQuery",outputHTML)#
			</cfif>
		</cfoutput>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadJQueryAutocomplete
Summary:	
	loads the autocomplete jQuery plugin
Returns:
	Void
Arguments:
	Boolean - Force
History:
 	2010-03-31 - RLW - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryAutocomplete" access="public" returntype="void">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/auto-complete/jquery.metadata.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js'></script>
			<link rel='stylesheet' type='text/css' href='/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.css' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryAutocomplete",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	S. Smith
Name:
	$loadjQueryBBQ
Summary:	
	Loads the BBQ plugin for jQuery
Returns:
	Void
Arguments:
	Boolean - Force
History:
 	2010-07-08 - SFS - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryBBQ" access="public" output="true" returntype="void" hint="Loads the BBQ plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="1.2.1" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/bbq/jquery.ba-bbq-#arguments.version#.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("bbq",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryBlockUI
Summary:
	Loads the JQuery BlockUI plugin which can be triggered to block ui during ajax call
Returns:
	None
Arguments:
	String - version - JQuery BlockUI version to load.
	Boolean - Force
History:
	2010-09-27 - RLW - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryBlockUI" access="public" output="true" returntype="void" hint="Loads the JQuery BlockUI plugin if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.35" hint="JQuery BlockUI plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/blockUI/jquery.blockUI-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryBlockUI",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
	G. Cronkright
Name:
	$loadJQueryCheckboxes
Summary:
	Loads the JQuery checkboxes Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery checkboxes version to load.
	Boolean - force - Forces JQuery checkboxes script header to load.
History:
	2010-03-04 - GAC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryCheckboxes" access="public" output="true" returntype="void" hint="Loads the JQuery checkboxes Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.1" hint="JQuery Checkboxes version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Checkboxes script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/checkboxes/jquery.checkboxes-#arguments.version#.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("checkboxes",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 	
	S. Smith
Name:
	$loadJQueryCookie
Summary:
	Loads the JQuery Cookie plugin if not loaded.
Returns:
	None
Arguments:
	Boolean - force - Forces JQuery Cookie script header to load.
History:
	2010-05-07 - SFS - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryCookie" access="public" output="true" returntype="void" hint="Loads the JQuery Cookie plugin if not loaded.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Cookie script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/cookie/jquery.cookie.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryCookie",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryDataTables
Summary:
	Loads the JQuery DataTables Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery DataTables version to load.
	Boolean - force - Forces JQuery DataTables script header to load.
History:
	2010-05-19 - MFC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2013-02-06 - MFC - Restructured the thirdparty folders & versions.
	2013-11-14 - DJM - Added a loadStyle parameter
--->
<cffunction name="loadJQueryDataTables" access="public" output="true" returntype="void" hint="Loads the JQuery DataTables Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.6" hint="JQuery DataTables version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery DataTables script header to load.">
	<cfargument name="loadStyles" type="boolean" required="false" default="true" hint="Boolean flag incicating if we need to load styles">
	<cfscript>
		var outputHTML = "";
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/datatables/#arguments.version#/js/jquery.dataTables.min.js"></script>
			<cfif arguments.loadStyles>
				<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/#arguments.version#/css/demo_page.css' type='text/css' media='screen' />
				<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/#arguments.version#/css/demo_table_jui.css' type='text/css' media='screen' />
				<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/#arguments.version#/css/demo_table.css' type='text/css' media='screen' />
				<!--- // Only available in v1.9 and up --->
				<cfif FileExists(expandPath("/ADF/thirdParty/jquery/datatables/#arguments.version#/css/jquery.dataTables.css"))>
					<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/#arguments.version#/css/jquery.dataTables.css' type='text/css' media='screen' />
				</cfif>
				<!--- // Only available in v1.9 and up --->
				<cfif FileExists(expandPath("/ADF/thirdParty/jquery/datatables/#arguments.version#/css/jquery.dataTables_themeroller.css"))>
					<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/#arguments.version#/css/jquery.dataTables_themeroller.css' type='text/css' media='screen' />
				</cfif>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryDataTables",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ryan kahn
Name:
	$loadJQueryDatePick
Summary:	
	Loads the DatePick plugin for jQuery
Returns:
	Void
Arguments:
	Boolean - Force
History:
 	2010-09-27 - RAK - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-01-24 - MFC - Replaced "@import" with "link" tag to load the CSS.
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryDatePick" access="public" output="true" returntype="void" hint="Loads the DatePick plugin for jQuery"> 
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	#loadJQuery(force=arguments.force)#
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/datepick/jquery.datepick.css' type='text/css' />
			<script type='text/javascript' src='/ADF/thirdParty/jquery/datepick/jquery.datepick.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("datePick",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryDoTimeout
Summary:
	Loads the doTimeout jQuery plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-06-22 - MTT - Created
	2011-07-20 - RAK - Added cfOutput to the code so that it will actually print the results
	2011-09-09 - RAK - Added cfoutput tags to the cfsavecontent
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryDoTimeout" access="public" output="true" returntype="void" hint="Loads the do timeout plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/dotimeout/jquery.dotimeout.plugin.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryDoTimeout",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryDump
Summary:
	Loads the dump jQuery plugin and necessary libraries
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-06-01 - MTT - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2011-09-09 - RAK - Added cfoutput tags to the cfsavecontent
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryDump" access="public" output="true" returntype="void" hint="Loads the dump plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/dump/jquery.dump.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryDump",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryFileUpload
Summary:
	Loads the file upload jQuery plugin
Returns:
	None
Arguments:
	None
History:
	2011-07-26 - MTT - Created
	2011-09-09 - RAK - Added cfoutput tags to the cfsavecontent
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryFileUpload" access="public" output="true" returntype="void" hint="Loads the file upload plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/fileupload/jquery.fileupload-ui.css">
			<script type="text/javascript" src="/ADF/thirdParty/jquery/fileupload/jquery.iframe-transport.js"></script>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/fileupload/jquery.fileupload.js"></script>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/fileupload/jquery.fileupload-ui.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryFileUpload",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadjQueryHighlight
Summary:
	Loads the Highlight plugin for jQuery
Returns:
	Void
Arguments:
	String - Version
	Boolean - Force
History:
 	2010-12-13 - GAC - Created
	2011-03-08 - GAC - Updated the renderScriptOnce with correct variable path
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryHighlight" access="public" output="true" returntype="void" hint="Loads the Highlight plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="3.0.0" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/highlight/jquery.highlight-#arguments.version#.yui.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("highlight",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$loadJQueryHotkeys
Summary:
	Loads jQuery Hotkeys plugin
Returns:
	void
Arguments:
	Boolean - Force
History:
 	2011-05-31 - RAK - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryHotkeys" access="public" returntype="void" hint="Loads jQuery Hotkeys plugin">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/hotkeys/jquery.hotkeys.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryHotkeys",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$loadJQueryJSON
Summary:
	Loads the JQuery JSON Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery JSON version to load.
	Boolean - force - Forces JQuery JSON script header to load.
History:
	2010-03-04 - GAC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryJSON" access="public" output="true" returntype="void" hint="Loads the JQuery JSON Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.2" hint="JQuery JSON version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery JSON script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/json/jquery.json-#arguments.version#.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("loadJQueryJSON",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadJQuerySelectboxes
Summary:	
	Loads the Selectboxes JQuery plugin
Returns:
	Void
Arguments:
	String - version
	Boolean - Force
History:
	2009-07-29 - RLW - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQuerySelectboxes" access="public" output="true" returntype="void" hint="Loads the JQuery selectboxes plugin."> 
	<cfargument name="version" type="string" required="false" default="2.2.4" hint="version to load - defaults to 2.2.4.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/selectboxes/jquery.selectboxes-#arguments.version#.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("selectboxes",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadSuperFish
Summary:	
	Loads the SuperFish drop down plugin
Returns:
	Void
Arguments:
	Boolean - Force
History:
 	2009-11-05 - RLW - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQuerySuperfish" access="public" output="true" returntype="void" hint="Loads the JQuery UI Stars plugin"> 
	<cfargument name="version" type="string" required="false" default="1.4.8" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/superfish/hoverIntent.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/superfish/jquery.superfish-#arguments.version#.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/superfish/css/superfish.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jquerySuperfish",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryTextLimit
Summary:
	Loads the text limit jQuery plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-06-22 - MTT - Created
	2011-07-20 - RAK - Added cfOutput to the code so that it will actually print the results
	2011-09-09 - RAK - Added cfoutput tags to the cfsavecontent
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryTextLimit" access="public" output="true" returntype="void" hint="Loads the text limit plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/textlimit/jquery.textlimit.plugin.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryTextLimit",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadJQueryTools
Summary:	
	Loads the Tools library for various effects
Returns:
	Void
Arguments:
	String - tool
	Boolean - Force
History:
 	2009-10-17 - RLW - Created
	2010-02-03 - MFC - Updated path to the CSS to remove from Third Party directory.
	2010-04-06 - MFC - Updated path to the CSS to "style".
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryTools" access="public" output="true" returntype="void" hint="Loads the JQuery tools plugin"> 
	<cfargument name="tool" type="string" required="false" default="all" hint="List of tools to load - leave blank to load entire library">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<cfif arguments.tool neq "all">
				<cfloop list="#arguments.tool#" index="tool">
					<script type='text/javascript' src='/ADF/thirdParty/jquery/tools/jquery.tools.#tool#.min.js'></script>
					<cfif fileExists("#server.ADF.dir#/thirdParty/jquery/tools/css/#tool#-minimal.css")>
						<link href="/ADF/extensions/style/jquery/tools/overlay-minimal.css" rel="stylesheet" type="text/css" />
					</cfif>
				</cfloop>
			<cfelse>
				<script type='text/javascript' src='/ADF/thirdParty/jquery/tools/jquery.tools.min.js'></script>
				<link href="/ADF/extensions/style/jquery/tools/overlay-minimal.css" rel="stylesheet" type="text/css" />
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("tools_#arguments.tool#",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadJQueryUI
Summary:
	Loads the JQuery UI Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery UI version to load.
	String - theme - JQuery UI theme to load.
	Boolean - force - Forces JQuery script header to load.
History:
	2009-07-31 - MFC - Created
	2009-09-16 - MFC - Added force argument.
	2010-08-26 - MFC - Updated to load 1.8 by default
	2010-12-21 - MFC - Removed the "min" from the script loading.
	2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
--->
<cffunction name="loadJQueryUI" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="1.8" hint="JQuery version to load.">
	<cfargument name="themeName" type="string" required="false" default="ui-lightness" hint="UI Theme Name (directory name)">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery UI script header to load.">
	<cfscript>
		var outputHTML = "";
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/js/jquery-ui-#arguments.version#.custom.js'></script>
			<cfif DirectoryExists(expandPath("/_cs_apps/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
				<link rel='stylesheet' href='/_cs_apps/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui-#arguments.version#.custom.css' type='text/css' media='screen' />
			<cfelseif DirectoryExists(expandPath("/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
				<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui-#arguments.version#.custom.css' type='text/css' media='screen' />
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryUI",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadJQueryUIStars
Summary:	
	Loads the JQuery UI Stars plugin
Returns:
	Void
Arguments:
	Boolean - force
History:
 	2009-11-05 - MFC - Created
	2009-12-02 - SFS - Added check to make sure jqueryUI is loaded ahead of time
	2011-02-02 - RAK - Updated default to 3.0
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryUIStars" access="public" output="true" returntype="void" hint="Loads the JQuery UI Stars plugin"> 
	<cfargument name="version" type="string" required="false" default="3.0" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfoutput>
		#loadJQueryUI(force=arguments.force)#
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/stars/#arguments.version#/ui.stars.min.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/stars/#arguments.version#/ui.stars.min.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryuistars",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$loadJSTree
Summary:
	Loads the jsTree plugin
Returns:
	void
Arguments:
	Boolean - force
	String  - version
	Boolean - loadJQueryCookie
	Boolean - loadJQueryHotkeys
History:
 	2011-05-31 - RAK - Created
 	2011-06-13 - RAK - removed a bug where I was defining a var after a output was opened
	2012-08-16 - GAC - Added the force parameter
	2014-01-22 - GAC - Added a version parameter
					 - Updated the dependencies to push through the force parameter
	2014-02-04 - MS  - Added a missing semi-colon to the thirdPartyLibPath statement
--->
<cffunction name="loadJSTree" access="public" returntype="void" hint="Loads the jsTree plugin">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="version" type="string" required="false" default="1.0" hint="Script version to load.">
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/jsTree";
		
		// Dependencies
		loadJQuery(force=arguments.force);
		loadJQueryCookie(force=arguments.force);
		loadJQueryHotkeys(force=arguments.force);
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='#thirdPartyLibPath#/#arguments.version#/jquery.jstree.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jstree",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	S. Smith
Name:
	$loadMouseMovement
Summary:
	Loads the mouse movement detection script for CFFormProtect if not already loaded.
Returns:
	None
Arguments:
	String - version - mouse movement version to load.
	Boolean - Force
History:
	2009-10-18 - SFS - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadMouseMovement" access="public" output="true" returntype="void" hint="Loads the mouse movement detection script for CFFormProtect if not already loaded.">
	<cfargument name="version" type="string" required="false" default="2.0.1" hint="Mouse Movement script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/cfformprotect/js/mouseMovement-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("mouseMovement",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadNiceForm
Summary:
	Loads the nice form headers and converts the CS Form layout
Returns:
	void
Arguments:
	Boolean - Force
History:
	2009-03-12 - RLW - Created
	2012-08-16 - GAC - Added the force parameter
	2014-01-22 - GAC - Replaced the '$' with the jQuery alias
--->
<cffunction name="loadNiceForms" access="public" returntype="void">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script language="javascript" type="text/javascript" src="/ADF/thirdParty/prettyForms/prettyForms.js"></script>
			<script type="text/javascript">
				jQuery(document).ready(function(){
					jQuery("input[name='submitbutton']").attr("value", "Save");
					jQuery("span[id^='tabDlg'] > table").addClass("csForms");
					jQuery("form[name='dlgform']").addClass("csForms");
					//jQuery(".cs_default_form").attr("class", "niceform");
					prettyForms();
					//jQuery(".clsPushButton").addClass("blue-pill");
					<cfif find("login.cfm", cgi.script_name)>
						// change the login button text
						jQuery(".clsPushButton").attr("value", "Login");
					</cfif>
				});
			</script>
			<link rel="stylesheet" type="text/css" media="all" href="/ADF/thirdParty/prettyForms/prettyForms.css" />
			<link rel="stylesheet" type="text/css" media="all" href="/commonspot/commonspot.css" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("niceForms",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M. Carroll
Name:
	$loadQTip
Summary:
	Loads the QTip Headers if not loaded.
Returns:
	None
Arguments:
	String - version - QTip version to load.
	Boolean - force - Forces QTip script header to load.
History:
	2009-09-26 - MFC - Created
	2013-09-04 - GAC - Updated to use folder versioning
--->
<cffunction name="loadQTip" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.0" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/qtip">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jquery.qtip.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("qtip",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadSWFObject
Summary:
	Loads the SWFObject Flash Embed Headers if not loaded.
Returns:
	None
Arguments:
	String - version - SWFObject version to load.
	Boolean - Force
History:
	2010-02-25 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadSWFObject" access="public" output="true" returntype="void" hint="Loads the SWFObject Flash Embed Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.2" hint="SWFObject version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/swfobject/swfobject-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("swfObject",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ryan kahn
Name:
	$loadSimplePassMeter
Summary:
	Loads the simplePassMeter plugin for jQuery
Returns:
	Void
Arguments:
	Boolean - Force
History:
 	2010-11-09 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadSimplePassMeter" access="public" output="true" returntype="void" hint="Loads the simplePassMeter plugin for jQuery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfscript>
		var outputHTML = '';
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/simplePassMeter/jquery.simplePassMeter-0.3.min.js'></script>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/simplePassMeter/simplePassMeter.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("simplePassMeter",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadTableSorter
Summary:
	Loads the JQuery Tablesorter Plugin Headers if not loaded.
Returns:
	None
Arguments:
	String - version - Tablesorter version to load.
	Boolean - Force
History:
	2009-06-25 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadTableSorter" access="public" output="true" returntype="void" hint="Loads the Tablesorter Plugin Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="2.0.3" hint="Tablesorter Plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/tablesorter/tablesorter-#TRIM(arguments.version)#.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("tablesorter",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadTableSorterPager
Summary:	
	Loads the JQuery Tablesorter Pager Addon from the argument.
Returns:
	Void
Arguments:
	String - version - Tablesorter version to load.
	Boolean - Force
History:
	2009-06-25 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadTableSorterPager" access="public" returntype="void" hint="Loads the Tablesorter Plugin Pager addon Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.0.3" hint="Tablesorter Plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var addonpath = "/ADF/thirdParty/jquery/tablesorter/tablesorter-" & TRIM(arguments.version) & "/addons/pager/" />
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#addonpath#tablesorter.pager.js"></script>
			<link rel="stylesheet" href="#addonpath#tablesorter.pager.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("TablesSorterPager",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadTableSorterTheme
Summary:	
	Loads the JQuery Tablesorter Plugin Themes from the argument.
Returns:
	Void
Arguments:
	String - Tablesorter Theme Name (directory name)
	String - version - Tablesorter version to load.
	Boolean - Force
History:
	2009-06-25 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadTableSorterThemes" access="public" returntype="void" hint="Loads the Tablesorter Plugin Theme Headers if not loaded.">
	<cfargument name="themeName" type="string" required="false" default="blue" hint="Tablesorter Theme Name (directory name)">
	<cfargument name="version" type="string" required="false" default="2.0.3" hint="Tablesorter Plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Tablesorter Plugin script header to load.">
	<cfset var themepath = "/ADF/thirdParty/jquery/tablesorter/tablesorter-" & TRIM(arguments.version) & "/themes/" />
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<cfif LEN(TRIM(arguments.themeName)) AND FileExists(expandPath("#themepath##TRIM(arguments.themeName)#/style.css"))>
				<link rel="stylesheet" href="#themepath##TRIM(arguments.themeName)#/style.css" type="text/css" media="screen" />
			<cfelse> <!--- default to blue --->
				<link rel="stylesheet" href="#themepath#blue/style1.css" type="text/css" media="screen" />
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("TableSorterThemes",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadThickbox
Summary:
	Loads the Thickbox Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery version to load.
	Boolean - force - Forces JQuery script header to load.
History:
	2009-06-08 - MFC - Created
--->
<cffunction name="loadThickbox" access="public" output="true" returntype="void" hint="Loads the Thickbox Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="3.1" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/thickbox/thickbox-#arguments.version#.js"></script>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/thickbox/thickbox.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("thickbox",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ryan kahn
Name:
	$loadUploadify
Summary:	
	Loads the uploadify plugin for jQuery
Returns:
	Void
Arguments:
	String - version
	Boolean - Force
History:
 	2010-10-26 - RAK - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2011-07-27 - MTT - Added the version argument. Created a folder for each version inside of /uploadify and renamed each minified version of the uploadify js file to jquery.uploadify.min.js (removing the version numbers from the file names). This lets us keep all the packaged files together per version.
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadUploadify" access="public" output="true" returntype="void" hint="Loads the uploadify plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="2.1.0" hint="JQuery Uploadify plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfoutput>
		#loadSWFObject(force=arguments.force)#
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/uploadify/#arguments.version#/uploadify.css" type="text/css" media="screen" />
			<script type='text/javascript' src='/ADF/thirdParty/jquery/uploadify/#arguments.version#/jquery.uploadify.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("uploadify",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	S. Smith
Name:
	$loadUsedKeyword
Summary:
	Loads the used keyboard detection script for CFFormProtect if not already loaded.
Returns:
	None
Arguments:
	String - version - used keyboard script version to load.
	Boolean - Force
History:
	2009-10-18 - SFS - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadUsedKeyboard" access="public" output="true" returntype="void" hint="Loads the used keyboard detection script for CFFormProtect if not already loaded.">
	<cfargument name="version" type="string" required="false" default="2.0.1" hint="Used Keyboard script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/cfformprotect/js/usedKeyboard-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("usedKeyboard",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadjQuerySWFObject
Summary:
	Loads the SWFObject jQuery Plug-in Flash Embed Headers if not loaded.
Returns:
	None
Arguments:
	String - version - jQuery SWFObject version to load.
	Boolean - Force
History:
	2009-09-04 - GAC - Created
	2010-02-25 - GAC - Updated and renamed the function
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQuerySWFObject" access="public" output="true" returntype="void" hint="Loads the SWFObject jQuery Plug-in Flash Embed Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.0.9" hint="jQuery SWFObject version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfoutput>
		#loadJQuery(force=arguments.force)#
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/swfobject/jquery.swfobject-#arguments.version#.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQuerySWFObject",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadjQueryTimeAgo
Summary:
	Loads the TimeAgo (automatically updating fuzzy timestamps) plugin for jQuery
Returns:
	Void
Arguments:
	String - Version
	Boolean - Force
History:
 	2011-03-08 - GAC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryTimeAgo" access="public" output="true" returntype="void" hint="Loads the TimeAgo (automatically updating fuzzy timestamps) plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="0.9.3" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/timeago/jquery.timeago-#arguments.version#.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("timeago",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ryan kahn
Name:
	$setDebugMode
Summary:
	display to the screen all the scripts as they load. Also displays when scripts are already loaded
Returns:
	Void
Arguments:
	Boolean - debugMode
History:
 	2010-10-04 - RAK - Created
--->
<cffunction name="setDebugMode" access="public" description="Set to true to display to the screen all the scripts as they load. Also displays when scripts are already loaded.">
	<cfargument name="debugMode" type="boolean" required="true">
	<cfset request.ADFScriptsDebugging = debugMode>
</cffunction>

</cfcomponent>