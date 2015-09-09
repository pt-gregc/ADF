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
	csPage_2_0.cfc
Summary:
	CCAPI Page functions for the ADF Library
Version:
	2.0
History:
	2013-01-01 - MFC - Created - New v2.0 to support ADF v1.6.
	2013-02-12 - MFC - Added injection dependency with CSData v1.2.
	2015-01-22 - GAC - Added the injection dependency for ccapi_2_0 to allow the inherited csPage_1_0.deletePage() to work
---> 
<cfcomponent displayname="csPage_2_0" extends="ADF.lib.ccapi.csPage_1_1" hint="Constructs a CCAPI instance and then creates or deletes a page with the given information">

<cfproperty name="version" value="2_0_6">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_2_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="apiPage" type="dependency" injectedBean="apiPage_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_2">
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
	2013-01-11 - MFC - Fixed issue with VAR not at the top for CF8 and under.
	2013-02-08 - MFC - Updated logging variable in error handling.
	2013-02-12 - MFC - Moved the "metadataStructToArray" code to a function in CSData.
	2014-03-05 - JTP - Var declarations
	2015-09-09 - GAC - Updated the custom metadata conversion to check if the data is already in a Array of Structs format
--->
<cffunction name="createPage" access="public" output="true" returntype="struct" hint="Creates a page using the argument data passed in">
	<cfargument name="stdMetadata" type="struct" required="true" hint="Standard Metadata would include 'Title, Description, TemplateId, SubsiteID etc...'">
	<cfargument name="custMetadata" type="struct" required="true" hint="Custom Metadata would be any custom metadata for the new page ex. customMetadata['formName']['fieldname']">
	<cfargument name="activatePage" type="numeric" required="false" default="1" hint="Flag to make the new page active or inactive"> 

	<cfscript>
		var contentResult = "";
		// Merge the custom metadata form into the standard metadata form to make a single data structure
		var pageData = arguments.stdMetadata;
		var tempStruct = structNew();
		var i = 1;
		var j = 1;
		var metadataKeyList = "";
		var currFormName = "";
		var currFormKeyList = "";
		var currFieldName = "";
		
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var loggingEnabled = false;
		// Check the element is in the API Config file and defined		
		var apiConfig = variables.api.getAPIConfig();
		var result = StructNew();
		
		// Convert Metadata Struct into an Array of values if needed
		//	FieldName = The name of the field in the metadata form.
		//	FormName = The name of the metadata form.
		//	Value = The value of the metadata field.
		if ( IsStruct(arguments.custMetadata) OR !IsArray(arguments.custMetadata) )
			pageData.metadata = variables.csData.metadataStructToArray(metadata=arguments.custMetadata);		
		else
			pageData.metadata = arguments.custMetadata;
		
		// Call the API apiElement Lib Component
		contentResult = variables.apiPage.create(pageData=pageData,activatePage=arguments.activatePage);
		
		// Format the result in the way that was previously constructed
		result.contentUpdated = contentResult.CMDSTATUS;
		result.msg = contentResult.CMDRESULTS;
		// Update the existing return variables to make backwards compat.
		result.newPageID = contentResult.CMDRESULTS;
		result.pageCreated = contentResult.CMDSTATUS;
		
		// Set the logging flag
		if ( isStruct(apiConfig) 
			AND StructKeyExists(apiConfig, "logging")
			AND StructKeyExists(apiConfig.logging, "enabled")
			AND apiConfig.logging.enabled == 1 ) 
		{
			
			if ( result.contentUpdated )
			{
				logStruct.msg = "#request.formattedTimestamp# - Page [Page ID = #result.newPageID#] [Title = #arguments.stdMetadata.title#]";
				logStruct.logFile = 'API_Page_create.log';
				arrayAppend(logArray, logStruct);
			}
			else 
			{
				// Check if the error is a CFCATCH struct
				if ( isStruct(result.msg)
						AND StructKeyExists(result.msg, "message")
						AND StructKeyExists(result.msg, "detail") )
					logStruct.msg = "#request.formattedTimestamp# - Error [Message: #result.msg.message#] [Details: #result.msg.detail#]";
				else 
					logStruct.msg = "#request.formattedTimestamp# - Error [#result.msg#]";
				logStruct.logFile = 'API_Page_create_error.log';
				arrayAppend(logArray, logStruct);
			}
			// Write the log files
			variables.utils.bulkLogAppend(logArray);		
		}
		return result; 
	</cfscript>
</cffunction>

</cfcomponent>