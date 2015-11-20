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
	Custom Element Hierarchy Selector
Name:
	custom_element_hierarchy_selector_base.cfc
Summary:
	This the base component for the Custom Element Hierarchy Selector field
ADF Requirements:
	
History:
	2014-01-16 - DJM - Created
	2014-01-29 - GAC - Converted to use AjaxProxy and the ADF Lib
    2014-04-21 - JTP - Added logic so that if filter has an expression we don't cache it
--->
<cfcomponent output="false" displayname="custom_element_hierarchy_selector_base" extends="ADF.core.Base" hint="Contains base functions to handle hierarchy selector">
	
	<cfscript>
		// Path to this CFT
		variables.cftPath = "/ADF/extensions/customfields/custom_element_hierarchy_selector";
	</cfscript>
	
	<cffunction name="getFields" returnformat="json" access="remote" hint="Get the fields for a custom element">
        <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		
        <cfscript>
			var result = QueryNew('');
			var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			var resultData = '';
			var elementDetails = customElementObj.getInfo(elementID=arguments.elementID);
		</cfscript>
		
		<cftry>
			<cfscript>
				resultData = customElementObj.getFields(elementID=arguments.elementID);
			</cfscript>
			<cfquery name="result" dbtype="query">
				SELECT ID, Label AS Name, Type, '#elementDetails.Name#' AS CustomElementName
				  FROM resultData
			</cfquery>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				result = QueryNew('ErrorMsg');
				QueryAddRow(result, 1);
				QuerySetCell(result, 'ErrorMsg', "Error occurred while trying to retrieve data the fields for the element.");
			</cfscript>
		</cfcatch>
		</cftry>
        <cfreturn result>
    </cffunction>
	
	<cffunction name="renderStyles" access="public" returntype="void" hint="Method to render the styles for datamanager">		
        <cfargument name="propertiesStruct" type="struct" required="true" hint="Properties structure for the field">
		<cfscript>
			var renderData = '';
		</cfscript>
		<cfsavecontent variable="renderData">
			<cfoutput><link rel="stylesheet" type="text/css" href="#variables.cftPath#/custom_element_hierarchy_selector_styles.css" /></cfoutput>
		</cfsavecontent>
		<cfoutput>#renderData#</cfoutput>
    </cffunction>
	
	<cffunction name="getFilteredData" returntype="array" access="public" hint="Get the data filtered for the field of the custom elemnt">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties for the field">
		<cfargument name="currentValues" type="string" required="true" hint="Input the current values for the field">
		<cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		<cfargument name="fieldID" type="numeric" required="true" hint="Custom element field ID">
		
		<cfscript>
			var dataMemArray = ArrayNew(1);
			var inputProps = arguments.propertiesStruct;
		</cfscript>
		
		<cflock name="objHierarchy" timeout="5" type="readOnly">
			<cfscript>
				if (StructKeyExists(application, 'objectHierarchyCustomField') 
					AND StructKeyExists(Application.objectHierarchyCustomField, arguments.elementID)
					AND StructKeyExists(Application.objectHierarchyCustomField[arguments.elementID], arguments.fieldID)
					AND StructKeyExists(Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID], 'cache'))
				{	
					dataMemArray = Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].cache;
				}	
			</cfscript>
		</cflock>
		
		<cfscript>
		/*
			if (ArrayLen(dataMemArray) AND NOT IsSimpleValue(dataMemArray[1]))
			{
				for (arrayIndex=1; arrayIndex LTE ArrayLen(dataMemArray); arrayIndex=arrayIndex+1)
				{
					if( ListFindNoCase(arguments.currentValues, dataMemArray[arrayIndex].id) 
							OR (inputProps.selectionType EQ 'multiAuto' AND ListFindNoCase(arguments.currentValues, dataMemArray[arrayIndex].parent)))
					{
						if (NOT StructKeyExists(dataMemArray[arrayIndex], 'state'))
							dataMemArray[arrayIndex]['state'] = StructNew();
						
						dataMemArray[arrayIndex]['state']['selected'] = true;
					}
				}				
			}
			*/
			return dataMemArray;
		</cfscript>
		
    </cffunction>
	
	<cffunction name="getFieldName" returntype="string" access="private" hint="Get the name of the field for a provided field ID from the query">
        <cfargument name="allFieldsQuery" type="query" required="true" hint="Input the query for all fields of the CE">
		<cfargument name="fieldID" type="numeric" required="true" hint="Input the ID of the field for which to retun the field name">
		<cfscript>
			var qryFieldName = '';
			var returnStr = '';
		</cfscript>
		<cftry>
			<cfquery name="qryFieldName" dbtype="query">
				SELECT Name
				  FROM arguments.allFieldsQuery 
				 WHERE ID = <cfqueryparam value="#arguments.fieldID#" cfsqltype="cf_sql_integer">
			</cfquery>
		<cfcatch>
			<cfscript>
				returnStr = 'Error: An error occurred while trying to get the field name for the provided field ID.';
			</cfscript>
		</cfcatch>
		</cftry>
		
		<cfscript>
			if (NOT Len(returnStr))
			{
				if (qryFieldName.RecordCount)
				{
					// returnStr = ListRest(qryFieldName.Name,'_');
					returnStr = qryFieldName.Name;
				}
				else
					returnStr = "Error: The specified field ID '#arguments.fieldID#' does not exist for this custom element.";
			}
			
			return returnStr;
		</cfscript>
	</cffunction>
	
	<cffunction name="isMemoryStructureGood" returntype="boolean" access="public" hint="Check if the memory is good or not and rebuild the memory cache data">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Properties for the field">
		<cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		<cfargument name="fieldID" type="numeric" required="true" hint="Custom element field ID">
		
        <cfscript>
			var getRecords = '';
			var isMemGood = 1;
			var cacheLastUpdate = '';
			var fieldProperties = arguments.propertiesStruct;
			var objLastUpdate = request.site.availControls[fieldProperties.customElement].lastUpdateSinceRestart;
			var cacheData = ArrayNew(1);
			var cfmlFilterCriteria = StructNew();
			var filterArray = ArrayNew(1);
			var defaultSortColumn = '';
			var i = 0;
			var memoryCache = StructNew();
			var cachedFilterArray = ArrayNew(1);
			var currentFilterArray = ArrayNew(1);
			var z = 0;
		</cfscript>
		
		<cflock name="objHierarchy" timeout="5" type="readOnly">
			<cfscript>	
				if (StructKeyExists(application, 'objectHierarchyCustomField')
					AND StructKeyExists(application.objectHierarchyCustomField, arguments.elementID)
					AND StructKeyExists(application.objectHierarchyCustomField[arguments.elementID], arguments.fieldID))
				{
					memoryCache = application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID];
				}
			</cfscript>
		</cflock>
		
		<cfscript>
			if (NOT StructIsEmpty(memoryCache))
			{
				cacheLastUpdate = memoryCache.lastUpdate;
				cacheData = memoryCache.cache;
					 
				if(ArrayLen(cacheData) AND (NOT IsDate(objLastUpdate) OR DateCompare(cacheLastUpdate, objLastUpdate) eq 1))
					isMemGood = 1;  
				else
					isMemGood = 0;
				
				if (isMemGood)
				{
					if (memoryCache.customElement NEQ fieldProperties.customElement
					OR memoryCache.parentField NEQ fieldProperties.parentField
					OR memoryCache.displayField NEQ fieldProperties.displayField
					OR memoryCache.valueField NEQ fieldProperties.valueField
					OR memoryCache.rootValue NEQ fieldProperties.rootValue
					OR memoryCache.rootNodeText NEQ fieldProperties.rootNodeText)
						isMemGood = 0;
				}
				
				if (isMemGood)
				{
					if (StructKeyExists(fieldProperties, 'filterCriteria') AND IsWDDX(fieldProperties.filterCriteria))
					{
						cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(fieldProperties.filterCriteria);			
						filterArray = cfmlFilterCriteria.filter.serSrchArray;
						defaultSortColumn = cfmlFilterCriteria.defaultSortColumn;
					}
					if (NOT ArrayLen(filterArray))
						filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';
						
					// check if filter contains #. If so assume filter has expression and make dynamic
					for( z=1; z lte ArrayLen(filterArray); z=z+1 )
					{
						if( Find( '##', filterArray[z] ) )
						{
							isMemGood = 0;
							break;
						}
					}	
				
					if (memoryCache.defaultSortColumn NEQ defaultSortColumn)
						isMemGood = 0;
					else
					{
						cachedFilterArray = memoryCache.filterArray;
						currentFilterArray = filterArray;
						if ((ArrayLen(cachedFilterArray) AND NOT ArrayLen(currentFilterArray)) 
						OR (ArrayLen(currentFilterArray) AND NOT ArrayLen(cachedFilterArray))
						OR ArrayLen(currentFilterArray) NEQ ArrayLen(cachedFilterArray))
							isMemGood = 0;
						else
						{
							for (i=1;i LTE ArrayLen(currentFilterArray);i=i+1)
							{
								if (currentFilterArray[i] NEQ cachedFilterArray[i])
								{
									isMemGood = 0;
									break;
								}
							}
						}
					}
				}
			}
			else
			{
				isMemGood = 0;
			}
			return isMemGood;
		</cfscript>
    </cffunction>
	

	<!---
		buildMemoryStructure()

		History:
			Fixed issue where if child node was ordered before parent, we would drop nodes.
	--->
	<cffunction name="buildMemoryStructure" returntype="void" access="public" hint="Build the memory structure" output="yes">
		<cfargument name="propertiesStruct" type="struct" required="true" hint="Memory cache name">
      <cfargument name="elementID" type="numeric" required="true" hint="Custom element ID">
		<cfargument name="fieldID" type="numeric" required="true" hint="Custom element field ID">
		
        <cfscript>
			var ceData = QueryNew('');
			var inputPropStruct = arguments.propertiesStruct;
			var cfmlFilterCriteria = StructNew();
			var customElementObj = Server.CommonSpot.ObjectFactory.getObject('CustomElement');
			var ceFields = customElementObj.getFields(elementID=inputPropStruct.customElement);
			var parentFieldName = getFieldName(allFieldsQuery=ceFields, fieldID=inputPropStruct.parentField);
			var displayFieldName = '';
			var valueFieldName = '';
			var fieldList = '';
			var errorMsg = '';
			var getFormattedData = QueryNew('');
			var dataArray = ArrayNew(1);
			var arrayIndex = 1;
			var filterArray = ArrayNew(1);
			var sortColumn = '';
			var sortDir = 'asc';
			var addedParents = StructNew();
			var defaultSortColumn = '';
		</cfscript>

		<cftry>
			<cfscript>
				if (ListFirst(parentFieldName,':') NEQ 'Error')
				{
					fieldList = parentFieldName;
					sortColumn = parentFieldName;
					displayFieldName = getFieldName(allFieldsQuery=ceFields, fieldID=inputPropStruct.displayField);
				}
				else
					errorMsg = ListRest(parentFieldName,':');

				
				if( NOT Len(ErrorMsg) AND ListFirst(displayFieldName,':') NEQ 'Error' )
				{
					if( NOT ListFindNoCase(fieldList, displayFieldName) AND displayFieldName neq '' )
						fieldList = ListAppend(fieldList, displayFieldName);
					valueFieldName = getFieldName(allFieldsQuery=ceFields, fieldID=inputPropStruct.valueField);
				}
				else
					errorMsg = ListRest(displayFieldName,':');
			</cfscript>
			
			<cfif NOT Len(ErrorMsg) AND ListFirst(valueFieldName,':') NEQ 'Error'>
				<cfscript>
					if (NOT ListFindNoCase(fieldList, valueFieldName))
						fieldList = ListAppend(fieldList, valueFieldName);
						
					if (StructKeyExists(inputPropStruct, 'filterCriteria') AND IsWDDX(inputPropStruct.filterCriteria))
					{
						cfmlFilterCriteria = Server.CommonSpot.UDF.util.WDDXDecode(inputPropStruct.filterCriteria);			
						filterArray = cfmlFilterCriteria.filter.serSrchArray;
						sortColumn = ListFirst(cfmlFilterCriteria.defaultSortColumn,'|');
						sortDir = ListLast(cfmlFilterCriteria.defaultSortColumn,'|');
						defaultSortColumn = cfmlFilterCriteria.defaultSortColumn;
					}
					
					if (NOT ArrayLen(filterArray))
						filterArray[1] = '| element_datemodified| element_datemodified| <= | | c,c,c| | ';

					if (NOT ListFindNoCase(fieldList, sortColumn))
						fieldList = ListAppend(fieldList, sortColumn);
						
					ceData = customElementObj.getRecordsFromSavedFilter( elementID=inputPropStruct.customElement, 
																				queryEngineFilter=filterArray, 
																				columnList=fieldList, 
																				orderBy=sortColumn, 
																				orderByDirection=sortDir, 
																				limit=0);
				</cfscript>
				
				<cfquery name="getFormattedData" dbtype="query">
					SELECT #parentFieldName# AS ParentField, #displayFieldName# AS DisplayField, #valueFieldName# AS ValueField
					  FROM ceData.ResultQuery
				 	ORDER BY #parentFieldName#
				<cfif sortColumn NEQ parentFieldName>
				 , #sortColumn# #sortDir#
				</cfif>
				</cfquery>

				<cfscript>
					if( inputPropStruct.RootNodeText neq '' )
					{
						arrayIndex = 1;
						dataArray[arrayIndex] = StructNew();
						dataArray[arrayIndex]['id'] = '#arguments.fieldID#_#inputPropStruct.rootValue#';
						dataArray[arrayIndex]['text'] = inputPropStruct.rootNodeText;
						dataArray[arrayIndex]['parent'] = '##';
					}						
					addedParents[inputPropStruct.rootValue] = StructNew();
				</cfscript>

				<cfif getFormattedData.RecordCount>
					<cfloop query="getFormattedData">
						<cfscript>
							// if the parent node has not already been added, add it and store off its offset into the array. 
							// 	They must exist before child nodes.
							if( NOT StructKeyExists( addedParents, getFormattedData.ParentField ) )
							{	
								arrayIndex = ArrayLen(dataArray) + 1;
								dataArray[arrayIndex] = StructNew();
								addedParents[getFormattedData.ParentField] = arrayIndex;
							}
							
							// If this node was already added into the array (processed a child already), get offset and 
							//		add info to that structure
							if( StructKeyExists( addedParents, getFormattedData.ValueField ) )
							{
								arrayIndex = addedParents[getFormattedData.ValueField];
							}	
							else	// otherwise append to the array
							{	
								arrayIndex = ArrayLen(dataArray) + 1;
								addedParents[getFormattedData.ValueField] = arrayIndex;
							}	
								
							dataArray[arrayIndex] = StructNew();
							dataArray[arrayIndex]['id'] = '#arguments.fieldID#_#getFormattedData.ValueField#';
							dataArray[arrayIndex]['text'] = "#getFormattedData.DisplayField#";
							
							if( getFormattedData.ParentField EQ inputPropStruct.rootValue )
							{
								if( inputPropStruct.RootNodeText neq '' )
									dataArray[arrayIndex]['parent'] = '#arguments.fieldID#_#inputPropStruct.rootValue#';
								else
									dataArray[arrayIndex]['parent'] = '##';
							}	
							else
								dataArray[arrayIndex]['parent'] = '#arguments.fieldID#_#getFormattedData.ParentField#';

						</cfscript>
					</cfloop>
				</cfif>
			<cfelse>
				<cfscript>
					errorMsg = ListRest(valueFieldName,':');
				</cfscript>
			</cfif>
		<cfcatch>
			<CFMODULE TEMPLATE="/commonspot/utilities/log-append.cfm" comment="Error while trying to retrieve the fields: #cfcatch.message# :: #cfcatch.detail#">
			<cfscript>
				errorMsg = "Error occurred while trying to retrieve data the fields for the element.";
			</cfscript>
		</cfcatch>
		</cftry>

		<cfif Len(errorMsg)>
			<cfset dataArray[1] = errorMsg>
		<cfelse>
			<cflock name="objHierarchy" timeout="5" type="Exclusive"> 
			    <cfscript>
					if (NOT StructKeyExists(Application, 'objectHierarchyCustomField'))
						Application.objectHierarchyCustomField = StructNew();
					if (NOT StructKeyExists(Application.objectHierarchyCustomField, arguments.elementID))
						Application.objectHierarchyCustomField[arguments.elementID] = StructNew();
					if (NOT StructKeyExists(Application.objectHierarchyCustomField[arguments.elementID], arguments.fieldID))
						Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID] = StructNew();
					
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].lastUpdate = Request.FormattedTimestamp;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].cache = dataArray;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].customElement = propertiesStruct.customElement;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].parentField = propertiesStruct.parentField;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].displayField = propertiesStruct.displayField;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].valueField = propertiesStruct.valueField;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].rootValue = propertiesStruct.rootValue;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].rootNodeText = propertiesStruct.rootNodeText;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].filterArray = filterArray;
					Application.objectHierarchyCustomField[arguments.elementID][arguments.fieldID].defaultSortColumn = defaultSortColumn;
				</cfscript>
			</cflock>
		</cfif>
    </cffunction>

</cfcomponent>