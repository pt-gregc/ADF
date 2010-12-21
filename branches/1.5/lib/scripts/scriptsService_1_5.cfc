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
	scriptsService_1_5.cfc
Summary:
	Scripts Service functions for the ADF Library
History:
	2010-12-10 - RAK - Created
--->
<cfcomponent displayname="scriptsService_1_5" extends="ADF.lib.scripts.scriptsService_1_0" hint="Scripts Service functions for the ADF Library">
<cfproperty name="version" default="1_5_0">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="ScriptsService_1_5">

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
	Version 1.0
History:
 	2010-10-04 - RAK - Created
 	2010-12-10 - RAK - Updated so this will be compatible with previous version and dups will not exist!
	2010-12-21 - MFC - Removed the hard coded force debugging.
--->
<cffunction name="renderScriptOnce" access="public" output="true" returntype="void" hint="Given unescaped outputHML and script name handles adding code to the page">
	<cfargument name="scriptName" type="string" required="true" hint="Name of the script that is being ran">
	<cfargument name="outputHTML" type="string" required="true" hint="HTML to have outputted to the screen">
	<cfscript>
		if(!StructKeyExists(request,"ADFScriptsDebugging")){
			request.ADFScriptsDebugging = false;
		}
	</cfscript>
	<cfif !isScriptLoaded(arguments.scriptName)>
		<cfscript>
			loadedScript(arguments.scriptName);
			//Clean the arguments.outputHTML for javascript strings
			arguments.outputHTML = Trim(arguments.outputHTML);
			arguments.outputHTML = Replace(arguments.outputHTML,'/','\/',"all");
			arguments.outputHTML = Replace(arguments.outputHTML,"'",'"',"all");
			arguments.outputHTML = ReReplace(arguments.outputHTML,'\n','',"all");
			arguments.outputHTML = ReReplace(arguments.outputHTML,'\t','',"all");
		</cfscript>
		<cfoutput>
			<!--- If no scripts have been loaded yet make a new array of scriptsLoaded --->
			<script type="text/javascript">
				if(typeof scriptsLoaded === 'undefined'){
					var scriptsLoaded= new Array();
				}
				//Load arguments.scriptName only once.
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
</cffunction>

</cfcomponent>