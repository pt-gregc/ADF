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
/* *************************************************************** */
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
	2011-02-09 - RAK - Var'ing un-var'd variables
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
		var formTabQuery = '';
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
/* *************************************************************** */
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
	2011-01-30 - RLW - modified the argument tabID to be a list instead of just a single tabID
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getFieldsFromTabID" hint="Returns array containing form field name and id in order from the tabID"
				access="public" 
				returntype="array"
				description="From tab id this can return either a simple listing of fields/fieldid in order. With recursive flag to true this function will return the fields/fieldid as normal but each field will have its default settings also.">
	<cfargument name="tabIDList" type="string" required="true">
	<cfargument name="recurse" type="boolean" required="false" default="false" hint="If true, this function will return a structure containing every fields and the fields default values.">
	<cfscript>
		var returnArray = ArrayNew(1);
		var formFieldQuery = '';
		var fieldStruct = StructNew();
	</cfscript>
	<cfquery name="formFieldQuery" datasource="#request.site.datasource#">
		  select FormInputControlMap.FieldID,FormInputControlMap.ItemPos,FormInputControl.FieldName
			 from FormInputControlMap
    inner join FormInputControl 
				ON FormInputControl.ID = FormInputControlMap.FieldID
  			where TabID in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.tabIDList#" list="Yes">)
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
/* *************************************************************** */
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
	2011-02-09 - RAK - Var'ing un-var'd variables
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
		var fieldDefaultValues = '';
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
					and params.VALSOURCE eq "element"
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
/* *************************************************************** */
Author: 	Ryan Kahn
Name:
	$getFieldParamsByID
Summary:
	Returns struct containing form parameters for a field (e.g. ID, Label, Required etc...)
Returns:
	struct
Arguments:
	number
History:
	2011-01-30 - RLW - Modified - Added additional parameters to the return structure
	2011-02-09 - RAK - Var'ing un-var'd variables
--->
<cffunction name="getFieldParamsByID" hint="Returns struct containing form field parameters (e.g. ID, Label, Required etc...)" access="public" returntype="struct">
	<cfargument name="fieldID" type="numeric" required="true">
	<cfscript>
		var multipleFieldQuery = '';
		var formFieldQuery = '';
		var fieldQuery = '';
		var params = StructNew();
	</cfscript>
	<cfquery name="formFieldQuery" datasource="#request.site.datasource#">
		  select FormID
			 from FormInputControlMap
  			where FieldID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fieldID#">
	</cfquery>
	<cfloop query="formFieldQuery">
		<cfset multipleFieldQuery = getElementFieldsByFormID(formID)>
		<!---
			getElementFieldsByFormID returns a resultset that contains EVERY field in the form, we just want the ONE field we need info from...
		--->
		<cfquery name="fieldQuery" dbType="query">
			select * from multipleFieldQuery where fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
		</cfquery>
		<cfscript>
			params = server.commonspot.udf.util.wddxdecode(fieldQuery.params[1],1);
			// add in some additional params from the query
			params.type = fieldQuery.type;
			params.name = fieldQuery.fieldName;
		//	params.description = fieldQuery.description;
		</cfscript>
	</cfloop>
	<cfreturn params>
</cffunction>

<!---
/* *************************************************************** */
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
	2011-01-28 - GAC - Modified - Added a exportFolder parameter so an alternate destionation folder can be assigned
--->
<cffunction name="exportCEData" access="public" returntype="string" hint="given a ce name export its data to a file. Return that file path.">
	<cfargument name="ceName" type="string" required="true" default="" hint="CE name to export data from">
	<cfargument name="exportFolder" type="string" required="false" default="#request.site.CSAPPSWEBURL#dashboard/ceExports/" hint="Destination Folder for export file">
	<cfscript>
		var ceDataSerialized = "";
		var ceData = variables.getCEData(arguments.ceName);
		var folder = ExpandPath("#arguments.exportFolder#");
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
/* *************************************************************** */
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
	filePath - String - File path to .exportedCE file
	clean - boolean - Wipe all existing data
	ceName - String - Set this if you are importing a csv, this is how we know what to import.
	ccapiCEName - string - Use this field if you Custom Element name is different than your CCAPI config XML node name
History:
 	2010-12-04 - RAK - Created
	2011-01-26 - RAK - Updated to allow importing csv files
	2011-01-28 - GAC - Added a parameter for passing in the CCAPI config XML node name
	2011-02-09 - RAK - Added arguments. to a variable, seemingly for no reason.
--->
<cffunction name="importCEData" access="public" returntype="Struct" hint="Given the contents of an import file, import the data">
	<cfargument name="filePath" type="string" required="true" default="" hint="File path to .exportedCE file">
	<cfargument name="clean" type="boolean" required="false" default="false" hint="Wipe all existing data">
	<cfargument name="ceName" type="string" required="false" default="" hint="Set this if you are importing a csv, this is how we know what to import.">
	<cfargument name="ccapiCEName" type="string" required="false" default="#arguments.ceName#" hint="Use this field if you Custom Element name is different than your CCAPI config XML node name">
	<cfscript>
		var rowData = '';
		var tempStruct = '';
		var dataToImport = "";
		var ceData = "";
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
	</cfscript>
	<cfif !isArray(ceData) && Find(",",dataToImport) && Len(ceName)>
		<!---	Boo, we didnt deserialize properly which means its probably a csv. Parse the crap out of it--->
		<cfscript>
			if(!Find('"',dataToImport)){
				//Wrap everything with quotes.
				for(i=2;i lte ListLen(dataToImport,chr(10)); i++){
					rowData = ListGetAt(dataToImport,i,chr(10));
					rowData = '"#Replace(rowData,",",'","',"ALL")#"';
					dataToImport = ListSetAt(dataToImport,i,rowData,chr(10));
				}
				//Replace the empty strings with Chr(1) and remove all the quotes we just added.
				dataToImport = Replace(dataToImport,'""',Chr(1),"ALL");
				dataToImport = Replace(dataToImport,'"',"","ALL");
			}
			ceData = variables.data.queryToArrayOfStructures(variables.data.csvToQuery(dataToImport));
			for(i=1;i <= ArrayLen(ceData);i++){
				tempStruct = StructNew();
				tempStruct.values = ceData[i];
				tempStruct.formName = arguments.ceName;
				ceData[i] = tempStruct;
			}
		</cfscript>
	</cfif>
	<cfscript>
		if(!ArrayLen(ceData)){
			returnStruct.msg = "There was no data to import";
			return returnStruct;
		}
		arguments.ceName = ceData[1].formName;
		if ( LEN(TRIM(arguments.ccapiCEName)) )
			arguments.ceName = arguments.ccapiCEName;
		
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
			if(StructKeyExists(ceData[i],"pageID")){
				currentCE.dataPageID = ceData[i].pageID;
			}
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
//Application.ADF.utils.doDump(scheduleArray,"scheduleArray",0);

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
/* *************************************************************** */
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
	2010-12-15 - RAK - Created
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
	2011-02-08 - RAK - Removing ptBlog2 from the function calls as this is not running in ptBlog2 and should never have been here. Its fixed now at least...
	2011-04-04 - MFC - Updated function to load the Forms from the server object factory.
						Attempted to add dependency but ADF build throws error.
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
						formName = getCENameByFormID(tmp.formID);
					tmp.formName = formName;
				}
			}
			tmp.values = structNew();
			// get the fields structure for this element
			fieldStruct = server.ADF.objectFactory.getBean("Forms_1_1").getCEFieldNameData(tmp.formName);
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
	2011-02-08 - RAK - Removing ptBlog2 from the function calls as this is not running in ptBlog2 and should never have been here. Its fixed now at least...
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-02-15 - RAK - Removing lowercasing of view values
	2011-03-14 - MFC - Update the viewname variable to remove spaces.
	2011-04-25 - MFC - Commented out the Oracle DB cast for "large_textarea,formatted_text_block".
	2011-04-27 - MFC - Updated the SQL WHEN condition to only check for empty string.
						Updated the "large_textarea,formatted_text_block" CASE for the IF condition when 'SQLServer'.
						Changed memoValue field size to "max".
--->
<cffunction name="buildRealTypeView" access="public" returntype="boolean">
	<cfargument name="elementName" type="string" required="true">
	<cfargument name="viewName" type="string" required="false" default="ce_#arguments.elementName#View">
	<cfscript>
		var deleteView = '';
		var viewCreated = false;
		var formID = getFormIDByCEName(arguments.elementName);
		var dbType = Request.Site.SiteDBType;
		var realTypeView = '';
		var fieldsSQL = '';
		var fldqry = '';
		var intType = '';
		// Remove the spaces in the name
		arguments.viewName = Replace(arguments.viewName, " ", "_", "all");
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
									<!--- 2011-04-27 - MFC - Changed condition to only check for empty string. --->
									WHEN fieldValue <> '' THEN fieldvalue
						<cfif dbtype is 'oracle'>
									<!--- TODO 
											Issue with Oracle DB and casting the 'memovalue' field. 
											Commented out to make this work in Oracle, but still needs to be resolved.
									 --->
									<!--- WHEN length(memovalue) < 4000 THEN CAST(memovalue as varchar2(4000)) --->
									<!--- ELSE CAST([memovalue] AS nvarchar2(2000)) --->
						<cfelseif dbtype is 'SQLServer'>
									ELSE CAST([memovalue] AS nvarchar(max))
	                    <cfelse>  
	                    			<!--- Don't CAST if using MySQL ---> 
						</cfif>
					   		END
							ELSE null
						END
					</cfcase>
					<cfdefaultcase> <!--- NEEDSWORK fieldtype like List, should add ListID column, fieldtype like email, could add 'lower case' function to avoid case sensitive issue --->
						CASE
							WHEN FieldID = #ID# THEN fieldvalue
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
	controlID - numeric
	pageID - numeric
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
/* *************************************************************** */
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
	elementName - string - Name of the element to sync
	newElements - array - 'New' or old Elements to be sync'd
	preformDelete - boolean - Boolean flag to preform delete. Does not delete by default.
	primaryKeys - string - A list of primary keys to use to compare elements 'reserved word' _pageID, ex: links,title,_pageID
	ignoreFields - string - A List of field names to ignore
	newOverride - struct - Override of the new functionality. Specify a bean and method.
	updateOverride - struct - Override of the update functionality. Specify a bean and method.
	deleteOverride - struct - Override of the delete functionality. Specify a bean and method.
History:
 	2010-22-12 - RAK - Created
 	2011-31-01 - RAK - Fixed issue where it would not compare properly if the keys passed in did not exactly match those in the elemeent
	2011-02-09 - RAK - Var'ing un-var'd variables
	2011-02-14 - RAK - Fixing issue where it tries to delete from index 0 of a list
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
		var manualCompare = false;
      		var syncKey = '';
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
			if(ListFindNoCase(keysToSync,currentKey)){
				keysToSync = ListDeleteAt(keysToSync,ListFindNoCase(keysToSync,currentKey));
			}
		}
		syncLen = ListLen(keysToSync);
		len=ArrayLen(arguments.newElements);
		//If the keys on the input struct dont match the keys on the source then we need to manually compare.
		if(ArrayLen(srcElements) and ListLen(StructKeyList(arguments.newElements[1].values)) neq ListLen(StructKeyList(srcElements[1].values))){
			manualCompare = true;
		}
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
				if(Len(ignoreFields) || manualCompare){//Check each key individually
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
					arguments.updateOverride.args.data.dataPageID = currentElement.pageID;
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
		if(arguments.preformDelete and !structIsEmpty(srcElementStruct)){
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
		returnStruct.msg = "Differential sync scheduled succesfully!";
		returnStruct.success=true;
		if(ArrayLen(commandArray)){
			returnStruct.scheduleID=arguments.elementName&"-differentialSync";
			scheduleParams = StructNew();
			scheduleParams.delay = 1;
			scheduleParams.tasksPerBatch = 25;
			application.ADF.scheduler.scheduleProcess(returnStruct.scheduleID,commandArray,scheduleParams);
		}
		return returnStruct;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
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
	element - struct- Element that we will get the key from
	primaryKeys - string- String of keys to search within the element for
History:
 	1/20/11 - RAK - Createdring - String of keys to search within the element for
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

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$searchForCEData
Summary:
	Wrapper function for getCEData
Returns:
	array
Arguments:
	 customElementName - string- Custom element name
	 searchValues - string- Values to search for
	 searchFields - string- Fields to search within
History:
 	2011-02-25 - RAK - Created
--->
<cffunction name="searchForCEData" access="public" returntype="array" hint="Wrapper function for getCEData">
	<cfargument name="customElementName" type="string" required="true" hint="Custom element name">
	<cfargument name="searchValues" type="string" required="false" default="" hint="Values to search for">
	<cfargument name="searchFields" type="string" required="false" default="" hint="Fields to search within">
	<cfreturn getCeData(
						customElementName = arguments.customElementName,
						queryType="search",
						searchValues = arguments.searchValues,
						searchFields = arguments.searchFields
	)>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$multipleFieldFindCEData
Summary:
	Wrapper function for getCEData multi call
Returns:
	array
Arguments:

History:
 	2011-02-25 - RAK - Created
--->
<cffunction name="multipleFieldFindCEData" access="public" returntype="array" hint="Wrapper function for getCEData multi call">
	<cfargument name="customElementName" type="string" required="true" hint="Custom element name">
	<cfargument name="searchValues" type="string" required="false" default="" hint="Values to search for">
	<cfargument name="searchFields" type="string" required="false" default="" hint="Fields to search within">
		<cfreturn getCeData(
						customElementName = arguments.customElementName,
						queryType="multi",
						searchValues = arguments.searchValues,
						searchFields = arguments.searchFields
	)>
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$findFileCEFieldID
Summary:
	Finds the custom element's field ID
Returns:
	string
Arguments:

History:
	2011-02-15 - RAK - Created
--->
<cffunction name="findFileCEFieldID" access="public" returntype="string" hint="Finds the custom element's field ID">
	<cfargument name="ceName" type="string" required="true" default="" hint="Custom element name to search within">
	<cfargument name="fieldName" type="string" required="true" default="" hint="Field Name to search for">
	<cfscript>
		var tabs = '';
		var tab = '';
		var field = '';
		 tabs = application.ADF.ceData_1_1.getTabsFromFormID(getFormIDByCEName(arguments.ceName),true);
	</cfscript>
	<cfloop array="#tabs#" index="tab">
		<cfloop array="#tab.fields#" index="field">
			<cfif field.FIELDNAME eq arguments.fieldName>
				<cfreturn field.fieldID>
			</cfif>
		</cfloop>
	</cfloop>
	<cfreturn "">
</cffunction>

<!---
/* ***************************************************************
/*
Author:
	Ryan Kahn
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
	2011-03-01 - RAK - Created, adds security into getCEdata
	2011-03-10 - MFC - NOT READY FOR PRIMETIME YET!
						More thought needed for the existing ADF users.
--->
<!--- <cffunction name="getCEData" access="public" returntype="array" hint="Returns array of structs for all data matching the Custom Element.">
	<cfargument name="customElementName" type="string" required="true">
	<cfargument name="customElementFieldName" type="string" required="false" default="">
	<cfargument name="item" type="any" required="false" default="">
	<cfargument name="queryType" type="string" required="false" default="selected">
	<cfargument name="searchValues" type="string" required="false" default="">
	<cfargument name="searchFields" type="string" required="false" default="">
	<!---
		2011-03-01 - RAK - Security determining if you can get the CEData is set in the proxyWhitelist files
	--->
	<cfscript>
		if(NOT variables.csSecurity.validateProxy("getCEDataSecurity",arguments.customElementName)){
			/*Security failed. Append to the log and return nothing useful.*/
			application.ADF.utils.logAppend("Get CEData call to non-whitelisted element: #arguments.customElementName#","getCEDataSecurityException.txt");
			return ArrayNew(1);
		}else{
			/*Passed security! Pass off to parent.*/
			return super.getCEData(
				arguments.customElementName,
				arguments.customElementFieldName,
				arguments.item,
				arguments.queryType,
				arguments.searchValues,
				arguments.searchFields);
		}
	</cfscript>
</cffunction> --->


<!---
/* ***************************************************************
/*
Author:
	PaperThin, Inc.
	Ryan Kahn
Name:
	$arrayOfCEDataMerge
Summary:
	Merges 2 arrays of CEData without duplicates.
Returns:
	array
Arguments:

History:
 	2011-04-27 - RAK - Created
--->
<cffunction name="arrayOfCEDataMerge" access="public" returntype="array" hint="Merges 2 arrays of CEData without duplicates.">
	<cfargument name="array1" type="array" required="true" default="" hint="Array to merge">
	<cfargument name="array2" type="array" required="true" default="" hint="Array to merge">
	<cfscript>
		var dataStruct = StructNew();
		var rtnArray = ArrayNew(1);

		for(i=1;i<=ArrayLen(array1);i++){
			StructInsert(dataStruct,array1[i].pageID,array1[i],true);
		}
		for(i=1;i<=ArrayLen(array2);i++){
			StructInsert(dataStruct,array2[i].pageID,array2[i],true);
		}
		for(key in dataStruct){
			ArrayAppend(rtnArray,StructFind(dataStruct,key));
		}
		return rtnArray;
	</cfscript>
</cffunction>


</cfcomponent>