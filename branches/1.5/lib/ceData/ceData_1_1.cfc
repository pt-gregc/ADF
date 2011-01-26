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
	ceData_1_1.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	1.1.0
History:
	2011-01-25 - MFC - Created - New v1.1
--->
<cfcomponent displayname="ceData_1_1" extends="ADF.lib.ceData.ceData_1_0" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="1_1_0">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_0">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="CEData_1_1">

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

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$getTabsFromFormID
Summary:
	Returns array containing form tab name and id ordered by their display name
Returns:
	Array
Arguments:
	number
History:
--->
<cffunction name="getTabsFromFormID" hint="Returns array containing form tab name and id ordered by their display name"
				access="public" 
				returntype="array" 
				description="From form ID this function, when recurse is set to true returns the form's tabs in order, with the tab's fields in order, with each field's default information.">
	<cfargument name="formID" type="numeric" required="true">
	<cfargument name="recurse" type="boolean" required="false" default="false" hint="If true, this function will return a structure containing every tabs fields and the fields default values.">
	<cfscript>
		var returnArray = ArrayNew(1);
		var tabStruct = StructNew();
	</cfscript>
	<cfquery name="formTabQuery" datasource="#request.site.datasource#">
		  select TabDisplayName,TabSortName,ID
			 from formControlTabs
  			where FormID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formID#">
		order by TabSortName
	</cfquery>
	<cfloop query="formTabQuery">
		<cfscript>
			tabStruct = StructNew();
			tabStruct.name = TabDisplayName;
			tabStruct.id = ID;
			if(recurse){
				tabStruct.fields = getFieldsFromTabID(ID);
			}
			ArrayAppend(returnArray,tabStruct);
		</cfscript>
	</cfloop>
	<cfreturn returnArray>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$getFieldsFromTabID
Summary:
	Returns array containing form field name and id in order from the tabID
Returns:
	Array
Arguments:
	number
History:
--->
<cffunction name="getFieldsFromTabID" hint="Returns array containing form field name and id in order from the tabID"
				access="public" 
				returntype="array"
				description="From tab id this can return either a simple listing of fields/fieldid in order. With recursive flag to true this function will return the fields/fieldid as normal but each field will have its default settings also.">
	<cfargument name="tabID" type="numeric" required="true">
	<cfargument name="recurse" type="boolean" required="false" default="false" hint="If true, this function will return a structure containing every fields and the fields default values.">
	<cfscript>
		var returnArray = ArrayNew(1);
		var fieldStruct = StructNew();
	</cfscript>
	<cfquery name="formFieldQuery" datasource="#request.site.datasource#">
		  select FormInputControlMap.FieldID,FormInputControlMap.ItemPos,FormInputControl.FieldName
			 from FormInputControlMap
    inner join FormInputControl 
				ON FormInputControl.ID = FormInputControlMap.FieldID
  			where TabID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tabID#">
		order by ItemPos
	</cfquery>
	<cfloop query="formFieldQuery">
		<cfscript>
			fieldStruct = StructNew();
			fieldStruct.FieldID = FieldID;
			fieldStruct.FieldName = ReplaceNoCase(FieldName, "FIC_", "", "all");
			fieldStruct.defaultValues = getFieldDefaultValueFromID(FieldID);
			ArrayAppend(returnArray,fieldStruct);
		</cfscript>
	</cfloop>
	<cfreturn returnArray>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$getFieldDefaultValueFromID
Summary:
	Returns struct containing form field default values
Returns:
	struct
Arguments:
	number
History:
--->
<cffunction name="getFieldDefaultValueFromID" hint="Returns struct containing form field default values"
				access="public" 
				returntype="struct"
				description="Attempts to get all relevant default form field information from field id.">
	<cfargument name="fieldID" type="numeric" required="true">
	<cfscript>
		var rtnStruct = StructNew();
		var params = "";
		var formFieldQuery = "";
		var defaultValues = StructNew();
		var multipleFieldQuery = "";
		var fieldQuery = "";
	</cfscript>
	<cfquery name="formFieldQuery" datasource="#request.site.datasource#">
		  select FormID
			 from FormInputControlMap
  			where FieldID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldID#">
	</cfquery>
	<cfloop query="formFieldQuery">
		<cfset multipleFieldQuery = application.ADF.cedata.getElementFieldsByFormID(formID)>
		<!---
			getElementFieldsByFormID returns a resultset that contains EVERY field in the form, we just want the ONE field we need info from...
		--->
		<cfquery name="fieldQuery" dbType="query">
			select * from multipleFieldQuery where fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
		</cfquery>
		<cfscript>
			fieldDefaultValues = application.ADF.cedata.getElementInfoByPageID(pageid=0,formid=formID);
			
			rtnStruct = StructNew();
			params = server.commonspot.udf.util.wddxdecode(fieldQuery.params[1],1);
			defaultValues = StructNew();
			defaultValues.type = fieldQuery.type[1];
			if(structKeyExists(params,"req")){
				defaultValues.required = params.req;
			}
			defaultValues.fieldName = ReplaceNoCase(fieldQuery.fieldName[1], "FIC_", "", "all");
			if(len(fieldDefaultValues.values[defaultValues.fieldName])){
				defaultValues.defaultValue = fieldDefaultValues.values[defaultValues.fieldName];
			}
			if(structkeyexists(params,"label")){
				defaultValues.label = params.label;
			}
			if(structkeyexists(params,"vallist") and params.vallist != ""){
				defaultValues.OptionListSource = "Value List";
				defaultValues.OptionList = params.vallist;
			}
			if(structkeyexists(params,"VALSOURCE")
					and params.VALSOURCE == "element" 
					and structkeyexists(params,"ELEMENTID") 
					and Len(params.ELEMENTID)
				){
				//Its an optionlist on a list of elements! And they selected an element. Figure out what element it is!
				defaultValues.OptionListSource = "Custom Element/Metadata/Simple Form Data";
				defaultValues.DynamicData = getCENameByFormID(params.ELEMENTID);
			}
			if(structkeyexists(params,"val")){
				defaultValues.value = params.val;
			}
			if(structkeyexists(params,"height")){
				defaultValues.height = params.height;
			}
			if(structkeyexists(params,"width")){
				defaultValues.width = params.width;
			}
			if(structkeyexists(params,"maxlength")){
				defaultValues.maxlength = params.maxlength;
			}
			if(structkeyexists(params,"size")){
				defaultvalues.size = params.size;
			}
			if(structkeyexists(params,"cols")){
				defaultvalues.size = params.cols;
			}
			if(structkeyexists(params,"rows")){
				defaultvalues.rows = params.rows;
			}
			rtnStruct = defaultValues;
		</cfscript>
	</cfloop>
	<cfreturn rtnStruct>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	Ryan Kahn
Name:
	$getFieldValueByFieldID
Summary:
	Returns struct containing form field values
Returns:
	struct
Arguments:
	number
History:
--->
<cffunction name="getFieldValuesByFieldID" hint="Returns struct containing form field values" access="public" returntype="struct">
	<cfargument name="fieldID" type="numeric" required="true">
	<cfscript>
		var params = StructNew();
	</cfscript>
	<cfquery name="formFieldQuery" datasource="#request.site.datasource#">
		  select FormID
			 from FormInputControlMap
  			where FieldID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldID#">
	</cfquery>
	<cfloop query="formFieldQuery">
		<cfset multipleFieldQuery = application.adf.cedata.getElementFieldsByFormID(formID)>
		<!---
			getElementFieldsByFormID returns a resultset that contains EVERY field in the form, we just want the ONE field we need info from...
		--->
		<cfquery name="fieldQuery" dbType="query">
			select * from multipleFieldQuery where fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
		</cfquery>
		<cfscript>
			params = server.commonspot.udf.util.wddxdecode(fieldQuery.params[1],1);
		</cfscript>
	</cfloop>
	<cfreturn params>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$exportCEData
Summary:
	given a ce name export its data to a file. Return that file path.
Returns:
	string
Arguments:
	ceName - string
History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="exportCEData" access="public" returntype="string" hint="given a ce name export its data to a file. Return that file path.">
	<cfargument name="ceName" type="string" required="true" default="" hint="CE name to export data from">
	<cfscript>
		var ceDataSerialized = "";
		var ceData = variables.getCEData(arguments.ceName);
		var folder = ExpandPath("#request.site.CSAPPSWEBURL#dashboard/ceExports/");
		var fileName = "#arguments.ceName#--#DateFormat(now(),'YYYY-MM-DD')#-#TimeFormat(now(),'HH-MM')#.txt";
		if(!ArrayLen(ceData)){
			//We have no CE data! return an empty string back
			return "";
		}
	</cfscript>
	<!---	Force the directory to exist--->
	<cfif NOT DirectoryExists(folder)>
		<cfmodule template="/commonspot/utilities/cp-cffile.cfm" action="MKDIR"directory="#folder#" replicate="false">
	</cfif>
	<!---	save the file--->
   <cffile action = "write"  file ="#folder##fileName#" output="#Server.Commonspot.UDF.util.serializeBean(ceData)#">
	<cfreturn folder&fileName>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$importCEData
Summary:
	Given the location of the .exportedCE file preform the import. If clean is specified wipe all existing data.
	Schedules a process with the name: "import-#ceName#" for instance: "import-Nav Element"
Returns:
	Struct
Arguments:
	filePath - String
	clean - boolean
History:
 	Dec 4, 2010 - RAK - Created
--->
<cffunction name="importCEData" access="public" returntype="Struct" hint="Given the contents of an import file, import the data">
	<cfargument name="filePath" type="string" required="true" default="" hint="File path to .exportedCE file">
	<cfargument name="clean" type="boolean" required="false" default="false" hint="Wipe all existing data">
	<cfscript>
		var dataToImport = "";
		var ceData = "";
		var ceName = "";
		var i = 1;
		var currentCE = "";
		var populateResults = "";
		var scheduleArray = ArrayNew(1);
		var scheduleStruct = "";
		var scheduleParams = "";
		var returnStruct = StructNew();
		returnStruct.success = false;
	</cfscript>
	<cftry>
		<cffile action="read" file="#filePath#" variable="dataToImport">
	<cfcatch>
		<cfscript>
			application.ADF.utils.logAppend(application.ADF.utils.doDump(cfcatch,"cfcatch",false,true),"importCEData-Errors.html");
		</cfscript>
		<cfset returnStruct.msg = "Unable to open file.">
		<cfreturn returnStruct>
	</cfcatch>
	</cftry>
	<cfscript>
		if(!len(dataToImport)){
			returnStruct.msg = "The file could not be read properly. Please see the logs.";
			return returnStruct;
		}
		// Horray! The file existed and had content
		ceData = Server.Commonspot.UDF.util.deserialize(dataToImport);
		if(!ArrayLen(ceData)){
			returnStruct.msg = "There was no data to import";
			return returnStruct;
		}
		ceName = ceData[1].formName;
		//We have a valid structure! lets do our clean if requested and continue on.
		if(arguments.clean){
			variables.deleteByElementName(ceName);
		}
		for(i=1;i<=ArrayLen(ceData);i=i+1){
			//Create the params for the populate content call
			currentCE = StructNew();
			currentCE.elementType = "custom";
			currentCE.submitChange = true;
			currentCE.submitChangeComment = "Element imported using CE Data import utility.";
			currentCE.dataPageID = ceData[i].pageID;
			structAppend(currentCE,ceData[i].values);

			//Build the populateContent call for the schedule
			scheduleStruct = StructNew();
			scheduleStruct.bean = "csContent_1_0";
			scheduleStruct.method = "populateContent";
			scheduleStruct.args.elementName = ceName;
			scheduleStruct.args.data = currentCE;
			
			//Add the item to the schedule
			ArrayAppend(scheduleArray,scheduleStruct);
		}

		//Setup the schedule params
		scheduleParams = StructNew();
		scheduleParams.delay = 1; //minutes till next schedule item
		scheduleParams.tasksPerBatch = 20; //how many tasks to do per iteration

		//Schedule it!
		returnStruct.scheduleID = "import-#ceName#";
		application.ADF.scheduler.scheduleProcess(returnStruct.scheduleID,scheduleArray,scheduleParams);
		returnStruct.msg = "Import scheduled succesfully!";
		returnStruct.elementName = ceName;
		returnStruct.success = true;
		return returnStruct;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$getElementByNameAndCSPageID
Summary:
	ElementStruct
Returns:
	struct
Arguments:
	name - string
	pageID - numeric
History:
 	Dec 15, 2010 - RAK - Created
--->
<cffunction name="getElementByNameAndCSPageID" access="public" returntype="struct" hint="ElementStruct">
	<cfargument name="name" type="string" required="true" default="" hint="Name of the element">
	<cfargument name="pageID" type="numeric" required="true" default="-1" hint="Commonspot Page ID">
	<cfscript>
		var rtnData = StructNew();
		var elementWDDX = "";
		var elementQuery = "";
		var elementPageID = "";
		var elementFormID = "";
	</cfscript>
	<cfquery name="elementQuery" datasource="#request.site.datasource#">
			select dw.elementData,ci.controlType
			from controlInstance ci
			inner join data_wddx dw on (
					dw.pageID = ci.pageID and
					dw.controlID = ci.controlID )
			where ci.pageid = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.pageID#">
			and controlName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
	</cfquery>
	<cfif elementQuery.RecordCount>
		<cfscript>
			elementWDDX = elementQuery.elementData;
			elementWDDX = server.commonspot.udf.util.wddxdecode(elementWDDX);
			elementPageID = ListGetAt(elementWDDX.lastRecord,1,"|");
			elementFormID = elementQuery.controlType;
			rtnData = getElementInfoByPageID(elementPageID,elementFormID);
		</cfscript>
	</cfif>
	<cfreturn rtnData>
</cffunction>

<!---
/* ************************************************************** */
Author: 	Ron West
Name:
	$buildCEDataArryFromQuery
Summary:	
	Returns a standard CEData Array to be used in Render Handlers from a ceDataView query
Returns:
	Array ceDataArray
Arguments:
	Query ceDataQuery
History:
 	2010-04-08 - RLW - Created
	2010-12-21 - MFC - Added function to CEDATA
--->
<cffunction name="buildCEDataArrayFromQuery" access="public" returntype="array" hint="Returns a standard CEData Array to be used in Render Handlers from a ceDataView query">
	<cfargument name="ceDataQuery" type="query" required="true" hint="ceData Query (usually built from ceDataView) results to be converted">
	<cfscript>
		var ceDataArray = arrayNew(1);
		var itm = "";
		var row = "";
		var column = "";
		var tmp = "";
		var formName = "";
		var i = "";
		var commonFieldList = "pageID,formID,dateAdded,dateCreated";
		var fieldStruct = structNew();
	</cfscript>
	<!--- <cfdump var="#arguments.ceDataQuery#"> --->

	<cfloop from="1" to="#arguments.ceDataQuery.recordCount#" index="row">
		<cfscript>
			tmp = structNew();
			// add in common fields			
			for( i=1; i lte listLen(commonFieldList); i=i+1 )
			{				
				commonField = listGetAt(commonFieldList, i);
				// handle each of the common fields
				if( findNoCase(commonField, arguments.ceDataQuery.columnList) )
					tmp[commonField] = arguments.ceDataQuery[commonField][row];
				else
					tmp[commonField] = "";
				// do special case work for formID/formName
				if( commonField eq "formID" )
				{
					if( not len(formName) )
						formName = application.ptBlog2.ceData.getCENameByFormID(tmp.formID);
					tmp.formName = formName;
				}
			}
			tmp.values = structNew();
			// get the fields structure for this element
			fieldStruct = application.ptBlog2.forms.getCEFieldNameData(tmp.formName);
			// loop through the field query and build the values structure
			for( itm=1; itm lte listLen(structKeyList(fieldStruct)); itm=itm+1 )
			{
				column = listGetAt(structKeyList(fieldStruct), itm);
				if( listFindNoCase(arguments.ceDataQuery.columnList, column) )
					tmp.values[column] = arguments.ceDataQuery[column][row];
			}
			arrayAppend(ceDataArray, tmp);
		</cfscript>
	</cfloop>
	<cfreturn ceDataArray>
</cffunction>

<!---
/* *************************************************************** */
Author: 	Ron West
Name:
	$buildRealTypeView
Summary:	
	Builds an element view for the posts2 element
Returns:
	Boolean viewCreated
Arguments:
	String ceName
	String viewName
History:
	2010-04-07 - RLW - Created
	2010-06-18 - SF - [Steve Farwell] Bug fix for building the view for MySQL
	2010-12-21 - MFC - Added function to CEDATA
--->
<cffunction name="buildRealTypeView" access="public" returntype="boolean">
	<cfargument name="elementName" type="string" required="true">
	<cfargument name="viewName" type="string" required="false" default="ce_#arguments.elementName#View">
	<cfscript>
		var viewCreated = false;
		var formID = application.ptBlog2.ceData.getFormIDByCEName(arguments.elementName);
		var dbType = Request.Site.SiteDBType;
		var realTypeView = '';
		var fieldsSQL = '';
		var fldqry = '';
		var intType = '';
		switch (dbtype)
		{
			case 'Oracle':
				intType = 'number(12)';
				break;
			case 'MySQL':
				intType = 'UNSIGNED';
				break;
			case 'SQLServer':
				intType = 'int';
				break;
		}
	</cfscript>

	<!--- // make sure that we actually have a form ID --->
	<cfif len(formID) and formID GT 0>
		<!--- // delete the view if it exsists already delete it --->
		<cftry>
			<cfquery name="deleteView" datasource="#request.site.dataSource#">
				Drop view #arguments.viewName#
			</cfquery>
			<cfcatch></cfcatch>
		</cftry>
	
		<cfquery name="fldqry" datasource="#Request.Site.DataSource#">
			select fic.ID, fic.type, fic.fieldName
			  from formINputControl fic, forminputcontrolMap
			 where forminputcontrolMap.fieldID  = fic.ID
				and forminputcontrolMap.formID = <cfqueryparam value="#formID#" cfsqltype="cf_sql_integer">
		</cfquery>
		
		<cfquery name="realTypeView" datasource="#Request.Site.DataSource#">
			CREATE VIEW #arguments.viewName# AS
			SELECT
			<cfloop query="fldqry">
				max(
				<cfswitch expression="#fldqry.type#">
					<cfcase value="integer">
					CASE
						WHEN FieldID = #ID# THEN CAST(fieldvalue as #intType#)
						ELSE 0
					END
					</cfcase>
					<cfcase value="float">
					CASE
						WHEN FieldID = #ID# THEN CAST(fieldvalue as DECIMAL(7,2))
						ELSE 0.0
					END
					</cfcase>
				<cfcase value="large_textarea,formatted_text_block">
					CASE
						WHEN FieldID = #ID# THEN
							CASE
								WHEN (fieldvalue is NOT NULL or fieldValue <> '')
								THEN fieldvalue
					<cfif dbtype is 'oracle'>
								<!--- WHEN length(memovalue) < 4000 THEN CAST(memovalue as varchar2(4000)) --->
								ELSE CAST([memovalue] AS nvarchar2(2000))
					<cfelseif dbtype is 'mssql'>
								ELSE CAST([memovalue] AS nvarchar(2000))
                    <cfelse>  
                    			<!--- Don't CAST if using MySQL --->          
					</cfif>
				   		END
						ELSE null
					END
				</cfcase>
				<cfdefaultcase> <!--- NEEDSWORK fieldtype like List, should add ListID column, fieldtype like email, could add 'lower case' function to avoid case sensitive issue --->
				CASE
					WHEN FieldID = #ID# THEN LOWER(fieldvalue)
					ELSE null
				END
				</cfdefaultcase>
				</cfswitch>
				<!--- ) as FieldID#ID#, --->
				) as #listGetAt(fieldName, 2, "_")#,
			</cfloop>
		   			PageID, controlID, formID<!--- , dateApproved, dateAdded --->
			  FROM data_fieldvalue
			 where formID = #formID#
				and versionstate >= 2
				and PageID > 0
		 GROUP BY PageID, ControlID, formID<!--- , dateApproved, dateAdded --->
		</cfquery>
		<cfset viewCreated = true>
	</cfif>
	<cfreturn viewCreated>
</cffunction>

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	M. Carroll
Name:
	$getDataPageIDFromControlIDandPageID
Summary:
	Returns the CE Data Page ID based on the Control ID and CommonSpot Page ID.
Returns:
	numeric
Arguments:
	numeric
	numeric
History:
	2010-12-23 - MFC - Created
--->
<cffunction name="getDataPageIDFromControlIDandPageID" access="public" returntype="numeric" hint="Returns the CE Data Page ID based on the Control ID and CommonSpot Page ID.">
	<cfargument name="controlID" type="numeric" required="true">
	<cfargument name="pageID" type="numeric" required="true">

	<cfset var retDataPageID = -1>
	<cfset var getDataWDDX = QueryNew("null")>
	<cfset var elementData = StructNew()>

	<!--- Query Data_WDDX to get the data for the control --->
	<cfquery name="getDataWDDX" datasource="#request.site.datasource#">
		SELECT 	*
		FROM 	Data_WDDX
		WHERE 	pageID = <cfqueryparam value="#arguments.pageID#" cfsqltype="cf_sql_integer">
		AND		controlID = <cfqueryparam value="#arguments.controlID#" cfsqltype="cf_sql_integer">
		AND 	versionState = 2
	</cfquery>
	
	<cfscript>
		// Check that we got records
		if ( getDataWDDX.RecordCount ) {
			// Transform the WDDX data
			elementData = server.commonspot.udf.util.wddxdecode(getDataWDDX.ElementData);
			// Get the data page ID out
			retDataPageID = ListFirst(elementData.LASTRECORD,"|");
		}
		return retDataPageID;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$differentialSync
Summary:
	Given a list of custom elements, custom element create or update or optionally delete elements
Returns:
	boolean
Arguments:

History:
 	12/22/10 - RAK - Created
--->
<cffunction name="differentialSync" access="public" returntype="struct" hint="Given a list of custom elements, custom element create or update or optionally delete elements">
	<cfargument name="elementName" type="string" required="true" default="" hint="Name of the element to sync">
	<cfargument name="newElements" type="array" required="true" default="" hint="'New' or old Elements to be sync'd">
	<cfargument name="preformDelete" type="boolean" required="false" default="false" hint="Boolean flag to preform delete. Does not delete by default.">
	<cfargument name="primaryKeys" type="string" required="false" default="_pageID" hint="A list of primary keys to use to compare elements 'reserved word' _pageID, ex: links,title,_pageID">
	<cfargument name="ignoreFields" type="string" required="false" default="" hint="A List of field names to ignore">
   <cfargument name="newOverride" type="struct" required="false" default="#StructNew()#" hint="Override of the new functionality. Specify a bean and method.">
	<cfargument name="updateOverride" type="struct" required="false" default="#StructNew()#" hint="Override of the update functionality. Specify a bean and method.">
	<cfargument name="deleteOverride" type="struct" required="false" default="#StructNew()#" hint="Override of the delete functionality. Specify a bean and method.">
  	<cfscript>
		var returnStruct = StructNew();
		var srcElements = "";
		var len = "";
		var tempStruct = StructNew();
		var srcElementStruct = '';
		var i = '';
		var keysToSync = '';
		var syncLen = '';
		var currentKey = '';
		var currentElement = '';
		var isDifferent = '';
		var j = '';
		var currentKeyValue = '';
		var newKeyValue = '';
		var commandArray = ArrayNew(1);
		var deleteList = '';
		var dataPageIDList = '';
		var scheduleParams = "";
		returnStruct.success = false;
		returnStruct.msg = "An unknown error occurred.";

		//*********************************************Begin validation*********************************************//

		if(!Len(arguments.elementName)){
			returnStruct.msg = "Element name must be defined.";
			return returnStruct;
		}
		if(!ArrayLen(arguments.newElements)){
			returnStruct.msg = "The list of elements to by sync'd is not defined.";
			return returnStruct;
		}
		if(!StructIsEmpty(arguments.updateOverride)){
			//The defined an override
			if(!StructKeyExists(arguments.updateOverride,"bean")
					|| !StructKeyExists(arguments.updateOverride,"method")
					|| !Len(arguments.updateOverride.method)
					|| !Len(arguments.updateOverride.bean)){
				returnStruct.msg = "Invalid structure for updateOverride, it must be a structure with keys bean and method which are string values.";
				return returnStruct;
			}
		}else{
			arguments.updateOverride.bean = "csContent_1_0";
			arguments.updateOverride.method = "populateContent";
		}
		arguments.updateOverride.args.elementName = arguments.elementName;
		arguments.updateOverride.args.data = StructNew();
		if(!StructIsEmpty(arguments.deleteOverride)){
			//The defined an override
			if(!StructKeyExists(arguments.deleteOverride,"bean")
					|| !StructKeyExists(arguments.deleteOverride,"method")
					|| !Len(arguments.deleteOverride.method)
					|| !Len(arguments.deleteOverride.bean)){
				returnStruct.msg = "Invalid structure for deleteOverride, it must be a structure with keys bean and method which are string values.";
				return returnStruct;
			}
		}else{
			arguments.deleteOverride.bean = "ceData_1_0";
			arguments.deleteOverride.method = "deleteCE";
		}
		arguments.deleteOverride.args.datapageidList = "";

		if(!StructIsEmpty(arguments.newOverride)){
			//The defined an override
			if(!StructKeyExists(arguments.newOverride,"bean")
					|| !StructKeyExists(arguments.newOverride,"method")
					|| !Len(arguments.newOverride.method)
					|| !Len(arguments.newOverride.bean)){
				returnStruct.msg = "Invalid structure for newOverride, it must be a structure with keys bean and method which are string values.";
				return returnStruct;
			}
		}else{
			arguments.newOverride.bean = "csContent_1_0";
			arguments.newOverride.method = "populateContent";
		}
		arguments.newOverride.args.elementName = arguments.elementName;
		arguments.newOverride.args.data = StructNew();

		//*********************************************End Validation*********************************************//
		
		/*
			Goal: Update the elements that have been changed and don't touch those which have not.
			1. Get all the existing records (srcElements)
				a. first serialize the primary key fields and store them in a lookup struct for detection
			2. Loop over newElements (arguments.newElements)
			3. If the newElement exists in the srcElements record check to see if it changed.
			4. If the subjectID does not exist in struct create a new record
			5. Loop over remaining subjectID's and delete them
		*/
		//1. Get all the existing records (srcElements)
		srcElements = getCEData(arguments.elementName);
		//1a. first serialize the primary key fields and store them in a lookup struct for detection
		srcElementStruct = StructNew();
		len=ArrayLen(srcElements);
		for(i=1;i<=len;i++){
			StructInsert(srcElementStruct,__generateStructKey(srcElements[i],arguments.primaryKeys),srcElements[i],true);
		}
		//2. Loop over newElements (arguments.newElements)
		/*
			However first lets get a list of keys that will be checked.
			1. get a list of all keys
			2. Remove from the list the ignored keys
		*/
		keysToSync = StructKeyList(arguments.newElements[1].values);
		len = ListLen(arguments.ignoreFields);
		for(i=1;i<=len;i++){
			currentKey = ListGetAt(arguments.ignoreFields,i);
			keysToSync = ListDeleteAt(keysToSync,ListFindNoCase(keysToSync,currentKey));
		}
		syncLen = ListLen(keysToSync);
		len=ArrayLen(arguments.newElements);
		for(i=1;i<=len;i++){
			newElement = arguments.newElements[i];
			//Figure out the element's lookup key
			currentKey = __generateStructKey(newElement,arguments.primaryKeys);
			//3. If the newElement exists in the srcElements record check to see if it changed.
			if(StructKeyExists(srcElementStruct,currentKey)){
				currentElement = srcElementStruct[currentKey];
				/* Check to see if it changes...
				1. Loop over comparing each key in the sync list
				2. If we notice a discrepancy flag it for update.
				3. Remove the element from the srcElementStruct since we found it
				*/
				isDifferent = false;
				if(Len(ignoreFields)){//Check each key individually
					for(j=1;j<=syncLen;j++){
						syncKey = ListGetAt(keysToSync,j);
						currentKeyValue = StructFind(currentElement.values,syncKey);
						newKeyValue = StructFind(newElement.values,syncKey);
						if(!currentKeyValue.Equals(newKeyValue)){
							isDifferent = true;
							break;
						}
					}
				}else{//check the entire object. Faster.
					currentKeyValue = currentElement.values;
					newKeyValue = newElement.values;
					if(!currentKeyValue.Equals(newKeyValue)){
						isDifferent = true;
					}
				}
				if(isDifferent){
					//We have a change on our hands! Do something!
				   arguments.updateOverride = duplicate(updateOverride);
					arguments.updateOverride.args.data = newElement.values;
					arguments.updateOverride.args.data.pageID = newElement.pageID;
					ArrayAppend(commandArray,arguments.updateOverride);
				}else{
					//This guy is not different. Do nothing for now.
				}
				StructDelete(srcElementStruct,currentKey);
			}else{
				//A new guy eh...
				arguments.newOverride = duplicate(newOverride);
				arguments.newOverride.args.data = StructNew();
				arguments.newOverride.args.data = newElement.values;
				ArrayAppend(commandArray,arguments.newOverride);
			}
		}
		//5. Loop over remaining subjectID's and delete them
		if(arguments.preformDelete){
			deleteList = StructKeyList(srcElementStruct);
			len = ListLen(deleteList);
			dataPageIDList = "";
			for(i=1;i<=len;i++){
				currentElement = structFind(srcElementStruct,listGetAt(deleteList,i));
				dataPageIDList = ListAppend(dataPageIDList,currentElement.pageID);
			}
			arguments.deleteOverride.args.datapageidList = dataPageIDList;
			ArrayAppend(commandArray,arguments.deleteOverride);
		}
//		Application.ADF.utils.doDump(commandArray,"commandArray",true);
		returnStruct.msg = "Differential sync scheduled succesfully!";
		returnStruct.success=true;
		returnStruct.scheduleID=arguments.elementName&"-differentialSync";
		scheduleParams = StructNew();
		scheduleParams.delay = 1;
		scheduleParams.tasksPerBatch = 25;
		application.ADF.scheduler.scheduleProcess(returnStruct.scheduleID,commandArray,scheduleParams);
		return returnStruct;
	</cfscript>
</cffunction>

<!---
/* ***************************************************************
/*
Author: 	
	PaperThin, Inc.
	Ryan Kahn
Name:
	$_getStructKey
Summary:	
	Helper function for getting the structures unique identifier as a string
Returns:
	string
Arguments:
	
History:
 	1/20/11 - RAK - Created
--->
<cffunction name="__generateStructKey" access="private" returntype="string" hint="Helper function for getting the structures unique identifier as a string">
	<cfargument name="element" type="struct" required="true" default="" hint="Element that we will get the key from">
	<cfargument name="primaryKeys" type="string" required="true" default="" hint="String of keys to search within the element for">
	<cfscript>
		var tempStruct = StructNew();
		var pkLength = ListLen(arguments.primaryKeys);
		var i = "";
		var currentKey = "";
		for(i=1;i<=pkLength;i++){
			//Insert into the struct the value from the other struct and keep its level
			currentKey = ListGetAt(arguments.primaryKeys,i);
			if(currentKey == "_pageID"){//Reserved pageID vkey
				StructInsert(tempStruct,currentKey,ToString(arguments.element.pageID),true);
			}else{
				StructInsert(tempStruct,currentKey,StructFind(arguments.element.values,currentKey),true);
			}
		}
		rtn = SerializeJSON(tempStruct);
		return rtn;
	</cfscript>

</cffunction>

</cfcomponent>