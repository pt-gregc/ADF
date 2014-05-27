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
	SiteBase.cfc
Summary:
	Site Base component for the ADF
History:
	2009-08-14 - MFC - Created
	2011-01-21 - GAC - Added a version variable to application.ADF
	2011-01-26 - GAC - Added a method for setLightboxProxyURL
	2011-04-05 - MFC - Updated the version property.
	2011-09-27 - GAC - Updated most of the comment blocks to follow the ADF standard
	2014-02-26 - GAC - Updated for version 1.7.0
--->
<cfcomponent displayname="SiteBase" extends="ADF.core.AppBase">

<cfproperty name="version" value="1_7_1">
<cfproperty name="file-version" value="4">

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	M. Carroll
Name:
	$initSite
Summary:
	Initialize the site variables
Returns:
	Void
Arguments:
	Void
History:
	2009-08-17 - MFC - Created
	2011-03-20 - MFC - Reconfigured Proxy White List to store in application space 
						to avoid conflicts with multiple sites. 
					   Declare variable for Application space.
--->
<cffunction name="initSite" access="private" returntype="void">
	
	<cfscript>
		// Initialize the ADF App Space
		application.ADF = StructNew();
		application.ADF.siteComponents = "";
		application.ADF.library = StructNew(); // Stores library components
		application.ADF.dependencyStruct = StructNew();  // Stores the bean dependency list
		application.ADF.siteAppList = ""; // Stores a list of the sites Apps loaded
		application.ADF.version = "";
		// Set the proxyWhiteList from the Server Apps ProxyWhiteList
		application.ADF.proxyWhiteList = server.ADF.proxyWhiteList;
		// Set the site to NOT enable siteDevMode by default
		application.ADF.siteDevMode = false;
		// Set the site to NOT enable proxyDebugLogging by default
		application.ADF.proxyDebugLogging = false;
	</cfscript>	
	
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	M. Carroll
Name:
	$loadSite
Summary:
	Load the application.ADF object factory, site specific components, and
		environment variables for the current site.
Returns:
	Void
Arguments:
	Void
History:
	2009-08-07 - MFC - Created
	2011-04-05 - MFC - Added 'application.ADF.csVersion' variable.
	2012-12-27 - MFC - Added the call to Load the site API or CCAPI Config
--->
<cffunction name="loadSite" access="private" returntype="void" hint="Stores the ADF Lib Components into application.ADF space.">
	<cfscript>
		initSite();
		
		// Build object factory 
		application.ADF.beanConfig = createObject("component", "ADF.core.lightwire.SiteBeanConfig").init();
		application.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(application.ADF.beanConfig);
		
		// Load the site config xml docs 
		configSiteEnvironment();
		
		// Load the site Ajax Service Proxy white list
		loadSiteAjaxProxyWhiteList();
		
		// Load the site components
		loadSiteComponents();
		
		// Load the site API or CCAPI Config
		loadSiteAPIConfig();
		
		// Adds the ADF version to the application.ADF stuct
		application.ADF.version = getADFversion();
		application.ADF.decimalVersion = getDecimalADFVersion();
		application.ADF.csVersion = getCSVersion();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	M. Carroll
Name:
	$configEnvironment
Summary:
	Initializes the server.ADF.environment space for the site.
Returns:
	Void
Arguments:
	Void
History:
	2009-08-10 - MFC - Created
--->
<cffunction name="configSiteEnvironment" access="private" returntype="void" hint="Initializes the server.ADF.environment space for the site.">
	<cfscript>
		// Clear the server.ADF.environment structure
		server.ADF.environment[request.site.id] = StructNew();
		// Add the site name to the struct
		StructInsert(server.ADF.environment[request.site.id], request.site.name, request.site.name, true);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	M. Carroll
Name:
	$loadSiteComponents
Summary:
	Load the site components in the application.ADF object factory into application.ADF components
Returns:
	Void
Arguments:
	Void
History:
	2009-08-07 - MFC - Created
--->
<cffunction name="loadSiteComponents" access="private" returntype="void" hint="Stores the site specific components in '/_cs_apps/components' into application.ADF space.">
	<cfscript>
		var i = 1;
		var bean = "";
		
		// Loop over the list of site components
		for ( i = 1; i LTE ListLen(application.ADF.siteComponents); i = i + 1)
		{
			// Get the current bean name
			beanName = ListGetAt(application.ADF.siteComponents, i);
			// Get the bean out of the object factory and load into application.ADF space
			application.ADF[beanName] = application.ADF.objectFactory.getBean(beanName);
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadLibrary
Summary:
	Loads the latest ADF library components into the application space
Returns:
	Void
Arguments:
	Void
History:
	2009-08-10 - MFC - Created
	2011-03-20 - RLW - Added support to load a "version" of library components
	2011-04-06 - MFC - Uncommented the 'localLibKeys' variable to load for the site
						LIB component overrides.
	2011-09-27 - GAC - Replaced the getADFversion calls with getDecimalADFVersion so it will read the XML file even if extra version digits
						are added to the ADFvesrion variable
--->
<cffunction name="loadLibrary" access="private" returntype="void" hint="Loads the latest ADF library components into the application space">
	<cfargument name="loadVersion" type="string" required="false" default="#getDecimalADFVersion()#" hint="Pass in the specific ADF version you would like to load">
	<cfscript>
		var libKeys = "";
		var localLibKeys = "";
		var i = 1;
		var libVersions = structNew();
		var thisComponent = "";
		var thisComponentEasyName = "";
		var ADFversion = getDecimalADFVersion();

		// Load the ADF Lib components
		application.ADF.beanConfig.loadADFLibComponents("#request.site.csAppsURL#lib/", "", "application"); 

		// Refresh the Object Factory
		application.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(application.ADF.beanConfig);

		// retrieve the libraryComponents to load
		libVersions = loadLibVersions();
		// verify that the passed in version is valid
		if( structKeyExists(libVersions, "v_" & arguments.loadVersion) )
			libKeys = structKeyList(libVersions["v_" & arguments.loadVersion] );
		else
			libKeys = structKeyList(libVersions["v_" & ADFversion] );
			
		// loop over the keys that are the lib component names
		for ( i = 1; i LTE ListLen(libKeys); i = i + 1)
		{
			// build the variables for loading components
			thisComponent = listGetAt(libKeys, i);
			thisComponentEasyName = listFirst(thisComponent, "_");
			
			// Load the bean into application space
			application.ADF[thisComponentEasyName] = server.ADF.objectFactory.getBean(thisComponent);
		}
		
		// Set the list of the Local LIB component overrides
		localLibKeys = StructKeyList(application.ADF.library);
		// 	This will override any server lib components
		for ( i = 1; i LTE ListLen(localLibKeys); i = i + 1)
		{
			// Load the bean into application space
			application.ADF[ListGetAt(localLibKeys,i)] = application.ADF.objectFactory.getBean(application.ADF.library[ListGetAt(localLibKeys,i)]);
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	R. West
Name:
	$loadLibVersions
Summary:
	Loads the mapping between library component versions and ADF versions
Returns:
	Struct rtnData
Arguments:
	Void
History:
	2011-03-20 - RLW - Created
--->
<cffunction name="loadLibVersions" access="public" returnType="struct" hint="Loads the mapping between library component versions and ADF versions">
	<cfscript>
		var versionXMLStr = "";
		var rtnData = structNew();
	</cfscript>
	<!--- // read the XML file from the /ADF/lib directory --->
	<cffile action="read" file="#expandPath('/ADF/lib/')#version.xml" variable="versionXMLStr">
	<!--- // deserialize the XML into CF --->
	<cfset rtnData = deserializeXML(versionXMLStr)>
	<cfreturn rtnData>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$resetLibrary
Summary:
	Loads the arguments ADF library component into the application space.
Returns:
	Void
Arguments:
	String - varName - Application scope variable name.
	String - beanName - Server ADF object factory bean name.
History:
	2009-08-10 - MFC - Created
--->
<cffunction name="resetLibrary" access="private" returntype="void" hint="Loads the arguments ADF library component into the application space.">
	<cfargument name="beanName" type="string" required="true" hint="Server ADF object factory bean name.">
	<cfargument name="varName" type="string" required="false" default="" hint="Application scope variable name.">
	<cfscript>
		var appVarName = arguments.varName;
		// Check if the variable name was not defined in the arguments
		if ( LEN(appVarName) LTE 0 )
			appVarName = ListFirst(arguments.beanName, "_");

		// Load the bean into application space
		application.ADF[appVarName] = application.ADF.objectFactory.getBean(arguments.beanName);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadSiteAjaxProxyWhiteList
Summary:
	Loads the site Ajax Service Proxy white list file
Returns:
	Void
Arguments:
	Void
History:
	2009-08-25 - MFC - Created
	2009-11-05 - MFC - Updated for the ajax proxy security based on bean and method.
	2011-02-02 - RAK - Updated structMerge to merge the lists also by adding true to the structMerge function
	2011-03-20 - MFC - Reconfigured Proxy White List to store in application space 
					to avoid conflicts with multiple sites. 
--->
<cffunction name="loadSiteAjaxProxyWhiteList" access="private" returntype="void" hint="">
	<cfscript>
		var configPath = "#request.site.csAppsDir#config/proxyWhiteList.xml";
		var configStruct = StructNew();
		// Check if the file exist on the site
		if ( fileExists( configPath ) ) {
			configStruct = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configPath);
			application.ADF.proxyWhiteList = server.ADF.objectFactory.getBean("Data_1_0").structMerge(application.ADF.proxyWhiteList, configStruct, true);
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$setAjaxProxyURL
Summary:	
	Each site can have its own AjaxProxy URL - we will default this to:
	/_cs_apps/ajaxProxy.cfm
Returns:
	Void
Arguments:
	String proxyURL
History:
	2009-10-14 - RLW - Created
--->
<cffunction name="setAjaxProxyURL" access="public" returntype="void" hint="Sets the URL to the AjaxProxy">
	<cfargument name="proxyURL" type="string" required="true" hint="The server relative URL to the ajaxProxy.cfm file">
	<cfset application.ADF.ajaxProxy = arguments.proxyURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Greg Cronkright
Name:
	$setLightboxProxyURL
Summary:	
	Each site can have its own lightboxProxy URL - we will default this to:
	/_cs_apps/lightboxProxy.cfm
Returns:
	Void
Arguments:
	String proxyURL
History:
	2009-10-14 - RLW - Created
	2011-01-26 - GAC - Modified - Based on code from RLWs setAjaxProxyURL
--->
<cffunction name="setLightboxProxyURL" access="public" returntype="void" hint="Sets the URL to the LightboxProxy">
	<cfargument name="proxyURL" type="string" required="true" hint="The server relative URL to the lightboxProxy.cfm file">
	<cfset application.ADF.lightboxProxy = arguments.proxyURL>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Greg Cronkright
Name:
	$enableProxyDebugLogging
Summary:	
	Enables or disables the AjaxProxy and Lightbox Proxy Debug logging for the site
Returns:
	Void
Arguments:
	Boolean enable
History:
	2013-10-19 - GAC - Created
--->
<cffunction name="enableProxyDebugLogging" access="public" returntype="void" hint="Enables or disables the AjaxProxy and Lightbox Proxy Debug logging for the site">
	<cfargument name="enable" type="boolean" required="false"  default="false">
	<cfset application.ADF.proxyDebugLogging = arguments.enable>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Greg Cronkright
Name:
	$enableADFsiteDevMode
Summary:	
	Enables or disables the ADF site Dev mode
	Default: false (disabled)
Returns:
	Void
Arguments:
	Boolenan enable
History:
	2013-10-19 - GAC - Created
--->
<cffunction name="enableADFsiteDevMode" access="public" returntype="void" hint="Enables or disables the ADF site Dev mode. Default: false (disabled)">
	<cfargument name="enable" type="boolean" required="false" default="false">
	<cfset application.ADF.siteDevMode = arguments.enable>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$loadLibraryComponent
Summary:
	Allows overriding of ADF beans and creating new ones with names
Returns:
	void
Arguments:
	string - beanName
	string - adfBeanName
History:
 	2011-01-18 - RAK - Created
	2011-02-09 - RAK - Var'ing un-var'd items
	2014-04-04 - GAC - Switched to the cfthrow tag since the cfscript 'throw' is not cf8 compatible
--->
<cffunction name="loadLibraryComponent" access="public" returntype="void" hint="Allows overriding of ADF beans and creating new ones with names">
	<cfargument name="beanName" type="string" required="true" default="" hint="Bean name to use in the overloading (ceData_1_5)">
	<cfargument name="adfBeanName" type="string" required="true" default="" hint="Destination bean name to set the adf bean to (ceData)">
	<cfscript>
		var bean = "false";
		var buildError = StructNew();
		var throwError = false;
		var throwErrorMsg = "";
		if (server.ADF.objectFactory.containsBean(beanName) )
		{
			StructInsert(application.ADF,adfBeanName,server.ADF.objectFactory.getSingleton(beanName),true);
		}
		else
		{
			// Throw error that the Library Component Bean doesn't exist.
			throwError = true;
			throwErrorMsg = "Could not find bean name: '#beanName#' while calling loadLibraryComponent.";
			// cfscript 'throw' is not cf8 compatible
			//throw("Could not find bean name: '#beanName#' while calling loadLibraryComponent");
		}
	</cfscript>
	<cfif throwError>
		<cfthrow message="#throwErrorMsg#">
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$loadSiteAPIConfig
Summary:
	Loads the API (or CCAPI) config file into server.ADF.environment space.
Returns:
	Void
Arguments:
	Void
History:
 	2012-12-27 - MFC - Created
	2013-01-11 - MFC - Updated to support CF 8 and under.
	2013-01-18 - MFC - Updated to not get the CoreConfig from the object factory
						when the server restarts.
	2013-01-23 - MFC - Modified the function to NOT expand the file of the CFM file.
	2013-01-24 - MFC - Added check if the ccapi config file exists and needs to be setup.
					    This will bypass any false errors if no config file exists.
	2014-05-21 - GAC - Updated to use the csAppsURL so the site's mapping path is included to help for a
						more accurate ExpandPath() when on a multi-site install
--->
<cffunction name="loadSiteAPIConfig" access="private" returntype="void">
	<cfscript>
		var APIConfig = "";	
		var configAppXMLPath = ExpandPath("#request.site.csAppsURL#config/ccapi.xml");
		var configAppCFMPath = "#request.site.csAppsURL#config/ccapi.cfm";
		var buildError = StructNew();
		var coreConfigObj = "";
		var configFileExists = false; // Track if the site has a ccapi config file

		try 
		{
			coreConfigObj = CreateObject("component", "ADF.core.Config");
			 	
			// Pass a Logical path for the CFM file to the getConfigViaXML() since it will be read via CFINCLUDE
			if ( FileExists(ExpandPath(configAppCFMPath)) )
			{
				APIConfig = coreConfigObj.getConfigViaXML(configAppCFMPath);
				configFileExists = true;	
			}
			// Pass an Absolute path for the XML file to the getConfigViaXML() since it will be read via CFFILE
			else if ( FileExists(configAppXMLPath) )
			{
				APIConfig = coreConfigObj.getConfigViaXML(configAppXMLPath);
				configFileExists = true;
			}
			
			// Verify that the CCAPI config needs to be setup b/c the config file exists
			if ( configFileExists )
			{
				// Validate the config has the fields we need
				if( isStruct(APIConfig) )
				{
					server.ADF.environment[request.site.id]['apiConfig'] = APIConfig;
				}
				else
				{
					// Build the Error Struct
					buildError.ADFmethodName = "API Config";
					buildError.details = "API Configuration CFM (or XML) file is not a valid data format. [#request.site.name# - #request.site.id#].";
					// Add the errorStruct to the server.ADF.buildErrors Array
					ArrayAppend(server.ADF.buildErrors,buildError);
				}
			}
		}
		catch (any exception)
		{
			// Build the Error Struct
			buildError.ADFmethodName = "API Config";
			//buildError.details = "API Configuration CFM (or XML) file is not setup for this site [#request.site.name# - #request.site.id#].";
			buildError.details = exception;
			// Add the errorStruct to the server.ADF.buildErrors Array
			ArrayAppend(server.ADF.buildErrors, buildError);
		}
	</cfscript>
</cffunction>

</cfcomponent>