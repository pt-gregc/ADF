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
 	scripts_1_0.cfc
Summary:
	Scripts functions for the ADF Library
Version:
	1.0
History:
	2009-06-22 - MFC - Created
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->
<cfcomponent displayname="scripts_1_0" extends="ADF.lib.libraryBase" hint="Scripts functions for the ADF Library">
	
<cfproperty name="version" value="1_0_12">
<cfproperty name="type" value="singleton">
<cfproperty name="scriptsService" injectedBean="scriptsService_1_0" type="dependency">
<cfproperty name="wikiTitle" value="Scripts_1_0">

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
	2011-07-21 - MFC - Force jQuery no conflict when in CS 6.2 or above.
	2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
					   Removed "Force jQuery no conflict" b/c not backwards compatiable with
							custom script code referencing "$".  
--->
<cffunction name="loadJQuery" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.4" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="noConflict" type="boolean" required="false" default="0" hint="JQuery no conflict flag.">

	<cfscript>
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<!--- Check if the header is out yet, or we want to force rendering --->
	<cfif (not variables.scriptsService.isScriptLoaded("jQuery")) OR (arguments.force)>
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/jquery-#arguments.version#.js"></script>
			<!--- // handle no conflict if necessary --->
			<cfif arguments.noConflict>
				<script type="text/javascript">
				// put jQuery into a no conflict mode
				jQuery.noConflict();
				</script>
			</cfif>
		</cfoutput>
		<!--- If we force, then don't record the loaded script --->
		<cfif NOT arguments.force>
			<cfset variables.scriptsService.loadedScript("jQuery")>
		</cfif>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadNiceForm
Summary:
	Loads the nice form headers and converts the CS Form layout
Returns:
	void
Arguments:
	void
History:
	2009-03-12 - RLW - Created
	2014-01-22 - GAC - Replaced the '$' with the jQuery alias
--->
<cffunction name="loadNiceForms" access="public" returntype="void">
<cfif not variables.scriptsService.isScriptLoaded("niceForms")>
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
	<cfset variables.scriptsService.loadedScript("niceForms")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
<cfif (not variables.scriptsService.isScriptLoaded("thickbox")) OR (arguments.force)>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/thickbox/thickbox-#arguments.version#.js"></script>
		<link rel="stylesheet" href="/ADF/thirdParty/jquery/thickbox/thickbox.css" type="text/css" media="screen" />
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("thickbox")>
	</cfif>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
	2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
--->
<cffunction name="loadJQueryUI" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
<cfargument name="version" type="string" required="false" default="1.8" hint="JQuery version to load.">
<cfargument name="themeName" type="string" required="false" default="ui-lightness" hint="UI Theme Name (directory name)">
<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery UI script header to load.">
<cfscript>
	// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
	arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
</cfscript>
<cfif (not variables.scriptsService.isScriptLoaded("jqueryui")) OR (arguments.force)>
	<cfoutput>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/js/jquery-ui-#arguments.version#.custom.js'></script>
	</cfoutput>
	<!--- Verify that the theme directory exists --->
	<cfif DirectoryExists(expandPath("/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
		<cfoutput>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui-#arguments.version#.custom.css' type='text/css' media='screen' />
		</cfoutput>
	</cfif>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("jqueryui")>
	</cfif>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadADFStyles
Summary:	
	Loads the generic ADF styles when needed
Returns:
	Void
Arguments:
	Void
History:
	2009-05-28 - RLW - Created
--->
<cffunction name="loadADFStyles" access="public" returntype="void">
<cfif not variables.scriptsService.isScriptLoaded("ADFStyles")>
	<cfoutput>
		<link rel="stylesheet" href="/ADF/zstyle/ADF.css" type="text/css" media="screen" />
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("ADFStyles")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$loadAutoGrow
Summary:
	Loads the AutoGrow Textarea jQuery Plug-in Headers if not loaded.
Returns:
	None
Arguments:
	String - version - AutoGrow version to load.
History:
	2009-06-18 - GAC - Created
--->
<cffunction name="loadAutoGrow" access="public" output="true" returntype="void" hint="Loads the AutoGrow jQuery Plug-in Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="1.2.2" hint="AutoGrow version to load.">
<cfif not variables.scriptsService.isScriptLoaded("autogrow")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/autogrow/autogrow-#arguments.version#.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("autogrow")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
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
History:
	2009-06-18 - GAC - Created
	2012-09-26 - GAC - Removed the ".packed" fromt he script src to be compatible with the new script file naming convention.
					 - Fixed the default version number
	2015-07-21 - GAC - Updated to use the version folder format
--->
<cffunction name="loadCFJS" access="public" output="true" returntype="void" hint="Loads the CFJS jQuery Plug-in Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="1.1" hint="CFJS version to load.">
<cfif not variables.scriptsService.isScriptLoaded("cfjs")>
	<cfscript>
		// 2011-12-28 - MFC - Make the version backwards compatiable to remove minor build numbers.
		arguments.version = variables.scriptsService.getMajorMinorVersion(arguments.version);
	</cfscript>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/cfjs/#arguments.version#/jquery.cfjs.min.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("cfjs")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$loadTableSorter
Summary:
	Loads the JQuery Tablesorter Plugin Headers if not loaded.
Returns:
	None
Arguments:
	String - version - Tablesorter version to load.
History:
	2009-06-25 - GAC - Created
--->
<cffunction name="loadTableSorter" access="public" output="true" returntype="void" hint="Loads the Tablesorter Plugin Headers if not loaded."> 
<cfargument name="version" type="string" required="false" default="2.0.3" hint="Tablesorter Plugin version to load.">
<cfif not variables.scriptsService.isScriptLoaded("tablesorter")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/tablesorter/tablesorter-#TRIM(arguments.version)#.min.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("tablesorter")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$loadTableSorterTheme
Summary:	
	Loads the JQuery Tablesorter Plugin Themes from the argument.
Returns:
	Void
Arguments:
	String - Tablesorter Theme Name (directory name)
	String - version - Tablesorter version to load.
History:
	2009-06-25 - GAC - Created
--->
<cffunction name="loadTableSorterThemes" access="public" returntype="void" hint="Loads the Tablesorter Plugin Theme Headers if not loaded.">
<cfargument name="themeName" type="string" required="false" default="blue" hint="Tablesorter Theme Name (directory name)">
<cfargument name="version" type="string" required="false" default="2.0.3" hint="Tablesorter Plugin version to load.">
<cfset var themepath = "/ADF/thirdParty/jquery/tablesorter/tablesorter-" & TRIM(arguments.version) & "/themes/" />
<cfif not variables.scriptsService.isScriptLoaded("TableSorterThemes")>
	<!--- Verify the length and that the theme directory exists --->
	<cfif LEN(TRIM(arguments.themeName)) AND FileExists(expandPath("#themepath##TRIM(arguments.themeName)#/style.css"))>
		<cfoutput>
			<link rel="stylesheet" href="#themepath##TRIM(arguments.themeName)#/style.css" type="text/css" media="screen" />
		</cfoutput>
	<cfelse> <!--- default to blue --->
		<cfoutput>
			<link rel="stylesheet" href="#themepath#blue/style1.css" type="text/css" media="screen" />
		</cfoutput>
	</cfif>
	<cfset variables.scriptsService.loadedScript("TableSorterThemes")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$loadTableSorterPager
Summary:	
	Loads the JQuery Tablesorter Pager Addon from the argument.
Returns:
	Void
Arguments:
	String - version - Tablesorter version to load.
History:
	2009-06-25 - GAC - Created
--->
<cffunction name="loadTableSorterPager" access="public" returntype="void" hint="Loads the Tablesorter Plugin Pager addon Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="2.0.3" hint="Tablesorter Plugin version to load.">
<cfset var addonpath = "/ADF/thirdParty/jquery/tablesorter/tablesorter-" & TRIM(arguments.version) & "/addons/pager/" />
<cfif not variables.scriptsService.isScriptLoaded("TablesSorterPager")>
	<cfoutput>
		<script type="text/javascript" src="#addonpath#tablesorter.pager.js"></script>
		<link rel="stylesheet" href="#addonpath#tablesorter.pager.css" type="text/css" media="screen" />
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("TablesSorterPager")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadJQuerySelectboxes
Summary:	
	Loads the Selectboxes JQuery plugin
Returns:
	Void
Arguments:
	String version
History:
	2009-07-29 - RLW - Created
--->
<cffunction name="loadJQuerySelectboxes" access="public" output="true" returntype="void" hint="Loads the JQuery selectboxes plugin."> 
<cfargument name="version" type="string" required="false" default="2.2.4" hint="version to load - defaults to 2.2.4.">
<cfif not variables.scriptsService.isScriptLoaded("selectboxes")>
	<cfoutput>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/selectboxes/jquery.selectboxes-#arguments.version#.min.js'></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("selectboxes")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$loadJCarousel
Summary:
	Loads the JQuery JCarousel Headers if not loaded.
Returns:
	None
Arguments:
	None
History:
	2009-02-04 - MFC - Created
--->
<cffunction name="loadJCarousel" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
<cfargument name="skinName" type="string" required="false" default="tango" hint="">
<cfargument name="force" type="boolean" required="false" default="0" hint="">
<cfif (not variables.scriptsService.isScriptLoaded("jcarousel")) OR (arguments.force)>
	<cfoutput>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.pack.js'></script>
		<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcarousel/jquery.jcarousel.css' type='text/css' media='screen' />
		<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcarousel/skins/#arguments.skinName#/skin.css' type='text/css' media='screen' />
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("jcarousel")>
	</cfif>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$loadGalleryView
Summary:
	Loads the JQuery GalleryView if not loaded.
Returns:
	None
Arguments:
	None
History:
	2009-02-04 - MFC - Created
	2014-04-11 - GAC - Removed bad ending cf ending comment tag
--->
<cffunction name="loadGalleryView" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
<cfargument name="version" type="numeric" required="false" default="1.1" hint="">
<cfargument name="themeName" type="string" required="false" default="light" hint="">
<cfif (not variables.scriptsService.isScriptLoaded("galleryview")) >
	<!--- <cfoutput>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/galleryview/jquery.galleryview-#arguments.version#.js'></script>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/galleryview/jquery.timers-1.1.2.js'></script>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/easing/jquery.easing.1.3.js'></script>
		<link rel='stylesheet' href='/ADF/thirdParty/jquery/galleryview/galleryview.css' type='text/css' media='screen' />
	</cfoutput> --->
	<cfoutput>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/galleryview/jquery-galleryview-#arguments.version#/jquery.galleryview-#arguments.version#-pack.js'></script>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/galleryview/jquery-galleryview-#arguments.version#/jquery.timers-1.1.2.js'></script>
		<!--- render the css for 2.0 --->
		<cfif arguments.version NEQ "1.1">
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/galleryview/jquery-galleryview-#arguments.version#/galleryview.css' type='text/css' media='screen' />
		</cfif>
		<!--- Jquery easing --->
		<script type='text/javascript' src='/ADF/thirdParty/jquery/easing/jquery.easing.1.3.js'></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("galleryview")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$loadSWFObject
Summary:
	Loads the SWFObject Flash Embed Headers if not loaded.
Returns:
	None
Arguments:
	String - version - SWFObject version to load.
History:
	2010-02-25 - GAC - Created
--->
<cffunction name="loadSWFObject" access="public" output="true" returntype="void" hint="Loads the SWFObject Flash Embed Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="2.2" hint="SWFObject version to load.">
<cfif not variables.scriptsService.isScriptLoaded("SWFObject")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/swfobject/swfobject-#arguments.version#.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("SWFObject")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	G. Cronkright
Name:
	$loadjQuerySWFObject
Summary:
	Loads the SWFObject jQuery Plug-in Flash Embed Headers if not loaded.
Returns:
	None
Arguments:
	String - version - jQuery SWFObject version to load.
History:
	2009-09-04 - GAC - Created
	2010-02-25 - GAC - Updated and renamed the function
--->
<cffunction name="loadjQuerySWFObject" access="public" output="true" returntype="void" hint="Loads the SWFObject jQuery Plug-in Flash Embed Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="1.0.9" hint="jQuery SWFObject version to load.">
<!--- // Check if jquery is loaded --->
<cfif NOT variables.scriptsService.isScriptLoaded("jQuery")>
	<cfscript>loadJQuery();</cfscript>
</cfif>
<cfif NOT variables.scriptsService.isScriptLoaded("jQuerySWFObject")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/swfobject/jquery.swfobject-#arguments.version#.min.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("jQuerySWFObject")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
<cfset var thirdPartyLibPath = "/ADF/thirdParty/jquery/qtip">
<!--- Check if the header is out yet, or we want to force rendering --->
<cfif (not variables.scriptsService.isScriptLoaded("qtip")) OR (arguments.force)>
	<cfoutput>
		<script type="text/javascript" src="#thirdPartyLibPath#/#arguments.version#/jquery.qtip.min.js"></script>
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("qtip")>
	</cfif>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
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
Author: 	Ron West
Name:
	$loadJCycle
Summary:	
	Loads the jCycle plugin for jQuery
Returns:
	Void
Arguments:
	String version
History:
 2009-10-20 - RLW - Created
--->
<cffunction name="loadJCycle" access="public" output="true" returntype="void" hint="Loads the jCycle plugin for jQuery"> 
<cfargument name="version" type="string" required="false" default="2.72" hint="jCycle version to load.">
<cfif not variables.scriptsService.isScriptLoaded("jcycle")>
	<cfoutput>
		<script type='text/javascript' src='/ADF/thirdParty/jquery/jcycle/jquery.cycle.all-#arguments.version#.js'></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("jcycle")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadJQueryTools
Summary:	
	Loads the Tools library for various effects
Returns:
	Void
Arguments:
	String tool
History:
 	2009-10-17 - RLW - Created
	2010-02-03 - MFC - Updated path to the CSS to remove from Third Party directory.
	2010-04-06 - MFC - Updated path to the CSS to "style".
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="loadJQueryTools" access="public" output="true" returntype="void" hint="Loads the JQuery tools plugin"> 
	<cfargument name="tool" type="string" required="false" default="all" hint="List of tools to load - leave blank to load entire library">
	
	<cfscript>
		var item = '';
	</cfscript>
	
	<cfif not variables.scriptsService.isScriptLoaded("tools_#arguments.tool#")>
		<cfif arguments.tool neq "all">
			<cfloop list="#arguments.tool#" index="item">
				<cfoutput>
					<script type='text/javascript' src='/ADF/thirdParty/jquery/tools/jquery.tools.#item#.min.js'></script>
					<cfif fileExists("#server.ADF.dir#/thirdParty/jquery/tools/css/#item#-minimal.css")>
						<link href="/ADF/extensions/style/jquery/tools/overlay-minimal.css" rel="stylesheet" type="text/css" />
					</cfif>
				</cfoutput>
			</cfloop>
		<cfelse>
			<cfoutput>
				<script type='text/javascript' src='/ADF/thirdParty/jquery/tools/jquery.tools.min.js'></script>
				<link href="/ADF/extensions/style/jquery/tools/overlay-minimal.css" rel="stylesheet" type="text/css" />
			</cfoutput>
		</cfif>
		<cfset variables.scriptsService.loadedScript("tools_#arguments.tool#")>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	S. Smith
Name:
	$loadMouseMovement
Summary:
	Loads the mouse movement detection script for CFFormProtect if not already loaded.
Returns:
	None
Arguments:
	String - version - mouse movement version to load.
History:
	2009-10-18 - SFS - Created
--->
<cffunction name="loadMouseMovement" access="public" output="true" returntype="void" hint="Loads the mouse movement detection script for CFFormProtect if not already loaded.">
<cfargument name="version" type="string" required="false" default="2.0.1" hint="Mouse Movement script version to load.">
<cfif not variables.scriptsService.isScriptLoaded("mouseMovement")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/cfformprotect/js/mouseMovement-#arguments.version#.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("mouseMovement")>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	S. Smith
Name:
	$loadUsedKeyword
Summary:
	Loads the used keyboard detection script for CFFormProtect if not already loaded.
Returns:
	None
Arguments:
	String - version - used keyboard script version to load.
History:
	2009-10-18 - SFS - Created
--->
<cffunction name="loadUsedKeyboard" access="public" output="true" returntype="void" hint="Loads the used keyboard detection script for CFFormProtect if not already loaded.">
<cfargument name="version" type="string" required="false" default="2.0.1" hint="Used Keyboard script version to load.">
<cfif not variables.scriptsService.isScriptLoaded("usedKeyboard")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/cfformprotect/js/usedKeyboard-#arguments.version#.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("usedKeyboard")>
</cfif>
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
History:
	2009-10-27 - MFC - Created
	2009-11-17 - RLW - Updated to set dynamic ajaxProxy
	2010-02-19 - MFC - Updated the CS 6.0 lightbox framework
	2010-03-01 - MFC - Added IF block to load the browse-all.js in CS 6.0 if not in a CS page.
	2010-04-30 - MFC - Updated the Lightbox framework to resolve issues.
	2010-12-07 - MFC - Updated the LB Properties to verify the request.params variables 
						outside the scriptservice check. This runs the verify for every 
						call to the load ADF LB.
	2011-07-21 - MFC - Run check for if commonspot.lightbox is defined yet.
--->
<cffunction name="loadADFLightbox" access="public" output="true" returntype="void" hint="ADF Lightbox Framework for the ADF Library">
	<cfargument name="version" type="string" required="false" default="1.0" hint="ADF Lightbox version to load">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	
	<cfset var productVersion = ListFirst(ListLast(request.cp.productversion," "),".")>
	
	<!--- Check if jquery is loaded --->
	<cfif (NOT variables.scriptsService.isScriptLoaded("jQuery")) OR (arguments.force)>
		<cfoutput>
		<cfscript>loadJQuery(force=arguments.force);</cfscript>
		</cfoutput>
	</cfif>
	
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
	
	<cfif (NOT variables.scriptsService.isScriptLoaded("ADFLightbox")) OR (arguments.force)>
		<!--- Load the ADF Lightbox Framework script --->
		<cfoutput>
		<script type='text/javascript' src='/ADF/extensions/lightbox/#arguments.version#/js/framework.js'></script>
		<!--- Load lightbox override styles --->
		<link href="/ADF/extensions/lightbox/#arguments.version#/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
		</cfoutput>
				
		<!--- Load the CommonSpot Lightbox when not in version 6.0 --->
		<cfif productVersion LT 6 >
			<cfoutput>
			<!--- Load the CommonSpot 6.0 Lightbox Framework --->
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
				 *	Loads in the Commonspot.util space for CS 5. This exists already in CS 6.
				 *	
				 */
    			// Check if the commonspot.util.dom space exists,
				//	If none, then build this from the Lightbox Util.js
				if ( (typeof commonspot.util == 'undefined') || (typeof commonspot.util.dom == 'undefined') )
				{
					IncludeJs('/ADF/extensions/lightbox/1.0/js/util.js', 'script');
				}
    		</script>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<!--- Load lightbox override styles --->
				<!--- Check if the request page exists for if we are on a CS page --->
				<cfif NOT StructKeyExists(request, "page")>
					<!--- Load the CommonSpot 6.0 Lightbox Framework --->
					<script type='text/javascript' src='/commonspot/javascript/browser-all.js'></script>
				</cfif>
			
				<!--- Setup the CommonSpot 6.0 Lightbox framework --->
				<!--- <cfinclude template="/commonspot/non-dashboard-include.cfm"> --->
				<cfoutput>
				<!--- <script type="text/javascript">
					/* if ((typeof commonspot == 'undefined' || !commonspot.lightbox) && (!top.commonspot || !top.commonspot.lightbox))
						loadNonDashboardFiles();
					else if ( typeof parent.commonspot != 'undefined' ){
						var commonspot = parent.commonspot;
					}
					else if ( typeof top.commonspot != 'undefined' ){
						var commonspot = top.commonspot;
					} */
					
					if (typeof commonspot == 'undefined' || !commonspot.lightbox) 
					{
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
				</script> --->
				<script type="text/javascript">
				<!--
					if (typeof commonspot == 'undefined' || !commonspot.lightbox)
					{	
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
					if (parent.commonspot && typeof newWindow == 'undefined')
					{
						var arrFiles = 
								[
									{fileName: '/commonspot/javascript/lightbox/overrides.js', fileType: 'script', fileID: null},
									{fileName: '/commonspot/javascript/lightbox/window_ref.js', fileType: 'script', fileID: null}
								];
						
						loadDashboardFiles(arrFiles);
					}	
				//-->
				</script>
				
				</cfoutput>
			</cfoutput>
		</cfif>
	
		<cfoutput>
		<script type="text/javascript">
			jQuery(document).ready(function(){ 
				// Set the Jquery to initialize the ADF Lightbox
				initADFLB();
				
				// get local references to objects we need in parent frame
				// commonspot object has state, so we need that instance; others are static, but why load them again
				//var commonspot = parent.commonspot;
				if ( (typeof commonspot != 'undefined') && (typeof commonspot.lightbox != 'undefined') ) {
					commonspot.lightbox.initCurrent(#request.params.width#, #request.params.height#, { title: '#request.params.title#', subtitle: '#request.params.subtitle#', close: 'true', reload: 'true' });
				}
			});
		</script>
		</cfoutput>
	</cfif>
	<cfset variables.ScriptsService.loadedScript("ADFLightbox")>
</cffunction>

<!---
/* ***************************************************************
/*
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
	Version
History:
 	2009-11-04 - MFC - Created
--->
<cffunction name="loadDropCurves" access="public" output="true" returntype="void" hint="Loads the Drop Curves plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="0.1.2" hint="Script version to load.">
	<cfif not variables.scriptsService.isScriptLoaded("dropcurves")>
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/dropcurves/jquery.dropCurves-#arguments.version#.min.js'></script>
		</cfoutput>
		<cfset variables.scriptsService.loadedScript("dropcurves")>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
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
	Version
History:
 	2009-11-05 - MFC - Created
	2009-12-02 - SFS - Added check to make sure jqueryUI is loaded ahead of time
--->
<cffunction name="loadJQueryUIStars" access="public" output="true" returntype="void" hint="Loads the JQuery UI Stars plugin"> 
	<cfargument name="version" type="string" required="false" default="2.1" hint="Script version to load.">
	<!--- Check if jqueryUI is loaded --->
	<cfif NOT variables.scriptsService.isScriptLoaded("jqueryui")>
		<cfoutput>
			<cfscript>loadJQueryUI();</cfscript>
		</cfoutput>
	</cfif>
	<cfif NOT variables.scriptsService.isScriptLoaded("jqueryuistars")>
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/stars/#arguments.version#/ui.stars.min.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/stars/#arguments.version#/ui.stars.min.css' type='text/css' media='screen' />
		</cfoutput>
		<cfset variables.scriptsService.loadedScript("jqueryuistars")>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	RLW
Name:
	$loadSuperFish
Summary:	
	Loads the SuperFish drop down plugin
Returns:
	Void
Arguments:
	Version
History:
 	2009-11-05 - RLW - Created
 	2013-02-20 - SFS - Added force parameter so that the library can be forced to display.
--->
<cffunction name="loadJQuerySuperfish" access="public" output="true" returntype="void" hint="Loads the JQuery UI Stars plugin"> 
	<cfargument name="version" type="string" required="false" default="1.4.8" hint="Script version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Superfish script header to load.">
	<cfif (NOT variables.scriptsService.isScriptLoaded("jquerySuperfish")) OR (arguments.force)>
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/superfish/hoverIntent.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/superfish/jquery.superfish-#arguments.version#.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/superfish/css/superfish.css' type='text/css' media='screen' />
		</cfoutput>
		<!--- If we force, then don't record the loaded script --->
		<cfif NOT arguments.force>
			<cfset variables.scriptsService.loadedScript("jquerySuperfish")>
		</cfif>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
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
	Version
History:
 	2009-12-15 - MFC - Created
--->
<cffunction name="loadJCrop" access="public" output="true" returntype="void" hint="Loads the JQuery Crop plugin"> 
	<!--- Check if jqueryUI is loaded --->
	<cfif NOT variables.scriptsService.isScriptLoaded("jQuery")>
		<cfoutput>
			<cfscript>loadJQuery();</cfscript>
		</cfoutput>
	</cfif>
	<cfif NOT variables.scriptsService.isScriptLoaded("jquerycrop")>
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcrop/js/jquery.Jcrop.min.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcrop/css/jquery.Jcrop.css' type='text/css' media='screen' />
		</cfoutput>
		<cfset variables.scriptsService.loadedScript("jquerycrop")>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
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
--->
<cffunction name="loadJQueryCheckboxes" access="public" output="true" returntype="void" hint="Loads the JQuery checkboxes Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="2.1" hint="JQuery Checkboxes version to load.">
<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Checkboxes script header to load.">
<cfif (not variables.scriptsService.isScriptLoaded("checkboxes")) OR (arguments.force)>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/checkboxes/jquery.checkboxes-#arguments.version#.min.js"></script>
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("checkboxes")>
	</cfif>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
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
--->
<cffunction name="loadJQueryJSON" access="public" output="true" returntype="void" hint="Loads the JQuery JSON Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="2.2" hint="JQuery JSON version to load.">
<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery JSON script header to load.">
<cfif (not variables.scriptsService.isScriptLoaded("jqueryJSON")) OR (arguments.force)>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/json/jquery.json-#arguments.version#.min.js"></script>
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("jqueryJSON")>
	</cfif>
</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadJQueryAutocomplete
Summary:	
	loads the autocomplete jQuery plugin
Returns:
	Void
Arguments:
	Void
History:
 2010-03-31 - RLW - Created
--->
<cffunction name="loadJQueryAutocomplete" access="public" returntype="void">
	<cfif not variables.scriptsService.isScriptLoaded("jqueryAutocomplete")>
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/auto-complete/jquery.metadata.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js'></script>
			<link rel='stylesheet' type='text/css' href='/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.css' />
		</cfoutput>
		<cfset variables.scriptsService.loadedScript("jqueryAutocomplete")>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
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
--->
<cffunction name="loadJQueryCookie" access="public" output="true" returntype="void" hint="Loads the JQuery Cookie plugin if not loaded.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery Cookie script header to load.">
	<cfif (not variables.scriptsService.isScriptLoaded("jqueryCookie")) OR (arguments.force)>
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/cookie/jquery.cookie.js"></script>
		</cfoutput>
		<!--- If we force, then don't record the loaded script --->
		<cfif NOT arguments.force>
			<cfset variables.scriptsService.loadedScript("jqueryCookie")>
		</cfif>
	</cfif>
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
--->
<cffunction name="loadJQueryDataTables" access="public" output="true" returntype="void" hint="Loads the JQuery DataTables Headers if not loaded.">
<cfargument name="version" type="string" required="false" default="1.6.2" hint="JQuery DataTables version to load.">
<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery DataTables script header to load.">
<cfif (not variables.scriptsService.isScriptLoaded("jqueryDataTables")) OR (arguments.force)>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/datatables/js/jquery.dataTables-#arguments.version#.min.js"></script>
		<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/css/demo_page.css' type='text/css' media='screen' />
		<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/css/demo_table_jui.css' type='text/css' media='screen' />
		<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/css/demo_table.css' type='text/css' media='screen' />
	</cfoutput>
	<!--- If we force, then don't record the loaded script --->
	<cfif NOT arguments.force>
		<cfset variables.scriptsService.loadedScript("jqueryDataTables")>
	</cfif>
</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$loadJQueryField
Summary:
	Loads the JQuery Field plugin.
Returns:
	None
Arguments:
	String - version - JQuery Field version to load.
History:
	2010-09-27 - RLW - Created
--->
<cffunction name="loadJQueryField" access="public" output="true" returntype="void" hint="Loads the JQuery Field plugin if not loaded.">
<cfargument name="version" type="string" required="false" default="0.9.8" hint="JQuery Field plugin version to load.">
<cfif not variables.scriptsService.isScriptLoaded("jqueryField")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/field/jquery.field-#arguments.version#.min.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("jqueryField")>
</cfif>
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
History:
	2010-09-27 - RLW - Created
--->
<cffunction name="loadJQueryBlockUI" access="public" output="true" returntype="void" hint="Loads the JQuery BlockUI plugin if not loaded.">
<cfargument name="version" type="string" required="false" default="2.35" hint="JQuery BlockUI plugin version to load.">
<cfif not variables.scriptsService.isScriptLoaded("jQueryBlockUI")>
	<cfoutput>
		<script type="text/javascript" src="/ADF/thirdParty/jquery/blockUI/jquery.blockUI-#arguments.version#.js"></script>
	</cfoutput>
	<cfset variables.scriptsService.loadedScript("jQueryBlockUI")>
</cfif>
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
	Version
History:
 	2010-09-27 - RAK - Created
	2012-01-24 - MFC - Replaced "@import" with "link" tag to load the CSS.
--->
<cffunction name="loadJQueryDatePick" access="public" output="true" returntype="void" hint="Loads the DatePick plugin for jQuery"> 
	#loadJQuery()#
	<cfif not variables.scriptsService.isScriptLoaded("datePick")>
		<cfoutput>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/datepick/jquery.datepick.css' type='text/css' />
			<script type='text/javascript' src='/ADF/thirdParty/jquery/datepick/jquery.datepick.js'></script>
		</cfoutput>
		<cfset variables.scriptsService.loadedScript("datePick")>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
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
	Version
History:
 	2010-07-08 - SFS - Created
--->
<cffunction name="loadJQueryBBQ" access="public" output="true" returntype="void" hint="Loads the BBQ plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="1.2.1" hint="Script version to load.">
	<cfif not variables.scriptsService.isScriptLoaded("bbq")>
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/bbq/jquery.ba-bbq-#arguments.version#.min.js'></script>
		</cfoutput>
		<cfset variables.scriptsService.loadedScript("bbq")>
	</cfif>
</cffunction>

</cfcomponent>