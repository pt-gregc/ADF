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
	api.cfc
Summary:
	API functions for the ADF Library
Version:
	1.0
History:
	2012-12-20 - MFC - Created
	2014-03-05 - JTP - Var declarations
--->
<cfcomponent displayname="api" extends="ADF.core.Base" hint="CCAPI functions for the ADF Library">

<cfproperty name="version" value="1_0_9">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_2">
<cfproperty name="wikiTitle" value="API">

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="init">
	<cfscript>
		super.init();
		
		// Init the session variables
		initSession();
		
		this.loginComponent = server.CommonSpot.api.getObject('Login');
		
		// Init the API Config Settings
		initAPIConfig();
		
		return this;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="initSession" access="private">
	<cfscript>
		// Check if the session space does NOT exist, then setup the variables
		
		if ( NOT StructKeyExists(session.ADF,"API") ) 
		{
			session.ADF.API = StructNew();
			// Init the API Config Settings
			initAPIConfig();
		}

		// - Init the session variables if they don't exist
		if ( NOT StructKeyExists(session.ADF.API, "token") )	
			session.ADF.API.token = "";
			
		if ( NOT StructKeyExists(session.ADF.API, "siteURL") )	
			session.ADF.API.siteURL = "";
			
		if ( NOT StructKeyExists(session.ADF.API, "subsiteID") )	
			session.ADF.API.subsiteID = 1;
			
		if ( NOT StructKeyExists(session.ADF.API, "remote") )	
			session.ADF.API.remote = false;	
				
		if ( NOT StructKeyExists(session.ADF.API, "csSession") )
			session.ADF.API.csSession = StructNew();

		if ( NOT StructKeyExists(session.ADF.API.csSession, "cfID") )	
			session.ADF.API.csSession.cfID = "";
			
		if ( NOT StructKeyExists(session.ADF.API.csSession, "cfToken") )		
			session.ADF.API.csSession.cfToken = "";
			
		if ( NOT StructKeyExists(session.ADF.API.csSession, "jSessionID") )
			session.ADF.API.csSession.jSessionID = "";
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="initAPIConfig" access="public">
	<cfscript>
		// Get the user account from the CCAPI Config
		var apiConfig = getAPIConfig();
		
		// Set the setSiteURL
		if ( isStruct(apiConfig) AND StructKeyExists(apiConfig, "wsVars") ) 
		{
			setSiteURL(apiConfig.wsVars.siteURL);
			setSubsiteID(apiConfig.wsVars.subsiteID);
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="login" access="public" output="true">
	<cfargument name="remote" type="boolean" required="false" default="false">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="0">
	<cfargument name="forceUsername" type="string" required="false" default="" hint="Field to override the CCAPI username used to login to the conduit page.">
	<cfargument name="forcePassword" type="string" required="false" default="" hint="Field to override the password used to login to the conduit page.">
	
	<cfscript>
		// Get the user account from the CCAPI Config
		var apiConfig = getAPIConfig();
		var loginCmd = StructNew();
		//var command = StructNew();
		var command = '';
		var retDataCmd = "";
		var userName = "";
		var password = "";
		
		if ( LEN(TRIM(arguments.forceUsername)) )
			userName = arguments.forceUsername;
		else
			userName = apiConfig.wsVars.csuserid;
		
		if ( LEN(TRIM(arguments.forcePassword))  )
			password = arguments.forcePassword;
		else
			password = apiConfig.wsVars.cspassword;
	</cfscript>
	
	<cftry>
		<cfscript>
			// Setup the Session space
			initSession();
			
			// Clear the CS Session
			session.ADF.API.csSession = StructNew();
			session.ADF.API.csSession.cfID = "";
			session.ADF.API.csSession.cfToken = "";
			session.ADF.API.csSession.jSessionID = "";
			
			// Validate the config has the fields we need
			/* if( isStruct(apiConfig) 
				AND structKeyExists(apiConfig, "wsVars")
				AND structKeyExists(apiConfig.wsVars, "csuserid")
				AND structKeyExists(apiConfig.wsVars, "cspassword")
				AND structKeyExists(apiConfig.wsVars, "siteURL")
				AND structKeyExists(apiConfig.wsVars, "subsiteID") ) { 
			 */
				
				// Set the setSiteURL
				setSiteURL(apiConfig.wsVars.siteURL);
				
				// Set the subsiteID
				// Check if we want to force login to a specific subsite
				if ( arguments.forceSubsiteID GT 0 )
					setSubsiteID(arguments.forceSubsiteID);
				else
					setSubsiteID(apiConfig.wsVars.subsiteID);
				
				// If forcing remote calls, then set the remote flag
				if ( arguments.remote )
					setRemoteflag(arguments.remote);
				
				// Check if we want to remote login
				if ( getRemoteFlag() )
				{
					 
					command = StructNew();
					command['Target'] = "Login";
					command['Method'] = "doLogin";
					
					command['Args'] = StructNew();
					command['Args']['userName'] = userName;
					command['Args']['password'] = password;
						
					/*
					command = '
						<Command>
							<Target>Login</Target>
							<Method>doLogin</Method>
							<Args>
								<userName>#userName#</userName>
								<password>#password#</password>
							</Args>
						</Command>
						';
					 */
					 
					// Run command and return Array
					retDataCmd = runRemote(commandStruct=command, authCommand=false);
					
					// Validate the return array and set the login data return
					if ( isArray(retDataCmd)
						 AND ArrayLen(retDataCmd) 
						 AND StructKeyExists(retDataCmd[1], "data") )
						loginCmd = retDataCmd[1].data;
				}
				else 
				{
					// Login via ColdFusion
					loginCmd = this.loginComponent.doLogin(userName=userName,
														   password=password);
				}

				if ( isStruct(loginCmd)
						AND StructKeyExists(loginCmd, "LoginResult") EQ 1
						AND StructKeyExists(loginCmd, "SessionCookies")
						AND StructKeyExists(loginCmd.SessionCookies, "cfID")
						AND StructKeyExists(loginCmd.SessionCookies, "cfToken") )
				{
					// Login Success
					session.ADF.API.csSession = loginCmd.SessionCookies;
					setAPIToken();
					
					if( apiConfig.logging.enabled )
						variables.utils.logAppend("#request.formattedTimestamp# - Success logging in to API. [LoginResult:#loginCmd.LoginResult#] [Token:#getAPIToken()#] [SubSiteID:#getSubsiteID()#]", "API_Login.log");
					
				}
				else if ( isStruct(loginCmd) AND StructKeyExists(loginCmd, "LoginResult") EQ 2 )
				{
					// Need Password Change
					clearAPIToken();
					if( apiConfig.logging.enabled )
						variables.utils.logAppend("#request.formattedTimestamp# - Error logging in to API. Password needs to be changed. [LoginResult:#loginCmd.LoginResult#]", "API_Login.log");
				}
				else if ( isStruct(loginCmd) AND StructKeyExists(loginCmd, "LoginResult") EQ 0 )
				{
					// Login Failed
					clearAPIToken();
					if( apiConfig.logging.enabled )
						variables.utils.logAppend("#request.formattedTimestamp# - Error logging in to API. Login Failed. [LoginResult:#loginCmd.LoginResult#]", "API_Login.log");
				}
				else 
				{
					// Error with Login
					clearAPIToken();
					if( apiConfig.logging.enabled )
						variables.utils.logAppend("#request.formattedTimestamp# - Error logging in to API.", "API_Login.log");
				}
		</cfscript>
		<cfcatch>
			<!--- // TODO:  fix this. Generate a better error to be displayed on the page --->
			<!--- <cfdump var="#cfcatch#" label="cfcatch" expand="false"> --->
			
			<cfoutput>
				<div>#cfcatch.Message#</div> 
				<!--- <div>#cfcatch.details#</div> ---> 
			</cfoutput>
			
			<cfif apiConfig.logging.enabled>
				<cfset variables.utils.logAppend("#cfcatch#", "API_Login_Error.html")>
			</cfif>
			
			<!--- <cfscript>
				// Error - Clear the CS Session
				session.ADF.API.csSession = StructNew();
				session.ADF.API.csSession.cfID = "";
				session.ADF.API.csSession.cfToken = "";
				session.ADF.API.csSession.jSessionID = "";
			</cfscript> --->
		</cfcatch>
	</cftry>
	<cfreturn this>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2013-10-25 - GAC - Updated to check login status local or remote
--->
<cffunction name="isLoggedIn" access="public">
	<cfscript>
		//var command = StructNew();
		var command = '';
		var retDataCmd = "";
		var loginStatus = false;
		
		// Setup the Session space
		initSession();
		
		// Check if the session token is defined
		if ( LEN(getAPIToken()) ) 
		{
		
			if ( getRemoteFlag() )
			{
				// Login via ColdFusion
				command = StructNew();
				command['Target'] = "Login";
				command['Method'] = "isLoggedIn";
				/* 
				command = '
						<Command>
					      <Target>Login</Target>
					      <Method>isLoggedIn</Method>
					   </Command>
				   ';
				 */
				// Run command and return Array
				retDataCmd = runRemote(commandStruct=command, authCommand=false);
				//application.ADF.utils.dodump(retDataCmd,"retDataCmd - isLoggedIn", false);
				
				// Validate the return array and set the login data return
				if ( isArray(retDataCmd)
					 AND ArrayLen(retDataCmd) 
					 AND StructKeyExists(retDataCmd[1], "data") )
					loginStatus = retDataCmd[1].data;

			}
			else 
			{
				// Login via ColdFusion
				loginStatus = this.loginComponent.isLoggedIn();	
			}
		}
		
		return loginStatus;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2013-10-25 - GAC - Updated to return a logout status
				  	  - Updated to logout local or remote 
--->
<cffunction name="logout" access="public">
	<cfscript>
		// Get the user account from the CCAPI Config
		var apiConfig = getAPIConfig();
		var command = '';
		var retDataCmd = "";
		var logoutMsg = "Success:1";
		var logoutStatus = true;
		
		try 
		{
			// Setup the Session space
			initSession();
			
			if ( getRemoteFlag() ){
				// Login via ColdFusion
				command = StructNew();
				command['Target'] = "Login";
				command['Method'] = "doLogout";
				/* 
				command = '
					<Command>
						<Target>Users</Target>
						<Method>doLogout</Method>
					</Command>';
				 */ 
				
				// Run command and return Array
				retDataCmd = runRemote(commandStruct=command, authCommand=false);
			}	
			else 
			{
				// logout via ColdFusion
				this.loginComponent.doLogout();	// Returns VOID
			}
			
			// Clear the session variables
			session.ADF.API.csSession = StructNew();
			session.ADF.API.csSession.cfID = "";
			session.ADF.API.csSession.cfToken = "";
			session.ADF.API.csSession.jSessionID = "";
			clearAPIToken();
			
		}
		catch (any e) 
		{
			logoutMsg = "Error:" & e.message;
			logoutStatus = false;
		}
		
		if( apiConfig.logging.enabled ) 
		{
			if ( logoutStatus )
				variables.utils.logAppend("#request.formattedTimestamp# - API Logout Success.", "API_Login.log");
			else			
				variables.utils.logAppend("#request.formattedTimestamp# - API Logout Failed. #e.message#", "API_Login.log");
		}
		
		return logoutMsg;
	</cfscript>	
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="runRemote" access="public" returntype="any" output="true" hint="Runs the Command API locally via HTML/XML.">
	<cfargument name="commandStruct" type="struct" required="false" hint="Command collection as Structure.">
	<cfargument name="commandArgsXML" type="String" required="false" hint="Command collection as XML.">
	<cfargument name="authCommand" type="boolean" required="false" default="true" hint="Run the command as the Authenticated user. Will force the login process.">
	<cfscript>
		var commandXML = "";
		var command_collection = '';
		var CFID = "";
		var CFToken = "";
		var httpSubsiteURL = "";
		
		// Setup the Session space
		initSession();
		
		httpSubsiteURL = buildSubsiteFullURL(session.ADF.API.subsiteID);
		
		// Psuedo overloading the arguments
		// Check if the commands collection is a structure
		if ( isStruct(arguments.commandStruct)
				AND StructCount(arguments.commandStruct) GT 0 )
		{
			commandXML = server.CommonSpot.UDF.Util.serializeBean(commandStruct);
			// Trim off the surrounding "<struct></struct>" tags
			commandXML = MID(commandXML,9,LEN(commandXML)-17);
		}
		else if ( LEN(arguments.commandArgsXML) )
		{
			commandXML = arguments.commandArgsXML;
		}
		
		// Validate if the XML starts with "COMMAND"
		if ( MID(server.commonspot.UDF.HTML.escape(TRIM(commandXML)),5, 7) NEQ "Command" ) 
			commandXML = '<Command>' & commandXML & '</Command>';
		
		command_collection = '<CommandCollection class="array">' & #commandXML# & '</CommandCollection>';
		//application.ADF.utils.dodump(command_collection,"command_collection",false);
	
		// Check if session is logged in
		if ( arguments.authCommand AND NOT isLoggedIn() )
			login();
		//application.ADF.utils.dodump(session.ADF.API,"session.ADF.API - runRemote",false);
		
		// Check if the command requires authentication
		//	AND we are logged in.
		if ( arguments.authCommand AND NOT LEN(session.ADF.API.token)  )
			return "";
	</cfscript>
	
	<cftry>
		<!--- Check that we have a valid API Token --->
		<cfhttp url="#httpSubsiteURL#loader.cfm" method="POST">
			<cfhttpparam type="FORMFIELD" name="csModule" value="components/dashboard/dashboard" />
			<cfhttpparam type="FORMFIELD" name="cmdCollectionXML" value="#command_collection#" />
			<cfhttpparam type="COOKIE" name="JSESSIONID" value="#session.ADF.API.csSession.jSessionID#" />
			<cfhttpparam type="COOKIE" name="CFID" value="#session.ADF.API.csSession.CFID#" />
			<cfhttpparam type="COOKIE" name="CFTOKEN" value="#session.ADF.API.csSession.CFToken#" />
		</cfhttp>
		<!--- <cfsavecontent variable="temp">
			<cfoutput>#command_collection#</cfoutput>
		</cfsavecontent>
		<cfdump var="#temp#" label="temp" expand="false"> --->
		<!--- Deserialize the return XML to struct --->
		<cfscript>
			//application.ADF.utils.dodump(cfhttp,"cfhttp - runRemote",false);
			if ( isXML(cfhttp.fileContent) )
				return server.Commonspot.UDF.util.deserialize(cfhttp.fileContent);
		</cfscript>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
			<!--- <cfdump var="#httpSubsiteURL#" label="httpSubsiteURL" expand="false"> --->
		</cfcatch>
	</cftry>
	
	<cfreturn "">
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2014-05-01 - GAC - Fixed typo in the try/catch around the populateCustomElement call, switched (e ANY) to (ANY e)
	2014-09-10 - GAC - Updated to fix bogus status=true results from the populateCustomElement() call.
--->
<cffunction name="runCCAPI" access="public" returntype="any" output="true" hint="Runs the Content Creation API.">
	<cfargument name="method" type="String" required="true">
	<cfargument name="sparams" type="Struct" required="true">
	<cfargument name="forceUsername" type="string" required="false" default="" hint="Field to override the CCAPI username used to login to the conduit page.">
	<cfargument name="forcePassword" type="string" required="false" default="" hint="Field to override the password used to login to the conduit page.">
	
	<cfscript>
		var wsObj = "";
		var result = StructNew();
		
		// Init the return data structure
		result.status = false;
		result.msg = "";
		result.data = StructNew();
		
		// Setup the Session space
		initSession();
		
		// Set the flag to make all CCAPI commands as remote
		//setRemoteFlag(true);
		
		
		// Check if we are not logged OR not logged into the correct subsite
		if ( NOT isLoggedIn() OR (getSubsiteID() NEQ sparams.subsiteID) ) 
		{
			// Login with the Public API
			//login(remote=true, forceSubsiteID=sparams.subsiteID);
			//login(forceSubsiteID=sparams.subsiteID);
			
			// Login through the CCAPI
			if ( LEN(TRIM(arguments.forceUsername)) AND LEN(TRIM(arguments.forcePassword))  )
			{
				ccapiLogin(forceUsername=arguments.forceUsername,forcePassword=arguments.forcePassword,forceSubsiteID=sparams.subsiteID);
			}
			else
			{	
				//setSubsiteID(sparams.subsiteID);
				ccapiLogin(forceSubsiteID=sparams.subsiteID);
			}
		}
		
		wsObj = getWebService();
		
		// If the web service is setup and the login token is valid
		if ( LEN(getAPIToken()) ) 
		{
			try 
			{
				switch (arguments.method)
				{
					// Populate Custom Element Record
					case "populateCustomElement":
						
						result.data = wsObj.populateCustomElement(ssid=getAPIToken(), sparams=arguments.sparams);						
//application.ADF.utils.dodump(result,"result",false);
						
						if ( IsSimpleValue(result.data) AND FindNoCase("success",result.data) )
							result.status = true;					
//application.ADF.utils.dodump(result,"result",false);

						break;
					// Populate a Text Block
					case "populateTextBlock":
						break;
				}
			}
			catch (ANY e)
			{
				// Error caught, send back the error message
				result.status = false;
				result.msg = e.message;
				result.data = e;
			}
		}
		else 
		{
			result.status = false;
			result.msg = "Error loading the Web Service.";
		}
		
		return result;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="runLocal" access="public" returntype="any" output="true" hint="Runs the Command API locally via ColdFusion.">
</cffunction>

<!--- // CCAPI FUNCTIONS --->

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2014-09-15 - GAC - Updated to add forceSubsiteID, forceUsername and forcePassword parameters
--->
<cffunction name="ccapiLogin" access="public" returntype="void" output="true">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="0">
	<cfargument name="forceUsername" type="string" required="false" default="" hint="Field to override the CCAPI username used to login to the conduit page.">
	<cfargument name="forcePassword" type="string" required="false" default="" hint="Field to override the password used to login to the conduit page.">
	
	<cfscript>
		// Get the user account from the CCAPI Config
		var apiConfig = getAPIConfig();
		var wsObj = getWebService();
		var error = '';
		var loginResult = '';
		var userName = '';
		var password = '';
		
		if ( LEN(TRIM(arguments.forceUsername)) )
			userName = arguments.forceUsername;
		else
			userName = apiConfig.wsVars.csuserid;
		
		if ( LEN(TRIM(arguments.forcePassword))  )
			password = arguments.forcePassword;
		else
			password = apiConfig.wsVars.cspassword;
			
		// Check if we want to force login to a specific subsite
		if ( arguments.forceSubsiteID GT 0 )
			setSubsiteID(arguments.forceSubsiteID);
		else
			setSubsiteID(apiConfig.wsVars.subsiteID);
		
		loginResult = wsObj.csLogin(site = getSiteURL(),
										csUserID = userName,
										csPassword = password,
										subSiteID = getSubsiteID(),
										subSiteURL = '');
										
//application.ADF.utils.doDUMP(loginResult,"loginResult",1);										
		
		// Verify that the login was successful and set the Token
		if ( ListFirst(loginResult, ":") is "Success" )
		{
			// Process the SSID
			processSSID(ssid=ListRest(loginResult, ":"));
			
//application.ADF.utils.doDUMP(session.ADF.api,"session.ADF.api",1);

			// Log Success
			if( apiConfig.logging.enabled )
				variables.utils.logAppend("#request.formattedTimestamp# - Success logging in to CCAPI. [Token:#getAPIToken()#], [SubSiteID:#getSubsiteID()#]", "API_Login.log");
		}
		else 
		{
			// Clear the Token
			clearAPIToken();
			error = ListRest(loginResult, ":");
			// Log Error
			if( apiConfig.logging.enabled )
				variables.utils.logAppend("#request.formattedTimestamp# - Error logging in to CCAPI: #error#", "API_Login.log");
		}
	</cfscript>
</cffunction>

<!--- 
/* *************************************************************** */
History:
	2012-12-26 - MFC - Created
	2014-04-10 - GAC - Fixed variable name in log output
--->
<cffunction name="ccapiLogout" access="public" returntype="void">
	<cfscript>
		// Get the user account from the CCAPI Config
		var apiConfig = getAPIConfig();
		var wsObj = getWebService();
		
		var logoutResult = wsObj.csLogout(ssid=getAPIToken());
		
		// Verify that the login was successful and set the Token
		if ( ListFirst(logoutResult, ":") is "Success" )
		{
			// Clear the API token
			clearAPIToken();
			// Log Success
			if ( apiConfig.logging.enabled )
				variables.utils.logAppend("#request.formattedTimestamp# - CCAPI Logout Success.", "API_Login.log");
		}
		else 
		{
			// Log Error
			if ( apiConfig.logging.enabled )
				variables.utils.logAppend("#request.formattedTimestamp# - Error Logout with the CCAPI: #logoutResult#", "API_Login.log");
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="processSSID" access="private" returnType="void" output="no" hint="Splits the specified SSID And returnt a struct of information stored in SSID.">
	<cfargument name="ssid" type="string" required="yes">

	<cfscript>
		var result = StructNew();
		var cookieInfo = ArrayNew(1);

		if ( Len(arguments.ssid) GT 0 ) 
		{
			session.ADF.API.csSession.CFID = ListFirst(arguments.ssid, " ");
			if ( ListLen(arguments.ssid, " ") GTE 2 )
				session.ADF.API.csSession.CFToken = ListGetAt(arguments.ssid, 2, " ");
			else
				session.ADF.API.csSession.CFToken = 0;
			
			if ( ListLen(arguments.ssid, " ") GT 3 )
				session.ADF.API.csSession.JSessionID = ListGetAt(arguments.ssid, 3, " ");
		}
		setSiteURL(ListLast(arguments.ssid, " "));
		setAPIToken();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$buildSubsiteFullURL
Summary:
	Returns the Full URL for the subsite (http://...)
Returns:
	string
Arguments:
	numeric
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="buildSubsiteFullURL" access="private" returntype="string" output="true" hint="Returns the Full URL for the subsite (http://...)">
	<cfargument name="subsiteID" type="numeric" required="true" hint="subsiteID to build the full URL from">
	<cfscript>
		var httpSubsiteURL = getSiteURL();
		var subsiteData = application.ADF.csData.getSubsiteQueryByID(subsiteID=getSubsiteID());

		// Remove the root subsite from the path
		httpSubsiteURL = Replace(httpSubsiteURL, request.site.CP_URL, "");
		
		// Add the subsite path to the string
		httpSubsiteURL = httpSubsiteURL & subsiteData.SubSiteURL;
		
		return httpSubsiteURL;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getWebService
Summary:
	Returns the Web Service object based on if running local or remote commands.	
Returns:
	any
Arguments:
	Void
History:
	2012-12-26 - MFC - Created
	2013-10-15 - GAC - Updated to handle the cs_remote for 7.0.1+, 8.0.1+ and 9+
--->
<cffunction name="getWebService" access="private" returntype="any">
	<cfscript>
		var apiConfig = getAPIConfig();
		var wsURL = "";
		var wsPath = "commonspot.webservice.cs_service";
		
		// Set the wsURL from the apiConfig
		if( isStruct(apiConfig) AND structKeyExists(apiConfig, "wsVars") AND structKeyExists(apiConfig.wsVars,"webserviceURL") AND LEN(apiConfig.wsVars.webserviceURL) ) 
			wsURL = apiConfig.wsVars.webserviceURL;

		if ( getRemoteFlag() AND LEN(TRIM(wsURL)) ) 
		{
			// Call the remote Web Service
			return createObject("webService", wsURL);
		}
		else 
		{	
		
			// Use the config webservice URL value to determine the correct wsPath
			if ( FindNoCase(wsURL,"cs_remote") )
				wsPath = "commonspot.webservice.cs_remote";	
		
			// Create the local object directly on the server
			return createObject("component", wsPath);				
		}
	</cfscript>
</cffunction>


<!--- // Private GETTERS/SETTERS --->

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2013-10-25 - GAC - can NOT be private since we are being injected in to ccapi_2_0
--->
<cffunction name="setSubsiteID" access="public" returntype="void" hint="Set the subsiteID"> 
	<cfargument name="subsiteID" type="numeric" required="true" hint="subsiteID to set">
	<cfset session.ADF.API.subsiteID = arguments.subsiteID>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2013-10-25 - GAC - can NOT be private since we are being injected in to ccapi_2_0
--->
<cffunction name="getSubsiteID" access="public" returntype="numeric" hint="Get the subsiteID">
	<cfreturn session.ADF.API.subsiteID>
</cffunction>

<cffunction name="setSiteURL" access="private" returntype="void" hint="Set the Site URL for Remote Commands.">
	<cfargument name="siteURL" type="string" required="true" hint="Site URL to set">
	<cfscript>
		// Check the length to see is defined
		if ( LEN(arguments.siteURL) )
		{
			session.ADF.API.siteURL = arguments.siteURL;
			//	Set the remote status
			//setRemoteFlag(true);
		}
		else 
		{
			// If the config site URL is not undefined, then make commands against the current site URL
			session.ADF.API.siteURL = request.site.url;
			//	Set the remote status
			//setRemoteFlag(false);
		}
		
		// Check if ends in "/"
		if ( RIGHT(session.ADF.API.siteURL, 1) NEQ "/" )
			session.ADF.API.siteURL = session.ADF.API.siteURL & "/";
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="getSiteURL" access="private" returntype="string" hint="Get the Site URL for Remote Commands.">
	<cfreturn session.ADF.API.siteURL>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="setAPIToken" access="private" returntype="void" hint="set the ccapi token">
	<cfscript>
		session.ADF.API.token = session.ADF.API.csSession.cfID & " " & session.ADF.API.csSession.cfToken;
		if ( LEN(session.ADF.API.csSession.JSessionID) )
			session.ADF.API.token = session.ADF.API.token & " " & session.ADF.API.csSession.JSessionID;
		session.ADF.API.token = session.ADF.API.token & " " & getSiteURL();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="clearAPIToken" access="private" returntype="void">
	<cfset session.ADF.API.token = "">
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
	2013-10-25 - GAC - Set to public to be able to access the current users login token
--->
<cffunction name="getAPIToken" access="public" returntype="string" hint="get the ccapi token">
	<cfreturn session.ADF.API.token>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="setRemoteFlag" access="private" returntype="void" hint="Set the Remote Flag">
	<cfargument name="remoteFlag" type="boolean" required="true">
	<cfset session.ADF.API.remote = arguments.remoteFlag>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="getRemoteFlag" access="private" returntype="boolean" hint="Get the Remote Flag">
	<cfreturn session.ADF.API.remote>
</cffunction>

<!---
/* *************************************************************** */
History:
	2012-12-20 - MFC - Created
--->
<cffunction name="getAPIConfig" access="public" returntype="struct">
	<cfscript>
		var tempStruct = structNew();
		// Build a init struct keys to pass back
		tempStruct.logging = StructNew();
		tempStruct.logging.enabled = false;
		tempStruct.elements = StructNew();
		tempStruct.wsVars = StructNew();
		tempStruct.wsVars.webserviceURL = "";
		tempStruct.wsVars.csuserid = "";
		tempStruct.wsVars.cspassword = "";
		tempStruct.wsVars.site = "";
		tempStruct.wsVars.siteURL = "";
		tempStruct.wsVars.subsiteID = 1;
		tempStruct.wsVars.cssites = "";
		
		if ( NOT StructKeyExists(server.ADF.environment, request.site.id) ) 
		{
			//return tempStruct;
			server.ADF.environment[request.site.id] = StructNew();
			StructInsert(server.ADF.environment[request.site.id], "apiConfig", tempStruct);
		}
		// Build the temporary config if nothing is defined at the site config level
		else if ( NOT StructKeyExists(server.ADF.environment[request.site.id], "apiConfig") ) 
		{
			// Insert into the Site Config
			StructInsert(server.ADF.environment[request.site.id], "apiConfig", tempStruct, true);
		}
		
		return server.ADF.environment[request.site.id].apiConfig;
	</cfscript>
</cffunction>

</cfcomponent>