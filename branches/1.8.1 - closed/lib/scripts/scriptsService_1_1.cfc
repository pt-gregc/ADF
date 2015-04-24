<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2015.
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
	scriptsService_1_1.cfc
Summary:
	Scripts Service functions for the ADF Library
Version:
	1.1
History:
	2010-12-10 - RAK - Created
--->
<cfcomponent displayname="scriptsService_1_1" extends="ADF.lib.scripts.scriptsService_1_0" hint="Scripts Service functions for the ADF Library">

<cfproperty name="version" value="1_1_5">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="ScriptsService_1_1">

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan kahn
Name:
	$renderScriptOnce
Summary:
	Given a script name and the html for the script it will determine
		if the script has already been loaded utilizing javascript.
	If it has not been loaded it loads the script and keeps track of the load.
	If it has been loaded it does nothing.
Returns:
	Void
Arguments:
	String - scriptName
	String - outputHTML
History:
 	2010-10-04 - RAK - Created
 	2010-12-10 - RAK - Updated so this will be compatible with previous version and dups will not exist!
	2010-12-21 - MFC - Removed the hard coded force debugging.
	2010-03-27 - MFC - Output the scripts directly when in IE, not through JavaScript.
	2011-06-29 - RAK - Fixed a bug where we were not removing single line comments from scripts which was commenting out code when we removed line breaks.
	2011-07-13 - DRM - Added escaping of returns in addition to newlines
	2015-04-23 - GAC - Added an option to disable the Javascript script loader
--->
<cffunction name="renderScriptOnce" access="public" output="true" returntype="void" hint="Given unescaped outputHML and script name handles adding code to the page">
	<cfargument name="scriptName" type="string" required="true" hint="Name of the script that is being ran">
	<cfargument name="outputHTML" type="string" required="true" hint="HTML to have outputted to the screen">
	<cfargument name="disableJSloader" type="boolean" required="false" default="false" hint="Flag to bypass the javascript loader but still only render the script once.">
	
	<cfscript>
		if ( !StructKeyExists(request,"ADFScriptsDebugging") )
		{
			request.ADFScriptsDebugging = false;
		}
	</cfscript>
	
	<cfif !isScriptLoaded(arguments.scriptName)>
		<cfscript>
			loadedScript(arguments.scriptName);
			//Clean the arguments.outputHTML for javascript strings
			arguments.outputHTML = Trim(arguments.outputHTML);
			
			// 2011-03-27 - MFC - Output the scripts directly when in IE, not through the JavaScript loader
			//   - Detect if IE to not load through JS
			if ( ListContains(CGI.HTTP_USER_AGENT, "MSIE") )
				arguments.disableJSloader = true;
		</cfscript>
		
		<cfif arguments.disableJSloader>
			<cfoutput>#arguments.outputHTML#</cfoutput>
		<cfelse>
			<!--- Else use JS to load through all other browsers --->
			<cfscript>
				//	Removing single line script comments because it comments code out when we remove line breaks! -> //
				arguments.outputHTML = ReReplace(arguments.outputHTML, '//[^\r\n]*', '', "all");

				// escape forward slashes and single quotes
				arguments.outputHTML = Replace(arguments.outputHTML, '/', '\/', "all");
				arguments.outputHTML = Replace(arguments.outputHTML, "'", "\'", "all");

				// kill rtns, newlines, and tabs
				arguments.outputHTML = ReReplace(arguments.outputHTML,'[\r\n\t]','',"all");
			</cfscript>
			<cfoutput>
				<!--- If no scripts have been loaded yet make a new array of scriptsLoaded --->
				<script type="text/javascript">
					if(typeof scriptsLoaded === 'undefined'){
						var scriptsLoaded= new Array();
					}
					//Load #arguments.scriptName# only once.
					if(!("#arguments.scriptName#" in scriptsLoaded)){
						document.write('#arguments.outputHTML#'+'<script type="text/javascript"><\/script>');
						scriptsLoaded["#arguments.scriptName#"] = true;
						<cfif request.ADFScriptsDebugging>
								document.write("Loading: #arguments.scriptName#\<br/\>");
							}else{
								document.write("#arguments.scriptName# already loaded\<br/\>");
						</cfif>
						}
				</script>
			</cfoutput>
		</cfif> 
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Ryan Kahn
Name:
	$findScript
Summary:	
	Finds the closest matching script to the version number in the filesystem
Returns:
	struct
Arguments:
	version - Req - version number to search for (only accepts 0-9 and periods)
	defaultDirectory - Req - Default directory to search for
	preamble - the text in the filename that goes before the version number to be found. ex: jquery-
	postamble - The text in the filename that goes after the version number ex: .custom.js
History:
 	2011-01-18 - RAK - Created
 	2011-05-10 - RAK - Modified findScript to trim out the min prior to checking to see if there is anything other than 0-9 and .
	2011-07-14 - MFC - Renamed cache variable to be under ADF struct, "application.ADF.cache".
	2012-07-13 - MFC - Added the "allowoverwrite" flag to "true" on the StructInsert commands to avoid errors.
	2013-10-29 - GAC - Added a check to make sure the application.ADF.cache is available
--->
<cffunction name="findScript" access="public" returntype="struct" hint="Finds the closest matching script to the version number in the filesystem">
	<cfargument name="version" type="string" required="true" default="1.0" hint="version number to search for (only accepts 0-9 and periods)">
	<cfargument name="defaultDirectory" type="string" required="true" default="" hint="Default directory to search for">
	<cfargument name="preamble" type="string" required="false" default="" hint="The text in the filename that goes before the version number to be found. ex: jquery-">
	<cfargument name="postamble" type="string" required="false" default=".js" hint="The text in the filename that goes after the version number ex: .custom.js">
	<!---
		To goal is to locate a version of the file that matches the script order of operations:
			1. Check the _cs_apps directory
			2. Default directory
			3. Trim off the least significant portion of the version number
			IF(Len(versionNumber)){
				repeat 1-3 until match
			}else{
				return failure information
			}
	--->
	<cfscript>
		var rtn = StructNew();
		var tempVersion = arguments.version;
		var lastIndex = -1;
		var csAppsDir = "#request.site.csappsweburl#thirdParty/#defaultDirectory#/";
		var adfDir = "/ADF/thirdParty/#defaultDirectory#/";
		var tempFile = "";
		var cacheString = "#defaultDirectory#/#preamble##version##postamble#";
		tempVersion = Replace(tempVersion,"min","","ALL");
		rtn.success=false;
		if(REFind("[^0-9.]",tempVersion)){
			rtn.message = "Version information can only contain 0-9 and periods.";
			return rtn;
		}
		rtn.success=true;
		
		// Make sure the application.ADF.cache is available
		if ( !StructKeyExists(application.ADF,"cache") )
			application.ADF.cache = StructNew();
			
		if( !StructKeyExists(application.ADF.cache,"scriptsCache") ) {
			application.ADF.cache.scriptsCache = StructNew();
		}
		else if ( StructKeyExists(application.ADF.cache.scriptsCache,cacheString) and Len(StructFind(application.ADF.cache.scriptsCache,cacheString)) ) {
			rtn.message =  StructFind(application.ADF.cache.scriptsCache,cacheString);
			return rtn;
		}
		while(Len(tempVersion)){
			// Search the cs_apps directory
			tempFile = "#csAppsDir##preamble##tempVersion##postamble#";
			if(FileExists(ExpandPath(tempFile))){
				rtn.message = tempFile;
				StructInsert(application.ADF.cache.scriptsCache,cacheString,tempFile,true);
				return rtn;
			}
			// Search the cs_apps directory for the Min
			tempFile = "#csAppsDir##preamble##tempVersion#.min#postamble#";
			if(FileExists(ExpandPath(tempFile))){
				rtn.message = tempFile;
				StructInsert(application.ADF.cache.scriptsCache,cacheString,tempFile,true);
				return rtn;
			}

			// Search the adf apps directory
			tempFile = "#adfDir##preamble##tempVersion##postamble#";
			if(FileExists(ExpandPath(tempFile))){
				rtn.message = tempFile;
				StructInsert(application.ADF.cache.scriptsCache,cacheString,tempFile,true);
				return rtn;
			}

			// Search the adf apps directory for the Min
			tempFile = "#adfDir##preamble##tempVersion#.min#postamble#";
			if(FileExists(ExpandPath(tempFile))){
				rtn.message = tempFile;
				StructInsert(application.ADF.cache.scriptsCache,cacheString,tempFile,true);
				return rtn;
			}

			//	Preform trim
			lastIndex = tempVersion.lastIndexOf('.');
			if(lastIndex neq -1){
				tempVersion = left(tempVersion,lastIndex);
			}else{
				tempVersion = "";
			}
		}
		StructInsert(application.ADF.cache.scriptsCache,cacheString,"",true);
		//Uh oh, we couldnt find it.
		application.ADF.utils.logAppend("Unable to find script #defaultDirectory#/#preamble##version##postamble#","findScript-error.txt");
		rtn.message = "Unable to find script. #defaultDirectory#/#preamble##version##postamble#";
		rtn.success = false;
		return rtn;
	</cfscript>
</cffunction>

</cfcomponent>