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
	scripts_1_2.cfc
Summary:
	Scripts functions for the ADF Library
Version:
	1.2
History:
	2012-12-07 - RAK - Created - New v1.2
--->
<cfcomponent displayname="scripts_1_2" extends="ADF.lib.scripts.scripts_1_1" hint="Scripts functions for the ADF Library">
	
<cfproperty name="version" default="1_2_2">
<cfproperty name="scriptsService" injectedBean="scriptsService_1_1" type="dependency">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Scripts_1_2">

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
--->
<cffunction name="loadJQuery" access="public" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.8" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="noConflict" type="boolean" required="false" default="0" hint="JQuery no conflict flag.">
	<cfscript>
		super.loadJQuery(version=arguments.version, force=arguments.force, noConflict=arguments.noConflict);
	</cfscript>
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
	2009-07-31 - MFC - Based on 1.1. Changed the theme loading folders for 1.9.
--->
<cffunction name="loadJQueryUI" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="1.9" hint="JQuery version to load.">
	<cfargument name="themeName" type="string" required="false" default="ui-lightness" hint="UI Theme Name (directory name)">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery UI script header to load.">
	<cfscript>
		var outputHTML = "";
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<!--- Check the version, if less than "1.9", then call the Scripts 1.1 function to load --->
	<cfif arguments.version LTE 1.8>
		<cfscript>
			super.loadJQueryUI(version=arguments.version, themeName=arguments.themeName, force=arguments.force);
		</cfscript>
	<cfelse>
		<cfsavecontent variable="outputHTML">
			<cfoutput>
				<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/js/jquery-ui-#arguments.version#.js'></script>
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
				#variables.scriptsService.renderScriptOnce("jQueryUI",outputHTML)#
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
--->
<cffunction name="loadJQueryUIForm" access="public" output="true" returntype="void" hint="Loads the form plugin for jquery ui">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<script type="text/javascript" src="/ADF/thirdParty/jquery/ui/form/jquery.ui.form.js"></script>
	</cfsavecontent>
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
--->
<cffunction name="loadJQueryEasing" access="public" output="true" returntype="void" hint="Loads the Easing plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="1.3" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/easing/">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#thirdPartyLibPath#jquery.easing-#arguments.version#.pack.js"></script>	
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

</cfcomponent>