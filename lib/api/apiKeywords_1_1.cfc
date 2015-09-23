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
	apiKeywords_1_1.cfc
Summary:
	API Keywords functions for the ADF Library
Version:
	1.1
History:
	2015-09-11 - GAC - Created
--->
<cfcomponent displayname="apiKeywords_1_1" extends="ADF.lib.api.apiKeywords_1_0" hint="API Keywords functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="apiRemote" type="dependency" injectedBean="apiRemote_1_0">
<!---<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">--->
<cfproperty name="wikiTitle" value="APIKeywords_1_1">

<!---//////////////////////////////////////////////////////--->
<!---//            REMOTE COMMAND API METHODS            //--->
<!---//////////////////////////////////////////////////////--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$setPageKeywordsRemote
Summary:
	Adds a keywords to an object. If a keyword does not exit, CommonSpot creates and adds it. 
	However, if the user does not have rights to add new keywords, this method returns a comma-delimited list of keywords that could not be added.

	http://{servername}/commonspot/help/api_help/Content/Components/Keywords/setForObject.html
Returns:
	Struct
Arguments:
	Numeric - csPageID	
	String - keywordList			
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="setPageKeywordsRemote" access="public" returntype="struct" hint="Adds a keywords to an object. If a keyword does not exit, CommonSpot creates and adds it.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="keywordList" type="string" required="true" hint="list of keywords to be added to the page">
	
	<cfscript>
		var pageResult = StructNew();
		var pageCmdResult = StructNew();
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "keywords";
		commandArgs['method'] = "setForObject";
		commandArgs['args'] = StructNew();
		commandArgs['args'].objectID = arguments.csPageID;
		commandArgs['args'].keywordList = arguments.keywordList;
		
		try 
		{
			// basicly just returns void and code 
			pageCmdResults = variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);

			pageResult["CMDSTATUS"] = true;
			pageResult["MSG"] = "Success: Keywords were updated for the page.";
			
			if ( StructKeyExists(pageCmdResults,"status")  )
				pageResult["CMDRESULTS"] = pageCmdResults.status;
			else
				pageResult["CMDRESULTS"] = pageCmdResults;
		} 
		catch (any e) 
		{
			pageResult["CMDSTATUS"] = false;
			pageResult["CMDRESULTS"] = e;
			pageResult["MSG"] = "Fail: There was an error updating the keywords for the page.";
			
			// Log Page Keyword Update Failure
		 	//doErrorLogging("cmdapi-keyword-update","setPageKeywordsRemote",pageResult);
		}
		
		pageResult["KEYWORDS"] = arguments.keywordList;
		pageResult["PAGEID"] = arguments.csPageID;
		
		return pageResult;
	</cfscript>
</cffunction>

</cfcomponent>