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
	csContent_1_0.cfc
Summary:
	CCAPI Content functions for the ADF Library
Version:
	1.0.1
History:
	2009-06-17 - RLW - Created
	2011-03-20 - RLW - Updated to use the new ccapi_1_0 component (was the original ccapi.cfc file)
--->
<cfcomponent displayname="csContent_1_0" hint="Constructs a CCAPI instance and then allows you to populate Custom Elements and Textblocks" extends="ADF.core.Base">
<cfproperty name="version" value="1_0_1">
<cfproperty name="type" value="transient">
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_0">
<cfproperty name="wikiTitle" value="CSContent_1_0">

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$populateContent
Summary:
	Handles population of the textblock content
	Will send to pre process before entering content
	Return structure will have a status code and message
Returns:
	Struct status - returns the status of the update with the following keys
		contentUpdated - did the content get updated
		msg - error message if available
Arguments:
	String elementName - the named element which content will be added for
	Struct data - the data for the element
	numeric - forceSubsiteID - If set this will override the subsiteID in the data.
	numeric - forcePageID - If set this will override the pageID in the data.
History:
	2008-05-30 - RLW - Created
	2010-12-09 - RAK - added forceSubsiteID and forcePageID functionality
	2011-03-19 - RLW - added support for controlID in config
--->
<cffunction name="populateContent" access="public" returntype="struct" hint="Use this method to populate content for either a Textblock or Custom Element">
	<cfargument name="elementName" type="string" required="true" hint="The name of the element from the CCAPI configuration">
	<cfargument name="data" type="struct" required="true" hint="Data for either the Texblock element or the Custom Element">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="If set this will override the subsiteID in the data.">
	<cfargument name="forcePageID" type="numeric" required="false" default="-1" hint="If set this will override the pageID in the data.">
	<cfscript>
		var elements = "";
		var thisElement = structNew();
		var result = structNew();
		var contentStruct = structNew();
		var contentUpdateResponse = "";
		var msg = "";
		var logFile = "";
		var error = "";
		var ws = "";
		var logStruct = structNew();
		var logArray = arrayNew(1);

		// construct the CCAPI object
		variables.ccapi.initCCAPI();
		elements = variables.ccapi.getElements();
		ws = variables.ccapi.getWS();
		result.contentUpdated = false;
		// get the settings for this element
		if ( isStruct(elements) and structKeyExists(elements, arguments.elementName) )
		{
			// set up local variable for the element
			thisElement = elements[arguments.elementName];
			// if there is no subsite default to 1
			if( not structKeyExists(thisElement, "subsiteID") )
				thisElement["subsiteID"] = 1;

			//2010-12-09 - RAK - If they forced the pageID set it
			if(arguments.forceSubsiteID neq -1){
				thisElement["subsiteID"] = arguments.forceSubsiteID;
			}else if( structKeyExists(arguments.data, "subsiteID")){
				//Otherwise check to see if subsiteID has been passed into data (signifying a local custom element)
				thisElement["subsiteID"] = arguments.data.subsiteID;
			}

			// assume global custom element and use default subsiteID

			// login for the first time or to the subsite where the new page was created
			if( variables.ccapi.loggedIn() eq 'false' or ( thisElement["subsiteID"] neq variables.ccapi.getSubsiteID() ) )
				variables.ccapi.login(thisElement["subsiteID"]);

			//2010-12-09 - RAK - If they forced the pageID set it
			if(arguments.forcePageID neq -1){
				thisElement["pageID"] = arguments.forcePageID;
			}else if( structKeyExists(arguments.data, "pageID") ){
				//Otherwise check to see if the data passed in for this element contains "pageID"
				thisElement["pageID"] = arguments.data.pageID;
			}

			// clear locks before starting
			variables.ccapi.clearLock(thisElement["pageID"]);

			// construct specific data for the content creation API
			contentStruct.pageID = thisElement["pageID"];
			if( structKeyExists(thisElement, "controlID") )
				contentStruct.controlID = thisElement["controlID"];
			else
				contentStruct.controlName = thisElement["controlName"];	
							
			
			// if we find the option to submit change in the data
			if( structKeyExists(arguments.data, "submitChange") )
				contentStruct.submitChange = arguments.data.submitChange;
			else
				contentStruct.submitChange = "1";
			// if we find the comment for the submission in the data struct
			if( structKeyExists(arguments.data, "submitChangeComment") )
				contentStruct.submitChange_comment = arguments.data.submitChangeComment;
			else
				contentStruct.submitChange_comment = "Submit data for Custom element through API";
			
			// Following structure contains the data.  The structure keys are the 'field names'
			contentStruct.data = arguments.data;
			// Call CCAPI to add/update textblock
			if( thisElement["elementType"] eq "textblock")
			{
				// update textblock
				contentUpdateResponse = ws.populateTextblock(ssid=variables.ccapi.getSSID(), sParams=contentStruct);
			}
			if( thisElement["elementType"] eq "custom" )
			{
				// update custom element
				contentUpdateResponse = ws.populateCustomElement(ssid=variables.ccapi.getSSID(), sParams=contentStruct);
				// check to see if update wasn't successful
				if( listFirst(contentUpdateResponse, ":") neq "Success" )
				{
					// clear locks after completing update
					variables.ccapi.clearLock(thisElement["pageID"]);

					// If update wasn't successful then login again to the default subsite specified in the config xml file
					if( thisElement["subsiteID"] neq variables.ccapi.getSubsiteID() )
					{
						variables.ccapi.login(thisElement["subsiteID"]);
						// TODO: do we need this logging?
						//logStruct.msg = "#request.formattedTimestamp# - Relogging into #thisElement['subsiteID']#";
						//logStruct.logFile = 'populate_content.log';
						//arrayAppend(logArray, logStruct);
					}
					else
						variables.ccapi.login();
					// Now try it again after logging in
					contentUpdateResponse = ws.populateCustomElement(ssid=variables.ccapi.getSSID(), sParams=contentStruct);
					
					// TODO: do we need this logging?
					//logStruct.msg = "#request.formattedTimestamp# - 2ND ATTEMPT: contentUpdateResponse: #contentUpdateResponse#";
					//logStruct.logFile = 'populate_content.log';
					//arrayAppend(logArray, logStruct);
				}
			}
			// TODO handle debugging for texblock update call
			if( listFirst(contentUpdateResponse, ":") eq "Success" )
			{
				result.contentUpdated = true;
				result.msg = contentUpdateResponse;
				logStruct.msg = "#request.formattedTimestamp# - Elemented Updated/Created: #thisElement['elementType']# [#arguments.elementName#]. ContentUpdateResponse: #contentUpdateResponse#";
				logStruct.logFile = 'CCAPI_populate_content.log';
				arrayAppend(logArray, logStruct);
			}
			else
			{
				result.msg = contentUpdateResponse;
				// comma separated for parsing
				// 'date','pageID','contentID','subsiteID','title','error'
				error = listRest(contentUpdateResponse, ":");
				logStruct.msg = "#request.formattedTimestamp# - Error updating element: #thisElement['elementType']# [#arguments.elementName#]. Error recorded: #error#";
				logStruct.logFile = 'CCAPI_populate_content_error.log';
				arrayAppend(logArray, logStruct);
			}
			// clear locks after completing update
			variables.ccapi.clearLock(thisElement["pageID"]);
		}
		else // logging for the element name not existing
		{
			logStruct.msg = "#request.formattedTimestamp# - Element name does not exist in configuration: #arguments.elementName#";
			logStruct.logFile = "CCAPI_populate_content_error.log";
			arrayAppend(logArray, logStruct);
		}
		if( variables.ccapi.loggingEnabled() and arrayLen(logArray) )
			variables.utils.bulkLogAppend(logArray);
		variables.ccapi.logout();
	</cfscript>
	<cfreturn result>
</cffunction>
</cfcomponent>