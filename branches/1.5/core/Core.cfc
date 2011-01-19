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
/* ***************************************************************
/*
Application Development Framework (ADF)
Copyright (c) 2009 PaperThin, Inc.
Dual licensed under the MIT and GPL licenses.
http://consulting.paperthin.com/services-wiki/index.php/ADF:Licenses

Author: 	
	PaperThin, Inc. 
Name:
	Core.cfc
Summary:
	Core component for Custom Application Common Framework
History:
	2009-06-22 - MFC - Created
--->
<cfcomponent name="Core" hint="Core component for Application Development Framework">

<cfproperty name="version" value="1_0_0">
	
<cffunction name="init" output="true" returntype="void">
	<cfscript>
		// Check if the ADF variable does not exist in server scope
		if ( NOT StructKeyExists(server, "ADF") )
			server.ADF = StructNew();
		
		server.ADF.beanConfig = StructNew();  // Stores the server bean configuration
		server.ADF.objectFactory = StructNew(); // Stores the server object factory
		server.ADF.dependencyStruct = StructNew();  // Stores the bean dependency list 
		server.ADF.library = StructNew(); // Stores library components
		server.ADF.proxyWhiteList = StructNew(); // Stores Ajax Proxy White List
		server.ADF.dir = expandPath('/ADF');
		
		// Build object factory 
		server.ADF.beanConfig = createObject("component","ADF.core.lightwire.BeanConfig").init();
		server.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(server.ADF.beanConfig);
		
		// Load the Ajax white list proxy
		server.ADF.proxyWhiteList = createObject("component","ADF.core.Config").getConfigViaXML(expandPath("/ADF/lib/ajax/proxyWhiteList.xml"));
	</cfscript>
</cffunction>

<!---
	/* ***************************************************************
	/*
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
Author: 	jrybacek
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
--->
<cffunction name="reset" access="remote" returnType="Struct">
	<cfargument name="type" type="string" required="false" default="all" hint="The type of the ADF to reset.  Options are 'Server', 'Site' or 'All'. Defaults to 'All'.">
	<cfscript>
		var rtnMsg = "Insufficient security, user not logged in.";
		var ADFReset = false;
		var returnStruct = StructNew();
		var siteName = "";
		var logFileName = "";
		var ADFversion = "v1.5";
		var forceReset = false;
				
		// Check if the ADF space exists in the SERVER and APPLICATION
		if ( NOT StructKeyExists(server, "ADF") OR NOT StructKeyExists(application, "ADF") )
			forceReset = true;
	</cfscript>
	
	<!--- // Check for reset for the user id logged in OR we have set the force flag --->
	<cfif (request.user.id gt 0) OR (forceReset)>
		<cftry>
			<cflock timeout="30" type="exclusive" name="ADF-RESET">
				<cfscript>
			 		// 2010-06-23 jrybacek Determine if user is logged in.
			  		// 2010-06-23 jrybacek Determine how much of the ADF is being requested to be reset
					switch (uCase(arguments.type))
					{
						case "ALL":
							// 2010-06-23 jrybacek Reload ADF server
							createObject("component", "ADF.core.Core").init();
							// 2010-06-23 jrybacek Reload ADF site
							createObject("component", "#request.site.name#._cs_apps.ADF").init();
							rtnMsg = "ADF #ADFversion# framework has been reset succesfully!";
							ADFReset = true;
							break;
						case "SERVER":
							// 2010-06-23 jrybacek Reload ADF server
							createObject("component", "ADF.core.Core").init();
							rtnMsg = "ADF #ADFversion# server framework has been reset succesfully!";
							ADFReset = true;
							break;
						case "SITE":
							// 2010-06-23 jrybacek Reload ADF site
							createObject("component", "#request.site.name#._cs_apps.ADF").init();
							rtnMsg = "ADF #ADFversion# site '#request.site.name#' has been reset succesfully!";
							ADFReset = true;
							break;
						default:
							rtnMsg = "Invalid argument '#arguments.type#' passed to method reset.";
							break;
					}
					if(ADFReset){//Reset the cache.
						application.ADFCache = StructNew();
					}
				</cfscript>
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
					<cfif NOT StructKeyExists(application, "ADF")>
						<cfoutput><p>application.ADF Does not exist.</p></cfoutput>
					<cfelse>
						<cfdump var="#application.ADF#" label="application.ADF" expand="false">
					</cfif>
				</cfsavecontent>


				<cfif StructKeyExists(request,"site")>
					<!--- Log the error content --->
					<cfset siteName = request.site.name>
				</cfif>
				<cfset logFileName = dateFormat(now(), "yyyymmdd") & "." & siteName & ".ADF_Load_Errors.htm">
				<cffile action="append" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #dump#" addnewline="true">
				<cfset rtnMsg = "Error building the ADF. <a href='/commonspot/logs/#logFileName#' target='_blank'>View the log</a>">
			</cfcatch>
		</cftry>
	</cfif>
	<cfscript>
		returnStruct.success = ADFReset;
		returnStruct.message = "&nbsp;"&DateFormat(now(),"yyyy-mm-dd")&" "&TimeFormat(now(),"hh:mm:ss")&" - "&rtnMsg;
		return returnStruct;
	</cfscript>
</cffunction>

</cfcomponent>
