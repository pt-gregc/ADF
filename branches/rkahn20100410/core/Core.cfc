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

<cffunction name="reset" access="remote" returnType="string">
	<cfargument name="type" type="string" required="false" default="all" hint="The type of the ADF to reset.  Options are 'Server', 'Site' or 'All'. Defaults to 'All'.">
	<cfscript>
		var rtnVal = false;

		try
		{
	  		// 2010-06-23 jrybacek Determine if user is logged in.
	  		if (request.user.id gt 0)
	  		{
		  		// 2010-06-23 jrybacek Determine how much of the ADF is being requested to be reset
				switch (uCase(arguments.type))
				{
					case "ALL":
						// 2010-06-23 jrybacek Reload ADF server
						createObject("component", "ADF.core.Core").init();
						// 2010-06-23 jrybacek Reload ADF site
						createObject("component", "#request.site.name#._cs_apps.ADF").init();
						rtnVal = "ADF framework reset request has been sent.";
						break;
					case "SERVER":
						// 2010-06-23 jrybacek Reload ADF server
						createObject("component", "ADF.core.Core").init();
						rtnVal = "ADF server reset request has been sent.";
						break;
					case "SITE":
						// 2010-06-23 jrybacek Reload ADF site
						createObject("component", "#request.site.name#._cs_apps.ADF").init();
						rtnVal = "ADF site '#request.site.name#' reset request has been sent.";
						break;
					default:
						rtnVal = "Invalid argument '#arguments.type#' passed to method reset.";
						break;
				}
	  		}
	  		else
	  		{
	  			rtnVal = "Insufficient security, user not logged in.";
	  		}
		}
		catch (any error)
		{
			writeOutput("<div class="".CS_Error_ADF"">Error resetting ADF.<br />Message: #error.message#<br />Detail: #error.detail#</div>");
		}
	</cfscript>
	<cfreturn rtnVal>
</cffunction>

</cfcomponent>
