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
History:
	2009-06-17 - RLW - Created
	2010-02-18 - RLW - Changed web service object to use direct CF component call
--->
<cfcomponent displayname="ccapi" extends="ADF.core.Base" hint="CCAPI functions for the ADF Library">
	
<cfproperty name="version" value="1_0_0">
<cfproperty name="CoreConfig" type="dependency" injectedBean="CoreConfig">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_0">
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

<!--- // Utility functions for building and running WS --->

<!---
/* ***************************************************************
/*
Author: 	Ron West
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
--->
<cffunction name="loadCCAPIConfig" access="public" returntype="void">
	<cfset var CCAPIConfig = StructNew()>
	<cfset var configAppXMLPath = ExpandPath("#request.site.csAppsWebURL#config/ccapi.xml")>
	<cfset var configAppCFMPath = request.site.csAppsWebURL & "config/ccapi.cfm">
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
				variables.utils.logAppend("Config XML file is not setup for this site [#request.site.name# - #request.site.id#].", "CCAPI_Errors.log");
			</cfscript>
		</cfcatch>
	</cftry>
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
		for( itm=1; itm lte listLen(elementsList); itm=itm+1 )
		{
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
/* ***************************************************************
/*
Author: 	Ron West
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
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadTemplates
Summary:	
	Based on the data returned from the configuration
	this utility will set all of the templates which are
	configured to handle API calls
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
	2009-06-30 - Deleted

<cffunction name="loadTemplates" access="private" returntype="void">
	<cfscript>
		var CCAPIConfig = getCCAPIConfig();
		var templatesList = "";
		var itm = 0;
		var thisTemplate = "";
		var templates = structNew();
		if( isStruct(CCAPIConfig) and structKeyExists(CCAPIConfig, "templates") )
			tempatesList = structKeyList(CCAPIConfig["templates"]);
		for( itm=1; itm lte listLen(templatesList); itm=itm+1 )
		{
			thisTemplate = CCAPIConfig["templates"][listGetAt(templatesList, itm)];
			// load this element into local variables first
			structInsert(templates, thisTemplate["name"], thisTemplates);			
		}
		// load the elements into object space
		setTemplates(templates);
	</cfscript>
</cffunction>--->

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
			if( len( getSSID()) )
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
--->
<cffunction name="clearLock" access="public" returntype="boolean">
	<cfargument name="pageID" type="numeric" required="true">
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