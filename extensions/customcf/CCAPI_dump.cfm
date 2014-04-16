<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	ccapi_dump.cfm
Summary:
	A page that test access to the CCAPI by attempting to login to CommonSpot using the CCAPI webservice call
History:
	2009-06-09 - MFC - Created
	2012-01-06 - MFC - Updated to logout when complete and added ADF login test
	2012-01-24 - MFC - Updated to remove "ADFdemo" reference.
	2012-12-26 - MFC - Updated to remove "CFINVOKE" tags for RAILO.
--->

<!--- // Use this file to test to see if the CommonSpot is allowing a user to login to the CCAPI web service --->
<!--- // COPY THIS FILE TO YOUR SITE "/CUSTOMCF/" AND ACCESS THE PAGE DIRECTLY THROUGH THE BROWSER --->

<!--- STANDARD CS CCAPI --->
<cfoutput><p>== STANDARD CS CCAPI ==</p></cfoutput>

<cftry>
	<!--- // Set your access variables  --->
	<cfset variables.userid = "webmaster">
	<cfset variables.password = "password">
	<cfset variables.webserviceURL = "http://#Request.CGIVars.HTTP_HOST#/commonspot/webservice/cs_service.cfc?wsdl">
	<cfset variables.site = "#request.site.url#">
	
	<cfscript>
		// create object for the webService call
		ws = createObject("webservice", webserviceURL);
	
		// call the login API
		foo = ws.csLogin(site = site,
						 csUserID = userID,
						 csPassword = password,
						 subSiteID = '1',
						 subSiteURL = '');
	</cfscript>	
	
	<!--- // determine whether or not we logged in successfully --->
	<cfif ListFirst(foo, ":") is "Error">
		<cfoutput><p>Login Failed</p></cfoutput>
		<!--- //Output the results --->
		<cfdump var="#foo#">
		<cfthrow detail="Login Failed">
	</cfif>
	<!--- // set the ssid token to be used in the remainder of the API calls --->
	<cfset ssid = ListRest(foo, ":")>
	<cfoutput><p>Login -- #ssid#</p></cfoutput>
	
	<!--- // invoke the logout API call --->
	<cfscript>
		foo = ws.cslogout(ssid = "#ssid#");
	</cfscript>
	<CFOUTPUT><p>Logout -- #foo#</p></CFOUTPUT>

	<cfcatch>
		<cfoutput><p>STANDARD CS CCAPI ERROR</p></cfoutput>
		<cfdump var="#cfcatch#" label="STANDARD CS CCAPI ERROR" expand="false">
	</cfcatch>
</cftry>

<!--- ADF CCAPI --->
<cfoutput><br /><p>== ADF CCAPI ==</p></cfoutput>
<cftry>
	<!--- Create the CCAPI from the ADF and Login --->
	<cfscript>
		ccapiObj = server.ADF.objectFactory.getBean("ccapi_1_0");
		ccapiObj.initCCAPI();
		ccapitLoginRet = ccapiObj.login(1);
		ccapiSSID = ccapiObj.getSSID();
	</cfscript>
	<cfoutput><p>Login -- #ccapiSSID#</p></cfoutput>
	
	<!--- // Logout --->
	<cfset ccapitLogoutRet = ccapiObj.logout()>
	<cfoutput><p>Logout -- #ccapitLogoutRet#</p></cfoutput>
	
	<cfcatch>
		<cfoutput><p>ADF CCAPI ERROR</p></cfoutput>
		<cfdump var="#cfcatch#" label="ADF CCAPI ERROR" expand="false">
	</cfcatch>
</cftry>