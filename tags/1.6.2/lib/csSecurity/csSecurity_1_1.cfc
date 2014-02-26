<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2014.
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
	csSecurity_1_1.cfc
Summary:
	 Security functions for the ADF Library
Version:
	1.1
History:
	2011-10-04 - GAC - Created
	2012-12-07 - MFC - Moved new functions to CSSecurity v1.2.
--->
<cfcomponent displayname="csSecurity_1_1" extends="ADF.lib.csSecurity.csSecurity_1_0" hint="Security functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="CSSecurity_1_1">

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
	Boolean - enforceVersions
History:
	2009-11-05 - MFC - Created
	2011-03-20 - MFC - Reconfigured Proxy White List to store in application space 
						to avoid conflicts with multiple sites.
	2011-09-22 - RAK - Removed else statement becuase it was not needed and combined if statements
	2011-10-04 - GAC - Added argument to validate Bean names with or without versions suffixes
--->
<cffunction name="validateProxy" access="public" returntype="boolean" output="false" hint="Returns T/F for if the component method is in the Proxy White List.">
	<cfargument name="bean" type="string" required="true" hint="Component bean name">
	<cfargument name="method" type="string" required="true" hint="Method requesting permission">
	<cfargument name="enforceVersions" type="boolean" required="false" default="false" hint="T/F flag used to set whether or not to enforce proxyWhiteList bean versions">
	<cfscript>
		var newBean = arguments.bean;
		var newProxy = application.ADF.proxyWhiteList;
		// if useVersions is false rebuild the proxyWhiteList structure removing version suffixes and combine method lists
		if ( NOT arguments.enforceVersions )
		{
			newBean = ListFirst(newBean,"_");
			newProxy = buildProxyWithoutBeanVersions();
		}
		// Check if the bean exists in the proxy white list struct
		// If we have a method list and we have a match so return true
		if ( StructKeyExists(newProxy, newBean) AND ListFindNoCase(newProxy[newBean], arguments.method) )
		{
			return true;
		}	
		return false;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.	 	
	G. Cronkright
Name:
	$buildProxyWithoutBeanVersions
Summary:
	Returns a Proxy White List structure with the versions suffixes striped from the bean names and combine method lists as needed
Returns:
	Struct
Arguments:
	NA
History:
	2011-10-04 - GAC - Created
	2011-10-04 - GAC - Replace a list loop with the ListUnion function to merge method lists from multiple versions of a lib component
---> 
<cffunction name="buildProxyWithoutBeanVersions" access="public" returntype="struct" output="true" hint="Returns a Proxy White List structure with the versions suffixes striped from the bean names.">
	<cfscript>
		var proxyStruct = application.ADF.proxyWhiteList;
		var retStruct = StructNew();
		var key = "";
		var newKey = "";
		var i = 0;
		var newItem = "";
		// Loop over proxyWhiteList Structure
		for ( key IN proxyStruct ){
			// Create the new StuctKey without the version suffix
			newKey = ListFirst(key,"_");
			// If a pruned struct key already exists in the new proxy struct add the unique methods to the existing methods list
			if ( StructKeyExists(retStruct,newKey) )
			{
				// Combine the new methods list with the current methods list for the new struct key			
				retStruct[newKey] = variables.data.listUnion(retStruct[newKey],proxyStruct[key]);	
			}
			else
			{
				retStruct[newKey] = proxyStruct[key];
			}	
		}
		return retStruct;
	</cfscript>
</cffunction>

</cfcomponent>