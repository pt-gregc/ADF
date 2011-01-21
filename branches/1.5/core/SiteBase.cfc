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
	SiteBase.cfc
Summary:
	Site Base component for the ADF
History:
	2009-08-14 - MFC - Created
	2011-01-21 - GAC - Added a version variable to Application.ADF
--->
<cfcomponent displayname="SiteBase" extends="ADF.core.AppBase">

<cfproperty name="version" value="1_0_0">

<!---
/* *************************************************************** */
Author: 	M. Carroll
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
	</cfscript>	
	
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
Name:
	$loadSite
Summary:
	Load the Application.ADF object factory, site specific components, and 
		environment variables for the current site.
Returns:
	Void
Arguments:
	Void
History:
	2009-08-07 - MFC - Created
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
		
		// Adds the ADF version to the Application.ADF stuct
		application.ADF.version = getADFversion();
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
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
Author: 	M. Carroll
Name:
	$loadSiteComponents
Summary:
	Load the site components in the APPLICATION.ADF object factory into APPLICATION.ADF components
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
Author: 	M. Carroll
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
--->
<cffunction name="loadLibrary" access="private" returntype="void" hint="Loads the latest ADF library components into the application space">
	
	<cfscript>
		var libKeys = StructKeyList(server.ADF.library);
		var localLibKeys = "";
		var i = 1;
		
		// Load the ADF Lib components
		application.ADF.beanConfig.loadADFLibComponents("#request.site.csAppsURL#lib/", "", "application");
		// Refresh the Object Factory
		application.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(application.ADF.beanConfig);
		localLibKeys = StructKeyList(application.ADF.library);
		
		// loop over the keys that are the lib component names
		for ( i = 1; i LTE ListLen(libKeys); i = i + 1)
		{
			// Load the bean into application space
			application.ADF[ListGetAt(libKeys,i)] = server.ADF.objectFactory.getBean(server.ADF.library[ListGetAt(libKeys,i)]);
		}
		// loop over the keys that are the local lib component names
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
Author: 	M. Carroll
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
	Author: 	M. Carroll
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
--->
<cffunction name="loadSiteAjaxProxyWhiteList" access="private" returntype="void" hint="">
	
	<cfscript>
		var configPath = "#request.site.csAppsDir#config/proxyWhiteList.xml";
		var configStruct = StructNew();
		// Check if the file exist on the site
		if ( fileExists( configPath ) )
		{
			configStruct = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configPath);
			server.ADF.proxyWhiteList = server.ADF.objectFactory.getBean("Data_1_0").structMerge(server.ADF.proxyWhiteList, configStruct);
		}
	</cfscript>
	
</cffunction>

<!---
/* *************************************************************** */
Author: 	Ron West
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
 	1/18/11 - RAK - Created
--->
<cffunction name="loadLibraryComponent" access="public" returntype="void" hint="Allows overriding of ADF beans and creating new ones with names">
	<cfargument name="beanName" type="string" required="true" default="" hint="Bean name to use in the overloading (ceData_1_5)">
	<cfargument name="adfBeanName" type="string" required="true" default="" hint="Destination bean name to set the adf bean to (ceData)">
	<cfscript>
		bean = "false";
		if(server.ADF.objectFactory.containsBean(beanName)){
			StructInsert(application.ADF,adfBeanName,server.ADF.objectFactory.getSingleton(beanName),true);
		}else{
			// TODO: Need to check this... not sure the cfscript version of cfthrow is CF8 compatible
			throw("Could not find bean name: '#beanName#' while calling loadLibraryComponent");
		}
	</cfscript>
</cffunction>

</cfcomponent>