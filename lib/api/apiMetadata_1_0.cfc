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
	apiMetadata_1_0.cfc
Summary:
	API Metadata functions for the ADF Library
Version:
	1.0
History:
	2015-09-11 - GAC - Created
--->
<cfcomponent displayname="apiMetadata_1_0" extends="ADF.lib.libraryBase" hint="API Metadata functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="apiRemote" type="dependency" injectedBean="apiRemote_1_0">
<!--- <cfproperty name="utils" type="dependency" injectedBean="utils_2_0"> --->
<cfproperty name="wikiTitle" value="APIMetadata_1_1">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$update
Summary:
	Updates the properties for a page (standard and custom)
	http://{servername}/commonspot/help/api_help/content/components/Content/updateMetadata.html
Returns:
	Struct
Arguments:
		csPageID 	PageIDImageIDMultimediaID 	Required 	The ID of the object whose metadata we wish to update.
		metadata		MetadataValueArray			Optional. 	Defaults to '#ArrayNew(1)#'.	An array of MetadataValue structures that describes the metadata field(s) for the specified page, or an empty array if no metadata is to be specified. Note, you should pass data in the array for all the metadata fields that have data. Any existing data, for any non-specified fields will be either be deleted (if no default value is defined for that field) or updated with the default value.
History:
	2016-08-26 - GAC - Created
--->
<cffunction name="update" access="public" returntype="struct" hint="Updates custom metadata for a CS Object.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="metadata" type="any" required="true" hint="a custom metadata structure of structures or a custom metadata array of structures">

	<cfscript>
		var retResult = StructNew();
		var contentComponent = server.CommonSpot.api.getObject('Content');
		var cMetadataArray = ArrayNew(1);
		var cMetadata = StructNew();

		if ( IsStruct(arguments.metadata) )
		{
			// Convert metadata struct to an Array of Structs
			cMetadataArray = application.ADF.csData.metadataStructToArray(metadata=arguments.metadata);
		}
		else if ( IsArray(arguments.metadata) )
			cMetadataArray = arguments.metadata;

		try
		{
			// contentComponent.updateMetadata returns VOID
			contentComponent.updateMetadata(id=arguments.csPageID,metadata=cMetadataArray);

		    // Check the return status has a LENGTH
		    retResult["CMDSTATUS"] = true;
		    retResult["CMDRESULTS"] = "Success: Custom Metadata was successful updated.";
		}
		catch (any e)
		{
		    retResult["CMDSTATUS"] = false;
		    retResult["CMDRESULTS"] = "Failed: Custom Metadata was not updated.";
		    retResult["CFCATCH"] = e;
		}

		return retResult;
	</cfscript>
</cffunction>

<!---//////////////////////////////////////////////////////--->
<!---//            REMOTE COMMAND API METHODS            //--->
<!---//////////////////////////////////////////////////////--->

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$updateMetadata
Summary:
	Updates the properties for a page (standard and custom)
	http://{servername}/commonspot/help/api_help/content/components/Content/updateMetadata.html
Returns:
	Struct
Arguments:
		csPageID 	PageIDImageIDMultimediaID 	Required 	The ID of the object whose metadata we wish to update.
		metadata		MetadataValueArray			Optional. 	Defaults to '#ArrayNew(1)#'.	An array of MetadataValue structures that describes the metadata field(s) for the specified page, or an empty array if no metadata is to be specified. Note, you should pass data in the array for all the metadata fields that have data. Any existing data, for any non-specified fields will be either be deleted (if no default value is defined for that field) or updated with the default value.
History:
	2016-08-26 - GAC - Created
--->
<cffunction name="updateRemote" access="public" returntype="struct" hint="Updates custom metadata for a CS Object.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="metadata" type="any" required="true" hint="a custom metadata structure of structures or a custom metadata array of structures">

	<cfscript>
		var retResult = StructNew();
		var commandArgs = StructNew();
		var cMetadataArray = ArrayNew(1);
		var cMetadata = StructNew();

		if ( IsStruct(arguments.metadata) )
		{
			// Convert metadata struct to an Array of Structs
			cMetadataArray = application.ADF.csData.metadataStructToArray(metadata=arguments.metadata);
		}
		else if ( IsArray(arguments.metadata) )
			cMetadataArray = arguments.metadata;

		commandArgs['Target'] = "Content";
		commandArgs['method'] = "updateMetadata";
		commandArgs['args'] = StructNew();
		commandArgs['args'].id = arguments.csPageID;
		commandArgs['args'].metadata = cMetadataArray;

		try
		{
			// page.SaveInfo returns VOID
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);

		    // Check the return status has a LENGTH
		    retResult["CMDSTATUS"] = true;
		    retResult["CMDRESULTS"] = "Success: Custom Metadata was successful updated.";
		}
		catch (any e)
		{
		    retResult["CMDSTATUS"] = false;
		    retResult["CMDRESULTS"] = "Failed: Custom Metadata was not updated.";
		    retResult["CFCATCH"] = e;
		}

		return retResult;
	</cfscript>
</cffunction>

</cfcomponent>