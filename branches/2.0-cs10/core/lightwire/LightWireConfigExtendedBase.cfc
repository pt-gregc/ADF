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
	LightWireConfigExtendedBase.cfc
Summary:
	LightWire Configuration component extended from the Base.cfc.
History:
	2009-08-14 - MFC - Created
	2011-07-11 - MFC/AW - Updated Init and loadADFAppBeanConfig for performance improvements.
	2012-12-26 - MFC - Updated the logging for the v1.6.
	2013-10-21 - GAC - Added 'file-version' property for ADF core files 
	2014-02-26 - GAC - Updated for version 1.7.0
	2014-03-24 - GAC - Added doLog and doOutput local private function to assit with debugging
	2014-10-07 - GAC - Updated for version 1.8.0
--->
<cfcomponent name="LightWireConfigExtendedBase" extends="ADF.thirdParty.lightwire.BaseConfigObject" output="false">

<cfproperty name="version" value="2_0_0">
<cfproperty name="file-version" value="3">

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
Author: 	
	PaperThin, Inc.
	G. Cronkright
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
Author: 	
	G. Cronkright
	PaperThin, Inc.
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
Author: 	
	G. Cronkright
	PaperThin, Inc.
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
Author: 	
	PaperThin, Inc.
	M. Carroll
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
Author: 
	PaperThin, Inc.	
	M. Carroll
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
	2013-02-26 - MFC - Updated comments to make sure the "appComPath" variable is not removed.
	2014-03-05 - JTP - Var declarations
	2014-03-07 - GAC - Updated the var'd buildError variable to init as a Structure 
--->
<cffunction name="loadADFAppBeanConfig" returntype="void" access="public" output="true" hint="Loads the custom apps bean config file.">
	<cfargument name="path" type="string" required="false" default="/ADF/apps/">
	
	<cfscript>
		var appLibDirQry = QueryNew("temp");
		var retFilteredQry = QueryNew("temp");
		var i = 1;
		var dirPath = '';
		var expPath = ExpandPath(arguments.path);
		var target = '';
		var appComPath = '';
		var buildError = StructNew();
		
		// Recurse the custom app directory
		appLibDirQry = directoryFiles(arguments.path, "true");
		// Query the results to find the 'appBeanConfig.cfm' files
		retFilteredQry = filterQueryByCFCFile(appLibDirQry, 'appBeanConfig.cfm');
	</cfscript>

	<!--- Build the appBeanConfig include statements --->
	<cfloop index="i" from="1" to="#retFilteredQry.RecordCount#">
		<cftry>
			<cfscript>
				dirPath = Replace(retFilteredQry.directory[i], expPath, "");
				target = Replace('#arguments.path##dirPath#/#retFilteredQry.name[i]#', '\', '/', 'all');
				// This is needed for the cfinclude below
				appComPath = getComPathForCustomAppDir(dirPath);
			</cfscript>
			<!--- // Include the the appBeanConfig file from each app --->
			<cfinclude template="#target#">
			<cfcatch>
				<!--- // Build the Error Struct --->
				<cfset buildError.appBeanConfigPath = target>
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
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$loadADFLibComponents
Summary:
	Loads the ADF Library components from the directory argument.
Returns:
	Void
Arguments:
	String - directoryPath - Directory path to load the component files
	String - excludeSubDirs - List of sub directory names to exclude
	String - objFactoryType - Type of objectFactory - Default: server 
History:
	2009-05-11 - MFC - Created
	2010-04-06 - MFC - Code cleanup.
	2014-03-19 - JTP - Add logic to not process dependencies for any site-level overrides in /_cs_apps/lib directory
	2014-03-24 - GAC - Added logic to the loadDependencies to allow the dependency files 
	                   to use the LIB override versions if the exist
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
		var dirPath = "";
		var overrideLibPath = false;
		
		// check if the cfcPath has a leading "/"
		if ( LEFT(cfcPath,1) NEQ "/" )
			cfcPath = "/" & cfcPath;

		if ( FindNoCase( request.site.CSAPPSURL & "lib", cfcPath ) )	
			overrideLibPath = true;
			
		// Recurse the custom app directory
		appLibDirQry = directoryFiles(cfcPath, "true");
		// filter the app lib directory query for CFC files
		CFCFilesQry = filterQueryByCFCFile(appLibDirQry,'%.cfc');
		// filter the app lib directory to remove any application.cfc files
		CFCFilesQry = filterQueryByCFCFile(CFCFilesQry, "application.cfc", "!=");
		
		// loop over the query and build the bean objects
		for (loop_i = 1; loop_i LTE CFCFilesQry.RecordCount; loop_i = loop_i + 1) 
		{
			// get the current records sub directory name
			dirPath = CFCFilesQry.directory[loop_i];
			//dirPath = Replace(CFCFilesQry.directory[loop_i],"\","/","all");

			dirName = ListFirst(Replace(dirPath,expandpath(cfcPath),"","all"),"/");
			
			// check if sub directory name is in our exclude list
			if ( NOT ListFindNoCase(excludeDirs,dirName) )
			{
				//dirPath = Replace(CFCFilesQry.directory[loop_i],"\","/","all");
				
				// Create the bean data to store in the array
				beanData = buildBeanDataStruct(dirPath, CFCFilesQry.name[loop_i]);			
				processMetadata(beanData, arguments.objFactoryType);

				dirPath = processCFCPath(dirPath=dirPath);
			}
		}

		// load the dependencies created from processMetadata
		//if ( FindNoCase( '_cs_apps/lib', cfcPath ) )
		//if ( overrideLibPath )
		//	loadDependencies(objFactoryType=arguments.objFactoryType,libType='site',overridePath=cfcPath);
		//else
		
		loadDependencies(objFactoryType=arguments.objFactoryType);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	M. Carroll
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
	2012-07-09 - MFC - Added TRY-CATCH error handling for if processing the metadata form fails.
	2012-12-26 - MFC - Replaced CFSCRIPT TRY-CATCH with CF tagged based TRY-CATCH.
--->
<cffunction name="processMetadata" access="private" returntype="void">
	<cfargument name="beanData" type="struct" required="true">
	<cfargument name="objFactoryType" type="string" required="false" default="server">

	<cfscript>
		var tmpStruct = "";
		var injected = 0;
		var metadata = "";
		var i = 1;
		var keys = "";
		var properties = arrayNew(1);
		var errorMessage = "";
	</cfscript>
	
	<cftry>
		<cfscript>
			metadata = getMetaData(CreateObject("component", arguments.beanData.cfcPath));
			
			if( structKeyExists(metadata, "properties") )
				properties = metadata.properties;
	
			// Loop over the properties
			for (i=1; i LTE ArrayLen(properties); i=i+1){
				keys = StructKeyList(properties[i]);
				// Check that the record has a name key
				if ( ListFindNoCase(keys,"name") and listFindNoCase(keys, "value") )
				{
					if (properties[i]["name"] EQ "type"){
						if ( properties[i]["value"] EQ "singleton" ) 
						{
							addSingleton(arguments.beanData.cfcPath, arguments.beanData.beanName);					
							injected = 1;
						}
						else if ( properties[i]["value"] EQ "transient" ) 
						{
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
				if ( ListFindNoCase(keys,"type") AND (properties[i]["type"] EQ "dependency") )
				{				
					tmpStruct = StructNew();
					tmpStruct.BeanName = arguments.beanData.beanName;
					tmpStruct.InjectedBeanName = properties[i]["injectedBean"];
					tmpStruct.PropertyName = properties[i]["name"];
					tmpStruct.BeanPath =  arguments.beanData.cfcPath;
					
					// Add bean and dependancies to the dependencyStruct for the Server.ADF or the site's Application.ADF'
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
		<cfcatch>
			<cfscript>
				// Build the CF error string to throw
				errorMessage = "Error processing the metadata for the component [#arguments.beandata.CFCPath#]";
				if ( StructKeyExists(cfcatch, "message") )
					errorMessage = errorMessage & "[CF Error Message = #cfcatch.message#]";
				if ( StructKeyExists(cfcatch, "TagContext")
						AND isArray(cfcatch.TagContext)
						AND ArrayLen(cfcatch.TagContext) ){
					
					errorMessage = errorMessage & "[Template = #cfcatch.TagContext[1].template#] [Line = #cfcatch.TagContext[1].line#]";
				}
				
				// Build the Error Struct
				buildError.args = arguments;
				buildError.details = cfcatch;
				doConfigBuildErrorLogging("processMetadata",buildError);	
			</cfscript>
			<cfthrow message="#errorMessage#" detail="#errorMessage#">
		</cfcatch>
	</cftry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
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
	2014-03-24 - GAC - Updated to check for local override Lib components when building Lib dependencies
--->
<cffunction name="loadDependencies" access="private" returntype="void">
	<cfargument name="objFactoryType" type="string" required="false" default="server">
	<!--- <cfargument name="libType" type="string" required="false" default="adf" hint="options: adf,app,site"> --->
	<!--- <cfargument name="overridePath" type="string" required="false" default=""> --->
	
	<cfscript>
		var appBeanStruct = '';
		var beanPath = '';
		var beanData = '';
		var i = 1;
		var keys = "";
		var currRecord = StructNew();
		var useOverrideBean = false;
		var	siteBeanDir = "";
		var siteBeanComPath = "";
		var siteBeanFilePath = "";

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
				
				// Check to see if there is a override version of this
				siteBeanDir = request.site.CSAPPSURL & "lib";
				//siteBeanFilePath = siteBeanDir & "/" & currRecord.BeanName & ".cfc";
				siteBeanComPath = siteBeanDir & "/" & currRecord.InjectedBeanName;
				siteBeanFilePath = siteBeanComPath & ".cfc";
				
				// Check if Library item has a site level override
				useOverrideBean = false;	
				if ( FileExists(ExpandPath(siteBeanFilePath)) )
					useOverrideBean = true;					
				
				if ( useOverrideBean )
				{
					// If the Bean has a local override file then use the overridePath for the bean path
					beanPath = siteBeanDir;	
				}
				else 
				{
					// Copy dependencies from server to application
					appBeanStruct = server.ADF.beanConfig.getConfigStruct();
					// Get the path info for the dependency bean
					beanPath = appBeanStruct[currRecord.InjectedBeanName].path;
					// Remove the last item in the path b/c it is the file name
					beanPath = ListDeleteAt(beanPath, ListLen(beanPath, "."), ".");	
				}	
									
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
Author: 
	PaperThin, Inc.	
	M. Carroll
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
Author: 
	PaperThin, Inc.	
	M. Carroll
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
	2014-03-05 - JTP - Var declarations
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
		var cfcName = '';

		// Check if there is a 'components' directory in the site
		if ( directoryExists(expandPath(comPath)) )
		{
			siteComponents = directoryFiles(comPath, "true");			
			siteComponentsFiles = filterQueryByCFCFile(siteComponents, '%.cfc');

			// Loop over the component files and create transients
			for (j = 1; j LTE siteComponentsFiles.RecordCount; j = j + 1) 
			{
				cfcName = ListFirst(siteComponentsFiles.name[j],'.');
				application.ADF.siteComponents = ListAppend(application.ADF.siteComponents, cfcName);
				beanData = buildBeanDataStruct("#request.site.CSAPPSURL#components", cfcName);
				// Add the transient object
				addTransient(beanData.cfcPath, beanData.beanName);
			}
		}
	</cfscript>
</cffunction>

<!--- // UTILITY FUNCTIONS --->

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
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
	<cfargument name="dirPath" type="string" required="true">
	<cfargument name="recurse" type="string" required="false" default="false">
	
	<cfset var dirQry = QueryNew("tmp")>
	<!--- recurse the custom app directory --->
	<cfdirectory action="list" directory="#ExpandPath(arguments.dirPath)#" name="dirQry" recurse="#arguments.recurse#">
	<cfreturn dirQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
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
Author: 	
	PaperThin, Inc.
	M. Carroll
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
	2014-03-05 - JTP - Var declarations
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
Author: 	
	PaperThin, Inc.
	M. Carroll
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
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	doBuildErrorLogging
Summary:
	Create a Log file for the given error and add the error struct to the application.ADF.buildErrors Array
Returns:
	Boolean
Arguments:
	String - meathodName
	Struct - errorDetailsStruct
	Boolean - addBuildErrors
History:
	2011-01-21 - GAC - Created
	2014-03-20 - GAC - Added parameter to allow to be used for debugging and not just error logging
				 	 - Updated the build struct to allow clearer display of the error detials
					 - Removed invalid filename characters when using the methodName as filename or lockname
	2014-03-24 - GAC - Moved the log file create process to its own local private method doLog
--->
<cffunction name="doConfigBuildErrorLogging" access="public" returntype="void" hint="Create a Log file for the given error and add the error struct to the application.ADF.buildErrors Array">
	<cfargument name="methodName" type="string" required="false" default="GenericBuild" hint="methodName to log">
	<cfargument name="errorDetailsStruct" type="struct" required="false" default="#StructNew()#" hint="Error details to log">
	<cfargument name="addBuildErrors" type="boolean" required="false" default="true" hint="Append error output to ADF build errors output.">
	
	<cfscript>
		var errorDumpStr = "";
		var safeMethodName = REReplaceNoCase(arguments.methodName,"[\W]","","ALL");
		//var logFileName = dateFormat(now(), "yyyymmdd") & "." & request.site.name & ".ADF_" & safeMethodName & "_Errors.htm";
		var logFileName = ".ADF_" & safeMethodName & "_Errors.htm";
		var errorStruct = StructNew();	
		
		// Add the methodName to the errorStruct
		errorStruct.ADFmethodName = arguments.methodName;
		errorStruct.ErrorDetails = arguments.errorDetailsStruct;
	</cfscript>
	
	<!--- // Package the error dump and write it to a html file in the logs directory --->
	<cfsavecontent variable="errorDumpStr">
		<cfdump var="#errorStruct#" label="#arguments.methodName# Error" expand="false">
	</cfsavecontent>
	
	<cfset doLog(msg=errorDumpStr,logFile=logFileName)>
	<!--- <cflock timeout="30" throwontimeout="Yes" name="#safeMethodName#FileLock" type="EXCLUSIVE">
		<cffile action="append" file="#request.cp.commonSpotDir#logs/#logFileName#" output="#request.formattedtimestamp# - #errorDumpStr#" addnewline="true">
	</cflock> --->
	
	<cfscript>
		// Add the errorStruct to the server.ADF.buildErrors Array
		if ( arguments.addBuildErrors )
			ArrayAppend(server.ADF.buildErrors,errorStruct);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	G. Cronkright
Name:
	doConfigLog
Summary:
	A local private method to create cs formatted log files during the build process
Returns:
	Boolean
Arguments:
	Any - msg
	String - logFile
	Boolean - addTimeStamp
	String - logDir
	String - label
History:
	2014-03-24 - GAC - Created
--->
<!--- doLog(msg="foo",logFile="logFile.log") --->
<cffunction name="doLog" access="private" returntype="void" output="false" hint="A local private method to create cs formatted log files">
	<cfargument name="msg" type="any" required="true" hint="if this value is NOT a simple string then the value gets converted to sting output using CFDUMP">
	<cfargument name="logFile" type="string" required="false" default="ADF_log.log">
	<cfargument name="addTimeStamp" type="boolean" required="false" default="true" hint="Adds a date stamp to the file name">
	<cfargument name="logDir" type="string" required="false" default="#request.cp.commonSpotDir#logs/">
	<cfargument name="label" type="string" required="false" default="" hint="Adds a text label to the log entry">
	
	<cfscript>
		var logFileName = ListDeleteAt(arguments.logFile,ListLen(arguments.logFile,"."), ".");
		var logFileExt = ListLast(arguments.logFile,".");
		var safeLogName = REReplaceNoCase(logFileName,"[\W]","","ALL");
		var utcNow = mid(dateConvert('local2utc', now()), 6, 19);
		var logFileNameWithExt = request.site.name & "." & safeLogName & "." & logFileExt;
		
		if( arguments.addTimeStamp )
			logFileNameWithExt = dateFormat(now(), "yyyymmdd") & "." & logFileNameWithExt;
			
		if( len(arguments.label) )
			arguments.label = arguments.label & "-";
	</cfscript>
	
	<cflock timeout="30" throwontimeout="Yes" name="#safeLogName#FileLock" type="EXCLUSIVE">
		<cffile action="append" file="#arguments.logDir##logFileNameWithExt#" output="#utcNow# (UTC) - #arguments.label# #arguments.msg#" addnewline="true" fixnewline="true">
	</cflock>
	<!--- <cffile action="append" file="#arguments.logDir##logFileName#" output="#utcNow# (UTC) - #arguments.label# #arguments.msg#" addnewline="true" fixnewline="true"> --->
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.	
	G. Cronkright
Name:
	doOutput
Summary:
	A local private method to output debug data to the page during the build process
Returns:
	Boolean
Arguments:
	String - msg
	String - label
History:
	2014-03-24 - GAC - Created
--->
<!--- doOutput(msg="foo",label="bar") --->
<cffunction name="doOutput" access="private" returntype="void" output="true" hint="A local private method to output debug data to the page during the build process">
	<cfargument name="msg" type="any" required="true">
	<cfargument name="label" type="string" default="" required="false">
	<cfif IsSimpleValue(arguments.msg)>
	<cfoutput>
	<div><cfif LEN(TRIM(arguments.label))>#arguments.label#: </cfif>#arguments.msg#</div>                        
	</cfoutput>                                                                                                              
	<cfelse>
	<cfdump var="#arguments.msg#" label="#arguments.label#" expand="false">
	</cfif>
	<!--- <cfflush> --->
</cffunction>

</cfcomponent>
