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
/* *********************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	application.cfc
Summary:
	Application.cfc for the file_uplaoder field
History:
	2011-08-23 - RAK - Created
--->
<cfcomponent>
	<cfset this.sessionManagement = true>
	
	<cffunction name="onRequestStart" access="public" returntype="any">
		<cfscript>
			// this will come through an AJAX call
			if( structKeyExists(url, "subsiteURL") )
				loadSiteAppSpace(url.subsiteURL);
			else if( structKeyExists(form, "subsiteURL") )
				loadSiteAppSpace(form.subsiteURL);
			else if( structKeyExists(request.params, "subsiteURL") AND LEN(request.params.subsiteURL) ) // Check if subsiteURL is defined in request.params and has a value.
				loadSiteAppSpace(request.params.subsiteURL);
		</cfscript>
	</cffunction>
	
	<cffunction name="loadSiteAppSpace" access="public" returntype="void">
		<cfargument name="subsiteURL" required="true" type="string">
		<cfinclude template="#arguments.subsiteURL#Application.cfm">
	</cffunction>

</cfcomponent>