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
	ccapi_2_0.cfc
Summary:
	CCAPI functions for the ADF Library
Version:
	2.0
History:
	2012-12-27 - MFC - Created.  Direct functions to the API Library.
	2014-10-16 - GAC - Fixed the component display name
--->
<cfcomponent displayname="ccapi_2_0" extends="ADF.lib.ccapi.ccapi_1_0" hint="CCAPI functions for the ADF Library">
	
<cfproperty name="version" value="2_0_3">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
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
	2012-01-23 - MFC - Modified to call the API library.
	2014-03-05 - JTP - Var declarations
	2014-03-07 - GAC - Updated the var'd apiConfig variable for backwards compatiblity
--->
<cffunction name="initCCAPI" access="public" returntype="void" hint="Initializes the CCAPI object using the settings in the ccapi.xml file from the site root">
	<cfscript>
		var apiConfig = StructNew();
		
		variables.api.initAPIConfig();
		
		apiConfig = variables.api.getAPIConfig();

		setCCAPIConfig(apiConfig);
		setCSUserID(apiConfig.wsVars.csuserid);
		setCSPassword(apiConfig.wsVars.cspassword);
		setSiteURL(apiConfig.wsVars.siteURL);
		setWebServiceURL(apiConfig.wsVars.webserviceURL);
		setSubsiteID(apiConfig.wsVars.subsiteID);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
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
	2012-01-23 - MFC - Modified to call the API library.
--->
<cffunction name="login">
	<cfargument name="subsiteID" required="false" type="numeric" default="1">
	<cfargument name="remote" type="boolean" required="false" default="false">
	<cfscript>
		if ( arguments.subsiteID gt 0 ) {
			variables.api.setSubsiteID(arguments.subsiteID);
		}
		
		return variables.api.login(remote=arguments.remote,forceSubsiteID=variables.api.getSubsiteid());
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
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
	2012-01-23 - MFC - Modified to call the API library.
	2013-10-25 - GAC - Updated to return status from the API logout call
--->
<cffunction name="logout">
	<cfscript>
		return variables.api.logout();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
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
	2012-01-23 - MFC - Modified to call the API library.
	2013-10-23 - GAC - Updated to return a value from the api.isloggedIn()
--->
<cffunction name="loggedIn">
	<cfargument name="resultMsg" type="string" required="false" default="">
	<cfscript>
		return variables.api.isLoggedIn();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
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
	2012-01-23 - MFC - Modified to call the API library.
--->
<cffunction name="loggingEnabled" access="public" returntype="boolean" hint="Determines if logging is enabled">
	<cfscript>
		var config = variables.api.getAPIConfig();
		if(isStruct(config)	and StructKeyExists(config,"logging")
									and StructKeyExists(config.logging,"enabled")
									and Len(config.logging.enabled)){
			return true;
		}
		return false;
	</cfscript>
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

<!--- // 10-25-2013 - Updated to use the API getToken method --->
<cffunction name="getSSID" access="public" returntype="string">
	<cfreturn variables.api.getAPIToken()>
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
	<cfset variables.ssid = arguments.ssid>
</cffunction>

</cfcomponent>