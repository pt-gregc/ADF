<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	apiKeywords.cfc
Summary:
	API Keywords functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
--->
<cfcomponent displayname="apiKeywords" extends="ADF.core.Base" hint="API Keywords functions for the ADF Library">

<cfproperty name="version" value="1_0_2">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API Keywords">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$setCommonspotPageKeywords
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
	2012-10-22 - MFC/GAC - Created
--->
<cffunction name="setForObject" access="public" returntype="struct" hint="Adds a keywords to an object. If a keyword does not exit, CommonSpot creates and adds it.">
	<cfargument name="csPageID" type="numeric" required="true" hint="numeric commonspot page id">
	<cfargument name="keywordList" type="string" required="true" hint="list of keywords to be added to the page">
	<cfscript>
		var pageCmdResult = StructNew();
		// Use the CS 6.x Command API to SET page keywords
		var kwComponent = server.CommonSpot.api.getObject('keywords');
		var kwCmdResults = "";
		try {
			kwCmdResults = kwComponent.setForObject(arguments.csPageID,arguments.keywordList);
			pageCmdResult["CMDSTATUS"] = true;
			pageCmdResult["CMDRESULTS"] = kwCmdResults;
		} 
		catch (any e) {
			pageCmdResult["CMDSTATUS"] = false;
			pageCmdResult["CMDRESULTS"] = kwCmdResults;
		}
		return pageCmdResult;
	</cfscript>
</cffunction>

</cfcomponent>