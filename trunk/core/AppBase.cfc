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
	AppBase.cfc
Summary:
	App Base component for the ADF
History:
	2009-08-14 - MFC - Created
	2010-04-06 - MFC - Cleaned the loadApp code.  Removed verifyLocalAppBeanConfigExists function.
	2010-04-08 - MFC - Updated loadSiteAppComponents function.
--->
<cfcomponent name="AppBase" extends="ADF.core.Base" hint="App Base component for the ADF">

<cfproperty name="version" value="1_0_0">

<cffunction name="init" output="true" returntype="any">
	<cfscript>
		if(StructKeyExists(super, 'init'))
			super.init(argumentCollection=arguments);
		StructAppend(variables, arguments, false);
		// Load objects into THIS local scope
		loadObjects();
		return this;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$loadObjects
Summary:
	Load variable scope into THIS local scope
Returns:
	Void
Arguments:
	Void
History:
	2009-08-06 - MFC - Created
--->
<cffunction name="loadObjects" access="private" returntype="void">
	<cfscript>
		var keys = "";
		var i = 1;
		var objectName = "";
		// Loop over the variables - load the objects into this scope
		keys = StructKeyList(variables);
		for (i=1; i LTE ListLen(keys); i=i+1){
			objectName = ListGetAt(keys,i);
			if ( (IsObject(variables[objectName])) AND (objectName NEQ "this") ){
				this[objectName] = variables[objectName];
			}
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$loadApp
Summary:
	Stores the ADF Lib Components into application.ADF space.
Returns:
	Void
Arguments:
	String - appBeanName - ADF lightwire bean name.
History:
	2009-06-05 - MFC - Created
	2010-04-06 - MFC - Removed old code.
	2010-08-26 - MFC - Changed "isDefined" to "StructKeyExists"
--->
<cffunction name="loadApp" access="private" returntype="void" hint="Stores the ADF Lib Components into application.ADF space.">
	<cfargument name="appBeanName" type="string" required="true" default="" hint="ADF lightwire bean name.">
	<cfscript>
		var app = "";
		if ( LEN(arguments.appBeanName) )
		{
			// Update the siteAppList
			application.ADF.siteAppList = ListAppend(application.ADF.siteAppList, arguments.appBeanName);
			
			// Create the Application Space for the app bean
			application[arguments.appBeanName] = StructNew();
			
			// Copy the App bean config struct from Server.ADF into Application.ADF
			copyServerBeanToApplication(arguments.appBeanName);
			// Load the local App components into the object factory
			loadSiteAppComponents(arguments.appBeanName);
			// Load the App
			application[arguments.appBeanName] = application.ADF.objectFactory.getBean(arguments.appBeanName);
			
			// set up the configuration of the element
			setAppConfig(arguments.appBeanName);			
			// Load the site ajax service proxy white list XML
			loadAppProxyWhiteList(arguments.appBeanName);
			// run the post init function if it is defined
			app = application.ADF.objectFactory.getBean(arguments.appBeanName);
			// [MFC] - Changed "isDefined" to "StructKeyExists"
			if( StructKeyExists(app, "postInit") )
				app.postInit();
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$setAppConfig
Summary:	
	Sets the environmental variables for an app
Returns:
	Void
Arguments:
	String appBeanName
History:
 2009-10-14 - RLW - Created
--->
<cffunction name="setAppConfig" access="public" returntype="void" hint="Sets the configuration for an app by looking in Config Element and Site XML">
	<cfargument name="appBeanName" type="string" required="true" hint="The name of the app to set the config for">
	<cfscript>
		// Load the Apps Configs for CE and XML configs into server.ADF.environment
		server.ADF.environment[request.site.id][arguments.appBeanName] = StructNew();
		StructAppend(server.ADF.environment[request.site.id][arguments.appBeanName], getAppCEConfigs(arguments.appBeanName), true);
		StructAppend(server.ADF.environment[request.site.id][arguments.appBeanName], getAppXMLConfigs(arguments.appBeanName), true);	
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$getAppConfig
Summary:	
	Returns the configuration data for this element
Returns:
	Struct config
Arguments:
	String appBeanName
History:
 2009-10-14 - RLW - Created
--->
<cffunction name="getAppConfig" access="public" returntype="struct" hint="Returns the configuration data for the element">
	<cfargument name="appBeanName" type="string" required="true" hint="The name of the app whose configuration is to be returned">
	<cfreturn server.ADF.environment[request.site.id][arguments.appBeanName]>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getAppCEConfigs
Summary:
	Returns the Apps custom element configuration structure
Returns:
	Struct - Data Values Structure
Arguments:
	String - appName
History:
	2009-08-06 - MFC - Created
--->
<cffunction name="getAppCEConfigs" access="public" returntype="struct">
	<cfargument name="appName" type="string" required="true">
	<!--- Call the config getConfigViaElement function with the App Name --->
	<cfreturn server.ADF.objectFactory.getBean("CoreConfig").getConfigViaElement(arguments.appName)>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getAppXMLConfigs
Summary:
	Returns the Apps XML configuration structure
Returns:
	Struct - Structure from the XML tags and values
Arguments:
	Void
History:
	2009-08-06 - MFC - Created
--->
<cffunction name="getAppXMLConfigs" access="private" returntype="struct" hint="Returns a structure for the site configurations for site and apps.">
	<cfargument name="appName" type="string" required="true">
	<cfscript>
		var retConfigStruct = StructNew();
		var configAppXMLPath = "#request.site.csAppsDIR#config/#arguments.appName#.xml";
		// Check if the config file exists for the site
		if ( FileExists(configAppXMLPath) )
			retConfigStruct = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configAppXMLPath);
	</cfscript>
	<cfreturn retConfigStruct>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	loadSiteAppComponents
Summary:
	Loads the Site Application components into the App structure
Returns:
	Void
Arguments:
	String - appScopeVarName - Application scope name.
	String - appBeanName - ADF lightwire bean name.
	Numeric - siteid - Site ID for the site components to load.
History:
	2009-07-22 - MFC - Created
	2010-04-06 - MFC - Code cleanup.
	2010-04-08 - MFC - Updated the Library overrides to pull from the "/lib/" directory
							not the "/components/lib/" in the sites application directory.
--->
<cffunction name="loadSiteAppComponents" access="private" returntype="void" hint="Stores the site specific components in '/_cs_apps/components' into application.ADF space."> 
	<cfargument name="appBeanName" type="string" required="true" default="" hint="ADF lightwire bean name.">
	
	<cfscript>
		// Get the apps local components
		var comPath = request.site.csAppsURL & getAppBeanDir(arguments.appBeanName) & "/components";
		var appLibPath = request.site.csAppsURL & getAppBeanDir(arguments.appBeanName) & "/lib";
		var utilsObj = "";
		var siteComponents = QueryNew("tmp");
		var siteComponentsFiles = QueryNew("tmp");
		var beanData = StructNew();
		var i = 1;
		var refreshObjFactory = false;
	
		// Check if there is a 'components' directory in the site
		if ( directoryExists(expandPath(comPath)) ) {
			utilsObj = server.ADF.objectFactory.getBean("utils_1_0");
			siteComponents = utilsObj.directoryFiles(expandPath(comPath), "false");	
			siteComponentsFiles = utilsObj.filterDirectoryQueryByType(siteComponents, '%.cfc');

			// Loop over the returned components to add to the application.ADF object factory
			for ( i = 1; i LTE siteComponentsFiles.RecordCount; i = i + 1)
			{
				beanData = application.ADF.beanConfig.buildBeanDataStruct(siteComponentsFiles.directory[i], siteComponentsFiles.name[i]);
				// Add the bean into the Application ADF objectfactory
				application.ADF.BeanConfig.addSingleton(beanData.cfcPath, beanData.beanName);
				application.ADF.BeanConfig.addConstructorDependency(arguments.appBeanName, beanData.beanName, beanData.cfcName);
			}
			// Set the refresh flag
			refreshObjFactory = true;
		}
		// Check if the Site App has any lib overrides
		if ( directoryExists(expandPath(appLibPath)) ){
			// Load the ADF Lib components
			application.ADF.beanConfig.loadADFLibComponents("#appLibPath#/", "", "application");
			// Set the refresh flag
			refreshObjFactory = true;
		}
		
		// Refresh the Object Factory
		if ( refreshObjFactory )
			application.ADF.objectFactory = createObject("component","ADF.core.lightwire.LightWireExtendedBase").init(application.ADF.beanConfig);
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$copyServerBeanToApplication
Summary:
	Recurses the bean in Server.ADF Bean Config and copies the beans to 
		the Application.ADF Bean Config.
		Recurses for the CONSTRUCTORDEPENDENCYSTRUCT, MIXINDEPENDENCYSTRUCT, and 
			SETTERDEPENDENCYSTRUCT data in the bean.
Returns:
	Void
Arguments:
	String - beanName - Bean Name to copy.
History:
	2009-08-07 - MFC - Created
	2010-04-06 - MFC - Code cleanup.
*/
--->
<cffunction name="copyServerBeanToApplication" access="private" returntype="void">
	<cfargument name="beanName" type="string" required="true">
	
	<cfscript>
		var i = 1;
		var j = 1;
		var k = 1;
		var cd_keys = "";
		var md_keys = "";
		var sd_keys = "";
		var appBeanStruct = server.ADF.beanConfig.getConfigStruct();
		
		// Check if we are working with a SERVER.ADF bean
		if ( StructKeyExists(appBeanStruct, arguments.beanName) ) {
			appBeanStruct = appBeanStruct[arguments.beanName];
			// Add the bean to the application ADF
			application.ADF.beanConfig.addConfigStruct(arguments.beanName, appBeanStruct);
	
			// Recurse over the beans fields fields to built the structure correctly
			// Add in the CONSTRUCTORDEPENDENCYSTRUCT beans
			cd_keys = StructKeyList(appBeanStruct.CONSTRUCTORDEPENDENCYSTRUCT);
			for ( i = 1; i LTE ListLen(cd_keys); i = i + 1)
				copyServerBeanToApplication(ListGetAt(cd_keys, i));
			
			// Add in the MIXINDEPENDENCYSTRUCT beans
			md_keys = StructKeyList(appBeanStruct.MIXINDEPENDENCYSTRUCT);
			for ( j = 1; j LTE ListLen(md_keys); j = j + 1)
				copyServerBeanToApplication(ListGetAt(md_keys, j));
				
			// Add in the SETTERDEPENDENCYSTRUCT beans
			sd_keys = StructKeyList(appBeanStruct.SETTERDEPENDENCYSTRUCT);
			for ( k = 1; k LTE ListLen(sd_keys); k = k + 1)
				copyServerBeanToApplication(ListGetAt(sd_keys, k));
		}
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getAppBeanDir
Summary:
	Returns the directory for the Application.
Returns:
	String - appBeanName - App Bean Name
Arguments:
	ARGS
History:
	2009-00-00 - MFC - Created
--->
<cffunction name="getAppBeanDir" access="public" returntype="string" hint="Returns the directory for the Application.">
	<cfargument name="appBeanName" type="string" required="true" default="" hint="ADF lightwire bean name.">
	
	<cfscript>
		var configStruct = application.ADF.beanConfig.GETCONFIGSTRUCT();
		var appBeanStruct = StructNew();
		var pathVal = "";
		var dir = "";
		// find the structkey for the application.ADF
		if ( StructKeyExists(configStruct, arguments.appBeanName) )
		{
			// get the struct out
			appBeanStruct = configStruct[#arguments.appBeanName#];
			// Check if the path key exists
			if ( StructKeyExists(appBeanStruct, "path") )
			{
				pathVal = appBeanStruct.path;
				// Find the list item before 'components' dir name
				dir = ListGetAt(pathVal, ListFindNoCase(pathVal, 'components', '.') - 1, '.');
			}
		}
	</cfscript>
	<cfreturn dir>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$loadAppProxyWhiteList
Summary:
	Loads the proxy white list XML for the application.
Returns:
	ARGS
Arguments:
	ARGS
History:
	2009-00-00 - MFC - Created
--->
<cffunction name="loadAppProxyWhiteList" access="private" returntype="void" hint="Loads the proxy white list XML for the application.">
	<cfargument name="appName" type="string" required="true">
	
	<cfscript>
		var appBeanStruct = application.ADF.beanConfig.getConfigStruct(arguments.appName);
		var appDirName = ListGetAt(appBeanStruct[arguments.appName].path, 3, ".");
		var proxyWhiteListXMLPath = ExpandPath("/ADF/apps/#appDirName#/components/proxyWhiteList.xml");
		var configStruct = StructNew();
		// Check if the config file exists for the site
		if ( FileExists(proxyWhiteListXMLPath) )
		{	
			configStruct = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(proxyWhiteListXMLPath);
			// Merge this config struct into the server proxy white list 
			server.ADF.proxyWhiteList = server.ADF.objectFactory.getBean("Data_1_0").structMerge(server.ADF.proxyWhiteList, configStruct);
		}
	</cfscript>
</cffunction>

</cfcomponent>