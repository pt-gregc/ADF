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
	csSubsite_1_0.cfc
Summary:
	CCAPI Subsite functions for the ADF Library
Version:
	1.0
History:
	2009-06-17 - RLW - Created
	2011-03-20 - RLW - Updated to use the new ccapi_1_0 component (was the original ccapi.cfc file)
	2013-11-18 - GAC - Updated the lib dependencies to utils_1_2 and csData_1_2
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
	2015-10-09 - GAC - Set the ccapi injectedBean to use ccapi_1_0 since ccapi_2_0 uses the CMD API which logs in/out differently and causes errors
---> 
<cfcomponent displayname="csSubsite_1_0" extends="ADF.lib.libraryBase" hint="Constructs a CCAPI object and then creates a subsite based on the argument data passed in">

<cfproperty name="version" value="1_0_6">
<cfproperty name="type" value="transient">
<!--- // Must Use ccapi_1_0 here - ccapi_2_0 uses the CMD API which logs in/out differently --->	
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_1_0"> 
<cfproperty name="utils" type="dependency" injectedBean="utils_2_0">
<cfproperty name="csData" type="dependency" injectedBean="csData_2_0">
<cfproperty name="wikiTitle" value="CSSubsite_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$createSubsite
Summary:
	Used to create a subsite
Returns:
	Struct status
Arguments:
	Struct subsiteData - the data for the subsite
		[name, displayName, description, language]
	Numeric subsiteID (optional) - where should this be located
	Numeric doLogin 
History:
	2008-10-16 - RLW - Created
	2009-06-25 - MFC - Updated logging for success
						Updated IF block for CCAPI login
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-04-27 - MFC - Added Parent SubsiteID to the success log.
	2012-02-24 - MFC - Added TRY-CATCH around processing to logout the CCAPI if any errors.
	2014-05-01 - GAC - Fixed typo in the try/catch, switched ( e ANY ) to ( ANY e )
--->
<cffunction name="createSubsite" access="public" returntype="struct" hint="Creates the subsite based on argument data">
	<cfargument name="subsiteData" type="struct" required="true" hint="Subsite Data struct ex: subsiteData['name'], subsiteData['displayName'], subsiteData['description']">
	<cfargument name="parentSubsite" type="numeric" required="false" default="1" hint="The subsiteID for the parent subsite">
	<cfargument name="doLogin" type="numeric" required="false" default="0" hint="Force the login always">
	<cfscript>
		var result = structNew();
		var msg = "";
		var logFile = "subsite_create.log";
		var error = "";
		var ws = "";
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var createResponse = '';
		result.subsiteCreated = false;
		
		try {
		
			// Check if we are not logged in
			//	OR force login with function argument
			//	OR we are logged into a subsite other than our parent argument subsite
			if( (variables.ccapi.loggedIn() EQ 'false') OR (arguments.doLogin GT 0) OR ( (arguments.parentSubsite NEQ 0) AND (variables.ccapi.getSubsiteID() NEQ arguments.parentSubsite) ) )	// login to the subsite where the new subsite will be created
			{
				// construct the CCAPI object
				variables.ccapi.initCCAPI();
				//ws = variables.ccapi.getWS();
				if( arguments.parentSubsite neq 0 )
					variables.ccapi.login(arguments.parentSubsite);
				else
					variables.ccapi.login();
			}
			// create the subsite
			ws = variables.ccapi.getWS();
			createResponse = ws.createSubsite(ssid=variables.ccapi.getSSID(), sparams=arguments.subsiteData);
			// check to see if update wasn't successful
			if( listFirst(createResponse, ":") neq "Success" )
			{
				// check to see if there was an error logging in
				if( findNoCase(listRest(createResponse, ":"), "login") and not arguments.doLogin )
				{
					// resend this through the login
					createResponse = variables.ccapi.createSubsite(arguments.subsiteData, arguments.parentSubsite, 1);
				}
				if( listFirst(createResponse, ":") neq "Success" )
				{
					logStruct.msg = "Error creating subsite: #arguments.subsiteData.name# - #listRest(createResponse, ':')#";
					logStruct.logFile = 'CCAPI_create_subsite.log';
					arrayAppend(logArray, logStruct);
					result.response = createResponse;
				}
				else
				{
					result.subsiteCreated = "true";
					result.response = createResponse;
				}
			}
			else {
				result.subsiteCreated = "true";
				result.response = createResponse;
				
				logStruct.msg = "Subsite Created: #arguments.subsiteData.name# - #listRest(createResponse, ':')# - Parent Subsite [#variables.ccapi.getSubsiteID()#]";
				logStruct.logFile = 'CCAPI_create_subsite.log';
				arrayAppend(logArray, logStruct);
			}
			if( variables.ccapi.loggingEnabled() )
				variables.utils.bulkLogAppend(logArray);
		}
		catch ( ANY e )
		{
			// Error caught, send back the error message
			result.subsiteCreated = false;
			result.response = e.message;
			
			// Log the error message also
			logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#] [Details: #e.Details#]";
			logStruct.logFile = "CCAPI_create_subsite_errors.log";
			variables.utils.bulkLogAppend(logArray);
		}
		
		// Logout
		variables.ccapi.logout();
	</cfscript>
	<cfreturn result>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$buildSubsitesFromPath
Summary:
	Verifies the subsite path exists or creates the subsites.  Returns the last subsites ID.
Returns:
	Numeric - Subsite ID for the last subsite in the path.
Arguments:
	String subsitePath - Subsite path to verify/create
History:
	2009-06-25 - MFC - Created
	2009-07-29 - RLW - Migrated to CSSubsite and converted app calls to global
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="buildSubsitesFromPath" access="public" returntype="numeric" hint="Verifies the subsite path exists or creates the subsites. Returns the last subsites ID.">
	<cfargument name="subsitePath" type="string" required="true">
	<cfscript>
		var retSubsiteID = 1;
		var currPath = "/";
		var currSubsiteID = 0;
		var ss_i = '';
		// Loop over the subsite names
		for ( ss_i = 1; ss_i LTE ListLen(arguments.subsitePath,'/'); ss_i = ss_i + 1) {
			currPath = currPath & ListGetAt(arguments.subsitePath, ss_i, '/') & "/";
			// Verify if the subsite exists
			currSubsiteID = variables.csData.getSubsiteID(currPath);
			// Does the subsite exist
			if ( currSubsiteID LTE 0 ){
				// Subsite does not exist, then create it
				currSubsiteID = handleCreateSubsite(currPath);
			}
		}
		retSubsiteID = currSubsiteID;
	</cfscript>
	<cfreturn retSubsiteID>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$handleCreateSubsite
Summary:
	Creates the subsite and returns the subsite ID.
	
	Only the last subsite in the argument path will be created.
	This does require that all previous subsites in the path exist.
Returns:
	Numeric - Subsite ID for the last subsite in the path.
Arguments:
	String subsitePath - Subsite path to verify/create
History:
	2009-06-25 - MFC - Created
	2009-07-29 - RLW - Migrated to CSSubsite and converted app calls to global
	2011-01-19 - GAC - Made the access for this function public 
--->
<cffunction name="handleCreateSubsite" access="public" returntype="numeric" hint="">
	<cfargument name="subsitePath" type="string" required="true">	
	<cfscript>
		var retSubID = 0;
		var parentSubPath = "";
		var subsiteData = StructNew();
		var parentSubID = 0;
		var subsiteStatus = StructNew();

		// Get the parent subsite path
		parentSubPath = Replace(arguments.subsitePath, "/#ListLast(arguments.subsitePath,'/')#/", "/");
		parentSubID = variables.csData.getSubsiteID(parentSubPath);
		
		// Build the subsite data struct
		subsiteData.name = ListLast(arguments.subsitePath,'/');
		subsiteData.displayName = ListLast(arguments.subsitePath,'/');
		subsiteData.description = ListLast(arguments.subsitePath,'/');
		
		// create the subsite
 		subsiteStatus = createSubsite(subsiteData, parentSubID, 1);

 		// Get the subsite ID for the subsite created
 		retSubID = variables.csData.getSubsiteID(arguments.subsitePath);
	</cfscript>
	<cfreturn retSubID>
</cffunction>

</cfcomponent>