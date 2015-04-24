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
	csPage_1_0.cfc
Summary:
	CCAPI Page functions for the ADF Library
Version:
	1.0
History:
	2009-06-17 - RLW - Created
	2011-03-20 - RLW - Updated to use the new ccapi_1_0 component (was the original ccapi.cfc file)
---> 
<cfcomponent displayname="csPage_1_0" extends="ADF.core.Base" hint="Constructs a CCAPI instance and then creates or deletes a page with the given information">

<cfproperty name="version" value="1_0_3">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_1_0">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_0">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_0">
<cfproperty name="taxonomy" type="dependency" injectedBean="taxonomy_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_0">
<cfproperty name="wikiTitle" value="CSPage_1_0">

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
	2012-02-24 - MFC - Added TRY-CATCH around processing to logout the CCAPI if any errors.
	2014-05-01 - GAC - Fixed typo in the try/catch, switched ( e ANY ) to ( ANY e )
	2015-02-03 - GAC - Updated catch block to check for the e.Details structkey
--->
<cffunction name="createPage" access="public" output="true" returntype="struct" hint="Creates a page using the argument data passed in">
	<cfargument name="stdMetadata" type="struct" required="true" hint="Standard Metadata would include 'Title, Description, TemplateId, SubsiteID etc...'">
	<cfargument name="custMetadata" type="struct" required="true" hint="Custom Metadata would be any custom metadata for the new page ex. customMetadata['formName']['fieldname']">
	<cfargument name="activatePage" type="numeric" required="false" default="1" hint="Flag to make the new page active or inactive"> 
	
	<cfscript>
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
		catch ( ANY e )
		{
			// Error caught, send back the error message
			result.pageCreated = false;
			result.msg = e.message;
			
			// Log the error message also
			logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#]";
			if ( StructKeyExists(e,"Details") AND LEN(TRIM(e.Details)) )
				logStruct.msg = logStruct.msg & " [Details: #e.Details#]";

			logStruct.logFile = "CCAPI_create_pages_errors.log";
			variables.utils.bulkLogAppend(logArray);
		}
			
		// Logout
		variables.ccapi.logout();
		// clear locks before starting
		variables.ccapi.clearLock(result.newPageID);
	</cfscript>
	<cfreturn result>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$deletePage
Summary:
	Deletes pages with the content creation API
Returns:
	Struct status
Arguments:
	Numeric: PageID
History:
	2008-12-08 - MFC - Created
	2011-02-09 - RAK - Var'ing un-var'd variables
	2012-02-24 - MFC - Added TRY-CATCH around processing to logout the CCAPI if any errors.
	2014-05-01 - GAC - Fixed typo in the try/catch, switched ( e ANY ) to ( ANY e )
	2015-02-03 - GAC - Updated catch block to check for the e.Details structkey
--->
<cffunction name="deletePage" access="public" output="true" returntype="struct" hint="Deletes the page based on the argument data">
	<cfargument name="deletePageData" type="struct" required="true" hint="Standard Metadata like 'PageID, SubsiteID'">		
	
	<cfscript>
		var deletePageResult = '';
		var logoutResult = '';
		var pageData = structNew();
		var ws = "";
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var result = structNew();
		
		result.pageDeleted = false;
		result.msg = "";
		
		// construct the CCAPI object
		variables.ccapi.initCCAPI();
		
		try {
			ws = variables.ccapi.getWS();
			// NOTE: always logging in to make sure that we create page in correct subsite
			variables.ccapi.login(arguments.deletePageData.subsiteID);
	
			// Page create parameters
			pageData = arguments.deletePageData;
	
			// invoke createPage API call
			deletePageResult = ws.deletePage(
				ssid = variables.ccapi.getSSID(),
				sParams = pageData);
	
			// if the call was successful then send back the new pageID
			if( listFirst( deletePageResult, ":") eq "success" )
			{
				//Log success
				logStruct.msg = "Delete Page Success: #request.formattedTimestamp# - Page (#pageData.pageID#) deleted on #request.formattedTimeStamp#";
				logStruct.logFile = 'CCAPI_delete_pages.log';
				arrayAppend(logArray, logStruct);
				result.pageDeleted = true;
			}
			else
			{
				//Log success
				logStruct.msg = "Error Delete Page: #request.formattedTimestamp# - Page Could Not Be deleted (#pageData.pageID#). Error: #deletePageResult#";
				logStruct.logFile = 'CCAPI_delete_pages.log';
				arrayAppend(logArray, logStruct);
				result.msg = deletePageResult;
			}
			if( variables.ccapi.loggingEnabled() )
				variables.utils.bulkLogAppend(logArray);
		}
		catch ( ANY e )
		{
			// Error caught, send back the error message
			result.pageDeleted = false;
			result.msg = e.message;
			
			// Log the error message also
			logStruct.msg = "#request.formattedTimestamp# - Error";
			logStruct.msg = logStruct.msg & " [Message: #e.Message#]";
			if ( StructKeyExists(e,"Details") AND LEN(TRIM(e.Details)) )
				logStruct.msg = logStruct.msg & " [Details: #e.Details#]";
			
			logStruct.logFile = "CCAPI_delete_pages_errors.log";
			variables.utils.bulkLogAppend(logArray);
		}
		// Logout
		variables.ccapi.logout();
		// clear locks before starting
		variables.ccapi.clearLock(pageData.pageID);
	</cfscript>
	<cfreturn result>
</cffunction>

</cfcomponent>