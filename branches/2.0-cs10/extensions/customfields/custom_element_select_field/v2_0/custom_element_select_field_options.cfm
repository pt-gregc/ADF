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

<!-------------
Author: 	
	PaperThin, Inc. 
Name:
	$custom_element_select_field_options.cfm
Summary:
	This file is included in the custom_element_select_field_filter.cfm for the ADF Custom Element Select field type.					
History:
	2014-02-26 - DJM - Created						
	2014-03-17 - GAC - Added dbType="QofQ" to the handle-in-list call inside the getFilteredRecords Query of queries
	2015-05-26 - DJM - Added the 2.0 version
	2015-12-15 - DJM - Updated code to send displayText if returnCurrentOnly is true
--->

<cfscript>
	getProperties = QueryNew('');
	optionsStruct = StructNew();
	optionsStruct.fieldHTML = "";
	cfmlInputParams = StructNew();
</cfscript>

<!--- Get the properties for the form and field IDs passed --->
<cfquery name="getProperties" datasource="#Request.Site.DataSource#">
	SELECT d2.params as InputParams, d3.FieldID, d2.fieldName, d2.description
	  FROM FormInputControl d2
   	INNER JOIN FormInputControlMap d3 ON d3.FieldID = d2.ID 
	INNER JOIN FormControl d1 ON d1.ID = d3.FormID   	 
	LEFT OUTER JOIN CustomFieldTypes cft ON d2.Type = cft.Type
	 WHERE d3.FormID = #attributes.sourceFormID#
	 AND cft.ID = #attributes.customFieldTypeID#
	 AND d3.FieldID = #attributes.sourceFieldID#
</cfquery>

<cfscript>
	if (getProperties.RecordCount AND IsWDDX(getProperties.InputParams))
	{
		cfmlInputParams = Server.CommonSpot.UDF.util.WDDXDecode(getProperties.InputParams);
		if( cfmlInputParams.CustomElement NEQ '' AND cfmlInputParams.DisplayField NEQ '' AND cfmlInputParams.ValueField NEQ '' )
			optionsStruct = createOptionsStructure(propertiesStruct=cfmlInputParams,currentValues=attributes.currentValues,returnCurrentOnly=attributes.returnCurrentOnly); // Call function that would buid up the options struct
	}

	multiple = '';
	if( StructKeyExists(cfmlInputParams, 'MultipleSelect') AND cfmlInputParams.MultipleSelect eq 1)
		multiple = 'multiple';
	
	if (multiple eq 'multiple')
		caller.fieldHTML = getFieldHTML(optionsStruct=optionsStruct, sourceFieldID=attributes.sourceFieldID, currentValues=attributes.currentValues);
		
	caller.optionsStruct = optionsStruct;
	caller.multiple = multiple;
	caller.label = cfmlInputParams.label;
	caller.description = getProperties.description;
	selectedValDisplayText = '';
	if (attributes.returnCurrentOnly AND ArrayLen(optionsStruct.optionText))
		selectedValDisplayText = ArrayToList(optionsStruct.optionText, '<br/>');

	caller.selectedValDisplayText = selectedValDisplayText;
</cfscript>
<!----// FUNCTIONS //----------------------------->

<cffunction name="getFieldHTML" returnType="any" hint="generates HTML with a div tag for the select field with multiple options list">
	<cfargument name="optionsStruct" type="struct" required="yes" hint="available options for this field">
	<cfargument name="sourceFieldID" type="string" required="yes" hint="ID of this source field">
	<cfargument name="currentValues" type="string" required="yes" hint="current values list">
	<cfscript>
		var fldHTML = '';
		var stringEnd = "</div>";
		var stringStart = '<div id="div_selectField_#arguments.sourceFieldID#"  style="width:300px;min-height:70px;max-height:200px;overflow:auto;border:1px inset ##999999;padding:3px;display:block;cursor:pointer;">';
		var i = 0;
		var optVals = arguments.optionsStruct['optionValues'];
		var optTxt = arguments.optionsStruct['optionText'];
		var html = '';
		var cssTxt = '';

	</cfscript>
	
	<cfsavecontent variable="html">
		<cfscript>
			if (arrayLen(optVals) eq arrayLen(optTxt))
			{
				for (i = 1; i le arrayLen(optVals); i=i+1)
				{
					WriteOutput('#Server.CommonSpot.udf.tag.checkboxRadio(type="checkbox", name="selectField_#arguments.sourceFieldID#", value="#optVals[i]#", checked="#ListFind(arguments.currentValues, optVals[i])#", title="#optTxt[i]#", label="#optTxt[i]#", labelClass="chxBoxLabel")#');
					if (i lt arrayLen(optVals))
						WriteOutput('<br />');
				}
			
			}
		</cfscript>
	</cfsavecontent>	
	<cfsavecontent variable="cssTxt">
	<cfoutput>
		<style>
		.chxBoxLabel
		{
			color: ##000000 !important;
			font-weight: normal !important;
			font-size: 11px !important;
			text-decoration: none !important;
		}
	</style>
	</cfoutput>
	</cfsavecontent>
	<cfscript>
		html = '#cssTxt##stringStart##html##stringEnd#';
		return html;
	</cfscript>
</cffunction>

<cffunction name="createOptionsStructure" returntype="struct" hint="Creates the data-display pair for the options of the selection list" output="true">
	<cfargument name="propertiesStruct" type="struct" required="yes" hint="Input the properties values">
	<cfargument name="currentValues" type="string" required="yes" hint="Input the current value for the field">
	<cfargument name="returnCurrentOnly" type="boolean" required="yes" hint="Boolean value indicating whether to return selected values only or not">
		
	<cfscript>
		var cfmlInputParams = arguments.propertiesStruct;
		var optionsStruct = StructNew();
		var ceID = 0;
		var sortColumn = '';
		var sortDir = '';		
		var ceObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var cfmlFilterCriteria = StructNew();
		var fieldList = '';
		var tmpFieldsArray = ArrayNew(1);
		var ceDataArray = QueryNew('');
		var filterArray = ArrayNew(1);
		var ceFieldsArray = ArrayNew(1);
		var valueWithoutParens = '';
		var hasParens = 0;
		var statementsArray = ArrayNew(1);
		var index = 0;
		var ceData = QueryNew('');
		var formIDColArray = ArrayNew(1);
		var formNameColArray = ArrayNew(1);
		var i = 0;
		var valueArray = ArrayNew(1);
		var displayArray = ArrayNew(1);
		var displayField = '';
		var getFilteredRecords = QueryNew('');
		var ceFieldsArrayLen = '';
		var fldsQry = '';		
		var tc = getTickCount();		
		var start = 0;
		var end = 0;
		var fld = '';
		
		if (StructKeyExists(cfmlInputParams,"customElement") and Len(cfmlInputParams.customElement))
			ceID = request.site.availControlsByName['custom:#cfmlInputParams.CustomElement#'].ID;		
	</cfscript>
	
	<cfif ceID GT 0 AND StructKeyExists(cfmlInputParams,"valueField") and Len(cfmlInputParams.valueField) AND StructKeyExists(cfmlInputParams,"displayField") and Len(cfmlInputParams.displayField)>
		<cfscript>
			if ( StructKeyExists(cfmlInputParams,"activeFlagField") and Len(cfmlInputParams.activeFlagField) and StructKeyExists(cfmlInputParams,"activeFlagValue") and Len(cfmlInputParams.activeFlagValue) ) 
			{
				if ( (TRIM(LEFT(cfmlInputParams.activeFlagValue,1)) EQ "[") AND (TRIM(RIGHT(cfmlInputParams.activeFlagValue,1)) EQ "]"))
				{
					valueWithoutParens = MID(cfmlInputParams.activeFlagValue, 2, LEN(cfmlInputParams.activeFlagValue)-2);
					hasParens = 1;
				}
				else
				{
					valueWithoutParens = cfmlInputParams.activeFlagValue;
				}
				
				// Run Query from Filter				
				statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=ceID,fieldIDorName=cfmlInputParams.activeFlagField,operator='Equals',value=valueWithoutParens);
				filterArray = ceObj.createQueryEngineFilter(filterStatementArray=statementsArray,filterExpression='1');

				if (hasParens)
				{
					filterArray[1] = ReplaceNoCase(filterArray[1], '| #valueWithoutParens#| |', '#valueWithoutParens#| ###valueWithoutParens###| |');
				}
			}
			
			if (NOT StructKeyExists(cfmlInputParams, 'filterCriteria') OR NOT IsWDDX(cfmlInputParams.filterCriteria))
			{
				if ( StructKeyExists(cfmlInputParams,"sortByField") and cfmlInputParams.sortByField NEQ '--')
				{
					sortColumn = cfmlInputParams.sortByField;
					sortDir = 'asc';
				}
				
				if (NOT Len(sortColumn) AND cfmlInputParams.displayField neq "--Other--")
				{
					sortColumn = cfmlInputParams.displayField;
					sortDir = 'asc';
				}
			}
			else
			{
				cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(cfmlInputParams.filterCriteria);	
				if ( StructKeyExists(cfmlFilterCriteria,"filter") )		
					filterArray = cfmlFilterCriteria.filter.serSrchArray;
				sortColumn = ListFirst(cfmlFilterCriteria.defaultSortColumn,'|');
				sortDir = ListLast(cfmlFilterCriteria.defaultSortColumn,'|');
			}

			if( StructKeyExists(cfmlInputParams, "displayField") AND LEN(cfmlInputParams.displayField) AND cfmlInputParams.displayField neq "--Other--" ) 
				fieldList = '#cfmlInputParams.displayField#,#cfmlInputParams.valueField#';
			else if( cfmlInputParams.displayField eq "--Other--" AND cfmlInputParams.DisplayFieldBuilder neq '' )
			{
				start = 1;
				fieldList = '';
				while( true )
				{
					start = FindNoCase( Chr(171), cfmlInputParams.DisplayFieldBuilder, start );
					if( start )
					{
						end = FindNoCase( Chr(187), cfmlInputParams.DisplayFieldBuilder, start );
						if( end )
						{
							fld = Mid( cfmlInputParams.DisplayFieldBuilder, start + 1, (end - (start+1)) );
							if( NOT FindNoCase( fld, fieldList ) )
								fieldList = ListAppend( fieldList, fld ); 
							start = end;	
						}
						else
							break;
					}
					else
						break;
				}
				// if value field not already in list, add it to the list			
				if( NOT FindNoCase( cfmlInputParams.valueField, fieldList ) )
					fieldList = ListAppend( fieldList, cfmlInputParams.valueField ); 
			}
			else
			{
				fieldList = cfmlInputParams.valueField;
			}
				

			if (NOT ArrayLen(filterArray))
				filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';


			if( sortDir eq '' )
				sortDir = 'Asc';
						
			ceData = ceObj.getRecordsFromSavedFilter( 
											elementID=ceID,
											queryEngineFilter=filterArray,
											columnList=fieldList,
											orderBy=sortColumn,
											orderByDirection=sortDir, 
											limit=0);

		</cfscript>
		
		<cfif ceData.ResultQuery.RecordCount>
			<cfif arguments.returnCurrentOnly AND Len(arguments.currentValues)>
				<cfquery name="getFilteredRecords" dbtype="query">
					SELECT *
					  FROM ceData.ResultQuery
					 WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="#cfmlInputParams.valueField#" LIST="#arguments.currentValues#" CFSQLTYPE="cf_Sql_varchar" dbType="QofQ">
				</cfquery>
			<cfelse>
				<cfset getFilteredRecords = ceData.ResultQuery>
			</cfif>
			
			<cfscript>		
				if( getFilteredRecords.RecordCount gt 0 )
				{
					ArraySet(formIDColArray, 1, getFilteredRecords.RecordCount, ceID);
					ArraySet(formNameColArray, 1, getFilteredRecords.RecordCount, cfmlInputParams.customElement);

					QueryAddColumn(getFilteredRecords, 'formID', formIDColArray);
					QueryAddColumn(getFilteredRecords, 'formName', formIDColArray);
				}
		
				ceDataArray = application.ADF.cedata.buildCEDataArrayFromQuery(getFilteredRecords);

				if( StructKeyExists(cfmlInputParams, "displayField") AND LEN(cfmlInputParams.displayField) AND cfmlInputParams.displayField neq "--Other--" ) 
					ceDataArray = application.ADF.cedata.arrayOfCEDataSort(ceDataArray, sortColumn, sortDir);

			</cfscript>
		</cfif>
	</cfif>
	
	<cfif ArrayLen(ceDataArray)>
		<cfloop index="i" from="1" to="#ArrayLen(ceDataArray)#">
			<cfscript>
				ArrayAppend(valueArray, ceDataArray[i].Values[cfmlInputParams.valueField]);
			
				if (cfmlInputParams.displayField eq "--Other--" and Len(cfmlInputParams.displayFieldBuilder))
					displayField = application.ADF.forms.renderDataValueStringfromFieldMask(ceDataArray[i].Values, cfmlInputParams.displayFieldBuilder);
				else
					displayField = ceDataArray[i].Values[cfmlInputParams.displayField];
					
				ArrayAppend(displayArray, displayField);
			</cfscript>
		</cfloop>
	</cfif>
	
	<cfscript>
		optionsStruct['optionValues'] = valueArray;
		optionsStruct['optionText'] = displayArray;

		return optionsStruct;
	</cfscript>
</cffunction>