<!--- 
The contents of this file are subject to the Mozilla Public License Version 1.1
(the "License"); you may not use this file except in compliance with the
License. You may obtain a copy of the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is comprised of the ADF directory

The Initial Developer of the Original Code is
PaperThin, Inc. Copyright(C) 2012.
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
	1.2
History:
	2012-12-31 - MFC - Created - New v1.2
--->
<cfcomponent displayname="ceData_1_2" extends="ADF.lib.ceData.ceData_1_1" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="1_2_1">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_2">
<cfproperty name="data" type="dependency" injectedBean="data_1_2">
<cfproperty name="wikiTitle" value="CEData_1_2">

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

</cfcomponent>