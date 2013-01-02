<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	csPage_1_1.cfc
Summary:
	CCAPI Page functions for the ADF Library
Version:
	1.1
History:
	2011-01-25 - RLW - Created - New v1.1
	2011-03-20 - RLW - Updated ccapi version to new 1.1
---> 
<cfcomponent displayname="csPage_2_0" extends="ADF.lib.ccapi.csPage_1_1" hint="Constructs a CCAPI instance and then creates or deletes a page with the given information">

<cfproperty name="version" value="2_0_1">
<cfproperty name="type" value="transient">
<cfproperty name="apiElement" type="dependency" injectedBean="apiPage_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="CSPage_2_0">

<cfscript>
	// standard metadata structures
	variables.stdMetadata = structNew();
	// variables.stdMetadata.pageID = 0;
	variables.stdMetadata.name = "";
	variables.stdMetadata.title = "";
	variables.stdMetadata.caption = "";
	variables.stdMetadata.description = "";
	variables.stdMetadata.globalKeywords = "";
	variables.stdMetadata.categoryName = "";
	variables.stdMetadata.subsiteID = "";
	variables.stdMetadata.templateID = "";
	// custom metadata structure
	variables.custMetadata = structNew();
	// page data
	variables.pageID = 0;
</cfscript>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$createPage
Summary:
	Creates pages with the content creation API
Returns:
	Struct result - contains a structure with the following keys
		- newPageID - the new pageID for the page created
		- pageCreated - did the page get created or not
		- msg - the error message (if it exists)
Arguments:
	Struct stdMetadata - standard metadata for the page (must contain the templateID)
	Struct custMetadata - custom metadata for the page
History:
	2008-10-07 - RLW - Created
	2009-07-12 - RLW - added a check for "pageExists" prior to creating the page
	2009-07-15 - RLW - changed the return format to structure and built consistent struct response
	2011-06-21 - MFC - Added logout call at the end of the process.
	2012-02-24 - MFC - Added TRY-CATCH around processing 
						to logout the CCAPI if any errors.
--->
<cffunction name="createPage" access="public" output="true" returntype="struct" hint="Creates a page using the argument data passed in">
	<cfargument name="stdMetadata" type="struct" required="true" hint="Standard Metadata would include 'Title, Description, TemplateId, SubsiteID etc...'">
	<cfargument name="custMetadata" type="struct" required="true" hint="Custom Metadata would be any custom metadata for the new page ex. customMetadata['formName']['fieldname']">
	<cfargument name="activatePage" type="numeric" required="false" default="1" hint="Flag to make the new page active or inactive"> 
	<!--- <cfscript>
		var pageData = structNew();
		var ws = "";
		var createPageResult = structNew();
		var msg = "";
		var pageExists = "";
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var result = structNew();
		result.pageCreated = false;
		result.newPageID = 0;
		result.msg = "";
		
		// construct the CCAPI object
		variables.ccapi.initCCAPI();
		
		try {
			// NOTE: always logging in to make sure that we create page in correct subsite
			variables.ccapi.login(arguments.stdMetadata.subsiteID);
			ws = variables.ccapi.getWS();
			// build page data structure
			pageData.type = "page";
			pageData.activate = arguments.activatePage;
	
			// Page create parameters
			pageData.cParams = arguments.stdMetadata;
			pageData.mData = arguments.custMetadata;
			
			// check to see if this page exists yet
			pageExists = variables.csData.getCSPageByName(pageData.cParams.name, pageData.cParams.subsiteID);
			if( not pageExists )
			{	
				// invoke createPage API call
				createPageResult = ws.createPage(
					ssid = variables.ccapi.getSSID(),
					sParams = pageData);
	
				// if the call was successful then send back the new pageID
				if( listFirst( createPageResult, ":") eq "success" )
				{
					// set the new pageID
					result.newPageID = listRest( createPageResult, ":");
					result.pageCreated = true;
	
					//Log success
					logStruct.msg = "#request.formattedTimestamp# - Page (#result.newPageID# - #arguments.stdMetadata.title#) created on #request.formattedTimeStamp#";
					logStruct.logFile = 'CCAPI_create_pages.log';
					arrayAppend(logArray, logStruct);
				}
				else
				{
					result.msg = createPageResult;
					/* need debugging on why this failed
					1. No subsite
					2. Page Exists
					3. No metadata
					*/
					//Log error
					logStruct.msg = "#request.formattedTimestamp# - Page Was Not Created (#arguments.stdMetadata.title#). Error: #createPageResult#";
					logStruct.logFile = 'CCAPI_create_pages_errors.log';
					arrayAppend(logArray, logStruct);
				}
			}
			else
			{
				result.newPageID = pageExists;
				result.pageCreated = false;
				logStruct.msg = "#request.formattedTimeStamp# - Page with title #arguments.stdMetadata.title# in subsite #request.subsiteCache[arguments.stdMetadata.subsiteID].url# already exists";
				logStruct.logFile = 'CCAPI_create_pages_errors.log';
				arrayAppend(logArray, logStruct);
			}
			
			// handle logging
			// TODO: plug the logging option into the CCAPI config settings
			if( variables.ccapi.loggingEnabled() and arrayLen(logArray) )
				variables.utils.bulkLogAppend(logArray);
		}
		catch (e ANY){
			// Error caught, send back the error message
			result.pageCreated = false;
			result.msg = e.message;
			
			// Log the error message also
			logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#] [Details: #e.Details#]";
			logStruct.logFile = "CCAPI_create_pages_errors.log";
			variables.utils.bulkLogAppend(logArray);
		}
			
		// Logout
		variables.ccapi.logout();
		// clear locks before starting
		variables.ccapi.clearLock(result.newPageID);
	</cfscript>
	<cfreturn result> --->
	<cfscript>
		// Call the API apiElement Lib Component
		var contentResult = variables.apiPage.populateCustom(elementName=arguments.elementName,
															    data=arguments.data,
															    forceSubsiteID=arguments.forceSubsiteID,
															    forcePageID=arguments.forcePageID,
															    forceLogout=arguments.forceLogout);
		
		// Format the result in the way that was previously constructed
		result.contentUpdated = contentResult.status;
		result.msg = contentResult.msg;
		return result; 
	</cfscript>
</cffunction>

</cfcomponent>