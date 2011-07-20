<!--- 
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
	1.1.0
History:
	2010-10-04 - RAK - Created - New v1.1
						Made massive revisons to script loading everything now goes 
						through one central script loader. Every single function was modified.
	2011-06-24 - GAC - Removed a misplaced double </cfcomponent> end tag
--->
<cfcomponent displayname="scripts_1_1" extends="ADF.lib.scripts.scripts_1_0" hint="Scripts functions for the ADF Library">
	
<cfproperty name="version" default="1_1_0">
<cfproperty name="scriptsService" injectedBean="scriptsService_1_1" type="dependency">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="Scripts_1_1">

<!---
/* ***************************************************************
/*
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
	Version 1.0
History:
 	2010-10-04 - RAK - Created
--->
<cffunction name="setDebugMode" access="public" description="Set to true to display to the screen all the scripts as they load. Also displays when scripts are already loaded.">
	<cfargument name="debugMode" type="boolean" required="true">
	<cfset request.ADFScriptsDebugging = debugMode>
</cffunction>

<!---
/* *************************************************************** */
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
	2011-01-19 - RAK - Updated to use findScript in scriptsService
	2011-06-29 - MFC - Force jQuery no conflict when in CS 6.2 or above.
--->
<cffunction name="loadJQuery" access="public" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.4" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfargument name="noConflict" type="boolean" required="false" default="0" hint="JQuery no conflict flag.">
	<cfscript>
		var outputHTML = "";
		var findScript = variables.scriptsService.findScript(arguments.version,"jquery","jquery-",".js");
		
		// 2011-06-29 - MFC - Force jQuery no conflict when in CS 6.2 or above.
		if ( application.ADF.csVersion GTE 6.2 )
			arguments.noConflict = true;
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
--->
<cffunction name="loadNiceForms" access="public" returntype="void">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script language="javascript" type="text/javascript" src="/ADF/thirdParty/prettyForms/prettyForms.js"></script>
			<script type="text/javascript">
				jQuery(document).ready(function($) {
					$("input[name='submitbutton']").attr("value", "Save");
					$("span[id^='tabDlg'] > table").addClass("csForms");
					$("form[name='dlgform']").addClass("csForms");
					//jQuery(".cs_default_form").attr("class", "niceform");
					prettyForms();
					//$(".clsPushButton").addClass("blue-pill");
					<cfif find("login.cfm", cgi.script_name)>
						// change the login button text
						$(".clsPushButton").attr("value", "Login");
					</cfif>
				});
			</script>
			<link rel="stylesheet" type="text/css" media="all" href="/ADF/thirdParty/prettyForms/prettyForms.css" />
			<link rel="stylesheet" type="text/css" media="all" href="/commonspot/commonspot.css" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("niceForms",outputHTML)#
	</cfoutput>
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
	2010-12-21 - MFC - Removed the "min" from the script loading.
--->
<cffunction name="loadJQueryUI" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="string" required="false" default="1.8" hint="JQuery version to load.">
	<cfargument name="themeName" type="string" required="false" default="ui-lightness" hint="UI Theme Name (directory name)">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery UI script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/js/jquery-ui-#arguments.version#.custom.js'></script>
			<cfif DirectoryExists(expandPath("/_cs_apps/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
				<link rel='stylesheet' href='/_cs_apps/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui-#arguments.version#.custom.css' type='text/css' media='screen' />
			<cfelse>
				<cfif DirectoryExists(expandPath("/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#"))>
					<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/jquery-ui-#arguments.version#/css/#arguments.themeName#/jquery-ui-#arguments.version#.custom.css' type='text/css' media='screen' />
				</cfif>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/zstyle/ADF.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("ADFStyles",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/autogrow/autogrow-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("autogrow",outputHTML)#
	</cfoutput>
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
--->
<cffunction name="loadCFJS" access="public" output="true" returntype="void" hint="Loads the CFJS jQuery Plug-in Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.1.12" hint="CFJS version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/cfjs/cfjs.packed-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("cfjs",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/tablesorter/tablesorter-#TRIM(arguments.version)#.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("tablesorter",outputHTML)#
	</cfoutput>
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
		#variables.scriptsService.renderScriptOnce("TableSorterThemes",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="#addonpath#tablesorter.pager.js"></script>
			<link rel="stylesheet" href="#addonpath#tablesorter.pager.css" type="text/css" media="screen" />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("TablesSorterPager",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/selectboxes/jquery.selectboxes-#arguments.version#.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("selectboxes",outputHTML)#
	</cfoutput>
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
--->
<cffunction name="loadGalleryView" access="public" output="true" returntype="void" hint="Loads the JQuery UI Headers if not loaded."> 
	<cfargument name="version" type="numeric" required="false" default="1.1" hint="">
	<cfargument name="themeName" type="string" required="false" default="light" hint="">
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
		#variables.scriptsService.renderScriptOnce("galleryview",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/swfobject/swfobject-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("swfObject",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfoutput>
		#loadJQuery()#
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/swfobject/jquery.swfobject-#arguments.version#.min.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jQuerySWFObject",outputHTML)#
	</cfoutput>
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
--->
<cffunction name="loadQTip" access="public" output="true" returntype="void" hint="Loads the JQuery Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.0" hint="JQuery version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/qtip/jquery.qtip-#arguments.version#.min.js"></script>
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
/* ***************************************************************
/*
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcycle/jquery.cycle.all-#arguments.version#.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jcycle",outputHTML)#
	</cfoutput>
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
--->
<cffunction name="loadJQueryTools" access="public" output="true" returntype="void" hint="Loads the JQuery tools plugin"> 
	<cfargument name="tool" type="string" required="false" default="all" hint="List of tools to load - leave blank to load entire library">
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
		#variables.scriptsService.renderScriptOnce("tools_#arguments.tool#",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/cfformprotect/js/mouseMovement-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("mouseMovement",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/cfformprotect/js/usedKeyboard-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("usedKeyboard",outputHTML)#
	</cfoutput>
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
	2010-12-21 - MFC - Updated the codes for HTML and scripts.
						Commented IF condition for loading the "commonspot/javascript/browser-all.js" link.
	2011-04-08 - RAK - Added includes to 6.1 overrides if this is in fact 6.1 or greater.
	2011-07-14 - MFC - Run check for if commonspot.lightbox is defined yet
--->
<cffunction name="loadADFLightbox" access="public" output="true" returntype="void" hint="ADF Lightbox Framework for the ADF Library">
	<cfargument name="version" type="string" required="false" default="1.0" hint="ADF Lightbox version to load">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery script header to load.">
	<cfset var productVersion = ListFirst(ListLast(request.cp.productversion," "),".")>
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
	         <link href="/ADF/extensions/lightbox/#arguments.version#/css/lightbox_overrides_6_1.css" rel="stylesheet" type="text/css">
			<cfelse>
	         <link href="/ADF/extensions/lightbox/#arguments.version#/css/lightbox_overrides.css" rel="stylesheet" type="text/css">
			</cfif>
		</cfoutput>
			<!--- Load the CommonSpot Lightbox when not in version 6.0 --->
			<cfif productVersion LT 6 >
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
			<cfelse>
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
				</cfoutput>
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
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadDropCurves" access="public" output="true" returntype="void" hint="Loads the Drop Curves plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="0.1.2" hint="Script version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/dropcurves/jquery.dropCurves-#arguments.version#.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("dropcurves",outputHTML)#
	</cfoutput>
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
	2011-02-02 - RAK - Updated default to 3.0
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryUIStars" access="public" output="true" returntype="void" hint="Loads the JQuery UI Stars plugin"> 
	<cfargument name="version" type="string" required="false" default="3.0" hint="Script version to load.">
	<cfset var outputHTML = "">
	<cfoutput>
		#loadJQueryUI()#
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/ui/stars/#arguments.version#/ui.stars.min.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/ui/stars/#arguments.version#/ui.stars.min.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("jqueryuistars",outputHTML)#
	</cfoutput>
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
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQuerySuperfish" access="public" output="true" returntype="void" hint="Loads the JQuery UI Stars plugin"> 
	<cfargument name="version" type="string" required="false" default="1.4.8" hint="Script version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/superfish/hoverIntent.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/superfish/jquery.superfish-#arguments.version#.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/superfish/css/superfish.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("jquerySuperfish",outputHTML)#
	</cfoutput>
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
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJCrop" access="public" output="true" returntype="void" hint="Loads the JQuery Crop plugin"> 
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jcrop/js/jquery.Jcrop.min.js'></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/jcrop/css/jquery.Jcrop.css' type='text/css' media='screen' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("jquerycrop",outputHTML)#
	</cfoutput>
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
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/auto-complete/jquery.metadata.js'></script>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.min.js'></script>
			<link rel='stylesheet' type='text/css' href='/ADF/thirdParty/jquery/auto-complete/jquery.auto-complete.css' />
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jqueryAutocomplete",outputHTML)#
	</cfoutput>
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
--->
<cffunction name="loadJQueryDataTables" access="public" output="true" returntype="void" hint="Loads the JQuery DataTables Headers if not loaded.">
	<cfargument name="version" type="string" required="false" default="1.6.2" hint="JQuery DataTables version to load.">
	<cfargument name="force" type="boolean" required="false" default="0" hint="Forces JQuery DataTables script header to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/datatables/js/jquery.dataTables-#arguments.version#.min.js"></script>
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/css/demo_page.css' type='text/css' media='screen' />
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/css/demo_table_jui.css' type='text/css' media='screen' />
			<link rel='stylesheet' href='/ADF/thirdParty/jquery/datatables/css/demo_table.css' type='text/css' media='screen' />
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
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryBBQ" access="public" output="true" returntype="void" hint="Loads the BBQ plugin for jQuery"> 
	<cfargument name="version" type="string" required="false" default="1.2.1" hint="Script version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/bbq/jquery.ba-bbq-#arguments.version#.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("bbq",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryDatePick" access="public" output="true" returntype="void" hint="Loads the DatePick plugin for jQuery"> 
	<cfset var outputHTML = "">
	#loadJQuery()#
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<style type='text/css'>@import '/ADF/thirdParty/jquery/datepick/jquery.datepick.css';</style>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/datepick/jquery.datepick.pack.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("datePick",outputHTML)#
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

History:
	2010-09-27 - RLW - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryBlockUI" access="public" output="true" returntype="void" hint="Loads the JQuery BlockUI plugin if not loaded.">
	<cfargument name="version" type="string" required="false" default="2.35" hint="JQuery BlockUI plugin version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type="text/javascript" src="/ADF/thirdParty/jquery/blockUI/jquery.blockUI-#arguments.version#.js"></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("jQueryBlockUI",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
History:
 	2010-10-26 - RAK - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadUploadify" access="public" output="true" returntype="void" hint="Loads the uploadify plugin for jQuery"> 
	<cfset var outputHTML = "">
	<cfoutput>
		#loadSWFObject()#
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<link rel="stylesheet" href="/ADF/thirdParty/jquery/uploadify/uploadify.css" type="text/css" media="screen" />
			<script type='text/javascript' src='/ADF/thirdParty/jquery/uploadify/jquery.uploadify.v2.1.0.min.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("uploadify",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
History:
 	2010-11-09 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadSimplePassMeter" access="public" output="true" returntype="void" hint="Loads the simplePassMeter plugin for jQuery">
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
	#variables.scriptsService.renderScriptOnce("simplePassMeter",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
History:
 	2010-12-13 - GAC - Created
	2011-03-08 - GAC - Updated the renderScriptOnce with correct variable path
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryHighlight" access="public" output="true" returntype="void" hint="Loads the Highlight plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="3.0.0" hint="Script version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/highlight/jquery.highlight-#arguments.version#.yui.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("highlight",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
History:
 	2011-03-08 - GAC - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadjQueryTimeAgo" access="public" output="true" returntype="void" hint="Loads the TimeAgo (automatically updating fuzzy timestamps) plugin for jQuery">
	<cfargument name="version" type="string" required="false" default="0.9.3" hint="Script version to load.">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/timeago/jquery.timeago-#arguments.version#.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
	#variables.scriptsService.renderScriptOnce("timeago",outputHTML)#
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

History:
 	2011-05-31 - RAK - Created
 	2011-06-13 - RAK - removed a bug where I was defining a var after a output was opened
--->
<cffunction name="loadJSTree" access="public" returntype="void" hint="Loads the jsTree plugin">
	<cfscript>
		var outputHTML = "";
	</cfscript>
	<cfoutput>
		<cfscript>
			//Dependencies
			loadJQuery();
			loadJQueryCookie();
			loadJQueryHotkeys();
		</cfscript>
	</cfoutput>
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/jsTree/jquery.jstree.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jstree",outputHTML)#
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

History:
 	2011-05-31 - RAK - Created
--->
<cffunction name="loadJQueryHotkeys" access="public" returntype="void" hint="Loads jQuery Hotkeys plugin">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<cfoutput>
			<script type='text/javascript' src='/ADF/thirdParty/jquery/hotkeys/jquery.hotkeys.js'></script>
		</cfoutput>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jQueryHotkeys",outputHTML)#
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
	None
History:
	2011-06-01 - MTT - Created
	2011-06-24 - GAC - Added CFOUTPUTS around the renderScriptOnce method call
--->
<cffunction name="loadJQueryDump" access="public" output="true" returntype="void" hint="Loads the dump plugin for jquery">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<script type="text/javascript" src="/ADF/thirdparty/jquery/dump/jquery.dump.js"></script>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jQueryDump",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
	None
History:
	2011-06-22 - MTT - Created
	2011-07-20 - RAK - Added cfOutput to the code so that it will actually print the results
--->
<cffunction name="loadJQueryDoTimeout" access="public" output="true" returntype="void" hint="Loads the do timeout plugin for jquery">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<script type="text/javascript" src="/ADF/thirdparty/jquery/dotimeout/jquery.dotimeout.plugin.js"></script>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jQueryDoTimeout",outputHTML)#
	</cfoutput>
</cffunction>

<!---
/* ***************************************************************
/*
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
	None
History:
	2011-06-22 - MTT - Created
	2011-07-20 - RAK - Added cfOutput to the code so that it will actually print the results
--->
<cffunction name="loadJQueryTextLimit" access="public" output="true" returntype="void" hint="Loads the text limit plugin for jquery">
	<cfset var outputHTML = "">
	<cfsavecontent variable="outputHTML">
		<script type="text/javascript" src="/ADF/thirdparty/jquery/textlimit/jquery.textlimit.plugin.js"></script>
	</cfsavecontent>
	<cfoutput>
		#variables.scriptsService.renderScriptOnce("jQueryTextLimit",outputHTML)#
	</cfoutput>
</cffunction>

</cfcomponent>