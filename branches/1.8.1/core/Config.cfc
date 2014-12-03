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
	Config.cfc
Summary:
	Config component for Custom Application Common Framework
History:
	2009-05-11 - MFC - Created
	2011-04-05 - MFC - Updated the version property
	2013-10-21 - GAC - Added 'file-version' property for ADF core files 
	2014-02-26 - GAC - Updated for version 1.7.0
	2014-10-07 - GAC - Updated for version 1.8.0
--->
<cfcomponent name="Config" hint="Config component for Application Development Framework" extends="ADF.core.Base">

<cfproperty name="version" value="1_8_1">
<cfproperty name="file-version" value="3">
	
<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getConfigViaXML
Summary:	
	Returns the configuration of an application via XML
Returns:
	Struct configStruct
Arguments:
	String filePath
History:
	2009-05-17 - RLW - Created
	2009-11-19 - GAC - Modified to read a XML config values from an included .CFM file
	2011-03-20 - RLW - Modified to use the new deserializeXML function loaded into Base.
	2013-01-23 - MFC - Added ADF Build Error handling.
	2014-03-05 - JTP - Var declarations
	2014-12-03 - GAC - Updated to use the renamed deserializeXMLstring method due to conflict with new CF11 deserializeXML function
--->
<cffunction name="getConfigViaXML" access="public" returntype="struct" output="true">
	<cfargument name="filePath" type="string" required="true">
	<cfscript>
		var configStruct = StructNew();
		var configXML = "";
		var configPath = arguments.filePath;
		var isConfigCFM = false;
		var buildError = '';
	 
	 	// Check if the config is CFM
		if ( ListLast(arguments.filePath,".") EQ "cfm" ) 
		{
			// Set the expanded path for the config to run the file exists
			configPath = ExpandPath(arguments.filePath);
			isConfigCFM = true;
		}
	</cfscript>
	<!--- Check if the file exists --->
	<cfif fileExists(configPath)>
		<cfif isConfigCFM>
			<!--- // Include the CFM config file --->
			<cfinclude template="#arguments.filePath#">
			<cfset configXML=toString(configXML)>
		<cfelse>
			<!--- // read the XML config file --->
			<cffile action="read" file="#configPath#" variable="configXML">
		</cfif>
		<cftry>
			<cfset configStruct = deserializeXMLstring(XMLString=configXML)>
			<cfcatch>
				<!--- // TODO: this needs some error catching --->
				<!--- <cfdump var="#cfcatch#" lablel="cfcatch" expand="false"> --->
				<cfscript>
					// Build the Error Struct
					buildError.ADFmethodName = "Core Config";
					buildError.details = "Core Config deserialize XML Error. [#request.site.name# - #request.site.id#].";
					// Add the errorStruct to the server.ADF.buildErrors Array
					ArrayAppend(server.ADF.buildErrors,buildError);
				</cfscript>
			</cfcatch>
		</cftry>
	</cfif>
	<cfreturn configStruct>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getConfigViaElement
Summary:	
	Returns the configuration of a site via a Custom Element
	
	Note: The custom element must have the following naming configuration:
	"#appName# Configuration"
Returns:
	Struct configStruct
Arguments:
	String Custom Element Name
History:
	2009-08-06 - RLW/MFC - Created
	2014-04-10 - GAC - Updated the ceData Lib version
--->
<cffunction name="getConfigViaElement" access="public" returntype="struct">
	<cfargument name="appName" type="string" required="true">
	
	<cfscript>
		var configStruct = structNew();
		var configElementQry = getConfigurationCE(arguments.appName);
		var ceData = server.ADF.objectFactory.getBean("ceData_2_0");
		var configData = ceData.getCEData(configElementQry.formName);
		if ( arrayLen(configData) )
		{
			configStruct = configData[1].values;
			configStruct.dataPageID = configData[1].pageID;
			configStruct.formID = configElementQry.id;
		}
	</cfscript>
	<cfreturn configStruct>
</cffunction>

<!---
/* *************************************************************** */
Author: 
	PaperThin, Inc.
Name:
	$searchConfigurationCE
Summary:
	Returns the sites custom elements that have the title ending in 'Configuration'
Returns:
	Query
Arguments:
	String - CE Name search string
History:
	2009-08-06 - MFC - Created
	2010-06-30 - MFC - Updated to search on lower case form name.
						Resolved bug with Oracle DB.s
	2011-02-14 - MFC - Code clean up: Removed the tabs in the SQL statement, 
						removed QueryNew, cfscript block for variables.
--->
<cffunction name="getConfigurationCE" access="private" returntype="query">
	<cfargument name="appName" type="string" required="true">
	
	<!--- Initialize the variables --->
	<cfscript>
		var getCE = "";
		var ceConfigNameSpace = LCase(arguments.appName) & " configuration";
		var ceConfigNameUnderscore = LCase(arguments.appName) & "_configuration";
	</cfscript>
	
	<!--- Query to get the data for the custom element by form name --->
	<cfquery name="getCE" datasource="#request.site.datasource#">
		SELECT ID, FormName
		  FROM FormControl
		 WHERE ((LOWER(FormName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ceConfigNameUnderscore#">) 
		       OR (LOWER(FormName) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ceConfigNameSpace#">))
		   AND (FormControl.action = '' OR FormControl.action is null)
	</cfquery>
	<cfreturn getCE>
</cffunction>

</cfcomponent>
