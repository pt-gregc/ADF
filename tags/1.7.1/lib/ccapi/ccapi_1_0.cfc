<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	1.0
History:
	2009-06-17 - RLW - Created
	2010-02-18 - RLW - Changed web service object to use direct CF component call
	2011-01-25 - MFC - Update to v1.0.1. Updated dependency to Utils_1_1.
--->
<cfcomponent displayname="ccapi" extends="ADF.core.Base" hint="CCAPI functions for the ADF Library">
	
<cfproperty name="version" value="1_0_3">
<cfproperty name="CoreConfig" type="dependency" injectedBean="CoreConfig">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="wikiTitle" value="CCAPI">

<cfscript>
	// xml config info
	variables.CCAPIConfig = structNew();
	// CS Content Creation API settings
	variables.csUserId = "";
	variables.csPassword = "";
	variables.SSID = "";
	variables.siteURL = "";
	variables.webserviceURL = "";
	variables.subsiteID = "";
	// vars for elements and templates
	variables.elements = structNew();
	variables.templates = structNew();
</cfscript>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
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

<!--- // Utility functions for building and running WS --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadCCAPIConfig
Summary:	
	Using the CoreConfig object - loads up the current sites configuration
	for this application
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
	2009-11-19 - GAC - Modified to load a XML CCAPI config values from a ccapi.CFM file (if available)
	2010-03-05 - GAC - Removed the loggingEnabled() function call from the try/catch
	2012-01-26 - MFC - Updated the config error message.
	2014-05-21 - GAC - Updated to use the csAppsURL so the site's mapping path is included to help for a
						more accurate ExpandPath() when on a multi-site install
--->
<cffunction name="loadCCAPIConfig" access="public" returntype="void">

	<cfscript>
		var CCAPIConfig = StructNew();
		var configAppXMLPath = ExpandPath("#request.site.csAppsURL#config/ccapi.xml");
		var configAppCFMPath = request.site.csAppsURL & "config/ccapi.cfm";
	</cfscript>

	<cftry>
		<cfscript>
			// config data should be loaded here
			// TODO: Need some error checking here
			// CCAPIConfig = server.ADF.environment[request.site.id].ccapi;
			
			// Pass a Logical path for the CFM file to the getConfigViaXML() since it will be read via CFINCLUDE
			if ( FileExists(ExpandPath(configAppCFMPath)) )
				CCAPIConfig = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configAppCFMPath);
			// Pass an Absolute path for the XML file to the getConfigViaXML() since it will be read via CFFILE
			else if ( FileExists(configAppXMLPath) )
				CCAPIConfig = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configAppXMLPath);
			
			setCCAPIConfig(CCAPIConfig);
		</cfscript>
		<cfcatch>
			<cfscript>
				variables.utils.logAppend("CCAPI Configuration CFM (or XML) file is not setup for this site [#request.site.name# - #request.site.id#].", "CCAPI_Errors.log");
			</cfscript>
		</cfcatch>
	</cftry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$buildWS
Summary:	
	Builds the Web Service object from webserviceURL variable
	defined in the configuration file
Returns:
	Void
Arguments:
	Boolean - forceRemote
History:
	2009-05-13 - RLW - Created
	2013-10-15 - GAC - Added logic to have CCAPI request use the new cs_remote.cfc
					 - Added logic to force createObject to use the remote webservice URL instead local path
--->
<cffunction name="buildWS" access="private" returntype="void" hint="Builds the Web Service object from webserviceURL variable defined in the configuration file">
	<cfargument name="forceRemote" required="false" type="boolean" default="false">
	<cfscript>
		var wsURL = getWebServiceURL();
		var wsPath = "commonspot.webservice.cs_service";
		// Check to see if the WebService URL is using the 7.0.1+, 8.0.1+ and 9+ cs_remote.cfc
		if ( FindNoCase(wsURL,"cs_remote") )
			wsPath = "commonspot.webservice.cs_remote";
		// Set the WS value	
		if ( arguments.forceRemote )
			variables.ws = createObject("webService", wsURL);
		else
			variables.ws = createObject("component", wsPath);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadElements
Summary:	
	Based on the data returned from the configuration
	this utility will set all of the elements which are
	configured to handle API calls
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
--->
<cffunction name="loadElements" access="private" returntype="void">
	<cfscript>
		var CCAPIConfig = getCCAPIConfig();
		var elementsList = "";
		var itm = 0;
		var thisElement = "";
		var elementName = "";
		var elements = structNew();
		if( isStruct(CCAPIConfig) and structKeyExists(CCAPIConfig, "elements") and isStruct(CCAPIConfig["elements"]) )
			elementsList = structKeyList(CCAPIConfig["elements"]);
		for( itm=1; itm lte listLen(elementsList); itm=itm+1 ) {
			elementName = listGetAt(elementsList, itm);
			thisElement = CCAPIConfig["elements"][elementName];
			// load this element into local variables first
			structInsert(elements, elementName, thisElement);			
		}
		// load the elements into object space
		setElements(elements);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$loadWSVars
Summary:	
	Builds the WebService variables required like: Username,Password,URL etc..
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
--->
<cffunction name="loadWSVars" access="private" returntype="void">
	<cfscript>
		var CCAPIConfig = getCCAPIConfig();
		var wsVars = structNew();
		if( isStruct(CCAPIConfig) and structKeyExists(CCAPIConfig, "wsVars") )
			wsVars = CCAPIConfig["wsVars"];
		if( structKeyExists(wsVars, "csuserid") )
			setCSUserID(wsVars["csuserid"]);
		if( structKeyExists(wsVars, "cspassword") )
			setCSPassword(wsVars["cspassword"]);
		if( structKeyExists(wsVars, "siteURL") )
			setSiteURL(wsVars["siteURL"]);
		if( structKeyExists(wsVars, "webserviceURL") )
			setWebServiceURL(wsVars["webserviceURL"]);
		if( structKeyExists(wsVars, "subsiteID") )
			setSubsiteID(wsVars["subsiteID"]);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
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
		return elementExists;	
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$login
Summary:	
	Login to the CCAPI for the subsite.
Returns:
	Void
Arguments:
	numeric - subsiteID
History:
	2009-05-13 - RLW - Created
	2011-06-16 - MFC - Updated login verification logic for success or error.
	2011-07-14 - RAK - Made sure that the user was logged out before they logged back in again. AKA cleaned up logged in sessions
--->
<cffunction name="login">
	<cfargument name="subsiteID" required="false" type="numeric" default="1">
	<!--- // call the CS API login --->
	<cfscript>
		var error = "";
		var loginResult = "";

		if(loggedIn()){
			logout();
		}

		if( arguments.subsiteID gt 0 ){
			setSubsiteID(arguments.subsiteID);
		}

		loginResult = variables.ws.csLogin(
			site = getSiteURL(),
			csUserID = getCSUserID(),
			csPassword = getCSPassword(),
			subSiteID = getSubsiteID(),
			subSiteURL = '');
		
		// Verify that the login was successful and set the SSID
		if ( ListFirst(loginResult, ":") is "Success" ){
			// Set the SSID
			setSSID(listRest(loginResult, ":"));
			// Log Success
			if( loggingEnabled() )
				variables.utils.logAppend("#request.formattedTimestamp# - Success logging in to CCAPI: #loginResult#, [SubSiteID:#subSiteID#]", "CCAPI_ws_login.log");
		}
		else {
			// Clear the SSID
			setSSID("");
			error = listLast(loginResult, ":");
			// Log Error
			if( loggingEnabled() )
				variables.utils.logAppend("#request.formattedTimestamp# - Error logging in to CCAPI: #error#", "CCAPI_ws_login.log");
		}
		//return loginResult;
	</cfscript>
	<cfreturn this> 
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
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
/* *************************************************************** */
Author: 
	PaperThin, Inc.		
	Ron West
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
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	Ron West
Name:
	$loggingEnabled
Summary:	
	Determines if logging is enabled
Returns:
	Boolean rtnVal
Arguments:
	Void
History:
	2009-07-09 - RLW - Created
	2010-12-09 - RAK - Improved fault tolerance
--->
<cffunction name="loggingEnabled" access="public" returntype="boolean" hint="Determines if logging is enabled">
	<cfscript>
		var config = getCCAPIConfig();
		if(isStruct(config)	and StructKeyExists(config,"logging")
									and StructKeyExists(config.logging,"enabled")
									and Len(config.logging.enabled)){
			return true;
		}
		return false;
	</cfscript>
	<cfreturn rtnVal>
</cffunction>

<!--- // Public GETTERS/SETTERS --->
<cffunction name="setSubsiteID" access="public" returntype="void">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfset variables.subsiteID = arguments.subsiteID>
</cffunction>

<cffunction name="getSubsiteID" access="public" returntype="numeric">
	<cfreturn variables.subsiteID>
</cffunction>

<cffunction name="getWS" access="public" returntype="any">
	<cfreturn variables.ws>
</cffunction>

<cffunction name="getSSID" access="public" returntype="string">
	<cfreturn variables.SSID>
</cffunction>

<!--- // Private GETTERS/SETTERS --->
<cffunction name="setCSPassword" access="private" returntype="void">
	<cfargument name="CSPassword" type="string" required="true">
	<cfset variables.CSPassword = arguments.CSPassword>
</cffunction>

<cffunction name="getCSPassword" access="private" returntype="string">
	<cfreturn variables.CSPassword>
</cffunction>

<cffunction name="getCSUserID" access="private" returntype="string">
	<cfreturn variables.CSUserID>
</cffunction>

<cffunction name="setCSUserID" access="private" returntype="void">
	<cfargument name="CSUserID" type="string" required="true">
	<cfset variables.CSUserID = arguments.CSUserID>
</cffunction>

<cffunction name="setSiteURL" access="private" returntype="void">
	<cfargument name="siteURL" type="string" required="true">
	<cfset variables.siteURL = arguments.siteURL>	
</cffunction>

<cffunction name="getSiteURL" access="private" returntype="string">
	<cfreturn variables.siteURL>
</cffunction>

<cffunction name="getCCAPIConfig" access="private" returntype="struct">
	<cfreturn variables.CCAPIConfig>
</cffunction>

<cffunction name="setCCAPIConfig" access="private" returntype="void">
	<cfargument name="CCAPIConfig" type="any" required="true">
	<cfset variables.CCAPIConfig = arguments.CCAPIConfig>
</cffunction>

<cffunction name="getElements" access="public" returntype="struct">
	<cfreturn variables.elements>
</cffunction>

<cffunction name="setElements" access="private" returntype="void">
	<cfargument name="elements" type="struct" required="true">
	<cfset variables.elements = elements>
</cffunction>

<cffunction name="getTemplates" access="private" returntype="struct">
	<cfreturn variables.templates>
</cffunction>

<cffunction name="setTemplates" access="private" returntype="void">
	<cfargument name="templates" type="struct" required="true">
	<cfset variables.templates = arguments.templates>
</cffunction>

<cffunction name="setWebServiceURL" access="private" returntype="void">
	<cfargument name="webServiceURL" type="string" required="true">
	<cfset variables.webServiceURL = arguments.webServiceURL>
</cffunction>

<cffunction name="getWebServiceURL" access="private" returntype="string">
	<cfreturn variables.webServiceURL>
</cffunction>

<cffunction name="setSSID" access="private" returntype="void">
	<cfargument name="ssid" type="string" required="true">
	<cfset variables.SSID = arguments.SSID>	
</cffunction>

</cfcomponent>