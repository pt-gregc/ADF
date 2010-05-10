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
	csSubsite_1_0.cfc
Summary:
	CCAPI Subsite functions for the ADF Library
History:
	2009-06-17 - RLW - Created
---> 
<cfcomponent displayname="csSubsite_1_0" extends="ADF.core.Base" hint="Constructs a CCAPI object and then creates a subsite based on the argument data passed in">
<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi">	
<cfproperty name="utils" type="dependency" injectedBean="utils_1_0">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_0">
<cfproperty name="wikiTitle" value="CSSubsite_1_0">

<!---
/* ***************************************************************
/*
Author: 	Ron West
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
History:
	2008-10-16 - RLW - Created
	2009-06-25 - MFC - Updated logging for success
						Updated IF block for CCAPI login
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
		result.subsiteCreated = false;
		// Check if we are not logged in
		//	OR force login with function argument
		//	OR we are logged into a subsite other than our parent argument subsite
		if( (variables.ccapi.loggedIn() EQ 'false') OR (arguments.doLogin GT 0) OR ( (arguments.parentSubsite NEQ 0) AND (variables.ccapi.getSubsiteID() NEQ arguments.parentSubsite) ) )	// login to the subsite where the new subsite will be created
		{
			// construct the CCAPI object
			variables.ccapi.initCCAPI();
			ws = variables.ccapi.getWS();
			if( arguments.parentSubsite neq 0 )
				variables.ccapi.login(arguments.parentSubsite);
			else
				variables.ccapi.login();
		}
		// create the subsite
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
			
			logStruct.msg = "Subsite Created: #arguments.subsiteData.name# - #listRest(createResponse, ':')#";
			logStruct.logFile = 'CCAPI_create_subsite.log';
			arrayAppend(logArray, logStruct);
		}
		if( variables.ccapi.loggingEnabled() )
			variables.utils.bulkLogAppend(logArray);
	</cfscript>
	<cfreturn result>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
--->
<cffunction name="buildSubsitesFromPath" access="public" returntype="numeric" hint="Verifies the subsite path exists or creates the subsites. Returns the last subsites ID.">
	<cfargument name="subsitePath" type="string" required="true">
	<cfscript>
		var retSubsiteID = 1;
		var currPath = "/";
		var currSubsiteID = 0;
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
--->
<cffunction name="handleCreateSubsite" access="private" returntype="numeric" hint="">
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