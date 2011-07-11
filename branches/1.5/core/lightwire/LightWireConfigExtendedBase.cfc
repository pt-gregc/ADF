<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2011.
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
	LightWireConfigExtendedBase,cfc
Summary:
	LightWire Configuration component extended from the Base.cfc.
History:
	2009-08-14 - MFC - Created
	2011-07-11 - MFC/AW - Updated Init and loadADFAppBeanConfig for performance improvements.
--->
<cfcomponent name="LightWireConfigBase" extends="ADF.thirdParty.lightwire.BaseConfigObject" output="false">

<cfproperty name="version" value="1_5_0">

<cffunction name="init" returntype="any" hint="I initialize default LightWire config properties." output=false access="public">
	<cfscript>
		if(StructKeyExists(super, 'init'))
			super.init(argumentCollection=arguments);
		variables.constructorDependencyRules = ArrayNew(1);
	</cfscript>
	<cfreturn this>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	G. Cronkright
	Name:
		$addSingleton
	Summary:
		Override method for the Lightwire addSingleton method with added error handling.
		Used to add the configuration properties for a Singleton.
	Returns:
		void
	Arguments:
		String - FullClassPath 
		String - BeanName 
		String - InitMethod 
	History:
		2011-01-20 - GAC - Copied from Lightwire BaseConfigObject.cfc
						   Modified to add error logging
--->
<cffunction name="addSingleton" returntype="void" hint="I add the configuration properties for a Singleton." output="false">
	<cfargument name="FullClassPath" required="true" type="string" hint="The full class path to the bean including its name. E.g. for com.UserService.cfc it would be com.UserService.">
	<cfargument name="BeanName" required="false" default="" type="string" hint="An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.UserService, it'll be named UserService unless you put something else here. If you put UserS, it'd be available as UserS, but NOT as UserService.">
	<cfargument name="InitMethod" required="false" default="" type="string" hint="A default custom initialization method for LightWire to call on the bean after constructing it fully (including setter and mixin injection) but before returning it.">
	<cfscript>
		var buildError = StructNew();

		try {
			// Call the addSingleton method from the extended BaseConfigObject in Lightwire
			Super.addSingleton(argumentCollection=arguments);
			//addBean(FullClassPath, BeanName, 1, InitMethod);
		}
		catch(Any e) {
			// Build the Error Struct
			buildError.args = arguments;
			buildError.details = e;
			// Log the Error struct and add it to the ADF buildErrors Array 
			doConfigBuildErrorLogging("addSingleton",buildError);
		}
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	G. Cronkright
	Name:
		$addTransient
	Summary:
		Override method for the Lightwire addTransient method with added error handling.
		Used to add the configuration properties for a Transient.
	Returns:
		void
	Arguments:
		String - FullClassPath 
		String - BeanName 
		String - InitMethod 
	History:
		2011-01-20 - GAC - Copied from Lightwire BaseConfigObject.cfc
						   Modified to add error logging
--->
<cffunction name="addTransient" returntype="void" hint="I add the configuration properties for a Transient." output="false">
	<cfargument name="FullClassPath" required="true" type="string" hint="The full class path to the bean including its name. E.g. for com.User.cfc it would be com.User.">
	<cfargument name="BeanName" required="false" default="" type="string" hint="An optional name to be able to use to refer to this bean. If you don't provide this, the name of the bean will be used as a default. E.g. for com.User, it'll be named User unless you put something else here. If you put UserBean, it'd be available as UserBean, but NOT as User.">
	<cfargument name="InitMethod" required="false" default="" type="string" hint="A default custom initialization method for LightWire to call on the bean after constructing it fully (including setter and mixin injection) but before returning it.">
	<cfscript>
		var buildError = StructNew();

		try {
			// Call the addTransient method from the extended BaseConfigObject in Lightwire
			Super.addTransient(argumentCollection=arguments);
			//addBean(FullClassPath, BeanName, 0, InitMethod);
		}
		catch( Any e ) {
			// Build the Error Struct
			buildError.args = arguments;
			buildError.details = e;
			// Log the Error struct and add it to the ADF buildErrors Array 
			doConfigBuildErrorLogging("addTransient",buildError);
		}
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	G. Cronkright
	Name:
		$addConstructorDependency
	Summary:
		Override method for the Lightwire addConstructorDependency method with added error handling.
		Used to  add a constructor object dependency for a bean.
	Returns:
		void
	Arguments:
		String - BeanName 
		String - InjectedBeanName 
		String - PropertyName 
	History:
		2011-01-20 - GAC - Copied from Lightwire BaseConfigObject.cfc
						   Modified to add error logging
--->
<cffunction name="addConstructorDependency" returntype="void" hint="I add a constructor object dependency for a bean." output="false">
	<cfargument name="BeanName" required="true" type="string" hint="The name of the bean to set the constructor dependencies for.">
	<cfargument name="InjectedBeanName" required="true" default="" type="string" hint="The name of the bean to inject.">
	<cfargument name="PropertyName" required="false" default="" type="string" hint="The optional property name to pass the bean into. Defaults to the bean name if not provided.">
	<cfscript>
		var buildError = StructNew();
		
		try {
			// Call the addTransient method from the extended BaseConfigObject in Lightwire
			Super.addConstructorDependency(argumentCollection=arguments);
		}
		catch( Any e ) {
			// Build the Error Struct
			buildError.args = arguments;
			buildError.details = e;
			// Log the Error struct and add it to the ADF buildErrors Array 
			doConfigBuildErrorLogging("addConstructorDependency",buildError);
		}
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$getComPathForCustomAppDir
	Summary:
		Return the com path for the directory path
	Returns:
		String - COM path for the custom app
	Arguments:
		String - dirPath - Custom App directory path
	History:
		2009-08-19 - MFC - Created
		2010-04-06 - MFC - Code cleanup.
--->
<cffunction name="getComPathForCustomAppDir" access="public" returntype="string" output="true" hint="Return the com path for the directory path.">
	<cfargument name="dirPath" type="string" required="true">
	
	<cfscript>
		// Get the '/ADF/apps' mapping path
		var ADFAppMapping = expandPath("/ADF/apps");
		// Replace the mapping path in the argument path
		var currPath = Replace(arguments.dirPath, ADFAppMapping, "");
		// Get out the APP directory Name
		var appDirName = ListFirst(ReplaceList(currPath, "\,/",".,."), ".");
		// Build the component path
		var retComPath = "ADF.apps." & appDirName & ".components.";
	</cfscript>
	<cfreturn retComPath>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$loadADFAppBeanConfig
	Summary:
		Searches the ADF to find "appBeanConfig.cfm". 
		These commands are included into the base ADF to create the objects
			for the custom application.
	Returns:
		Void
	Arguments:
		String - path
	History:
		2009-05-11 - MFC - Created
		2011-01-21 - GAC - Modified to add error logging around the cfinclude
		2011-02-09 - GAC - Removed self-closing CF tag slashes
		2011-05-13 - MFC - Set the expand path variable outside of the CFLOOP
		2011-07-11 - MFC/AW - Updated AppConfig path building.
--->
<cffunction name="loadADFAppBeanConfig" returntype="void" access="public" output="true" hint="Loads the custom apps bean config file.">
	<cfargument name="path" type="string" required="false" default="\ADF\apps\">
	
	<cfscript>
		var appLibDirQry = QueryNew("temp");
		var retFilteredQry = QueryNew("temp");
		var i = 1;
		var dirPath = '';
		var expPath = ExpandPath(arguments.path);
		var target = '';
		var appComPath = '';
		
		// Recurse the custom app directory
		appLibDirQry = directoryFiles(arguments.path, "true");
		// Query the results to find the 'appBeanConfig.cfm' files
		retFilteredQry = filterQueryByCFCFile(appLibDirQry, 'appBeanConfig.cfm');
	</cfscript>

	<!--- Build the appBeanConfig include statements --->
	<cfloop index="i" from="1" to="#retFilteredQry.RecordCount#">
		<cfscript>
			dirPath = Replace(retFilteredQry.directory[i], expPath, "");
			target = Replace('#arguments.path##dirPath#/#retFilteredQry.name[i]#', '\', '/', 'all');
			appComPath = getComPathForCustomAppDir(dirPath);
		</cfscript>
		<cftry>
			<!--- // Include the the appBeanConfig file from each app --->
			<cfinclude template="#target#">
			<cfcatch>
				<!--- // Build the Error Struct --->
				<cfset buildError.appBeanConfigPath = appBeanConfigPath>
				<!--- <cfset buildError.args = arguments> --->
				<cfset buildError.details = cfcatch>
				<!--- // Log the Error struct and add it to the ADF buildErrors Array --->
				<cfset doConfigBuildErrorLogging("loadADFAppBeanConfig",buildError)>
			</cfcatch>
		</cftry>
	</cfloop>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$loadADFLibComponents
	Summary:
		Loads the ADF Library components from the directory argument.
	Returns:
		Void
	Arguments:
		String - directoryPath - Directory path to load the component files
		String - excludeSubDirs - List of sub directory names to exclude
	History:
		2009-05-11 - MFC - Created
		2010-04-06 - MFC - Code cleanup.
--->
<cffunction name="loadADFLibComponents" returntype="void" access="public" output="true" hint="Creates Singletons for all components in directory argument.">
	<cfargument name="directoryPath" type="string" required="true">
	<cfargument name="excludeSubDirs" type="string" required="false" default="">
	<cfargument name="objFactoryType" type="string" required="false" default="server">
		
	<cfscript>
		var cfcPath = arguments.directoryPath;
		var excludeDirs = Replace(arguments.excludeSubDirs,"/","","all");
		var appLibDirQry = QueryNew("tmp");
		var CFCFilesQry = QueryNew("tmp");
		var loop_i = 1;
		var beanData = StructNew();
		var dirName = "";
		
		// check if the cfcPath has a leading "/"
		if ( LEFT(cfcPath,1) NEQ "/" )
			cfcPath = "/" & cfcPath;
	
		// Recurse the custom app directory
		appLibDirQry = directoryFiles(cfcPath, "true");
		// filter the app lib directory query for CFC files
		CFCFilesQry = filterQueryByCFCFile(appLibDirQry,'%.cfc');
		// filter the app lib directory to remove any Application.cfc files
		CFCFilesQry = filterQueryByCFCFile(CFCFilesQry, "Application.cfc", "!=");
		// loop over the query and build the bean objects
		for (loop_i = 1; loop_i LTE CFCFilesQry.RecordCount; loop_i = loop_i + 1) {
			// get the current records sub directory name
			dirName = ListFirst(Replace(CFCFilesQry.directory[loop_i],expandpath(cfcPath),"","all"),"/");
			// check if sub directory name is in our exclude list
			if ( NOT ListFindNoCase(excludeDirs,dirName) ){
				// Create the bean data to store in the array
				beanData = buildBeanDataStruct(CFCFilesQry.directory[loop_i], CFCFilesQry.name[loop_i]);			
				processMetadata(beanData, arguments.objFactoryType);
			}
		}
		// load the dependencies created from processMetadata
		loadDependencies(arguments.objFactoryType);
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$processMetadata
	Summary:
		Process the component metadata property tags to create the beans and dependencies.
	Returns:
		Void
	Arguments:
		Struct - beanData - Bean data structure
	History:
		2009-06-05 - MFC - Created
		2010-04-06 - MFC - Code cleanup.
		2011-02-09 - RAK - Var'ing un-var'd items
--->
<cffunction name="processMetadata" access="private" returntype="void">
	<cfargument name="beanData" type="struct" required="true">
	<cfargument name="objFactoryType" type="string" required="false" default="server">
	<cfscript>
		var tmpStruct = "";
		var injected = 0;
		var metadata = getMetaData(CreateObject("component", arguments.beanData.cfcPath));
		var i = 1;
		var keys = "";
		var properties = arrayNew(1);
		if( structKeyExists(metadata, "properties") )
			properties = metadata.properties;

		// Loop over the properties
		for (i=1; i LTE ArrayLen(properties); i=i+1){
			keys = StructKeyList(properties[i]);
			// Check that the record has a name key
			if ( ListFindNoCase(keys,"name") and listFindNoCase(keys, "value") ){
				if (properties[i]["name"] EQ "type"){
					if ( properties[i]["value"] EQ "singleton" ) {
						addSingleton(arguments.beanData.cfcPath, arguments.beanData.beanName);					
						injected = 1;
					}
					else if ( properties[i]["value"] EQ "transient" ) {
						addTransient(arguments.beanData.cfcPath, arguments.beanData.beanName);					
						injected = 1;
					}
				}
				
				// Update the lib component struct
				if ( arguments.objFactoryType EQ "server" )
					StructInsert(server.ADF.library, ListFirst(beanData.cfcname,"_"), arguments.beanData.beanName, true);
				else
					StructInsert(application.ADF.library, ListFirst(beanData.cfcname,"_"), arguments.beanData.beanName, true);
			}
			// Check that the record has a name key
			if ( ListFindNoCase(keys,"type") AND (properties[i]["type"] EQ "dependency") ){				
				tmpStruct = StructNew();
				tmpStruct.BeanName = arguments.beanData.beanName;
				tmpStruct.InjectedBeanName = properties[i]["injectedBean"];
				tmpStruct.PropertyName = properties[i]["name"];
				if ( arguments.objFactoryType EQ "server" )
					StructInsert(server.ADF.dependencyStruct, "#arguments.beanData.beanName#:#properties[i]['name']#", tmpStruct, true);
				else
					StructInsert(application.ADF.dependencyStruct, "#arguments.beanData.beanName#:#properties[i]['name']#", tmpStruct, true);
			}
		}
		// if it was not injected then assume it is a transient
		if( not injected )
			addTransient(arguments.beanData.cfcPath, arguments.beanData.beanName);
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$loadDependencies
	Summary:
		Process the server.ADF.dependencyStruct structure to generate the dependencies.
	Returns:
		Void
	Arguments:
		Struct - beanData - Bean data structure
	History:
		2009-05-15 - MFC - Created
		2010-04-06 - MFC - Code cleanup.
		2011-02-09 - RAK - Var'ing un-var'd items
--->
<cffunction name="loadDependencies" access="private" returntype="void">
	<cfargument name="objFactoryType" type="string" required="false" default="server">
	<cfscript>
		var appBeanStruct = '';
		var beanPath = '';
		var beanData = '';
		var i = 1;
		var keys = "";
		var currRecord = StructNew();

		if ( arguments.objFactoryType EQ "server" )
			keys = StructKeyList(server.ADF.dependencyStruct);
		else
			keys = StructKeyList(application.ADF.dependencyStruct);
			
		for (i=1; i LTE ListLen(keys); i = i + 1) {
			if ( arguments.objFactoryType EQ "server" )
			{
				currRecord = server.ADF.dependencyStruct[ListGetAt(keys, i)];
			}
			else
			{
				currRecord = application.ADF.dependencyStruct[ListGetAt(keys, i)];
				// Copy dependencies from server to application
				appBeanStruct = server.ADF.beanConfig.getConfigStruct();
				// Get the path info for the dependency bean
				beanPath = appBeanStruct[currRecord.InjectedBeanName].path;
				// Remove the last item in the path b/c it is the file name
				beanPath = ListDeleteAt(beanPath, ListLen(beanPath, "."), ".");
				// Create the bean data to store in the array
				beanData = buildBeanDataStruct(beanPath, currRecord.InjectedBeanName);			
				// Load the bean into the object factory
				processMetadata(beanData, arguments.objFactoryType);
			}
		
			addMixinDependency(currRecord.BeanName, currRecord.InjectedBeanName, currRecord.PropertyName);
		}
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$addConfigStruct
	Summary:
		Stores the config struct into the config for the object factory.
	Returns:
		Void
	Arguments:
		String - beanName
		Struct - configStruct
	History:
		2009-08-07 - MFC - Created
--->
<cffunction name="addConfigStruct" access="public" returntype="void" hint="Stores the config struct into the config for the object factory.">
	<cfargument name="beanName" type="string" required="true">
	<cfargument name="configStruct" type="struct" required="true">
	
	<cfscript>
		variables.config[arguments.beanName] = arguments.configStruct;
	</cfscript>

</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$loadSiteComponents
	Summary:
		Process the site level components into the object factory.
	Returns:
		Void
	Arguments:
		Void
	History:
		2009-06-05 - MFC - Created
		2010-04-06 - MFC - Code cleanup.
		2011-02-09 - RAK - Var'ing un-var'd items
--->
<cffunction name="loadLocalComponents" access="public" returntype="void" hint="Process the site level components into the object factory.">
	<cfscript>
		// Get the sites for this server
		var siteComponents = '';
		var j = 1;
		var siteComponentsDir = QueryNew("temp");
		var siteComponentsFiles = QueryNew("temp");
		var beanData = StructNew();
		var comPath = "#request.site.CSAPPSURL#components/";

		// Check if there is a 'components' directory in the site
		if ( directoryExists(expandPath(comPath)) ){
			siteComponents = directoryFiles(comPath, "true");			
			siteComponentsFiles = filterQueryByCFCFile(siteComponents, '%.cfc');

			// Loop over the component files and create transients
			for (j = 1; j LTE siteComponentsFiles.RecordCount; j = j + 1) {
				cfcName = ListFirst(siteComponentsFiles.name[j],'.');
				application.ADF.siteComponents = ListAppend(application.ADF.siteComponents, cfcName);
				beanData = buildBeanDataStruct("#request.site.CSAPPSURL#components", cfcName);
				// Add the transient object
				addTransient(beanData.cfcPath, beanData.beanName);
			}
		}
	</cfscript>
</cffunction>



<!--- UTILITY FUNCTIONS --->

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$directoryFiles
	Summary:
		Returns the files for the directory
	Returns:
		Query - Directory files
	Arguments:
		String - Directory path
		String - Recurse Value
	History:
		2009-05-11 - MFC - Created
--->
<cffunction name="directoryFiles" returntype="query" access="private" output="true" hint="Returns the files for the directory.">
	<cfargument name="dirPath" type="string" required="true" default="\ADF\lib\com">
	<cfargument name="recurse" type="string" required="false" default="false">
	
	<cfset var dirQry = QueryNew("tmp")>
	<!--- recurse the custom app directory --->
	<cfdirectory action="list" directory="#ExpandPath(arguments.dirPath)#" name="dirQry" recurse="#arguments.recurse#">
	<cfreturn dirQry>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$filterQueryByCFCFile
	Summary:
		Filters the query to find the CFC file name
	Returns:
		Query
	Arguments:
		Query - dirQuery - Query to filter
		String - whereCondValue
		String - whereOperator
	History:
		2009-05-11 - MFC - Created
--->
<cffunction name="filterQueryByCFCFile" access="private" returntype="query" output="false" hint="Filters the query to find the CFC file name.">
	<cfargument name="dirQuery" type="query" required="true">
	<cfargument name="whereCondValue" type="string" required="true">
	<cfargument name="whereOperator" type="string" required="false" default="LIKE">
	
	<cfset var retFilteredQry = QueryNew("temp")>
	
	<!--- query the results to find the 'appBeanConfig.cfm' files --->
	<cfquery name="retFilteredQry" dbtype="query">
		SELECT 		Directory, Name, Type
		FROM 		arguments.dirQuery
		WHERE 		Type = 'File'
		AND 		UPPER(Name) #whereOperator# <cfqueryparam cfsqltype="cf_sql_varchar" value="#UCASE(arguments.whereCondValue)#">
		ORDER BY 	Directory, Name
	</cfquery>
	
	<cfreturn retFilteredQry>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$buildBeanDataStruct
	Summary:
		Builds the Bean Data Struct with formatted data to create singletons and dependencies
	Returns:
		Struct - Bean data struct
	Arguments:
		String - cfcPath - Path to the cfc
		String - cfcName - Name of the component for the bean
		String - beanNamePrefix - Prefix to the name of the custom app bean config
	History:
		2009-05-11 - MFC - Created
		2010-11-29 - MFC - Removed commented code.
--->
<cffunction name="buildBeanDataStruct" access="public" returntype="struct" output="true" hint="Builds the Bean Data Struct with formatted data to create singletons and dependencies.">
	<cfargument name="cfcPath" type="string" required="true" default="">
	<cfargument name="cfcName" type="string" required="true" default="">
	<cfargument name="beanNamePrefix" type="string" required="false" default="">
	<cfscript>
		// initialize the return bean data struct
		var retBeanData = StructNew();
		retBeanData.cfcPath = "";
		retBeanData.cfcName = "";
		retBeanData.beanName = "";

		retBeanData.cfcPath =  processCFCPath(arguments.cfcPath);
		retBeanData.cfcName = ListFirst(arguments.cfcName, ".");
		retBeanData.cfcPath = "#retBeanData.cfcPath##retBeanData.cfcName#";
		// Store that bean data	
		retBeanData.beanName = "#arguments.beanNamePrefix##retBeanData.cfcName#";
		return retBeanData;
	</cfscript>
</cffunction>

<!---
	/* *************************************************************** */
	Author: 	M. Carroll
	Name:
		$processCFCPath
	Summary:
		Returns the CFC path for the component relative to the ADF or site name for the full directory path.
	Returns:
		String - Com Path relative to the ADF or site name.
	Arguments:
		String - dirPath - Directory Path
	History:
		2009-10-19 - MFC - Created
		2010-03-29 - MFC/GAC - Restructured for correct request variables and paths.
		2010-10-20 - RLW - fixed bug that required the ADF to be installed in a directory named "ADF"
		2010-11-23 - RLW - fixed bug loading the site level ADF components overrides (/cs_apps/lib/)
		2010-12-08 - RAK - Fixing bug loading site component overrides (/_cs_apps/lib)
										added expandPath and changed hardcoded var to request.site.csAppsURL
--->
<cffunction name="processCFCPath" access="private" returntype="string" hint="Returns the CFC path for the component relative to the ADF or site name for the full directory path.">
	<cfargument name="dirPath" type="string" required="true">
	<cfscript>
		var retComPath = arguments.dirPath;
		// get the real path to the ADF
		var ADFPath = expandPath('/ADF');
		var csAppsPath = expandPath(request.site.csAppsURL);

		// process the ADF components
		if( findNoCase(ADFPath, retComPath) ) {
			retComPath = mid(retComPath, findNoCase(ADFPath, retComPath) + len(ADFPath), len(retComPath));			// add ADF back in
			retComPath = "/ADF" & retComPath;
		}// process the site level components
		else if ( FINDNOCASE(csAppsPath, retComPath) ){
			retComPath = mid(retComPath, findNoCase(csAppsPath, retComPath) + len(csAppsPath), len(retComPath));
			retComPath = request.site.csAppsURL & retComPath;
		}
		
		// Replace the slashes in the list to periods to support CFC notation
		retComPath = ReplaceList(retComPath, "\,/", ".,.");

		// Trim the first character to make sure doesn't start with "."
		if ( LEFT(retComPath, 1) EQ "." )
			retComPath = REPLACE(retComPath, ".", "");
		// Check if the cfc path ends in "."
		if ( RIGHT(retComPath, 1) NEQ "." )
			retComPath = retComPath & ".";
	</cfscript>
	<cfreturn retComPath>
</cffunction>

<!---
	/* ***************************************************************
	/*
	Author: 	G. Cronkright
	Name:
		doBuildErrorLogging
	Summary:
		Create a Log file for the given error and add the error struct to the Application.ADF.buildErrors Array
	Returns:
		Boolean
	Arguments:
		String - meathodName
	History:
		2011-01-21 - GAC - Created
--->
<cffunction name="doConfigBuildErrorLogging" access="public" returntype="void">
	<cfargument name="methodName" type="string" required="false" default="GenericBuild">
	<cfargument name="errorDetailsStruct" type="struct" required="false" default="#StructNew()#">
	<cfscript>
		var dump = "";
		var logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & ".ADF_" & arguments.methodName & "_Errors.htm";
		var errorStruct = arguments.errorDetailsStruct;	
		// Add the methodName to the errorStruct
		errorStruct.ADFmethodName = arguments.methodName;
	</cfscript>
	<!--- // Package the error dump and write it to a html file in the logs directory --->
	<cfsavecontent variable="dump">
		<cfdump var="#errorStruct#" label="#arguments.methodName# Error" expand="false">
	</cfsavecontent>
	<cffile action="append" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #dump#" addnewline="true">
	<cfscript>
		// Add the errorStruct to the server.ADF.buildErrors Array 
		ArrayAppend(server.ADF.buildErrors,errorStruct);
	</cfscript>
</cffunction>

</cfcomponent>