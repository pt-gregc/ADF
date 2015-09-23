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
	ceData_2_0.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	2.0
History:
	2012-12-31 - MFC - Created - New v2.0
	2013-07-03 - GAC - Added getCEDataViewList and getCEDataViewNumericList functions to be used by the getCEDataView function
	2013-10-23 - GAC - Removed the cfproperty dependency for the data_1_2 lib and injected directly in the required methods
	2013-01-15 - GAC - Removed obsolete dev funtions: buildViewforCE and buildViewCodeforCE
	2014-10-09 - GAC - Updated the BuildView and the BuildRealTypeView methods to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}" 
--->
<cfcomponent displayname="ceData_2_0" extends="ADF.lib.ceData.ceData_1_1" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="2_0_32">
<cfproperty name="type" value="singleton">
<cfproperty name="wikiTitle" value="CEData_2_0">

<cfscript>
	variables.SQLViewNameADFVersion = "1.8"; 
</cfscript>

<cffunction name="getSQLViewNameADFVersion" access="public" returntype="string" hint="Returns the SQL View Naming Convention ADF Version">
	<cfreturn variables.SQLViewNameADFVersion>
</cffunction>

<!---
/* ************************************************************** */
Author: 	
	PaperThin, Inc.
	Ron West
Name:
	$buildCEDataArrayFromQuery
Summary:	
	Returns a standard CEData Array to be used in Render Handlers from a ceDataView query
Returns:
	Array ceDataArray
Arguments:
	Query ceDataQuery
History:
 	2010-04-08 - RLW - Created
	2010-12-21 - MFC - Added function to CEDATA
	2011-02-08 - RAK - Removing ptBlog2 from the function calls as this is not running in ptBlog2 and should never have been here. Its fixed now at least...
	2011-04-04 - MFC - Updated function to load the Forms from the server object factory.
						Attempted to add dependency but ADF build throws error.
	2011-05-26 - MFC - Modified function to set the fieldStruct variable outside of the cfloop.	
	2012-12-13 - MFC - Updated to check if the fieldname starts with "FIC_" and remove.
	2013-09-27 - GAC - Updated the Forms Lib that is used to call the getCEFieldNameData function
	2013-10-23 - GAC - Updated the commonFields logic that turns the formID into a formName
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="buildCEDataArrayFromQuery" access="public" returntype="array" hint="Returns a standard CEData Array to be used in Render Handlers from a ceDataView query">
	<cfargument name="ceDataQuery" type="query" required="true" hint="ceData Query (usually built from ceDataView) results to be converted">
	<cfscript>
		var ceDataArray = arrayNew(1);
		var itm = "";
		var row = "";
		var column = "";
		var tmp = "";
		var defaultTmp = StructNew(); // Default temp for common fields over each loop
		var formName = "";
		var i = "";
		//var commonFieldList = "pageID,formID,dateAdded,dateCreated";
		var commonField = '';
		var commonFieldList = "pageID,formID";
		var fieldStruct = structNew();
		var queryColFieldList = ""; // List to store the column names
		var queryColPos = "";
		// Sort the column name list to be safe
		var origQueryColFieldList = ListSort(arguments.ceDataQuery.columnList, "textnocase");
		var currColName = '';

		
		// Check that we have a query with values
		if ( arguments.ceDataQuery.recordCount GTE 1 )
		{
			// Setup the default common fields 
			// get the fields structure for this element
			fieldStruct = server.ADF.objectFactory.getBean("Forms_1_1").getCEFieldNameData(getCENameByFormID(arguments.ceDataQuery["formID"][1]));
		}
		
		// Check if the query column contains "FIC_" and remove
		for ( i=1; i LTE ListLen(origQueryColFieldList); i++ )
		{
			currColName = ListGetAt(origQueryColFieldList, i);
			if ( UCASE(LEFT(currColName, 4)) EQ "FIC_" )
				currColName = Replace(currColName, "FIC_", "");
			// Add the cleaned name into the list
			queryColFieldList = ListAppend(queryColFieldList, currColName);
		}
	</cfscript>
	
	<cfloop from="1" to="#arguments.ceDataQuery.recordCount#" index="row">
		<cfscript>
			tmp = structNew();
			// Set the tmp to the default values from the common fields
			//tmp = defaultTmp;
			
			// add in common fields			
			for( i=1; i lte listLen(commonFieldList); i=i+1 ) 
			{	
				// Set the commonField to work with
				commonField = listGetAt(commonFieldList, i);
				// handle each of the common fields
				if( findNoCase(commonField, queryColFieldList) and StructKeyExists(arguments.ceDataQuery,commonField) )
					tmp[commonField] = arguments.ceDataQuery[commonField][row];
				else
					tmp[commonField] = "";
					
				// do special case work for formID/formName
				if ( commonField eq "formID"  ) 
				{
					// Get the FormName from the FormID
					if( not len(formName) and StructKeyExists(tmp,commonField) and IsNumeric(tmp[commonField]) )
						formName = getCENameByFormID(tmp[commonField]);
					
					// Set the Value for the formName in the tmp Struct
					tmp.formName = formName;
				} 
			}
			
			tmp.values = structNew();
			
			// loop through the field query and build the values structure
			for( itm=1; itm lte listLen(structKeyList(fieldStruct)); itm=itm+1 ) 
			{
				column = listGetAt(structKeyList(fieldStruct), itm);
				// Get the position of the column from the in query
				queryColPos = listFindNoCase(queryColFieldList, column);
				// Get the column name from the original column name list
				if( queryColPos GT 0)
					tmp.values[column] = arguments.ceDataQuery[ListGetAt(origQueryColFieldList,queryColPos)][row];
				else
					tmp.values[column] = "";
			}
			arrayAppend(ceDataArray, tmp);
		</cfscript>
	</cfloop>
	<cfreturn ceDataArray>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$buildRealTypeView
Summary:	
	Builds an element view for the passed in element
Returns:
	Boolean viewCreated
Arguments:
	String  ceName
	String  viewName
	Struct  fieldTypes
	Struct  options
History:
	2013-01-04 - MFC - Sets the view table name to the "getViewTableName" function if no
						value passed in.  Calls the SUPER function to create the table.
	2013-01-29 - GAC - Updated the getViewTableName logic so it creates a view table name if a viewName is NOT passed in
	2013-12-06 - DRM - Accept and pass fieldTypes for the 'new' buildRealTypeView
	2014-04-04 - DRM - Accept and pass options to the 'new' buildRealTypeView
	2014-05-30 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="buildRealTypeView" access="public" returntype="boolean" hint="Builds an element view for the passed in element name">
	<cfargument name="elementName" type="string" required="true" hint="element name to build the view table off of">
	<cfargument name="viewName" type="string" required="false" default="" hint="Override the view name that gets generated">
	<cfargument name="fieldTypes" type="struct" default="#structNew()#" hint="see ceData_1_1.cfc">
	<cfargument name="options" type="struct" default="#structNew()#" hint="See argument notes for this method in ceData_1_1.">
	<cfscript>
		// Set the view table name from the elementName if a viewName is NOT passed in
		arguments.viewName = trim(arguments.viewName);
		if ( len(arguments.viewName) eq 0 )
		{
			// ADF 1.8 SQL View Naming using the vCE_{CustomElementName} convention
			arguments.viewName = getCEViewName(ceName=arguments.elementName,type="adfversion",version=getSQLViewNameADFVersion());
		}
		// Call the SUPER function to build the view table
		return super.buildRealTypeView(argumentCollection=arguments);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright, D. Merrill
Name:
	buildView
Summary:
	Rebuilds a requested  View
Returns:
	boolean
Arguments:
	String  ceName
	String  viewName
	Struct  fieldTypes
	Boolean forceRebuild
	Struct  options
History: - some carried over from original in ptCalendar app
	2011-07-11 - GAC - Created
	2013-12-04 - DRM - Added forceRebuild arg and logic
	2013-12-06 - DRM - Copied from ptCalendar app, renamed
		Accept and pass fieldTypes
		Default viewName to "", use local default if blank
		Honor Request.Params.adfRebuildSQLViews as well as arguments.forceRebuild
	2014-04-04 - DRM - Accept and pass options to the 'new' version of buildRealTypeView ceData_1_1
	2014-05-30 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="buildView" access="public" returntype="boolean" output="false" hint="Rebuilds the requested View.">
	<cfargument name="ceName" type="string" required="true" hint="Name of custom element to base view off of.">
	<cfargument name="viewName" type="string" default="" hint="Optional name of view to create. If blank or not passed, defaults to one calc'd from custom element name.">
	<cfargument name="fieldTypes" type="struct" default="#structNew()#" hint="Optional struct of field type specs; see hint for this arg in buildRealTypeView().">
	<cfargument name="forceRebuild" type="boolean" default="false" hint="Pass true to rebuild the view always, even if it already exists.">
	<cfargument name="options" type="struct" default="#structNew()#" hint="See argument notes for buildRealTypeView method in ceData_1_1.">
	
	<cfscript>
		var buildNow = arguments.forceRebuild or (structKeyExists(Request.Params, "adfRebuildSQLViews") and Request.Params.adfRebuildSQLViews eq 1);
		
		arguments.viewName = trim(arguments.viewName);
		
		if ( LEN(arguments.viewName) EQ 0 )
		{
			// if no view name passed in, calc the default name here, to check if view exists; should use same algorithm as buildRealTypeView
			// - Use ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
			arguments.viewName = getCEViewName(ceName=arguments.ceName,type="adfversion",version=getSQLViewNameADFVersion()); 
		}
		
		buildNow = buildNow or not server.ADF.objectFactory.getBean("data_1_2").verifyTableExists(tableName=arguments.viewName);

		if (buildNow)
			return buildRealTypeView
			(
				elementName=arguments.ceName,
				viewName=arguments.viewName,
				fieldTypes=arguments.fieldTypes,
				options=arguments.options
			);
		return true;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$defaultFieldQuery
Summary:
	Given a Custom Element Form ID this function will build a default
	query with the fields for that element.
Returns:
	Query fields
Arguments:
	Numeric ceFormID
History:
	2013-01-04 - MFC - Created
--->
<cffunction name="defaultFieldQuery" access="public" returntype="query" output="true">
	<cfargument name="ceFormID" type="numeric" required="true">
	<cfscript>
		var fieldQuery = "";
		var itm = 1;
		var retQuery = QueryNew("pageid,formid","VarChar,VarChar");
		var thisField = "";
		
		if( (len(arguments.ceFormID)) and (arguments.ceFormID GT 0) ) {
			// get the field query for this element
			fieldQuery = getElementFieldsByFormID(arguments.ceFormID);
			
			// loop through the query and build the default structure
			for( itm=1; itm LTE fieldQuery.recordCount; itm=itm+1 ) {
				// replace the FIC_ from the beginning
				thisField = ReplaceNoCase(fieldQuery.fieldName[itm], "FIC_", "", "all");
				
				// Add the column into the query
				QueryAddColumn(retQuery, thisField, "VarChar", ArrayNew(1));				
			}
		}
		return retQuery;
	</cfscript>
</cffunction>

<!---
/* ************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$elementContainData
Summary:	
	Checks the element data structure to see if the fields contain data.
Returns:
	Boolean
Arguments:
	Struct - elementData
	String - excludeFields
History:
 	2012-12-14 - MFC - Created			
--->
<cffunction name="elementContainData" access="public" returntype="boolean" output="true">
	<cfargument name="elementData" type="struct" required="true">
	<cfargument name="excludeFields" type="string" required="false" default="">
	
	<cfscript>
		var i=1;
		var dataFieldNames = StructKeyList(arguments.elementData);
		var currFieldName = "";
	
		// Loop over the keys in the "elementData"
		for ( i=1; i LTE ListLen(dataFieldNames); i++ ){
			currFieldName = ListGetAt(dataFieldNames, i);
				
			// Check if we need to exclude this field or not
			if ( ListFindNoCase(excludeFields, currFieldName) LTE 0 ){
				
				// Check if the field contains data, if so then return TRUE
				if ( LEN(TRIM(arguments.elementData[currFieldName])) GT 0 )
					return true;
			}
		}
		return false;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEData
Summary:
	Returns array of structs for all data matching the Custom Element.
	Params can specify exact fields for searching.
Returns:
	Query
Arguments:
	String - Custom Element Name
	String - Element Field Name
	String - Item Values to Search
	String - Query Type, options [selected,notSelected,search]
	String - Search Values
History:
	2013-01-04 - MFC - Reworked the processing for the GETCEDATA functionality.
	2013-01-24 - MFC - Added check if the value is in the Field ID Name Map.
	2013-04-02 - SDH - Fixed issue with VAR variables in the function.
	2013-04-02 - MFC - Cleaned up the variable names and removed unused variables.
	2013-07-01 - GAC - Updated the getDataFieldValue call to also pass the formID to prevent returning bad data.
	2013-09-27 - GAC - Added the ORDER BY statement to the Query Of Queries for RAILO to obey the DISTINCT keyword in a QoQs (prevents railo for returning too many records)
					 - Added a cfqueryparam in the currPageIDDataQry QofQs
	2013-10-23 - GAC - Removed the local dependency for the data_1_2 Lib which was causing errors being extended by the general_chooser.cfc
	2013-01-31 - JTP - Optimized function for larger data sets
	2014-02-24 - JTP - Var'ing the local getDataPageValueQrySORTED variable
	2015-09-10 - GAC - Replaced duplicate() with Server.CommonSpot.UDF.util.duplicateBean() 
	2015-09-23 - GAC - duplicateBean() is a CS 9.0.3 specific update ... rolling back to Duplicate()
--->

<cffunction name="getCEData" access="public" returntype="array" hint="Returns array of structs for all data matching the Custom Element." output="false">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="any" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="searchFields" type="string" required="false" default="">
	<cfargument name="itemListDelimiter" type="string" required="false" default="," hint="Only valid for the 'selected','notselected', 'list', 'numericList' and 'searchInList' queryTypes">

	<cfscript>
		// initialize the variables
		var data_i = 1;
	 	var ceFormID = getFormIDByCEName(arguments.customElementName);
		var ceFieldID = "";
		var searchCEFieldName = "";
		var searchCEFieldID = "";
		var ceFieldName = "";
		var pageIDValueQry = QueryNew("temp");
		var ceFieldIDNameMap = StructNew();
		var sFldsLen = 0;
		var prevPageID = 0;
		var getDataPageValueQrySORTED = "";
		
		// sdhardesty fixes 03-27-13
		var i = 1;
		var currFieldName = '';
		var newRow = "";
		var ceDefaultFieldQry = QueryNew("temp");
		var ceFieldQuery = QueryNew("temp");
		var getDataPageValueQry = QueryNew("temp");
		var ceDataQry = QueryNew("temp"); 
		var distinctPageIDQry = QueryNew("temp"); 
		var currPageIDDataQry = QueryNew("temp"); 
		// end sdhardesty fixes 03-27-13
		
		if (LEN(arguments.customElementFieldName) OR Len(arguments.searchFields)) 
		{
			// check if queryType is Search
			if ( arguments.queryType EQ "search" OR arguments.queryType EQ "multi" ) 
			{
				// get the id's for each item in the list and create a new list of id's
				sFldsLen = ListLen(arguments.searchFields);
				for (data_i=1; data_i LTE sFldsLen; data_i=data_i+1)
				{
					searchCEFieldName = "FIC_" & TRIM(ListGetAt(arguments.searchFields,data_i));
					searchCEFieldID = ListAppend(searchCEFieldID, getElementFieldID(ceFormID, searchCEFieldName));
				}
			}

			// convert the CE Field Name Arg to the field ID
			// check if the field name starts with 'FIC_'
			if (arguments.customElementFieldName CONTAINS "FIC_")
				ceFieldID = getElementFieldID(ceFormID, arguments.customElementFieldName);
			else
			{
				ceFieldName = "FIC_" & arguments.customElementFieldName;
				ceFieldID = getElementFieldID(ceFormID, ceFieldName);
			}
		}
		
		// special case for versions
		if ( arguments.queryType eq "versions" )
			pageIDValueQry = getPageIDForElement(ceFormID, ceFieldID, arguments.item, "selected", arguments.searchValues, searchCEFieldID, arguments.itemListDelimiter);
		else
			pageIDValueQry = getPageIDForElement(ceFormID, ceFieldID, arguments.item, arguments.queryType, arguments.searchValues, searchCEFieldID, arguments.itemListDelimiter);
			
		// Get the default structure for the element fields
		// Build the query row for the default field values
		ceDefaultFieldQry = defaultFieldQuery(ceFormID=ceFormID);
		ceFieldQuery = getElementFieldsByFormID(formID=ceFormID);
		
		// Get the mapping of field ID's to Field Names
		//	Example: ceFieldIDNameMap[1011] = "myFieldName"
		ceFieldIDNameMap = StructNew();
		for ( i=1; i LTE ceFieldQuery.recordCount; i++ )
			ceFieldIDNameMap[ceFieldQuery.fieldID[i]] = Replace(ceFieldQuery.fieldName[i], "FIC_", "");

		// Build in the initial query for the CE Data storage
		// a CS 9.0.3 specific update ... rolling back to Duplicate()
		//ceDataQry = Server.CommonSpot.UDF.util.duplicateBean(ceDefaultFieldQry);
		ceDataQry = duplicate(ceDefaultFieldQry);
		
		getDataPageValueQry = getDataFieldValue(pageID=ValueList(pageIDValueQry.pageID),formid=ceFormID);
	</cfscript>
	
	<!--- // order by pageid so all records are next to each other --->
	<cfquery name="getDataPageValueQrySORTED" dbtype="query">
		SELECT *
		FROM 	getDataPageValueQry
		ORDER BY PageID 
	</cfquery>
	
	<cfif getDataPageValueQrySORTED.RecordCount gt 0 >
		
		<!--- Loop over the query of page ids --->
		<cfloop query="getDataPageValueQrySORTED">
			
			<cfif getDataPageValueQrySORTED.PageID neq prevPageID>
				<cfset prevPageID = getDataPageValueQrySORTED.PageID>
				
				<!--- Create the data set to be added back in --->
				<!--- Add a new row --->
				<cfset newRow = QueryAddRow(ceDataQry)>
			</cfif>
				
			<!--- Set the PageID and FormID --->
			<cfset QuerySetCell(ceDataQry, "pageID", getDataPageValueQrySORTED.pageID, newRow)>
			<cfset QuerySetCell(ceDataQry, "formID", getDataPageValueQrySORTED.formID, newRow)>
				
			<!--- Check if the value is in the Field ID Name Map --->
			<cfif StructKeyExists(ceFieldIDNameMap, getDataPageValueQrySORTED.fieldID)>
				<!--- Get the field ID to the set the column field name --->
				<cfset currFieldName = ceFieldIDNameMap[getDataPageValueQrySORTED.fieldID]>
				<cfif LEN(getDataPageValueQrySORTED.memoValue)>
					<cfset QuerySetCell(ceDataQry, currFieldName, getDataPageValueQrySORTED.memoValue, newRow)>
				<cfelse>
					<cfset QuerySetCell(ceDataQry, currFieldName, getDataPageValueQrySORTED.fieldValue, newRow)>
				</cfif>
			</cfif>
			
		</cfloop>
		
	</cfif>	
	
	<cfscript>
		// Check if we are processing the selected list
		if ( arguments.queryType EQ "selected" and len(arguments.customElementFieldName) and len(arguments.item) ) 
		{
			// Order the return data by the order the list was passed in
			// --IMPORTANT: We CAN NOT use the local 'variables.data.QuerySortByOrderedList' since this LIB is extended by the general_chooser.cfc
			ceDataQry = server.ADF.objectFactory.getBean("data_1_2").QuerySortByOrderedList(query=ceDataQry, 
																							   columnName=arguments.customElementFieldName, 
																							   columnType="varchar",
																							   orderList=arguments.item,
																								orderListDelimiter = arguments.ItemListDelimiter);
		} 

		// Flip the query back into the CE Data Array Format
		return buildCEDataArrayFromQuery(ceDataQuery=ceDataQry);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataCore
Summary:
	 A worker function that processes the query data from the 
	 getCEData function and returns a query
Returns:
	Query
Arguments:
	Query - qry
	Query - qry2
	Query - ceFieldIDNameMap
History:
	2014-01-31 - JTP - Created
	2014-03-05 - JTP - Var declarations
--->
<cffunction name="getCEDataCore" access="private" output="No" returntype="query" hint=" A worker function that processes the query data from the getCEData function and returns a query">
	<cfargument name="qry" required="Yes" type="query">
	<cfargument name="qry2" required="Yes" type="query">
	<cfargument name="ceFieldIDNameMap" required="Yes" type="struct">
	
	<cfscript>
		var getDataPageValueQrySORTED = arguments.qry;
		var ceDataQry = arguments.qry2;
		var newrow = '';
		var currPageIDDataQry = '';
		var prevPageID = 0;
		var currFieldName = '';
	</cfscript>

	<cfif getDataPageValueQrySORTED.RecordCount gt 0 >
		<!--- // Loop over the query of page ids --->
		<cfloop query="getDataPageValueQrySORTED">
			
			<cfif getDataPageValueQrySORTED.PageID neq prevPageID>
				<cfset prevPageID = getDataPageValueQrySORTED.PageID>
				
				<!--- // Create the data set to be added back in --->
				<!--- // Add a new row --->
				<cfset newRow = QueryAddRow(ceDataQry)>
			</cfif>
				
			<!--- // Set the PageID and FormID --->
			<cfset QuerySetCell(ceDataQry, "pageID", getDataPageValueQrySORTED.pageID, newRow)>
			<cfset QuerySetCell(ceDataQry, "formID", getDataPageValueQrySORTED.formID, newRow)>
				
			<!--- // Check if the value is in the Field ID Name Map --->
			<cfif StructKeyExists(ceFieldIDNameMap, getDataPageValueQrySORTED.fieldID)>
				<!--- Get the field ID to the set the column field name --->
				<cfset currFieldName = ceFieldIDNameMap[getDataPageValueQrySORTED.fieldID]>
				<cfif LEN(getDataPageValueQrySORTED.memoValue)>
					<cfset QuerySetCell(ceDataQry, currFieldName, getDataPageValueQrySORTED.memoValue, newRow)>
				<cfelse>
					<cfset QuerySetCell(ceDataQry, currFieldName, getDataPageValueQrySORTED.fieldValue, newRow)>
				</cfif>
			</cfif>
			
		</cfloop>
	</cfif>
	
	<cfreturn ceDataQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataView
Summary:
	Returns array of structs for all data matching the Custom Element querying the View Table.
	Params can specify exact fields for searching.
Returns:
	Query
Arguments:
	String - Custom Element Name
	String - Element Field Name
	String - Item Values to Search
	String - Query Type, options 
				[selected,notSelected,search,searchInList,multi,list,numericList,greaterThan,between]
	String - Search Values
	String - Search Fields
	Boolean - Force Rebuild
	String - itemListDelimiter 
History:
	2013-01-04 - MFC - Created
	2013-04-02 - MFC - Added call to verify if the view table exists and create the view.
	2013-07-03 - GAC - Added support for the "list" and "numericList" queryTypes 
	2013-10-23 - GAC - Removed the local dependency for the data_1_2 Lib which was causing errors being extended by the general_chooser.cfc
	2014-02-21 - JTP - Updated 'searchInList' with better handling of non-UUID lists
	2014-02-21 - GAC - Added itemListDelimiter parameter
	2014-04-04 - GAC - Changed the cfscript thow to the utils.doThow with logging option
	2014-05-30 - GAC - Changed the utils lib to load from the server getBean instead of using Application.ADF.utils
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
	2014-12-03 - GAC - Moved the QuerySortByOrderedList method call to getCEDataViewSelected() method SINCE IT IS ONLY USED FOR queryType=SELECTED 
--->
<cffunction name="getCEDataView" access="public" returntype="array" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="searchFields" type="string" required="false" default="">
	<cfargument name="forceRebuild" type="boolean" default="false">
	<cfargument name="itemListDelimiter" type="string" required="false" default="," hint="Only valid for the 'selected','notselected', 'list', 'numericList' and 'searchInList' queryTypes">
	
	<cfscript>
		var viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
		var ceViewQry = QueryNew("null");
		var dataArray = ArrayNew(1);
		var viewTableExists = false;
		var throwErrorMsg = "";
		var utils = server.ADF.objectFactory.getBean("utils_1_2");
		
		try {
			
			// Verify if the view table exists, create if doesn't exists
			viewTableExists = buildView(ceName=arguments.customElementName,
													viewName=viewTableName,
													forceRebuild=arguments.forceRebuild);
			
			// TIMER START
			//a2 = GetTickCount();

			if ( viewTableExists ) 
			{
				
				// Switch Case based on the query type
				switch (arguments.queryType)
				{
				
					case "selected":
						ceViewQry = getCEDataViewSelected(customElementName=arguments.customElementName,
														  customElementFieldName=arguments.customElementFieldName,
														  item=arguments.item,
														  overrideViewTableName=viewTableName,
														  itemListDelimiter=arguments.itemListDelimiter);
						break;
					case "notSelected":
						ceViewQry = getCEDataViewNotSelected(customElementName=arguments.customElementName,
														     customElementFieldName=arguments.customElementFieldName,
														  	 item=arguments.item,
														     overrideViewTableName=viewTableName,
														     itemListDelimiter=arguments.itemListDelimiter);
						break;	
					
					case "search":
						ceViewQry = getCEDataViewSearch(customElementName=arguments.customElementName,
														searchValues=arguments.searchValues,
													  	searchFields=arguments.searchFields,
													    item=arguments.item,
													  	customElementFieldName=arguments.customElementFieldName,
													    overrideViewTableName=viewTableName);
						break;	
					case "searchInList":
						// To make backwards compatible, check if the "searchFields" are passed in the "customElementFieldName" arg.
						if ( LEN(TRIM(arguments.searchFields)) EQ 0 AND LEN(arguments.customElementFieldName) )
							arguments.searchFields = arguments.customElementFieldName;
						// To make backwards compatible, check if the "searchValues" are passed in the "items" arg.
						if ( LEN(TRIM(arguments.searchValues)) EQ 0 AND LEN(arguments.item) )
							arguments.searchValues = arguments.item;
					
						ceViewQry = getCEDataViewSearchInList(customElementName=arguments.customElementName,
															  searchFields=arguments.searchFields,
															  searchValues=arguments.searchValues,
															  overrideViewTableName=viewTableName,
															  searchValuesDelimiter=arguments.itemListDelimiter);
						break;	
					case "multi":
						ceViewQry = getCEDataViewMulti(customElementName=arguments.customElementName,
													   searchFields=arguments.searchFields,
													   searchValues=arguments.searchValues,
												  	   overrideViewTableName=viewTableName);
						break;
					case "list":
						ceViewQry = getCEDataViewList(customElementName=arguments.customElementName,
													   customElementFieldName=arguments.customElementFieldName,
													   item=arguments.item,
												  	   overrideViewTableName=viewTableName,
												  	   itemListDelimiter=arguments.itemListDelimiter);
						break;	
					case "numericList":
						ceViewQry = getCEDataViewNumericList(customElementName=arguments.customElementName,
													  		 customElementFieldName=arguments.customElementFieldName,
													  		 item=arguments.item,
												  	   		 overrideViewTableName=viewTableName,
														 	 itemListDelimiter=arguments.itemListDelimiter);
						break;
					case "greaterThan":
						ceViewQry = getCEDataViewGreaterThan(customElementName=arguments.customElementName,
														  	 customElementFieldName=arguments.customElementFieldName,
														  	 item=arguments.item,
														  	 overrideViewTableName=viewTableName);
						break;
					case "between":
						ceViewQry = getCEDataViewBetween(customElementName=arguments.customElementName,
														 customElementFieldName=arguments.customElementFieldName,
														 item=arguments.item,
														 overrideViewTableName=viewTableName,
														 itemListDelimiter=arguments.itemListDelimiter);
						break;
				}
				
				// TIMER END
				//b2 = GetTickCount();
				//timer2 = "getCEDataView - Query Timer = " & b2-a2;
				//utils.dodump(ceViewQry, "ceViewQry", false);	
				
			}
			else 
			{
				// Throw error that the Library Component Bean doesn't exist.
				throwErrorMsg = "A view for #arguments.customElementName# Custom Element does not exist!";
				utils.doThrow(message=throwErrorMsg,logerror=true);
				// cfscript 'throw' is not cf8 compatible
				//throw(message="View Table Does Not Exist", detail="View Table Does Not Exist");	
			}
		}
		catch (ANY exception) {
			utils.dodump(exception, "CFCATCH", false);	
		}
	
		if ( ceViewQry.recordCount ) 
		{
			// Flip the query back into the CE Data Array Format
			dataArray = buildCEDataArrayFromQuery(ceDataQuery=ceViewQry);
			
			// MOVED into the getCEDataViewSelected() method ---  SINCE IT IS ONLY USED FOR queryType=SELECTED ... 
			// Check if we are processing the selected list
			/*if ( arguments.queryType EQ "selected" and len(arguments.customElementFieldName) and len(arguments.item) ) 
			{
				// Order the return data by the order the list was passed in
				// --IMPORTANT: We CAN NOT use the local 'variables.data.QuerySortByOrderedList' since this LIB is extended by the general_chooser.cfc
				ceViewQry = server.ADF.objectFactory.getBean("data_1_2").QuerySortByOrderedList(query=ceViewQry, 
																								   columnName=arguments.customElementFieldName, 
																								   columnType="varchar",
																								   orderList=arguments.item,
																								   orderListDelimiter=arguments.itemListDelimiter);
				//utils.dodump(ceViewQry, "ceViewQry", false);
			}*/
		}
		
		return dataArray;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewBetween
Summary:
	Queries the CE Data View table for the Query Type of "BETWEEN".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - customElementFieldName - Element Field Name
	String - item - Item Values find the records containing this values
	String - overrideViewTableName - Override for the view table to query
	String - itemListDelimiter - delimiter for the item values if a list is passed in
History:
	2013-01-11 - MFC - Created
	2014-02-21 - GAC - Added itemList delimiter option
	2014-03-05 - JTP - Var declarations
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewBetween" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfargument name="itemListDelimiter" type="string" required="false" default=",">
	
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var dbType = Request.Site.SiteDBType;
		var rwPre = '';
		var rwPost = '';
		
		// Set the escape characters for reserverd words
		switch (dbType)
		{
			case 'Oracle':
				rwPre = '"';
				rwPost = '"';
				break;
			case 'MySQL':
				rwPre = '`';
				rwPost = '`';
				break;
			case 'SQLServer':
				rwPre = '[';
				rwPost = ']';
				break;	
		}	
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	<cftry>
		<!--- Check the ITEMS arg is correct with 2 values for the span --->
		<cfif ListLen(arguments.item,arguments.itemListDelimiter) EQ 2>
			<cfquery name="ceViewQry" datasource="#request.site.datasource#">
				SELECT *
				FROM   #viewTableName#
				WHERE  #rwPre##arguments.customElementFieldName##rwPost# >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListFirst(arguments.item,arguments.itemListDelimiter)#">
				AND    #rwPre##arguments.customElementFieldName##rwPost# <= <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(arguments.item,arguments.itemListDelimiter)#">
			</cfquery>
		<cfelse>
			<cfthrow message="Only pass in a delimited list of 2 values for the 'item' for the queryType 'between'">
		</cfif>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewGreaterThan
Summary:
	Queries the CE Data View table for the Query Type of "GREATERTHAN".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - customElementFieldName - Element Field Name
	String - item - Item Values find the records containing this values
	String - overrideViewTableName - Override for the view table to query
History:
	2013-01-11 - MFC - Created
	2014-03-05 - JTP - Var declarations
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewGreaterThan" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var dbType = Request.Site.SiteDBType;
		var rwPre = '';
		var rwPost = '';
		
		// Set the escape characters for reserverd words
		switch (dbType)
		{
			case 'Oracle':
				rwPre = '"';
				rwPost = '"';
				break;
			case 'MySQL':
				rwPre = '`';
				rwPost = '`';
				break;
			case 'SQLServer':
				rwPre = '[';
				rwPost = ']';
				break;	
		}	
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			WHERE  #rwPre##arguments.customElementFieldName##rwPost# > <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
		</cfquery>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewMulti
Summary:
	Queries the CE Data View table for the Query Type of "MULTI".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - searchFields - List of Element Fields to search (one-to-one match with the values)
	String - searchValues - List of Value to search (one-to-one match with the fields)
	String - overrideViewTableName - Override for the view table to query
History:
	2013-01-11 - MFC - Created
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewMulti" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="searchFields" type="string" required="false" default="">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var currFieldNum = 1;
					
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			<!--- Loop over the list of fields to build search cases --->
			<cfloop from="1" to="#ListLen(arguments.searchFields)#" index="currFieldNum">
				<!--- Check if the first condition, or just adding on --->
				<cfif currFieldNum EQ 1>
					WHERE
				<cfelse>
					AND
				</cfif>
				( #ListGetAt(arguments.searchFields, currFieldNum)# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListGetAt(arguments.searchValues,currFieldNum)#"> )
			</cfloop>
		</cfquery>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewNotSelected
Summary:
	Queries the CE Data View table for the Query Type of "NOTSELECTED".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - customElementFieldName - Element Field Name
	String - item - Item Values find the records containing this values
	String - overrideViewTableName - Override for the view table to query
	String - itemListDelimiter - delimiter for the item values if a list is passed in
History:
	2013-01-11 - MFC - Created
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
	2014-02-21 - GAC - Added itemListDelimiter parameter
	2014-03-05 - JTP - Var declarations
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewNotSelected" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfargument name="itemListDelimiter" type="string" required="false" default=",">

	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var dbType = Request.Site.SiteDBType;
		var rwPre = '';
		var rwPost = '';		
		
		// Set the escape characters for reserverd words
		switch (dbType)
		{
			case 'Oracle':
				rwPre = '"';
				rwPost = '"';
				break;
			case 'MySQL':
				rwPre = '`';
				rwPost = '`';
				break;
			case 'SQLServer':
				rwPre = '[';
				rwPost = ']';
				break;	
		}	
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	<cftry>
		<!--- Check that the Arguments are specified --->
		<cfif LEN(arguments.customElementFieldName) AND LEN(arguments.item)>
			<cfquery name="ceViewQry" datasource="#request.site.datasource#">
				SELECT *
				FROM   #viewTableName#
				<!--- Check if the items are a list --->
				<cfif ListLen(arguments.item,arguments.itemListDelimiter) GT 1>
					WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD='#rwPre##arguments.customElementFieldName##rwPost#' LIST="#arguments.item#" isNot=1 CFSQLTYPE="cf_sql_varchar" SEPARATOR="#arguments.itemListDelimiter#">
					<!--- WHERE #arguments.customElementFieldName# NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">) --->
				<cfelse>
					WHERE #rwPre##arguments.customElementFieldName##rwPost# <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
				</cfif>
			</cfquery>
		</cfif>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewSearch
Summary:
	Queries the CE Data View table for the Query Type of "SEARCH".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - searchFields - List of Element Fields to search
	String - searchValues - Value to search
	String - item - Item Values to exclude from the search results
	String - customElementFieldName - Element Field for the excluded item values
	String - overrideViewTableName - Override for the view table to query
History:
	2013-01-11 - MFC - Created
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewSearch" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="searchFields" type="string" required="false" default="">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var currFieldNum = 1;
		var excludeItemQry = QueryNew("null");
		var excludePageIDList = "";	//	List of Page IDs to exclude from the search results
			
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	<cftry>
		<!--- Get the exlcuded items if defined --->
		<cfif LEN(arguments.customElementFieldName) AND LEN(arguments.item)>
			<cfset excludeItemQry = getCEDataViewSelected(customElementName=arguments.customElementName,
														  customElementFieldName=arguments.customElementFieldName,
														  item=arguments.item,
														  overrideViewTableName=viewTableName)>
			<cfif excludeItemQry.recordCount>
				<cfset excludePageIDList = ValueList(excludeItemQry.pageid)>
			</cfif>
		</cfif>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			<!--- Loop over the list of fields to build search cases --->
			<cfloop from="1" to="#ListLen(arguments.searchFields)#" index="currFieldNum">
				<!--- Check if the first condition, or just adding on --->
				<cfif currFieldNum EQ 1>
					WHERE
				<cfelse>
					OR
				</cfif>
				( #ListGetAt(arguments.searchFields, currFieldNum)# LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.searchValues#%"> )
			</cfloop>
			<cfif ListLen(excludePageIDList) GT 0>
				AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="pageid" LIST="#excludePageIDList#" isNot=1 cfsqltype="cf_sql_varchar">
				<!--- AND pageid NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#excludePageIDList#" list="true">) --->
			</cfif>
		</cfquery>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewSearchInList
Summary:
	Queries the CE Data View table for the Query Type of "SEARCHINLIST".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - searchFields - Single field name to search
	String - searchValues - List of values to search
	String - overrideViewTableName - Override for the view table to query
	String - itemListDelimiter - delimiter for the item values if a list is passed in
History:
	2013-01-11 - MFC - Created
	2014-02-20 - JTP - Updated 'searchInList' with better handling of non-UUID lists
	2014-02-21 - GAC - Added itemListDelimiter parameter
					 - Added escape characters for reserverd words in the criteria column
					 - Added logic is a searchFields is passed but no Item value then look of null or empty strings
	2014-03-05 - JTP - Var declarations
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewSearchInList" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="searchFields" type="string" required="false" default="" hint="Currently only support one search field">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfargument name="searchValuesDelimiter" type="string" required="false" default=",">
	
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var currFieldNum = 1;
		var theItem = "";
		var rwPre = "";
		var rwPost = "";
		var dbType = Request.Site.SiteDBType;
		var theListLen = 0;
		
		// Set the escape characters for reserverd words
		switch (dbType)
		{
			case 'Oracle':
				rwPre = '"';
				rwPost = '"';
				break;
			case 'MySQL':
				rwPre = '`';
				rwPost = '`';
				break;
			case 'SQLServer':
				rwPre = '[';
				rwPost = ']';
				break;	
		}		
		
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			<cfif LEN(arguments.searchFields)> 
				<cfif LEN(arguments.searchValues)>
					<!--- // Loop over the list of fields to build search cases --->
					<cfset theListLen = ListLen(arguments.searchValues,arguments.searchValuesDelimiter)>
					<cfloop from="1" to="#theListLen#" index="currFieldNum">
						<cfset theItem = LCASE(ListGetAt(arguments.searchValues,currFieldNum,arguments.searchValuesDelimiter))>
						<!--- // Check if the first condition, or just adding on --->
						<cfif currFieldNum EQ 1>
							WHERE
						<cfelse>
							OR
						</cfif>
						LOWER(#rwPre##arguments.searchFields##rwPost#) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#theItem#"> 
						OR
						LOWER(#rwPre##arguments.searchFields##rwPost#) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#theItem#,%"> 
						OR
						LOWER(#rwPre##arguments.searchFields##rwPost#) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#theItem#,%"> 
						OR
						LOWER(#rwPre##arguments.searchFields##rwPost#) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%,#theItem#"> 
					</cfloop>
				<cfelse>
					<!--- // If no Item value is passed look of null or empty strings --->
					WHERE LOWER(#rwPre##arguments.searchFields##rwPost#) IS <cfqueryparam cfsqltype="cf_sql_varchar" null="true"> 
					   OR LOWER(#rwPre##arguments.searchFields##rwPost#) = <cfqueryparam cfsqltype="cf_sql_varchar" value=""> 
				</cfif>
			</cfif>
		</cfquery>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewSelected
Summary:
	Queries the CE Data View table for the Query Type of "SELECTED".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - customElementFieldName - Element Field Name
	String - item - Item Values find the records containing this values
	String - overrideViewTableName - Override for the view table to query
	String - itemListDelimiter - delimiter for the item values if a list is passed in
History:
	2013-01-11 - MFC - Created
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
	2014-02-21 - GAC - Added itemListDelimiter parameter
	2014-03-05 - JTP - Var declarations
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
	2014-11-18 - GAC - Updated to sort by the order of the selected items that are passed in (same as getCEData(queryType="selected"))
--->
<cffunction name="getCEDataViewSelected" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfargument name="itemListDelimiter" type="string" required="false" default=",">
	
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var dbType = Request.Site.SiteDBType;
		var rwPre = '';
		var rwPost = '';		
		
		// Set the escape characters for reserverd words
		switch (dbType)
		{
			case 'Oracle':
				rwPre = '"';
				rwPost = '"';
				break;
			case 'MySQL':
				rwPre = '`';
				rwPost = '`';
				break;
			case 'SQLServer':
				rwPre = '[';
				rwPost = ']';
				break;	
		}	
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			<cfif LEN(TRIM(arguments.customElementFieldName))>
				<!--- // Check if the items are a list --->
				<cfif ListLen(arguments.item,arguments.itemListDelimiter) GT 1>
					WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD='#rwPre##arguments.customElementFieldName##rwPost#' LIST="#arguments.item#" CFSQLTYPE="cf_sql_varchar" SEPARATOR="#arguments.itemListDelimiter#"> 
					<!--- WHERE #arguments.customElementFieldName# IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">) --->
				<cfelse>
					WHERE #rwPre##arguments.customElementFieldName##rwPost# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
				</cfif>
			</cfif>
		</cfquery>
	
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	
	<cfscript>
		// Check if we are processing the selected list
		if ( ceViewQry.RecordCount GT 1 AND len(arguments.customElementFieldName) and listlen(arguments.item,arguments.ItemListDelimiter) GT 1 ) 
		{
			// Order the return data by the order the list was passed in
			// --IMPORTANT: We CAN NOT use the local 'variables.data.QuerySortByOrderedList' since this LIB is extended by the general_chooser.cfc
			ceViewQry = server.ADF.objectFactory.getBean("data_1_2").QuerySortByOrderedList(query=ceViewQry, 
																							   columnName=arguments.customElementFieldName, 
																							   columnType="varchar",
																							   orderList=arguments.item,
																								orderListDelimiter = arguments.ItemListDelimiter);
		} 
	</cfscript>
	
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewList
Summary:
	Queries the CE Data View table for the Query Type of "LIST".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - customElementFieldName - Element Field Name
	String - item - Item Values find the records containing this values
	String - overrideViewTableName - Override for the view table to query
	String - itemListDelimiter - delimiter for the item values if a list is passed in
History:
	2013-07-03 - GAC - Created
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
	2014-02-21 - GAC - Added itemListDelimiter parameter
	2014-03-05 - JTP - Var declarations
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewList" access="public" returntype="Query" output="true" hint="Queries the CE Data View table for the Query Type of 'List'.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfargument name="itemListDelimiter" type="string" required="false" default=",">
	
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
		var getListItemIDs = '';
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>

	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName# dvt
			WHERE  PageID IN (	SELECT DISTINCT PageID
								FROM  Data_FieldValue dfv
								WHERE dfv.listID IN (	SELECT DISTINCT listID 
														FROM  Data_ListItems
														WHERE pageID = dfv.PageID
														<cfif ListLen(arguments.item,arguments.itemListDelimiter) GT 1>
															AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="StrItemValue" LIST="#preserveSingleQuotes(arguments.item)#" CFSQLTYPE="cf_sql_varchar" SEPARATOR="#arguments.itemListDelimiter#">
															<!--- AND StrItemValue IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#preserveSingleQuotes(arguments.item)#" list="true">) --->
														<cfelseif ListLen(arguments.item) EQ 1>
															AND StrItemValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
														</cfif>
													)
								AND   FormID = dvt.FormID
								AND   VersionState = 2
								AND   PageID <> 0
							)
		</cfquery>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEDataViewNumericList
Summary:
	Queries the CE Data View table for the Query Type of "NumericList".
Returns:
	Query
Arguments:
	String - customElementName - Custom Element Name
	String - customElementFieldName - Element Field Name
	String - item - Item Values find the records containing this values
	String - overrideViewTableName - Override for the view table to query
	String - itemListDelimiter - delimiter for the item values if a list is passed in
History:
	2013-07-03 - GAC - Created
	2014-01-03 - GAC - Updated SQL 'IN' statements to use the CS module 'handle-in-list.cfm'
	2014-02-21 - GAC - Added itemListDelimiter parameter
	2014-06-05 - GAC - Updated to use the getCEViewName method instead of the DEPRECATED getViewTableName method
	2014-10-09 - GAC - Update to use the ADF 1.8 SQL View Naming convention: "vCE_{CustomElementName}"
--->
<cffunction name="getCEDataViewNumericList" access="public" returntype="Query" output="true" hint="Queries the CE Data View table for the Query Type of 'NumericList'.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfargument name="itemListDelimiter" type="string" required="false" default=",">
	
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getCEViewName(ceName=arguments.customElementName,type="adfversion",version=getSQLViewNameADFVersion());
	</cfscript>
	
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName# dvt
			WHERE  PageID IN (	SELECT DISTINCT PageID 
								FROM  Data_FieldValue dfv
								WHERE dfv.listID IN (	SELECT DISTINCT listID 
														FROM  Data_ListItems
														WHERE pageID = dfv.PageID
														AND <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="NumItemValue" LIST="#arguments.item#" SEPARATOR="#arguments.itemListDelimiter#">
														<!--- AND   NumItemValue IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item#" list="true">) --->
													)
								AND   FormID = dvt.FormID
								AND   VersionState = 2
								AND   PageID <> 0
							)
		</cfquery>
		<cfcatch>
			<cfdump var="#cfcatch#" label="cfcatch" expand="false">
		</cfcatch>
	</cftry>
	<cfreturn ceViewQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getDataFieldValue
Summary:
	Returns the query from data_fieldValue based on the pageid
Returns:
	Query
Arguments:
	String - pageID
	String - formID
History:
	2013-01-04 - MFC - Created
	2013-07-01 - GAC - Added a formID parameter to prevent bad data from being returned by the getDataFieldValueQry query.
	2014-01-03 - TP - Converted the SQL 'IN' statement to use the CS handle-in-list module
--->
<cffunction name="getDataFieldValue" access="public" returntype="query" hint="Returns Page ID Query in Data_FieldValue matching Form ID">
	<cfargument name="pageID" type="string" required="true">
	<cfargument name="formID" type="string" required="false" default="">
	
	<cfscript>
		// Initialize the variables
		var getDataFieldValueQry = queryNew("temp");
	</cfscript>

	<cfquery name="getDataFieldValueQry" datasource="#request.site.datasource#">
		SELECT PageID, FormID, FieldID, fieldValue, memoValue
		FROM Data_FieldValue
		<cfif ListLen(arguments.pageID) GT 1>
			WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="PageID" LIST="#arguments.pageID#">
		<cfelse>
			WHERE PageID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#VAL(arguments.pageID)#">
		</cfif>
		<cfif LEN(TRIM(arguments.formID)) AND IsNumeric(arguments.formID)>
			AND FormID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.formID#">
		</cfif>
		AND VersionState = 2
		AND PageID <> 0
	</cfquery>
	
	<cfreturn getDataFieldValueQry>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getGlobalCustomElements
Summary:
	Returns a query of the active global CE's.
Returns:
	query
Arguments:
	Void
History:
	2012-11-07 - MFC - Created
--->
<cffunction name="getGlobalCustomElements" access="public" returntype="query" output="false">
	<cfscript>
		// Initialize the variables
		var csQry = QueryNew("temp");
	</cfscript>
	<cfquery name="csQry" datasource="#request.site.datasource#">
		SELECT	AvailableControls.ID, 
				AvailableControls.ShortDesc AS FormName
		FROM 	AvailableControls 
					INNER JOIN FormControlMap ON AvailableControls.ID = FormControlMap.FormID
		WHERE 	FormControlMap.ClassID = 1
		AND 	AvailableControls.ElementState = 0
		ORDER BY FormName ASC
	</cfquery>
	<cfreturn csQry>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	$arrayOfCEDataToQuery
Summary:
	Returns Query from a Custom Element Array of Structures
Returns:
	Query
Arguments:
	Array - theArray
	Boolean - excludeFICfields
	String - excludeTopLevelFieldList
History:
	2013-10-15 - GAC - Sets the "excludeFICfields" function to true to remove FIC_ feilds by default (if no value is passed in)
					 - Calls the SUPER function in cedata_1_0 to convert the array to a query
					 - Sets the excludeTopLevelFieldList with a default value list of 'ID,recordcount' 
					 	which are not generally not needed when converting a CE Data Array to a query
--->
<cffunction name="arrayOfCEDataToQuery" returntype="query" output="true" access="public" hint="Returns Query from a Custom Element Array of Structures">
	<cfargument name="theArray" type="array" required="true">
	<cfargument name="excludeFICfields" type="boolean" required="false" default="true">
	<cfargument name="excludeTopLevelFieldList" type="string" required="false" default="id,recordcount"> 
	<cfscript>
		return super.arrayOfCEDataToQuery(theArray=arguments.theArray, excludeFICfields=arguments.excludeFICfields, excludeTopLevelFieldList=arguments.excludeTopLevelFieldList);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
	G. Cronkright
Name:
	getCEViewName
Summary:
	Creates the SQL view name for the build view method
Returns:
	boolean
Arguments:
	String  ceName
	String  type
	String  version
	String  viewPrefix
	String  viewSuffix
History:
	2013-12-02 - GAC - Updated to create 30 character or less view names for Oracle
	2013-12-06 - DRM - Copied from ptCalendar app
	2014-02-18 - GAC - Updated logic to test for Oracle DB before testing character limit of the view name 
	2014-05-21 - GAC - Added parameters to the getCEViewName to handle backwards compatibility for SQL view naming conventions used in older ADF versions.
					   and to allow for custom naming conventions by passing in custom prefix and/or suffix
--->
<cffunction name="getCEViewName" access="public" returntype="string" output="false">
	<cfargument name="ceName" type="string" required="true">
	<cfargument name="type" type="string" required="false" default="Default" hint="View Name Type. Options: Default, FormID, ADFversion, Custom">
	<cfargument name="version" type="string" required="false" default="" hint="Optional: For use with Type=ADFversion. Pass in an ADF version number to set SQL View Naming convention for the specified version. Ignored if Type is not set to ADFversion."> 
	<cfargument name="viewPrefix" type="string" required="false" default="" hint="Optional: For use with Type=Custom. Custom SQL View Name Prefix. Ignored if Type is not set to custom.">
	<cfargument name="viewSuffix" type="string" required="false" default="" hint="Optional: For use with Type=Custom. Custom SQL View Name Suffix. Ignored if Type is not set to custom.">

	<cfscript>
		var retViewName = TRIM(arguments.ceName);
		var oracleCharLimit = 30; // Oracle VIEW name character limitation
		var dbType = Request.Site.SiteDBType;
		var viewNameTypeOptions = "Default,FormID,ADFversion,Custom";
		var defaultADFversion = application.ADF.version; // Default version of the ADF SQL View Naming convention
		var throwErrorMsg = "";
		
		if ( ListFindNoCase(viewNameTypeOptions,arguments.type,",") EQ 0 )
			arguments.type = "Default";
		
		if ( LEN(arguments.version) EQ 0 )
			arguments.version = defaultADFversion;
			
		switch ( arguments.type )
		{
			 case "FormID":
		         retViewName = getCEFormIdViewName(ceName=arguments.ceName);
		         break;
		    case "ADFversion":
		       	 retViewName = getCEViewNameMigrate(ceName=arguments.ceName,adfVersion=arguments.version);
		         break;
		    case "Custom":
		       	 retViewName = getCEViewNameCustom(ceName=arguments.ceName,viewPrefix=arguments.viewPrefix,viewSuffix=arguments.viewSuffix);
		         break;
		    default: 
		    	 retViewName = getCEViewNameMigrate(ceName=arguments.ceName,adfVersion=defaultADFversion);
		}
		
		// If needed, check for valid oracle character view name length
		if ( dbType EQ "Oracle" AND LEN(retViewName) GT oracleCharLimit )
		{
			// Throw error that the ceName to use as a viewName for Oracle
			throwErrorMsg = "[ceData.getCEViewName] Custom element name with prefix and suffix has a total of #LEN(retViewName)# characters which is longer than the #oracleCharLimit# character limit for an Oracle view.";

			server.ADF.objectFactory.getBean("utils_1_2").doThrow(message=throwErrorMsg,logerror=true);
			//server.ADF.objectFactory.getBean("utils_1_2").logAppend(throwErrorMsg);	
		}
		
		return retViewName;
	</cfscript>	
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEViewNameMigrate
Summary:
	Returns a string for the SQL view name based on the version of the ADF that is passed in
	
	Default: 1.5 (ADF 1.5 ceData_1_1)
	Example: "ce_{CustomElementName}View"
	
	Option: 1.6  (ADF 1.6 ceData_2_0)
	Example: "ce_view_{CustomElementFormID}"
	
	Option: 1.7 (ADF 1.7 ceData_2_0)
	Example: "ce_view_{CustomElementFormID}"
	
	Option: 1.8 (ADF 1.8)
	Example: "vCE_{CustomElementName}"
Returns:
	string
Arguments:
	string - ceName
History:
	2014-05-21 - GAC - Created
	2014-05-30 - GAC - Added addtional logic to handle bad versions or and empty version being passed in
	2014-11-21 - GAC - Moved the server.ADF.ojectFactory.getBean() call down in to the conditional logic
--->
<cffunction name="getCEViewNameMigrate" access="public" returntype="string" output="true" hint="Returns a string for the SQL view name based on the version of the ADF that is passed in">
	<cfargument name="ceName" type="string" required="false" default="">
	<cfargument name="adfVersion" type="string" required="false" default="" hint="Options: 1.5,1.6,1.7,1.8">
	<cfscript>
		var retFormID = 0;
		var retViewName = "";
		var defaultADFversion = application.ADF.version;
		var utilsLib = "utils_1_2";
		
		arguments.ceName = TRIM(arguments.ceName);
		arguments.adfVersion = TRIM(arguments.adfVersion);
		
		if ( LEN(arguments.adfVersion) EQ 0 OR IsNumeric(ListFirst(arguments.adfVersion,".")) EQ 0 ) 
			arguments.adfVersion = defaultADFversion;
		
		// If the passed in version is less than 1.6  then use the ADF 1.5 SQL View Name convention
		if ( server.ADF.objectFactory.getBean(utilsLib).versionCompare(versionA=arguments.adfVersion,versionB="1.6") LT 0 )
		{
			// Generate the view name using the ADF 1.5 SQL View Name convention
			retViewName = getCEViewNameADF_1_5(ceName=arguments.ceName);
		}
		// If the passed in version is less than 1.8  then use the ADF 1.6 SQLView Name convention
		else if (  server.ADF.objectFactory.getBean(utilsLib).versionCompare(versionA=arguments.adfVersion,versionB="1.8") LT 0 )
		{
			// Generate the view name using the ADF 1.6 & 1.7 SQL View Name convention
			retViewName = getCEViewNameADF_1_6(ceName=arguments.ceName);
		}
		else
		{
			// Generate the view name using the future ADF 1.8 SQL View Name convention "vCE_{CustomElementName}"
			retViewName = getCEViewNameADF_1_8(ceName=arguments.ceName);
		}

		return retViewName;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEViewNameADF_1_5
Summary:
	Returns a string for the SQL view name that uses the ADF 1.5 view naming convention
	
	Example: "ce_{CustomElementName}View"
Returns:
	string
Arguments:
	string - ceName
History:
	2014-05-21 - GAC - Created
--->
<cffunction name="getCEViewNameADF_1_5" access="public" returntype="string" output="true" hint="Returns a string for the SQL view name that uses the ADF 1.5 view naming convention. (Example: ce_{CustomElementName}View)">
	<cfargument name="ceName" type="string" required="false" default="">
	<cfscript>
		var retViewName = "";
		var vNamePrefix = "ce_";
		var vNameSuffix = "View";

		arguments.ceName = TRIM(arguments.ceName);
		
		// Concatenate the prefix, ce name and the suffix
		retViewName = vNamePrefix & arguments.ceName & vNameSuffix;
		// Convert space in element to underscores
		retViewName = reReplace(TRIM(retViewName), "[\s]", "_", "all");
		
		return retViewName;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEViewNameADF_1_6
Summary:
	Returns a string for the SQL view name that uses the ADF 1.6 & 1.7 view naming convention
	
	Example: "ce_view_{CustomElementFormID}"
Returns:
	string
Arguments:
	string - ceName
History:
	2014-05-21 - GAC - Created
--->
<cffunction name="getCEViewNameADF_1_6" access="public" returntype="string" output="true" hint="Returns a string for the SQL view name that uses the ADF 1.6 view naming convention. (Example: ce_{CustomElementName}View)">
	<cfargument name="ceName" type="string" required="false" default="">
	<cfscript>
		arguments.ceName = TRIM(arguments.ceName);
		
		return getCEFormIdViewName(ceName=arguments.ceName);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEViewNameADF_1_8
Summary:
	Returns a string for the SQL view name that uses the ADF 1.8 view naming convention
	
	Example: "vCE_{CustomElementName}"
Returns:
	string
Arguments:
	string - ceName
History:
	2014-05-30 - GAC - Created
--->
<cffunction name="getCEViewNameADF_1_8" access="public" returntype="string" output="true" hint="Returns a string for the SQL view name that uses the ADF 1.8 view naming convention. (Example: ce_{CustomElementName}View)">
	<cfargument name="ceName" type="string" required="false" default="">
	<cfscript>
		var retViewName = "";
		var vNamePrefix = "vCE_";
		
		arguments.ceName = TRIM(arguments.ceName);
		
		// Concatenate the prefix, ce name and the suffix
		retViewName = vNamePrefix & arguments.ceName;
		// Convert space in element to underscores
		retViewName = reReplace(TRIM(retViewName), "[\s]", "_", "all");
		
		return retViewName;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEViewNameCustom
Summary:
	Returns a string for the SQL view name that use a user defined prefix and suffix around the Custom Element name
	
	Fall back to the ADF 1.8 (future) naming convention if no custom prefix and suffix values are passed in
	
	Example: "{viewPrefix}{CustomElementName}(viewSuffix)"
Returns:
	string
Arguments:
	string - ceName
History:
	2014-05-30 - GAC - Created
--->
<cffunction name="getCEViewNameCustom" access="public" returntype="string" output="true" hint="Returns a string for the SQL view name that use a user defined prefix and suffix around the Custom Element name">
	<cfargument name="ceName" type="string" required="false" default="">
	<cfargument name="viewPrefix" type="string" required="false" default="" hint="Optional: Custom SQL View Name Prefix. Default: vCE_">
	<cfargument name="viewSuffix" type="string" required="false" default="" hint="Optional: Custom SQL View Name Suffix.">
	<cfscript>
		var retViewName = TRIM(arguments.ceName);
		
		arguments.viewPrefix = TRIM(arguments.viewPrefix);
		arguments.viewSuffix = TRIM(arguments.viewSuffix);
		
		// If no custom prefix and suffix are passed in then use the 1.8 naming convention
		if ( LEN(arguments.viewPrefix) EQ 0 AND LEN(arguments.viewSuffix) EQ 0  )
			retViewName = getCEViewNameADF_1_8(ceName=retViewName);
		else
		{
			// Concatenate the prefix, ce name and the suffix
			retViewName = TRIM(arguments.viewPrefix) & TRIM(arguments.ceName) & TRIM(arguments.viewSuffix);
			// Convert space in element to underscores
			retViewName = reReplace(TRIM(retViewName), "[\s]", "_", "all");
		}
		
		return retViewName;
	</cfscript>
</cffunction>


<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEFormIdViewName
Summary:
	By default returns a string for the SQL view name that s prefixed with "ce_view_" and appends the CE Form ID 
	
	Example: "ce_view_{CustomElementFormID}"
	
	The arguments allow to either pass in the CE Form ID or the CE Form Name.	
Returns:
	string
Arguments:
	numeric - ceFormID
	string - ceFormID
	string - viewPrefix
	string - viewSuffix
History:
	2013-01-04 - MFC - Created
	2014-05-21 - GAC - Updated to rename method and change parameter names
					 - Updated to add error logging
					 - Updated to add new parameters to set the view prefix and suffix
	2014-07-28 - GAC - Updated the logic and the function name in the logged error message
--->
<cffunction name="getCEFormIdViewName" access="public" returntype="string" output="true" hint="By default returns a string for the SQL view name that s prefixed with 'ce_view_' and appends the CE Form ID. (Example: ce_view_{CustomElementFormID})">
	<cfargument name="ceFormID" type="numeric" required="false" default="0" hint="Pass the formID. Not needed if passing the  CE Name.">
	<cfargument name="ceName" type="string" required="false" default="" hint="Pass the Custom Element Name. Not needed if passing the Form ID.">
	<cfargument name="viewPrefix" type="string" required="false" default="ce_view_" hint="Default: ce_view_">
	<cfargument name="viewSuffix" type="string" required="false" default="" hint="Default: {empty string}">
	<cfscript>
		var retFormID = 0;
		var retViewName = "";
		var vNamePrefix = "ce_view_";
		var vNameSuffix = "";

		arguments.ceName = TRIM(arguments.ceName);
		
		if ( LEN(arguments.viewPrefix) NEQ 0 )
			vNamePrefix=arguments.viewPrefix;
		
		if ( LEN(arguments.viewSuffix) NEQ 0 )
			vNameSuffix=arguments.viewSuffix;

		// Check the arguments that are passed in
		if ( arguments.ceFormID GT 0 )
			retFormID = arguments.ceFormID;
		else if ( LEN(arguments.ceName) )
			retFormID = getFormIDByCEName(ceName=arguments.ceName);
		
		// Check that we have a form ID before hand
		if ( IsNumeric(retFormID) AND retFormID GT 0 )
		{
			// Concatinate the prefix, formid and the suffix
			retViewName = TRIM(vNamePrefix & retFormID & vNameSuffix);
			// Convert space in element to underscores
			retViewName = reReplace(retViewName, "[\s]", "_", "all");
			
			return retViewName;
		}
		else 
		{ 
			// Error message
			if ( LEN(TRIM(arguments.ceName)) )
				throwErrorMsg = "[ceData.getCEFormIdViewName] No form ID was returned for provided custom element: '#arguments.ceName#'. Can not create a valid view name.";
			else
				throwErrorMsg = "[ceData.getCEFormIdViewName] Can not create a valid view name. (FormID: '#arguments.ceFormID#')";
				
			// Throw and Log error
			server.ADF.objectFactory.getBean("utils_1_2").doThrow(message=throwErrorMsg,logerror=true);	
			//server.ADF.objectFactory.getBean("utils_1_2").logAppend(throwErrorMsg);	
			
			// If error is thrown return an empty string
			return "";
		}
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	G. Cronkright
Name:
	$verifyViewTableExists
Summary:
	Verifies that a CE View Table exists, if one does not exist then it attempt to build one.
Returns:
	boolean
Arguments:
	String - customElementName
	String - viewTableName
	Struct - fieldTypes
	Boolean - forceRebuild
History:
	2013-01-29 - GAC - Created
	2013-11-18 - GAC - Added a dbType logic to add additional 'table_schema' criteria for MySQL
					 - Added different table schema name for Oracle (thanks DM)
					 - Added logging to the CFCatch rather than just returning false
	2013-11-18 - GAC - Converted to use the generic data_1_2.verifyTableExists
	2013-12-16 - DRM - Updated to call "buildView" which now handles the building or rebuild of the Views
--->
<!--- // DEPRECATED - please use buildView() --->
<cffunction name="verifyViewTableExists" access="public" returntype="boolean" output="false" hint="Verifies that a CE View Table exists, if one does not exist then it attempt to build one.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="viewTableName" type="string" required="false" default="">
	<cfargument name="fieldTypes" type="struct" default="#structNew()#">
	<cfargument name="forceRebuild" type="boolean" default="false">
	<cfscript>
		return buildView(ceName=arguments.customElementName, viewName=arguments.viewTableName, fieldTypes=arguments.fieldTypes, forceRebuild=arguments.forceRebuild);
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
Name:
	$getCEViewTableName
Summary:
	Returns a string for the view table name.
	The table name is prefixed with "ce_view_" and based on the CE form ID.
	Sample = "ce_view_#CUSTOM-ELEMENT-FORM-ID#"
	
	The arguments allow to either pass in the CE Form ID or the CE Form Name.	
Returns:
	string
Arguments:
	numeric - customElementFormID
	string - customElementName
History:
	2013-01-04 - MFC - Created
--->
<!--- // DEPRECATED - please use getCEFormIdViewName(ceFormID,ceName) --->
<cffunction name="getViewTableName" access="public" returntype="string" output="true">
	<cfargument name="customElementFormID" type="numeric" required="false" default="0">
	<cfargument name="customElementName" type="string" required="false" default="">
	<cfscript>
		return getCEFormIdViewName(ceFormID=arguments.customElementFormID,ceName=arguments.customElementName);
	</cfscript>
</cffunction>

</cfcomponent>