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
	csSecurity_1_2.cfc
Summary:
	 Security functions for the ADF Library
Version:
	1.2
History:
	2012-12-07 - MFC - Created
--->
<cfcomponent displayname="csSecurity_1_2" extends="ADF.lib.csSecurity.csSecurity_1_1" hint="Security functions for the ADF Library">

<cfproperty name="version" value="1_2_1">
<cfproperty name="type" value="singleton">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="wikiTitle" value="CSSecurity_1_2">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.	
	G. Cronkright
Name:
	$isValidAuthToken
Summary:	
	Returns T/F if the passed in authToken validates or not
Returns:
	Boolean
Arguments:
	String authToken
History:
	2012-06-25 - GAC - Created
--->
<cffunction name="isValidAuthToken" access="public" returntype="boolean" hint="Returns T/F if the passed in authToken validates or not">
	<cfargument name="authToken" type="string" required="true" hint="">
	<cfscript>
		var result = true;
		
		/* Place the logic here to validate the provided auth token and return true if valid */
			
		return result;
	</cfscript>
</cffunction>

</cfcomponent>