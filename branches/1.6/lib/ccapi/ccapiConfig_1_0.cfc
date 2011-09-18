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
	ccapi.cfc
Summary:
	CCAPI functions for the ADF Library
Version:
	1.0.1
History:
	2009-06-17 - RLW - Created
	2010-02-18 - RLW - Changed web service object to use direct CF component call
	2011-01-25 - MFC - Update to v1.0.1. Updated dependency to Utils_1_1.
	2011-03-19 - RLW - Added dependency for ceData_1_1, forms_1_1, scripts_1_1 and csData_1_1
--->
<cfcomponent displayname="ccapiConfig" extends="ADF.core.Base" hint="CCAPI configuration">
	
<cfproperty name="version" value="1_0_">
<cfproperty name="CoreConfig" type="dependency" injectedBean="CoreConfig">
<cfproperty name="utils" type="dependency" injectedBean="utils_1_1">
<cfproperty name="ceData" type="dependency" injectedBean="ceData_1_1">
<cfproperty name="csData" type="dependency" injectedBean="csData_1_1">
<cfproperty name="forms" type="dependency" injectedBean="forms_1_1">
<cfproperty name="scripts" type="dependency" injectedBean="scripts_1_1">
<cfproperty name="wikiTitle" value="CCAPI Configuration">

<cfscript>
	// xml config info
	variables.CCAPIConfig = structNew();
	// CS Content Creation API settings
	variables.csUserId = "";
	variables.csPassword = "";
	variables.SSID = "";
	variables.siteURL = "";
	variables.webserviceURL = "";
	variables.subsiteID = "";
	// vars for elements and templates
	variables.elements = structNew();
	variables.templates = structNew();
	// custom element name for CCAPI config
	variables.configElementName = "CCAPI Configuration";
</cfscript>

<!--- // Utility functions for building and running WS --->

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadCCAPIConfig
Summary:	
	Using the CoreConfig object - loads up the current sites configuration
	for this application
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
	2009-11-19 - GAC - Modified to load a XML CCAPI config values from a ccapi.CFM file (if available)
	2010-03-05 - GAC - Removed the loggingEnabled() function call from the try/catch
	2011-03-19 - RLW - Added support for the Custom Element configuration
--->
<cffunction name="loadCCAPIConfig" access="public" returntype="void">
	<cfscript>
		var CCAPIConfig = StructNew();
		var configAppXMLPath = ExpandPath("#request.site.csAppsWebURL#config/ccapi.xml");
		var configAppCFMPath = request.site.csAppsWebURL & "config/ccapi.cfm";
		var configElementData = arrayNew(1);
		var CCAPIPageQry = queryNew("");
		var CCAPIPageID = 0;
		var tmpWSVars = structNew();
	</cfscript>
	<cftry>
		<cfscript>
			// config data should be loaded here
			// TODO: Need some error checking here
			// CCAPIConfig = server.ADF.environment[request.site.id].ccapi;
			
			// check to see if there is a custom element record for the config
			if( variables.ceData.elementExists(variables.configElementName) ){
				// get the data from the element
				ConfigElementData = variables.ceData.getCEData(variables.configElementName);
				if( arrayLen(configElementData) ){
					CCAPIConfig.logging = structNew();
					// check if logging is enabled
					if( len(configElementData[1].values.enableLogging) and configElementData[1].values.enableLogging eq 1 )
						CCAPIConfig.logging.enabled = true;
					else
						CCAPIConfig.logging.enabled = false;
					// set the data for the config element
					tmpWSVars.csUserID = configElementData[1].values.csUserID;
					tmpWSVars.csPassword = configElementData[1].values.csPassword;
					tmpWSVars.SSID = "";
					tmpWSVars.siteURL = "http://cfusion/demo";
					tmpWSVars.webserviceURL = "";
					tmpWSVars.subsiteID = "1";
					// set vars for WS call
					CCAPIConfig.wsVars = tmpWSVars;
					// process elements from element mapping
					if( structKeyExists(configElementData[1].values, "elements") and listLen(configElementData[1].values.elements) )
						CCAPIConfig.elements = getElementsFromElementMap();
					// process the elements dynamically based on registred CCAPI page
					if( len(ConfigElementData[1].values.CCAPIPage) ){
						// convert the CCAPIPage url into the pageID
						CCAPIPageQry = variables.csData.getCSPageDataByURL(ConfigElementData[1].values.CCAPIPage);
						if( CCAPIPageQry.recordCount ){
							CCAPIPageID = CCAPIPageQry.ID;
							CCAPIConfig.elements = getElementsFromCCAPIPage(CCAPIPageID);
						}
					}
				}
			}
			// Pass a Logical path for the CFM file to the getConfigViaXML() since it will be read via CFINCLUDE
			else if ( FileExists(ExpandPath(configAppCFMPath)) )
				CCAPIConfig = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configAppCFMPath);
			// Pass an Absolute path for the XML file to the getConfigViaXML() since it will be read via CFFILE
			else if ( FileExists(configAppXMLPath) )
				CCAPIConfig = server.ADF.objectFactory.getBean("CoreConfig").getConfigViaXML(configAppXMLPath);

			setCCAPIConfig(CCAPIConfig);
		</cfscript>
		<cfcatch>
			<cfscript>
				variables.utils.logAppend("Error loading CCAPI Config [#cfcatch.message#]. Its possible the config.cfm or config.xml file is not setup for this site [#request.site.name# - #request.site.id#].", "CCAPI_Errors.log");
			</cfscript>
		</cfcatch>
	</cftry>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	R. West
Name:
	$getElementsFromElementMap
Summary:
	Builds the CCAPI elements structure based on the map created in the CCAPI Config element
Returns:
	Struct elements
Arguments:
	String elementMapList
History:
	2011-03-19 - RLW - Created
--->
<cffunction name="getElementsFromElementMap" access="public" returnType="struct" hint="Builds the CCAPI elements structure based on the map created in the CCAPI Config element">
	<cfargument name="elementMapList" type="string" required="true" hint="List of uniqueID's from the Element Mapping Custom Element">
	<cfscript>
		var elements = structNew();
	</cfscript>
	<cfreturn elements>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	R. West
Name:
	$getElementsFromCCAPIPage
Summary:
	Builds the CCAPI elements structure based on a CS Page
Returns:
	Struct elements
Arguments:
	Numeric pageID
History:
	2011-03-19 - RLW - Created
--->
<cffunction name="getElementsFromCCAPIPage" access="public" returnType="struct" hint="Builds the CCAPI elements structure based on a CS Page">
	<cfargument name="pageID" type="numeric" required="true" hint="CommonSpot PageID for registered CCAPI page">
	<cfscript>
		var elements = structNew();
		var tmp = structNew();
		var itm = 1;
		// retrieve subsiteID for ccapi page
		var subsiteID = variables.csData.getSubsiteIDByPageID(arguments.pageID);
		// get the elements for the page passed in (only TBandCEData but allow unammed elements too)
		var pageElements = variables.csData.getElementsByPageID(arguments.pageID, true, false);
		if( arrayLen(pageElements) ){
			// loop through and build the elements structure
			for(itm; itm lte arrayLen(pageElements); itm=itm+1 ){
				tmp = structNew();
				// if the element has been named use it - otherwise use the controlID
				if( len(pageElements[itm].controlName) )
					tmp.controlName = pageElements[itm].controlName;
				else
					tmp.controlID = pageElements[itm].controlID;
				tmp.pageID = arguments.pageID;
				tmp.subsiteID = subsiteID;
				if( pageElements[itm].controlType gt request.constants.elementMaxFactory )
					tmp.elementType = "custom";
				else
					tmp.elementType = "texblock";
				// load the element into the element structure (use element name if it exists - otherwise the custom element name)
				if( len(pageElements[itm].controlName) )
					elements[pageElements[itm].controlName] = tmp;
				else
					elements[pageElements[itm].shortDesc] = tmp;
			}
		}
	</cfscript>
	<cfreturn elements>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadElements
Summary:	
	Based on the data returned from the configuration
	this utility will set all of the elements which are
	configured to handle API calls
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
--->
<cffunction name="loadElements" access="private" returntype="void">
	<cfscript>
		var CCAPIConfig = getCCAPIConfig();
		var elementsList = "";
		var itm = 0;
		var thisElement = "";
		var elementName = "";
		var elements = structNew();
		if( isStruct(CCAPIConfig) and structKeyExists(CCAPIConfig, "elements") and isStruct(CCAPIConfig["elements"]) )
			elements = CCAPIConfig.elements;
		// load the elements into object space
		setElements(elements);
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadWSVars
Summary:	
	Builds the WebService variables required like: Username,Password,URL etc..
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
--->
<cffunction name="loadWSVars" access="private" returntype="void">
	<cfscript>
		var CCAPIConfig = getCCAPIConfig();
		var wsVars = structNew();
		if( isStruct(CCAPIConfig) and structKeyExists(CCAPIConfig, "wsVars") )
			wsVars = CCAPIConfig["wsVars"];
		if( structKeyExists(wsVars, "csuserid") )
			setCSUserID(wsVars["csuserid"]);
		if( structKeyExists(wsVars, "cspassword") )
			setCSPassword(wsVars["cspassword"]);
		if( structKeyExists(wsVars, "siteURL") )
			setSiteURL(wsVars["siteURL"]);
		if( structKeyExists(wsVars, "webserviceURL") )
			setWebServiceURL(wsVars["webserviceURL"]);
		if( structKeyExists(wsVars, "subsiteID") )
			setSubsiteID(wsVars["subsiteID"]);
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$loadTemplates
Summary:	
	Based on the data returned from the configuration
	this utility will set all of the templates which are
	configured to handle API calls
Returns:
	Void
Arguments:
	Void
History:
	2009-05-13 - RLW - Created
	2009-06-30 - Deleted

<cffunction name="loadTemplates" access="private" returntype="void">
	<cfscript>
		var CCAPIConfig = getCCAPIConfig();
		var templatesList = "";
		var itm = 0;
		var thisTemplate = "";
		var templates = structNew();
		if( isStruct(CCAPIConfig) and structKeyExists(CCAPIConfig, "templates") )
			tempatesList = structKeyList(CCAPIConfig["templates"]);
		for( itm=1; itm lte listLen(templatesList); itm=itm+1 )
		{
			thisTemplate = CCAPIConfig["templates"][listGetAt(templatesList, itm)];
			// load this element into local variables first
			structInsert(templates, thisTemplate["name"], thisTemplates);			
		}
		// load the elements into object space
		setTemplates(templates);
	</cfscript>
</cffunction>--->


<!---
/* ***************************************************************
/*
Author: 	R. West
Name:
	$loadPanel
Summary:
	Builds the HTML for the CCAPI Panel
Returns:
	String panelHTML
Arguments:
	
History:
	2011-03-20 - RLW - Created
--->
<cffunction name="loadPanel" access="public" returnType="string" hint="Builds the HTML for the CCAPI Panel">
	<cfscript>
		var panelHTML = "";
	</cfscript>
	<!--- // save the panelHTML based on the settings --->
	<cfsavecontent variable="panelHTML">
		<cfinclude template="left_panel.cfm">
	</cfsavecontent>
	<cfreturn panelHTML>
</cffunction>

<!--- // Public GETTERS/SETTERS --->
<cffunction name="setSubsiteID" access="public" returntype="void">
	<cfargument name="subsiteID" type="numeric" required="true">
	<cfset variables.subsiteID = arguments.subsiteID>
</cffunction>

<cffunction name="getSubsiteID" access="public" returntype="numeric">
	<cfreturn variables.subsiteID>
</cffunction>

<cffunction name="getWS" access="public" returntype="any">
	<cfreturn variables.ws>
</cffunction>

<cffunction name="getSSID" access="public" returntype="string">
	<cfreturn variables.SSID>
</cffunction>

<!--- // Private GETTERS/SETTERS --->
<cffunction name="setCSPassword" access="private" returntype="void">
	<cfargument name="CSPassword" type="string" required="true">
	<cfset variables.CSPassword = arguments.CSPassword>
</cffunction>

<cffunction name="getCSPassword" access="private" returntype="string">
	<cfreturn variables.CSPassword>
</cffunction>

<cffunction name="getCSUserID" access="private" returntype="string">
	<cfreturn variables.CSUserID>
</cffunction>

<cffunction name="setCSUserID" access="private" returntype="void">
	<cfargument name="CSUserID" type="string" required="true">
	<cfset variables.CSUserID = arguments.CSUserID>
</cffunction>

<cffunction name="setSiteURL" access="private" returntype="void">
	<cfargument name="siteURL" type="string" required="true">
	<cfset variables.siteURL = arguments.siteURL>	
</cffunction>

<cffunction name="getSiteURL" access="private" returntype="string">
	<cfreturn variables.siteURL>
</cffunction>

<cffunction name="getCCAPIConfig" access="public" returntype="struct">
	<cfreturn variables.CCAPIConfig>
</cffunction>

<cffunction name="setCCAPIConfig" access="private" returntype="void">
	<cfargument name="CCAPIConfig" type="any" required="true">
	<cfset variables.CCAPIConfig = arguments.CCAPIConfig>
</cffunction>

<cffunction name="getElements" access="public" returntype="struct">
	<cfreturn variables.elements>
</cffunction>

<cffunction name="setElements" access="private" returntype="void">
	<cfargument name="elements" type="struct" required="true">
	<cfset variables.elements = elements>
</cffunction>

<cffunction name="getTemplates" access="private" returntype="struct">
	<cfreturn variables.templates>
</cffunction>

<cffunction name="setTemplates" access="private" returntype="void">
	<cfargument name="templates" type="struct" required="true">
	<cfset variables.templates = arguments.templates>
</cffunction>

<cffunction name="setWebServiceURL" access="private" returntype="void">
	<cfargument name="webServiceURL" type="string" required="true">
	<cfset variables.webServiceURL = arguments.webServiceURL>
</cffunction>

<cffunction name="getWebServiceURL" access="private" returntype="string">
	<cfreturn variables.webServiceURL>
</cffunction>

<cffunction name="setSSID" access="private" returntype="void">
	<cfargument name="ssid" type="string" required="true">
	<cfset variables.SSID = arguments.SSID>	
</cffunction>

</cfcomponent>