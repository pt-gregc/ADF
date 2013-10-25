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
	2013-10-24 - GAC - Updated to handle ADF CCAPI_1_0, ADF CCAPI_2_0 and ADF API_1_0 testing
--->

<!--- // Use this file to test to see if the CommonSpot is allowing a user to login to the CCAPI web service --->
<!--- // COPY THIS FILE TO YOUR SITE "/CUSTOMCF/" AND ACCESS THE PAGE DIRECTLY THROUGH THE BROWSER --->

<cfif NOT structKeyExists(request.cp,"ccapiAccessDir")>
	<cfif find("commonspotcloud.com",request.site.url)>
		<cfoutput>This appears to be a CommonSpot Cloud server, but the line in the servervars.cfm for enabling the CCAPI is currently commented out. Edit the servervars.cfm file in /cust/keys/cs/ and uncomment "ServerInfo.ccapiAccessDir", it should be the last line in the file. Restart #server.coldfusion.productname# once you are finished.</cfoutput>
		<cfexit>
	<cfelse>
		<!--- This is probably an on-premise installation and they shouldn't have request.cp.ccapiAccessDir defined anyway. --->
	</cfif>
</cfif>

<cfscript>
// !!! START- UPDATE THESE VALUES FOR THE SPECIFIC CCAPI TEST TO RUN !!! 
		
verboseOutput = false;
remoteRequests = false;
serviceLegacyMode = true;
enableADFCCAPIv1 = true;
enableADFCCAPIv2 = true;
enableADFAPIv1 = true;
		
// !!! END- UPDATE THESE VALUES FOR THE SPECIFIC CCAPI TEST TO RUN  !!! 

		ccapiConfig = StructNew();
		
// !!! START- UPDATE THESE VALUES FOR YOUR SERVER !!! 

ccapiConfig.userid = "webmaster";
ccapiConfig.password = "password";

// !!! END - UPDATE THESE VALUES FOR YOUR SERVER !!! 
		
		ccapiConfig.site = "#request.site.url#"; 
		ccapiConfig.subsiteID = 1;
		
		// FORCE LEGACY SERVICE MODE FOR SITE LESS THAN OR EQUAL TO VERSION 6.x
		if ( ListFirst(ListLast(request.cp.productversion," "),".") LTE 6 )
		 	serviceLegacyMode = true;
		
		if ( serviceLegacyMode ) {
			// FOR CS 7.0 and  8.0 use cs_service.cfc
			ccapiConfig.webserviceURL = "http://#Request.CGIVars.SERVER_NAME#:#Request.CGIVars.SERVER_PORT#/commonspot/webservice/cs_service.cfc?wsdl";
			ccapiConfig.localServicePath = "commonspot.webservice.cs_service";
		}
		else {
			// FOR CS 7.0.1, 8.0.1 and 9+ use cs_remote.cfc
			ccapiConfig.webserviceURL = "http://#Request.CGIVars.SERVER_NAME#:#Request.CGIVars.SERVER_PORT#/commonspot/webservice/cs_remote.cfc?wsdl";
			ccapiConfig.localServicePath = "commonspot.webservice.cs_remote";
		}
		
		// Check for URL varaibles
		doCCAPIdump = false;
		if ( StructKeyExists(request.params,"ccapiDump") AND IsBoolean(request.params.ccapiDump) )
			doCCAPIdump = request.params.ccapiDump;
</cfscript>

<cfoutput><h2>Site: #ccapiConfig.site#</h2></cfoutput>
<cfoutput>
<p>
	Service Component: <strong><cfif serviceLegacyMode> cs_service (legacy ccapi)<cfelse> cs_remote</cfif></strong><br/>
	Service Requests: <strong><cfif remoteRequests> Remote<cfelse> Local </cfif></strong><br/>
	Verbose Output: <strong>#UCASE(verboseOutput)#</strong><br/>
	<br/>
	<a href="?ccapiDump=1">Click to RUN the CCAPI Dump</a>
</p>
</cfoutput>

<!--- STANDARD CS CCAPI --->
<cfoutput><p><strong>== STANDARD CS CCAPI ==</strong></p></cfoutput>

<cfoutput><div>Standard CCAPI config settings<div></cfoutput>
<cfdump var="#ccapiConfig#" label="ccapiConfig" expand="false">

<cfif doCCAPIdump>
	<cftry>
		<!--- // create ccapi object --->
		<cfscript>
			if ( remoteRequests ) {
				// create object for the remote webService call
				ccapiObj = createObject("webservice", ccapiConfig.webserviceURL);
			}
			else {
				// create object for the LOCAL webservice call
				ccapiObj = createObject("component", ccapiConfig.localServicePath); 		
			}
	
			// call the login API
			foo = ccapiObj.csLogin(
								site = ccapiConfig.site,
								csUserID = ccapiConfig.userID,
								csPassword = ccapiConfig.password,
								subSiteID = ccapiConfig.subsiteID,
								subSiteURL = ''
							);
		</cfscript>
		
		<cfif verboseOutput>
			<cfoutput><div>CCAPI Object<div></cfoutput>
			<cfdump var="#ccapiObj#" label="" expand="false">
			<!---<cfexit>--->
		</cfif>
		
		<!--- // determine whether or not we logged in successfully --->
		<cfif ListFirst(foo, ":") is "Error">
			<cfoutput><p>Login Failed</p></cfoutput>
			<!--- //Output the results --->
			<cfdump var="#foo#" label="foo">
			<cfexit>
		</cfif>
	
		<!--- // set the ssid token to be used in the remainder of the API calls --->
		<cfset ssid = ListRest(foo, ":")>
		<cfoutput><p>Login -- #ssid# (#foo#)</p></cfoutput>
	
		<cfscript>
			// call the login API
			foo = ccapiObj.cslogout(ssid);
		</cfscript>
	
		<CFOUTPUT><p>Logout -- #foo#</p></CFOUTPUT>
	
		<cfcatch>
			<cfoutput><p>STANDARD CS CCAPI ERROR</p></cfoutput>
			<cfdump var="#cfcatch#" label="STANDARD CS CCAPI ERROR" expand="false">
		</cfcatch>
	
	</cftry>
<cfelse>
	<p>Click the link above to run.</p>
</cfif>

<!--- // ADF CCAPI --->
<cfif enableADFCCAPIv1>
	<cfoutput><br /><p><strong>== ADF CCAPI 1.0 ==</strong></p></cfoutput>
	<cfif doCCAPIdump>
		<cftry>
			<!--- Create the CCAPI from the ADF and Login --->
			<cfscript>
				ccapiObj1 = server.ADF.objectFactory.getBean("ccapi_1_0");
				ccapiObj1.initCCAPI();
				ccapiLoginRet1 = ccapiObj1.login(1);
				ccapiSSID1 = ccapiObj1.getSSID();
			</cfscript>
			<cfoutput><p>Login -- #ccapiSSID1#</p></cfoutput>
		
			<!--- // Logout --->
			<cfset ccapiLogoutRet1 = ccapiObj1.logout()>
			<cfoutput><p>Logout -- #ccapiLogoutRet1#</p></cfoutput>
		
			<cfcatch>
				<cfoutput><p>ADF CCAPI 1.0 ERROR</p></cfoutput>
				<cfdump var="#cfcatch#" label="ADF CCAPI 1.0 ERROR" expand="false">
			</cfcatch>
		</cftry>
	<cfelse>
		<p>Click the link above to run.</p>
	</cfif>
</cfif>

<cfif enableADFCCAPIv2>
	<cfoutput>
	<br />
	<p>
		<strong>== ADF CCAPI 2.0 ==</strong><br />
		(If you are logged in to CommonSpot this test will log you out.)
	</p>
	</cfoutput>
	<cfif doCCAPIdump>
		<cftry>
			<!--- Create the CCAPI from the ADF and Login --->
			<cfscript>
				ccapiObj2 = server.ADF.objectFactory.getBean("ccapi_2_0");
				ccapiObj2.initCCAPI();
				ccapiLoginRet2 = ccapiObj2.login(1);
				ccapiSSID2 = ccapiObj2.getSSID();
			</cfscript>
			<cfoutput><p>Login -- #ccapiSSID2#</p></cfoutput>
		
			<!--- // Logout --->
			<cfset ccapiLogoutRet2 = ccapiObj2.logout()>
			<cfoutput><p>Logout -- #ccapiLogoutRet2#</p></cfoutput>
		
			<cfcatch>
				<cfoutput><p>ADF CCAPI 2.0 ERROR</p></cfoutput>
				<cfdump var="#cfcatch#" label="ADF CCAPI 2.0 ERROR" expand="false">
			</cfcatch>
		</cftry>
	<cfelse>
		<p>Click the link above to run.</p> 
	</cfif> 
</cfif>

<cfif enableADFAPIv1>
	<cfoutput>
		<br />
		<p>
			<strong>== ADF CAMMAND API 1.0  ==</strong><br />
			(If you are logged in to CommonSpot this test will log you out.)
		</p>
	</cfoutput>
	<cfif doCCAPIdump>
		<cftry>
			<!--- Create the CCAPI from the ADF and Login --->
			<cfscript>
				apiObj = server.ADF.objectFactory.getBean("api_1_0");
				apiObj.init();
				apiLoginRet = apiObj.login(remote=remoteRequests,forceSubsiteID=0);
				apiToken = apiObj.getAPIToken();
			</cfscript>
			<cfoutput><p>Login -- #apiToken#</p></cfoutput>
		
			<!--- // Logout --->
			<cfset apiLogoutRet = apiObj.logout()>
			<cfoutput><p>Logout -- #apiLogoutRet#</p></cfoutput> 
		
			<cfcatch>
				<cfoutput><p>ADF API 1.0 ERROR</p></cfoutput>
				<cfdump var="#cfcatch#" label="ADF API ERROR" expand="false">
			</cfcatch> 
		</cftry>
	<cfelse>
		<p>Click the link above to run.</p>
	</cfif> 
</cfif>