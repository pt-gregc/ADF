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
	apiDocument_1_0.cfc
Summary:
	API Uploaded Document functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
--->
<cfcomponent displayname="apiDocument_1_0" extends="ADF.core.Base" hint="CCAPI functions for the ADF Library">

<cfproperty name="version" value="1_0_1">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="APIDocument_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$deleteRemote
Summary:
	Deletes a commonspot uploaded document using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/UploadedDocument/delete.html
Returns:
	Struct
Arguments:
	Numeric csPageID	
	Boolean ignoreWarnings		
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="deleteRemote" access="public" returntype="struct" hint="Deletes a page or template.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="ignoreWarnings" type="boolean"  default="false" required="false" hint="a flag to delete the page even if page warning are thrown. Use with caution!">
	
	<cfscript>
		var pageCmdResult = StructNew();
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "UploadedDocument";
		commandArgs['method'] = "delete";
		commandArgs['args'] = StructNew();
		commandArgs['args'].id = arguments.csPageID;
		commandArgs['args'].ignoreWarnings = arguments.ignoreWarnings;
		
		try 
		{
			// Returns Void
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
			pageCmdResult["CMDSTATUS"] = true;
			pageCmdResult["CMDRESULTS"] = true;
		} 
		catch ( any e ) 
		{
			pageCmdResult["CMDSTATUS"] = false;
			if ( StructKeyExists(e,"Reason") AND StructKeyExists(e['Reason'],"pageID") ) 
				pageCmdResult["CMDRESULTS"] = e['Reason']['pageID']; 
			else if ( StructKeyExists(e,"message") )
				pageCmdResult["CMDRESULTS"] = e.message;
			else
				pageCmdResult["CMDRESULTS"] = e;
		}
		return pageCmdResult;
	</cfscript>
</cffunction>

</cfcomponent>