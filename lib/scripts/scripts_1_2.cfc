<!--- 
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
--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	scripts_1_2.cfc
Summary:
	Scripts functions for the ADF Library
Version:
	1.2
History:
	2012-12-07 - RAK - Created - New v1.2
	2013-03-01 - GAC - Updated jQuery iCalendar comment headers
	2013-09-05 - GAC - Updated with functions for and jQuery qTip2 JQuery ImagesLoaded
	2013-09-27 - DMB - Added a function to load jQuery Cycle2 lib 
	2014-05-19 - GAC - Added functions for jQuery plug-ins: jEditable, Calx, Calculation
	2014-09-16 - GAC - Updated references to thirdparty to thirdParty for case sensitivity
	2015-02-17 - GAC - Added a loadJQueryTimeAgo function to load version 1.4 by default
	2015-04-22 - GAC - Added the loadCKEditor and the loadTypeAheadBundle functions	
	2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path	
	2015-07-21 - GAC - Added and updated the loadCFJS function for CFJS v1.3
	2015-09-18 - GAC - Deprecated the loadJQueryUIForm() script
--->
<cfcomponent displayname="scripts_1_2" extends="scripts_1_1" hint="Scripts functions for the ADF Library">
	
<cfproperty name="version" value="1_2_32">
<cfproperty name="scriptsService" injectedBean="scriptsService_1_1" type="dependency">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Scripts_1_2">

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	Greg Cronkright
Name:
	$loadBootstrap
Summary:
	Loads the JQuery Bootstrap Headers if not loaded.
Returns:
	None
Arguments:
	String - version  - major.minor version only ()
	Boolean - force - Forces the Bootstrap headers to load
	Boolean - useDefaultTheme -  Loads the default bootstrap theme by default
History:
	2014-12-03 - GAC - Created
	2015-04-17 - GAC - Moved the jQuery plugin version of bootstrap into the jquery directory
--->
<cffunction name="loadBootstrap" access="public" output="true" returntype="void" hint="Loads the JQuery Bootstrap Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="3.3" hint="Bootstrap version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces the Bootstrap headers to load.">
	<cfargument name="useDefaultTheme" type="boolean" required="false" default="true" hint="Loads the default bootstrap theme css file.">
	
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/bootstrap/";
		var scriptPath = ""; 
		
		// Only use the major.minor version numbers and strip .maintenance/.build number if passed in
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
		
		scriptPath = thirdPartyLibPath & arguments.version & "/"; 
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<link href="#scriptPath#css/bootstrap.min.css" rel="stylesheet" type="text/css" />
		<cfif useDefaultTheme>
		<link href="#scriptPath#css/bootstrap-theme.min.css" rel="stylesheet" type="text/css" />
		</cfif>
		<script type="text/javascript" src="#scriptPath#js/bootstrap.min.js" charset="utf-8"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("bootstrap",outputHTML)#
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
	http://cfjs.riaforge.org/
	https://github.com/topherj/cfjs

	Function Listing:
	https://github.com/topherj/cfjs/wiki/CFJS-Function-List
Returns:
	None
Arguments:
	String - version - CFJS version to load.
	Boolean - Force
History:
	2015-07-21 - GAC - Added for version 1.3 of CFJS
	                 - Updated to use versioned directories
--->
<cffunction name="loadCFJS" access="public" output="true" returntype="void" hint="Loads the CFJS jQuery Plug-in Headers if not loaded.">
	<cfargument name="version" type="string" required="true" default="1.3" hint="CFJS version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/cfjs/";
		
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
		
		// Append the version to the thirdPartyLibPath
		thirdPartyLibPath = thirdPartyLibPath & arguments.version & "/"; 
	</cfscript>

	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#jquery.cfjs.min.js"></script>
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
Name:
	$loadCKEditor
Summary:
	Loads the ckeditor script Headers if not loaded.
	
	!! Important !!
	We DO NOT include the CK Editor code library in the ADF/thirdParty folder.
	
	First we look for in two different unversioned local site folders:
		1) cs_customization - Commonspot  "/cs_customization/ckeditor/"
		2) _cs_apps - ADF thirdParty folder "/_cs_apps/thirdParty/ckeditor/"
	If we can't find it either of those locations then we use the CKEditor CDN for the version specified.
		eg. "//cdn.ckeditor.com/4.4.7/full/ckeditor.js"
Returns:
	None
Arguments:
	String - version - CKEditor version to load from the CDN.
	String - package -  CKEditor package to load from the CDN.
	Boolean - useCDN - Disables local filesystem checking and loads directly from the CDN.
	Boolean - force - Forces CKEditor script header to load.
History:
	2015-04-22 - GAC - Created
	2015-05-21 - GAC - With the addition of the scriptsService.jsCommentStripper() the CDN URL can now use the scripts js loader
--->
<cffunction name="loadCKEditor" access="public" output="true" returntype="void" hint="Loads the ckeditor scriptHeaders if not loaded."> 
	<cfargument name="version" type="string" required="false" default="4.4.7" hint="Optional: CKeditor version to load. Used only when loading from ckeditor CDN.">
	<cfargument name="package" type="string" required="false" default="full" hint="Optional: CKeditor package to load.  Used only when loading from ckeditor CDN.">
	<cfargument name="useCDN" type="boolean" required="false" default="false" hint="Disables local filesystem checking and loads directly from the CDN.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces CKEditor script header to load.">
	
	<cfscript>
		var outputHTML = "";
		var csScriptLibPath = "/cs_customization/ckeditor/ckeditor.js";
		var adfScriptLibPath = "/_cs_apps/thirdParty/ckeditor/ckeditor.js";
		var loadViaCDN = false;
		var packageList = 'basic,standard,standard-all,full,full-all';
		var disableJSloader = false;
		
		if ( LEN(TRIM(arguments.package)) EQ 0 OR ListFindNoCase(packageList,arguments.package) EQ 0 )
			arguments.package = "full";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<cfif !arguments.useCDN>
				<!--- // Attempt to find and load the local site level ckeditor.js file --->
				<cfif FileExists(expandPath(csScriptLibPath))>
					<script type="text/javascript" src="#csScriptLibPath#"></script>
				<cfelseif FileExists(expandPath(adfScriptLibPath))>
					<script type="text/javascript" src="#adfScriptLibPath#"></script>
				<cfelse>
					<cfset loadViaCDN = true>
				</cfif>
			<cfelse>
				<cfset loadViaCDN = true>
			</cfif>	
			<!--- // If we can't find site level files or forceCDN is true... load ckeditor from the CDN --->
			<cfif loadViaCDN>
				<!--- // [GAC 2015-04-23] - currently external URLs get stripped if we use the renderScriptOnce javascript loader --->
				<!--- // [GAC 2015-05-21] using scriptsService.jsCommentStripper() this is no longer an issue --->
				<!--- REMOVE - <cfset disableJSloader = true> --->
				<cfset disableJSloader = true>
				<script type="text/javascript" src="//cdn.ckeditor.com/#arguments.version#/#arguments.package#/ckeditor.js"></script>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce(scriptName="ckeditor",outputHTML=outputHTML,disableJSloader=disableJSloader)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	Greg Cronkright
Name:
	$loadDateFormat
Summary:
	Loads the JavaScript Date Format library for the Calendar App if not loaded.
	By Steven Levithan
	http://blog.stevenlevithan.com/archives/date-time-format
Returns:
	None
Arguments:
	String - version 
	Boolean - force - Forces JQuery script header to load.
History:
	2013-02-12 - GAC - Created
--->
<cffunction name="loadDateFormat" access="public" output="true" returntype="void" hint="Loads the JavaScript Date Format library for the Calendar App if not loaded.d.">
	<cfargument name="version" type="string" required="false" default="1.2" hint="Date Format version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces the JavaScript for the Calendar App to load.">
	<cfscript>
		var outputHTML = "";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/js/dateformat/#arguments.version#/date.format.js" charset="utf-8"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("DateFormat",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	Greg Cronkright
Name:
	$loadDateJS
Summary:
	Loads the JavaScript DateJS library for the Calendar App if not loaded.
	http://www.datejs.com/
Returns:
	None
Arguments:
	String - version 
	Boolean - force - Forces JQuery script header to load.
History:
	2013-02-12 - GAC - Created
--->
<cffunction name="loadDateJS" access="public" output="true" returntype="void" hint="Loads the JavaScript Date Format library for the Calendar App if not loaded.d.">
	<cfargument name="version" type="string" required="false" default="1.0" hint="Date Format version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces the JavaScript for the Calendar App to load.">
	<cfscript>
		var outputHTML = "";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/js/datejs/#arguments.version#/date.js" charset="utf-8"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("DateJS",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
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
	G. Cronkright
Name:
	$loadFontAwesome
Summary:
	Loads the Font Awesome iconic font and CSS toolkit
Returns:
	void
Arguments:
	String - Version
	Boolean - Force
History:
 	2014-09-22 - GAC - Created
	2014-12-03 - GAC - Fixed the the major.minor version consistency issue to remove the .maintenance/.build number if passed in
--->
<cffunction name="loadFontAwesome" access="public" output="true" returntype="void" hint="Loads the Font Awesome iconic font and CSS toolkit">
	<cfargument name="version" type="string" required="false" default="4.2" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces Font Awesome css header to load.">
	<cfargument name="dynamicHeadRender" type="boolean" required="false" default="false" hint="Uses jQuery to load the Font Awesome css into the HEAD of the document dynamically.">
	<cfargument name="overridePath" type="string" required="false" default="" hint="A relative path to a custom site level override font-awesome css file">
	
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/css/font-awesome/";
		var scriptPath = ""; 
		var scriptPathExt = ""; 
		
		// Only use the major.minor version numbers and strip .maintenance/.build number if passed in
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version); 
	
		scriptPath = thirdPartyLibPath & arguments.version & "/css/font-awesome.min.css"; 
		// An ADF css extension css file that add sizes (6x-10x) 
		scriptPathExt = thirdPartyLibPath & arguments.version & "/css/font-awesome-ADF-ext.css"; 
	
		// If an overridePath is passed in and valid load that .css file instead
		if ( LEN(TRIM(arguments.overridePath)) AND ListLast(arguments.overridePath,".") EQ "css" AND FileExists(expandPath(arguments.overridePath)) )
		{
			scriptPath = arguments.overridePath;
			scriptPathExt = "";
		}
	</cfscript>
	
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<cfif arguments.dynamicHeadRender>
			<script>
				jQuery(function(){
					jQuery('<link>').attr('rel','stylesheet').attr('type','text/css').attr('href','#scriptPath#').appendTo('head'); 
					<cfif LEN(TRIM(scriptPathExt))>
					jQuery('<link>').attr('rel','stylesheet').attr('type','text/css').attr('href','#scriptPathExt#').appendTo('head'); 
					</cfif>
				});
			</script>
		<cfelse>
			<link href="#scriptPath#" rel="stylesheet" type="text/css" />
			<cfif LEN(TRIM(scriptPathExt))>
			<link href="#scriptPathExt#" rel="stylesheet" type="text/css" />
			</cfif>
		</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("fontAwesome",outputHTML)#
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
	2012-12-07 - MFC - Based on 1.1.  Set to default load JQuery 1.8.
	2013-02-06 - MFC - Set default to 1.9 and load JQuery Migrate Plugin when 
						loading v1.9 or greater.
	2014-05-05 - GAC - Updated the default jQuery version to 1.11
	2014-12-03 - GAC - Updated to fix the version detection logic for the loadMigratePlugin
--->
<cffunction name="loadJQuery" access="public" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.11" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="noConflict" type="boolean" required="false" default="0" hint="JQuery no conflict flag.">
	
	<cfscript>
		// Flag to determine if we load the JQuery Migrate plugin after the loading process
		var loadMigratePlugin = false; 
		
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);

		// Check that we are loading v1.9 or greater (eg. 1.9.x, 1.11.x or 2.x load the Migrate plugin)
		if ( 
				(ListFirst(arguments.version,".") EQ 1 AND ListLast(arguments.version,".") GTE 9) 
					OR (ListFirst(arguments.version,".") GTE 2) 
			) 
		{
			// If forcing, then load migrate plugin OR the jquery script is NOT loaded yet
			if ( arguments.force OR NOT variables.scriptsService.isScriptLoaded("jQuery") )
				loadMigratePlugin = true;	
		}
				
		// Call the super function to load
		super.loadJQuery(version=arguments.version, force=arguments.force, noConflict=arguments.noConflict);
		
		// Check that we need to load with JQuery Migrate plugin
		if ( loadMigratePlugin )
			loadJQueryMigrate(force=arguments.force);
	</cfscript>
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
	2015-06-26 - GAC - Added version BlockUI v2.7 
--->
<cffunction name="loadJQueryBlockUI" access="public" output="true" returntype="void" hint="Loads the JQuery BlockUI plugin if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.7" hint="JQuery BlockUI plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="renderInHead" type="boolean" required="false" default="false" hint="Flag to render the script in the document head.">
	
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/blockUI/";
		
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath##arguments.version#/jquery.blockUI.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce(scriptName="jQueryBlockUI",outputHTML=outputHTML,renderInHead=arguments.renderInHead)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadCapty
Summary:
	Loads the capty plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2012-01-20 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryCapty" access="public" output="true" returntype="void" hint="Loads the JQuery Capty plugin code.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/capty/css/jquery.capty.css">
			<script type="text/javascript" src="/ADF/thirdParty/jquery/capty/js/jquery.capty.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryCapty",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJCycle
Summary:	
	Loads the jCycle plugin for jQuery
Returns:
	Void
Arguments:
	String - version - "2.9"
	Boolean - Force
History:
 	2012-12-17 - MFC - Based on 1.1.  Set to default load version 2.9.
--->
<cffunction name="loadJCycle" access="public" output="true" returntype="void" hint="Loads the jCycle plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="2.9" hint="jCycle version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfscript>
		// Call the super function
		super.loadJCycle(version=arguments.version, force=arguments.force);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Dave Beckstrom
Name:
	$loadJCycle2
Summary:	
	Loads the jCycle2 responsive plugin for jQuery
	
	Note: Console logging is globally disabled by default. To enable on slide show by slide show 
		  basis set the loadJCycle2(enablelog=true) and add 'data-cycle-log="false"' to your slide show 
		  html parent element or control vian your cycle2 js configuration options
		  
		 <div class="cycle-slideshow" data-cycle-log="false"></div>
		 OR
		 jQuery('.cycle-slideshow').cycle({
		 		speed: 600,
			    log: false
		 });
Returns:
	Void
Arguments:
	String version
History:
 	2013-09-25 - DMB - Created
	2013-10-17 - GAC - Updated the script name passed to the renderScriptOnce function
	2013-10-25 - GAC - Updated to globally disable Cycle2 console logging by default with a parameter to re-enable
--->
<cffunction name="loadJCycle2" access="public" output="true" returntype="void" hint="Loads the jCycle2 responsive plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="20130909" hint="jCycle version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces jCycle2 script header to load.">
	<cfargument name="enablelog" type="boolean" required="false" default="false" hint="Set to true to enable console logging.">
	<cfscript>
		var outputHTML = "";
		// safety check to make sure atleast the min version is loaded
		if ( !IsNumeric(arguments.version) OR arguments.version LT 20130909) 
			arguments.version = 20130909;
	</cfscript>	
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcycle2/#arguments.version#/jquery.cycle2.min.js'></script>
			<cfif NOT arguments.enablelog>
			<script>jQuery.fn.cycle.log = jQuery.noop</script>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jcycle2",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$loadJQueryCalculation
Summary:
	Loads the jQuery Calculation
Returns:
	None
Arguments:
	String - version - version to load.
	Boolean - force - Forces script header to load.
History:
	2013-05-16 - GAC - Added
--->
<cffunction name="loadJQueryCalculation" access="public" output="true" returntype="void" hint="Loads the jQuery Calculation Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="0.4" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/calculation">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jquery.calculation.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jquerycalculation",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$loadJQueryCalcX
Summary:
	Loads the jQuery CalcX
Returns:
	None
Arguments:
	String - version - version to load.
	Boolean - force - Forces script header to load.
History:
	2013-05-16 - GAC - Added
--->
<cffunction name="loadJQueryCalcX" access="public" output="true" returntype="void" hint="Loads the jQuery CalcX Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.1" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/calcx">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jquery.calx.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jquerycalcx",outputHTML)#
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
	2013-01-16 - MFC - Restructured the thirdParty folders & versions. Set to default load JQuery Data Tables 1.9.
	2013-02-06 - MFC - Moved the "Restructured the thirdParty folders & versions" support code to
						the Scripts 1.1 to make backwards compatibable.
	2013-11-14 - DJM - Added a loadStyle parameter
--->
<cffunction name="loadJQueryDataTables" access="public" output="true" returntype="void" hint="Loads the JQuery DataTables Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.9" hint="JQuery DataTables version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery DataTables script header to load.">
	<cfargument name="loadStyles" type="boolean" required="false" default="true" hint="Boolean flag incicating if we need to load styles">
	<cfscript>
		super.loadJQueryDataTables(version=arguments.version, force=arguments.force, loadStyles=arguments.loadStyles);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$loadJQueryJeditable
Summary:
	Loads the jQuery JEditable
Returns:
	None
Arguments:
	String - version - version to load.
	Boolean - force - Forces script header to load.
History:
	2013-05-16 - GAC - Added
--->
<cffunction name="loadJQueryJeditable" access="public" output="true" returntype="void" hint="Loads the jQuery JEditable Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.7" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/jeditable">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jquery.jeditable.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryjeditable",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	Greg Cronkright
Name:
	$loadJQueryiCalendar
Summary:
	Loads the jQuery iCalendar Headers if not loaded.
Returns:
	None
Arguments:
	String - version 
	Boolean - force - Forces JQuery script header to load.
History:
	2013-02-12 - GAC - Created
--->
<cffunction name="loadJQueryiCalendar" access="public" output="true" returntype="void" hint="Loads the jQuery iCalendar for the Calendar App if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.1" hint="JQuery iCalendar version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces the JavaScript for the Calendar App to load.">
	<cfscript>
		var outputHTML = "";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<link href="/ADF/thirdParty/jquery/icalendar/#arguments.version#/jquery.icalendar.pt.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/ADF/thirdParty/jquery/icalendar/#arguments.version#/jquery.icalendar.pt.js" charset="utf-8"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryiCalendar",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$loadJQueryImagesLoaded
Summary:
	Loads the jQuery Images Loaded Headers if not loaded.
Returns:
	None
Arguments:
	String - version - version to load.
	Boolean - force - Forces script header to load.
History:
	2013-09-04 - GAC - Added
--->
<cffunction name="loadJQueryImagesLoaded" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="3.0" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/imagesloaded">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/imagesloaded.pkgd.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryimagesloaded",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	D. Beckstrom
Name:
	$loadJQueryMobile
Summary:
	Loads the JQuery Mobile script.
Returns:
	None
Arguments:
	String - version - JQuery version to load.
	Boolean - force - Forces JQuery script header to load.
History:
	2012-07-11 - DMB - Created
	2012-07-24 - DMB - Added check to see if user is authenticated before running jQuery
	2013-03-14 - MFC - Moved the function into the Scripts library.  Updated the logic for the 
						"renderScriptOnce" call to script service.
					   Set the default to v1.3.
--->
<cffunction name="loadJQueryMobile" access="public" output="true" returntype="void" hint="Loads the JQuery Mobile script if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.4" hint="JQuery Mobile version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Mobile to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/mobile/#arguments.version#/jquery.mobile-#arguments.version#.min.js"></script>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/mobile/#arguments.version#/jquery.mobile-#arguments.version#.min.css" />
			<!--- the following adds rel="external" to the Commonspot dashboard entrance menu --->
			<cfif not (session.user.userid is "anonymous")>
				<script type="text/javascript">
					jQuery(document).ready(function() { 
					jQuery("##cs_entrance_menu a").attr("rel","external");
				})
				</script>
			</cfif>
		</cfoutput>	
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryMobile",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryMigrate
Summary:
	Loads the JQuery Migrate Plugin for Jquery backwards compatibility. 
Returns:
	None
Arguments:
	String - Version
	Boolean - Force
History:
	2013-02-06 - MFC - Created
	2013-10-26 - GAC - Updated to load v1.2 by default
--->
<cffunction name="loadJQueryMigrate" access="public" output="true" returntype="void" hint="Loads the JQuery Migrate Plugin for Jquery backwards compatibility.">
	<cfargument name="version" type="string" required="false" default="1.2" hint="JQuery Migrate version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Migrate script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script src="/ADF/thirdParty/jquery/migrate/jquery-migrate-#arguments.version#.js"></script>
		</cfoutput>	
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryMigrate",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryMultiselect
Summary:
	Loads the file multiselect jQuery plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-09-27 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryMultiselect" access="public" output="true" returntype="void" hint="Loads the multiselect plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<link rel="stylesheet" href="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.css">
		<link rel="stylesheet" href="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.filter.css">
		<script type="text/javascript" src="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.min.js"></script>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/multiselect/jquery.multiselect.filter.min.js"></script>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryMultiselect",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryNMCFormHelper
Summary:	
	Loads the nmcFormHelper plugin for jQuery.
	http://www.gethifi.com/blog/nmcformhelper
Returns:
	Void
Arguments:
	String - version
	Boolean - Force
History:
 	2013-01-16 - MFC - Created
--->
<cffunction name="loadJQueryNMCFormHelper" access="public" output="true" returntype="void" hint="Loads the nmcFormHelper plugin for jQuery."> 
	<cfargument name="version" type="string" required="false" default="1.0" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery nmcFormHelper plugin script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/nmcFormHelper/#arguments.version#/nmcFormHelper.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryNMCFormHelper",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryPlupload
Summary:
	Loads the plupload JQuery plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-07-27 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryPlupload" access="public" output="true" returntype="void" hint="Loads the plupload plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/plupload/js/plupload.full.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryPlupload",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQuerySWFUpload
Summary:
	Loads the swfupload JQuery plugin
Returns:
	None
Arguments:
	String - version
	Boolean - useQueue
	Boolean - Force
History:
	2011-07-31 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
	2013-01-08 - MTT - Added the useQueue parameter to add the queue plugin to swfupload
--->
<cffunction name="loadJQuerySWFUpload" access="public" output="true" returntype="void" hint="Loads the SWF upload plugin for jquery">
	<cfargument name="version" type="string" required="false" default="2.2.0.1" hint="Script version to load.">
	<cfargument name="useQueue" type="boolean" required="false" default="0" hint="Flag to include the SWFUpload queue plugin file.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/swfupload/swfupload-#arguments.version#/swfupload.js"></script>
		<cfif arguments.useQueue>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/swfupload/swfupload-#arguments.version#/swfupload.queue.js"></script>
		</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	<cfif arguments.force>
		#outputHTML#
	<cfelse>
		#variables.scriptsService.renderScriptOnce("jQuerySWFUpload",outputHTML)#
	</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadTableSorter
Summary:
	Loads the JQuery Tablesorter Plugin Headers if not loaded.
Returns:
	None
Arguments:
	String - version - Tablesorter version to load.
	Boolean - force
History:
	2009-06-25 - GAC - Created
	2013-01-16 - MFC - Restructured the thirdParty folders & versions. Set to default load version 2.0.
--->
<cffunction name="loadTableSorter" access="public" output="true" returntype="void" hint="Loads the Tablesorter Plugin Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="2.0" hint="Tablesorter Plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery DataTables script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/tablesorter/#arguments.version#/jquery.tablesorter.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryTablesorter",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$loadTableSorterTheme
Summary:	
	Loads the JQuery Tablesorter Plugin Themes from the argument.
Returns:
	Void
Arguments:
	String - Tablesorter Theme Name (directory name)
	String - version - Tablesorter version to load.
	Boolean - force
History:
	2009-06-25 - GAC - Created
	2013-01-16 - MFC - Restructured the thirdParty folders & versions. Set to default load version 2.0.
--->
<cffunction name="loadTableSorterThemes" access="public" returntype="void" hint="Loads the Tablesorter Plugin Theme Headers if not loaded.">
	<cfargument name="themeName" type="string" required="false" default="blue" hint="Tablesorter Theme Name (directory name)">
	<cfargument name="version" type="string" required="false" default="2.0" hint="Tablesorter Plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery DataTables script header to load.">
	<cfset var themepath = "/ADF/thirdParty/jquery/tablesorter/#arguments.version#/themes/">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<!--- Verify the length and that the theme directory exists --->
		<cfif LEN(TRIM(arguments.themeName)) AND FileExists(expandPath("#themepath##TRIM(arguments.themeName)#/style.css"))>
			<cfoutput>
				<link rel="stylesheet" href="#themepath##TRIM(arguments.themeName)#/style.css" type="text/css" media="screen" />
			</cfoutput>
		<cfelse> <!--- default to blue --->
			<cfoutput>
				<link rel="stylesheet" href="#themepath#blue/style.css" type="text/css" media="screen" />
			</cfoutput>
		</cfif>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryTableSorterThemes",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadTableSorterPager
Summary:	
	Loads the JQuery Tablesorter Pager Addon from the argument.
Returns:
	Void
Arguments:
	String - version - Tablesorter version to load.
	Boolean - force
History:
	2009-06-25 - GAC - Created
	2013-01-16 - MFC - Restructured the thirdParty folders & versions. Set to default load version 2.0.
--->
<cffunction name="loadTableSorterPager" access="public" returntype="void" hint="Loads the Tablesorter Plugin Pager addon Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.0" hint="Tablesorter Plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Tablesorter script header to load.">
	<cfset var addonpath = "/ADF/thirdParty/jquery/tablesorter/#arguments.version#/addons/pager/" />
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
			#variables.scriptsService.renderScriptOnce("jqueryTableSorterThemes",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryTemplates
Summary:
	Loads the templates (tmpl) plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-07-27 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryTemplates" access="public" output="true" returntype="void" hint="Loads the templates (tmpl) plugin for jquery">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<script type="text/javascript" src="/ADF/thirdParty/jquery/templates/jquery.tmpl.min.js"></script>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryTemplates",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>


<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryTimeAgo
Summary:	
	Loads the TimeAgo (automatically updating fuzzy timestamps) plugin for jQuery
Returns:
	Void
Arguments:
	String - version - "1.4"
	Boolean - Force
History:
 	2015-02-17 - GAC - Based on 1.1.  Set to default load version 1.4.
--->
<cffunction name="loadJQueryTimeAgo" access="public" output="true" returntype="void" hint="Loads the TimeAgo (automatically updating fuzzy timestamps) plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="1.4" hint="jCycle version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfscript>
		// Call the super function
		super.loadJQueryTimeAgo(version=arguments.version,force=arguments.force);
	</cfscript>
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
	String - version
	Boolean - Force
History:
 	2009-10-17 - RLW - Created
	2010-02-03 - MFC - Updated path to the CSS to remove from Third Party directory.
	2010-04-06 - MFC - Updated path to the CSS to "style".
	2012-08-16 - GAC - Added the force parameter
	2013-01-16 - MFC - Restructured the thirdParty folders & versions.
	 				   Removed the "tool" argument.
	 				   Added the "version" argument.
--->
<cffunction name="loadJQueryTools" access="public" output="true" returntype="void" hint="Loads the JQuery tools plugin"> 
	<cfargument name="version" type="string" required="false" default="1.2" hint="JQuery Tools version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Tools script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/tools/#arguments.version#/jquery.tools.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryTools",outputHTML)#
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
	2013-01-01 - MFC - Based on 1.1. Changed the theme loading folders for 1.9.
	2013-02-06 - MFC - Changed the theme loading folders for 1.10.
					   Updated the IF statement to check the decimal places is only 1 length.
	2014-09-30 - GAC - Changed the theme loading folders for 1.11. 
	2015-04-17 - GAC - Pulled out the jQueryUI Style sheet code and moved it to its own function
	2015-05-21 - GAC - Fixed the logic with the version detection to load scripts 1.1 version
--->
<cffunction name="loadJQueryUI" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="1.11" hint="JQuery version to load.">
	<cfargument name="themeName" type="string" required="false" default="ui-lightness" hint="UI Theme Name (directory name)">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery UI script header to load.">
	
	<cfscript>
		var outputHTML = "";
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
 
	<!--- // Check the version, if less than or equal "1.8.x" then call the Scripts 1.1 function to load. --->
	<cfif ListFirst(version,".") EQ 0 OR (ListFirst(version,".") LTE 1 AND ListFirst(ListRest(version,"."),".") LTE 8)>
		<cfscript>
			super.loadJQueryUI(version=arguments.version,themeName=arguments.themeName,force=arguments.force);
		</cfscript>
	<cfelse>
		<cfsavecontent variable="outputHTML">
			<cfoutput>
				<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/js/jquery-ui-#arguments.version#.js'></script>
			</cfoutput>
		</cfsavecontent>
		<cfoutput>
			<cfif arguments.force>
				#outputHTML#
			<cfelse>
				#variables.scriptsService.renderScriptOnce("jQueryUI",outputHTML)#
			</cfif>
		</cfoutput>
		<cfscript>
			loadJQueryUIstyles(version=arguments.version,themeName=arguments.themeName,force=arguments.force);
		</cfscript>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryUIstyles
Summary:
	Loads the JQuery UI css file Headers if not loaded.
Returns:
	None
Arguments:
	String - version - JQuery UI version to load.
	String - theme - JQuery UI theme to load.
	Boolean - force - Forces JQuery script header to load.
History:
	2015-04-17 - GAC - Created
	2015-08-06 - GAC - Updated renderScriptOnce scriptName to avoid loading more that one UI theme stylesheet 
--->
<cffunction name="loadJQueryUIstyles" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="1.11" hint="JQuery version to load.">
	<cfargument name="themeName" type="string" required="false" default="ui-lightness" hint="UI Theme Name (directory name)">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery UI script header to load.">
	<cfscript>
		var outputHTML = "";
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<cfif DirectoryExists(expandPath("/_cs_apps/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
				<link rel='stylesheet' href='/_cs_apps/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui.css' type='text/css' media='screen' />
			<cfelseif DirectoryExists(expandPath("/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
				<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui.css' type='text/css' media='screen' />
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryUIstyles",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadJQueryUIForm
Summary:
	Loads the file multiselect jQuery plugin
Returns:
	None
Arguments:
	Boolean - Force
History:
	2011-09-27 - MTT - Created
	2012-08-16 - GAC - Added the force parameter
	2015-09-18 - GAC - Deprecated this function by commiting out the code that renders the script tag that loads it
--->
<!---// DEPRECATED: The loadJQueryUIForm() has been deprecated will no longer load the jquery.ui.form.js script --->
<!---// The project has been archived by google code but can still be found as this address (if needed): https://code.google.com/p/jquery-ui-form/ --->
<cffunction name="loadJQueryUIForm" access="public" output="true" returntype="void" hint="Loads the form plugin for jquery ui">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<!--- <cfsavecontent variable="outputHTML">
		<script type="text/javascript" src="/ADF/thirdParty/jquery/ui/form/jquery.ui.form.js"></script>
	</cfsavecontent> --->
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryUIForm",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	Greg Cronkright
Name:
	$loadJQueryUITimepickerAddon
Summary:
	Loads the jQuery UI Timepicker Addon for the Calendar App if not loaded.
	
	https://github.com/trentrichardson/jQuery-Timepicker-Addon
Returns:
	None
Arguments:
	String - version 
	Boolean - force - Forces script header to load.
History:
	2013-02-06 - GAC - Created
--->
<cffunction name="loadJQueryUITimepickerAddon" access="public" output="true" returntype="void" hint="Loads the jQuery UI Timepicker Addon for the Calendar App if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.2" hint="JQueryUI Timepicker Addon version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces the JavaScript for the Calendar App to load.">
	<cfscript>
		var outputHTML = "";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<link href="/ADF/thirdParty/jquery/ui/timepicker-addon/#arguments.version#/jquery-ui-timepicker-addon.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/ADF/thirdParty/jquery/ui/timepicker-addon/#arguments.version#/jquery-ui-timepicker-addon.js" charset="utf-8"></script>
		<cfif arguments.version GTE "1.2">
		<script type="text/javascript" src="/ADF/thirdParty/jquery/ui/timepicker-addon/#arguments.version#/jquery-ui-sliderAccess.js" charset="utf-8"></script>
		</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryUITimepickerAddon",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin Inc.
	Greg Cronkright
Name:
	$loadJQueryUITimepickerFG
Summary:
	Loads the jQuery UI Timepicker FG (Fran�ois G�linas) for the Calendar App if not loaded.
	
	http://fgelinas.com/code/timepicker/
Returns:
	None
Arguments:
	String - version 
	Boolean - force - Forces JQuery script header to load.
History:
	2013-02-06 - GAC - Created
	2015-05-20 - DJM - Modified the css file name to refer to the correct file
--->
<cffunction name="loadJQueryUITimepickerFG" access="public" output="true" returntype="void" hint="Loads the jQuery UI Timepicker Addon for the Calendar App if not loaded.">
	<cfargument name="version" type="string" required="false" default="0.3" hint="JQueryUI Timepicker Addon version to load.">
	<cfargument name="force" type="boolean" required="false" default="false" hint="Forces the JavaScript for the Calendar App to load.">
	<cfscript>
		var outputHTML = "";
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
		<link href="/ADF/thirdParty/jquery/ui/timepicker-fg/#arguments.version#/jquery.ui.timepicker.css" rel="stylesheet" type="text/css" />
		<script type="text/javascript" src="/ADF/thirdParty/jquery/ui/timepicker-fg/#arguments.version#/jquery.ui.timepicker.js" charset="utf-8"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jQueryUITimepickerFG",outputHTML)#
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
	
	NOTE: jsTree 3.0 requires 1.9.0 or greater in your webpage.
Returns:
	void
Arguments:
	Boolean - force
	String - version
	Boolean- loadStyles
	String - theme
History:
	2014-01-22- GAC - Created new method for jsTree 3.0
--->
<cffunction name="loadJSTree" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="3.0" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces script header to load.">
	<cfargument name="loadStyles" type="boolean" required="false" default="true" hint="Boolean flag incicating if we need to load styles">
	<cfargument name="theme" type="string" required="false" default="default" hint="Sets the jsTree theme name.">
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/jsTree";
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfif arguments.version LT 3>
		<cfscript> 
			// Call the super function
			super.loadJSTree(version='1.0',force=arguments.force);
		</cfscript>
	<cfelse>
		<cfsavecontent variable="outputHTML">
			<cfoutput>
				<cfif arguments.loadStyles AND LEN(TRIM(arguments.theme)) NEQ 0>
				<link type="text/css" rel="stylesheet" href="#thirdPartyLibPath#/#arguments.version#/themes/#arguments.theme#/style.min.css" />
				</cfif>
				<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jstree.min.js"></script>
			</cfoutput>
		</cfsavecontent>
		<cfoutput>
			<cfif arguments.force>
				#outputHTML#
			<cfelse>
				#variables.scriptsService.renderScriptOnce("jstree",outputHTML)#
			</cfif>
		</cfoutput>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author:
	Fig Leaf Software
	Mike Tangorre (mtangorre@figleaf.com)
Name:
	$loadMathUUID
Summary:
	Loads the math.uuid.js library
Returns:
	None
Arguments:
	Boolean - Force
History:
	2012-02-15 - MTT - Created
	2012-02-23 - MFC - Moved the JS file into a "math-uuid" folder.
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadMathUUID" access="public" output="true" returntype="void" hint="Loads the math.uuid.js library.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/js/math-uuid/math.uuid.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("mathuuid",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	Andy Reid
Name:
	$loadTipsy
Summary:
	Loads the tipsy Headers if not loaded.
Returns:
	None
Arguments:
	Boolean - force - Forces tipsy script header to load.
History:
	2011-11-22 - AAR - Created
	2012-02-15 - MTT - Modified the key used with the renderScriptOnce call to tipsy.
--->
<cffunction name="loadTipsy" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/tipsy/javascripts/jquery.tipsy.js"></script>
			<link rel="stylesheet" type="text/css" href="/ADF/thirdParty/jquery/tipsy/stylesheets/tipsy.css" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("tipsy",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadjQueryEasing
Summary:
	Loads the Easing plugin for jQuery
Returns:
	Void
Arguments:
	String - Version
	Boolean - Force
History:
 	2011-10-20 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
	2013-04-23 - MFC - Fixed the path to remove the "pack" and "-" in the file name.
--->
<cffunction name="loadJQueryEasing" access="public" output="true" returntype="void" hint="Loads the Easing plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="1.3" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/easing/">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#jquery.easing.#arguments.version#.js"></script>	
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jqueryeasing",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadjQueryFancyBox
Summary:
	Loads the fancyBox plugin for jQuery
Returns:
	Void
Arguments:
	String - Version
	Boolean - Force
History:
 	2011-10-20 - GAC - Created
	2012-06-01 - MFC - Fixed function calls to loadjQueryEasing and loadjQueryMouseWheel.
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryFancyBox" access="public" output="true" returntype="void" hint="Loads the fancyBox plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="1.3.4" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/fancybox/">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#jquery.fancybox-#arguments.version#.pack.js"></script>
			#loadjQueryEasing(force=arguments.force)#
			#loadjQueryMouseWheel(force=arguments.force)#
			<link rel="stylesheet" href="#thirdPartyLibPath#jquery.fancybox-#arguments.version#.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("fancybox",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadjQueryMouseWheel
Summary:
	Loads the Mouse Wheel plugin for jQuery
Returns:
	Void
Arguments:
	String - Version
	Boolean - Force
History:
 	2011-10-20 - GAC - Created
	2012-08-16 - GAC - Added the force parameter
--->
<cffunction name="loadJQueryMouseWheel" access="public" output="true" returntype="void" hint="Loads the Mouse Wheel plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="3.0.4" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/mousewheel/">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#jquery.mousewheel-#arguments.version#.pack.js"></script>	
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("jquerymousewheel",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
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
	2013-09-04 - GAC - Created to add the latest version of qTip2
--->
<cffunction name="loadQTip" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.1" hint="Version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces script header to load.">
	<!--- <cfargument name="useImagesLoaded" type="boolean" required="false" default="0" hint="Loads optional imagesLoaded header add-on.">
	<cfargument name="ImagesLoadedVersion" type="string" required="false" default="3.0" hint="Version of imagesLoaded to load."> --->
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/qtip";
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfif arguments.version LT 2>
		<cfscript> 
			// Call the super function
			super.loadQTip(version='1.0',force=arguments.force);
		</cfscript>
	<cfelse>
		<cfsavecontent variable="outputHTML">
			<cfoutput>
				<link type="text/css" rel="stylesheet" href="#thirdPartyLibPath#/#arguments.version#/jquery.qtip.min.css" />
				<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jquery.qtip.min.js"></script>
			</cfoutput>
		</cfsavecontent>
		<cfoutput>
			<cfif arguments.force>
				#outputHTML#
			<cfelse>
				#variables.scriptsService.renderScriptOnce("qtip",outputHTML)#
			</cfif>
			<!--- <cfif arguments.useImagesLoaded>
				<!-- // Optional: imagesLoaded dependancy to better support images inside your tooltips -->
				#loadJQueryImagesLoaded(force=arguments.force)# 
			</cfif> --->
		</cfoutput>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadTypeAheadBundle
Summary:	
	Loads the jQuery TypeAhead Bundle autocomplete plugin
	which includes bloodhound.js and typeahead.jquery.js 
	
	https://github.com/twitter/typeahead.js
	http://twitter.github.io/typeahead.js/examples/
Returns:
	Void
Arguments:
	String - version
	Boolean - Force
History:
 	2015-04-17 - GAC - Created
--->
<cffunction name="loadTypeAheadBundle" access="public" output="true" returntype="void" hint="Loads the jQuery TypeAhead Bundle autocomplete plugin"> 
	<cfargument name="version" type="string" required="false" default="10.5" hint="JQuery Tools version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Tools script header to load.">
	<cfscript>
		var outputHTML = "";
		var thirdPartyLibPath = "/ADF/thirdParty/jquery/typeahead/";
		
		// Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
		
		// Append the version to the thirdPartyLibPath
		thirdPartyLibPath = thirdPartyLibPath & arguments.version & "/"; 
	</cfscript>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#typeahead.bundle.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		<cfif arguments.force>
			#outputHTML#
		<cfelse>
			#variables.scriptsService.renderScriptOnce("typeaheadBundle",outputHTML)#
		</cfif>
	</cfoutput>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$loadUploadify
Summary:	
	Loads the uploadify plugin for jQuery
Returns:
	Void
Arguments:
	String - version - 3.2.1
	Boolean - Force
History:
 	2012-12-17 - GAC - Based on scripts 1.1.  Set to default load version 2.9.
--->
<cffunction name="loadUploadify" access="public" output="true" returntype="void" hint="Loads the uploadify plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="3.2.1" hint="JQuery Uploadify plugin version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfscript>
		super.loadUploadify(version=arguments.version, force=arguments.force);
	</cfscript>
</cffunction>


<cffunction name="appendToResourceGroup" returntype="void">
	<cfargument name="content" type="string" required="true">
	<cfargument name="resourceGroup" type="string" required="true">
	<cfargument name="location" type="string" default="foot">
	<cfmodule template="/commonspot/utilities/append-to-resource-group">#arguments.content#</cfmodule>
</cffunction>

</cfcomponent>