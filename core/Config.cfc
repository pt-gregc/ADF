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
Author: 	
	PaperThin, Inc. 
Name:
	Config.cfc
Summary:
	Config component for Custom Application Common Framework
History:
	2009-05-11 - MFC - Created
--->
<cfcomponent name="Config" hint="Config component for Application Development Framework" extends="ADF.core.Base">

<cfproperty name="version" value="1_0_0">
<!--- 
	TODO determine if a.) Config should be versioned and b.) if we should allow for injection
<cfproperty type="dependency" name="ceData" injectedBean="ceData_1_0"> --->
	
<!---
	/* ***************************************************************
	/*
	Author: 	Ron West
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
	--->
<cffunction name="getConfigViaXML" access="public" returntype="struct" output="true">
	<cfargument name="filePath" type="string" required="true">
	<cfscript>
		var configStruct = StructNew();
		var configXML = "";
		var configPath = arguments.filePath;
		var isConfigCFM = false;
	 
		if ( ListLast(arguments.filePath,".") IS "cfm" ) {
			configPath = ExpandPath(arguments.filePath);
			isConfigCFM = true;
		}
	</cfscript>
	
	<!--- //check if the file exists --->
	<cfif fileExists(configPath)>
		<cfif isConfigCFM>
			<!--- // include the CFM config file --->
			<cfinclude template="#arguments.filePath#">
			<cfset configXML=toString(configXML)>
		<cfelse>
			<!--- // read the XML config file --->
			<cffile action="read" file="#arguments.filePath#" variable="configXML">
		</cfif>
		<cftry>
			<cfset configStruct = Server.CommonSpot.MapFactory.deserialize(configXML)>
			<cfcatch>
				<!--- // TODO: this needs some error catching --->
				<!--- <cfdump var="#cfcatch#" lablel="cfcatch" expand="false"> --->
			</cfcatch>
		</cftry>
	</cfif>
	<cfreturn configStruct>
</cffunction>

<!---
	/* ***************************************************************
	/*
	Author: 	Ron West / M. Carroll
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
		2009-08-06 - RLW - Created
	--->
<cffunction name="getConfigViaElement" access="public" returntype="struct">
	<cfargument name="appName" type="string" required="true">
	
	<cfscript>
		var configStruct = structNew();
		var configElementQry = getConfigurationCE(arguments.appName);
		var ceData = server.ADF.objectFactory.getBean("ceData_1_0");
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
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$searchConfigurationCE
Summary:
	Returns the sites sustom elements that have the title ending in 'Configuration'
Returns:
	Query
Arguments:
	String - CE Name search string
History:
	2009-08-06 - MFC - Created
--->
<cffunction name="getConfigurationCE" access="private" returntype="query">
	<cfargument name="appName" type="string" required="true">
	
	<!--- Initialize the variables --->
	<cfset var getCE = QueryNew("temp")>
	<!--- Query to get the data for the custom element by pageid --->
	<cfquery name="getCE" datasource="#request.site.datasource#">
		SELECT 	ID, FormName
		FROM 	FormControl
		WHERE 	((FormName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.appName#_Configuration">) OR (FormName LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.appName# Configuration">))
		AND 	(FormControl.action = '' OR FormControl.action is null)
	</cfquery>
	<cfreturn getCE>
</cffunction>

</cfcomponent>
