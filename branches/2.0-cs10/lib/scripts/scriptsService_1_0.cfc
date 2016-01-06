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
	scriptsService_1_0.cfc
Summary:
	Scripts Service functions for the ADF Library
Version:
	1.0
History:
	2009-06-17 - RLW - Created
	2011-12-28 - MFC - Added "getMajorMinorVersion" function to backwards compatibility.
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->
<cfcomponent displayname="scriptsService_1_0" extends="ADF.lib.libraryBase" hint="Scripts Service functions for the ADF Library">

<cfproperty name="version" value="1_0_4">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="ScriptsService_1_0">

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$scriptLoaded
Summary:	
	Use this function to ensure that only one set of the script
	is loaded - this uses request scope to handle that
Returns:
	Boolean isScriptLoaded
Arguments:
	String scriptName
History:
	2009-05-14 - RLW - Created
--->
<cffunction name="isScriptLoaded" access="public" returntype="Boolean">
	<cfargument name="scriptName" type="string" required="true">
	<cfset var isScriptLoaded = 0>
	<cfparam name="request.scriptsExecuted" default="">
	<cfscript>
		if( listFindNoCase(request.scriptsExecuted, arguments.scriptName) )
			isScriptLoaded = 1;
	</cfscript>
	<cfreturn isScriptLoaded>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$scriptLoaded
Summary:	
	Updates the system variables to flag that a particular scipt
	has already been loaded
Returns:
	Void
Arguments:
	String scriptName
History:
	2009-05-14 - RLW - Created
--->
<cffunction name="loadedScript" access="public" returntype="void">
	<cfargument name="scriptName" type="string" required="true">
	<cfscript>
		if(!StructKeyExists(request,"scriptsExecuted")){
			request.scriptsExecuted = "";
		}

		if(!StructKeyExists(request,"scriptsAgent")){
			request.scriptsAgent = "";
		}

		if(request.scriptsAgent neq request.environment.userAgentProps.type){
			request.scriptsAgent = request.environment.userAgentProps.type;
			request.scriptsExecuted = "";
		}
		request.scriptsExecuted = listAppend(request.scriptsExecuted, arguments.scriptName);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getMajorMinorVersion
Summary:
	Returns the Major and Minor version to remove the build number.
	Ex. 1.3.2 = 1.3
Returns:
	String
Arguments:
	String
History:
	2011-12-28 - MFC - Created
--->
<cffunction name="getMajorMinorVersion" access="public" returntype="string" output="true">
	<cfargument name="currVersion" type="string" required="true">

	<cfscript>
		var newVersion = arguments.currVersion;
		// Check the format of the argument contains minor versions
		if ( ListLen(arguments.currVersion, ".") GTE 3 ) {
			// Trim down to only major.minor versions
			newVersion = ListFirst(arguments.currVersion, '.') & "." & ListGetAt(arguments.currVersion, 2, '.');
		}
		return newVersion;
	</cfscript>
</cffunction>

</cfcomponent>