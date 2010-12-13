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
	csPage_1_0.cfc
Summary:
	CCAPI Page functions for the ADF Library
History:
	2009-06-17 - RLW - Created
---> 
<cfcomponent displayname="csPage_1_0" extends="ADF.core.Base" hint="Constructs a CCAPI instance and then creates or deletes a page with the given information">
<cfproperty name="version" value="1_0_0">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_0">
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
/* ***************************************************************
/*
Author: 	Ron West
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
		// clear locks before starting
		variables.ccapi.clearLock(result.newPageID);
		// handle logging
		// TODO: plug the logging option into the CCAPI config settings
		if( variables.ccapi.loggingEnabled() and arrayLen(logArray) )
			variables.utils.bulkLogAppend(logArray);
	</cfscript>
	<cfreturn result>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
--->
<cffunction name="deletePage" access="public" output="true" returntype="struct" hint="Deletes the page based on the argument data">
	<cfargument name="deletePageData" type="struct" required="true" hint="Standard Metadata like 'PageID, SubsiteID'">		
	<cfscript>
		var pageData = structNew();
		var ws = "";
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var result = structNew();
		result.pageDeleted = false;
		result.msg = "";
		// construct the CCAPI object
		variables.ccapi.initCCAPI();
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
		// clear locks before starting
		variables.ccapi.clearLock(pageData.pageID);
		// Logout
		logoutResult = variables.ccapi.logout();
	</cfscript>
	<cfreturn result>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$copyPage
Summary:
	Duplicates the page from source to destination using destination template. 
	IF sourceCustomElementNames and destCustomElementNames are defined it will attempt a ccapi set on the destCustomElementNames from the source set.
Returns:
	Struct boolean
Arguments:
	numeric: sourcePageID 
	numeric: destinationSubsiteID 
	numeric: destinationTemplateID 
	array: sourceCustomElementNames 
	array: destCCAPIElementNames 
History:
	2010-11-05 - RAK - Created
--->
<cffunction name="copyPage" access="public" returntype="boolean" hint="Duplicates the page from source to destination using destination template. ">
	<cfargument name="sourcePageID" type="numeric" required="true">
	<cfargument name="destinationSubsiteID" type="numeric" required="true">
	<cfargument name="destinationTemplateID" type="numeric" required="false">
	<cfargument name="sourceCustomElementNames" type="array" required="false" default="#ArrayNew(1)#">
	<cfargument name="destCCAPIElementNames" type="array" required="false" default="#ArrayNew(1)#">
	
	<cfscript>
		var i = 1;
		var j = 1;
		var k = 1;
		var customElementFormID = "";
		var elementInformation = "";
		var customData = "";
		var stdMetadata = StructNew();
		var data = StructNew();
		var currentField = "";
		var custMetadata = application.ADF.csData.getCustomMetadata(arguments.sourcePageID);
		var sourcePage = application.ADF.csData.getStandardMetadata(arguments.sourcePageID);
		
		//Error checking
		if(ArrayLen(sourceCustomElementNames) neq ArrayLen(destCCAPIElementNames)){
			application.ADF.utils.logAppend("Source custom element list is not the same length of custom element names.","copyPageLog.txt");
			return false;
		}
		
		//Does the page exist? If so throw an exception telling them so
		if(application.ADF.csData.getCSPageByName(sourcePage.name,arguments.destinationSubsiteID)){
			application.ADF.utils.logAppend("Page already exists: '#sourcePage.name#' in subsiteID: #arguments.destinationSubsiteID#","copyPageLog.txt");
			return false;
		}
		
		//setup the stdMetadata from our source page
		stdMetadata = sourcePage;
		stdMetadata.templateID = arguments.destinationTemplateID;
		stdMetadata.subsiteID = arguments.destinationSubsiteID;

		//Create the page
		newPage = application.ADF.csPage.createPage(stdMetadata,custMetadata);
		if(!newPage.pageCreated){//we couldnt create the page! Log the error and return out false.
			application.ADF.utils.logAppend("There was an error while creating page: '#stdMetadata.name#' in subsiteID: #stdMetadata.subsiteID#","copyPageLog.txt");
			return false;
		}
		//Page creation successful!
		newPageID = newPage.newPageID;
		
		//Iterate over each element and process the imports!
		for(i=1;i<=ArrayLen(arguments.sourceCustomElementNames);i++){
			customElementFormID = application.ADF.ceData.getFormIDByCEName(arguments.sourceCustomElementNames[i]);
			customData = application.ADF.ceData.getElementInfoByPageID(
								pageID = arguments.sourcePageID,
								formid = customElementFormID);
			//Setup the data for each custom element
			data = StructNew();
			data.subsiteID = arguments.destinationSubsiteID;
			data.pageID = newPageID;
			data.submitChange = 1;
			data.submitChange_comment = "Submit data for Custom element through API";
			//Get the tabs, iterate over 
			elementTabs = application.ADF.ceData.getTabsFromFormID(customElementFormID,true);
			//Iterate over each tab
			for(k=1;k<=ArrayLen(elementTabs);k++){
				//Iterate over each field in the tab
				for(j=1;j<=ArrayLen(elementTabs[k].fields);j++){
					//Get the current field for the current tab
					currentField = elementTabs[k].fields[j];
					//Its a formatted text block! Fix the entities!}
					if(currentField.defaultValues.type == "formatted_text_block"){
						customData.values[currentField.fieldName] = server.commonspot.udf.html.DECODEENTITIES(customData.values[currentField.fieldName]);
					}
					//Fill out data with the updated value
					data[currentField.fieldName] = customData.values[currentField.fieldName];
				}
			}
			//Populate the element with the data
			populateContentResults = application.ADF.csContent.populateContent(destCustomElementNames[i],data);
			if(!populateContentResults.contentUpdated){
				application.ADF.utils.logAppend("There was an error while updating element: '#destCustomElementNames[i]#' on page: '#stdMetadata.name#' in subsiteID: #stdMetadata.subsiteID#","copyPageLog.txt");
				return false;
			}
		}
		//Log our success!
		application.ADF.utils.logAppend("Page '#stdMetadata.name#' created in subsiteID: #stdMetadata.subsiteID# succesfully.","copyPageLog.txt");
		return true;
	</cfscript>
</cffunction>

</cfcomponent>