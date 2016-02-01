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
	apiImage_1_0.cfc
Summary:
	API Image functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
    2016-01-29 - GAC - Added createFromDataRemote and deleteRemote methods
--->
<cfcomponent displayname="apiImage_1_0" extends="ADF.lib.libraryBase" hint="API Image functions for the ADF Library">

<cfproperty name="version" value="1_0_3">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="apiRemote" type="dependency" injectedBean="apiRemote_1_0">
<cfproperty name="wikiTitle" value="APIImage_1_0">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$createFromDataRemote
Summary:
	Creates a commonspot image using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/image/createfromdata.html
Returns:
	Struct
Arguments:
	String subsiteIDOrURL
	String fileName
	String encodedImageData
	Boolean isPublic
	Numeric categoryID
	String description
	Array metadata
History:
	2016-01-29 - GAC - Created
--->
<cffunction name="createFromDataRemote" access="public" returntype="struct" hint="">
	<cfargument name="subsiteIDOrURL" type="string" required="true" hint="">
	<cfargument name="fileName" type="string" required="true" hint="">
	<cfargument name="encodedImageData" type="string" required="true">
	<cfargument name="isPublic" type="boolean" required="false" default="true">
	<cfargument name="categoryID" type="numeric" required="false" default="1">
	<cfargument name="description" type="string" required="false" default="image">
	<cfargument name="metadata" type="array" required="false" default="#ArrayNew(1)#">

	<cfscript>
		var result = StructNew();
		var cmdResults = StructNew();
		var commandArgs = StructNew();
		var imageID = 0;

		commandArgs['Target'] = "image";
		commandArgs['method'] = "createFromData";
		commandArgs['args'] = StructNew();
		commandArgs['args'].subsiteIDOrURL = arguments.subsiteIDOrURL;
		commandArgs['args'].fileName = arguments.fileName;
		commandArgs['args'].encodedImageData = arguments.encodedImageData;
		commandArgs['args'].isPublic = arguments.isPublic;
		commandArgs['args'].categoryID = arguments.categoryID;
		commandArgs['args'].description = arguments.description;
		commandArgs['args'].metadata = arguments.metadata;

		try
		{
			// basicly just returns void and code
			cmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			//WriteDump(cmdResults);

			if ( StructKeyExists(cmdResults,"data") )
		   	{
		   		result["CMDRESULTS"] = cmdResults.data;
		   		result["CMDSTATUS"] = true;
				result["MSG"] = "Success: image was created.";
				imageID = cmdResults.data;
		   	}
		   	else
		   	{
			   	if ( StructKeyExists(cmdResults,"status") AND  StructKeyExists(cmdResults.status,"code") )
			   		result["CMDRESULTS"] = cmdResults.status.code;
			   	else
			   		result["CMDRESULTS"] = cmdResults;

				result["CMDSTATUS"] = false;
				result["MSG"] = "Fail: There was an error creating the image.";
		   	}
		}
		catch (any e)
		{
			result["CMDSTATUS"] = false;
			result["CMDRESULTS"] = e;
			result["MSG"] = "Fail: There was an error creating the image.";

			// Log Page Keyword Update Failure
		 	//doErrorLogging("cmdapi-image-create","createFromDataRemote",result);
		}

		result["fileName"] = arguments.fileName;
		result["imageID"] = imageID;

		return result;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$deleteRemote
Summary:
	Deletes a commonspot image using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/image/delete.html
Returns:
	Struct
Arguments:
	Numeric csImageID
	Boolean ignoreWarnings
History:
	2016-01-29 - GAC - Created
--->
<cffunction name="deleteRemote" access="public" returntype="struct" hint="Deletes an image.">
	<cfargument name="csImageID" type="numeric" required="true" hint="numeric commonspot image id">
	<cfargument name="ignoreWarnings" type="boolean"  default="false" required="false" hint="a flag to delete the image even if warning are thrown. Use with caution!">

	<cfscript>
		var cmdResults = StructNew();
		var result = StructNew();
		var commandArgs = StructNew();

		commandArgs['Target'] = "Image";
		commandArgs['method'] = "delete";
		commandArgs['args'] = StructNew();
		commandArgs['args'].imageID = arguments.csImageID;
		commandArgs['args'].ignoreWarnings = arguments.ignoreWarnings;

		try
		{
			cmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			//WriteDump(cmdResults);

			if ( StructKeyExists(cmdResults,"status") AND  StructKeyExists(cmdResults.status,"code") AND cmdResults.status.code EQ 200 )
		   	{
		   		result["CMDRESULTS"] = cmdResults.status;
		   		result["CMDSTATUS"] = true;
				result["MSG"] = "Success: image was deleted.";
		   	}
		   	else
		   	{
			   	if ( StructKeyExists(cmdResults,"status") )
			   		result["CMDRESULTS"] = cmdResults.status;
			   	else
			   		result["CMDRESULTS"] = cmdResults;

				result["CMDSTATUS"] = false;
				result["MSG"] = "Fail: There was an error deleting the image.";
		   	}
		}
		catch ( any e )
		{
			result["CMDSTATUS"] = false;
			if ( StructKeyExists(e,"Reason") )
				result["CMDRESULTS"] = e['Reason'];
			else if ( StructKeyExists(e,"message") )
				result["CMDRESULTS"] = e.message;
			else
				result["CMDRESULTS"] = e;
		}
		return result;
	</cfscript>
</cffunction>

</cfcomponent>