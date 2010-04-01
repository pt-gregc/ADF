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
	scriptsService_1_0.cfc
Summary:
	Scripts Service functions for the ADF Library
History:
	2009-06-17 - RLW - Created
--->
<cfcomponent displayname="scriptsService_1_0" extends="ADF.core.Base" hint="Scripts Service functions for the ADF Library">
	<cfproperty name="version" default="1_0_0">
	<cfproperty name="type" value="singleton">
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
		<cfparam name="request.scriptsExecuted" default="">
		<cfset request.scriptsExecuted = listAppend(request.scriptsExecuted, arguments.scriptName)>
	</cffunction>

</cfcomponent>