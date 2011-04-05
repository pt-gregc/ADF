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
	2011-01-26 - GAC - Added a method for setLightboxProxyURL
	2011-04-05 - MFC - Updated the version property.
--->
<cfcomponent displayname="SiteBase" extends="ADF.core.AppBase">

<cfproperty name="version" value="1_5_0">

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
	2011-04-05 - MFC - Added 'application.ADF.csVersion' variable.
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
		application.ADF.csVersion = getCSVersion();
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
	2011-03-20 - RLW - Added support to load a "version" of library components
--->
<cffunction name="loadLibrary" access="private" returntype="void" hint="Loads the latest ADF library components into the application space">
	<cfargument name="loadVersion" type="string" required="false" default="#getADFVersion()#" hint="Pass in the specific ADF version you would like to load">
	<cfscript>
		var libKeys = "";
		var localLibKeys = "";
		var i = 1;
		var libVersions = structNew();
		var thisComponent = "";
		var thisComponentEasyName = "";

		// Load the ADF Lib components
		application.ADF.beanConfig.loadADFLibComponents("#request.site.csAppsURL#lib/", "", "application");

		// Refresh the Object Factory
		application.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(application.ADF.beanConfig);		

		//localLibKeys = StructKeyList(application.ADF.library);
		
		// retrieve the libraryComponents to load
		libVersions = loadLibVersions();
		// verify that the passed in version is valid
		if( structKeyExists(libVersions, "v_" & arguments.loadVersion) )
			libKeys = structKeyList(libVersions["v_" & arguments.loadVersion] );
		else
			libKeys = structKeyList(libVersions["v_" & getADFVersion()] );
			
		// loop over the keys that are the lib component names
		for ( i = 1; i LTE ListLen(libKeys); i = i + 1)
		{
			// build the variables for loading components
			thisComponent = listGetAt(libKeys, i);
			thisComponentEasyName = listFirst(thisComponent, "_");
			
			// Load the bean into application space
			application.ADF[thisComponentEasyName] = server.ADF.objectFactory.getBean(thisComponent);
		}

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
Author: 	R. West
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
	2011-02-02 - RAK - Updated structMerge to merge the lists also by adding true to the structMerge function
	2011-03-20 - MFC - Reconfigured Proxy White List to store in application space 
					to avoid conflicts with multiple sites. 
--->
<cffunction name="loadSiteAjaxProxyWhiteList" access="private" returntype="void" hint="">
	
	<cfscript>
		var configPath = "#request.site.csAppsDir#config/proxyWhiteList.xml";
		var configStruct = StructNew();
		// Check if the file exist on the site
		if ( fileExists( configPath ) )
		{
			configStruct = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configPath);
			application.ADF.proxyWhiteList = server.ADF.objectFactory.getBean("Data_1_0").structMerge(application.ADF.proxyWhiteList, configStruct, true);
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
Author: 	Greg Cronkright
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
--->
<cffunction name="loadLibraryComponent" access="public" returntype="void" hint="Allows overriding of ADF beans and creating new ones with names">
	<cfargument name="beanName" type="string" required="true" default="" hint="Bean name to use in the overloading (ceData_1_5)">
	<cfargument name="adfBeanName" type="string" required="true" default="" hint="Destination bean name to set the adf bean to (ceData)">
	<cfscript>
		var bean = "false";
		if(server.ADF.objectFactory.containsBean(beanName)){
			StructInsert(application.ADF,adfBeanName,server.ADF.objectFactory.getSingleton(beanName),true);
		}else{
			// TODO: Need to check this... not sure the cfscript version of cfthrow is CF8 compatible
			throw("Could not find bean name: '#beanName#' while calling loadLibraryComponent");
		}
	</cfscript>
</cffunction>

</cfcomponent>