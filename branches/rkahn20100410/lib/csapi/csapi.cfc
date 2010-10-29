<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2010.
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
	csapi.cfc
Summary:
	CS API functions for the ADF Library
History:
	2010-08-26 - RLW - Created
--->
<cfcomponent displayname="csapi" extends="ADF.core.Base" hint="CS API functions for the ADF Library">
	
<cfproperty name="version" value="1_0_0">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_0">
<cfproperty name="wikiTitle" value="CSAPI">

<cfscript>
	variables.ccapiObj = "";
	variables.subsiteID = 0;
	variables.token = "";
</cfscript>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$FUNCTIONNAME
Summary:
	SUMMARY
Returns:
	ARGS
Arguments:
	ARGS
History:
	2010-00-00 - MFC - Created
--->
<cffunction name="initCSAPI" access="public" returntype="void" output="true" hint="">
	<cfargument name="subsiteID" required="false" type="numeric" default="1">
	<cfscript>
		setSubsiteID(arguments.subsiteID);
		loadCCAPI();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadCCAPI
Summary:
	Loads the CCAPI object
Returns:
	void
Arguments:
	void
History:
	2010-08-26 - MFC - Created
--->
<cffunction name="loadCCAPI" access="private" returntype="void" output="true" hint="">
	<cfargument name="subsiteID" required="false" type="numeric" default="1">
	<cfscript>
		variables.ccapiObj = server.ADF.objectFactory.getBean("ccapi");
		variables.ccapiObj.initCCAPI();
		login();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$run
Summary:
	Runs the command against the API.
Returns:
	any
Arguments:
	string
History:
	2010-08-26 - MFC - Created
	2010-10-25 - MFC - Added the deserialize for the return XML.
--->
<cffunction name="run" access="public" returntype="any" output="true" hint="">
	<cfargument name="commandXML" type="string" required="true" hint="">
	
	<cfscript>
		var CFID = ListFirst(getCCAPIToken(), " ");
		var CFToken = ListGetAt(getCCAPIToken(), 2, " ");	
		var httpSubsiteURL = buildSubsiteFullURL(getSubsiteID());
		var command_collection = "";
	</cfscript>
	
	<cfscript>
		command_collection = '
			<CommandCollection class="array">
			#arguments.commandXML#
			</CommandCollection>';
	</cfscript>
	
	<cfhttp url="#httpSubsiteURL#loader.cfm" method="POST">
		<cfhttpparam type="FORMFIELD" name="csModule" value="components/dashboard/dashboard" />
		<cfhttpparam type="FORMFIELD" name="cmdCollectionXML" value="#command_collection#" />
		<cfhttpparam type="FORMFIELD" name="CFID" value="#CFID#" />
		<cfhttpparam type="FORMFIELD" name="CFTOKEN" value="#CFToken#" />
	</cfhttp>
		
	<!--- Deserialize the return XML --->
	<cfreturn Server.Commonspot.UDF.util.deserialize(cfhttp.fileContent)>
</cffunction>


<cffunction name="login" access="public" returntype="void">
	<cfargument name="subsiteID" required="false" type="numeric" default="1">
	<!--- // call the CS API login --->
	<cfscript>
		var loginResult = "";
		variables.ccapiObj.login(getSubsiteID());
		
		// Verify is logged in
		if ( variables.ccapiObj.loggedIn() )
			setCCAPIToken();
	</cfscript>
</cffunction>


<cffunction name="setSubsiteID" access="public" returntype="void">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfset variables.subsiteID = arguments.subsiteID>
</cffunction>
<cffunction name="getSubsiteID" access="public" returntype="numeric">
	<cfreturn variables.subsiteID>
</cffunction>

<cffunction name="setCCAPIToken" access="public" returntype="void">
	<cfset variables.token = variables.ccapiObj.getSSID()>
</cffunction>
<cffunction name="getCCAPIToken" access="public" returntype="string">
	<cfreturn variables.token>
</cffunction>


<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$buildSubsiteFullURL
Summary:
	Returns the Full URL for the subsite (http://...)
Returns:
	string
Arguments:
	numeric
History:
	2010-08-26 - MFC - Created
	2010-10-25 - MFC - Updated the command to build the httpSubsiteURL variable.
--->
<cffunction name="buildSubsiteFullURL" access="private" returntype="string" output="true" hint="">
	<cfargument name="subsiteID" type="numeric" required="true" hint="">
	
	<cfscript>
		var subsiteData = application.ptProfile.csData.getSubsiteQueryByID(subsiteID=arguments.subsiteID);
		var httpSubsiteURL = Replace(request.site.url, request.site.CP_URL, "") & subsiteData.SubSiteURL;
		
		return httpSubsiteURL;
	</cfscript>
</cffunction>

</cfcomponent>