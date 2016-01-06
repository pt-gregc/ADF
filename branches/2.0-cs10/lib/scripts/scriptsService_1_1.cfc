<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2016.
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
	2015-04-27 - GAC - Added jsCommentStripper and its processing and helper functions
	2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
--->
<cfcomponent displayname="scriptsService_1_1" extends="scriptsService_1_0" hint="Scripts Service functions for the ADF Library">

<cfproperty name="version" value="1_1_7">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="ScriptsService_1_1">

<cfscript>
	// init variable for jsCommentStripper
	variables.jsCSoutputArray = ArrayNew(1);
</cfscript>

<!---
/* *************************************************************** */
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
	Boolean - disableJSloader
	Boolean - renderInline
History:
 	2010-10-04 - RAK - Created
 	2010-12-10 - RAK - Updated so this will be compatible with previous version and dups will not exist!
	2010-12-21 - MFC - Removed the hard coded force debugging.
	2010-03-27 - MFC - Output the scripts directly when in IE, not through JavaScript.
	2011-06-29 - RAK - Fixed a bug where we were not removing single line comments from scripts which was commenting out code when we removed line breaks.
	2011-07-13 - DRM - Added escaping of returns in addition to newlines
	2015-04-23 - GAC - Added an option to disable the Javascript script loader
	2015-04-28 - GAC - Added a flag to use cfhtmlhead to render the generated scripts in the HEAD of the page
					 - Added jsCommentStripper() to remove comments from generated JS code. 
--->
<cffunction name="renderScriptOnce" access="public" output="true" returntype="void" hint="Given unescaped outputHML and script name handles adding code to the page">
	<cfargument name="scriptName" type="string" required="true" hint="Name of the script that is being ran">
	<cfargument name="outputHTML" type="string" required="true" hint="HTML to have outputted to the screen">
	<cfargument name="disableJSloader" type="boolean" required="false" default="false" hint="Flag to bypass the javascript loader but still only render the script once.">
	<cfargument name="renderInHead" type="boolean" required="false" default="false" hint="Flag to render the script in the document head.">

	<cfscript>
		var renderScript = "";
		
		if ( !StructKeyExists(request,"ADFScriptsDebugging") )
			request.ADFScriptsDebugging = false;
			
		if ( Application.ADF.SiteDevMode AND structKeyExists(Request.Params, "ADFscriptsDebug") and Request.Params.ADFscriptsDebug eq 1)
			request.ADFScriptsDebugging = true;
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
		
		<cfsavecontent variable="renderScript">
		<cfif arguments.disableJSloader>
			<cfoutput>#arguments.outputHTML#</cfoutput>
		<cfelse>
			<!--- // Else use JS to load through all other browsers --->
			<cfscript>
					// TODO :: TEST THE FOLLOWING jsCommentStripper() METHOD ::
					// This function removes all JS Comments but allow external URLs to remain 
					// (with the REGEX method  below single line comments // and URLs https:// both get stripped out ) 
					//arguments.outputHTML = jsCommentStripper(str=arguments.outputHTML);
					
					//	Removing single line script comments because it comments code out when we remove line breaks! -> //
					arguments.outputHTML = ReReplace(arguments.outputHTML, '//[^\r\n]*', '', "all");
	
					// escape forward slashes and single quotes
					arguments.outputHTML = Replace(arguments.outputHTML, '/', '\/', "all");
					arguments.outputHTML = Replace(arguments.outputHTML, "'", "\'", "all");
	
					// kill rtns, newlines, and tabs
					arguments.outputHTML = ReReplace(arguments.outputHTML,'[\r\n\t]','',"all");
				</cfscript>
				<cfoutput>
					<!--- // If no scripts have been loaded yet make a new array of scriptsLoaded --->
					<cfif request.ADFScriptsDebugging>
					<!-- // RenderInHead: #arguments.renderInHead# -->
					</cfif>
					<script type="text/javascript">
						if(typeof scriptsLoaded === 'undefined')
						{
							var scriptsLoaded= new Array();
						}
						//Load #arguments.scriptName# only once.
						if(!("#arguments.scriptName#" in scriptsLoaded))
						{
							document.write('#arguments.outputHTML#'+'<script type="text/javascript"><\/script>');
							scriptsLoaded["#arguments.scriptName#"] = true;
						<cfif request.ADFScriptsDebugging>
							document.write("Loading: #arguments.scriptName#\<br/\>");
						}
						else
						{
							document.write("#arguments.scriptName# already loaded\<br/\>");
						</cfif>
						}
					</script>
				</cfoutput>
			</cfif> 
		</cfsavecontent>
		<cfif LEN(TRIM(renderScript))>
			<cfif arguments.renderInHead>
				<cfhtmlhead text="#TRIM(renderScript)#">
			<cfelse>
				<cfoutput>#TRIM(renderScript)#</cfoutput>
			</cfif>
		</cfif>
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
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

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$jsCommentStripper
Summary:	
	Finds and removes javascript comments from javascript code that is 
	generated by CFML functions and templates
	
	Based on JS version stripcomments.js by Mike Moagrius
	https://github.com/moagrius/stripcomments/blob/master/strip-comments.js
Returns:
	string
Arguments:
	String - Str
History:
 	2015-04-24 - GAC - Created
--->
<cffunction name="jsCommentStripper" returntype="string">
	<cfargument name="str" type="string" default="" required="false">
	
	<cfscript>
		var string = arguments.str;
		var length = 0;
		var position = 0;

		variables.jsCSoutputArray = ArrayNew(1);
		
		_jsCS_process(str=arguments.str);
		
		if ( ArrayLen(variables.jsCSoutputArray) )
			string = ArrayToList(variables.jsCSoutputArray,""); 
		
		return string;
	</cfscript>	
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///       jsCommentStripper String Processing Functions       /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!--- 
	_jsCS_process(str)
 --->
<cffunction name="_jsCS_process" returntype="void" access="private">
	<cfargument name="str" type="string" default="" required="false">

	<cfscript>
		var position = 0;
		
		while ( !_jsCS_atEnd(str=arguments.str,pos=position) ) 
		{
			position = _jsCS_processDoubleQuotedString(str=arguments.str,pos=position);
			position = _jsCS_processSingleQuotedString(str=arguments.str,pos=position);
			position = _jsCS_processSingleLineComment(str=arguments.str,pos=position);
			position = _jsCS_processMultiLineComment(str=arguments.str,pos=position);
			
			if ( !_jsCS_atEnd(str=arguments.str,pos=position) ) 
			{
				_jsCS_add(str=arguments.str,pos=position);
				position = _jsCS_next(pos=position);
			}
		}
	</cfscript>
</cffunction>

<!--- 
	_jsCS_processDoubleQuotedString(str,pos)
 --->
<cffunction name="_jsCS_processDoubleQuotedString" returntype="numeric">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var DOUBLE_QUOTE = '"';
		var position = arguments.pos;
		var currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
	
		if ( currChar == DOUBLE_QUOTE ) 
		{
			_jsCS_add(str=arguments.str,pos=position);
			position = _jsCS_next(pos=position);
			
			while ( !_jsCS_atEnd(str=arguments.str,pos=position) ) 
			{
				currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
				if ( currChar == DOUBLE_QUOTE && !_jsCS_isEscaping(str=arguments.str,pos=position) ) 
					return position;
				
				_jsCS_add(str=arguments.str,pos=position);
				position = _jsCS_next(pos=position); 
			}
		}
		return position;
	</cfscript>
</cffunction>

<!--- 
	_jsCS_processSingleQuotedString(str,pos)
 --->
<cffunction name="_jsCS_processSingleQuotedString" returntype="numeric">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var SINGLE_QUOTE = "'";
		var position = arguments.pos;
		var currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
	
		if ( currChar == SINGLE_QUOTE ) 
		{
			_jsCS_add(str=arguments.str,pos=position);
			position = _jsCS_next(pos=position);

			while (!_jsCS_atEnd(str=arguments.str,pos=position) ) {
				currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
				
				if ( currChar == SINGLE_QUOTE && !_jsCS_isEscaping(str=arguments.str,pos=position) ) 
					return position;
				
				_jsCS_add(str=arguments.str,pos=position);
				position = _jsCS_next(pos=position); 
			}
		}
		return position;
	</cfscript>
</cffunction>

<!--- 
	_jsCS_processSingleLineComment(str,pos)
 --->
<cffunction name="_jsCS_processSingleLineComment" returntype="numeric">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var SLASH = '/';
		var NEW_LINE = '\n';
		var CARRIAGE_RETURN = '\r';
		var position = arguments.pos;
		var currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
		var nextChar = _jsCS_getNextCharacter(str=arguments.str,pos=position);
		
		if ( currChar == SLASH ) 
		{
			if ( nextChar == SLASH ) 
			{
				if ( !_jsCS_atEnd(str=arguments.str,pos=position) )
				{
					position = _jsCS_next(pos=position); 
					while ( !_jsCS_atEnd(str=arguments.str,pos=position) )
					{
						position = _jsCS_next(pos=position);
						if ( !_jsCS_atEnd(str=arguments.str,pos=position) )
						{
							currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
							if ( ArrayLen(REMatch(NEW_LINE,currChar)) || ArrayLen(REMatch(CARRIAGE_RETURN,currChar)) ) 
									return position;
						}
					}
				}
			}
		}
		return position;
	</cfscript>
</cffunction>

<!--- 
	_jsCS_processMultiLineComment(str,pos)
 --->
<cffunction name="_jsCS_processMultiLineComment" returntype="numeric">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var SLASH = '/';
		var STAR = '*';
		var position = arguments.pos;
		var currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
		var nextChar = _jsCS_getNextCharacter(str=arguments.str,pos=position);

		if ( currChar EQ SLASH) 
		{
			if ( nextChar EQ STAR) 
			{			
				while ( !_jsCS_atEnd(str=arguments.str,pos=position) ) {
					position = _jsCS_next(pos=position);
					currChar = _jsCS_getCurrentCharacter(str=arguments.str,pos=position);
					nextChar = _jsCS_getNextCharacter(str=arguments.str,pos=position);
					if ( currChar EQ STAR ) 
					{
						if ( nextChar EQ SLASH) 
						{
							position = _jsCS_next(pos=position);
							position = _jsCS_next(pos=position);
							return position;
						}
					}
				}
			}
		}
		return position;
	</cfscript>
</cffunction>

<!--- ///////////////////////////////////////////////////////////////// --->
<!--- ///            jsCommentStripper Helper Functions             /// --->
<!--- ///////////////////////////////////////////////////////////////// --->

<!--- 
	_jsCS_isEscaping(str,pos)
 --->
<cffunction name="_jsCS_isEscaping" returntype="boolean">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var caret = arguments.pos - 1;
		var escaped = false;
		var BACK_SLASH = '\\';
		
		if ( _jsCS_getPreviousCharacter(str=arguments.str,pos=arguments.pos) == BACK_SLASH ) 
		{
				while ( caret > 0) 
				{
					if ( arguments.str.charAt(caret--) != BACK_SLASH ) 
					{
						return escaped;
					}
					escaped = !escaped;
				}
				return escaped;
		}
		return false;
	</cfscript>
</cffunction>

<!--- 
	_jsCS_add(str,pos)
 --->
<cffunction name="_jsCS_add" returntype="array">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var currentCharacter = _jsCS_getCurrentCharacter(str=arguments.str,pos=arguments.pos);
	
		// Add the Current Character to the jsCommentStripper output array
		arrayAppend(variables.jsCSoutputArray,currentCharacter);
		
		return variables.jsCSoutputArray;
	</cfscript>
</cffunction>

<!--- 
	_jsCS_getCurrentCharacter(str,pos)
 --->
<cffunction name="_jsCS_getCurrentCharacter" returntype="string">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		return arguments.str.charAt(arguments.pos);
	</cfscript>
</cffunction>

<!--- 
	_jsCS_getPreviousCharacter(str,pos)
 --->
<cffunction name="_jsCS_getPreviousCharacter" returntype="string">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		return arguments.str.charAt(arguments.pos - 1);
	</cfscript>
</cffunction>

<!--- 
	_jsCS_getNextCharacter(str,pos)
 --->
<cffunction name="_jsCS_getNextCharacter" returntype="string">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		var nextPos = arguments.pos + 1; 
	
		if ( !_jsCS_atEnd(str=arguments.str,pos=nextPos) )
			return arguments.str.charAt(nextPos);
		else
			return "";
	</cfscript>
</cffunction>

<!--- 
	_jsCS_next(pos)
 --->
<cffunction name="_jsCS_next" returntype="numeric">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfreturn arguments.pos + 1> 
</cffunction>

<!--- 
	_jsCS_atEnd(str,pos)
 --->
<cffunction name="_jsCS_atEnd" returntype="boolean">
	<cfargument name="str" type="string" required="true">
	<cfargument name="pos" type="numeric" required="true">
	
	<cfscript>
		if ( arguments.pos >= len(arguments.str) )
			return true;
		else
			return false;
	</cfscript>
</cffunction>

</cfcomponent>