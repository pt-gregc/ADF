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
Custom Field Type:
	Custom Element Select Field 
Name:
	custom element select field_base.cfc
Summary:
	The Base Component for the Custom Element Select Field 
ADF Requirements:
	fields_1_0
	cedata_2_0
History:
	2014-03-07 - GAC - Created
	2014-09-16 - DJM - Fixed issue when the currentValue is empty string or comma
--->

<cfcomponent output="false" displayname="custom element select field_base" extends="ADF.extensions.customfields.customfieldsBase" hint="This the base component for the Custom Element Select field">

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderCustomElementSelect
Summary:
	Returns the HTML for an custom element select control
Returns:
	String
Arguments:
	Any - propertiesStruct
	Numeric - formID
	String - fqFieldName
	String - fieldCurrentValue
	Boolean - isReadOnly
History:
 	2014-03-07 - DJM - Created
	2014-03-13 - GAC - Fix the default values for the var'd ceDataArray and the ceData varaibles
	2014-03-14 - JTP Commented out logic that perform sort. Should have been EQ vs NEQ, but not needed as we are doing client side sorting for --other--
--->
<cffunction name="renderCustomElementSelect" access="public" returntype="String" hint="Returns the HTML for an custom element select control">
	<cfargument name="propertiesStruct" type="any" required="true" hint="Properties structure for the field in json format">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form">
	<cfargument name="fqFieldName" type="string" required="true" hint="Name of the field">
	<cfargument name="fieldCurrentValue" type="string" required="true" hint="Current value for the field">
	<cfargument name="isReadOnly" type="boolean" required="true" hint="Boolean value indicating if the field is read only">
	<cfscript>
		var inputPropStruct = StructNew();
		var formFieldType = '';
		var isSelectionList = 0;
		var ceDataArray = ArrayNew(1);
		var ceData = QueryNew('tmp');
		var formResultHTML = '';
		
		if (IsJSON(arguments.propertiesStruct))
		{
			inputPropStruct = DeserializeJSON(arguments.propertiesStruct);
		}
		else
		{
			inputPropStruct = arguments.propertiesStruct;
		}
		
		formFieldType = getFieldType(inputPropStruct);
		if (formFieldType EQ 'select')
			isSelectionList = 1;
	
		ceData = getCEData(inputPropStruct,arguments.formID,arguments.fieldCurrentValue,arguments.isReadOnly);
		if (ceData.RecordCount)
			ceDataArray = application.ADF.cedata.buildCEDataArrayFromQuery(ceData);

		// Sort the list by the display field value, if its other.. all bets are off we sort via jquery... 
//		if( StructKeyExists(inputPropStruct, "displayField") AND LEN(inputPropStruct.displayField) AND inputPropStruct.displayField eq "--Other--" ) 
//			ceDataArray = application.ADF.cedata.arrayOfCEDataSort(ceDataArray, inputPropStruct.displayField);
	</cfscript>
	
	<!--- Result from the Form Submit --->
	<cfsavecontent variable="formResultHTML">
		<cfif isSelectionList>
			<!--- // Selection List //---->
			<cfoutput>#renderSelectionList(inputPropStruct,arguments.fqFieldName,arguments.fieldCurrentValue,arguments.isReadOnly,ceDataArray)#</cfoutput>		
		<cfelse>
			<!--- // Checkboxes / Radio Buttons //---->
			<cfoutput>#renderCheckBoxRadio(inputPropStruct,arguments.fqFieldName,arguments.fieldCurrentValue,formFieldType,ceDataArray)#</cfoutput>		
		</cfif>
	</cfsavecontent>
	<cfreturn formResultHTML>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getFieldType
Summary:
	Returns the type of field to be rendered for an custom element select control
Returns:
	String
Arguments:
	Struct - propertiesStruct
History:
 	2014-03-07 - DJM - Created
--->
<cffunction name="getFieldType" access="public" returntype="string" hint="Returns the type of field to be rendered for an custom element select control">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var formFieldType = '';
		if( NOT StructKeyExists(inputPropStruct,"fieldtype") OR inputPropStruct.fieldtype eq 'select' )		
		{
			formFieldType = 'select';
		}	
		else	
		{
			if( inputPropStruct.multipleSelect )
				formFieldType = 'checkbox';
			else
				formFieldType = 'radio';	
		}
		return formFieldType;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$getCEData
Summary:
	Return the data for the custom elemnt select field
Returns:
	Query
Arguments:
	Struct - propertiesStruct
	Numeric - formID
	String - fieldCurrentValue
	Boolean - isReadOnly
History:
 	2014-03-07 - DJM - Created
--->
<cffunction name="getCEData" access="public" returntype="query" hint="Return the data for the custom elemnt select field">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="formID" type="numeric" required="true" hint="ID of the form">
	<cfargument name="fieldCurrentValue" type="string" required="true" hint="Current value for the field">
	<cfargument name="isReadOnly" type="boolean" required="true" hint="Boolean value indicating if the field is read only">
	<cfscript>
		var inputPropStruct = arguments.propertiesStruct;
		var ceObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
		var valueWithoutParens = '';
		var hasParens = 0;
		var statementsArray = ArrayNew(1);
		var filterArray = ArrayNew(1);
		var cfmlFilterCriteria = StructNew();
		var sortColumn = '';
		var sortDir = '';
		var fieldList = '';
		var start = 0;
		var end = 0;
		var ceData = StructNew();
		var formIDColArray = ArrayNew(1);
		var formNameColArray = ArrayNew(1);
		var returnData = QueryNew('');
		var ceFormID = arguments.formID;
		var currentValue = arguments.fieldCurrentValue;
		
		if ( StructKeyExists(inputPropStruct,"activeFlagField") and Len(inputPropStruct.activeFlagField) and StructKeyExists(inputPropStruct,"activeFlagValue") and Len(inputPropStruct.activeFlagValue) ) 
		{
			if ( (TRIM(LEFT(inputPropStruct.activeFlagValue,1)) EQ "[") AND (TRIM(RIGHT(inputPropStruct.activeFlagValue,1)) EQ "]"))
			{
				valueWithoutParens = MID(inputPropStruct.activeFlagValue, 2, LEN(inputPropStruct.activeFlagValue)-2);
				hasParens = 1;
			}
			else
			{
				valueWithoutParens = inputPropStruct.activeFlagValue;
			}
				
			statementsArray[1] = ceObj.createStandardFilterStatement(customElementID=ceFormID,fieldIDorName=inputPropStruct.activeFlagField,operator='Equals',value=valueWithoutParens);
					
			filterArray = ceObj.createQueryEngineFilter(filterStatementArray=statementsArray,filterExpression='1');
			
			if (hasParens)
			{
				filterArray[1] = ReplaceNoCase(filterArray[1], '| #valueWithoutParens#| |', '#valueWithoutParens#| ###valueWithoutParens###| |');
			}
				
			cfmlFilterCriteria.filter = StructNew();
			cfmlFilterCriteria.filter.serSrchArray = filterArray;
			cfmlFilterCriteria.defaultSortColumn = inputPropStruct.activeFlagField & '|asc';
		}
		
		if ( StructKeyExists(inputPropStruct,"sortByField") and inputPropStruct.sortByField NEQ '--')
		{
			cfmlFilterCriteria.defaultSortColumn = inputPropStruct.sortByField & '|asc';
		}
			
		if (NOT StructIsEmpty(cfmlFilterCriteria))
			inputPropStruct.filterCriteria = Server.CommonSpot.UDF.util.WDDXEncode(cfmlFilterCriteria);
	
		if (StructKeyExists(inputPropStruct, 'filterCriteria') AND IsWDDX(inputPropStruct.filterCriteria))
		{
			cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(inputPropStruct.filterCriteria);	
			if ( StructKeyExists(cfmlFilterCriteria,"filter") )		
				filterArray = cfmlFilterCriteria.filter.serSrchArray;
			sortColumn = ListFirst(cfmlFilterCriteria.defaultSortColumn,'|');
			sortDir = ListLast(cfmlFilterCriteria.defaultSortColumn,'|');
		}
	
		if (StructKeyExists(inputPropStruct,"customElement") and Len(inputPropStruct.customElement))
		{
			if( StructKeyExists(inputPropStruct, "displayField") AND LEN(inputPropStruct.displayField) AND inputPropStruct.displayField neq "--Other--" )
				fieldList = '#inputPropStruct.displayField#,#inputPropStruct.valueField#';
			else if( inputPropStruct.displayField eq "--Other--" AND inputPropStruct.DisplayFieldBuilder neq '' )
			{
				start = 1;
				while( true )
				{
					start = FindNoCase( Chr(171), inputPropStruct.DisplayFieldBuilder, start );
					if( start )
					{
						end = FindNoCase( Chr(187), inputPropStruct.DisplayFieldBuilder, start );
						if( end )
						{
							fld = Mid( inputPropStruct.DisplayFieldBuilder, start + 1, (end - (start+1)) );
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
				if( NOT FindNoCase( inputPropStruct.valueField, fieldList ) )
					fieldList = ListAppend( fieldList, inputPropStruct.valueField ); 			
			}
			else
			{
				fieldList = inputPropStruct.valueField;
			}
			
			if (NOT Len(sortColumn) AND NOT Len(sortDir))
			{
				sortColumn = ListFirst(fieldList);
				sortDir = 'asc';
			}
			
			if (NOT ArrayLen(filterArray))
				filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';
			
			ceData = ceObj.getRecordsFromSavedFilter(elementID=ceFormID, queryEngineFilter=filterArray, columnList=fieldList, orderBy=sortColumn, orderByDirection=sortDir, Limit=0);
			
			if (ceData.ResultQuery.RecordCount)
			{
				ArraySet(formIDColArray, 1, ceData.ResultQuery.RecordCount, ceFormID);
				ArraySet(formNameColArray, 1, ceData.ResultQuery.RecordCount, inputPropStruct.customElement);
			}
			
			QueryAddColumn(ceData.ResultQuery, 'formID', formIDColArray);
			QueryAddColumn(ceData.ResultQuery, 'formName', formIDColArray);
		}
	</cfscript>
	
	<!--- if read only we only need the current selected records --->
	<cfif arguments.isReadOnly AND StructKeyExists(ceData, 'ResultQuery')>
		<cfquery name="ceData.ResultQuery" dbtype="query">
			select * from ceData.ResultQuery
				<cfif ListLen(currentValue) gt 1>
					where #inputPropStruct.ValueField# IN ( #ListQualify(currentValue, "'")# )
				<cfelse>
					where #inputPropStruct.ValueField# = '#currentValue#'
				</cfif>
		</cfquery>
	</cfif>
	
	<cfscript>
		if (StructKeyExists(ceData, 'ResultQuery'))
			returnData = ceData.ResultQuery;
		
		return returnData;
	</cfscript>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderSelectionList
Summary:
	Return the HTML for selection list for the custom elemnt select field
Returns:
	Query
Arguments:
	Struct - propertiesStruct
	String - fqFieldName
	String - fieldCurrentValue
	Boolean - isReadOnly
	Array - dataArray
History:
 	2014-03-07 - DJM - Created
--->
<cffunction name="renderSelectionList" access="public" returntype="string" hint="Return the HTML for selection list for the custom elemnt select field">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="fqFieldName" type="string" required="true" hint="Name of the field">
	<cfargument name="fieldCurrentValue" type="string" required="true" hint="Current value for the field">
	<cfargument name="isReadOnly" type="boolean" required="true" hint="Boolean value indicating if the field is read only">
	<cfargument name="dataArray" type="array" required="true" hint="Data array of the field">
	<cfscript>
		var formResultHTML = '';
		var inputPropStruct = arguments.propertiesStruct;
		var ceDataArray = arguments.dataArray;
		var readOnly = arguments.isReadOnly;
		var cfs_i = 0;
		var isSelected = false;
		var currentSelectedValue = '';
		var displayField = '';
		var value = '';
		var ceDataArrayLen = ArrayLen(ceDataArray);
	</cfscript>
	
	<cfsavecontent variable="formResultHTML">
		<cfif StructKeyExists(inputPropStruct,"multipleSelect") and StructKeyExists(inputPropStruct,"multipleSelectSize") and inputPropStruct.multipleSelect>
			<cfoutput><select multiple="multiple" size="#inputPropStruct.multipleSelectSize#" name='#arguments.fqFieldName#_select' class="#inputPropStruct.fldName# cls#arguments.fqFieldName#" id='#arguments.fqFieldName#_select' onchange='#arguments.fqFieldName#_loadSelection()'<cfif arguments.isReadOnly> disabled='disabled'</cfif>></cfoutput>
		<cfelse>							
			<cfoutput><select name='#arguments.fqFieldName#_select' class="#inputPropStruct.fldName# cls#arguments.fqFieldName#" id='#arguments.fqFieldName#_select' onchange='#arguments.fqFieldName#_loadSelection()'<cfif arguments.isReadOnly> disabled='disabled'</cfif>></cfoutput>
		</cfif>
				
		<cfif inputPropStruct.renderSelectOption>
			<cfoutput><option value=""> -- select -- </option></cfoutput>
		</cfif>
		
			<cfloop index="cfs_i" from="1" to="#ceDataArrayLen#">
			<cfscript>
				value = ceDataArray[cfs_i].Values[inputPropStruct.valueField];
				if( ListFindNoCase(arguments.fieldCurrentValue,value) )		// mark as selected if found in currentvalue
				{
					isSelected = true;
					if( NOT ListFindNoCase(currentSelectedValue, value) )	// make sure its not already in the list
						currentSelectedValue = ListAppend(currentSelectedValue, value);
				}	
				else
					isSelected = false;
			</cfscript>
             
			<cfoutput><option value="#value#"<cfif isSelected> selected="selected"</cfif>></cfoutput>
			
			<cfif inputPropStruct.displayField eq "--Other--" and Len(inputPropStruct.displayFieldBuilder)>
				<!--- // Convert the Field Builder String to Values from the element ---> 
				<cfset displayField = application.ADF.fields.renderDataValueStringfromFieldMask(ceDataArray[cfs_i].Values, inputPropStruct.displayFieldBuilder)>
				<cfoutput>#displayField#</cfoutput>
			<cfelse>
				<cfoutput>#ceDataArray[cfs_i].Values[inputPropStruct.displayField]#</cfoutput>
			</cfif>
			
			<cfoutput></option></cfoutput>
		</cfloop>
 		
		<cfoutput></select>		
		<!--- // hidden field to store the value --->
		<input type='hidden' name='#arguments.fqFieldName#' id='#inputPropStruct.fldName#' value='#currentSelectedValue#'></cfoutput>
	</cfsavecontent>
	<cfreturn formResultHTML>
</cffunction>

<!---
/* *************************************************************** */
Author:
	PaperThin, Inc.
Name:
	$renderCheckBoxRadio
Summary:
	Return the HTML for radio button/check box for the custom elemnt select field
Returns:
	Query
Arguments:
	Struct - propertiesStruct
	String - fqFieldName
	String - fieldCurrentValue
	Boolean - isReadOnly
	Array - dataArray
History:
 	2014-03-07 - DJM - Created
	2014-03-23 - JTP - Changed to have 'Select All' / 'Deselect All' links
--->
<cffunction name="renderCheckBoxRadio" access="public" returntype="string" hint="Return the HTML for radio button/check box for the custom elemnt select field">
	<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
	<cfargument name="fqFieldName" type="string" required="true" hint="Name of the field">
	<cfargument name="fieldCurrentValue" type="string" required="true" hint="Current value for the field">	
	<cfargument name="fieldTypeToRender" type="string" required="true" hint="Type of the field to render">
	<cfargument name="dataArray" type="array" required="true" hint="Data array of the field">
	<cfscript>
		var formResultHTML = '';
		var inputPropStruct = arguments.propertiesStruct;
		var ceDataArray = arguments.dataArray;
		var cfs_i = 0;
		var isSelected = 0;
		var currentSelectedValue = '';
		var displayField = '';
		var value = '';
		var ceDataArrayLen = ArrayLen(ceDataArray);
	</cfscript>
	
	<cfsavecontent variable="formResultHTML">
		<cfoutput><div id="#arguments.fqFieldName#_div" style="max-height:#inputPropStruct.heightValue#px; width:#inputPropStruct.widthValue#px; border: 1px solid grey; background-color:white; overflow:auto; padding:5px 5px;"></cfoutput>
		<cfloop index="cfs_i" from="1" to="#ceDataArrayLen#">
			<cfscript>
				value = ceDataArray[cfs_i].Values[inputPropStruct.valueField];							
				if( ListFind(arguments.fieldCurrentValue, value) )
				{
					isSelected = 1;
					if( NOT ListFindNoCase( currentSelectedValue, value ) )
						currentSelectedValue = ListAppend(currentSelectedValue, value);
				}	
				else
					isSelected = 0;

				if( inputPropStruct.displayField eq "--Other--" AND Len(inputPropStruct.displayFieldBuilder) )
				{
					// Convert the Field Builder String to Values from the element 
					displayField = application.ADF.fields.renderDataValueStringfromFieldMask(ceDataArray[cfs_i].Values, inputPropStruct.displayFieldBuilder);
				}	
				else
					displayField = ceDataArray[cfs_i].Values[inputPropStruct.displayField];
			</cfscript>
             
			<cfoutput>
				<div style="line-height:14px;">
				<input type="#fieldTypeToRender#" name="#arguments.fqFieldName#_select" class="#inputPropStruct.fldName# cls#arguments.fqFieldName#" id="#arguments.fqFieldName#_select_#value#" value="#value#"<cfif isSelected> checked="checked"</cfif>  onchange="#arguments.fqFieldName#_loadSelection()">
				<label for="#arguments.fqFieldName#_select_#value#" style="font-weight:normal; color:black;">#displayField#</label>
				</div>
			</cfoutput>
		</cfloop>
		
		<cfoutput></div></cfoutput>
		
		<cfif inputPropStruct.renderClearSelectionLink>
			<cfoutput>
			<div style="text-align: right; font-size:xx-small;">
				<cfif inputPropStruct.multipleSelect><div style="display:inline-block" id="#arguments.fqFieldName#_SelectAll"><a href="javascript:;">Select All</a></div>&nbsp;</cfif>
				<div style="display:inline-block" id="#arguments.fqFieldName#_DeselectAll"><a href="javascript:;">Deselect All</a></div>
			</div>
			</cfoutput>
		</cfif>
				
		<!--- // hidden field to store the value --->
		<cfoutput><input type="hidden" name="#arguments.fqFieldName#" id="#inputPropStruct.fldName#" value="#currentSelectedValue#"></cfoutput>
	</cfsavecontent>
	<cfreturn formResultHTML>
</cffunction>

</cfcomponent>