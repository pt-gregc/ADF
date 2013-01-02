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
	apiElement.cfc
Summary:
	API Element functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
--->
<cfcomponent displayname="apiElement" extends="ADF.core.Base" hint="CCAPI functions for the ADF Library">

<cfproperty name="version" value="1_0_1">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API Elements">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$populateCustom
Summary:
	Populates a custom element record.
	Return structure will have a status code and message
Returns:
	Struct status - returns the status of the update with the following keys
		status - Did the content get updated
		msg - Error message if available
		data - Structure to return data
Arguments:
	String elementName - the named element which content will be added for
	Struct data - the data for the element
	numeric - forceSubsiteID - If set this will override the subsiteID in the data.
	numeric - forcePageID - If set this will override the pageID in the data.
	boolean - forceLogout - Flag to keep the API session logged in for a continuous process. 
History:
	2012-02-24 - MFC - Created
--->
<cffunction name="populateCustom" access="public" returntype="struct">
	<cfargument name="elementName" type="string" required="true" hint="The name of the element from the CCAPI configuration">
	<cfargument name="data" type="struct" required="true" hint="Data for either the Texblock element or the Custom Element">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="If set this will override the subsiteID in the data.">
	<cfargument name="forcePageID" type="numeric" required="false" default="-1" hint="If set this will override the pageID in the data.">
	<cfargument name="forceLogout" type="boolean" required="false" default="true" hint="Flag to keep the API session logged in for a continuous process.">
	<cfscript>
		var result = structNew();
		var logStruct = structNew();
		var logArray = arrayNew(1);
		var thisElementConfig = structNew();
		var contentStruct = structNew();
		var apiResponse = "";
		var loggingEnabled = true;
		
		// Init the return data structure
		result.status = false;
		result.msg = "";
		result.data = StructNew();
	</cfscript>

	<!--- LOCK to prevent multiple CCAPI calls to update 
			custom elements through a single CCAPI page.
			Prevents the "security-exception -- conflict" error message.
	 --->
	<cflock type="exclusive" name="CCAPIPopulateContent" timeout="30">
		<cfscript>
			// Error handling
			try {
				// Check the element is in the API Config file and defined		
				apiConfig = variables.api.getAPIConfig();
				
				// Set the logging flag
				if ( isStruct(apiConfig) 
					AND StructKeyExists(apiConfig, "logging")
					AND StructKeyExists(apiConfig.logging, "enabled")
					AND apiConfig.logging.enabled == 1 )
					loggingEnabled = true;
				else
					loggingEnabled = false;
				
				if( isStruct(apiConfig) 
					AND StructKeyExists(apiConfig, "elements")
					AND StructKeyExists(apiConfig.elements, arguments.elementName) ) {
					// set up local variable for the element
					thisElementConfig = apiConfig.elements[arguments.elementName];
					// If there is no subsite default to 1
					if( not StructKeyExists(thisElementConfig, "subsiteID") )
						thisElementConfig["subsiteID"] = 1;
				}
				else {
					// Log the error message also
					if ( loggingEnabled ) {
						logStruct.msg = "#request.formattedTimestamp# - Element [#arguments.elementName#] is not defined in the API Configuration.";
						logStruct.logFile = "API_populate_custom_error.log";
						arrayAppend(logArray, logStruct);
						variables.utils.bulkLogAppend(logArray);
					}
					result.msg = "Element [#arguments.elementName#] is not defined in the API Configuration.";
					return result;	
				}
				
				// Check that we are updating a custom element
				if( thisElementConfig["elementType"] NEQ "custom" ){
					if ( loggingEnabled ) {
						// Log the error message also
						logStruct.msg = "#request.formattedTimestamp# - Element [#arguments.elementName#] is not defined as a custom element in the API Configuration.";
						logStruct.logFile = "API_populate_custom_error.log";
						arrayAppend(logArray, logStruct);
						variables.utils.bulkLogAppend(logArray);
					}
					result.msg = "Element [#arguments.elementName#] is not defined as a custom element in the API Configuration.";
					return result;
				}
				
				// If they forced the subsite ID, then set in the config
				if (arguments.forceSubsiteID neq -1){
					thisElementConfig["subsiteID"] = arguments.forceSubsiteID;
				} else if ( StructKeyExists(arguments.data, "subsiteID")){
					//Otherwise check to see if subsiteID has been passed into data (signifying a local custom element)
					thisElementConfig["subsiteID"] = arguments.data.subsiteID;
				}
				
				// If they forced the page ID, then set in the config
				if (arguments.forcePageID neq -1){
					thisElementConfig["pageID"] = arguments.forcePageID;
				} else if ( StructKeyExists(arguments.data, "pageID") ){
					//Otherwise check to see if the data passed in for this element contains "pageID"
					thisElementConfig["pageID"] = arguments.data.pageID;
				}
			
				// Construct specific data for the content creation API
				contentStruct.subsiteID = thisElementConfig["subsiteID"];
				contentStruct.pageID = thisElementConfig["pageID"];
				
				if( StructKeyExists(thisElementConfig, "controlID") )
					contentStruct.controlID = thisElementConfig["controlID"];
				else
					contentStruct.controlName = thisElementConfig["controlName"];	
				
				// If we find the option to submit change in the data
				if( StructKeyExists(arguments.data, "submitChange") )
					contentStruct.submitChange = arguments.data.submitChange;
				else
					contentStruct.submitChange = "1";
				
				// If we find the comment for the submission in the data struct
				if( StructKeyExists(arguments.data, "submitChangeComment") )
					contentStruct.submitChange_comment = arguments.data.submitChangeComment;
				else
					contentStruct.submitChange_comment = "Submit data for Custom element through API";
				
				// Following structure contains the data.  The structure keys are the 'field names'
				contentStruct.data = arguments.data;
				
				// Call the API to run the CCAPI Command
				apiResponse = variables.api.runCCAPI(method="populateCustomElement",
													 sparams=contentStruct);
			
				// Check that the API ran
				if ( apiResponse.status ){
							
					// Pass back the API return to the results
					result = apiResponse;
					
					// Log the success
					if ( listFirst(result.data, ":") eq "Success" ){
						logStruct.msg = "#request.formattedTimestamp# - Elemented Updated/Created: #thisElementConfig['elementType']# [#arguments.elementName#]. ContentUpdateResponse: #result.data#";
						logStruct.logFile = 'CCAPI_populate_content.log';
						arrayAppend(logArray, logStruct);
					}
					else {
						// Log the error message also
						result.msg = listRest(result.data, ":");
						logStruct.msg = "#request.formattedTimestamp# - Error updating element: #thisElementConfig['elementType']# [#arguments.elementName#]. Error recorded: #result.msg#";
						logStruct.logFile = 'API_populate_custom_error.log';
						arrayAppend(logArray, logStruct);
					}
				}
				else {
					// Error while running the API Command
					result = apiResponse;
					// Log the error message also
					logStruct.msg = "#request.formattedTimestamp# - Error [Message: #result.msg#]";
					if ( StructKeyExists(result.data, "detail") )
						logStruct.msg = logStruct.msg & " [Details: #result.data.detail#]";
					logStruct.logFile = "API_populate_custom_error.log";
					arrayAppend(logArray, logStruct);
				}
			}
			catch (e ANY){
				// Error caught, send back the error message
				result.status = false;
				result.msg = e.message;
				result.data = e;
				// Log the error message also
				logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#] [Details: #e.detail#]";
				logStruct.logFile = "API_populate_custom_error.log";
				arrayAppend(logArray, logStruct);
			}
			
			// Write the log files
			if ( loggingEnabled and arrayLen(logArray) )
				variables.utils.bulkLogAppend(logArray);
			
			// Check if we want to force the logout
			if ( arguments.forceLogout )
				variables.api.logout();
			
			return result;
		</cfscript>
	</cflock>
</cffunction>

</cfcomponent>