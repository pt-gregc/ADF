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
	ccapi.cfc
Summary:
	CCAPI functions for the ADF Library
Version:
	1.0.1
History:
	2011-03-20 - RLW - Created
--->
<cfcomponent displayname="ccapi" extends="ccapiConfig_1_0" hint="CCAPI functions for the ADF Library">
	
<cfproperty name="version" value="1_0_1">
<cfproperty name="CoreConfig" type="dependency" injectedBean="CoreConfig">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
<cfproperty name="forms" type="dependency" injectedBean="forms_1_1">
<cfproperty name="scripts" type="dependency" injectedBean="scripts_1_1">
<cfproperty name="wikiTitle" value="CCAPI">

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$initCCAPI
Summary:	
	Initializes the CCAPI object using the settings in the ccapi.xml file from the site root
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
	2009-06-30 - RLW - Removed the "loadTemplates()" function - obsolete
--->
<cffunction name="initCCAPI" access="public" returntype="void" hint="Initializes the CCAPI object using the settings in the ccapi.xml file from the site root">
	<cfscript>
		loadCCAPIConfig();
		// load the elements and templates
		loadElements();
		loadWSVars();
		buildWS();
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$buildWS
Summary:	
	Builds the Web Service object from all of the varialbes
	defined from the configuration file
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
--->
<cffunction name="buildWS" access="private" returntype="void">
	<cfset variables.ws = createObject("component", "commonspot.webservice.cs_service")>
	<!--- <cfset variables.ws = createObject("webService", getWebServiceURL())> --->
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$hasElement
Summary:	
	Given an element name - determines if it is configured correctly
	to use that element
Returns:
	Boolean elementExists
Arguments:
	String elementName
History:
	2009-05-13 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="hasElement" access="public" returntype="numeric">
	<cfargument name="elementName" type="string" required="true">
	<cfscript>
		var elementExists = 0;
		if( structKeyExists(getElements(), arguments.elementName) )
			elementExists = 1;
	</cfscript>
	<cfreturn elementExists>
</cffunction>

<cffunction name="login">
	<cfargument name="subsiteID" required="false" type="numeric" default="1">
	<!--- // call the CS API login --->
	<cfscript>
		var error = "";
		var loginResult = "";
		if( arguments.subsiteID gt 0 )
			setSubsiteID(arguments.subsiteID);
			
		loginResult = variables.ws.csLogin(
			site = getSiteURL(),
			csUserID = getCSUserID(),
			csPassword = getCSPassword(),
			subSiteID = getSubsiteID(),
			subSiteURL = '');

		// verify that the login was successful and set the SSID
		if( ListFirst(loginResult, ":") is "Error" )
		{					
			error = listLast(loginResult, ":");
			// log error
			// TODO Move to the main logging utilities in the factory
			if( loggingEnabled() )
				variables.utils.logAppend("#request.formattedTimestamp# - Error logging in to CCAPI: #error#", "CCAPI_ws_login.log");
		}
		else if( loggingEnabled() )
			variables.utils.logAppend("#request.formattedTimestamp# - Success logging in to CCAPI: #loginResult#, [subSiteID:#subSiteID#]", "CCAPI_ws_login.log");
		// set the SSID
		setSSID(listRest(loginResult, ":"));
	</cfscript>
	<cfreturn this>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$logout
Summary:
	Logs out the current request from the CCAPI
Returns:
	String result
Arguments:
	null
History:
	2008-05-21 - RLW - Created
	2010-06-17 - MFC - Added Clear the SSID and SubsiteID for the session
--->
<cffunction name="logout">
	<cfscript>
		var logoutResult = variables.ws.csLogout(getSSID());
		
		// Clear the SSID and SubsiteID for the session
		setSSID("");
		setSubsiteID(0);
		
		if( loggingEnabled() )
			variables.utils.logAppend("#request.formattedTimestamp# - Logout result: #logoutResult#", "CCAPI_ws_login.log");
	</cfscript>
	<cfreturn logoutResult>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	loggedIn()
Summary:
	checks to make sure that the object has been instantiated correctly
Returns:
	(Boolean success) - did this succeed correctly
Arguments:
	(String resultMsg) - [Optional] the message that comes back from the custom element call
		This will be used to see if it contains "no login" message
History:
	2007-08-08 - RLW - Created
--->
<cffunction name="loggedIn">
	<cfargument name="resultMsg" type="string" required="false" default="">
	<cfscript>
		var rtnVar = "false";
		// if we did not get a message assume that length in the ssid will suffice
		if( not len(arguments.resultMsg) )
		{
			// if the first character of the SSID is a number then we logged in
			if( isNumeric(left(getSSID(),1)) )
				rtnVar = "true";
		}
		else
		{
			// do we have the "no login" message
			if( not findNoCase("No login", arguments.resultMsg) )
				rtnVar = "true";
		}
	</cfscript>
	<cfreturn rtnVar>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$clearLock
Summary:
	Clears the lock for the page id passed in (allows the CCAPI to make multiple calls)
Returns:
	(Boolean success) - did it clear the lock
Arguments:
	(Numeric pageID) - the page ID to be cleared
History:
	2007-08-08 - RLW - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="clearLock" access="public" returntype="boolean">
	<cfargument name="pageID" type="numeric" required="true">
	<cfset var doLockClear = ''>
	<!--- // clear the lock for this page --->
	<cfquery name="doLockClear" datasource="#request.site.datasource#" timeout="60">
		delete
		from locks
		where targetID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageID#">
	</cfquery>
	<cfscript>
		if( loggingEnabled() )
			variables.utils.logAppend("#now()# - clearing locks - pageID: #arguments.pageID#", "CCAPI_status.log");
	</cfscript>
	<cfreturn true>
</cffunction>
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
	Name:
		$loggingEnabled
	Summary:	
		Determines if logging is enabled
	Returns:
		Boolean doLogging
	Arguments:
		Void
	History:
		2009-07-09 - RLW - Created
		2010-12-09 - RAK - Improved fault tolerance
		2011-03-20 - RLW - Fixed bug - was always logging
	--->
<cffunction name="loggingEnabled" access="public" returntype="boolean" hint="Determines if logging is enabled">
	<cfscript>
		var config = getCCAPIConfig();
		var doLogging = false;
		if( isStruct(config) and StructKeyExists(config,"logging") and StructKeyExists(config.logging,"enabled") and isBoolean(config.logging.enabled) )
			doLogging = config.logging.enabled;
	</cfscript>
	<cfreturn doLogging>
</cffunction>


</cfcomponent>