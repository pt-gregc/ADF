<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc.  Copyright (c) 2009-2016.
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
	2011-04-05 - MFC - Modified - Updated the version property.
	2011-07-11 - MFC - Updated INIT function for no IF statement for call to "super.init".
	2013-04-25 - MFC - Added "validateAppBeanExists" function.
	2013-10-21 - GAC - Added 'file-version' property for ADF core files 
	2014-02-26 - GAC - Updated for version 1.7.0
	2014-10-07 - GAC - Updated for version 1.8.0
	2015-06-10 - ACW - Updated the component extends to no longer be dependant on the 'ADF' in the extends path
--->
<cfcomponent name="AppBase" extends="Base" hint="App Base component for the ADF">

<cfproperty name="version" value="2_0_1">
<cfproperty name="file-version" value="3">

<cffunction name="init" output="true" returntype="any">
	<cfscript>
		super.init(argumentCollection=arguments);
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
/* *************************************************************** */
Author:
	PaperThin, Inc.
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
	2013-01-18 - MFC - Added check for if the "app" is a struct.
	2013-04-25 - MFC - Validate if the "appBeanName" exists in the SERVER object factory.
	2014-04-04 - GAC - Switched to the cfthrow tag since the cfscript 'throw' is not cf8 compatible
--->
<cffunction name="loadApp" access="private" returntype="void" hint="Stores the ADF Lib Components into application.ADF space.">
	<cfargument name="appBeanName" type="string" required="true" default="" hint="ADF lightwire bean name.">
	<cfscript>
		var app = "";
		var throwError = false;
		var throwErrorMsg = "";
		
		if ( LEN(arguments.appBeanName) )
		{
			// Update the siteAppList
			application.ADF.siteAppList = ListAppend(application.ADF.siteAppList, arguments.appBeanName);
			
			// Validate if the "appBeanName" exists in the SERVER object factory
			if ( validateAppBeanExists(arguments.appBeanName) ){
			
				// Create the Application Space for the app bean
				application[arguments.appBeanName] = StructNew();
				
				// Copy the App bean config struct from server.ADF into application.ADF
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
				// [MFC] - Added check for if the "app" is a struct.
				if( isStruct(app) AND StructKeyExists(app, "postInit") )
					app.postInit();
			}
			else {
				// Throw error that the App Bean doesn't exist.
				throwError = true;
				throwErrorMsg = "The'#arguments.appBeanName#' app could not be loaded. Check that the app exists in the '/ADF/apps/' directory.";
				// cfscript 'throw' is not cf8 compatible
				//throw("The'#arguments.appBeanName#' app could not be loaded. Check that the app exists in the '/ADF/apps/' directory.");
				//server.ADF.objectFactory.getBean("log_1_0").logAppend(throwErrorMsg);
			}
		}
	</cfscript>
	<cfif throwError>
		<cfthrow message="#throwErrorMsg#">
	</cfif>
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
	2012-10-18 - MFC - Check to see if a bean already exists within an app, and load in the override.
						Resolves the issue with the bean and CFC name being different names loaded into the
						App Bean Config.
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

		var beanConfigStruct = application.ADF.beanConfig.getConfigStruct();
			
		// Check if there is a 'components' directory in the site
		if ( directoryExists(expandPath(comPath)) ) {
			utilsObj = server.ADF.objectFactory.getBean("utils_1_0");
			siteComponents = utilsObj.directoryFiles(expandPath(comPath), "false");	
			siteComponentsFiles = utilsObj.filterDirectoryQueryByType(siteComponents, '%.cfc');

			// Loop over the returned components to add to the application.ADF object factory
			for ( i = 1; i LTE siteComponentsFiles.RecordCount; i = i + 1)
			{
				beanData = application.ADF.beanConfig.buildBeanDataStruct(siteComponentsFiles.directory[i], siteComponentsFiles.name[i]);

				// 2012-10-18 - Check to see if a bean already exists within an app, and load in the override.
				if ( StructKeyExists(beanConfigStruct, beanData.beanName) ){
					// Get the nickname of the CFC to override
					if ( StructKeyExists(beanConfigStruct, arguments.appBeanName)
							AND StructKeyExists(beanConfigStruct[arguments.appBeanName], "CONSTRUCTORDEPENDENCYSTRUCT")
							AND StructKeyExists(beanConfigStruct[arguments.appBeanName].CONSTRUCTORDEPENDENCYSTRUCT, beanData.beanName) ){
						beanData.cfcName = beanConfigStruct[arguments.appBeanName].CONSTRUCTORDEPENDENCYSTRUCT[beanData.beanName];
					}
				}
				
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
	Recurses the bean in server.ADF Bean Config and copies the beans to
		the application.ADF Bean Config.
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
		
		// Check if we are working with a server.ADF bean
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
/* *************************************************************** */
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
	2011-02-02 - RAK - Updated structMerge to merge the lists also by adding true to the structMerge function
	2011-03-20 - MFC - Reconfigured Proxy White List to store in application space 
						to avoid conflicts with multiple sites. 
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
			// Merge this config struct into the application proxy white list 
			application.ADF.proxyWhiteList = server.ADF.objectFactory.getBean("data_1_2").structMerge(application.ADF.proxyWhiteList, configStruct, true);
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$validateAppBeanExists
Summary:
	Validates if the app bean exists in the server ADF object factory.
Returns:
	Boolean
Arguments:
	String - appName
History:
	2013-04-25 - MFC - Created
--->
<cffunction name="validateAppBeanExists" access="public" returntype="boolean" hint="Validates if the app bean exists in the server ADF object factory.">
	<cfargument name="appName" type="string" required="true">
	<cfscript>
		// Check if the App Bean is created in the Server ADF object factory
		if ( isObject(server.ADF.objectFactory.getBean(arguments.appName)) )
			return true;
		else
			return false;	 
	</cfscript>
</cffunction>

</cfcomponent>