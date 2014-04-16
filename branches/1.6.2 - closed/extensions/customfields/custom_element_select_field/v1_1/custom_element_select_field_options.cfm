<cfscript>
	getProperties = QueryNew('');
	optionsStruct = StructNew();
	cfmlInputParams = StructNew();
</cfscript>

<!--- Get the properties for the form and field IDs passed --->
<cfquery name="getProperties" datasource="#Request.Site.DataSource#">
	SELECT d2.params as InputParams, d3.FieldID, d2.fieldName
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
		if (cfmlInputParams.CustomElement NEQ '' AND cfmlInputParams.DisplayField NEQ '' AND cfmlInputParams.ValueField NEQ '')
			optionsStruct = createOptionsStructure(propertiesStruct=cfmlInputParams,currentValues=attributes.currentValues,returnCurrentOnly=attributes.returnCurrentOnly); // Call function that would buid up the options struct
	}
	
	multiple = '';
	if( StructKeyExists(cfmlInputParams, 'MultipleSelect') AND cfmlInputParams.MultipleSelect )
		multiple = 'multiple';
	
	caller.optionsStruct = optionsStruct;
	caller.multiple = multiple;
</cfscript>

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
			
			ceFieldsArray = application.ADF.cedata.getTabsFromFormID(formID=ceID,recurse=true);
			if (ArrayLen(ceFieldsArray) AND StructKeyExists(ceFieldsArray[1],'fields') AND IsArray(ceFieldsArray[1].fields) AND ArrayLen(ceFieldsArray[1].fields))
			{
				for(index=1;index LTE ArrayLen(ceFieldsArray[1].fields);index=index+1)
				{
					fieldList = ListAppend(fieldList, ceFieldsArray[1].fields[index].fieldName);
					if (NOT Len(sortColumn) AND NOT Len(sortDir) AND index EQ 1)
					{
						sortColumn = ceFieldsArray[1].fields[index].fieldName;
						sortDir = 'asc';
					}
				}
			}
			
			if (NOT ArrayLen(filterArray))
				filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';
			ceData = ceObj.getRecordsFromSavedFilter(elementID=ceID,queryEngineFilter=filterArray,columnList=fieldList,orderBy=sortColumn,orderByDirection=sortDir);
		</cfscript>
		
		<cfif ceData.ResultQuery.RecordCount>
			<cfif arguments.returnCurrentOnly AND Len(arguments.currentValues)>
				<cfquery name="getFilteredRecords" dbtype="query">
					SELECT *
					  FROM ceData.ResultQuery
					 WHERE <CFMODULE TEMPLATE="/commonspot/utilities/handle-in-list.cfm" FIELD="#cfmlInputParams.valueField#" LIST="#arguments.currentValues#" CFSQLTYPE="cf_Sql_varchar">
				</cfquery>
			<cfelse>
				<cfset getFilteredRecords = ceData.ResultQuery>
			</cfif>
			
			<cfscript>		
				ArraySet(formIDColArray, 1, getFilteredRecords.RecordCount, ceID);
				ArraySet(formNameColArray, 1, getFilteredRecords.RecordCount, cfmlInputParams.customElement);
				
				QueryAddColumn(getFilteredRecords, 'formID', formIDColArray);
				QueryAddColumn(getFilteredRecords, 'formName', formIDColArray);
				ceDataArray = application.ADF.cedata.buildCEDataArrayFromQuery(getFilteredRecords);
				
				if( StructKeyExists(cfmlInputParams, "displayField") AND LEN(cfmlInputParams.displayField) AND cfmlInputParams.displayField neq "--Other--" ) 
					ceDataArray = application.ADF.cedata.arrayOfCEDataSort(ceDataArray, sortColumn);
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