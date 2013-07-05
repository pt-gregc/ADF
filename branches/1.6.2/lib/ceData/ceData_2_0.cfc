<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2013.
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
	ceData_1_2.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	2.0
History:
	2012-12-31 - MFC - Created - New v2.0
	2013-07-03 - GAC - Added getCEDataViewList and getCEDataViewNumericList functions to be used by the getCEDataView function
--->
<cfcomponent displayname="ceData_2_0" extends="ADF.lib.ceData.ceData_1_1" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="2_0_6">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_2">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="wikiTitle" value="CEData_1_2">

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
		var commonFieldList = "pageID,formID";
		var fieldStruct = structNew();
		var queryColFieldList = ""; // List to store the column names
		var queryColPos = "";
		// Sort the column name list to be safe
		var origQueryColFieldList = ListSort(arguments.ceDataQuery.columnList, "textnocase");
		
		// Check that we have a query with values
		if ( arguments.ceDataQuery.recordCount GTE 1 ){
			// Setup the default common fields 
			// get the fields structure for this element
			fieldStruct = server.ADF.objectFactory.getBean("Forms_1_0").getCEFieldNameData(getCENameByFormID(arguments.ceDataQuery["formID"][1]));
		}
		
		// Check if the query column contains "FIC_" and remove
		for ( i=1; i LTE ListLen(origQueryColFieldList); i++ ){
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
				commonField = listGetAt(commonFieldList, i);
				// handle each of the common fields
				if( findNoCase(commonField, queryColFieldList) )
					tmp[commonField] = arguments.ceDataQuery[commonField][row];
				else
					tmp[commonField] = "";
				// do special case work for formID/formName
				if( commonField eq "formID" )
				{
					if( not len(formName) )
						formName = getCENameByFormID(tmp.formID);
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
	String ceName
	String viewName
History:
	2013-01-04 - MFC - Sets the view table name to the "getViewTableName" function if no
						value passed in.  Calls the SUPER function to create the table.
	2013-01-29 - GAC - Updated the getViewTableName logic so it creates a view table name if a viewName is NOT passed in
--->
<cffunction name="buildRealTypeView" access="public" returntype="boolean" hint="Builds ane lement view for the passed in element name">
	<cfargument name="elementName" type="string" required="true" hint="element name to build the view table off of">
	<cfargument name="viewName" type="string" required="false" default="" hint="Override the view name that gets generated">
	<cfscript>
		// Set the view table name from the elementName if a viewName is NOT passed in
		if ( LEN(TRIM(arguments.viewName)) EQ 0 )
			arguments.viewName = getViewTableName(customElementName=arguments.elementName);
		// Call the SUPER function to build the view table
		return super.buildRealTypeView(elementName=arguments.elementName, viewName=arguments.viewName);
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
--->
<cffunction name="getCEData" access="public" returntype="array" hint="Returns array of structs for all data matching the Custom Element.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="any" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="searchFields" type="string" required="false" default="">

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
		
		if (LEN(arguments.customElementFieldName) OR Len(arguments.searchFields)) {
			// check if queryType is Search
			if ( arguments.queryType EQ "search" OR arguments.queryType EQ "multi" ) {
				// get the id's for each item in the list and create a new list of id's
				for (data_i=1; data_i LTE ListLen(arguments.searchFields); data_i=data_i+1){
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
			pageIDValueQry = getPageIDForElement(ceFormID, ceFieldID, arguments.item, "selected", arguments.searchValues, searchCEFieldID);
		else
			pageIDValueQry = getPageIDForElement(ceFormID, ceFieldID, arguments.item, arguments.queryType, arguments.searchValues, searchCEFieldID);
		
		// Get the default structure for the element fields
		// Build the query row for the default field values
		ceDefaultFieldQry = defaultFieldQuery(ceFormID=ceFormID);
		ceFieldQuery = getElementFieldsByFormID(formID=ceFormID);
		
		// Get the mapping of field ID's to Field Names
		//	Example: ceFieldIDNameMap[1011] = "myFieldName"
		ceFieldIDNameMap = StructNew();
		for ( i=1; i LTE ceFieldQuery.recordCount; i++ ){
			ceFieldIDNameMap[ceFieldQuery.fieldID[i]] = Replace(ceFieldQuery.fieldName[i], "FIC_", "");
		}
	
		// Build in the initial query for the CE Data storage
		ceDataQry = duplicate(ceDefaultFieldQry);
		getDataPageValueQry = getDataFieldValue(pageID=ValueList(pageIDValueQry.pageID),formid=ceFormID);
	</cfscript>
	
	<cfquery name="distinctPageIDQry" dbtype="query">
		SELECT 	DISTINCT PageID
		FROM 	getDataPageValueQry
	</cfquery>
	
	<cfif distinctPageIDQry.RecordCount gt 0 >
		<!--- Loop over the query of page ids --->
		<cfloop query="distinctPageIDQry">
			<cfset currPageIDDataQry = "">
			<cfquery name="currPageIDDataQry" dbtype="query">
				SELECT *
				FROM   getDataPageValueQry
				WHERE  pageid = #distinctPageIDQry.pageid#
			</cfquery>
			<cfif currPageIDDataQry.recordCount>
				<!--- Create the data set to be added back in --->
				<!--- Add a new row --->
				<cfset newRow = QueryAddRow(ceDataQry)>
				
				<!--- Loop over the sub query and set the data into the query row --->
				<cfloop query="currPageIDDataQry">
					<!--- Set the PageID and FormID --->
					<cfset QuerySetCell(ceDataQry, "pageID", currPageIDDataQry.pageID, newRow)>
					<cfset QuerySetCell(ceDataQry, "formID", currPageIDDataQry.formID, newRow)>
					<!--- Check if the value is in the Field ID Name Map --->
					<cfif StructKeyExists(ceFieldIDNameMap, currPageIDDataQry.fieldID)>
						<!--- Get the field ID to the set the column field name --->
						<cfset currFieldName = ceFieldIDNameMap[currPageIDDataQry.fieldID]>
						<cfif LEN(currPageIDDataQry.memoValue)>
							<cfset QuerySetCell(ceDataQry, currFieldName, currPageIDDataQry.memoValue, newRow)>
						<cfelse>
							<cfset QuerySetCell(ceDataQry, currFieldName, currPageIDDataQry.fieldValue, newRow)>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cfif>
	<cfscript>
		// Check if we are processing the selected list
		if ( arguments.queryType EQ "selected" and len(arguments.customElementFieldName) and len(arguments.item) ){
			// Order the return data by the order the list was passed in
			ceDataQry = application.ADF.data.querySort(query=ceDataQry, 
													   columnName=arguments.customElementFieldName, 
													   columnType="varchar",
													   orderList=arguments.item);
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
History:
	2013-01-04 - MFC - Created
	2013-04-02 - MFC - Added call to verify if the view table exists and create the view.
	2013-07-03 - GAC - Added support for the "list" and "numericList" queryTypes 
--->
<cffunction name="getCEDataView" access="public" returntype="array" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="searchFields" type="string" required="false" default="">
	<cfscript>
		var viewTableName = getViewTableName(customElementName=arguments.customElementName);
		var ceViewQry = QueryNew("null");
		var dataArray = ArrayNew(1);
		var viewTableExists = false;
		
		try {
			
			// Verify if the view table exists, create if doesn't exists
			viewTableExists = verifyViewTableExists(customElementName=arguments.customElementName,
													viewTableName=viewTableName);
			
			// TIMER START
			//a2 = GetTickCount();
			
			if ( viewTableExists ) {
				
				// Switch Case based on the query type
				switch (arguments.queryType){
				
					case "selected":
						ceViewQry = getCEDataViewSelected(customElementName=arguments.customElementName,
														  customElementFieldName=arguments.customElementFieldName,
														  item=arguments.item,
														  overrideViewTableName=viewTableName);
						break;
					case "notSelected":
						ceViewQry = getCEDataViewNotSelected(customElementName=arguments.customElementName,
														     customElementFieldName=arguments.customElementFieldName,
														  	 item=arguments.item,
														     overrideViewTableName=viewTableName);
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
						// To make backwards compatiable, check if the "searchFields" are passed in the "customElementFieldName" arg.
						if ( LEN(arguments.searchFields) EQ 0 AND LEN(arguments.customElementFieldName) GT 0 )
							arguments.searchFields = arguments.customElementFieldName;
						// To make backwards compatiable, check if the "searchValues" are passed in the "items" arg.
						if ( LEN(arguments.searchValues) EQ 0 AND LEN(arguments.item) GT 0 )
							arguments.searchValues = arguments.item;
					
						ceViewQry = getCEDataViewSearchInList(customElementName=arguments.customElementName,
															  searchFields=arguments.searchFields,
															  searchValues=arguments.searchValues,
														  	  overrideViewTableName=viewTableName);
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
												  	   overrideViewTableName=viewTableName);
						break;	
					case "numericList":
						ceViewQry = getCEDataViewNumericList(customElementName=arguments.customElementName,
													  		 customElementFieldName=arguments.customElementFieldName,
													  		 item=arguments.item,
												  	   		 overrideViewTableName=viewTableName);
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
														 overrideViewTableName=viewTableName);
						break;
				}
				
				// TIMER END
				//b2 = GetTickCount();
				//timer2 = "getCEDataView - Query Timer = " & b2-a2;
				//application.ADF.utils.dodump(ceViewQry, "ceViewQry", false);	
				
			}
			else {
				throw(message="View Table Does Not Exist", detail="View Table Does Not Exist");	
			}
		}
		catch (ANY exception){
			application.ADF.utils.dodump(exception, "CFCATCH", false);	
		}
		
		if ( ceViewQry.recordCount ) {
			// Check if we are processing the selected list
			if ( arguments.queryType EQ "selected" and len(arguments.customElementFieldName) and len(arguments.item) ){
				// Order the return data by the order the list was passed in
				ceViewQry = application.ADF.data.querySort(query=ceViewQry, 
														   columnName=arguments.customElementFieldName, 
														   columnType="varchar",
														   orderList=arguments.item);
			}
			// Flip the query back into the CE Data Array Format
			dataArray = buildCEDataArrayFromQuery(ceDataQuery=ceViewQry);
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
History:
	2013-01-11 - MFC - Created
--->
<cffunction name="getCEDataViewBetween" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	<cftry>
		<!--- Check the ITEMS arg is correct with 2 values for the span --->
		<cfif ListLen(arguments.item) EQ 2>
			<cfquery name="ceViewQry" datasource="#request.site.datasource#">
				SELECT *
				FROM   #viewTableName#
				<cfif ListLen(arguments.item) EQ 2>
					WHERE  #arguments.customElementFieldName# > <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListFirst(arguments.item)#">
					AND    #arguments.customElementFieldName# < <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(arguments.item)#">
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
--->
<cffunction name="getCEDataViewGreaterThan" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			WHERE  #arguments.customElementFieldName# > <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
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
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
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
History:
	2013-01-11 - MFC - Created
--->
<cffunction name="getCEDataViewNotSelected" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	<cftry>
		<!--- Check that the Arguments are specified --->
		<cfif LEN(arguments.customElementFieldName) AND LEN(arguments.item)>
			<cfquery name="ceViewQry" datasource="#request.site.datasource#">
				SELECT *
				FROM   #viewTableName#
				<!--- Check if the items are a list --->
				<cfif ListLen(arguments.item) GT 1>
					WHERE #arguments.customElementFieldName# NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">)
				<cfelse>
					WHERE #arguments.customElementFieldName# <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
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
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
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
				AND pageid NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#excludePageIDList#" list="true">)
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
History:
	2013-01-11 - MFC - Created
--->
<cffunction name="getCEDataViewSearchInList" access="public" returntype="Query" output="true">
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
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			<!--- Loop over the list of fields to build search cases --->
			<cfloop from="1" to="#ListLen(arguments.searchValues)#" index="currFieldNum">
				<!--- Check if the first condition, or just adding on --->
				<cfif currFieldNum EQ 1>
					WHERE
				<cfelse>
					AND
				</cfif>
				( #arguments.searchFields# LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ListGetAt(arguments.searchValues,currFieldNum)#%"> )
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
History:
	2013-01-11 - MFC - Created
--->
<cffunction name="getCEDataViewSelected" access="public" returntype="Query" output="true">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName#
			<!--- Check if the items are a list --->
			<cfif ListLen(arguments.item) GT 1>
				WHERE #arguments.customElementFieldName# IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">)
			<cfelseif ListLen(arguments.item) EQ 1>
				WHERE #arguments.customElementFieldName# = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
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
History:
	2013-07-03 - GAC - Created
--->
<cffunction name="getCEDataViewList" access="public" returntype="Query" output="true" hint="Queries the CE Data View table for the Query Type of 'List'.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	
	<!--- // queryType eq list get the listID's first that match the input --->
	<!--- <cfquery name="getListItemIDs" datasource="#request.site.datasource#">
		SELECT DISTINCT listID
		FROM data_listItems
		WHERE strItemValue in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#preserveSingleQuotes(arguments.item)#" list="true">)
	</cfquery> --->
	
	<cftry>
		<cfquery name="ceViewQry" datasource="#request.site.datasource#">
			SELECT *
			FROM   #viewTableName# dvt
			WHERE  PageID IN (	SELECT DISTINCT PageID
								FROM  Data_FieldValue dfv
								WHERE dfv.listID IN (	SELECT DISTINCT listID 
														FROM  Data_ListItems
														WHERE pageID = dfv.PageID
														<cfif ListLen(arguments.item) GT 1>
															AND StrItemValue IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#preserveSingleQuotes(arguments.item)#" list="true">)
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
History:
	2013-07-03 - GAC - Created
--->
<cffunction name="getCEDataViewNumericList" access="public" returntype="Query" output="true" hint="Queries the CE Data View table for the Query Type of 'NumericList'.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="string" required="false" default="">
	<cfargument name="overrideViewTableName" type="string" required="false" default="" hint="Override for the view table to query.">
	<cfscript>
		var viewTableName = "";
		var ceViewQry = QueryNew("null");
				
		// Set the override for the view table name if defined
		if ( LEN(arguments.overrideViewTableName) )
			viewTableName = arguments.overrideViewTableName;
		else
			viewTableName = getViewTableName(customElementName=arguments.customElementName);
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
														AND   NumItemValue IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item#" list="true">)
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
History:
	2013-01-04 - MFC - Created
	2013-07-01 - GAC - Added a formID parameter to prevent bad data from being returned by the getDataFieldValueQry query.
--->
<cffunction name="getDataFieldValue" access="public" returntype="query" hint="Returns Page ID Query in Data_FieldValue matching Form ID">
	<cfargument name="pageID" type="string" required="true">
	<cfargument name="formID" type="string" required="false" default="">
	
	<cfscript>
		// Initialize the variables
		var getDataFieldValueQry = queryNew("temp");
	</cfscript>

	<!--- <cfscript>
		a5 = GetTickCount();
	</cfscript> --->

	<cfquery name="getDataFieldValueQry" datasource="#request.site.datasource#">
		SELECT PageID, FormID, FieldID, fieldValue, memoValue
		FROM Data_FieldValue
		<cfif ListLen(arguments.pageID) GT 1>
			WHERE PageID IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.pageID#" list="true">)
		<cfelse>
			WHERE PageID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#VAL(arguments.pageID)#">
		</cfif>
		<cfif LEN(TRIM(arguments.formID)) AND IsNumeric(arguments.formID)>
			AND FormID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.formID#">
		</cfif>
		AND VersionState = 2
		AND PageID <> 0
	</cfquery>
	
	<!--- <cfscript>
		b5 = GetTickCount();
		timer5 = "getPageIDForElement - Query Timer = " & b5-a5;
	</cfscript>
	<cfdump var="#timer5#" label="getDataFieldValue - Query Timer" expand="false"> --->
	
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
<cffunction name="getGlobalCustomElements" access="public" returntype="query" output="true">

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
<cffunction name="getViewTableName" access="public" returntype="string" output="true">
	<cfargument name="customElementFormID" type="numeric" required="false" default="0">
	<cfargument name="customElementName" type="string" required="false" default="">
	<cfscript>
		var ceFormID = 0;
		// Check the arguments that are passed in
		if ( arguments.customElementFormID GT 0 )
			ceFormID = arguments.customElementFormID;
		else if ( LEN(arguments.customElementName) )
			ceFormID = getFormIDByCEName(CEName=arguments.customElementName);
		// Check that we have a form ID before hand
		if ( ceFormID GT 0 )
			return "ce_view_#ceFormID#";
		else 
			return "";
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
	
	--Tested with MySQL and MSSQL
Returns:
	boolean
Arguments:
	String - customElementName
	String - viewTableName
History:
	2013-01-29 - GAC - Created
--->
<cffunction name="verifyViewTableExists" access="public" returntype="boolean" output="false" hint="Verifies that a CE View Table exists, if one does not exist then it attempt to build one.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="viewTableName" type="string" required="false" default="">
	<cfscript>
		var verifySourceDB = QueryNew("temp");
		
		// Set the view table name if a viewTableName is not passed in
		if ( LEN(TRIM(arguments.viewTableName)) EQ 0 )
			arguments.viewTableName = getViewTableName(customElementName=arguments.customElementName);
	</cfscript>
	<cftry>
		<cfif LEN(TRIM(arguments.viewTableName))>
			<!--- // Check if the table exists in the Source DB --->
			<cfquery name="verifySourceDB" datasource="#Request.Site.DataSource#">
				SELECT 	* 
				  FROM 	INFORMATION_SCHEMA.TABLES 
	    		 WHERE 	TABLE_NAME = <cfqueryparam value="#arguments.viewTableName#" cfsqltype="cf_sql_varchar">
			</cfquery>
		</cfif>
		<!--- // Check that we don't have the table --->
		<cfif verifySourceDB.RecordCount LTE 0> 
			<!--- // Create the view from the Element --->
			<cfreturn buildRealTypeView(elementName=arguments.customElementName,viewName=arguments.viewTableName)>
		<cfelse>
			<cfreturn true>
		</cfif>
		<cfcatch>
			<cfreturn false>
		</cfcatch>
	</cftry>
</cffunction>

</cfcomponent>