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
	ceData_1_0.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	1.0.1
History:
	2009-06-22 - MFC - Created
	2010-12-21 - MFC - v1.0.1 - Added buildRealTypeView and buildCEDataArrayFromQuery functions.
--->
<cfcomponent displayname="ceData_1_0" extends="ADF.core.Base" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="1_0_1">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_0">
<cfproperty name="data" type="dependency" injectedBean="data_1_0">
<cfproperty name="wikiTitle" value="CEData_1_0">

<!---
/**
* Sorts an array of structures based on a key in the structures.
*
* @param aofS       Array of structures.
* @param key        Key to sort by.
* @param sortOrder  Order to sort by, asc or desc.
* @param sortType   Text, textnocase, numeric, or time.
* @param delim      Delimiter used for temporary data storage. Must not exist in data. Defaults to a period.
* @param datefield  Used for time sorting, the basis for the construction of the array for sorting times.
* @return Returns a sorted array.
* @author Nathan Dintenfass (nathan@changemedia.com)
* @version 1, December 10, 2001
*/
--->
<cffunction name="arrayOfCEDataSort" access="public" returntype="array">
	<cfargument name="aOfS" type="array" required="true">
	<cfargument name="key" type="string" required="true">
	<cfargument name="sortOrder" type="string" required="false" default="asc">
	<cfargument name="sortType" type="string" required="false" default="textnocase">
	<cfargument name="delim" type="string" required="false">
	<cfargument name="datefield" type="string" required="false">

	<cfscript>
		//by default we'll use an ascending sort
        var sortOrder2 = "asc";
        //by default, we'll use a textnocase sort
        var sortType2 = "textnocase";
        //by default, use ascii character 30 as the delim
        var delim2 = ".";
		//if this is a time sort, then what is the date field? Default to "eventdate"
		var datefield2 = "eventdate";
        //make an array to hold the sort stuff
        var sortArray = arraynew(1);
        //make an array to return
        var returnArray = arraynew(1);
        //grab the number of elements in the array (used in the loops)
        var count = arrayLen(arguments.aOfS);
        //make a variable to use in the loop
        var ii = 1;
        //if there is a 3rd argument, set the sortOrder
        if(structKeyExists(arguments, 'sortOrder'))
            sortOrder2 = arguments.sortOrder;
        //if there is a 4th argument, set the sortType
        if(structKeyExists(arguments, 'sortType')){
			//If we are sorting by time then set the type to textnocase
			if (arguments.sortType eq 'time')
				sortType2 = 'textnocase';
			else
            sortType2 = arguments.sortType;
		}
        //if there is a 5th argument, set the delim
        if(structKeyExists(arguments, 'delim'))
            delim2 = arguments.delim;
        if(structKeyExists(arguments, 'datefield'))
            datefield2 = arguments.datefield;

        if(structKeyExists(arguments, 'sortType') AND arguments.sortType eq 'time'){
			//we are doing a time sort
			//loop over the array of structs, building the sortArray
			//construct the array using the date of the specified date field and the time portion of the specified key
			for(ii = 1; ii lte count; ii = ii + 1)
				sortArray[ii] = left(arguments.aOfS[ii].values[datefield2],11) & mid(arguments.aOfS[ii].values[arguments.key],11,11) & delim2 & ii;
		}
		else {
        //loop over the array of structs, building the sortArray
        for(ii = 1; ii lte count; ii = ii + 1)
            sortArray[ii] = arguments.aOfS[ii].values[arguments.key] & delim2 & ii;
		}

		//Application.ADF.utils.doDump(sortArray,"sortArray",0);
		//now sort the array
        arraySort(sortArray,sortType2,sortOrder2);
		//Application.ADF.utils.doDump(sortArray,"sortArray - sorted (#sortType2#,#sortOrder2#)",0);
        //now build the return array
        for(ii = 1; ii lte count; ii = ii + 1)
            returnArray[ii] = arguments.aOfS[listLast(sortArray[ii],delim2)];
        //return the array
		//Application.ADF.utils.doDump(returnArray,"returnArray",0);
        return returnArray;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$defaultFieldStruct
Summary:
	Given a Custom Element Name this function will build a default
	structure with the fields for that element
Returns:
	Struct fields
Arguments:
	String ceName
History:
	2009-03-02 - RLW - Created
	2009-05-01 - MFC - Updated: Updated the 'FIC_' logic
--->
<cffunction name="defaultFieldStruct" access="public" returntype="struct">
	<cfargument name="ceName" type="string" required="true">
	<cfscript>
		var fieldQuery = queryNew("fieldID,fieldName");
		var rtnStruct = structNew();
		// get the formID for this Custom Element
		var formID = getFormIDByCEName(arguments.ceName);
		var itm = 1;
		var thisField = "";
	
		if( (len(formID)) and (formID GT 0) )
		{
			// get the field query for this element
			fieldQuery = getElementFieldsByFormID(formID);
			// loop through the query and build the default structure
			for( itm=1; itm lte fieldQuery.recordCount; itm=itm+1 )
			{
				// replace the FIC_ from the beginning
				thisField = ReplaceNoCase(fieldQuery.fieldName[itm], "FIC_", "", "all");
				// add this field in
				if( not structKeyExists(rtnStruct, thisField) )
					rtnStruct[thisField] = "";
				// TODO would be nice to get the default data for this field
			}
		}
	</cfscript>
	<cfreturn rtnStruct>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$deleteCacheInstances
Summary:
	Given a Custom Element Name this function will delete the cache instance
	data from the TypedCacheInstances, TypedCacheQueries, and TypedCacheHits tables.
Returns:
	Void
Arguments:
	String ceName
History:
	2009-03-24 - MFC - Created
--->
<cffunction name="deleteCacheInstances" access="public" returntype="void">
	<cfargument name="ceName" type="string" required="true">
	<cfscript>
		var getCacheQueryID = queryNew("temp");
		var deleteCacheQueries = queryNew("temp");
		var deleteCacheHits = queryNew("temp");
		var deleteCacheInstances = queryNew("temp");
		var queryIDList = "";
		var ceFormID = getFormIDByCEName(arguments.ceName);
	</cfscript>
	<!--- get the cache query ID --->
	<cfquery name="getCacheQueryID" datasource="#request.site.datasource#">
		SELECT DISTINCT QueryID
		FROM         	TypedCacheInstances
		WHERE     		ControlTypeID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ceFormID#">
	</cfquery>
	<!--- check that we have records --->
	<cfif getCacheQueryID.RecordCount>
		<cfset queryIDList = "#ValueList(getCacheQueryID.QueryID)#">
		<!--- delete from TypedCacheQueries --->
		<cfquery name="deleteCacheQueries" datasource="#request.site.datasource#">
			DELETE FROM TypedCacheQueries
			WHERE     	QueryID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#queryIDList#" list="true"> )
		</cfquery>
		<!--- delete from TypedCacheQueries --->
		<cfquery name="deleteCacheHits" datasource="#request.site.datasource#">
			DELETE FROM TypedCacheHits
			WHERE     	QueryID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#queryIDList#" list="true"> )
		</cfquery>
		<!--- delete from TypedCacheInstances --->
		<cfquery name="deleteCacheInstances" datasource="#request.site.datasource#">
			DELETE FROM TypedCacheInstances
			WHERE     	QueryID IN ( <cfqueryparam cfsqltype="cf_sql_integer" value="#queryIDList#" list="true"> )
		</cfquery>
	</cfif>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$deleteByElementName
Summary:
	Delete the Custom Element records from the data_fieldvalue table given a Custom Element name
Returns:
	Boolean
Arguments:
	String CEName
History:
	2009-07-07 - RLW - created
	2009-08-12 - MFC - Updated: Add the check to csSecurity
	2009-10-22 - MFC - Updated: Changed Return Type Boolean
	2010-02-04 - MFC - Updated: Replaced the delete query with a call to the deleteCE function.
--->
<cffunction name="deleteByElementName" access="public" returntype="boolean" hint="Delete the Custom Element records from the data_fieldvalue table given a Custom Element name">
	<cfargument name="ceName" type="string" required="true">
	<cfscript>
		var deleteCEData = queryNew("temp");
		// get the formID for the Page Mapping element
		var formID = getFormIDByCEName(arguments.ceName);
		var pageIDs = getPageIDForElement(formID);
		// Verify the security for the logged in user
		if ( variables.csSecurity.isValidContributor() OR variables.csSecurity.isValidCPAdmin() ) {
			if ( listLen(valueList(pageIDs.pageID)) ){
				return deleteCE(valueList(pageIDs.pageID));
			}
		}
	</cfscript>
	<cfreturn false>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$deleteCE
Summary:
	Delete the Custom Element records from the data_fieldvalue table
Returns:
	Boolean
Arguments:
	Numeric - Form ID
	String - Data Page ID (list)
History:
	2009-02-26 - MFC - Created
	2009-08-12 - MFC - Updated: Add the check to csSecurity
	2009-10-22 - MFC - Updated: Changed Return Type Boolean
	2010-02-04 - MFC - Updated: Changed function to remove the query and make call
							to CS Module deletefieldvalue.
--->
<cffunction name="deleteCE" access="public" returntype="boolean">
	<cfargument name="datapageidList" type="string" required="true">

	<cfset var deleteCEData = queryNew("temp")>
	<cfset var i = 1>
	<cfset var currPageID = 1>
	<cfset var formID = 0>
	<cfset var elementFields = "">
	<!--- Verify the security for the logged in user --->
	<cfif variables.csSecurity.isValidContributor() OR variables.csSecurity.isValidCPAdmin()>
		<!--- Loop over the page id list --->
		<cftry>
			<cfloop index="i" from="1" to="#ListLen(datapageidList)#">
				<cfset currPageID = ListGetAt(datapageidList,i)>
				<cfset formID = getFormIDFromPageID(currPageID)>
				<cfset elementFields = getElementFieldsByFormID(formID)>
				<!--- Loop over the element fields --->
				<cfloop index="j" from="1" to="#elementFields.RecordCount#">
					<!------// delete field value //------->
					<CFMODULE template="/commonspot/metadata/tags/data_control/deletefieldvalue.cfm"
								dsn="#Request.Site.datasource#"
								id="#elementFields.FieldID[j]#"
								formID="#formID#"
								pageID="#currPageID#">
				</cfloop>
			</cfloop>
		<cfcatch>
			<!--- <cfdump var="#cfcatch#" label="cfcatch" expand="false"> --->
			<cfreturn false>
		</cfcatch>
		</cftry>
	</cfif>
	<cfreturn true>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
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
	2009-01-20 - MFC - Created
	2009-01-27 - MFC - Added searchValues argument.
	2009-04-08 - MFC - Updated:	Added new query type conditions for "versions". This will
									return all the version data for an element record
	2009-05-27 - MFC - Updated: Trim arguments.searchFields to remove whitespace when creating
									searchCEFieldName variable.
								Cleaned code and put in cfscript.
	2010-09-17 - MFC - Updated: Added new queryType for "searchInList".
								Find any of the items in a list that match a list item in a 
									CE field that stores a list of values.
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
		var dataArray = ArrayNew(1);
		var retQuery = "";
		var CEFormID = getFormIDByCEName(arguments.customElementName);
		var CEFieldID = "";
		var searchCEFieldName = "";
		var searchCEFieldID = "";
		var ceFieldName = "";
		var getPageIDValues = QueryNew("temp");
		var retTempDataArray = ArrayNew(1);
		
		if (LEN(arguments.customElementFieldName) OR Len(arguments.searchFields)) {
			// check if queryType is Search
			if ( arguments.queryType EQ "search" OR arguments.queryType EQ "multi" ) {
				// get the id's for each item in the list and create a new list of id's
				for (data_i=1; data_i LTE ListLen(arguments.searchFields); data_i=data_i+1){
					searchCEFieldName = "FIC_" & TRIM(ListGetAt(arguments.searchFields,data_i));
					searchCEFieldID = ListAppend(searchCEFieldID, getElementFieldID(CEFormID, searchCEFieldName));
				}
			}

			// convert the CE Field Name Arg to the field ID
			// check if the field name starts with 'FIC_'
			if (arguments.customElementFieldName CONTAINS "FIC_")
				CEFieldID = getElementFieldID(CEFormID, arguments.customElementFieldName);
			else
			{
				ceFieldName = "FIC_" & arguments.customElementFieldName;
				CEFieldID = getElementFieldID(CEFormID, ceFieldName);
			}
		}
		// special case for versions
		if ( arguments.queryType eq "versions" )
			getPageIDValues = getPageIDForElement(CEFormID, CEFieldID, arguments.item, "selected", arguments.searchValues, searchCEFieldID);
		else
			getPageIDValues = getPageIDForElement(CEFormID, CEFieldID, arguments.item, arguments.queryType, arguments.searchValues, searchCEFieldID);
		
		// Check that we got a query back
		if ( getPageIDValues.RecordCount gt 0 ){
			// Loop over the query of page ids 
			for( data_i=1; data_i LTE getPageIDValues.RecordCount; data_i=data_i+1 ) {
				if (isNumeric(getPageIDValues.PageID[data_i])) {
					// if we want to return the data version then call different function
					if ( arguments.queryType eq "versions" ){
						// get the data versions for the page id
						dataArray[data_i] = getElementInfoVersionsByPageID(getPageIDValues.PageID[data_i], CEFormID);
					}
					else {
						// get the data for the page id
						dataArray[data_i] = getElementInfoByPageID(getPageIDValues.PageID[data_i], CEFormID, true);
					}
				}
			}
		}
		// Check if we are processing the selected list
		if ( arguments.queryType EQ "selected" and len(arguments.customElementFieldName) and len(arguments.item) ){
			// Order the return data by the order the list was passed in
			dataArray = sortArrayByIDList(dataArray, arguments.customElementFieldName, arguments.item);
		}
		/* 2010-09-17 - MFC - Updated */
		// Check the query type for "selectedList"
		else if ( arguments.queryType eq "searchInList" ){
			// Loop over the records to do a list find for the data
			for( data_i=1; data_i LTE ArrayLen(dataArray); data_i=data_i+1 ) {
				
				// Compare the data values list with the arguments items list.
				//	If the list returned has a length then the item is in the data values list.
				if ( ListLen(variables.data.ListInCommon(dataArray[data_i].Values[arguments.customElementFieldName],arguments.item)) )
					ArrayAppend(retTempDataArray, dataArray[data_i]);
			}
			// Set the temp data array back to the return value
			dataArray = retTempDataArray;
		}
	</cfscript>
	<cfreturn dataArray>
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
Name:
	$getDataFieldValueByPageID
Summary:
	Returns a query for the data fields in Data_FieldValue for the PageID
Returns:
	Query
Arguments:
	Numeric PageID
History:
	2009-01-20 - MFC - Created
	2009-02-11 - MFC - Updated: Added formid argument and update Where clause of query
	2009-04-08 - MFC - Updated: Added currentVersionFlag and versionid argument
								Added VersionID field to query and added IF block
	2009-07-22 - MFC - Updated: Updated SQL statement INNER JOIN.
	2010-03-05 - SFS - Updated: Added DateAdded and DateApproved to selected fields
	2010-12-22 - MFC - Updated: Added AuthorID and OwnerID fields to the Query.
--->
<cffunction name="getDataFieldValueByPageID" access="public" returntype="query">
	<cfargument name="pageid" type="Numeric" required="true">
	<cfargument name="formid" type="Numeric" required="true">
	<cfargument name="currentVersionFlag" type="boolean" required="false" default="true">
	<cfargument name="versionID" type="numeric" required="false" default="2">
	
	<cfset var getDataFieldValues = queryNew("temp")>
	<!--- Query to get the data for the custom element by pageid --->
	<cfquery name="getDataFieldValues" datasource="#request.site.datasource#">
		SELECT  	FormInputControl.FieldName,
					FormControl.FormName,
					Data_FieldValue.FieldValue,
				    Data_FieldValue.MemoValue,
					Data_FieldValue.FormID,
					Data_FieldValue.FieldID,
					Data_FieldValue.VersionID,
					Data_FieldValue.listID,
					Data_FieldValue.DateAdded,
					Data_FieldValue.DateApproved,
					Data_FieldValue.AuthorID,
					Data_FieldValue.OwnerID
		FROM      	FormInputControl INNER JOIN FormInputControlMap ON FormInputControl.ID = FormInputControlMap.FieldID
					INNER JOIN 	FormControl ON FormControl.ID = FormInputControlMap.FormID
					INNER JOIN 	Data_FieldValue ON Data_FieldValue.FieldID = FormInputControlMap.FieldID 
		WHERE     	(Data_FieldValue.PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageid#">)
		AND 	  	(Data_FieldValue.FormID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">)
		<cfif arguments.currentVersionFlag eq true>
			AND 	  (Data_FieldValue.VersionState = 2)
		<cfelse>
			<!--- else return the version from the argument --->
			AND 	  (Data_FieldValue.VersionID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.versionID#">)
		</cfif>
	</cfquery>

	<cfreturn getDataFieldValues>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getElementFieldID
Summary:
	Returns a specific element field ID
Returns:
	Numeric
Arguments:
	Numeric Form ID
	String Field Name
History:
	2009-01-20 - MFC - Created
	2010-02-18 - MFC - Updated to check if the field name contains "FIC_"
--->
<cffunction name="getElementFieldID" access="public" returntype="numeric">
	<cfargument name="CEFormID" type="numeric" required="true">
	<cfargument name="CEFieldName" type="string" required="true">

	<!--- Get the field values for the form --->
	<cfscript>
		// Initialize the variables
		var elementFields = queryNew("temp");
		var selectFieldID = queryNew("temp");
		
		// Check if the fieldname starts with "FIC_"
		if ( UCASE(ListFirst(arguments.CEFieldName,"_")) NEQ "FIC" )
			arguments.CEFieldName = "FIC_" & arguments.CEFieldName;
		
		elementFields = getElementFieldsByFormID(arguments.CEFormID);
	</cfscript>

	<!--- check that records were returned --->
	<cfif elementFields.RecordCount>
		<!--- search over the fields for the matching field name --->
		<cfquery name="selectFieldID" dbtype="query">
			select	fieldID
			from	elementFields
			where	UPPER(fieldname) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#UCASE(arguments.CEFieldName)#">
		</cfquery>

		<!--- if record was found then return the fieldID --->
		<cfif selectFieldID.RecordCount>
			<cfreturn selectFieldID.fieldID>
		</cfif>
	</cfif>

	<!--- Else no records found return 0 --->
	<cfreturn 0>

</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getElementFieldsByFormID
Summary:
	Returns a query for the Element fields for the Element form ID
Returns:
	Query
Arguments:
	Numeric FormID
History:
	2009-01-20 - MFC - Created
--->
<cffunction name="getElementFieldsByFormID" access="public" returntype="query">
	<cfargument name="formid" type="Numeric" required="true">

	<cfset var getElementFields = queryNew("temp")>
	<!--- Query to get the data for the custom element by pageid --->
	<cfquery name="getElementFields" datasource="#request.site.datasource#">
		SELECT     FormInputControl.FieldName,
				   FormInputControlMap.FieldID,
				   FormInputControl.Params,
				   FormInputControl.Type
		FROM       FormControl INNER JOIN
                      FormInputControlMap ON FormControl.ID = FormInputControlMap.FormID INNER JOIN
                      FormInputControl ON FormInputControlMap.FieldID = FormInputControl.ID
		WHERE      (FormInputControlMap.FormID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">)
		ORDER BY   FormInputControl.FieldName
	</cfquery>

	<cfreturn getElementFields>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getElementInfoByPageID
Summary:
	Returns a structures for the Element Data matching the pageid
Returns:
	Struct
Arguments:
	Numeric - Page ID
	Numeric - Form ID
	Boolean - T/F flag if want the Data Values in a sub structure for easier access
				Default = true
History:
	2009-01-20 - MFC - Created
	2009-02-11 - MFC - Updated: If block to check if struct key already exists before inserting
								Added formid argument and passed to getDataFieldValueByPageID function
	2010-03-05 - SFS - Updated: If block added after the end of StructInsert loop to add DateAdded and
								DateApproved fields to retStruct
	2010-12-10 - RAK - Removed requirement of formID.
	2010-12-14 - MFC - Updated argument to getFormIDFromPageID function.  Added comments.
--->
<cffunction name="getElementInfoByPageID" access="public" returntype="struct">
	<cfargument name="pageid" type="Numeric" required="true">
	<cfargument name="formid" type="Numeric" required="false" default="-1">
	<cfargument name="separateValueStruct" type="boolean" required="false" default="true">

	<cfscript>
		// Initialize the variables
		var getElementInfo = queryNew("temp");
		var getElementFields = queryNew("temp");
		var dataValuesStruct = StructNew();
		var elmt_i = 1;
		var retStruct = StructNew();
		var elmt_j = 1;
		var dataFldName = "";
		var dataFldVal = "";

		// Get the Form ID by the page ID if not passed in
		if(arguments.formID eq -1){
			arguments.formID = getFormIDFromPageID(arguments.pageid);
		}
		// Query to get the data for the custom element by pageid
		// [MFC 2/11/09] Added formid argument to function call
		getElementInfo = getDataFieldValueByPageID(arguments.pageid, arguments.formid);
		// Get ALL the fields for the custom element
		// getElementFields = getElementFieldsByFormID(getElementInfo.FormID[1]);
		getElementFields = getElementFieldsByFormID(arguments.formid);

		// Load the field data into a struct with the fieldID as keys
		for( elmt_i = 1; elmt_i LTE getElementInfo.RecordCount; elmt_i=elmt_i+1 )
		{
			// [MFC 2/11/09] Check if the key is already in the struct
			if ( NOT StructKeyExists(dataValuesStruct, "#getElementInfo.FieldID[elmt_i]#") ) {
				//check if the value is too large for fieldValue
				if ( LEN(getElementInfo.FieldValue[elmt_i]) )
					StructInsert(dataValuesStruct,getElementInfo.FieldID[elmt_i],getElementInfo.FieldValue[elmt_i]);
				else
					StructInsert(dataValuesStruct,getElementInfo.FieldID[elmt_i],getElementInfo.MemoValue[elmt_i]);
			}
		}

		// Set the getElementFields query into a structure with the CE fields as keys
		// initialize the variables
		retStruct.pageid = arguments.pageid;
		retStruct.formid = getElementInfo.FormID[1];
		retStruct.formname = getElementInfo.FormName[1];
		retStruct.dateadded = getElementInfo.dateadded[1];
		retStruct.dateapproved = getElementInfo.dateapproved[1];
		
		// check if we want the values struct separated
		if (arguments.separateValueStruct)
			retStruct.values = StructNew();
		// loop over the form fields
		for( elmt_j = 1; elmt_j LTE getElementFields.RecordCount; elmt_j=elmt_j+1 )
		{
			// trim the 'fic_' from the field name
			dataFldName = RIGHT(getElementFields.FieldName[elmt_j],LEN(getElementFields.FieldName[elmt_j])-4);
			dataFldVal = "";
			// if the fieldname is a key in dataValuesStruct, then data exists for the field
			//	set the field to dataFldVal for the struct insert
			if ( StructKeyExists(dataValuesStruct, "#getElementFields.FieldID[elmt_j]#") )
				dataFldVal = dataValuesStruct[getElementFields.FieldID[elmt_j]];
			// insert the data field name and value key pair into the struct
			// check if we want the values struct separated
			if (arguments.separateValueStruct)
				StructInsert(retStruct.values,dataFldName,dataFldVal);
			else
				StructInsert(retStruct,dataFldName,dataFldVal);
		}	
		return retStruct;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
Name:
	$getElementInfoVersionsByPageID
Summary:
	Returns an array of structures for the Element Data versions matching the pageid
Returns:
	Array
Arguments:
	Numeric - Page ID
	Numeric - Form ID
	Numeric - Version ID - to return only a specific versions records
	Boolean - T/F flag if want the Data Values in a sub structure for easier access
				Default = true
History:
	2009-01-20 - MFC - Created
	2009-02-11 - MFC - Updated: If block to check if struct key already exists before inserting
								Added formid argument and passed to getDataFieldValueByPageID function
	2010-03-05 - SFS - Updated: Additional StructInsert added after the end of StructInsert loop to add
								DateAdded and DateApproved fields to retStruct
	2010-12-22 - MFC - Updated: Added AuthorID and OwnerID fields to the return structure.
--->
<cffunction name="getElementInfoVersionsByPageID" access="public" returntype="array">
	<cfargument name="pageid" type="Numeric" required="true">
	<cfargument name="formid" type="Numeric" required="true">
	<cfargument name="versionID" type="Numeric" required="false" default="0">
	
	<cfscript>
		// Initialize the variables
		var getElementInfo = queryNew("temp");
		var getElementFields = queryNew("temp");
		var dataValuesStruct = StructNew();
		var dataValuesArray = ArrayNew(1);
		var ver_i = 1;
		var elmt_i = 1;
		var elmt_j = 1;
		var versionStruct = StructNew();
		var dataFldName = "";
		var dataFldVal = "";
		
		// get the version query for the CE
		dataVersions = getElementVersionsForPageID(arguments.pageid, arguments.formid);

		for( ver_i = 1; ver_i LTE dataVersions.RecordCount; ver_i=ver_i+1 )
		{
			// check if we only need a specific version returned
			if ( (arguments.versionid EQ 0) OR (arguments.versionid EQ ver_i) )
			{	
				// clear the structs
				dataValuesStruct = StructNew();
				versionStruct = StructNew();
				
				// Query to get the versions data from the custom element by pageid
				getElementInfo = getDataFieldValueByPageID(arguments.pageid, arguments.formid, false, dataVersions.versionid[ver_i]);

				// Get ALL the fields for the custom element
				getElementFields = getElementFieldsByFormID(getElementInfo.FormID[1]);

				// Load the field data into a struct with the fieldID as keys
				for( elmt_i = 1; elmt_i LTE getElementInfo.RecordCount; elmt_i=elmt_i+1 )
				{
					// [MFC 2/11/09] Check if the key is already in the struct
					if ( NOT StructKeyExists(dataValuesStruct, "#getElementInfo.FieldID[elmt_i]#") ) {
						//check if the value is too large for fieldValue
						if ( LEN(getElementInfo.FieldValue[elmt_i]) )
							StructInsert(dataValuesStruct,getElementInfo.FieldID[elmt_i],getElementInfo.FieldValue[elmt_i]);
						else
							StructInsert(dataValuesStruct,getElementInfo.FieldID[elmt_i],getElementInfo.MemoValue[elmt_i]);
					}
				}
				
				// initialize the variables
				versionStruct.pageid = arguments.pageid;
				versionStruct.formid = getElementInfo.FormID[ver_i];
				versionStruct.formname = getElementInfo.FormName[ver_i];
				versionStruct.versionid = getElementInfo.versionid[ver_i];
				versionStruct.dateadded = getElementInfo.dateadded[ver_i];
				versionStruct.dateapproved = getElementInfo.dateapproved[ver_i];
				versionStruct.authorid = getElementInfo.AuthorID[ver_i];
				versionStruct.ownerid = getElementInfo.OwnerID[ver_i];
				
				versionStruct.values = StructNew();
				// loop over the form fields
				for( elmt_j = 1; elmt_j LTE getElementFields.RecordCount; elmt_j=elmt_j+1 )
				{
					// trim the 'fic_' from the field name
					dataFldName = RIGHT(getElementFields.FieldName[elmt_j],LEN(getElementFields.FieldName[elmt_j])-4);
					dataFldVal = "";
					// if the fieldname is a key in dataValuesStruct, then data exists for the field
					//	set the field to dataFldVal for the struct insert
					if ( StructKeyExists(dataValuesStruct, "#getElementFields.FieldID[elmt_j]#") )
						dataFldVal = dataValuesStruct[getElementFields.FieldID[elmt_j]];
					// insert the data field name and value key pair into the struct
					StructInsert(versionStruct.values,dataFldName,dataFldVal);
				}
				
				// if no specified version id then build the whole array
				if ( arguments.versionid EQ 0 )
					dataValuesArray[ver_i] = versionStruct;
				else if ( arguments.versionid EQ ver_i ) // else build 1 term array for specific version
					dataValuesArray[1] = versionStruct;
			}
		}
		return dataValuesArray;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getElementVersionsForPageID
Summary:
	Returns a query of the element version ids for the PageID
Returns:
	Query
Arguments:
	Numeric PageID
History:
	2009-04-08 - MFC - Created
--->
<cffunction name="getElementVersionsForPageID" access="public" returntype="query">
	<cfargument name="pageid" type="Numeric" required="true">
	<cfargument name="formid" type="Numeric" required="true">
	
	<cfset var getDataFieldVersions = queryNew("temp")>
	<!--- Query to get the versions data for the custom element by pageid --->
	<cfquery name="getDataFieldVersions" datasource="#request.site.datasource#">
		SELECT DISTINCT    VersionID, PageID
		FROM      Data_FieldValue
		WHERE     (PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageid#">)
		AND 	  (FormID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">)
		ORDER BY 	VersionID
	</cfquery>

	<cfreturn getDataFieldVersions>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getFormIDByCEName
Summary:
	Returns the formID for the Custom Element name
Returns:
	Numeric Form ID
Arguments:
	String CE Name
History:
	2009-01-20 - MFC - Created
	2009-05-06 - MFC - Updated: Return if block to return 0, if no records found
	2009-10-16 - MFC - Updated: Add lookup for CE Name with spaces OR underscores
--->
<cffunction name="getFormIDByCEName" access="public" returntype="numeric">
	<cfargument name="CEName" type="string" required="true">

	<!--- Initialize the variables --->
	<cfset var getFormID = QueryNew("temp")>
	<cfset var tmpCENameSpaces = Replace(arguments.CEName, "_", " ", "all")>
	<cfset var tmpCENameUnders = Replace(arguments.CEName, " ", "_", "all")>
	
	<!--- Query to get the data for the custom element by pageid --->
	<cfquery name="getFormID" datasource="#request.site.datasource#">
		SELECT 	ID
		FROM 	FormControl
		WHERE 	(FormName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpCENameSpaces#"> OR FormName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpCENameUnders#">)
		AND 	(FormControl.action = '' OR FormControl.action is null)
	</cfquery>

	<cfif getFormID.RecordCount>
		<cfreturn getFormID.ID>
	<cfelse>
		<cfreturn 0>
	</cfif>
	
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll, M. Mendelson ( THE AU Master)
Name:
	$getPageIDForFormID
Summary:
	Returns Page ID's in Data_FieldValue matching Form ID
Returns:
	Query
Arguments:
	Numeric - Form ID
	Numeric - Element Field Name
	String - Item Values to Search
	String - Query Type, options [selected,notSelected,search]
	String - Search Values
History:
	2009-01-20 - MFC - Created
	2009-01-27 - MFC - 	Added searchValues argument.
						Updated search to not include any current selections.
	2009-02-11 - MFC - Updated: Query structure for IF block where clause
	2009-02-12 - MFC - Updated: Query WHERE clause for fieldid in selected and notselected
	2009-10-21 - MFC - Updated: SELECTED and NOTSELECTED updated to return empty string fields
	2010-03-08 - MFC - Updated: Updated the SEARCH and MULTI to lowercase for searching.
	2010-09-17 - MFC - Updated: Added new queryType for "searchInList".
								Find any of the items in a list that match a list item in a 
									CE field that stores a list of values.
								Removed if statements for condition " contains in 'list' ".
--->
<cffunction name="getPageIDForElement" access="public" returntype="query" hint="Returns Page ID Query in Data_FieldValue matching Form ID">
	<cfargument name="formid" type="numeric" required="true">
	<cfargument name="fieldid" type="string" required="false" default="">
	<cfargument name="item" type="any" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="searchFields" type="string" required="false" default="">

	<cfscript>
		// Initialize the variables
		var itm = 0;
		var getListItemIDs = queryNew("temp");
		var getPageIDForFormID = queryNew("temp");
		// Make the search case to lowercase
		arguments.searchValues = LCASE(arguments.searchValues);
	</cfscript>

	<!--- // queryType eq list get the listID's first that match the input --->
	<cfif (arguments.queryType EQ "list") OR (arguments.queryType EQ "numericList")>
		<cfquery name="getListItemIDs" datasource="#request.site.datasource#">
			SELECT DISTINCT listID
			FROM data_listItems
			WHERE
				<cfif arguments.queryType eq "numericList">
					numItemValue in (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.item#" list="true">)
				<!--- <cfelse>
					strItemValue in (#preserveSingleQuotes(listQualify(arguments.item, "'"))#) --->
				</cfif>
		</cfquery>
	</cfif>
	
	<cfquery name="getPageIDForFormID" datasource="#request.site.datasource#">
		SELECT DISTINCT PageID
		FROM Data_FieldValue
		WHERE	FormID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
		<!--- Check if we have a fieldid --->
		<cfif LEN(arguments.fieldid)>
			<!--- Build the where clause for the SELECTED --->
			<cfif arguments.queryType eq "selected">
				<!--- Check if we have a list of values --->
				<cfif ListLen(arguments.item) gt 1>
					AND		fieldValue IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">)
				<cfelse>
					AND		fieldValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
				</cfif>
				AND			FieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldid#">
			<!--- Build the where clause for the NOT SELECTED --->
			<cfelseif arguments.queryType eq "notselected">
				<cfif ListLen(arguments.item) gt 1>
					AND		fieldValue NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">)
				<cfelse>
					AND		fieldValue <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
				</cfif>
				AND			FieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldid#">
			<!--- Build the where clause for the SEARCH --->
			<cfelseif arguments.queryType eq "search">
				<cfif LEN(arguments.item)>
					AND PageID NOT IN (SELECT DISTINCT PageID
										FROM Data_FieldValue
										WHERE ( fieldValue IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#" list="true">) )
										AND ( FieldID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldid#" list="true">) )
										)
				</cfif>
				AND		FieldID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.searchFields#" list="true">)
				AND		LOWER(fieldValue) LIKE '%' + <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.searchValues#"> + '%'
			<!--- Build the where clause for the MULTI --->
			<cfelseif arguments.queryType EQ "multi">
				<cfif ListLen(arguments.searchFields)>
					<cfloop from="1" to="#ListLen(arguments.searchFields)#" index="itm">
						AND PageID IN
							( SELECT DISTINCT PageID FROM Data_FieldValue
								WHERE FormID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
								AND FieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ListGetAt(arguments.searchFields,itm)#">
								AND LOWER(fieldValue) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListGetAt(arguments.searchValues,itm)#">
							)
					</cfloop>
				</cfif>
			<!--- Build the where clause for the LIST --->
			<!--- <cfelseif arguments.queryType contains "list"> --->
			<cfelseif (arguments.queryType EQ "list") OR (arguments.queryType EQ "numericList")>
				<cfif listLen(valueList(getListItemIds.listID))>
					AND fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
					AND listID in (<cfqueryparam cfsqltype="cf_sql_integer" value="#valueList(getListItemIDs.listID)#" list="true">)
				<cfelse><!--- // should return zero results --->
					AND fieldID = 0
				</cfif>
			<!--- Build the where clause for the GREATERTHAN --->
			<cfelseif arguments.queryType EQ "greaterThan">
				AND fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
				AND fieldValue > <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.item#">
			<!--- // Build the where clause for the BETWEEN operator --->
			<cfelseif arguments.queryType EQ "between">
				AND fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
				AND ( fieldValue > <cfqueryparam cfsqltype="cf_sql_varchar" value="#listFirst(arguments.item)#"> AND fieldValue < <cfqueryparam cfsqltype="cf_sql_varchar" value="#listLast(arguments.item)#">)
			<!--- /* 2010-09-17 - MFC - Updated */ --->
			<cfelseif arguments.queryType EQ "searchInList">
				AND fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
				<!--- Filter down the result set with a search --->
				<cfloop from="1" to="#ListLen(arguments.item)#" index="itm">
					AND	LOWER(fieldValue) LIKE '%' + <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListGetAt(arguments.item, itm)#"> + '%'
				</cfloop>
			</cfif>
		</cfif>
		AND VersionState = 2
		AND PageID <> 0
	</cfquery>
	<cfreturn getPageIDForFormID>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M Carroll
Name:
	$invalidateElementCache
Summary:
	Given a control and page id, invalidate the cache for the element on the page
Returns:
	Void
Arguments:
	Numeric - Page ID
	Numeric - Control ID
History:
	2009-03-24 - MFC - Created
--->
<cffunction name="invalidateElementCache" access="public" returntype="void">
	<cfargument name="pageID" type="numeric" required="true">
	<cfargument name="controlID" type="numeric" required="true">

	<cfscript>
		Application.CacheInfoCache.InvalidateByID("element",0,0,0,arguments.pageID,arguments.controlID);
	</cfscript>

</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M Carroll
Name:
	$getAllCustomElements
Summary:
	Returns all the Custom Elements for the site.
Returns:
	Query - Custom Elements
Arguments:
	stateList - Value or List of Values (any combination of these options: 0-active,1-inactive,2-deleted)
History:
	2009-05-21 - MFC - Created
	2010-04-13 - MFC - Removed ownerid where clause.
	2010-12-17 - GAC - Changed the query get the data from the AvailableControls table to get active Custom Elements
	2010-12-17 - GAC - Added an argument to pass in a value or a list of values to get CEs with a specific or a combination of states
--->
<cffunction name="getAllCustomElements" access="public" returntype="query" hint="Returns all the Custom Elements for the site.">
	<cfargument name="stateList" type="string" required="false" default="0" hint="Use a value or a list of values to display Available custom elements. Options: 0-active,1-inactive,2-deleted">
	<cfscript>
		// Initialize the variables
		var qCustomElements = QueryNew("id,formname,state");
		var controlType = "custom";
		// remove any non-numeric values from the passed in value
		var stList = REReplace(arguments.stateList,"[^,0-9]","","ALL");
		// If remaining value does not not have at least one value, set it back to the default to only return active records
		if ( ListLen(stList) EQ 0 )
			stList = 0;
	</cfscript>
	<!--- // query to get the Custom Element List from the "AvailableControls" table --->
	<cfquery name="qCustomElements" datasource="#request.site.datasource#">
		SELECT 		ID, ShortDesc AS FormName, ElementState AS state
		FROM 		AvailableControls
		WHERE 		Name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#controlType#">
		AND 		ElementState IN (<cfqueryparam cfsqltype="cf_sql_numeric" value="#stList#" list="true" separator=",">)
		ORDER BY 	ShortDesc
	</cfquery>
	<!--- TODO: Remove before launch ... after the above query has be verified --->
	<!--- <cfquery name="qCustomElements" datasource="#request.site.datasource#">
		SELECT 		ID, FormName
		FROM 		formcontrol
		WHERE 		(FormControl.action = '' OR FormControl.action is null)
		ORDER BY 	FormName
	</cfquery> --->
	<cfreturn qCustomElements>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$sortArrayByIDList
Summary:
	Returns a sorted Array of Structures by the field and id list arguments
Returns:
	Array
Arguments:
	Array - Array of Structs
	String - Element Field Name
	String - List of Field Values
History:
	2009-02-12 - MFC - Created
	2009-02-20 - MFC - Updated:
--->
<cffunction name="sortArrayByIDList" access="public" returntype="array">
	<cfargument name="arrayOfStructs" type="array" required="true">
	<cfargument name="idFieldName" type="string" required="true">
	<cfargument name="idList" type="string" required="true">

	<cfscript>
		var retArray = ArrayNew(1);
		var i = 1;
		var j = 1;
		var arrayCount = 1;
		var fldVal = "";
		
		// loop over the idList
		for (i = 1; i lte #ListLen(arguments.idList)#; i = i + 1)
		{
			// loop over the arrayOfStructs to find the matching item with the ID
			for (j = 1; j lte #ArrayLen(arguments.arrayOfStructs)#; j=j+1)
			{
				// [MFC 2/20/09] Check if the values struct exists.  Set fldVal variable.
				if ( structKeyExists(arguments.arrayOfStructs[j], "values") )
					fldVal = arguments.arrayOfStructs[j].Values["#arguments.idFieldName#"];
				else
					fldVal = arguments.arrayOfStructs[j][arguments.idFieldName];

				if ( ListGetAt(arguments.idList,i) eq fldVal )
				{
					retArray[arrayCount] = arguments.arrayOfStructs[j];
					arrayCount = arrayCount + 1;
				}
			}
		}
		return retArray;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getFormIDFromPageID
Summary:
	Returns the Form ID for the Page ID.
Returns:
	Numeric - Form ID
Arguments:
	Numeric - PageID - Data Page ID
History:
	2009-07-14 - MFC - Created
--->
<cffunction name="getFormIDFromPageID" access="public" returntype="numeric" hint="Returns the Form ID for the Page ID.">
	<cfargument name="pageid" type="Numeric" required="true">
	
	<cfset var getDataFieldValues = queryNew("temp")>
	<!--- Query to get the data for the custom element by pageid --->
	<cfquery name="getDataFieldValues" datasource="#request.site.datasource#">
		SELECT    FormID
        FROM      Data_FieldValue 
		WHERE     PageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.pageid#">
		AND 	  VersionState = 2
	</cfquery>
	<!--- Check that we have a query values --->
	<cfif getDataFieldValues.RecordCount>
		<cfreturn getDataFieldValues.FormID>	
	<cfelse>
		<cfreturn 0>	
	</cfif>

</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getCENameByFormID
Summary:
	Returns the CE Name for the Custom Element Form ID
Returns:
	String CE Name
Arguments:
	Numeric Form ID
History:
	2009-08-25 - MFC - Created
--->
<cffunction name="getCENameByFormID" access="public" returntype="string">
	<cfargument name="FormID" type="numeric" required="true">

	<!--- Initialize the variables --->
	<cfset var getFormID = QueryNew("temp")>
	
	<!--- Query to get the data for the custom element by pageid --->
	<cfquery name="getFormID" datasource="#request.site.datasource#">
		SELECT 	FormName
		FROM 	FormControl
		WHERE 	ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.FormID#">
		AND 	(FormControl.action = '' OR FormControl.action is null)
	</cfquery>

	<cfif getFormID.RecordCount>
		<cfreturn getFormID.FormName>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>

<!---
/* *************************************************************** */
Author: 	M. Carroll
Name:
	$compareCEDataArray
Summary:
	Returns a CEData array format with matches in array1 and array2.
Returns:
	Array
Arguments:
	Array - array1
	Array - array2
History:
	2009-08-28 - MFC - Created
	2010-07-22 - MFC - Updated to set the large array in the outer loop.
						Validate if both arrays have lengths.
--->
<cffunction name="compareCEDataArray" access="public" returntype="array" hint="Returns a CEData array format with matches in array1 and array2.">
	<cfargument name="array1" type="array" required="true">
	<cfargument name="array2" type="array" required="true">
	
	<cfscript>
		var retArray = ArrayNew(1);
		var array1PageIDList = "";
		var array2PageIDList = "";
		var i = 1;
		var j = 1;
		
		// Set the array1 to be the larger array
		var largeArray = arguments.array1;
		var smallArray = arguments.array2;
		
		// Validate that both arrays have LENGTHS
		if ( ArrayLen(largeArray) AND (NOT ArrayLen(smallArray)) ) {
			return largeArray;
		}
		else if ( ArrayLen(smallArray) AND (NOT ArrayLen(largeArray)) ) {
			return smallArray;
		}
		else if ( (NOT ArrayLen(largeArray)) AND (NOT ArrayLen(smallArray)) ){
			return retArray;
		}
		
		// Check if array2 is larger
		if ( ArrayLen(arguments.array2) GT ArrayLen(arguments.array1) ){
			largeArray = arguments.array2;
			smallArray = arguments.array1;
		}
				
		// Loop over largeArray
		for ( i = 1; i LTE ArrayLen(largeArray); i = i + 1)
		{
			// Loop over the smallArray
			for ( j = 1; j LTE ArrayLen(smallArray); j = j + 1)
			{		
				// check if the current largeArray pageid has any matches in smallArray
				if ( largeArray[i].pageid EQ smallArray[j].pageid )
				{
					ArrayAppend(retArray, largeArray[i]);
					break;
				}
			}
		}
	</cfscript>
	<cfreturn retArray>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$diffCEDataArray
Summary:
	Compares 2 CEData arrays and returns a CEData array 
	with the values found in array1 but not in array2.
Returns:
	Array
Arguments:
	Array - array1
	Array - array2
History:
	2009-09-02 - MFC - Created
--->
<cffunction name="diffCEDataArray" access="public" returntype="array">
	<cfargument name="array1" type="array" required="true">
	<cfargument name="array2" type="array" required="true">
	
	<cfscript>
		var retArray = arguments.array1;
		var i = 1;
		var j = 1;
		// Loop over array1
		//for ( i = 1; i LTE ArrayLen(retArray); i = i + 1)
		for ( i = ArrayLen(retArray); i GTE 1; i = i - 1)
		{
			// Loop over the array2
			for ( j = 1; j LTE ArrayLen(arguments.array2); j = j + 1)
			{		
				// check if the current array1 pageid has any matches in array2
				if ( retArray[i].pageid EQ arguments.array2[j].pageid )
				{
					// Delete the item from the list
					ArrayDeleteAt(retArray, i);
					break;
				}
			}
		}
	</cfscript>
	<cfreturn retArray>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	M. Carroll
Name:
	$containsFieldType
Summary:
	Returns T/F for if the custom element contains an the field type argument.
Returns:
	Boolean
Arguments:
	Numeric - formid - CE form id.
	String - fieldType - Field Type
History:
	2009-09-04 - MFC - Created
--->
<cffunction name="containsFieldType" access="public" returntype="boolean" hint="">
	<cfargument name="FormID" type="numeric" required="true">
	<cfargument name="fieldType" type="string" required="true">

	<cfscript>
		// Get the fields for the CE
		var fieldsQry = getElementFieldsByFormID(arguments.formID);
		var i = 1;
		// Loop over the fields to determin if any types are RTE
		for ( i = 1; i LTE fieldsQry.RecordCount; i = i + 1)
		{
			if ( fieldsQry.Type[i] EQ fieldType )
			{
				return true;
			}
		}
		return false;
	</cfscript>

</cffunction>

<!---
/* ***************************************************************
/*
Author: 	M. Carroll
Name:
	$getCEForCategory
Summary:
	Returns a query of the CE's name and form ID that are in the Category argument.
Returns:
	Query
Arguments:
	String - categoryName - Category Nam
History:
	2009-09-09 - MFC - Created
--->
<cffunction name="getCEForCategory" access="public" returntype="query" hint="Returns a query of the CE's name and form ID that are in the Category argument.">
	<cfargument name="categoryName" type="string" required="true" hint="Category Name">
	
	<cfset var ceQry = QueryNew("tmp")>
	<cfquery name="ceQry" datasource="#request.site.datasource#">
		SELECT  ControlCategoryLookup.Category, FormControl.FormName, FormControl.ID
		FROM    AvailableControls INNER JOIN
	                ControlCategoryLookup ON AvailableControls.CategoryID = ControlCategoryLookup.ID INNER JOIN
	                FormControl ON AvailableControls.ID = FormControl.ID
		WHERE   (AvailableControls.ElementState = 0)
		AND	   	ControlCategoryLookup.Category = <cfqueryparam value="#arguments.categoryName#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn ceQry>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getCEDataField
Summary:
	Returns the single field data value for the custom element record.
Returns:
	ANY
Arguments:
	Numeric - formid - Custom element form id.
	Numeric - datapageid - Custom element data page id record.
	String - fieldName - Custom element field name to return data.
History:
	2009-10-21 - MFC - Created
--->
<cffunction name="getCEDataField" access="public" returntype="ANY" hint="Returns the single field data value for the custom element record.">
	<cfargument name="formid" type="numeric" required="true" hint="Custom element form id.">
	<cfargument name="datapageid" type="numeric" required="true" hint="Custom element data page id record.">
	<cfargument name="fieldName" type="string" required="true" hint="Custom element field name to return data.">
	
	<cfscript>
		var fldVal = "";
		// Get the data struct for the formid and datapageid
		var dataStruct = getElementInfoByPageID(arguments.datapageid, arguments.formid);
		
		// Check if the key exists for the field name
		if ( StructKeyExists(dataStruct.Values, arguments.fieldName) )
			fldVal = dataStruct.Values[arguments.fieldName];
	</cfscript>
	<cfreturn fldVal>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	S. Smith
Name:
	$getCEFieldValues
Summary:
	Returns all values for a particular field in a particular custom element.
Returns:
	An alphabetical list of all the field values
Arguments:
	String - CEName - Custom element name.
	String - fieldName - Custom element field for which you want to find all the values.
History:
	2009-10-25 - SFS - Created
--->
<cffunction name="getCEFieldValues" access="public" returntype="string" hint="Returns all values for a particular field in a particular custom element.">
	<cfargument name="ceName" type="string" required="true" hint="Custom element name.">
	<cfargument name="fieldName" type="string" required="true" hint="Custom element field name to return data.">

	<cfset var ceDataList = "">	
	<cfset var ceData = application.adf.ceData.getCEData(arguments.ceName)>
	<cfset ceData = application.ADF.ceData.arrayOfCEDataSort(ceData,arguments.fieldName,'asc','textnocase','^')>
	
	<cfloop from="1" to="#arrayLen(ceData)#" index="itm">
		<cfset ceDataList = ListAppend(ceDataList,Evaluate("ceData[itm].values.#arguments.fieldname#"))>
	</cfloop>

	<cfreturn ceDataList>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getCEDataField
Summary:
	Returns the single field data value by the custom element UUID data value.
Returns:
	ANY
Arguments:
	Numeric - formid - Custom element form id.
	String - UUID - Custom element UUID data value.
	String - fieldName - Custom element field name to return data.
History:
	2009-10-21 - MFC - Created
	2009-12-07 - MFC - Updated the query to have the DISTINCT and FORMID in the where clause.
--->
<cffunction name="getCEDataFieldUUID" access="public" returntype="ANY" hint="Returns the single field data value by the custom element UUID data value.">
	<cfargument name="formid" type="numeric" required="true" hint="Custom element form id.">
	<cfargument name="uuid" type="string" required="true" hint="Custom element UUID data value.">
	<cfargument name="fieldName" type="string" required="true" hint="Custom element field name to return data.">
	
	<cfset var fldVal = "">
	<cfset var qryUUID = QueryNew("tmp")>
		
	<!--- Run a query to get the CE with the UUID --->
	<cfquery name="qryUUID" datasource="#request.site.datasource#">
		SELECT DISTINCT pageid
		FROM 			data_fieldvalue
		WHERE 			fieldValue = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.uuid#">
		AND 			formid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formid#">
	</cfquery>
	
	<!--- Check that we got values back --->
	<cfif qryUUID.RecordCount>
		<!--- Call getCEDataField to do the work and send the data page id from the query --->
		<cfset fldVal = getCEDataField(arguments.formid, qryUUID.pageid[1], arguments.fieldName)>
	</cfif>
	<cfreturn fldVal>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$pageMapElementExists
Summary:	
	Determines whether or not an element exists or not
Returns:
	Boolean elementExists
Arguments:
	String ElementName
History:
 2009-10-30 - RLW - Created
--->
<cffunction name="elementExists" access="public" returntype="boolean" hint="Determines whether or not an element exists">
	<cfargument name="elementName" type="string" required="true" hint="the name of the custom element to check">
	<cfscript>
		var elementExists = false;
		if( getFormIDByCEName(arguments.elementName) neq 0 )
			elementExists = true;
	</cfscript>
	<cfreturn elementExists>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$getCEDataByFieldID
Summary:	
	Returns Custom Element Data records for a given FieldID
Returns:
	Query getPageIDValues
Arguments:
	Numeric fieldID
History:
 2009-11-30 - RLW - Created
--->
<cffunction name="getCEDataByFieldID" access="public" returntype="query" hint="Returns Custom Element Data records for a given FieldID">
	<cfargument name="fieldID" type="numeric" required="true">
	<cfscript>
		var ceDataAry = arrayNew(1);
		var getPageIDValues = queryNew('');
		var pageIDList = "";
	</cfscript>
	<!--- // get pageIDs and formID for the given fieldID --->
	<cfquery name="getPageIDValues" datasource="#request.site.datasource#">
		select pageID, formID, fieldValue, memoValue, itemID, listID, fieldID
		from data_fieldValue
		where fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
		and versionState = 2
	</cfquery>
	<cfreturn getPageIDValues>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$getFieldIDsByType
Summary:	
	Returns a list of fieldID's for a given Field Type
Returns:
	String fieldIDList
Arguments:
	String fieldType
History:
 2009-11-30 - RLW - Created
--->
<cffunction name="getFieldIdsByType" access="public" returntype="string" hint="Returns a list of fieldID's for a given Field Type">
	<cfargument name="fieldType" type="string" required="true">
	<cfscript>
		var fieldIDList = "";
		var fieldIDQuery = queryNew('');
	</cfscript>
	<cfquery name="fieldIDQuery" datasource="#request.site.datasource#">
		select ID
		from formInputControl
		where type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldType#">
	</cfquery>
	<cfif fieldIDQuery.recordCount>
		<cfset fieldIDList = valueList(fieldIDQuery.ID)>
	</cfif>
	<cfreturn fieldIDList>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getCountForElementField
Summary:
	Returns the numeric count for the matching field data value in the custom element.
Returns:
	Numeric
Arguments:
	String ceName
	String fieldName
	String fieldValue
History:
	2010-02-18 - MFC - Created
--->
<cffunction name="getCountForElementField" access="public" returntype="numeric" hint="">
	<cfargument name="ceName" type="string" required="true" hint="Custom element name">
	<cfargument name="fieldName" type="string" required="true" hint="Custom element field name">
	<cfargument name="fieldValue" type="any" required="true" hint="Field value to search">
	
	<cfscript>
		var countQry = QueryNew("tmp");
		// Get the form and field ID's
		var formID = getFormIDByCEName(CEName=arguments.ceName);
		var fieldID = getElementFieldID(CEFormID=formID,CEFieldName=arguments.fieldName);
	</cfscript>
	
	<cfquery name="countQry" datasource="#request.site.datasource#">
		SELECT DISTINCT PageID
		FROM 	Data_FieldValue
		WHERE	FormID = <cfqueryparam value="#formID#" cfsqltype="cf_sql_integer">
		AND		FieldID = <cfqueryparam value="#fieldID#" cfsqltype="cf_sql_integer">
		AND 	FieldValue = <cfqueryparam value="#arguments.fieldValue#" cfsqltype="cf_sql_varchar">
	</cfquery>
	<cfreturn countQry.RecordCount>
</cffunction>
<!---
/* ***************************************************************
/*
Author: 	Ron West
Name:
	$buildElementInfoStruct
Summary:	
	Given a ceData array - builds an elementInfo struct
Returns:
	Struct elementInfo
Arguments:
	Array ceData
History:
 2010-04-03 - RLW - Created
--->
<cffunction name="buildElementInfoStruct" access="public" returntype="struct" hint="Builds an ElementInfo structure given a ceData array">
	<cfargument name="ceData" type="array" required="true">
	<cfscript>
		var elementInfo = structNew();
		elementInfo.elementData = structNew();
		elementInfo.elementData.propertyValues = arguments.ceData;
	</cfscript>
	<cfreturn elementInfo>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	S. Smith
Name:
	$arrayOfCEDataToQuery
Summary:
	Returns Query from a Custom Element Array of Structures
Returns:
	Query
Arguments:
	Array
History:
	2010-07-27 - SFS - Created based upon the arrayOfStructuresToQuery function in data_1_0.cfc
--->
<cffunction name="arrayOfCEDataToQuery" access="public" returntype="query">
	<cfargument name="theArray" type="array" required="true">

	<cfscript>
		var colNames = "";
		var theQuery = queryNew("");
		var i=0;
		var j=0;
		//if there's nothing in the array, return the empty query
		if(NOT arrayLen(arguments.theArray))
			return theQuery;
		//get the column names into an array =
		colNames = structKeyArray(arguments.theArray[1]["values"]);
		//build the query based on the colNames
		theQuery = queryNew(arrayToList(colNames));
		//add the right number of rows to the query
		queryAddRow(theQuery, arrayLen(arguments.theArray));
		//for each element in the array, loop through the columns, populating the query
		for(i=1; i LTE arrayLen(arguments.theArray); i=i+1){
			for(j=1; j LTE arrayLen(colNames); j=j+1){
				querySetCell(theQuery, colNames[j], arguments.theArray[i]["values"][colNames[j]], i);
			}
		}
	    return theQuery;
	</cfscript>
</cffunction>

</cfcomponent>