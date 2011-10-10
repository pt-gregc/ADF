<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	Application.cfc
Summary:
	Application file.
Version:
	1.5.0.630
History:
	2009-06-17 - RLW - Created
	2011-01-19 - RAK - Fixed typo in utils
	2011-03-11 - MFC - Added If condition to check if subsiteURL is defined in request.params and has a value.
						Changed loadSiteAppSpace function to 'public' access.
	2011-03-19 - RLW - Moved the conditional logic of url scope check up because left panels don't have request.params until after Application.cfm executes
	2011-10-04 - GAC - Updated getBean csSecurity call to reference csSecurity_1_1
--->
<cfcomponent>
	
	<cfset this.sessionManagement = true>
	
	<cffunction name="onRequestStart" access="public" returntype="any">
		<!--- // include CommonSpots application.cfm --->
		<!--- <cfinclude template="/commonspot/Application.cfm"> --->
		<cfscript>
			// this will come through an AJAX call
			if( structKeyExists(url, "subsiteURL") )
				loadSiteAppSpace(url.subsiteURL);
			else if( structKeyExists(form, "subsiteURL") )
				loadSiteAppSpace(form.subsiteURL);
			else if( structKeyExists(request.params, "subsiteURL") AND LEN(request.params.subsiteURL) ) // Check if subsiteURL is defined in request.params and has a value.
				loadSiteAppSpace(request.params.subsiteURL);
			// Verify the security for the logged in user
			if ( NOT server.ADF.objectFactory.getBean("csSecurity_1_1").isValidContributor() )
				server.ADF.objectFactory.getBean("utils_1_0").abort();
		</cfscript>
		
	</cffunction>
	
	<cffunction name="loadSiteAppSpace" access="public" returntype="void">
		<cfargument name="subsiteURL" required="true" type="string">
		<cfinclude template="#arguments.subsiteURL#Application.cfm">
	</cffunction>

</cfcomponent>