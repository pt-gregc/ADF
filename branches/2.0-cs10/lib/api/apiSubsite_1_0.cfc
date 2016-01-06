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
	apiSubsite_1_0.cfc
Summary:
	API Subsite functions for the ADF Library
Version:
	1.0
History:
	2012-12-26 - MFC - Created
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
	2015-11-06 - GAC - Added the deleteRemote function 
--->
<cfcomponent displayname="apiSubsite_1_0" extends="ADF.lib.libraryBase" hint="API Subsite functions for the ADF Library">

<cfproperty name="version" value="1_0_3">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<!--- <cfproperty name="utils" type="dependency" injectedBean="utils_2_0"> --->
<cfproperty name="wikiTitle" value="APISubsite_1_0">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$deleteRemote
Summary:
	Deletes a commonspot page using the public command API
	http://{servername}/commonspot/help/api_help/Content/Components/Subsite/delete.html
Returns:
	Struct
Arguments:
	Numeric csSubsiteID		
History:
	2015-11-08 - GAC - Created
--->
<cffunction name="deleteRemote" access="public" returntype="struct" hint="Deletes a page or template.">
	<cfargument name="csSubsiteID" type="numeric" required="true" hint="numeric commonspot page id">
	
	<cfscript>
		var ssCmdResult = StructNew();
		var commandArgs = StructNew();
		
		commandArgs['Target'] = "subsite";
		commandArgs['method'] = "delete";
		commandArgs['args'] = StructNew();
		commandArgs['args'].subsiteID = arguments.csSubsiteID;
		
		try 
		{
			// Returns Void
			variables.apiRemote.runCmdApi(commandStruct=commandArgs,authCommand=true);
			
			ssCmdResult["CMDSTATUS"] = true;
			ssCmdResult["CMDRESULTS"] = true;
		} 
		catch ( any e ) 
		{
			ssCmdResult["CMDSTATUS"] = false;
			if ( StructKeyExists(e,"Reason") AND StructKeyExists(e['Reason'],"subsiteID") ) 
				ssCmdResult["CMDRESULTS"] = e['Reason']['subsiteID']; 
			else if ( StructKeyExists(e,"message") )
				ssCmdResult["CMDRESULTS"] = e.message;
			else
				ssCmdResult["CMDRESULTS"] = e;
		}
		return ssCmdResult;
	</cfscript>
</cffunction>

</cfcomponent>