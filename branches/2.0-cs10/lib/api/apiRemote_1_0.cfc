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
/* *************************************************************** */
Author: 	
	PaperThin, Inc. 
Name:
	apiRemote_1_0.cfc
Summary:
	CMD API Remote Request functions for the ADF Library
Version:
	1.0.0
History:
	2015-09-01 - GAC - Created
--->
<cfcomponent displayname="apiRemote_1_0" extends="ADF.lib.libraryBase" hint="CMD API Remote Request functions for the ADF Library">
	
<cfproperty name="version" value="1_0_0">
<cfproperty name="api" type="dependency" injectedBean="api_1_0">
<cfproperty name="wikiTitle" value="APIRemote_1_0">

<!---//////////////////////////////////////////////////////--->
<!---//     COMMAND API REMOTE CALL HANDLING METHODS     //--->
<!---//////////////////////////////////////////////////////--->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$runCmdApi
Summary:
	Runs the Command API remotely via HTML/XML.
Returns:
	any
Arguments:
	Struct - commandStruct
	String - commandXML 
	Boolean - authCommand
	Numeric - forceSubsiteID
	String - forceUsername
	String - forcePassword
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="runCmdApi" access="public" returntype="any" hint="Runs the Command API remotely via HTML/XML.">
	<cfargument name="commandStruct" type="struct" required="false" hint="Command collection as Structure.">
	<cfargument name="commandXML" type="String" required="false" hint="Command collection as XML.">
	<cfargument name="authCommand" type="boolean" required="false" default="true" hint="Run the command as the Authenticated user. Will force the login process.">
	<cfargument name="forceSubsiteID" type="numeric" required="false" default="-1" hint="">
	<cfargument name="forceUsername" type="string" required="false" default="" hint="Field to override the CCAPI username used to login to the conduit page.">
	<cfargument name="forcePassword" type="string" required="false" default="" hint="Field to override the password used to login to the conduit page."> 
	
	<cfscript>
		var retData = StructNew();
		var cmdResultArray = ArrayNew(1);
		var cmdResult = StructNew();
		var apiConfig = variables.api.getAPIConfig();
		var preCmdXML = "";
		var postCmdXML = "";
		var cmdXML = "";
		var bodyCmdXML = "";
		var cmdCollectionXML = "";
		var httpSubsiteURL = "";
		var preCmd = StructNew();
		var postCmd = StructNew();
		var Username = "";
		var Password = "";
		
		retData.errorMsg = "";
		
		if ( LEN(TRIM(arguments.forceUsername)) )
			userName = arguments.forceUsername;
		else if ( StructKeyExists(apiConfig,"wsVars") AND StructKeyExists(apiConfig.wsVars,"csuserid") AND LEN(TRIM(apiConfig.wsVars.csuserid)) )
			userName = apiConfig.wsVars.csuserid;
		else
			 arguments.authCommand = false;
		
		if ( LEN(TRIM(arguments.forcePassword))  )
			password = arguments.forcePassword;
		else if ( StructKeyExists(apiConfig,"wsVars") AND StructKeyExists(apiConfig.wsVars,"cspassword") AND LEN(TRIM(apiConfig.wsVars.cspassword)) )
			password = apiConfig.wsVars.cspassword;
		else
			 arguments.authCommand = false;

		if ( IsNumeric(arguments.forceSubsiteID) AND arguments.forceSubsiteID GT 0 AND LEN(TRIM(request.SubsiteCache[arguments.forceSubsiteID].url)) NEQ 0 )	
			httpSubsiteURL = buildRemoteSubsiteFullURL(subsiteID=arguments.forceSubsiteID);
		else
			httpSubsiteURL = buildRemoteSubsiteFullURL(subsiteID=1);

		if ( arguments.authCommand ) 
		{
			// Login Command
			preCmd['Target'] = "Login";
			preCmd['Method'] = "doLogin";
			preCmd['Args'] = StructNew();
			preCmd['Args']['userName'] = Username;
			preCmd['Args']['password'] = Password;
			preCmdXML = buildCommandString(preCmd);
		
			// Logout Command
			postCmd['Target'] = "Login";
			postCmd['Method'] = "doLogout";
			postCmdXML = buildCommandString(postCmd);
		}
		
		// Check if the commands collection is a structure
		if ( isStruct(arguments.commandStruct) AND StructCount(arguments.commandStruct) GT 0 )
			bodyCmdXML = buildCommandString(arguments.commandStruct);
		else 
			bodyCmdXML = arguments.commandXML;

		if ( LEN(TRIM(bodyCmdXML)) ) 
		{
			cmdXML = preCmdXML & bodyCmdXML & postCmdXML;

			cmdCollectionXML = '<CommandCollection class="array">' & cmdXML & '</CommandCollection>';
		}
	</cfscript>
	
	<cfif IsXML(cmdCollectionXML)>
		<cftry>
			<!--- Check that we have a valid API Token --->
			<cfhttp url="#httpSubsiteURL#loader.cfm" method="POST">
				<cfhttpparam type="FORMFIELD" name="csModule" value="components/dashboard/dashboard" />
				<cfhttpparam type="FORMFIELD" name="cmdCollectionXML" value="#cmdCollectionXML#" />
			</cfhttp>
			<!--- Deserialize the return XML to struct --->
			<cfscript>
				if ( isXML(cfhttp.fileContent) )
					cmdResultArray = server.Commonspot.UDF.util.deserialize(cfhttp.fileContent);
		
				if ( IsArray(cmdResultArray) )
				{
					if ( ArrayLen(cmdResultArray) GTE 2 )
						retData = cmdResultArray[2];
				}
				else
					retData = cmdResultArray;
			</cfscript>
			<cfcatch>
				<cfdump var="#cfcatch#" label="cfcatch" expand="false">
				<cfset retData.error = cfcatch>
			</cfcatch>
		</cftry>
	<cfelse>
		<cfset retData.errorMsg = "Error: Command is was not valid!">
	</cfif>
	
	<cfreturn retData>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$buildCommandString
Summary:
	
Returns:
	string
Arguments:
	cmdData = Struct
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="buildCommandString" access="public" returntype="string" output="true" hint="">
	<cfargument name="cmdData" type="struct" required="false" default="#StructNew()#" hint="">
	
	<cfscript>
		var commandXML = "";
		
		if ( isStruct(arguments.cmdData) AND StructCount(arguments.cmdData) GT 0 )
		{
			commandXML = server.CommonSpot.UDF.Util.serializeBean(cmdData);
			// Trim off the surrounding "<struct></struct>" tags
			commandXML = MID(commandXML,9,LEN(commandXML)-17);
		}
		
		// Validate if the XML starts with "COMMAND"
		if ( MID(server.commonspot.UDF.HTML.escape(TRIM(commandXML)),5, 7) NEQ "Command" ) 
			commandXML = '<Command>' & commandXML & '</Command>';
		
		return commandXML;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getRemoteSiteURL
Summary:
	Returns the Site URL for Remote Commands.
Returns:
	string
Arguments:
	numeric
History:
	2015-09-11 - GAC - Created
--->
<cffunction name="getRemoteSiteURL" access="public" returntype="string" hint="Get the Site URL for Remote Commands.">
	<cfscript>
		var apiConfig = variables.api.getAPIConfig();
		var retVal = request.site.url;
		
		if ( StructKeyExists(apiConfig,"wsVars") AND StructKeyExists(apiConfig.wsVars,"siteURL") AND LEN(TRIM(apiConfig.wsVars.siteURL)) )
			retVal = apiConfig.wsVars.siteURL;

		// Check to make sure the retVal ends in "/"
		if ( RIGHT(retVal, 1) NEQ "/" )
			retVal = retVal & "/";
		
		return retVal;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$buildRemoteSubsiteFullURL
Summary:
	Returns the Full URL for the subsite (http://...)
Returns:
	string
Arguments:
	numeric
History:
	2015-09-01 - GAC - Created
--->
<cffunction name="buildRemoteSubsiteFullURL" access="public" returntype="string" hint="Returns the Full URL for the subsite (http://...)">
	<cfargument name="subsiteID" type="numeric" required="false" default="1" hint="subsiteID to build the full URL from">
	
	<cfscript>
		var httpSubsiteURL = getRemoteSiteURL();
		var subsiteData = application.ADF.csData.getSubsiteQueryByID(subsiteID=arguments.subsiteID);

		// Remove the root subsite from the path
		httpSubsiteURL = Replace(httpSubsiteURL, request.site.CP_URL, "");
		
		// Add the subsite path to the string
		httpSubsiteURL = httpSubsiteURL & subsiteData.SubSiteURL;
		
		return httpSubsiteURL;
	</cfscript>
</cffunction>

</cfcomponent>