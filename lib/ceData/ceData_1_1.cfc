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
	ceData_1_1.cfc
Summary:
	Custom Element Data functions for the ADF Library
Version
	1.1
History:
	2011-01-25 - MFC - Created - New v1.1
	2011-10-04 - GAC - Updated csSecurity dependency to csSecurity_1_1
	2012-03-19 - GAC - Updated and fixed comment headers
--->
<cfcomponent displayname="ceData_1_1" extends="ADF.lib.ceData.ceData_1_0" hint="Custom Element Data functions for the ADF Library">

<cfproperty name="version" value="1_1_9">
<cfproperty name="type" value="singleton">
<cfproperty name="csSecurity" type="dependency" injectedBean="csSecurity_1_1">
<cfproperty name="data" type="dependency" injectedBean="data_1_1">
<cfproperty name="wikiTitle" value="CEData_1_1">

<!---
/* *************************************************************** */
Author: 	
	PaperThin, Inc.
	Ryan Kahn
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
	<cfargument name="formID" type="numeric" required="true" hint="FormID to get the tabs from">
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
Author:
	PaperThin, Inc.	
	Ryan Kahn
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
	<cfargument name="tabIDList" type="string" required="true" hint="list of tab IDs to get fields from">
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
Author: 	
	PaperThin, Inc.
	Ryan Kahn
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
	2011-05-04 - MFC - Added check for CS 5 to decode the HTML escaped param WDDX.
	2012-04-16 - GAC - Removed the circular references to application.ADF.cedata
--->
<cffunction name="getFieldDefaultValueFromID" hint="Returns struct containing form field default values"
				access="public" 
				returntype="struct"
				description="Attempts to get all relevant default form field information from field id.">
	<cfargument name="fieldID" type="numeric" required="true" hint="Field ID to get the default values from">
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
		<cfset multipleFieldQuery = getElementFieldsByFormID(formID)>
		<!---
			getElementFieldsByFormID returns a resultset that contains EVERY field in the form, we just want the ONE field we need info from...
		--->
		<cfquery name="fieldQuery" dbType="query">
			select * from multipleFieldQuery where fieldID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fieldID#">
		</cfquery>
		<cfscript>
			fieldDefaultValues = getElementInfoByPageID(pageid=0,formid=formID);
			rtnStruct = StructNew();
			
			// 2011-05-04 - MFC - Added check for CS 5 to decode the HTML escaped param WDDX.
			// Check if in CS 5 or lower to decode the HTML in the wddx
			if ( application.ADF.csVersion LT 6 ){
				fieldQuery.params[1] = server.commonspot.udf.data.fromHTML(fieldQuery.params[1]);
			}

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
Author: 	
	PaperThin, Inc.
	Ryan Kahn
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
	2011-05-04 - RAK - Added check for CS 5 to decode the HTML escaped param WDDX.
--->
<cffunction name="getFieldParamsByID" hint="Returns struct containing form field parameters (e.g. ID, Label, Required etc...)" access="public" returntype="struct">
	<cfargument name="fieldID" type="numeric" required="true" hint="Field ID to get params from">
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
			// 2011-05-04 - RAK - Added check for CS 5 to decode the HTML escaped param WDDX.
			// Check if in CS 5 or lower to decode the HTML in the wddx
			if ( application.ADF.csVersion LT 6 ){
				params = server.commonspot.udf.data.fromHTML(params);
			}

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
		<cfmodule template="/commonspot/utilities/cp-cffile.cfm" action="MKDIR" directory="#folder#" replicate="false">
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
		ceData = server.Commonspot.UDF.util.deserialize(dataToImport);
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
		
		// Check that we have a query with values
		if ( arguments.ceDataQuery.recordCount GTE 1 ){
			// Setup the default common fields 
			// get the fields structure for this element
			fieldStruct = server.ADF.objectFactory.getBean("Forms_1_0").getCEFieldNameData(getCENameByFormID(arguments.ceDataQuery["formID"][1]));
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
	Struct fieldTypes
		FIELD TYPE DETERMINATION
			arguments.fieldTypes is a struct keyed by field type, whose values are a list of fields (without 'fic_') that should be forced to that type.
				It can also contain the key defaultTextType, whose value will be used as the type for fields not explicitly spec'd that aren't integer or float.
			Supported types are integer, float, shortText, and longText; anything else is treated as longText, meaning memo/CLOB.
			If no spec is provided:
				The following field types are automatically inferred to be shortText:
					calendar, checkbox, date, email, img, text
				Other fields with a MaxLength given that's short enough for CommonSpot to store values in FieldValue will also be automatically assumed to be shortText.
				Certain expressions in the field's default value are also assumed to be shortText; see code for the list of them.
		BEHAVIOR OF DIFFERENT FIELD TYPES
			Integer and float types CAST FieldValue to the appropriate type for the db.
			Fields spec'd as shortText use FieldValue only, ignoring MemoValue.
				Where possible that's good, because it avoids a SQL expressions, and because memo-style columns typically support only LIKE queries, so they also can't be joined against.
				However, with shortText, values longer than 425 characters will be returned by the view as NULL, because CommonSpot stores values that size in MemoText, not FieldValue.
		ORACLE COMPATIBILITY
			Oracle can't combine FieldValue and MemoValue in any way that supports comparisons other than LIKE, and therefor joins, without truncating data at 4000 characters.
				For that reason, fieldTypes customized for the view's specific usage may be required if Oracle compatibility is needed.
			Default here is to truncate, assuming that those comparisons are more likely than needing to get the whole MemoValue from these views.
				Declaring a field as longText uses the LIKE-only non-truncating version instead.
		THE OPTIMAL STRATEGY
			Pass defaultTextType="shortText", and list all longText fields explicitly.
			That uses the simple FieldValue-only definition for all text columns except ones explicitly made longText, which use the LIKE-only non-truncating syntax.
			This approach is fully compatible with Oracle.
		CAPTURING VIEW SQL
			If you want to capture the view creation SQL, append this to the URL of a request that will attempt to create the views you want to capture:
				?adfLogViewSQL=1
			The SQL used to create the view will be written to a file named {date}.{site}.ADFlogViewSQL.log, in the CommonSpot logs directory.
			If an error occurs, view sql will still be written to that file, with an indication that there was an error.
			
CODING PATTERNS
	Ideally, direct calls to this method should be replaced by calls to ceData_2_0.buildView().
		That lets you explicitly force the view to rebuild always, even if it already exists.
	Where custom view specs or view names are required (which is common), one approach is to use the following pattern in your App.cfc:
		Create a getCEViewSpecs(customElementName) method, which returns the appropriate fieldTypes struct for each custom element the app creates views for.
		If desired, override the inherited getCEViewName(customElementName), with one that returns the view names you want to use.
		Override the buildView method inherited from ceData_2_0, calling those getCEViewSpecs and getCEViewName methods, then calling cedata's buildView method.
		See the PT Calendar app for an example.
	An alternative is for each DAO in an app to own its own view specs, and for App.cfc to call each of them in postInit.
	Bottom line:
		You should think about what code should be creating views, and related, what code owns view specs.
		Make sure that all code that might build or rebuild views has access to view specs.

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
	2011-05-03 - RAK - Modified code to default to try the memo field if the data is null or ''
	2010-09-24 - GAC - Added an optional FIX for use with SQL2000. The FIX is commented out since SQL 2000 is not widely used.
	2012-06-20 - GAC - Updated the SQL to allow CE Field names with underscores (_). Changed the 'AS {FIELDNAME}' to strip the "FIC_" instead of using a ListGetAt with an underscore delimiter.
					 - Also added brackets [] around the {FIELDNAME} to allow for field names that might be reserved or non-standard SQL field names.
	2012-08-03 - DMB - Added check for db type around the square brackets Greg added and rendered single quotes instead if under mySQL.
	2012-10-16 - DMB - Updated to use the memovalue field for fields longer than 425 characters.
	2012-10-24 - GAC - Added a db type version check to uncomment the fix for using nvarchar(4000) instead of nvarchar(max) for older versions of MSSQL.
					 - Moved the memovalue field fix into the conditional logic for MySQL. In the old position the syntax caused MSSQL view table creation to fail. 
	2013-01-08 - MFC - Added TRY-CATCH for error handling when generating the view table.
	2013-02-04 - MFC - Added IF statement to check that the view table name has a length.
	2013-11-19 - DRM - Major rework of how the generated view combines FieldValue and MemoValue
						part of Oracle case was never written
						allow passing of fieldTypes struct, docs above about its use
						various ways to auto-detect if a field can be short text
						don't truncate data on recent SQL Server
						honor ntext vs text type of MemoValue col
						log error if there is one (was only a comment there before)
						some cleanup, including removing query names where result is ignored
	2014-02-19 - GAC - Added local variables for the VersionState Operator and Value
	2014-02-19 - GAC - Added escape characters for reserverd words in custom element field names
--->
<cffunction name="buildRealTypeView" access="public" returntype="boolean" hint="Builds an element view for the passed in element name">
	<cfargument name="elementName" type="string" required="true" hint="element name to build the view table off of">
	<cfargument name="viewName" type="string" default="" hint="Override the view name that gets generated">
	<cfargument name="fieldTypes" type="struct" default="#structNew()#" hint="See notes above.">
	<cfscript>
		var viewCreated = false;
		var formID = getFormIDByCEName(arguments.elementName);
		var dbType = Request.Site.SiteDBType;
		var dbInfo = server.commonspot.datasources[Request.Site.Datasource];
		var dbVersion = "";
		var fieldsSQL = "";
		var fieldInfo = "";
		var fieldType = "";
		var defaultFieldType = "";
		var fieldParams = "";
		var fieldMaxLength = 0;
		var isUnicode = siteDBIsUnicode();
		var fieldTypeIndex = structNew();
		var fieldsArray = "";
		var selectSyntax = "";
		var selectSyntaxLong = "";
		var selectExpr = "";
		var intType = "";
		var qryMemoColType = "";
		var colAlias = "";
		var maxFieldValueLen = 425;
		var logSQL = (structKeyExists(Request.Params, "adfLogViewSQL") and Request.Params.adfLogViewSQL eq 1);
		var logMsg = "";
		var i = 0;
		var createViewResult = QueryNew('temp');
		var versionStateOpr = "=";
		var versionStateValue = 2;

		// make sure that we actually have a form ID
		if (formID eq "" or formID LTE 0)
			return false;

		if (arguments.viewName eq "")
			arguments.viewName = "ce_#arguments.elementName#View";

		// Remove the spaces in the name
		arguments.viewName = Replace(arguments.viewName, " ", "_", "all");

		// Set the db version if available
		if (StructKeyExists(dbInfo,"version"))
			dbVersion = ListFirst(dbInfo.version,".");

		if (structKeyExists(Request.Constants, "dfvFieldvalueColumnMax"))
			maxFieldValueLen = Request.Constants.dfvFieldvalueColumnMax;

		// build struct of types for each field alias out of arguments.fieldTypes, which is a list of columns for each spec'd type
		for (fieldType in arguments.fieldTypes)
		{
			fieldsArray = listToArray(arguments.fieldTypes[fieldType]);
			for (i = 1; i lte arrayLen(fieldsArray); i = i + 1)
			{
				if (fieldType eq "defaultTextType")
					defaultFieldType = arguments.fieldTypes[fieldType];
				else
					fieldTypeIndex[fieldsArray[i]] = fieldType;
			}
		}
		
		// Set datatypes and select exprs for different db types
		switch (dbtype)
		{
			case 'Oracle':
				intType = 'number(12)';
				// see notes above for fieldSpecs argument
				selectSyntax = "CASE WHEN FieldValue IS NOT NULL THEN FieldValue ELSE CAST(MemoValue AS VARCHAR(4000)) END"; // truncates data, no choice
				selectSyntaxLong = "CASE WHEN FieldValue IS NOT NULL THEN TO_CLOB(FieldValue) ELSE MemoValue END"; // supports LIKE comparison only, no choice
				if (isUnicode)
					selectSyntaxLong = replace(selectSyntaxLong, "TO_CLOB", "TO_NCLOB");
				break;

			case 'MySQL':
				intType = 'UNSIGNED';
				selectSyntax = "CASE WHEN FieldValue IS NOT NULL AND FieldValue <> '' THEN FieldValue ELSE MemoValue END"; // tolerates implicit cast between the two cols
				break;

			case 'SQLServer':
				intType = 'int';
				selectSyntax = "CAST(CASE WHEN FieldValue IS NOT NULL AND FieldValue <> '' THEN FieldValue ELSE MemoValue END AS VARCHAR(MAX))";
				if (dbVersion LT 9) // 9 = MSSQL 2005
					selectSyntax = replace(selectSyntax, "VARCHAR(MAX)", "VARCHAR(4000)"); // MSSQL 2000 and below don't have VARCHAR(MAX); this truncates data, no choice
				break;
		}
		
		if (isUnicode)
			selectSyntax = replace(selectSyntax, "VARCHAR", "NVARCHAR");
			
		if (selectSyntaxLong eq "") // only Oracle has different longText syntax
			selectSyntaxLong = selectSyntax;
	</cfscript>

	<!--- delete the view if it exists already --->
	<cftry>
		<cfquery datasource="#Request.Site.Datasource#">
			DROP VIEW #arguments.viewName#
		</cfquery>
		<cfcatch><!--- assume it's because view didn't exist, we're good ---></cfcatch>
	</cftry>

	<cftry>
		<cfquery name="fieldInfo" datasource="#Request.Site.Datasource#">
			SELECT fic.FieldName, fic.Type, fic.Params, ficm.FormID, fic.ID AS FieldID, dv.FieldValue AS FieldDefaultValue
			  FROM FormInputControl fic
			  JOIN FormInputControlMap ficm ON ficm.FieldID = fic.ID
			  LEFT OUTER JOIN Data_FieldValue dv ON dv.FormID = ficm.FormID AND dv.FieldID = fic.ID AND PageID = 0 <!--- default value spec, if there is one --->
			 WHERE ficm.FormID = <cfqueryparam value="#formID#" cfsqltype="CF_SQL_INTEGER">
			 ORDER BY ID <!--- should be recs for all fields, but just in case, put oldest one first, as main table in the join, avoiding missing pseudo-rows from fields that aren't there --->
		</cfquery>
		<cfscript>
			firstTableName = "dfv_#fieldInfo.FieldID#";
		</cfscript>

		<cfquery datasource="#Request.Site.Datasource#" result="createViewResult" >
CREATE VIEW #arguments.viewName# AS
SELECT
<cfloop query="fieldInfo">
	<cfscript>
		table = "dfv_#FieldID#";
		colAlias = ReplaceNoCase(FieldName, "FIC_", "");
		fieldType = Type;
		fieldMaxLength = 0;
		if (structKeyExists(fieldTypeIndex, colAlias))
			fieldType = fieldTypeIndex[colAlias];
		else if (listFindNoCase("calendar,checkbox,date,email,img,text", Type)) // CommonSpot field types we know can't be too long to fit in FieldValue
			fieldType = "shortText";
		else if (listFindNoCase("request.formattedTimeStamp,request.user.id,request.user.userid,request.page.id,request.subsite.id,createUUID(),now()", FieldDefaultValue)) // default value expressions implying short text
			fieldType = "shortText";
		else if (fieldType neq "integer" and fieldType neq "float")
			fieldType = ""; // flag to check max length
	</cfscript>
	<cfif fieldType eq ""><!--- no decision yet, need to check max length --->
		<cfset fieldType = defaultFieldType><!--- use spec'd default if nothing else is definitive --->
		<cfif isWDDX(Params)>
			<cfwddx action="WDDX2CFML" input="#Params#" output="fieldParams">
			<cfscript>
				if (structKeyExists(fieldParams, "maxLength"))
				{
					fieldMaxLength = val(fieldParams.maxLength);
					if (fieldMaxLength gt maxFieldValueLen) // too long for FieldValue
						fieldType = "longText";
					else if (fieldMaxLength gt 0) // max length spec'd and not too long
						fieldType = "shortText";
				}
			</cfscript>
		</cfif>
	</cfif>
	<cfscript>
		// next line writes field type debug info into the query if enabled (doesn't break anything)
		//writeOutput("	/* fieldType=#fieldType# haveTypeSpec=#structKeyExists(fieldTypeIndex, colAlias)# Type=#Type# MaxLength=#fieldMaxLength# DefaultValue=#FieldDefaultValue# */#chr(10)#");
		switch(fieldType)
		{
			case "integer":
				selectExpr = "CAST(FieldValue as #intType#)";
				break;
			case "float":
				selectExpr = "CAST(FieldValue as DECIMAL(7,2))";
				break;
			case "shortText":
				selectExpr = "FieldValue";
				break;
			case "longText":
				selectExpr = selectSyntaxLong;
				break;
			default:
				selectExpr = selectSyntax;
		}
		selectExpr = replaceList(selectExpr, "FieldValue,MemoValue", "#table#.FieldValue,#table#.MemoValue");
		
		if (dbtype eq "SQLServer")
			colAlias = '[#colAlias#]';
		else if (dbtype eq "MySQL")
			colAlias = '`#colAlias#`';
		else if (dbtype eq "Oracle")
			colAlias = '"#colAlias#"';	
			
		selectExpr = "#selectExpr# AS #colAlias#,#chr(10)#";
		writeOutput(selectExpr);
	</cfscript>
</cfloop>
#firstTableName#.FormID, #firstTableName#.ControlID, #firstTableName#.PageID
<cfloop query="fieldInfo">
<cfset table = "dfv_#FieldID#">
<cfif CurrentRow eq 1>FROM Data_FieldValue #table#<cfelse>
LEFT OUTER JOIN Data_FieldValue #table# ON #table#.FormID = #FormID# AND #table#.FieldID = #FieldID# AND #table#.VersionState #versionStateOpr# #versionStateValue# AND #table#.PageID = #firstTableName#.PageID</cfif>
</cfloop>
<cfloop query="fieldInfo" startrow="1" endrow="1">
<cfset table = "dfv_#FieldID#"><!--- this WHERE clause is the first table's equivalent of the JOIN constraints for other tables --->
WHERE #table#.FormID = #FormID# AND #table#.FieldID = #FieldID# AND #table#.VersionState #versionStateOpr# #versionStateValue# AND #table#.PageID > 0
</cfloop>
		</cfquery>

		<cfscript>
			viewCreated = true;
			if ( logSQL and StructKeyExists(createViewResult,"sql") )
				server.ADF.objectFactory.getBean("utils_1_2").logAppend("#arguments.viewName##Chr(10)##createViewResult.sql##repeatString("-", 50)#", "ADFlogViewSQL.log");
		</cfscript>

		<cfcatch>
			<cfscript>
				logMsg = "[ceData_1_1.buildRealTypeView] Error building view: #arguments.viewName##Chr(10)##cfcatch.message# #cfcatch.detail#";
				logMsg = "#logMsg##chr(10)#QUERY SQL:#chr(10)##cfcatch.sql#";
				server.ADF.objectFactory.getBean("utils_1_2").logAppend(logMsg);
			</cfscript>
		</cfcatch>
	</cftry>

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
	<cfargument name="controlID" type="numeric" required="true" hint="ControlID to get datapageID from">
	<cfargument name="pageID" type="numeric" required="true" hint="pageID to get datapageID from">

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
	Given a list of custom elements, create or update or optionally delete elements.
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
	2011-06-02 - RAK - added the ability to specify your own sync source of an array of CEDAta
	2011-06-03 - RAK - added the ability to specify the ccapi name, if not specified it defaults to using the element name
	2011-07-08 - MFC - Replaced variable named 'len'.
						Added check to remove duplicate records in the source data on the delete process (in step 1a).
						Updated the build key list in step 5 with a unique delimiter for key values that may contain "," in the text.
	2011-07-17 - MFC - Removed update to step 5, this has been cleared up when generating the key.
						Added call to clear the "currentElement" variable when looping in step 2.
	2013-04-11 - MFC - Updated the calls to "generateStructKey" function for the new function name.
--->
<cffunction name="differentialSync" access="public" returntype="struct" hint="Given a list of custom elements, create or update or optionally delete elements.">
	<cfargument name="elementName" type="string" required="true" default="" hint="Name of the element to sync">
	<cfargument name="newElements" type="array" required="true" default="" hint="'New' or old Elements to be sync'd">
	<cfargument name="preformDelete" type="boolean" required="false" default="false" hint="Boolean flag to preform delete. Does not delete by default.">
	<cfargument name="primaryKeys" type="string" required="false" default="_pageID" hint="A list of primary keys to use to compare elements 'reserved word' _pageID, ex: links,title,_pageID">
	<cfargument name="ignoreFields" type="string" required="false" default="" hint="A List of field names to ignore">
    <cfargument name="newOverride" type="struct" required="false" default="#StructNew()#" hint="Override of the new functionality. Specify a bean and method.">
	<cfargument name="updateOverride" type="struct" required="false" default="#StructNew()#" hint="Override of the update functionality. Specify a bean and method.">
	<cfargument name="deleteOverride" type="struct" required="false" default="#StructNew()#" hint="Override of the delete functionality. Specify a bean and method.">
	<cfargument name="syncSourceContent" type="array" required="false" hint="Array of CE Data to use as the sync source">
	<cfargument name="elementCCAPIName" type="string" required="false" default="#arguments.elementName#" hint="CCAPI name for the element to be updated">
  	<cfscript>
		var returnStruct = StructNew();
		var srcElements = "";
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
      	var currSrcElementKey = ""; // Stores the current source element key for building the 'srcElementStruct'.
      	var dupSrcDataPageIDList = ""; // List for DataPageIDs for duplicate recs in source data.
		
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
		arguments.updateOverride.args.elementName = arguments.elementCCAPIName;
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
		arguments.newOverride.args.elementName = arguments.elementCCAPIName;
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
		if(StructKeyExists(arguments,"syncSourceContent")){
			srcElements = arguments.syncSourceContent;
		}else{
			srcElements = getCEData(arguments.elementName);
		}
		//1a. first serialize the primary key fields and store them in a lookup struct for detection
		srcElementStruct = StructNew();
		for(i=1;i<=ArrayLen(srcElements);i++){
			// 2011-07-08 - MFC
			//	Set the source element key to a variable.
			//	Check if the key already exists, then we have a duplicate record.
			currSrcElementKey = generateStructKey(srcElements[i],arguments.primaryKeys);
			if ( NOT StructKeyExists(srcElementStruct, currSrcElementKey) )
				StructInsert(srcElementStruct,currSrcElementKey,srcElements[i],true);
			else
				dupSrcDataPageIDList = ListAppend(dupSrcDataPageIDList, srcElements[i].pageID);
		}

		//2. Loop over newElements (arguments.newElements)
		/*
			However first lets get a list of keys that will be checked.
			1. get a list of all keys
			2. Remove from the list the ignored keys
		*/
		keysToSync = StructKeyList(arguments.newElements[1].values);
		for(i=1;i<=ListLen(arguments.ignoreFields);i++){
			currentKey = ListGetAt(arguments.ignoreFields,i);
			if(ListFindNoCase(keysToSync,currentKey)){
				keysToSync = ListDeleteAt(keysToSync,ListFindNoCase(keysToSync,currentKey));
			}
		}
		syncLen = ListLen(keysToSync);
		//If the keys on the input struct dont match the keys on the source then we need to manually compare.
		if(ArrayLen(srcElements) and ListLen(StructKeyList(arguments.newElements[1].values)) neq ListLen(StructKeyList(srcElements[1].values))){
			manualCompare = true;
		}

		for(i=1;i<=ArrayLen(arguments.newElements);i++){
			newElement = arguments.newElements[i];
			//Figure out the element's lookup key
			currentKey = generateStructKey(newElement,arguments.primaryKeys);
			// Clear the variable when iterating
			currentElement = StructNew();
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
			dataPageIDList = "";
			for(i=1;i<=ListLen(deleteList);i++){
				currentElement = structFind(srcElementStruct,listGetAt(deleteList,i));
				dataPageIDList = ListAppend(dataPageIDList,currentElement.pageID);
			}
			
			// 2011-07-08 - MFC - Added Step 5a.
			// 5a. Get any duplicate records and add to the delete dataPageIDList
			if ( ListLen(dupSrcDataPageIDList) )
				dataPageIDList = ListAppend(dataPageIDList, dupSrcDataPageIDList);
			
			// Add the dataPageIDList to the delete command
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
	$generateStructKey
Summary:	
	Helper function for getting the structures unique identifier as a string
Returns:
	string
Arguments:
	element - struct- Element that we will get the key from
	primaryKeys - string- String of keys to search within the element for
History:
 	2011-01-20 - RAK - Created - String of keys to search within the element for
	2011-07-17 - MFC - Updated to add check for the key value before adding to the tempStruct.
					   Updated the return to encrypt the key to avoid any problems with JSON string as key.
	2013-04-11 - MFC - Changed the function name from "__generateStructKey" to remove leading underscores.
					   Changed the function access type to public.
--->
<cffunction name="generateStructKey" access="public" returntype="string" hint="Helper function for getting the structures unique identifier as a string">
	<cfargument name="element" type="struct" required="true" default="" hint="Element that we will get the key from">
	<cfargument name="primaryKeys" type="string" required="true" default="" hint="String of keys to search within the element for">
	<cfscript>
		var tempStruct = StructNew();
		var pkLength = ListLen(arguments.primaryKeys);
		var i = "";
		var currentKey = "";
		var keyValue = "";
		for(i=1;i<=pkLength;i++){
			//Insert into the struct the value from the other struct and keep its level
			currentKey = ListGetAt(arguments.primaryKeys,i);
			if(currentKey == "_pageID"){//Reserved pageID vkey
				StructInsert(tempStruct,currentKey,ToString(arguments.element.pageID),true);
			}else{
				// Set the key value and then check if key has a value.
				keyValue = StructFind(arguments.element.values,currentKey);		
				if ( LEN(keyValue) )
					StructInsert(tempStruct,currentKey,StructFind(arguments.element.values,currentKey),true);
			}
		}
		rtn = SerializeJSON(tempStruct);
		// Encrypt the key to avoid any problems with JSON string as key.
		return ENCRYPT(rtn, "diffSync", "CFMX_COMPAT", "Hex");
	</cfscript>

</cffunction>

<!---
/* *************************************************************** */
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
/* *************************************************************** */
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
/* *************************************************************** */
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
	string - ceName - Custom element name to search within
	string - fieldName - Field Name to search for
History:
	2011-02-15 - RAK - Created
	2011-05-04 - MFC - Updated call to 'getTabsFromFormID' function to be local.
--->
<cffunction name="findFileCEFieldID" access="public" returntype="string" hint="Finds the custom element's field ID">
	<cfargument name="ceName" type="string" required="true" default="" hint="Custom element name to search within">
	<cfargument name="fieldName" type="string" required="true" default="" hint="Field Name to search for">
	<cfscript>
		var tabs = '';
		var tab = '';
		var field = '';
		tabs = getTabsFromFormID(getFormIDByCEName(arguments.ceName),true);
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
/* *************************************************************** */
Author:
	PaperThin, Inc.
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
/* ************************************************************** */
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
	array
	array
History:
 	2011-04-27 - RAK - Created
	2011-04-28 - MFC - Var'd looping variables.
--->
<cffunction name="arrayOfCEDataMerge" access="public" returntype="array" hint="Merges 2 arrays of CEData without duplicates.">
	<cfargument name="array1" type="array" required="true" default="" hint="Array to merge">
	<cfargument name="array2" type="array" required="true" default="" hint="Array to merge">
	<cfscript>
		var dataStruct = StructNew();
		var rtnArray = ArrayNew(1);
		var i = 1;
		var key = "";

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