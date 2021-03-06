<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
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
	csUpload_1_0.cfc
Summary:
	CCAPI Upload functions for the ADF Library
Version:
	1.0
History:
	2009-06-17 - MFC - Created
	2011-03-20 - RLW - Updated to use the new ccapi_1_0 component (was the original ccapi.cfc file)
	2013-11-18 - GAC - Updated the lib dependency to utils_1_2
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
	2015-10-09 - GAC - Set the ccapi injectedBean to use ccapi_1_0 since ccapi_2_0 uses the CMD API which logs in/out differently and causes errors
---> 
<cfcomponent displayname="csUpload_1_0" extends="ADF.lib.libraryBase" hint="Constructs a CCAPI instance and then allows you to Upload Images">

<cfproperty name="version" value="1_0_3">
<cfproperty name="type" value="transient">
<!--- // Must Use ccapi_1_0 here - ccapi_2_0 uses the CMD API which logs in/out differently --->
<cfproperty name="ccapi" type="dependency" injectedBean="ccapi_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_2_0">
<cfproperty name="wikiTitle" value="CSUpload_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$uploadImage
Summary:
	Handles upload of an image to the Image Gallery
	Return structure will have a status code and message
Returns:
	Struct status - returns the status of the update
Arguments:
	Struct data - the data for the element
History:
	2009-06-12 - MFC - Created
	2012-02-24 - MFC - Added TRY-CATCH around processing to logout the CCAPI if any errors.
	2014-05-01 - GAC - Fixed typo in the try/catch, switched ( e ANY ) to ( ANY e )
--->
<cffunction name="uploadImage" access="public" returntype="struct" hint="Use this method to upload images into the Image Gallery">
		<cfargument name="subsiteid" type="numeric" required="true">
		<cfargument name="data" type="struct" required="true" hint="Data for upload image.">
		<cfargument name="imgBinaryData" type="Binary" required="true" hint="Binary data of the image.">
		<cfargument name="doLogin" type="numeric" required="false" default="0" hint="Force the login always">
		<cfscript>
			var result = structNew();
			var uploadResponse = "";
			var ws = "";
			var logStruct = structNew();
			var logArray = arrayNew(1);
			
			// construct the CCAPI object
			variables.ccapi.initCCAPI();
			result.uploadCompleted = false;
			
			try {
				ws = variables.ccapi.getWS();
				
				if( variables.ccapi.loggedIn() EQ 'false' or arguments.doLogin gt 0 )	// login to the subsite where the new subsite will be created
				{
					if( arguments.subsiteid neq 0 )
						variables.ccapi.login(arguments.subsiteid);
					else
						variables.ccapi.login();
				}
				
				// create the subsite
				uploadResponse = ws.uploadImage(ssid=variables.ccapi.getSSID(), sparams=arguments.data, image=toBase64(arguments.imgBinaryData));
				// check to see if update wasn't successful
				if( listFirst(uploadResponse, ":") neq "Success" )
				{
					// check to see if there was an error logging in
					if( findNoCase(listRest(uploadResponse, ":"), "login") and not arguments.doLogin )
					{
						// resend this through the login
						uploadImage(arguments.subsiteid, arguments.data,arguments.imgBinaryData, 1);
					}
					logStruct.msg = "#request.formattedTimestamp# - Error upload image: #arguments.data.localfilename# - #listRest(uploadResponse, ':')#";
					logStruct.logFile = 'CCAPI_upload_image.log';
					arrayAppend(logArray, logStruct);
				}
				else {
					result.uploadCompleted = "true";
					logStruct.msg = "#request.formattedTimestamp# - Upload Image Success: #arguments.data.localfilename# - #uploadResponse#";
					logStruct.logFile = 'CCAPI_upload_image.log';
					arrayAppend(logArray, logStruct);
				}	
				result.uploadResponse = uploadResponse;
				
				// handle logging
				// TODO: plug the logging option into the CCAPI config settings
				if( variables.ccapi.loggingEnabled() and arrayLen(logArray) )
					variables.utils.bulkLogAppend(logArray);
			}
			catch ( ANY e )
			{
				// Error caught, send back the error message
				result.uploadCompleted = false;
				result.uploadResponse = e.message;
				
				// Log the error message also
				logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#] [Details: #e.Details#]";
				logStruct.logFile = "CCAPI_upload_image_errors.log";
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
	G. Cronkright
Name:
	$uploadDocument
Summary:
	Handles upload of a document to a designated subsite's 'upload' folder via the CCAPI 
	Return structure will have a status code and message
Returns:
	Struct status - returns the status of the upload
Arguments:
	Struct data - the data for the element
History:
	2010-01-15 - GAC - Created
	2011-02-09 - GAC - Removed self-closing CF tag slashes
	2012-02-24 - MFC - Added TRY-CATCH around processing to logout the CCAPI if any errors.
	2014-05-01 - GAC - Fixed typo in the try/catch, switched ( e ANY ) to ( ANY e )
--->
<cffunction name="uploadDocument" access="public" returntype="struct" hint="Use this method to upload a document into the upload folder of an designated subsite">
	<cfargument name="subsiteid" type="numeric" required="true">
	<cfargument name="data" type="struct" required="true" hint="Data for upload document.">
	<cfargument name="docBinaryData" type="Binary" required="true" hint="Binary data of the document.">
	<cfargument name="doLogin" type="numeric" required="false" default="0" hint="Force the login always">	
	<cfscript>
		var result = structNew();
		var uploadResponse = "";
		var ws = "";
		var logStruct = structNew();
		var logArray = arrayNew(1);
			
		// construct the CCAPI object
		variables.ccapi.initCCAPI();
		result.uploadCompleted = false;
		
		try {
			ws = variables.ccapi.getWS();
	
			if( variables.ccapi.loggedIn() EQ 'false' or arguments.doLogin gt 0 )	// login to the subsite where the new subsite will be created
			{
				if( arguments.subsiteid neq 0 )
					variables.ccapi.login(arguments.subsiteid);
				else
					variables.ccapi.login();
			}
			
			// upload document
			uploadResponse = ws.uploadDocument(ssid=variables.ccapi.getSSID(), sparams=arguments.data, document=toBase64(arguments.docBinaryData));
			
			// check to see if update wasn't successful
			if( listFirst(uploadResponse, ":") neq "Success" )
			{
				// check to see if there was an error logging in
				if( findNoCase(listRest(uploadResponse, ":"), "login") and not arguments.doLogin )
				{
					// resend this through the login
					uploadDocument(arguments.subsiteid, arguments.data, arguments.docBinaryData, 1);
				}
				logStruct.msg = "#request.formattedTimestamp# - Error upload documents: #arguments.data.localFileName# - #listRest(uploadResponse, ':')#";
				logStruct.logFile = 'CCAPI_upload_document.log';
				arrayAppend(logArray, logStruct);
			}
			else {
				result.uploadCompleted = "true";
				logStruct.msg = "#request.formattedTimestamp# - Upload documents Success: #arguments.data.localFileName# - #uploadResponse#";
				logStruct.logFile = 'CCAPI_upload_document.log';
				arrayAppend(logArray, logStruct);
			}	
			result.uploadResponse = uploadResponse;
			// Logout
			variables.ccapi.logoutResult = variables.ccapi.logout();
			// handle logging
			// TODO: plug the logging option into the CCAPI config settings
			if( variables.ccapi.loggingEnabled() and arrayLen(logArray) )
				variables.utils.bulkLogAppend(logArray);
		}
		catch ( ANY e )
		{
			// Error caught, send back the error message
			result.uploadCompleted = false;
			result.uploadResponse = e.message;
			
			// Log the error message also
			logStruct.msg = "#request.formattedTimestamp# - Error [Message: #e.message#] [Details: #e.Details#]";
			logStruct.logFile = "CCAPI_upload_document_errors.log";
			variables.utils.bulkLogAppend(logArray);
		}

		// Logout
		variables.ccapi.logout();
		
		return result;
	</cfscript>
</cffunction>

</cfcomponent>