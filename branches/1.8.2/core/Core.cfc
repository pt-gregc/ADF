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
	Core.cfc
Summary:
	Core component for Custom Application Common Framework
History:
	2009-06-22 - MFC - Created
	2011-01-20 - GAC - Modified - Added a shared variable for ADF version
									Added a function that returns the ADF version
	2011-01-21 - GAC - Modified - Added a place to store build errors that occur while building the ADF
	2011-04-05 - MFC - Modified - Updated the version property.
								  Added a shared variable for CS version
								  Added a function that returns the CS version
	2012-03-08 - MFC - Modified - Removed the cfproperty for the "svnRevision".
								  Added "variables.buildRev" to be manually updated before releases.
								  Added "server.ADF.buildRev" to have available in the ADF space.
	2012-07-11 - MFC - Modified - New v1.6.0 branch.
	2013-03-15 - MFC - Modified - New v1.6.1 branch.
	2013-05-21 - MFC - Modified - New v1.6.2 branch.
	2013-10-21 - GAC - Modified - Added 'file-version' property for ADF core files 
	2014-02-26 - GAC - Modified - New v1.7.0 branch.
	2014-02-26 - GAC - Modified - New v1.7.1 branch.
	2014-10-07 - GAC - Updated for version 1.8.0
	2014-12-03 - GAC - Updates for Adobe ColdFusion 11 compatibility
--->
<cfcomponent name="Core" hint="Core component for Application Development Framework">

<cfproperty name="version" value="1_8_2">
<cfproperty name="file-version" value="7">

<cfscript>
	variables.ADFversion = "1.8.2"; // use a dot delimited version number
	// ADF Build Revision Number
	variables.buildRev = "1572";
	// ADF Codename
	variables.buildName = "Centipede";
	// CS product version, get the decimal value
	variables.csVersion = Val(ListLast(request.cp.productversion, " "));
</cfscript>
	
<cffunction name="init" output="true" returntype="void">
	<cfscript>
		// Check if the ADF variable does not exist in server scope
		if ( NOT StructKeyExists(server, "ADF") ) 
		{
			server.ADF = StructNew();
			server.ADF.environment = StructNew();  // Stores the App and Site configuration data
		}
		
		server.ADF.beanConfig = StructNew();  // Stores the server bean configuration
		server.ADF.objectFactory = StructNew(); // Stores the server object factory
		server.ADF.dependencyStruct = StructNew();  // Stores the bean dependency list 
		server.ADF.library = StructNew(); // Stores library components
		server.ADF.proxyWhiteList = StructNew(); // Stores Ajax Proxy White List
		server.ADF.dir = expandPath('/ADF');
		server.ADF.buildErrors = ArrayNew(1); // Place to store errors that occur while building the ADF
		server.ADF.version = getADFversion(); // Get the ADF version
		server.ADF.csVersion = getCSVersion(); // Get the ADF version
		server.ADF.buildRev = variables.buildRev;
		server.ADF.buildName = variables.buildName;
				
		// Build object factory 
		server.ADF.beanConfig = createObject("component","ADF.core.lightwire.BeanConfig").init();
		server.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(server.ADF.beanConfig);
		
		// Load the Ajax white list proxy
		server.ADF.proxyWhiteList = createObject("component","ADF.core.Config").getConfigViaXML(expandPath("/ADF/lib/ajax/proxyWhiteList.xml"));
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
Name:
	getADFMapping
Summary:
	Returns the hard-coded ADF mapping for the server
	
	Used primarily for importing custom element, metadata forms, and 
		custom field types.
Returns:
	String - ADF Mapping
Arguments:
	Void
History:
	2009-07-23 - MFC - Created
--->
<cffunction name="getADFMapping" access="public" returntype="string">
	<cfreturn "/ADF/">
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	getADFversion
Summary:
	Returns the ADF Version
Returns:
	String - ADF Version
Arguments:
	Void
History:
	2011-01-20 - GAC - Created
	2011-02-09 - GAC - Removed self-closing cfreturn slash
--->
<cffunction name="getADFversion" access="public" returntype="string">
	<cfreturn variables.ADFversion>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	M. Carroll
Name:
	getCSversion
Summary:
	Returns the CS Version as the numeric value.
Returns:
	numeric - ADF Version
Arguments:
	Void
History:
	2011-04-05 - MFC - Created
--->
<cffunction name="getCSVersion" access="public" returntype="numeric">
	<!--- Return CS version from the Product Version variable --->
	<cfreturn variables.csVersion>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
	G. Cronkright
Name:
	getSiteDevModeStatus
Summary:
	Returns the Site Dev Mode Status
Returns:
	boolean - dev mode status
Arguments:
	NA
History:
	2013-10-19 - GAC - Created
	2014-12-03 - GAC - Updated the returnType to boolean
--->
<cffunction name="getSiteDevModeStatus" access="public" returntype="boolean">
	<Cfscript>
		var status = false;
		if ( StructKeyExists(application,"ADF") AND StructKeyExists(application.ADF,"siteDevMode") AND IsBoolean(application.ADF.siteDevMode) AND application.ADF.siteDevMode ) 
			status = true;				
		return status;
	</Cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	jrybacek
Name:
	reset
Summary:
	Resets the ADF if the user is logged in
Returns:
	Status
Arguments:
	String - type
		Accepted Values: "ALL","SERVER","SITE"
History:
	2010-06-23 - jrybacek - Created
	2010-10-29
	2010-12-15 - GAC - Modified - Added the ADF version to the reset message
	2010-12-20 - MFC - Modified - Added check at top to verify if ADF space exists in the SERVER and APPLICATION 
									and set the force reset flag.
	2011-01-19 - RAK - Modified - Added cache reset
	2011-01-20 - GAC - Modified - Gets the ADF version from the getADFversion function
	2011-02-09 - RAK - Var'ing un-var'd items
	2011-02-09 - RAK - Fixing typo
	2011-02-09 - GAC - Removed self-closing slash on cfthrow
	2011-04-06 - MFC - Changed the ADF reset error log to not append to the file and overwrite the file.
	2011-05-03 - MFC - Commented out 'application.ADF' cfdump from the debug log. CFDump was too large and
						caused performance slowness loading debug html.
	2011-06-29 - MT - Set a response header indicating if the ADF was reset or not.
	2011-07-14 - MFC - Renamed cache variable to be under ADF struct, "application.ADF.cache".
	2012-01-12 - MFC - Updated the ADF reset message text.
	2013-01-23 - MFC - Increased the CFLOCK timeout to "120".
	2013-10-28 - GAC - Added production mode or development mode designation message to the ADF reset message text
	2013-12-05 - GAC - Added the forceResetStatus to the returnStruct to pass if the reset was Forced or not
--->
<cffunction name="reset" access="remote" returnType="Struct">
	<cfargument name="type" type="string" required="false" default="all" hint="The type of the ADF to reset.  Options are 'Server', 'Site' or 'All'. Defaults to 'All'.">
	<cfscript>
		var rtnMsg = "ADF Reset Error: You must be logged in to perform this operation.";
		var ADFReset = false;
		var returnStruct = StructNew();
		var siteName = "";
		var logFileName = "";
		var ADFversion = "v" & getADFversion();
		var forceReset = false;
		var dump = "";
		var devModeStatus =  false;
		// Check if the ADF space exists in the SERVER and APPLICATION
		if ( NOT StructKeyExists(server, "ADF") OR NOT StructKeyExists(application, "ADF") )
			forceReset = true;
	</cfscript>
	
	<!--- // Check for reset for the user id logged in OR we have set the force flag --->
	<cfif (request.user.id gt 0) OR (forceReset)>
		<cftry>
			<cflock timeout="120" type="exclusive" name="ADF-RESET">
				<cfscript>
			 		// 2010-06-23 jrybacek Determine if user is logged in.
			  		// 2010-06-23 jrybacek Determine how much of the ADF is being requested to be reset
					switch (uCase(arguments.type)) {
						case "ALL":
							// 2010-06-23 jrybacek Reload ADF server
							createObject("component", "ADF.core.Core").init();
							// 2010-06-23 jrybacek Reload ADF site
							createObject("component", "#request.site.name#._cs_apps.ADF").init();
							rtnMsg = "ADF #ADFversion# has been reset successfully!";
							ADFReset = true;
							break;
						case "SERVER":
							// 2010-06-23 jrybacek Reload ADF server
							createObject("component", "ADF.core.Core").init();
							rtnMsg = "ADF #ADFversion# server has been reset successfully!";
							ADFReset = true;
							break;
						case "SITE":
							// 2010-06-23 jrybacek Reload ADF site
							createObject("component", "#request.site.name#._cs_apps.ADF").init();
							rtnMsg = "ADF #ADFversion# site '#request.site.name#' has been reset successfully!";
							ADFReset = true;
							break;
						default:
							rtnMsg = "Invalid argument '#arguments.type#' passed to method reset.";
							break;
					}
					if ( ADFReset ) {
						//Reset the cache.
						application.ADF.cache = StructNew();
						// Get the Dev Mode Status to display with reset message
						devModeStatus =  getSiteDevModeStatus();
						// Append the dev or production mode text to the rtnMsg string
						if ( devModeStatus ) 
							rtnMsg = rtnMsg & " [Development Mode]";	
						else 
							rtnMsg = rtnMsg & " [Production Mode]";
					}
				</cfscript>
				<!--- // If sever.ADF.buildError Array has any errors... throw an exception (used the cfthrow tag for CF8 compatibility) --->
				<cfif StructKeyExists(server.ADF,"buildErrors") AND ArrayLen(server.ADF.buildErrors)>
					<cfthrow type="ADFBuildError" message="ADF Build Errors Occured" detail="Check the server.ADF.buildErrors for Details.">
				</cfif>
			</cflock>
			<cfcatch>
				<cfsavecontent variable="dump">
					<!--- Dump the cfcatch --->
					<cfdump var="#cfcatch#" label="cfcatch" expand="false">
					
					<!--- Dump the server.ADF --->
					<cfif NOT StructKeyExists(server, "ADF")>
						<cfoutput><p>server.ADF Does not exist.</p></cfoutput>
					<cfelse>
						<cfdump var="#server.ADF#" label="server.ADF" expand="false">
					</cfif>
					
					<!--- Dump the application.ADF --->
					<!--- 2011-05-03 - MFC - Commented out 'application.ADF' cfdump from the debug log. --->
					<!--- <cfif NOT StructKeyExists(application, "ADF")>
						<cfoutput><p>application.ADF Does not exist.</p></cfoutput>
					<cfelse>
						<cfdump var="#application.ADF#" label="application.ADF" expand="false">
					</cfif> --->
				</cfsavecontent>
				<!--- // Log the error content --->
				<cfif StructKeyExists(request,"site")>
					<cfset siteName = request.site.name>
				</cfif>
				<cfset logFileName = dateFormat(now(), "yyyymmdd") & "." & siteName & ".ADF_Load_Errors.htm">
				<cffile action="write" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #dump#" addnewline="true">
				<cfset rtnMsg = "Error building the ADF #ADFversion#. <a href='/commonspot/logs/#logFileName#' target='_blank'>View the log</a>">
			</cfcatch>
		</cftry>
	</cfif>
	<cfscript>
		//
		// 2011-06-29 - MT - Set a response header indicating if the ADF was reset or not
		//
		getPageContext().getResponse().setHeader( "X-CS_ADF_Reset" , "#ADFReset#" );
		
		returnStruct.success = ADFReset;
		returnStruct.message = "&nbsp;" & DateFormat(now(),"yyyy-mm-dd") & " " & TimeFormat(now(),"hh:mm:ss") & " - " & rtnMsg;
		returnStruct.forceResetStatus = forceReset;
		returnStruct.devModeStatus = devModeStatus;
		return returnStruct;
	</cfscript>
</cffunction>

</cfcomponent>
