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
	csSecurity_1_0.cfc
Summary:
	Custom Element Security functions for the ADF Library
Version:
	1.0
History:
	2009-07-08 - MFC - Created
	2011-10-04 - GAC - Updated comment block headers
	2015-06-11 - GAC - Updated the component extends to use the libraryBase path
--->
<cfcomponent displayname="csSecurity_1_0" extends="ADF.lib.libraryBase" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="1_0_2">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="CSSecurity_1_0">

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	M. Carroll
Name:
	$isValidContributor
Summary:	
	Returns T/F if the logged in user is a content contributor
Returns:
	Boolean
Arguments:
	Void
History:
	2009-07-08 - MFC - Created
	2010-11-28 - MFC - Added new check for user in the request scope.
--->
<cffunction name="isValidContributor" access="public" returntype="boolean" hint="Returns T/F if the logged in user is a content contributor">
	<cfscript>
		var result = false;
		// Verify if the logged in user id contributor
		if ( StructKeyExists(request,"user") AND StructKeyExists(request.user, "licensedcontributor") AND request.user.licensedcontributor EQ 1){
			result = true;
		}
	</cfscript>
	<cfreturn result>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M. Carroll
Name:
	$isValidCPAdmin
Summary:	
	Returns T/F if the logged in user is a member of the CP Admin group
Returns:
	Boolean
Arguments:
	Void
History:
	2009-07-08 - MFC - Created
--->
<cffunction name="isValidCPAdmin" access="public" returntype="boolean" hint="Returns T/F if the logged in user is a member of the CP Admin group">
	<cfscript>
		var result = false;
		// Verify if the logged in user id contributor
		if ( (StructKeyExists(request.user, "grouplist")) AND (ListFind(request.user.grouplist, 5) GTE 1) )
			result = true;
	</cfscript>
	<cfreturn result>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	M. Carroll
Name:
	$validateProxy
Summary:
	Returns T/F for if the component method is in the Proxy White List.
Returns:
	Boolean - T/F
Arguments:
	Struct - bean - Component bean name
	String - method - Method requesting permission
History:
	2009-11-05 - MFC - Created
	2011-03-20 - MFC - Reconfigured Proxy White List to store in application space 
						to avoid conflicts with multiple sites.
	2011-09-22 - RAK - Removed else statement becuase it was not needed and combined if statements
--->
<cffunction name="validateProxy" access="public" returntype="boolean" hint="Returns T/F for if the component method is in the Proxy White List.">
	<cfargument name="bean" type="string" required="true" hint="Component bean name">
	<cfargument name="method" type="string" required="true" hint="Method requesting permission">
	<cfscript>
		// Check if the bean exists in the proxy white list struct
		// If we have a method list and we have a match to our argument
		if ( StructKeyExists(application.ADF.proxyWhiteList, arguments.bean)
		      and ListFindNoCase(application.ADF.proxyWhiteList[arguments.bean], arguments.method) ){
			return true;
		}
		return false;
	</cfscript>
</cffunction>

</cfcomponent>